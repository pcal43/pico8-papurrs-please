local GameScreen = {}
GameScreen.new = function()
    local self = {}

    printh("init1!")

    self.weekdayNumber = 1
    self.centerMessage = nil
    self.scrollPos = 0
    self.targetPos = 1
    self.canPress = false
    self.showStatusIcons = false
    self.showCats = false
    self.showPoster = false
    self._last_time = time()
    self.coroutine = nil
    self.totalCatsThisWeek = 0
    self.foundCatsThisWeek = 0
    self.isGameOver = false

    function self.draw()
        cls(PEACH) -- offwhite background

        -- draw poster at the top
        if self.showPoster then
            if #self.posters > 0 then
                self.posters[1].draw()
            end
        end

        if self.showStatusIcons then
            -- draw icons: left (sprite 8) with catsRemaining, and clock (sprite 10) right with seconds
            palt(BLACK, false) -- black is black, beige is transparent
            -- left icon and catsRemaining beneath
            local left_x = CLOCK_MARGIN
            local left_y = CLOCK_MARGIN
            spr(POSTER_ICON, left_x, left_y, 2, 2)
            local cats = flr(#self.posters)
            local cats_s = tostr(cats)
            local cats_w = #cats_s * 4
            local cats_tx = (left_x + 8) - (cats_w / 2)
            local cats_ty = left_y + 16 + 2
            print(cats_s, cats_tx, cats_ty, DARK_BLUE)
            -- clock (upper-right) and secondsRemaining beneath
            local clock_x = 128 - 16 - CLOCK_MARGIN
            local clock_y = CLOCK_MARGIN
            spr(CLOCK_ICON, clock_x, clock_y, 2, 2)
            local secs = flr(self.secondsRemaining)
            local s = tostr(secs)
            local txt_w = #s * 4
            local tx = (clock_x + 8) - (txt_w / 2)
            local ty = clock_y + 16 + 2
            print(s, tx, ty, DARK_BLUE)
            palt()
        end

        -- draw the visible cats
        if self.showCats then
            local base_index = flr(self.scrollPos)
            for j = -1, 1 do
                local catIndex = base_index + j
                if catIndex > 0 and catIndex <= #self.catList then
                    self.catList[catIndex].draw()
                end
            end
        end

        -- draw center message if present
        if self.centerMessage then
            printCentered(self.centerMessage, SCREEN_WIDTH/2, PROMPT_TEXT_Y, DARK_BLUE)
        end
    end

    function self.update()
        if self.coroutine then
            resume(self.coroutine)
        end
 
        -- update animations - we want to do these in all modes
        if self.showPoster then
            if #self.posters > 0 then
                self.posters[1].update()
            end
        end

        if self.showCats then
            -- adjust scrollPos to 'catch up' with targetPos            
            local diff = self.targetPos - self.scrollPos
            local dist = abs(diff)
            if dist > 0 then
                local step = dist * 0.2
                if step < 0.1 then step = 0.1 end
                if step >= dist then
                    self.scrollPos = self.targetPos
                else
                    self.scrollPos = self.scrollPos + sgn(diff) * step
                end
            end
            -- update the x position of the visible cats
            local base_index = flr(self.scrollPos)
            local frac = self.scrollPos - base_index
            local spacing = CAT_WIDTH + SPACE_BETWEEN_CATS
            for j = -1, 1 do
                local catIndex = base_index + j
                if catIndex > 0 and catIndex <= #self.catList then
                    -- position each slot, then shift by fractional progress toward next slot
                    self.catList[catIndex].x = SCREEN_WIDTH/2 + (j * spacing) - (frac * spacing)
                    self.catList[catIndex].update()
                end
            end
        end
    end

    function self.startDay()
        local weekday = WEEKDAYS[self.weekdayNumber]
        self.posters, self.catList = generatePostersAndCats(weekday.cats, weekday.posters, weekday.minTraits, weekday.maxTraits, weekday.traits)
        self.scrollPos = 0
        self.targetPos = 1
        self.secondsRemaining = weekday.time
        self.showCats = false
        self.showPoster = false                
        self.showStatusIcons = true
        self.centerMessage = "\^w"..weekday.name..[[


tHERE aRE ]]..#self.catList..[[ lOST cATS tODAY. 

hELP tHEM gET hOME!

rEADY?


press ❎ to start]]
        self.coroutine = cocreate(function()
            while btn(BUTTON_X) do  -- make sure they release the button
                yield()
            end
            while not btn(BUTTON_X) do 
                yield()
            end
        printh("XXXXX")

            self.startPicking()
        end)
    end

    function self.startPicking()
        self.showCats = true
        self.showPoster = true
        self.showStatusIcons = true
        self.coroutine = cocreate(function()
            while true do
                if self.posters and #self.posters < 1 then
                    self.startChecking()
                    return
                end

                -- update countdown
                local now = time()
                local dt = now - (self._last_time or now)
                self._last_time = now
                if dt > 0 then
                    if self.secondsRemaining > dt then
                        self.secondsRemaining = self.secondsRemaining - dt
                    else
                        self.secondsRemaining = 0
                    end
                end

                -- discrete taps: left decrements, right increments
                if btn(BUTTON_LEFT) then
                    if self.canPress then
                        if self.targetPos > 1 then
                            self.targetPos = self.targetPos - 1
                        end
                        self.canPress = false
                    end
                elseif btn(BUTTON_RIGHT) then
                    if self.canPress then
                        if self.targetPos < #self.catList then
                            self.targetPos = self.targetPos + 1
                        end
                        self.canPress = false
                    end
                elseif btn(BUTTON_UP) then
                    if self.canPress or false then
                        -- cycle to the next poster
                        if #self.posters > 1 then
                            -- Animate current poster up off screen
                            self.posters[1].targetY = POSTER_NEW_DISPLAY_POS - 20
                            -- Move it to the back of the queue
                            local currentPoster = self.posters[1]
                            del(self.posters, currentPoster)
                            add(self.posters, currentPoster)
                            -- Animate the next poster down
                            self.posters[1].y = POSTER_NEW_DISPLAY_POS
                            self.posters[1].targetY = POSTER_TOP_DISPLAY_POS
                        end
                        self.canPress = false
                    end
                elseif btn(BUTTON_DOWN) then
                    if self.canPress then
                        -- If they press the action button, that means they think
                        -- the currently-selected cat is the lost cat described in the 
                        -- current poster.  Check if the cat has a poster; if it does not, 
                        -- Pop the current poster ([1]) off self.posters and assign it
                        -- to the cat that is in the middle of the screen
                        local selectedCat = self.catList[self.targetPos]
                        if selectedCat and not selectedCat.poster and #self.posters > 0 then
                            -- Assign the poster to the cat
                            selectedCat.poster = self.posters[1]
                            selectedCat.poster.speed = POSTER_FLOAT_SPEED
                            selectedCat.poster.targetY = POSTER_BOT_DISPLAY_POS
                            
                            -- Remove the poster from the list
                            del(self.posters, self.posters[1])
                            
                            -- Animate the next poster moving down
                            if #self.posters > 0 then
                                self.posters[1].y = POSTER_NEW_DISPLAY_POS
                                self.posters[1].targetY = POSTER_TOP_DISPLAY_POS
                            end
                        end
                        self.canPress = false
                    end
                else
                    self.canPress = true
                end
                if self.posters[1] then
                    local pronoun = self.posters[1].isFemale and "hER" or "hIM"
                    --self.centerMessage = " \148: cHANGE pOSTER\n\139\145: cHANGE cAT     "
                    self.centerMessage = "\139\145: cHANGE cAT     "                    
                    if self.targetPos == self.scrollPos then
                        local selectedCat = self.catList[self.targetPos]
                        if selectedCat and not selectedCat.poster then
                            self.centerMessage = self.centerMessage.."\n \131: tHIS iS "..pronoun.."! "
                        end
                    end
                end
            yield()

            end
        end)
    end

    function self.startChecking()
        self.coroutine = cocreate(function()
            local correct = 0
            self.showStatusIcons = false

            self.centerMessage = "dONE.  lET'S cHECK!"
            for j = 2, 1 * TICKS_PER_SECOND do  
                yield() 
            end
            self.centerMessage = nil

            for i = 1, #self.catList do
                self.targetPos = i
                while self.scrollPos != self.targetPos do -- wait for scrolling to finish
                    yield()
                end
                local cat = self.catList[i]
                if cat.poster then
                    cat.poster.targetY = POSTER_TOP_DISPLAY_POS  -- move the poster up
                    while cat.poster.y > cat.poster.targetY do   -- wait for it to get there
                        yield()
                    end
                    cat.adornmentSpriteId = QUESTION_ICON

                    for j = 1, .5 * TICKS_PER_SECOND do 
                        yield() 
                    end
                    if cat.poster.isMatch(cat.traits) then
                        cat.adornmentSpriteId = MATCH_ICON
                        correct += 1
                        sfx(SOUND_MEOW)
                    else
                        cat.adornmentSpriteId = BAD_MATCH_ICON
                        sfx(SOUND_BUZZ)
                    end
                    for j = 1, .5 * TICKS_PER_SECOND do 
                        yield() 
                    end
                end
            end
            for j = 1, 1 * TICKS_PER_SECOND do 
                yield() 
            end
            -- scroll cats off screen and wait for scrolling to finish
            self.targetPos = #self.catList + 2
            while self.scrollPos != self.targetPos do
                yield()
            end
            -- display score summary
            self.message = ""
            local scoreMessage = "\^w"..WEEKDAYS[self.weekdayNumber].name.."\n\nlost cats: "..#self.catList.."\n    found: "..correct
            if correct == #self.catList then
                scoreMessage = scoreMessage.."\n\n\^wpurrfect!"
            end
            self.centerMessage = scoreMessage
            -- wait before showing continue prompt
            for j = 1, 1 * TICKS_PER_SECOND do  
                yield() 
            end
            -- wait for button press
            self.centerMessage = scoreMessage.."\n\npress ❎ to continue"
            while not btn(BUTTON_X) do 
                yield()
            end
            
            -- Update week totals
            self.totalCatsThisWeek += #self.catList
            self.foundCatsThisWeek += correct
            

            if self.weekdayNumber == #WEEKDAYS then
                self.doEndGame()
            else
                self.weekdayNumber += 1
                self.startDay()
            end
        end)
    end

    function self.doEndGame()
        self.showCats = false
        self.showPoster = false
        self.showStatusIcons = false
        
        self.coroutine = cocreate(function()
            -- Display final score
            local scoreMessage = "\^wend of week!\n\ntOTAL lOST cATS tHIS wEEK:\n"..self.totalCatsThisWeek.."\nyOU fOUND:\n"..self.foundCatsThisWeek
            
            if self.foundCatsThisWeek == self.totalCatsThisWeek then
                scoreMessage = scoreMessage.."\n\n\^wpURRFECT!"
            end
            self.centerMessage = scoreMessage
            for j = 1, 2 * TICKS_PER_SECOND do  
                yield() 
            end
            self.centerMessage = scoreMessage.."\n\npress ❎ to continue"
            while btn(BUTTON_X) do
                yield()
            end
            while not btn(BUTTON_X) do
                yield()
            end
            self.coroutine = nil
            self.isGameOver = true
        end)
    end


    function self.isDone()
        return self.isGameOver
    end

    return self
end



-- Returns lists of Cat and Poster objects, each of length count.  Each poster
-- will have a random number of traits (between minTraits and maxTraits).  
-- The traits for the Cats and Posters will be chosen such that there will be a bijection
-- between Cats and Posters: for each Cat returned there will be exactly one Poster that
-- is a match for it (as defined by Poster.isMatch), and vice versa.
--
-- Other than that, the Poster traits will be chosen randomly.  The TraitKeys will be chosen 
-- randomly from those in the list TraitKeys (in Traits.lua).  The values for
-- each Poster trait will be randomly chosen.  A Poster will have at most one mapping for
-- any given TraitKey.
--
-- Cats will have all of the TraitKeys defined in their trait tables, with the TraitValues
-- for each again randomly chosen.  Again, provided that the 1:1 matching relationship
-- between Cats and Posters is maintained
--
-- If the 1:1 matching constraint cannot be maintained, and error should be printed 
-- and the 'count' reduced to the point where the constraints can be satisfied.

function generatePostersAndCats(catCount, posterCount, minTraits, maxTraits, posterTraitKeys)
    if catCount < posterCount then
        printh("error: catCount ("..catCount..") < posterCount ("..posterCount..")")
        return {}, {}
    end
    
    printh("generatePosters: "..posterCount.." posters for "..catCount.." cats, traits "..minTraits.."-"..maxTraits)
    
    local posters = {}
    local cats = {}
    local name_indeces = pickUniqueIntegers(catCount, 1, CAT_NAME_COUNT)
    
    -- Step 1: Generate unique cats with random trait combinations
    local usedCatCombos = {}
    local attempts = 0
    local maxAttempts = catCount * 50
    
    while #cats < catCount and attempts < maxAttempts do
        attempts += 1
        
        local catTraits = {}
        local catComboKey = ""
        for i = 1, #TraitKeys do
            local traitKey = TraitKeys[i]
            local possibleValues = TraitValues[traitKey]
            local idx = flr(rnd(#possibleValues)) + 1
            catTraits[traitKey] = possibleValues[idx]
            catComboKey = catComboKey..traitKey..":"..idx..","
        end
        
        if not usedCatCombos[catComboKey] then
            usedCatCombos[catComboKey] = true
            add(cats, Cat.new(TUXEDO_CAT, catTraits))
        end
    end
    
    if #cats < catCount then
        printh("warning: only generated "..#cats.." unique cats (requested "..catCount..")")
        catCount = #cats
        if posterCount > catCount then
            posterCount = catCount
        end
    end
    
    -- Step 2: Create posters for posterCount randomly selected cats
    local usedPosterCombos = {}
    local catsForPosters = pickUniqueIntegers(posterCount, 1, catCount)
    
    for i = 1, posterCount do
        local catIndex = catsForPosters[i]
        local cat = cats[catIndex]
        local foundValidPoster = false
        local posterAttempts = 0
        local maxPosterAttempts = 100
        
        while not foundValidPoster and posterAttempts < maxPosterAttempts do
            posterAttempts += 1
            
            -- Pick random number of traits and random trait keys
            local numTraits = minTraits + flr(rnd(maxTraits - minTraits + 1))
            local availableKeys = {}
            for i = 1, #posterTraitKeys do
                add(availableKeys, posterTraitKeys[i])
            end
            
            local selectedKeys = {}
            for i = 1, numTraits do
                if #availableKeys > 0 then
                    local idx = flr(rnd(#availableKeys)) + 1
                    add(selectedKeys, availableKeys[idx])
                    del(availableKeys, availableKeys[idx])
                end
            end
            
            -- Build poster traits from this cat's traits
            local posterTraits = {}
            local posterComboKey = ""
            for i = 1, #selectedKeys do
                local traitKey = selectedKeys[i]
                posterTraits[traitKey] = cat.traits[traitKey]
                posterComboKey = posterComboKey..traitKey..":"..cat.traits[traitKey].name..","
            end
            
            -- Check if this poster combo is unique
            if not usedPosterCombos[posterComboKey] then
                -- Check if this poster would accidentally match any OTHER cat
                local matchesOtherCat = false
                for i = 1, #cats do
                    if i != catIndex then
                        local otherCat = cats[i]
                        local matches = true
                        for traitKey, traitValue in pairs(posterTraits) do
                            if otherCat.traits[traitKey] != traitValue then
                                matches = false
                                break
                            end
                        end
                        if matches then
                            matchesOtherCat = true
                            break
                        end
                    end
                end
                
                if not matchesOtherCat then
                    usedPosterCombos[posterComboKey] = true
                    local name = requireNonNil(get_cat_name(name_indeces[catIndex]), "nil cat name")
                    local poster = Poster.new(name, name_indeces[catIndex] < CAT_NAME_FIRST_MALE, posterTraits)
                    add(posters, poster)
                    foundValidPoster = true
                end
            end
        end
        
        if not foundValidPoster then
            printh("error: couldn't create valid poster for cat "..catIndex)
            -- Still add a poster to maintain array structure, even if suboptimal
            local name = requireNonNil(get_cat_name(name_indeces[catIndex]), "nil cat name")
            local posterTraits = {}
            -- Use first minTraits traits from the cat
            local traitIdx = 0
            for _, traitKey in pairs(posterTraitKeys) do
                if traitIdx < minTraits then
                    posterTraits[traitKey] = cat.traits[traitKey]
                    traitIdx += 1
                end
            end
            local poster = Poster.new(name, name_indeces[catIndex] < CAT_NAME_FIRST_MALE, posterTraits)
            add(posters, poster)
        end
    end
    
    -- Shuffle cats so they're not in the same order as posters
    shuffleArray(cats)
    
    printh("generated "..#cats.." cats and "..#posters.." posters")
    return posters, cats
end

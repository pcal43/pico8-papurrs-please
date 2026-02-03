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
    self.totalPostersThisWeek = 0
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
        self.posters, self.catList = generatePostersAndCats(weekday.cats, weekday.catTraits, weekday.posterCount, weekday.posterTraitCount, weekday.posterTraits)
        self.scrollPos = 0
        self.targetPos = 1
        self.secondsRemaining = weekday.time
        self.showCats = false
        self.showPoster = false                
        self.showStatusIcons = true
        self.centerMessage = "\^w"..weekday.name..[[


tHERE aRE ]]..#self.posters..[[ lOST cATS tODAY. 

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
                    self.doAllChosen()
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
                        self.doTimesUp()
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

    function self.doTimesUp()
        self.coroutine = cocreate(function()
            self.centerMessage = "\^wtimes up!"
            for j = 1, 3 * TICKS_PER_SECOND do  
                yield() 
            end
            self.doChecks()
        end)
    end    

    function self.doAllChosen()
        self.coroutine = cocreate(function()
            self.centerMessage = "\^wall done!"
            for j = 1, 2 * TICKS_PER_SECOND do  
                yield() 
            end
            self.doChecks()
        end)
    end        

    function self.doChecks()
        self.showStatusIcons = false
        self.showPoster = false
        self.coroutine = cocreate(function()
            local correct = 0
            self.showStatusIcons = false
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
            local posterCount = WEEKDAYS[self.weekdayNumber].posterCount
            self.message = ""
            local scoreMessage = "\^w"..WEEKDAYS[self.weekdayNumber].name.."\n\nlost cats: "..posterCount.."\n    found: "..correct
            if correct == posterCount then
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
            self.totalPostersThisWeek += posterCount
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
            local scoreMessage = "\^wend of week!\n\ntOTAL lOST cATS tHIS wEEK:\n"..self.totalPostersThisWeek.."\nyOU fOUND:\n"..self.foundCatsThisWeek
            
            if self.foundCatsThisWeek == self.totalPostersThisWeek then
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

function generatePostersAndCats(catCount, catTraits, posterCount, posterTraitCount, posterTraitKeys)
    if catCount < posterCount then
        printh("error: catCount ("..catCount..") < posterCount ("..posterCount..")")
        return {}, {}
    end
    
    printh("generatePosters: "..posterCount.." posters for "..catCount.." cats, "..posterTraitCount.." traits per poster")
    
    local posters = {}
    local cats = {}
    local name_indeces = pickUniqueIntegers(catCount, 1, CAT_NAME_COUNT)
    
    local usedPosterCombos = {}
    local usedCatCombos = {}
    local pairAttempts = 0
    local maxPairAttempts = posterCount * 200
    
    -- Step 1: Generate poster-cat pairs until we have enough
    while #posters < posterCount and pairAttempts < maxPairAttempts do
        pairAttempts += 1
        
        -- Generate a random poster with exactly posterTraitCount traits
        local availableKeys = {}
        for i = 1, #posterTraitKeys do
            add(availableKeys, posterTraitKeys[i])
        end
        
        local selectedKeys = {}
        for i = 1, posterTraitCount do
            if #availableKeys > 0 then
                local idx = flr(rnd(#availableKeys)) + 1
                add(selectedKeys, availableKeys[idx])
                del(availableKeys, availableKeys[idx])
            end
        end
        
        local posterTraits = {}
        local posterComboKey = ""
        for i = 1, #selectedKeys do
            local traitKey = selectedKeys[i]
            local possibleValues = TraitValues[traitKey]
            local valueIdx = flr(rnd(#possibleValues)) + 1
            posterTraits[traitKey] = possibleValues[valueIdx]
            posterComboKey = posterComboKey..traitKey..":"..valueIdx..","
        end
        
        if not usedPosterCombos[posterComboKey] then
            -- Try to create a matching cat for this poster
            local catAttempts = 0
            local maxCatAttempts = 50
            local foundValidCat = false
            
            while not foundValidCat and catAttempts < maxCatAttempts do
                catAttempts += 1
                
                local thisCatTraits = {}
                for traitKey, traitValue in pairs(posterTraits) do
                    thisCatTraits[traitKey] = traitValue
                end
                
                for i = 1, #TraitKeys do
                    local traitKey = TraitKeys[i]
                    if thisCatTraits[traitKey] == nil then
                        local possibleValues = TraitValues[traitKey]
                        local allowedIndices = catTraits[traitKey]
                        if allowedIndices then
                            local idx = allowedIndices[flr(rnd(#allowedIndices)) + 1]
                            thisCatTraits[traitKey] = possibleValues[idx]
                        else
                            local idx = flr(rnd(#possibleValues)) + 1
                            thisCatTraits[traitKey] = possibleValues[idx]
                        end
                    end
                end
                
                local catComboKey = ""
                for i = 1, #TraitKeys do
                    local traitKey = TraitKeys[i]
                    catComboKey = catComboKey..traitKey..":"..thisCatTraits[traitKey].name..","
                end
                
                if not usedCatCombos[catComboKey] then
                    -- Check if this cat matches exactly one existing poster (plus this new one)
                    local matchCount = 0
                    for i = 1, #posters do
                        if posters[i].isMatch(thisCatTraits) then
                            matchCount += 1
                            break
                        end
                    end
                    
                    -- Verify matches the new poster
                    local tempPoster = {traits = posterTraits, isMatch = Poster.new("temp", true, posterTraits).isMatch}
                    if tempPoster.isMatch(thisCatTraits) then
                        matchCount += 1
                    end
                    
                    if matchCount == 1 then
                        -- Success! Add both poster and cat
                        usedPosterCombos[posterComboKey] = true
                        usedCatCombos[catComboKey] = true
                        
                        local posterIndex = #posters + 1
                        local name = requireNonNil(get_cat_name(name_indeces[posterIndex]), "nil cat name")
                        add(posters, Poster.new(name, name_indeces[posterIndex] < CAT_NAME_FIRST_MALE, posterTraits))
                        add(cats, Cat.new(TUXEDO_CAT, thisCatTraits))
                        foundValidCat = true
                    end
                end
            end
        end
    end
    
    if #posters < posterCount then
        printh("warning: only generated "..#posters.." poster-cat pairs (requested "..posterCount..") after "..pairAttempts.." attempts")
    end
    
    -- Step 3: Generate additional cats if catCount > posterCount (these won't match any poster)
    attempts = 0
    maxAttempts = (catCount - posterCount) * 50
    
    while #cats < catCount and attempts < maxAttempts do
        attempts += 1
        
        local thisCatTraits = {}
        local catComboKey = ""
        for i = 1, #TraitKeys do
            local traitKey = TraitKeys[i]
            local possibleValues = TraitValues[traitKey]
            local allowedIndices = catTraits[traitKey]
            local idx
            if allowedIndices then
                idx = allowedIndices[flr(rnd(#allowedIndices)) + 1]
            else
                idx = flr(rnd(#possibleValues)) + 1
            end
            thisCatTraits[traitKey] = possibleValues[idx]
            catComboKey = catComboKey..traitKey..":"..possibleValues[idx].name..","
        end
        
        if not usedCatCombos[catComboKey] then
            -- Check if this cat would match any poster
            local matchesAnyPoster = false
            for i = 1, #posters do
                if posters[i].isMatch(thisCatTraits) then
                    matchesAnyPoster = true
                    break
                end
            end
            
            if not matchesAnyPoster then
                usedCatCombos[catComboKey] = true
                add(cats, Cat.new(TUXEDO_CAT, thisCatTraits))
            end
        end
    end
    
    if #cats < catCount then
        printh("warning: only generated "..#cats.." unique cats (requested "..catCount..")")
    end
    
    -- Shuffle cats so they're not in the same order as posters
    shuffleArray(cats)
    
    printh("generated "..#cats.." cats and "..#posters.." posters")
    return posters, cats
end

local GameScreen = {}
GameScreen.new = function(weekday)
    local self = {}

    -- states
    local PICKING = 0
    local PICKING_DONE = 1
    local CHECKING = 2
    local CHECKING_DONE = 3

    local MESSAGE_DELAY = 120

    self.state = PICKING
    self.messageTimer = 0
    self.message = "lost cat!"
    self.centerMessage = nil
    self.scrollPos = 0
    self.targetPos = 1
    self.canPress = false
    self.secondsRemaining = 60.0
    self._last_time = time()

    self.posters, self.catList = generatePostersAndCats(weekday.posters, weekday.minTraits, weekday.maxTraits, weekday.traits)
    self.catListSize = 10

    function self.draw()
        cls(PEACH) -- offwhite background

        -- draw poster at the top
        if #self.posters > 0 then
            self.posters[1].draw()
        end

        local header_h = 9
        local header_w = 84
        local header_x = (128 - header_w) / 2
        local header_y = 0
        rectfill(header_x - 1, header_y, header_x + 1 + header_w - 1, header_y + header_h, BLACK)
        print_center_top(self.message, 0, 5, YELLOW, 2) -- yellow text


        -- draw icons: left (sprite 8) with catsRemaining, and clock (sprite 10) right with seconds
        palt(BLACK, false) -- black is black, beige is transparent

        -- left icon and catsRemaining beneath
        local left_x = CLOCK_MARGIN
        local left_y = CLOCK_MARGIN
        spr(8, left_x, left_y, 2, 2)
        local cats = flr(#self.posters)
        local cats_s = tostr(cats)
        local cats_w = #cats_s * 4
        local cats_tx = (left_x + 8) - (cats_w / 2)
        local cats_ty = left_y + 16 + 2
        print(cats_s, cats_tx, cats_ty, DARK_BLUE)

        -- clock (upper-right) and secondsRemaining beneath
        local clock_x = 128 - 16 - CLOCK_MARGIN
        local clock_y = CLOCK_MARGIN
        spr(10, clock_x, clock_y, 2, 2)
        local secs = flr(self.secondsRemaining)
        local s = tostr(secs)
        local txt_w = #s * 4
        local tx = (clock_x + 8) - (txt_w / 2)
        local ty = clock_y + 16 + 2
        print(s, tx, ty, DARK_BLUE)
        palt()


        -- draw the visible cats
        local base_index = flr(self.scrollPos)
        for j = -1, 1 do
            local catIndex = base_index + j
            if catIndex > 0 and catIndex <= #self.catList then
                self.catList[catIndex].draw()
            end
        end
        
        -- draw center message if present
        if self.centerMessage then
            printCentered(self.centerMessage, SCREEN_WIDTH/2, 48, DARK_BLUE)
        end
    end

    function self.update()
        self.messageTimer -= 1
        if self.state == PICKING then
            self.update_picking()
            if  #self.posters < 1 then
                self.state = PICKING_DONE
                self.message = "picking done!"
                self.messageTimer = MESSAGE_DELAY               
            elseif self.secondsRemaining <= 0 then
                self.state = PICKING_DONE                
                self.message = "times up!"
                self.messageTimer = MESSAGE_DELAY                
            end
        elseif self.state == PICKING_DONE then
            self.messageTimer -= 1
            if self.messageTimer <= 0 then
                self.state = CHECKING
                self.messageTimer = 0
                self.message = "let's check!"
                self.targetPos = 1
            end
        elseif self.state == CHECKING then
            self.update_checking()
        end

        -- update animations - we want to do these in all modes

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

        -- update poster animation
        if #self.posters > 0 then
            self.posters[1].update()
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

    function self.update_picking()
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
        if btn(0) then
            if self.canPress then
                if self.targetPos > 1 then
                    self.targetPos = self.targetPos - 1
                end
                self.canPress = false
            end
        elseif btn(1) then
            if self.canPress then
                if self.targetPos < #self.catList then
                    self.targetPos = self.targetPos + 1
                end
                self.canPress = false
            end
        elseif btn(4) then
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
    end

    function self.update_checking()
        if not self.checkingCoroutine then
            self.checkingCoroutine = cocreate(function()
                local correct = 0
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

                        local pronoun = cat.poster.isFemale and "her" or "him"
                        self.message = "is this "..pronoun.."?"
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
                local scoreMessage = "\^wlost cats: "..#self.catList.."\n\^w    found: "..correct
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
                while not btn(4) do 
                    yield()
                end



                self.state = CHECKING_DONE
                self.checkingCoroutine = nil
            end)
        end
        if self.checkingCoroutine then
            coresume(self.checkingCoroutine)
        end
    end


    function self.isDone()
        return self.state == CHECKING_DONE
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

function generatePostersAndCats(count, minTraits, maxTraits, posterTraitKeys)
    printh("!!")
--    requireArray(posterTraitKeys)
    --requireNonNil(count)
    --requireNonNil(minTraits)
    --requireNonNil(maxTraits)
    printh("generatePosters".." x "..tostr(count).." x "..tostr(minTraits).." x "..tostr(maxTraits))
    minTraits = requireNonNil(minTraits)
    maxTraits = requireNonNil(maxTraits)
    posterTraitKeys = requireNonNil(posterTraitKeys)
    
    local posters = {}
    local cats = {}
    
    -- Calculate maximum possible unique combinations
    local maxCombos = 1
    for i = 1, #TraitKeys do
        local traitKey = TraitKeys[i]
        maxCombos = maxCombos * #TraitValues[traitKey]
    end
    
    -- Reduce count if we don't have enough unique combinations
    if count > maxCombos then
        printh("reducing count from "..count.." to "..maxCombos.." (max unique combinations)")
        count = maxCombos
    end
    
    -- Get n unique integers to use as indices for cat names
    local name_indeces = pickUniqueIntegers(count, 1, CAT_NAME_COUNT)
    
    -- Generate unique cat trait combinations
    local usedCatCombos = {}  -- track cat combinations as strings
    local usedPosterCombos = {}  -- track poster combinations as strings
    local attempts = 0
    local maxAttempts = count * 100
    
    while #cats < count and attempts < maxAttempts do
        attempts = attempts + 1
        
        -- Generate random cat trait combination
        local catTraits = {}
        local catComboKey = ""
        for i = 1, #TraitKeys do
            local traitKey = TraitKeys[i]
            local possibleValues = TraitValues[traitKey]
            local idx = flr(rnd(#possibleValues)) + 1
            catTraits[traitKey] = possibleValues[idx]
            catComboKey = catComboKey..traitKey..":"..idx..","
        end
        
        -- Check if this cat combination is unique
        if not usedCatCombos[catComboKey] then
            -- Try multiple poster configurations for this cat
            local posterAttempts = 0
            local maxPosterAttempts = MAX_POSTER_CONFIG_ATTEMPTS
            local foundValidPoster = false
            
            while not foundValidPoster and posterAttempts < maxPosterAttempts do
                posterAttempts = posterAttempts + 1
                
                -- Try different numbers of traits and selections
                local numTraits = minTraits + flr(rnd(maxTraits - minTraits + 1))
                -- Pick numTraits random keys from posterTraitKeys
                local availableKeys = {}
                for i = 1, #posterTraitKeys do
                    add(availableKeys, posterTraitKeys[i])
                end
                local traitKeys = {}
                for i = 1, numTraits do
                    if #availableKeys > 0 then
                        local idx = flr(rnd(#availableKeys)) + 1
                        add(traitKeys, availableKeys[idx])
                        del(availableKeys, availableKeys[idx])
                    end
                end
                
                -- build poster traits by copying from cat
                local posterTraits = {}
                local posterComboKey = ""
                for j = 1, #traitKeys do
                    local traitKey = traitKeys[j]
                    posterTraits[traitKey] = catTraits[traitKey]
                    -- build unique key for this poster
                    local val = catTraits[traitKey]
                    posterComboKey = posterComboKey..traitKey..":"..val.name..","
                end
                
                -- Check if this poster combination is unique
                if not usedPosterCombos[posterComboKey] then
                    -- Now check bidirectional uniqueness:
                    -- 1. This poster should not match any existing cat
                    -- 2. This cat should not match any existing poster
                    local isUnique = true
                    
                    -- Check if this poster would match any existing cat
                    for i = 1, #cats do
                        local otherCat = cats[i]
                        local matches = true
                        for traitKey, traitValue in pairs(posterTraits) do
                            if otherCat.traits[traitKey] != traitValue then
                                matches = false
                                break
                            end
                        end
                        if matches then
                            isUnique = false
                            break
                        end
                    end
                    
                    -- Check if this cat would match any existing poster
                    if isUnique then
                        for i = 1, #posters do
                            local otherPoster = posters[i]
                            local matches = true
                            for traitKey, traitValue in pairs(otherPoster.traits) do
                                if catTraits[traitKey] != traitValue then
                                    matches = false
                                    break
                                end
                            end
                            if matches then
                                isUnique = false
                                break
                            end
                        end
                    end
                    
                    if isUnique then
                        usedCatCombos[catComboKey] = true
                        usedPosterCombos[posterComboKey] = true
                        add(cats, Cat.new(TUXEDO_CAT, catTraits))
                        
                        local catIndex = #cats
                        local name = requireNonNil(get_cat_name(name_indeces[catIndex]), "nil cat name")
                        add(posters, Poster.new(name, name_indeces[catIndex] < CAT_NAME_FIRST_MALE, posterTraits))
                        foundValidPoster = true
                    end
                end
            end
        end
    end
    
    -- Report if we couldn't generate enough unique pairs
    if #cats < count then
        printh("could only generate "..#cats.." unique cat/poster pairs (requested "..count..")")
    end
    
    -- Shuffle cats so they're not in the same order as posters
    shuffleArray(cats)
    
        printh("generateposters END")
    return posters, cats
end

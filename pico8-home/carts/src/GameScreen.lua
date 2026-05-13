local GameScreen = {}
GameScreen.new = function()
    local self = {}

    self.weekdayNumber = 1
    self.centerMessage = nil
    self.scrollPos = 0
    self.targetPos = 1
    self.canPress = false
    self.showStatusIcons = false
    self.showCats = false
    self.showPoster = false
    self.coroutine = nil
    self.totalPostersThisWeek = 0
    self.foundCatsThisWeek = 0
    self.isGameOver = false
    self.returningPoster = nil

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

        -- draw returning poster (animating off screen after undo)
        if self.returningPoster then
            self.returningPoster.draw()
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

        -- animate returning poster (undo) until it leaves the top of the screen
        if self.returningPoster then
            self.returningPoster.update()
            if self.returningPoster.y <= self.returningPoster.targetY then
                self.returningPoster.y = POSTER_NEW_DISPLAY_POS
                self.returningPoster.targetY = POSTER_TOP_DISPLAY_POS
                self.returningPoster.speed = POSTER_PRINT_SPEED
                add(self.posters, self.returningPoster)
                self.returningPoster = nil
            end
        end
    end

    function self.startDay()
        local weekday = WEEKDAYS[self.weekdayNumber]
        self.posters, self.catList = generatePostersAndCats(weekday.catCount, weekday.catTraits, weekday.posterCount, weekday.posterTraitCount, weekday.posterTraits, weekday.randomizePosterTraitOrder)
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
            self.startPicking()
        end)
    end

    function self.startPicking()
        self.showCats = true
        self.showPoster = true
        self.showStatusIcons = true
        self._last_time = time()
        self.coroutine = cocreate(function()
            while true do
                if self.posters and #self.posters < 1 and not self.returningPoster then
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
                            sfx(SOUND_LEFT)
                        end
                        self.canPress = false
                    end
                elseif btn(BUTTON_RIGHT) then
                    if self.canPress then
                        if self.targetPos < #self.catList then
                            self.targetPos = self.targetPos + 1
                            sfx(SOUND_RIGHT)
                        end
                        self.canPress = false
                    end
                elseif btn(BUTTON_UP) then
                    if self.canPress then
                        local selectedCat = self.catList[self.targetPos]
                        if selectedCat and selectedCat.poster then
                            -- undo: detach poster from cat and animate it off the top
                            local undoPoster = selectedCat.poster
                            undoPoster.speed = POSTER_FLOAT_SPEED
                            undoPoster.targetY = POSTER_NEW_DISPLAY_POS
                            selectedCat.poster = nil
                            self.returningPoster = undoPoster
                            sfx(SOUND_UNDO)
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
                            sfx(SOUND_RUFFLE)
                            
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
                if self.posters[1] or self.returningPoster then
                    self.centerMessage = "\139\145: cHANGE cAT     "
                    if self.targetPos == self.scrollPos then
                        local selectedCat = self.catList[self.targetPos]
                        if selectedCat and selectedCat.poster then
                            local undoPronoun = selectedCat.poster.isFemale and "hER" or "hIM"
                            self.centerMessage = self.centerMessage.."\n \148: uNDO!"
                        elseif selectedCat and not selectedCat.poster and self.posters[1] then
                            local pronoun = self.posters[1].isFemale and "hER" or "hIM"
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
            sfx(SOUND_TIMESUP)
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
                        for j = 1, .5 * TICKS_PER_SECOND do 
                            yield() 
                        end
                    else
                        cat.adornmentSpriteId = BAD_MATCH_ICON
                        sfx(SOUND_BUZZ)
                        for j = 1, .5 * TICKS_PER_SECOND do 
                            yield() 
                        end
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
            
            -- Display initial score
            self.centerMessage = "\^wend of week\n\ntOTAL lOST cATS: "..self.totalPostersThisWeek
            for j = 1, 1 * TICKS_PER_SECOND do  
                yield() 
            end

            self.centerMessage = self.centerMessage.."\n\nyOU fOUND: "..self.foundCatsThisWeek
            for j = 1, 1 * TICKS_PER_SECOND do  
                yield() 
            end
            self.centerMessage = self.centerMessage.."\n\nyOUR rANK:\n"
            for j = 1, 2 * TICKS_PER_SECOND do  
                yield() 
            end

            -- Calculate and display rank
            local percentage = (self.foundCatsThisWeek / self.totalPostersThisWeek) * 100
            local rank = "kitten"
            for i = 1, #RANK_LEVELS do
                if percentage <= RANK_LEVELS[i].threshold then
                    rank = RANK_LEVELS[i].name
                    break
                end
            end
            self.centerMessage = self.centerMessage.."\^w"..rank

            for j = 1, 3 * TICKS_PER_SECOND do  
                yield() 
            end

            -- Add continue prompt
            self.centerMessage = self.centerMessage.."\n\n\npress ❎ to continue"
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


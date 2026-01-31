local GameScreen = {}
GameScreen.new = function()
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
    self.scrollPos = 0
    self.targetPos = 1
    self.canPress = false
    self.secondsRemaining = 60.0
    self._last_time = time()

    self.posters, self.catList = generatePostersAndCats(10, 1, 1)
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
        if self.scrollPos == self.targetPos then -- dont do anything yet if we're still scrolling to the next cat
            local cat = self.catList[self.scrollPos]
            local poster = cat.poster
            if poster then
                if poster.targetY > POSTER_TOP_DISPLAY_POS then
                    -- the first time we see the it, its poster will be at the bottom.  start moving it up
                    poster.targetY = POSTER_TOP_DISPLAY_POS
                elseif poster.y <= poster.targetY then
                    -- otherwise, we wait for it to move to the target.  when it gets there...
                    local pronoun = poster.isFemale and "her" or "him"
                    self.message = "is this "..pronoun.."?"
                    if poster.isMatch(cat.traits) then
                        cat.adornmentSpriteId = MATCH_ICON
                    else 
                        cat.adornmentSpriteId = BAD_MATCH_ICON
                    end
                    if self.targetPos < #self.catList then
                        self.targetPos += 1
                    else
                        self.state = CHECKING_DONE
                    end
                end
            else
            end
        end
    end


    function self.isDone()
        return self.state == CHECKING_DONE
    end

    return self
end



-- Returns a list of n Poster objects.  Every poster will be for a cat with a unique name.
function generatePostersAndCats(count, minTraits, maxTraits)
  printh("IN")
    minTraits = requireNonNil(minTraits)
    maxTraits = requireNonNil(maxTraits)
    
    local posters = {}
    -- Get n unique integers to use as indices for cat names
    local name_indeces = pickUniqueIntegers(count, 1, CAT_NAME_COUNT)
    for i = 1, count do
        -- determine how many traits this poster should have
        local numTraits = minTraits + flr(rnd(maxTraits - minTraits + 1))
        -- select random trait keys
        local traitKeys = pickUniqueIntegers(numTraits, 1, TRAIT_TYPE_COUNT)
        -- build traits map
        local traits = {}
        for j = 1, #traitKeys do
            local traitKey = traitKeys[j]
            local possibleValues = TraitValues[traitKey]
            -- pick a random value using #
            local selectedValue = possibleValues[flr(rnd(#possibleValues)) + 1]

            traits[traitKey] = selectedValue  -- use trait key to create map
        end
        
        local name = requireNonNil(get_cat_name(name_indeces[i]), "nil cat name returned ("..name_indeces[i]..")")
        add(posters, Poster.new(name, name_indeces[i] < CAT_NAME_FIRST_MALE, traits))
    end

    local cats = {}

    for i=1,count do
        local fidx = ((i - 1) % #TraitValues[FUR_COLOR]) + 1
        local eidx = ((i - 1) % #TraitValues[EYE_COLOR]) + 1
        local traits = {
            [FUR_COLOR] = TraitValues[FUR_COLOR][fidx],
            [EYE_COLOR] = TraitValues[EYE_COLOR][eidx]
        }
        cats[i] = Cat.new(TUXEDO_CAT, traits)
    end

    return posters, cats
end

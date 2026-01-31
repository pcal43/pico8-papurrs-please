local GameScreen = {}
GameScreen.new = function()
    local self = {}

    self.scrollPos = 0
    self.targetPos = 1
    self.canPress = true
    self.secondsRemaining = 60.0
    self._last_time = time()
    self.posterY = POSTER_NEW_DISPLAY_POS
    self.targetPosterY = POSTER_TOP_DISPLAY_POS

    self.catList = {}
    self.catListSize = 10

    self.posters = generate_posters(10)

    for i=1,self.catListSize do
        local fidx = ((i - 1) % #TraitValues[FUR_COLOR]) + 1
        local eidx = ((i - 1) % #TraitValues[EYE_COLOR]) + 1
        local traits = {
            [FUR_COLOR] = TraitValues[FUR_COLOR][fidx],
            [EYE_COLOR] = TraitValues[EYE_COLOR][eidx]
        }
        self.catList[i] = Cat.new(TUXEDO_CAT, traits)
    end


    function self.show()
    end

    function self.draw()
        cls(15) -- offwhite background

        -- draw poster at the top
        self.posters[1].draw(self.posterY)

        local header_h = 9
        local header_w = 84
        local header_x = (128 - header_w) / 2
        local header_y = 0
        rectfill(header_x - 1, header_y, header_x + 1 + header_w - 1, header_y + header_h, 0)
        self.print_center_top("lost cat!", 0, 5, 10, 2) -- yellow text



        -- draw icons: left (sprite 8) with catsRemaining, and clock (sprite 10) right with seconds
        palt(0, false) -- black is black, beige is transparent
        local CLOCK_MARGIN = 2

        -- left icon and catsRemaining beneath
        local left_x = CLOCK_MARGIN
        local left_y = CLOCK_MARGIN
        spr(8, left_x, left_y, 2, 2)
        local cats = flr(#self.posters)
        local cats_s = tostr(cats)
        local cats_w = #cats_s * 4
        local cats_tx = (left_x + 8) - (cats_w / 2)
        local cats_ty = left_y + 16 + 2
        print(cats_s, cats_tx, cats_ty, 1)

        -- clock (upper-right) and secondsRemaining beneath
        local clock_x = 128 - 16 - CLOCK_MARGIN
        local clock_y = CLOCK_MARGIN
        spr(10, clock_x, clock_y, 2, 2)
        local secs = flr(self.secondsRemaining)
        local s = tostr(secs)
        local txt_w = #s * 4
        local tx = (clock_x + 8) - (txt_w / 2)
        local ty = clock_y + 16 + 2
        print(s, tx, ty, 1)
        palt()


        self.draw_cat_list(self.scrollPos)

    end

    function self.update()

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
                    
                    -- Remove the poster from the list
                    del(self.posters, self.posters[1])
                    
                    -- Animate the next poster moving down
                    if #self.posters > 0 then
                        self.posterY = POSTER_NEW_DISPLAY_POS
                        self.targetPosterY = POSTER_TOP_DISPLAY_POS
                    end
                end
                
                self.canPress = false
            end
        else
            self.canPress = true
        end

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

        -- adjust posterY to 'catch up' with targetPosterY
        local posterDiff = self.targetPosterY - self.posterY
        local posterDist = abs(posterDiff)
        if posterDist > 0 then
            if posterDist <= POSTER_MOVE_SPEED then
                self.posterY = self.targetPosterY
            else
                self.posterY = self.posterY + sgn(posterDiff) * POSTER_MOVE_SPEED
            end
        end

    end

 function self.print_center_top(text, line, y_margin, color, base_y)
    local w = #text * 8
    local x = (128 - w) / 2
    local y = (base_y or 0) + ((line - 1) * TEXT_HEIGHT) + (y_margin or 0)
    local wide_text = "\^w"..text    
    print(wide_text, x, y, color or 1, true)
end



    local SCREEN_WIDTH = 128
    local SCREEN_HEIGHT = 128
    local SPACE_BETWEEN_CATS = 12
    local CAT_Y_POS = SCREEN_HEIGHT - 4
    local CAT_WIDTH = 64

    function self.draw_cat_list(scrollPos)
        local base_index = flr(scrollPos)
        local frac = scrollPos - base_index
        local spacing = CAT_WIDTH + SPACE_BETWEEN_CATS

        for j = -1, 1 do
            local catIndex = base_index + j
            if catIndex > 0 and catIndex <= #self.catList then
                -- position each slot, then shift by fractional progress toward next slot
                local xPos = SCREEN_WIDTH/2 + (j * spacing) - (frac * spacing)
                self.catList[catIndex].draw(xPos, CAT_Y_POS)
            end
        end
    end




    return self
end

local GameScreen = {}
GameScreen.new = function()
    local self = {}

    self.scrollPos = 0
    self.targetPos = 1
    self.canPress = true

    self.catList = {}
    local fur_list = {FurColors.WHITE, FurColors.ORANGE, FurColors.GRAY, FurColors.BLACK, FurColors.BROWN}
    local eye_list = {EyeColors.GREEN, EyeColors.BLUE, EyeColors.GOLDEN}
    for i=1,5 do
        local fidx = ((i - 1) % #fur_list) + 1
        local eidx = ((i - 1) % #eye_list) + 1
        local traits = {
            [TraitKeys.FUR_COLOR] = fur_list[fidx],
            [TraitKeys.EYE_COLOR] = eye_list[eidx]
        }
        self.catList[i] = Cat.new(TUXEDO_CAT, traits)
    end

    function self.show()
    end

    function self.draw()
        cls(15) -- offwhite background

        -- draw paper at the top
        local rw, rh = 84, 44
        local rx = (128 - rw) / 2
        local ry = 0
        rectfill(rx, ry, rx + rw - 1, ry + rh - 1, 7)
        rectfill(rx, ry, rx, ry + rh - 1, 5)                   -- left
        rectfill(rx + rw - 1, ry, rx + rw - 1, ry + rh - 1, 5) -- right
        rectfill(rx, ry + rh - 1, rx + rw - 1, ry + rh - 1, 5) -- bottom

        self.print_center_top("lost cat:", 0, 2)
        self.print_center_top("fluffy", 1, 2)
        self.print_center_top("blue fur", 2, 4)
        self.print_center_top("green eyes", 3, 4)

        self.draw_cat_list(self.scrollPos)

    end

    function self.update()

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

    end

 function self.print_center_top(text, line, y_margin)
    local TEXT_HEIGHT = 6
    local w = #text * 8
    local x = (128 - w) / 2
    local y = (line * TEXT_HEIGHT) + (y_margin or 0)
    local wide_text = "\^w"..text    
    print(wide_text, x, y, 1, true)
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

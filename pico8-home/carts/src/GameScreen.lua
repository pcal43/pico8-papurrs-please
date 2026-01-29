local GameScreen = {}
GameScreen.new = function()
    local self = {}

    self.scrollPos = 0
    self.targetPos = 1
    self.canPress = true

    self.catList = {}
    for i=1,5 do
        local traits = { [TraitKeys.FUR_COLOR] = i * 2 , [TraitKeys.EYE_COLOR] = i + 9}
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
                self.targetPos = self.targetPos - 1
                self.canPress = false
            end
        elseif btn(1) then
            if self.canPress then
                                            printh("tap "..tostr(self.canPress))

                self.targetPos = self.targetPos + 1
                self.canPress = false
            end
        else 
                                            printh("clear")

            self.canPress = true
        end


        -- lerp scrollPos toward targetPos by 2% per frame
        if self.scrollPos ~= self.targetPos then
            self.scrollPos = self.scrollPos + (self.targetPos - self.scrollPos) * 0.02
            if abs(self.targetPos - self.scrollPos) < 0.001 then
                self.scrollPos = self.targetPos
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
        for i = -1, 1 do
            local catIndex = flr(scrollPos + i)
            if catIndex > 0 and catIndex <= #self.catList then
                local xPos = SCREEN_WIDTH/2 + (i * CAT_WIDTH + SPACE_BETWEEN_CATS)
                self.catList[catIndex].draw(xPos, CAT_Y_POS)
            end
        end

    end




    return self
end

local TitleScreen = {}
TitleScreen.new = function(playfield, startFn)
    local self = {}

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

        -- draw 64x64 sprite centered (set sprite_id to the top-left tile index of your 64x64 sprite)
        local sprite_id = 0
        local x = (128 - 64) / 2
        local y = 128 - 64 - 4 -- 4px margin from bottom

        -- make color 15 transparent and ensure black (0) is drawn as opaque
        palt(0, false)
        palt(15, true)
        spr(sprite_id, x, y, 8, 8)
        -- restore common defaults (black transparent, 15 opaque)
        palt(15, false)
        palt(0, true)

    end

    function self.update()
    end

 function self.print_center_top(text, line, y_margin)
    local TEXT_HEIGHT = 6
    local w = #text * 8
    local x = (128 - w) / 2
    local y = (line * TEXT_HEIGHT) + (y_margin or 0)
    local wide_text = "\^w"..text    
    print(wide_text, x, y, 1, true)
end


    return self
end

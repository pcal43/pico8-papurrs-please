local TitleScreen = {}
TitleScreen.new = function()
    local self = {}
    
    self.done = false
    self.blink_timer = 0
    
    function self.show()
    end
    
    function self.update()
        self.blink_timer += 1
        
        if btnp(4) or btnp(5) then
            self.done = true
        end
    end
    
    function self.draw()
        cls(1) -- dark blue background
        
        -- Draw title
        local title = "lost cats!"
        local title_w = #title * 8
        local title_x = (128 - title_w) / 2
        print("\^w"..title, title_x, 32, 7)
        
        -- Draw subtitle
        local subtitle = "a week at the animal shelter"
        local sub_w = #subtitle * 4
        local sub_x = (128 - sub_w) / 2
        print(subtitle, sub_x, 48, 6)
        
        -- Blinking "press ❎ to start"
        if self.blink_timer % 30 < 20 then
            local start = "press ❎ to start"
            local start_w = #start * 4
            local start_x = (128 - start_w) / 2
            print(start, start_x, 80, 7)
        end
        
        -- Credits
        print("by pcal", 32, 110, 5)
    end
    
    function self.is_done()
        return self.done
    end
    
    return self
end
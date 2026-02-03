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
        cls(PEACH) -- dark blue background
        
        -- Draw title
        printCentered("\^wlost cats!", SCREEN_WIDTH/2, 32, DARK_BLUE)
        
        -- Draw subtitle
        printCentered("sPEND A WEEK AT THE\nANIMAL SHELTER MATCHING CATS\nWITH \"LOST CAT\" POSTERS", SCREEN_WIDTH/2, 48, DARK_BLUE)
        
        -- Blinking "press ❎ to start"
        if self.blink_timer % 30 < 20 then
            printCentered("press ❎ to start", SCREEN_WIDTH/2, 95, BLACK)
        end
        
        -- Credits
        printCentered("BY PCAL", SCREEN_WIDTH/2, 110, DARK_GRAY)
    end
    
    return self
end
local DaySplashScreen = {}
DaySplashScreen.new = function(weekday)
    local self = {}
    
    self.day_name = weekday.name
    self.ready = false
    self.done = false
    
    function self.update()
        if not self.ready then
            self.ready = not btn(4)
        elseif btnp(4) then
            self.done = true
        end
    end
    
    function self.isDone()
        return self.done
    end
    
    function self.draw()
        cls(PEACH) -- dark blue background
        
        -- Draw day name
        local day_text = self.day_name
        local day_w = #day_text * 8
        local day_x = (128 - day_w) / 2
        print("\^w"..day_text, day_x, 40, WHITE)
        
        -- Draw "Ready?" prompt
        local ready = "ready?"
        local ready_w = #ready * 4
        local ready_x = (128 - ready_w) / 2
        print(ready, ready_x, 64, LIGHT_GRAY)
        
        -- Draw action prompt
        local prompt = "press ❎ to start"
        local prompt_w = #prompt * 4
        local prompt_x = (128 - prompt_w) / 2
        print(prompt, prompt_x, 80, DARK_GRAY)
    end
    
    return self
end

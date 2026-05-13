local Controller = {}
Controller.new = function()

    local self = {}
    local gameScreen = nil
    self.current_screen = nil

    function self.init()
        cartdata("papurrs-please") -- set the key for persistent storage
    end

    function self.update()
        if self.current_screen then
            self.current_screen.update()
        end
        resume(self.flow)        
    end
    
    function self.draw()
        if self.current_screen then
            self.current_screen.draw()
        end
    end
    
    
    self.flow = cocreate(function()
        while true do
            self.current_screen = TitleScreen.new()
            while btnp(BUTTON_X) do  -- make sure button clears
                yield() 
            end
            while not btnp(BUTTON_X) do 
                yield() 
            end
            self.current_screen = GameScreen.new()
            self.current_screen.startDay()        
            while not self.current_screen.isDone() do 
                yield() 
            end
        end
    end)
    
    return self
end

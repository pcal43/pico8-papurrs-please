local Controller = {}
Controller.new = function()

    local self = {}
    local gameScreen = nil
    self.current_screen = nil

    function self.init()
        cartdata("lost-cats") -- set the key for persistent storage
    end


    function self.update()
        if self.current_screen and self.current_screen.update then
            self.current_screen.update()
        end
        coresume(self.flow)
    end
    
    function self.draw()
        if self.current_screen and self.current_screen.draw then
            self.current_screen.draw()
        end
    end
    
    
    self.flow = cocreate(function()
        while true do
            -- Title screen
            self.current_screen = TitleScreen.new()
            while not btnp(4) do yield() end
            
            -- Play through the week
            for day=1,5 do
                -- Day splash
                self.current_screen = DaySplashScreen.new(WEEKDAYS[day])
                while not self.current_screen.isDone() do yield() end
                
                -- Create the game screen
                self.current_screen = GameScreen.new(WEEKDAYS[day])
                while not self.current_screen.isDone() do yield() end
                
    --            -- Show message
    --            local msg = self.current_screen.secondsRemaining <= 0 
    --                and "time's up!" or "all cats found!"
    --            self.current_screen.message = msg
    --            for i=1,60 do yield() end
                
                -- Review each cat
    --            for i=1,#self.current_screen.catList do
    --                local cat = self.current_screen.catList[i]
    --                if cat.poster then
    --                    self.current_screen.review_index = i
    --                    self.current_screen.is_correct = cat.matches(cat.poster.traits)
    --                    for j=1,90 do yield() end
    --                end
    --            end
                
                -- Day results
    --            self.current_screen.show_results = true
    --            while not btnp(4) do yield() end
            end
            
            -- Game over
    --        self.current_screen = GameOverScreen.new()
    --        while true do yield() end
        end
    end)
    
    return self
end

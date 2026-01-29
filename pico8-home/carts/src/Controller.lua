CONTROLLER = nil

local Controller = {}
Controller.new = function()

    local self = {}
    self.frameAlpha = -1

    local gameScreen = nil
    local activeScreen = gameScreen    

    local function showTitle()
        gameScreen.show()
        activeScreen = gameScreen
    end


    function self.init()
        cartdata("lost-cats") -- set the key for persistent storage

        gameScreen = GameScreen.new()
        showTitle()
    end

    function self.update()
        self.frameAlpha += 1
        if (activeScreen != nil) activeScreen.update()
    end

    function self.draw()


        if (activeScreen != nil) activeScreen.draw()
    end

    function self.onStart(selectedLevel)
    end

    function self.onReset()
    end

    function self.onExit()
        showTitle()
    end

    function self.onNext()
    end

    function self.onSolved()
    end

    return self
end

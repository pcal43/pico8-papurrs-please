CONTROLLER = nil

local Controller = {}
Controller.new = function()

    local self = {}
    self.frameAlpha = -1

    local titleScreen = nil
    local activeScreen = titleScreen    

    local function showTitle()
        titleScreen.show()
        activeScreen = titleScreen
    end


    function self.init()
        cartdata("lost-cats") -- set the key for persistent storage
        titleScreen = TitleScreen.new(playfield, self.onStart)
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

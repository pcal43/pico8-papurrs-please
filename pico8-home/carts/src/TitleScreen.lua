local TitleScreen = {}
TitleScreen.new = function()
    local self = {}
    
    self.done = false
    self.blink_timer = 0

    -- pick a random value from a TraitValues list
    local function rndTrait(key)
        local vals = TraitValues[key]
        return vals[flr(rnd(#vals)) + 1]
    end

    -- shuffle fur colors so each cat gets a unique one
    local fur_pool = {}
    for i = 1, #TraitValues[FUR_COLOR] do fur_pool[i] = i end
    for i = #fur_pool, 2, -1 do
        local j = flr(rnd(i)) + 1
        fur_pool[i], fur_pool[j] = fur_pool[j], fur_pool[i]
    end
    local fur_idx = 0

    local function randomTraits()
        fur_idx += 1
        return {
            [FUR_COLOR]    = TraitValues[FUR_COLOR][fur_pool[fur_idx]],
            [EYE_COLOR]    = rndTrait(EYE_COLOR),
            [COLLAR_COLOR] = rndTrait(COLLAR_COLOR),
            [STRIPES]      = rndTrait(STRIPES),
            [EAR_COLOR]    = rndTrait(EAR_COLOR),
        }
    end

    -- arrowhead formation: back row drawn first so front cats appear on top
    -- y=113 → sprite top at 50, just barely overlapping logo bottom (y=51)
    Y_OFFSET = -3
    local formation = {
        { x=32,   y=118 + Y_OFFSET },  -- L (left flank)
        { x=72,  y=CAT_Y_POS + Y_OFFSET }, -- F  (front/center)        
        { x=112, y=118 + Y_OFFSET },  -- R (right flank)

    }
    for _, c in ipairs(formation) do
        c.traits = randomTraits()
    end

    function self.show()
    end
    
    function self.update()
        self.blink_timer += 1
        
        if btnp(4) or btnp(5) then
            self.done = true
        end
    end
    
    function self.draw()
        cls(PEACH)

        -- Draw cats in arrowhead formation, back-to-front
        for _, c in ipairs(formation) do
            TUXEDO_CAT.draw(c.x, c.y, c.traits)
        end

        -- Draw logo at 2x size on top of cats
        local logo_w, logo_h = 54, 25
        local dw, dh = logo_w * 2, logo_h * 2
        sspr(0, 64, logo_w, logo_h, flr((SCREEN_WIDTH - dw) / 2), 1, dw, dh)

        -- Blinking "press ❎ to start"
        if self.blink_timer % 30 < 20 then
            printCentered("press ❎ to start", SCREEN_WIDTH/2, 122, BLACK)
        end

        -- Credits: bottom-right corner, left-aligned to each other
        print("PCAL", 2, 122, DARK_GRAY)
        print(VERSION,   108, 122, DARK_GRAY)
    end
    
    return self
end

TraitKeys = {
    FUR_COLOR = 1,
    EYE_COLOR = 2
}


CatType = {}
CatType.new = function(spriteId)
    local self = {}
    self.spriteId = spriteId

    -- draws the cat with it bottom middle point centered on the given coordinates
    function self.draw(x, y, traits)
        palt(0, false) -- black is black, beige is transparent
        palt(15, true)
        pal(1, traits[TraitKeys.FUR_COLOR])
        pal(11, traits[TraitKeys.EYE_COLOR])

        spr(self.spriteId, x - 64 / 2, y - 64, 8, 8)
        palt(15, false) -- reset
        palt(0, true)
    end

    return self
end

TUXEDO_CAT = CatType.new(0)


Cat = {}
Cat.new = function(catType, traits)
    local self = {}
    self.catType = catType
    self.traits = traits
    self.name = "???"

    function self.draw(x, y)
        self.catType.draw(x, y, traits)
    end

    return self
end


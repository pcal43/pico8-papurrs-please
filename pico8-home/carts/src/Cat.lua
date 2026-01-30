


CatType = {}
CatType.new = function(spriteId)
    local self = {}
    self.spriteId = spriteId

    -- draws the cat with it bottom middle point centered on the given coordinates
    function self.draw(x, y, traits)
        palt(0, false) -- black is black, beige is transparent
        palt(15, true)
        pal(1, traits[TraitKeys.FUR_COLOR].fur)
        pal(7, traits[TraitKeys.FUR_COLOR].whiskers)
        pal(9, traits[TraitKeys.FUR_COLOR].nose)
        pal(0, traits[TraitKeys.FUR_COLOR].outline)

        pal(3, traits[TraitKeys.EYE_COLOR].inner)
        pal(11, traits[TraitKeys.EYE_COLOR].outer)
        pal(4, 0) -- pupils are grey to distinguish from outline

        spr(self.spriteId, x - 64 / 2, y - 64, 8, 8)
        pal()
        palt()

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


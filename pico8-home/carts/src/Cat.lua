


CatTemplate = {}
CatTemplate.new = function(spriteId)
    local self = {}
    self.spriteId = spriteId

    -- draws the cat with it bottom middle point centered on the given coordinates
    function self.draw(x, y, traits)
        palt(0, false) -- black is black, beige is transparent
        palt(15, true)
        printh(tostr(traits))
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

TUXEDO_CAT = CatTemplate.new(0)


Cat = {}
Cat.new = function(catTemplate, traits)
    local self = {}
    self.catTemplate = requireNonNil(catTemplate)
    self.traits = requireNonNil(traits)

    function self.draw(x, y)
      requireNonNil(traits)
        printh(tostr(traits))
        printh("-------")      
        self.catTemplate.draw(x, y, traits)
    end

    return self
end


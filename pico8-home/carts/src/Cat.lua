
TraitKeys = {
    FUR_COLOR = 1,
    EYE_COLOR = 2
}

FurColors = {
   WHITE = {
     name = "white",
     fur = 7,
     stripes = 6,
     whiskers = 5,
     nose = 14,
     outline = 0
   },
   ORANGE = {
     name = "orange",
     fur = 9,
     stripes = 4,
     whiskers = 7,
     nose = 14,
     outline = 0
   },
   GRAY = {
     name = "gray",
     fur = 5,
     stripes = 6,
     whiskers = 7,
     nose = 9,
     outline = 0
   },
   BLACK = {
     name = "black",
     fur = 0,
     stripes = 1,
     whiskers = 7,
     nose = 9,
     outline = 5
   },
   BROWN = {
     name = "brown",
     fur = 4,
     stripes = 9,
     whiskers = 7,
     nose = 9,
     outline = 0
   }
}

EyeColors = {
   GREEN = {
     name = "green",
     inner = 3,
     outer = 11
   },
   BLUE = {
     name = "blue",
     inner = 13,
     outer = 12
   },
   GOLDEN = {
     name = "golden",
     inner = 9,
     outer = 10
   }
}



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

        pal(3, traits[TraitKeys.EYE_COLOR].inner)
        pal(11, traits[TraitKeys.EYE_COLOR].outer)

        spr(self.spriteId, x - 64 / 2, y - 64, 8, 8)
        pal()
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





CatTemplate = {}
CatTemplate.new = function(spriteId)
    local self = {}
    self.spriteId = spriteId

    -- draws the cat with it bottom middle point centered on the given coordinates
    function self.draw(x, y, traits)
        palt(0, false) -- black is black, beige is transparent
        palt(15, true)
        pal(1, traits[FUR_COLOR].fur)
        pal(7, traits[FUR_COLOR].whiskers)
        pal(9, traits[FUR_COLOR].nose)
        pal(0, traits[FUR_COLOR].outline)

        pal(3, traits[EYE_COLOR].inner)
        pal(11, traits[EYE_COLOR].outer)
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
    self.poster = nil
    self.posterY = POSTER_BOT_DISPLAY_POS
    self.posterTargetY = POSTER_BOT_DISPLAY_POS

    function self.draw(x, y)
        requireNonNil(traits)
        if self.poster then
            self.poster.draw(self.posterY)
        end
        self.catTemplate.draw(x, y, traits)
    end

    return self
end

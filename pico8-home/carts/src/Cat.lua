CatTemplate = {}
CatTemplate.new = function(spriteId)
    local self = {}
    self.spriteId = spriteId

    -- draws the cat with it bottom middle point centered on the given coordinates
    function self.draw(x, y, traits)
        palt(BLACK, false)
        palt(PEACH, true)
        pal(DARK_BLUE, traits[FUR_COLOR].fur)
        pal(WHITE, traits[FUR_COLOR].whiskers)
        pal(ORANGE, traits[FUR_COLOR].nose)
        pal(BLACK, traits[FUR_COLOR].outline)

        pal(DARK_GREEN, traits[EYE_COLOR].inner)
        pal(GREEN, traits[EYE_COLOR].outer)
        pal(PINK, traits[EAR_COLOR].color)        
        pal(BROWN, BLACK) -- pupils are grey to distinguish from outline

        spr(self.spriteId, x - 64 / 2, y - 63, 8, 8)
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
    self.x = SCREEN_WIDTH / 2
    self.adornmentSpriteId = nil

    function self.update()
        if self.poster then
            self.poster.x = self.x
            self.poster.update()
        end
    end

    function self.draw()
        requireNonNil(traits)
        self.catTemplate.draw(self.x, CAT_Y_POS, traits)
        if self.adornmentSpriteId then
            spr(self.adornmentSpriteId, self.x - 8, CAT_Y_POS - 63 - 16, 2, 2)
        end
        if self.poster then
            self.poster.draw()
        end


    end

    return self
end

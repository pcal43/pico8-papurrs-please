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

        pal(BLUE, traits[FUR_COLOR].stripes) --FIXME


        pal(DARK_GREEN, traits[EYE_COLOR].inner)
        pal(GREEN, traits[EYE_COLOR].outer)
        pal(PINK, traits[EAR_COLOR].color)        
        pal(BROWN, BLACK) -- pupils are grey to distinguish from outline

        spr(self.spriteId, x - 64 / 2, y - 63, 8, 8)
        pal()

        if traits[COLLAR_COLOR].color != -1 then
            palt(BLACK, false)
            palt(PEACH, true)
            pal(PINK, traits[COLLAR_COLOR].color)
            spr(COLLAR_SPRITE, x - 64 / 2 + 11, y - 36 + 10, 3, 1)
            pal()
        end
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
            spr(self.adornmentSpriteId, self.x - 8, PROMPT_TEXT_Y, 2, 2)
        end
        if self.poster then
            self.poster.draw()
        end


    end

    return self
end

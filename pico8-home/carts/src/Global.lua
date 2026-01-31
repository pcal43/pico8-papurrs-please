
POSTER_TOP_DISPLAY_POS = 9
POSTER_BOT_DISPLAY_POS = 118
POSTER_NEW_DISPLAY_POS = -30
POSTER_MOVE_SPEED = 4

TEXT_HEIGHT = 6
TRAIT_SPACING = 1


FUR_COLOR = 1
FUR_PATTERN = 2
EYE_COLOR = 3
EAR_COLOR = 4
COLLAR = 5
TRAIT_TYPE_COUNT = 5


function requireNonNil(x, msg) 
    assert(x ~= nil, msg or "unexpected nil value")
    return x
end

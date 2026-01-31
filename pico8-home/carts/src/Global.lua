
SCREEN_WIDTH = 128
SCREEN_HEIGHT = 128

BLACK = 0
DARK_BLUE = 1
DARK_PURPLE = 2
DARK_GREEN = 3
BROWN = 4
DARK_GRAY = 5
LIGHT_GRAY = 6
WHITE = 7
RED = 8
ORANGE = 9
YELLOW = 10
GREEN = 11
BLUE = 12
INDIGO = 13
PINK = 14
PEACH = 15

SPACE_BETWEEN_CATS = 12
CAT_Y_POS = SCREEN_HEIGHT - 4
CAT_WIDTH = 64

CLOCK_MARGIN = 2

POSTER_TOP_DISPLAY_POS = 9
POSTER_BOT_DISPLAY_POS = 118
POSTER_NEW_DISPLAY_POS = -30
POSTER_PRINT_SPEED = 4
POSTER_FLOAT_SPEED = 12
POSTER_WIDTH = 84

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


function print_center_top(text, line, y_margin, color, base_y)
    local w = #text * 8
    local x = (128 - w) / 2
    local y = (base_y or 0) + ((line - 1) * TEXT_HEIGHT) + (y_margin or 0)
    local wide_text = "\^w"..text    
    print(wide_text, x, y, color or 1, true)
end


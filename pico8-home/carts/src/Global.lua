
SCREEN_WIDTH = 128
SCREEN_HEIGHT = 128

TICKS_PER_SECOND = 30

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

SOUND_BUZZ = 0
SOUND_MEOW = 1

TEXT_HEIGHT = 6
TRAIT_SPACING = 1

FUR_COLOR = 1
EYE_COLOR = 2
FUR_PATTERN = 3
EAR_COLOR = 4
COLLAR = 5

MATCH_ICON = 12
BAD_MATCH_ICON = 14
QUESTION_ICON = 44

MAX_POSTER_CONFIG_ATTEMPTS = 50

WEEKDAYS = {
    {
        name = "monday",
        posters = 5,
        traits = { FUR_COLOR },
        minTraits = 1,
        maxTraits = 1
    },
    {
        name = "tuesday",
        posters = 10,
        traits = { FUR_COLOR, EYE_COLOR },
        minTraits = 1,
        maxTraits = 2
    },
    {
        name = "wednesday",
        posterCount = 15,
        posterTraits = { FUR_COLOR, EYE_COLOR, EAR_COLOR },
        minTraits = 2,
        maxTraits = 3
    },
    {
        name = "thursday",
        posterCount = 15,
        posterTraits = { FUR_COLOR, EYE_COLOR },
        minTraits = 2,
        maxTraits = 2
    },
    {
        name = "friday",
        posterCount = 15,
        posterTraits = { FUR_COLOR, EYE_COLOR },
        minTraits = 2,
        maxTraits = 2
    }
}



function requireNonNil(x, msg) 
    assert(x ~= nil, msg or "unexpected nil value")
    return x
end

function printCentered(text, x, y, color)
    local lines = {}
    local current = ""
    
    -- Split text by \n
    for i = 1, #text do
        local char = sub(text, i, i)
        if char == "\n" then
            add(lines, current)
            current = ""
        else
            current = current .. char
        end
    end
    -- Add the last line
    add(lines, current)
    
    -- Print each line centered
    for i = 1, #lines do
        local line = lines[i]
        local charWidth = 4  -- default 4 pixels per character
        local textLength = #line
        
        -- Check if line starts with wide text control character (chr(23))
        if sub(line, 1, 1) == chr(6) and sub(line, 2, 2) == "w" then
            charWidth = 8  -- wide characters are 8 pixels
            textLength = textLength - 2  -- exclude control character from width calculation
        end

        
        local w = textLength * charWidth
        local lineX = x - w / 2
        local lineY = y + (8 * (i - 1))
        print(line, lineX, lineY, color or WHITE)
    end
end


function print_center_top(text, line, y_margin, color, base_y)
    local w = #text * 8
    local x = (128 - w) / 2
    local y = (base_y or 0) + ((line - 1) * TEXT_HEIGHT) + (y_margin or 0)
    local wide_text = "\^w"..text    
    print(wide_text, x, y, color or 1, true)
end

function pickUniqueIntegers(count, minValue, maxValue)
    local pool = {}
    local results = {}
    
    -- 1. fill the pool with all possible numbers
    for i=minValue,maxValue do 
        add(pool, i) 
    end
    
    -- 2. pick 'count' numbers from the pool
    for i=1,count do
        -- pick a random index based on current pool size
        local idx = flr(rnd(#pool)) + 1
        
        -- add the value at that index to our results
        local val = pool[idx]
        add(results, val)
        
        -- remove it from the pool so it can't be picked again
        del(pool, val)
    end
    
    return results
end

function shuffleArray(arr)
    for i = #arr, 2, -1 do
        local j = flr(rnd(i)) + 1
        arr[i], arr[j] = arr[j], arr[i]
    end
    return arr
end

-- Returns true if the table is empty or has only consecutive integer keys starting at 1
function isArray(t)
    if type(t) ~= "table" then return false end
    
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    if count == 0 then return true end
    
    return #t == count
end

-- Assertions
function requireArray(val, name)
    requireNonNil(val)
    name = name or "value"
    assert(isArray(val), name.." must be a sequential array; found "..type(val))
end

function mapSize(val)
    requireNonNil(val, "mapSize input")
    local count = 0
    for _ in pairs(val) do
        count = count + 1
    end
    return count
end

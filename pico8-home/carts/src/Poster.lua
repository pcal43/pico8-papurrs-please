Poster = {}
Poster.new = function(name, traits)
    local self = {}
    self.name = requireNonNil(name)
    self.traits = requireNonNil(traits)
    self.y = POSTER_TOP_DISPLAY_POS
    self.targetY = POSTER_TOP_DISPLAY_POS

    function self.update()
        -- adjust y to 'catch up' with targetY
        local diff = self.targetY - self.y
        local dist = abs(diff)
        if dist > 0 then
            if dist <= POSTER_MOVE_SPEED then
                self.y = self.targetY
            else
                self.y = self.y + sgn(diff) * POSTER_MOVE_SPEED
            end
        end
    end

    function self.draw(x, y)
        y = y or self.y -- use instance y if not provided
        local poster_x = x - POSTER_WIDTH / 2

        local traitCount = #self.traits
        local posterHeight = 2 + TEXT_HEIGHT + (2 * TRAIT_SPACING) + (traitCount * (TEXT_HEIGHT + TRAIT_SPACING)) + 2

        local rx = poster_x
        rectfill(rx, y, rx + POSTER_WIDTH - 1, y + posterHeight, WHITE) -- white
        rect(rx, y, rx + POSTER_WIDTH - 1, y + posterHeight, DARK_GRAY) -- outline

        -- print name
        local name_w = #self.name * 8
        local name_x = poster_x + (POSTER_WIDTH - name_w) / 2
        local name_y = y + 2
        local wide_name = "\^w"..self.name
        print(wide_name, name_x, name_y, DARK_BLUE, true)
        
        -- print traits
        local trait_line = 1
        for trait_key, trait_value in pairs(self.traits) do
            local trait_w = #trait_value.name * 8
            local trait_x = poster_x + (POSTER_WIDTH - trait_w) / 2
            local trait_y = y + 9 + ((trait_line - 1) * TEXT_HEIGHT) + 4
            local wide_trait = "\^w"..trait_value.name
            print(wide_trait, trait_x, trait_y, DARK_BLUE, true)
            trait_line = trait_line + 1
        end
    end

    return self
end


-- Returns a list of n Poster objects.  Every poster will be for a cat with a unique name.
function generate_posters(count, minTraits, maxTraits)
    minTraits = minTraits or 2
    maxTraits = maxTraits or 4
    
    local posters = {}
    -- Get n unique integers to use as indices for cat names
    local name_indeces = get_unique_integers(count, CAT_NAME_COUNT)
    for i = 1, count do
        -- determine how many traits this poster should have
        local numTraits = minTraits + flr(rnd(maxTraits - minTraits + 1))
        -- select random trait keys
        local traitKeys = get_unique_integers(numTraits, TRAIT_TYPE_COUNT)
        -- build traits array
        local traits = {}
        for j = 1, #traitKeys do
            local traitKey = traitKeys[j]
            local possibleValues = TraitValues[traitKey]
            
            -- pick a random value using #
            local selectedValue = possibleValues[flr(rnd(#possibleValues)) + 1]
            
            add(traits, selectedValue)  -- use add() to append to array
        end
        
        local name = requireNonNil(get_cat_name(name_indeces[i]), "nil cat name returned ("..name_indeces[i]..")")        
        add(posters, Poster.new(name, traits))
    end
    
    return posters
end


-- Cat names stored as comma-delimited string to save tokens
CAT_NAMES = "angel,apollo,ash,athena,aurora,baby,bailey,bambi,bandit,bear,bella,blaze,boo,boots,buddy,butterball,butterscotch,buttons,callie,candy,cappuccino,caramel,casper,chaos,charlie,charm,cheeto,cherry,chester,chip,chloe,cloudfur,cinnamon,cleo,clover,cocoa,coconut,comet,cookie,copper,cricket,cuddles,daffodil,daisy,diamond,doodle,duke,dusty,echo,ember,espresso,faith,fawn,felix,fiona,flash,fluffy,freckles,garfield,george,ghost,ginger,gizmo,glitter,goose,gracie,gravy,gypsy,harley,harmony,hazel,hercules,hobbes,honey,hope,indigo,iris,ivy,jack,jade,jasper,jazz,jewel,jinx,jojo,karma,kiki,kitty,kiwi,latte,lavender,legend,leo,licorice,lightning,lily,loki,lollipop,lotus,louie,lulu,lucy,lucky,luna,maggie,mango,maple,marble,marshmallow,marvel,max,mercury,midnight,milo,mischief,misty,mittens,mocha,molly,moonlight,moose,mopsy,muffin,murphy,mystic,nachos,nala,ninja,noodle,nova,nugget,nutmeg,oak,olive,oliver,onyx,opal,oreo,oscar,pandora,patches,pearl,peanut,penny,pepper,phoebe,precious,princess,pumpkin,quincy,rascal,rocky,romeo,rosie,ruby,rusty,salem,sam,scarlett,scout,sebastian,shadow,simba,smokey,snickers,snowball,socks,sophie,storm,sugar,tabby,taco,tiger,tilly,toby,tucker,violet,waffle,whiskers,whisper,willow,yoshi,zeus,ziggy,zoe"
CAT_NAME_COUNT = 185

function get_cat_name(n) 
  local count = 0
  local start = 1
  
  for i = 1, #CAT_NAMES do
    if sub(CAT_NAMES, i, i) == "," or i == #CAT_NAMES then
      count += 1
      if count == n then
        local endpos = i == #CAT_NAMES and i or i - 1
        return sub(CAT_NAMES, start, endpos)
      end
      start = i + 1
    end
  end
  return nil
end

-- Return a list of n unique integers, the maximium value of which is maxValue
function get_unique_integers(n, maxValue)
  local pool = {}
  local results = {}
  
  -- 1. fill the pool with all possible numbers
  for i=1,maxValue do 
    add(pool, i) 
  end
  
  -- 2. pick 'n' numbers from the pool
  for i=1,n do
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

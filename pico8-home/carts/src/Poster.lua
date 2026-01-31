Poster = {}
Poster.new = function(name, isFemale, traits)
    local self = {}
    self.name = requireNonNil(name)
    self.isFemale = requireNonNil(isFemale)
    self.traits = requireNonNil(traits)
    self.x = SCREEN_WIDTH / 2
    self.y = POSTER_NEW_DISPLAY_POS
    self.targetY = POSTER_TOP_DISPLAY_POS
    self.speed = POSTER_PRINT_SPEED

    function self.update()
        -- adjust y to 'catch up' with targetY
        local diff = self.targetY - self.y
        local dist = abs(diff)
        if dist > 0 then
            if dist <= self.speed then
                self.y = self.targetY
            else
                self.y = self.y + sgn(diff) * self.speed
            end
        end
    end

    function self.draw()
        local traitCount = #self.traits
        local posterHeight = 2 + TEXT_HEIGHT + (2 * TRAIT_SPACING) + (traitCount * (TEXT_HEIGHT + TRAIT_SPACING)) + 2

        local rx = self.x - POSTER_WIDTH / 2
        rectfill(rx, self.y, rx + POSTER_WIDTH - 1, self.y + posterHeight, WHITE) -- white
        rect(rx, self.y, rx + POSTER_WIDTH - 1, self.y + posterHeight, DARK_GRAY) -- outline

        -- print name
        local name_w = #self.name * 8
        local name_x = rx + (POSTER_WIDTH - name_w) / 2
        local name_y = self.y + 2
        local wide_name = "\^w"..self.name
        print(wide_name, name_x, name_y, DARK_BLUE, true)
        
        -- print traits
        local trait_line = 1
        for trait_key, trait_value in pairs(self.traits) do
            local trait_w = #trait_value.name * 8
            local trait_x = rx + (POSTER_WIDTH - trait_w) / 2
            local trait_y = self.y + 9 + ((trait_line - 1) * TEXT_HEIGHT) + 4
            local wide_trait = "\^w"..trait_value.name
            print(wide_trait, trait_x, trait_y, DARK_BLUE, true)
            trait_line = trait_line + 1
        end
    end

    -- return true if all of the traits in this Lost Cat Poster are satisfied by all of the
    -- traits in the given traits array.  Specifically, this is true if and only if there is
    -- no TraitKey 'x' such that self.traits[x] does not equal traits[x]
    function self.isMatch(traits)
        for trait_key, trait_value in pairs(self.traits) do
            if traits[trait_key] != trait_value then
                return false
            end
        end
        return true
    end


    return self
end

-- Returns a list of n Poster objects.  Every poster will be for a cat with a unique name.
function generate_posters(count, minTraits, maxTraits)
  printh("IN")
    minTraits = requireNonNil(minTraits)
    maxTraits = requireNonNil(maxTraits)
    
    local posters = {}
    -- Get n unique integers to use as indices for cat names
    local name_indeces = get_unique_integers(count, 1, CAT_NAME_COUNT)
    for i = 1, count do
        -- determine how many traits this poster should have
        local numTraits = minTraits + flr(rnd(maxTraits - minTraits + 1))
        -- select random trait keys
        local traitKeys = get_unique_integers(numTraits, 1, TRAIT_TYPE_COUNT)
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
        add(posters, Poster.new(name, name_indeces[i] < CAT_NAME_FIRST_MALE, traits))
    end
      printh("OUT")
    return posters
end


-- Cat names stored as comma-delimited string to save tokens
CAT_NAMES = "angel,athena,aurora,baby,bambi,bella,callie,candy,charm,cherry,chloe,cinnamon,cleo,clover,cloudfur,cocoa,cookie,daffodil,daisy,diamond,dusty,echo,faith,fawn,fiona,fluffy,ginger,glitter,gracie,gypsy,harley,harmony,hazel,honey,hope,indigo,iris,ivy,jade,jazz,jewel,jinx,jojo,karma,kiki,kitty,kiwi,latte,lavender,licorice,lily,lollipop,lotus,lulu,lucy,luna,maggie,mango,maple,marble,marshmallow,mischief,misty,mittens,mocha,molly,moonlight,mopsy,muffin,mystic,nala,nova,olive,onyx,opal,pandora,pearl,penny,pepper,phoebe,precious,princess,pumpkin,rosie,ruby,scarlett,scout,sophie,sugar,tabby,tilly,violet,willow,zoe,apollo,ash,bailey,bandit,bear,blaze,boo,boots,buddy,butterball,butterscotch,buttons,cappuccino,caramel,casper,chaos,charlie,cheeto,chester,chip,coconut,comet,copper,cricket,cuddles,doodle,duke,ember,espresso,felix,flash,freckles,garfield,george,ghost,gizmo,goose,gravy,hercules,hobbes,jack,jasper,legend,leo,lightning,loki,louie,lucky,marvel,max,mercury,midnight,milo,moose,murphy,nachos,ninja,noodle,nugget,nutmeg,oak,oliver,oreo,oscar,patches,peanut,quincy,rascal,rocky,romeo,rusty,salem,sam,sebastian,shadow,simba,smokey,snickers,snowball,socks,storm,taco,tiger,toby,tucker,waffle,whiskers,whisper,yoshi,zeus,ziggy"

CAT_NAME_COUNT = 184
CAT_NAME_FIRST_MALE = 94

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

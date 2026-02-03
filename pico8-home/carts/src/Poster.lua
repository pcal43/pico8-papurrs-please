
Poster = {}
Poster.new = function(name, isFemale, traits, randomizeTraitOrder)
    local self = {}
    self.name = requireNonNil(name)
    self.isFemale = requireNonNil(isFemale)
    self.traits = requireNonNil(traits)
    self.traitCount = mapSize(traits)
    self.x = SCREEN_WIDTH / 2
    self.y = POSTER_NEW_DISPLAY_POS
    self.targetY = POSTER_TOP_DISPLAY_POS
    self.speed = POSTER_PRINT_SPEED
    
    -- Build trait text once
    self.traitText = ""
    
    -- Collect traits into array
    local traitArray = {}
    for trait_key, trait_value in pairs(traits) do
        add(traitArray, trait_value)
    end
    
    if randomizeTraitOrder then
        shuffleArray(traitArray)
    end
    
    for i = 1, #traitArray do
        if i > 1 then
            self.traitText = self.traitText.."\n"
        end
        self.traitText = self.traitText..traitArray[i].name
    end

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
        local posterHeight = 2 + TEXT_LINE_HEIGHT + (2 * TRAIT_SPACING) + (self.traitCount * (TEXT_LINE_HEIGHT + TRAIT_SPACING)) + 2

        local rx = self.x - POSTER_WIDTH / 2
        rectfill(rx, self.y, rx + POSTER_WIDTH - 1, self.y + posterHeight, WHITE) -- white
        rect(rx, self.y, rx + POSTER_WIDTH - 1, self.y + posterHeight, DARK_GRAY) -- outline

        -- print name
        local name_y = self.y + 2
        local wide_name = "\^w"..self.name
        printCentered(wide_name, self.x, name_y, DARK_BLUE)
        
        -- print traits
        local trait_y = self.y + 9 + 4
        printCentered(self.traitText, self.x, trait_y, DARK_BLUE)
    end

    function self.isMatch(traits)
        return isPosterMatch(self.traits, traits)
    end

    return self
end

-- Return true if all of the given posterTraits are satisfied by the given catTraits.
-- Specifically, this is true if and only if there is no TraitKey 'x' such that 
-- posterTraits[x] does not equal catTraits[x]
function isPosterMatch(posterTraits, catTraits)
    requireNonNil(posterTraits)
    requireNonNil(catTraits)
    for trait_key, trait_value in pairs(posterTraits) do
        local cat_trait = catTraits[trait_key]
        if cat_trait then
            if cat_trait != trait_value then
                return false
            end
        else
            return false
        end
    end
    return true
end



-- comma-delimited string to save tokens
CAT_NAMES = "angel,athena,aurora,baby,bailey,bambi,bella,callie,candy,charm,cherry,chloe,cinnamon,cleo,clover,cloudfur,cocoa,cookie,daffodil,daisy,diamond,dusty,echo,faith,fawn,fiona,fluffy,ginger,glitter,gracie,gypsy,harley,harmony,hazel,honey,hope,indigo,iris,ivy,jade,jazz,jewel,jinx,jojo,karma,kiki,kitty,kiwi,latte,lavender,licorice,lily,lollipop,lotus,lulu,lucy,luna,maggie,mango,maple,marble,marshmallow,mischief,misty,mittens,mocha,molly,moonlight,mopsy,muffin,mystic,nala,nova,olive,onyx,opal,pandora,pearl,penny,pepper,phoebe,precious,princess,pumpkin,ripley,rosie,ruby,scarlett,scout,sophie,sugar,tabby,tilly,violet,willow,zoe,apollo,ash,bailey,bandit,bear,blaze,boo,boots,buddy,butterball,buttons,cappuccino,caramel,casper,chaos,charlie,cheeto,chester,chip,coconut,comet,copper,cricket,cuddles,doodle,duke,ember,espresso,felix,flash,freckles,garfield,george,ghost,gizmo,goose,gravy,hercules,hobbes,jack,jasper,legend,leo,lightning,loki,louie,lucky,marvel,max,mercury,midnight,milo,moose,murphy,nachos,ninja,noodle,nugget,nutmeg,oak,oliver,oreo,oscar,patches,peanut,quincy,rascal,rocky,romeo,rusty,salem,sam,sebastian,shadow,simba,smokey,snickers,snowball,socks,stormy,taco,tiger,toby,tucker,waffle,whiskers,whisper,yoshi,zeus,ziggy"
CAT_NAME_COUNT = 185
CAT_NAME_FIRST_MALE = 96

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

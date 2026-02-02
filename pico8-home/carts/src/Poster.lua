Poster = {}
Poster.new = function(name, isFemale, traits)
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
    local first = true
    for trait_key, trait_value in pairs(traits) do
        if not first then
            self.traitText = self.traitText.."\n"
        end
        self.traitText = self.traitText..trait_value.name
        first = false
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

    -- return true if all of the traits in this Lost Cat Poster are satisfied by all of the
    -- traits in the given traits array.  Specifically, this is true if and only if there is
    -- no TraitKey 'x' such that self.traits[x] does not equal traits[x]
    function self.isMatch(traits)
        requireNonNil(traits)
        printh("=== isMatch checking for "..self.name.." ===")
        printh("poster has "..mapSize(self.traits).." traits")
        for trait_key, trait_value in pairs(self.traits) do
            printh("checking trait_key="..trait_key)
            printh("  poster trait_value.name="..trait_value.name)
            local cat_trait = traits[trait_key]
            if cat_trait then
                printh("  cat trait_value.name="..cat_trait.name)
                if cat_trait != trait_value then
                    printh("  MISMATCH!")
                    return false
                else
                    printh("  match ok")
                end
            else
                printh("  cat has no trait for key "..trait_key)
                return false
            end
        end
        printh("all traits matched!")
        return true
    end


    return self
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

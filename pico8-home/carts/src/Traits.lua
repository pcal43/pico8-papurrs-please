


TraitKeys= {
    FUR_COLOR = 1,
    FUR_PATTERN = 2,
    EYE_COLOR = 3,
    COLLAR = 4,
}

TraitValues = {}

TraitValues[TraitKeys.FUR_PATTERN] = {
   SOLID = {
     name = "solid color"
   },
   STRIPED = {
     name = "striped"
   },
   CALICO = {
     name = "calico"
   },
}

TraitValues[TraitKeys.COLLAR] = {
    NO_COLLAR = {
      name = "no collar",
      color = -1
    },
    PINK_COLLAR = {
      name = "pink collar",
      color = 14
    },
    GREEN_COLLAR = {
      name = "green collar",
      color = 3
    }
}

TraitValues[TraitKeys.FUR_COLOR] = {
   WHITE = {
     name = "white fur",
     fur = 7,
     stripes = 6,
     whiskers = 5,
     nose = 14,
     outline = 0
   },
   ORANGE = {
     name = "orange fur",
     fur = 9,
     stripes = 4,
     whiskers = 7,
     nose = 14,
     outline = 0
   },
   GRAY = {
     name = "gray fur",
     fur = 5,
     stripes = 6,
     whiskers = 7,
     nose = 9,
     outline = 0
   },
   BLACK = {
     name = "black fur",
     fur = 0,
     stripes = 1,
     whiskers = 7,
     nose = 9,
     outline = 5
   },
   BROWN = {
     name = "brown fur",
     fur = 4,
     stripes = 9,
     whiskers = 7,
     nose = 9,
     outline = 0
   }
}

TraitValues[TraitKeys.EYE_COLOR] = {
   GREEN = {
     name = "green eyes",
     inner = 3,
     outer = 11
   },
   BLUE = {
     name = "blue eys",
     inner = 13,
     outer = 12
   },
   GOLDEN = {
     name = "golden eyes",
     inner = 9,
     outer = 10
   }
}


-- Returns a list of 'count' cat names randomly chosen from a list.  Names are guaranteed to be
-- unique by calling the get_unique function
function get_names(count)

end



-- Cat names stored as comma-delimited string to save tokens
CAT_NAMES = "angel,apollo,ash,athena,aurora,baby,bailey,bambi,bandit,bear,bella,blaze,boo,boots,buddy,butterball,butterscotch,buttons,callie,candy,cappuccino,caramel,casper,chaos,charlie,charm,cheeto,cherry,chester,chip,chloe,cloudfur,cinnamon,cleo,clover,cocoa,coconut,comet,cookie,copper,cricket,cuddles,daffodil,daisy,diamond,doodle,duke,dusty,echo,ember,espresso,faith,fawn,felix,fiona,flash,fluffy,freckles,garfield,george,ghost,ginger,gizmo,glitter,goose,gracie,gravy,gypsy,harley,harmony,hazel,hercules,hobbes,honey,hope,indigo,iris,ivy,jack,jade,jasper,jazz,jewel,jinx,jojo,karma,kiki,kitty,kiwi,latte,lavender,legend,leo,licorice,lightning,lily,loki,lollipop,lotus,louie,lulu,lucy,lucky,luna,maggie,mango,maple,marble,marshmallow,marvel,max,mercury,midnight,milo,mischief,misty,mittens,mocha,molly,moonlight,moose,mopsy,muffin,murphy,mystic,nachos,nala,ninja,noodle,nova,nugget,nutmeg,oak,olive,oliver,onyx,opal,oreo,oscar,pandora,patches,pearl,peanut,penny,pepper,phoebe,precious,princess,pumpkin,quincy,rascal,rocky,romeo,rosie,ruby,rusty,salem,sam,scarlett,scout,sebastian,shadow,simba,smokey,snickers,snowball,socks,sophie,storm,sugar,tabby,taco,tiger,tilly,toby,tucker,violet,waffle,whiskers,whisper,willow,yoshi,zeus,ziggy,zoe"

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


function get_unique(count, maxValue)
  local pool = {}
  local results = {}
  
  -- 1. fill the pool with all possible numbers
  for i=1,maxValue do 
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

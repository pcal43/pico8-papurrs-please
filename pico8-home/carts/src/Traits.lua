

FUR_COLOR = 1
EYE_COLOR = 2
COLLAR_COLOR = 3
STRIPES = 4
EAR_COLOR = 5

TraitKeys = {
  FUR_COLOR,
  EYE_COLOR,
  COLLAR_COLOR,
  STRIPES,
  EAR_COLOR,  
}

TraitValues = {}

TraitValues[STRIPES] = {
   {
     name = "no stripes"
   },
   {
     name = "stripes"
   }
}

TraitValues[COLLAR_COLOR] = {
    {
      name = "no collar",
      color = -1
    },
    {
      name = "pink collar",
      color = PINK
    },
    {
      name = "green collar",
      color = DARK_GREEN
    },
    {
      name = "blue collar",
      color = BLUE
    },
    {
      name = "red collar",
      color = RED
    }
}

TraitValues[FUR_COLOR] = {
   {
     name = "white fur",
     fur = WHITE,
     stripes = LIGHT_GRAY,
     whiskers = DARK_GRAY,
     nose = PINK,
     outline = BLACK
   },
   {
     name = "orange fur",
     fur = ORANGE,
     stripes = BROWN,
     whiskers = WHITE,
     nose = PINK,
     outline = BLACK
   },
   {
     name = "gray fur",
     fur = DARK_GRAY,
     stripes = LIGHT_GRAY,
     whiskers = WHITE,
     nose = ORANGE,
     outline = BLACK
   },
   {
     name = "black fur",
     fur = BLACK,
     stripes = DARK_BLUE,
     whiskers = WHITE,
     nose = ORANGE,
     outline = DARK_GRAY
   },
   {
     name = "brown fur",
     fur = BROWN,
     stripes = ORANGE,
     whiskers = WHITE,
     nose = ORANGE,
     outline = BLACK
   }
}

TraitValues[EYE_COLOR] = {
   {
     name = "green eyes",
     inner = DARK_GREEN,
     outer = GREEN
   },
   {
     name = "blue eyes",
     inner = INDIGO,
     outer = BLUE
   },
   {
     name = "golden eyes",
     inner = ORANGE,
     outer = YELLOW
   }
}

TraitValues[EAR_COLOR] = {
   {
     name = "pink ears",
     color = PINK
   },
   {
     name = "white ears",
     color = WHITE
   },
   {
     name = "black ears",
     inner = BLACK
   }
}


WEEKDAYS = {
    {
        name = "monday",
        posterCount = 4,
        catCount = 5,
        time = 20,
        catTraits = { [EYE_COLOR] = { 1, 1, 2 }, [COLLAR_COLOR] = { 1 }, [EAR_COLOR] = { 1 }, [STRIPES] = { 1 } },
        posterTraits = { FUR_COLOR },
        posterTraitCount = 1
    },
    {
        name = "tuesday",
        posterCount = 6,
        catCount = 7,
        time = 30,
        catTraits = { [COLLAR_COLOR] = { 1, 1, 1, 2 }, [EAR_COLOR] = { 1 }, [STRIPES] = { 1, 1, 1, 1, 1, 1, 2 } },
        posterTraits = { FUR_COLOR, EYE_COLOR },
        posterTraitCount = 2
    },
    {
        name = "wednesday",
        posterCount = 8,
        catCount = 10,
        time = 45,
        catTraits = { [STRIPES] = { 1, 1, 1, 2 } },
        posterTraits = { FUR_COLOR, EYE_COLOR, COLLAR_COLOR },
        posterTraitCount = 3
    },
    {
        name = "thursday",
        posterCount = 10,
        catCount = 12,
        time = 60,
        catTraits = { },
        posterTraits = { FUR_COLOR, EYE_COLOR, COLLAR_COLOR, STRIPES },
        posterTraitCount = 3
    },
    {
        name = "friday",
        posterCount = 12,
        catCount = 15,
        time = 90,
        catTraits = { },
        posterTraits = { EYE_COLOR, STRIPES, EAR_COLOR },
        posterTraitCount = 3
    }
}



-- Cat names stored as comma-delimited string to save tokens
CAT_NAMES = "angel,apollo,ash,athena,aurora,baby,bailey,bambi,bandit,bear,bella,blaze,boo,boots,buddy,butterball,butterscotch,buttons,callie,candy,cappuccino,caramel,casper,chaos,charlie,charm,cheeto,cherry,chester,chip,chloe,cloudfur,cinnamon,cleo,clover,cocoa,coconut,comet,cookie,copper,cricket,cuddles,daffodil,daisy,diamond,doodle,duke,duster,dusty,echo,ember,espresso,faith,fawn,felix,fiona,flash,fluffy,freckles,garfield,george,ghost,ginger,gizmo,glitter,goose,gracie,gravy,gypsy,harley,harmony,hazel,hercules,hobbes,honey,hope,indigo,iris,ivy,jack,jade,jasper,jazz,jewel,jinx,jojo,kara,karma,kiki,kitty,kiwi,latte,lavender,legend,leo,licorice,lightning,lily,loki,lollipop,lotus,louie,lulu,lucy,lucky,luna,maggie,mango,maple,marble,marshmallow,marvel,max,mercury,midnight,milo,mischief,misty,mittens,mocha,molly,moonlight,moose,mopsy,muffin,murphy,mystic,nachos,nala,ninja,noodle,nova,nugget,nutmeg,oak,olive,oliver,onyx,opal,oreo,oscar,pandora,patches,pearl,peanut,penny,pepper,phoebe,precious,princess,pumpkin,quincy,rascal,rocky,romeo,rosie,ruby,rusty,salem,sam,scarlett,scout,sebastian,shadow,simba,smokey,snickers,snowball,socks,sophie,storm,sugar,tabby,taco,tiger,tilly,toby,tucker,violet,waffle,whiskers,whisper,willow,yoshi,zeus,ziggy,zoe"

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


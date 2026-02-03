

-- Returns lists of Cat and Poster objects, each of length count.  Each poster
-- will have a random number of traits (between minTraits and maxTraits).  
-- The traits for the Cats and Posters will be chosen such that there will be a bijection
-- between Cats and Posters: for each Cat returned there will be exactly one Poster that
-- is a match for it (as defined by Poster.isMatch), and vice versa.
--
-- Other than that, the Poster traits will be chosen randomly.  The TraitKeys will be chosen 
-- randomly from those in the list TraitKeys (in Traits.lua).  The values for
-- each Poster trait will be randomly chosen.  A Poster will have at most one mapping for
-- any given TraitKey.
--
-- Cats will have all of the TraitKeys defined in their trait tables, with the TraitValues
-- for each again randomly chosen.  Again, provided that the 1:1 matching relationship
-- between Cats and Posters is maintained
--
-- If the 1:1 matching constraint cannot be maintained, and error should be printed 
-- and the 'count' reduced to the point where the constraints can be satisfied.

function generatePostersAndCats(catCount, catTraits, posterCount, posterTraitCount, posterTraitKeys, randomizePosterTraitOrder)
    if catCount < posterCount then
        printh("error: catCount ("..catCount..") < posterCount ("..posterCount..")")
        catCount = posterCount
    end
    
    printh("generatePosters: "..posterCount.." posters for "..catCount.." cats, "..posterTraitCount.." traits per poster")
    
    local posters = {}
    local cats = {}
    local name_indeces = pickUniqueIntegers(catCount, 1, CAT_NAME_COUNT)
    
    local usedPosterCombos = {}
    local usedCatCombos = {}
    local pairAttempts = 0
    local maxPairAttempts = posterCount * 200
    
    -- Step 1: Generate poster-cat pairs until we have enough
    while #posters < posterCount and pairAttempts < maxPairAttempts do
        pairAttempts += 1
        
        -- Generate a random poster with exactly posterTraitCount traits
        local availableKeys = {}
        for i = 1, #posterTraitKeys do
            add(availableKeys, posterTraitKeys[i])
        end
        
        local selectedKeys = {}
        for i = 1, posterTraitCount do
            if #availableKeys > 0 then
                local idx = flr(rnd(#availableKeys)) + 1
                add(selectedKeys, availableKeys[idx])
                del(availableKeys, availableKeys[idx])
            end
        end
        
        local posterTraits = {}
        local posterComboKey = ""
        for i = 1, #selectedKeys do
            local traitKey = selectedKeys[i]
            local possibleValues = TraitValues[traitKey]
            local valueIdx = flr(rnd(#possibleValues)) + 1
            posterTraits[traitKey] = possibleValues[valueIdx]
            posterComboKey = posterComboKey..traitKey..":"..valueIdx..","
        end
        
        if not usedPosterCombos[posterComboKey] then
            -- Try to create a matching cat for this poster
            local catAttempts = 0
            local maxCatAttempts = 50
            local foundValidCat = false
            
            while not foundValidCat and catAttempts < maxCatAttempts do
                catAttempts += 1
                
                local thisCatTraits = {}
                for traitKey, traitValue in pairs(posterTraits) do
                    thisCatTraits[traitKey] = traitValue
                end
                
                for i = 1, #TraitKeys do
                    local traitKey = TraitKeys[i]
                    if thisCatTraits[traitKey] == nil then
                        local possibleValues = TraitValues[traitKey]
                        local allowedIndices = catTraits[traitKey]
                        if allowedIndices then
                            local idx = allowedIndices[flr(rnd(#allowedIndices)) + 1]
                            thisCatTraits[traitKey] = possibleValues[idx]
                        else
                            local idx = flr(rnd(#possibleValues)) + 1
                            thisCatTraits[traitKey] = possibleValues[idx]
                        end
                    end
                end
                
                local catComboKey = ""
                for i = 1, #TraitKeys do
                    local traitKey = TraitKeys[i]
                    catComboKey = catComboKey..traitKey..":"..thisCatTraits[traitKey].name..","
                end
                
                if not usedCatCombos[catComboKey] then
                    -- Check if this cat matches any existing poster
                    local matchCount = 0
                    for i = 1, #posters do
                        if posters[i].isMatch(thisCatTraits) then
                            matchCount += 1
                            break
                        end
                    end
                    
                    -- Verify matches the new poster (by construction it should)
                    if isPosterMatch(posterTraits, thisCatTraits) then
                        matchCount += 1
                    end
                    
                    if matchCount == 1 then
                        -- Success! Add both poster and cat
                        usedPosterCombos[posterComboKey] = true
                        usedCatCombos[catComboKey] = true
                        
                        local posterIndex = #posters + 1
                        local name = requireNonNil(get_cat_name(name_indeces[posterIndex]), "nil cat name")
                        add(posters, Poster.new(name, name_indeces[posterIndex] < CAT_NAME_FIRST_MALE, posterTraits, randomizePosterTraitOrder))
                        add(cats, Cat.new(TUXEDO_CAT, thisCatTraits))
                        foundValidCat = true
                    end
                end
            end
        end
    end
    
    if #posters < posterCount then
        printh("warning: only generated "..#posters.." poster-cat pairs (requested "..posterCount..") after "..pairAttempts.." attempts")
    end
    
    -- Step 3: Generate additional cats if catCount > posterCount (these won't match any poster)
    attempts = 0
    maxAttempts = (catCount - posterCount) * 50
    
    while #cats < catCount and attempts < maxAttempts do
        attempts += 1
        
        local thisCatTraits = {}
        local catComboKey = ""
        for i = 1, #TraitKeys do
            local traitKey = TraitKeys[i]
            local possibleValues = TraitValues[traitKey]
            local allowedIndices = catTraits[traitKey]
            local idx
            if allowedIndices then
                idx = allowedIndices[flr(rnd(#allowedIndices)) + 1]
            else
                idx = flr(rnd(#possibleValues)) + 1
            end
            thisCatTraits[traitKey] = possibleValues[idx]
            catComboKey = catComboKey..traitKey..":"..possibleValues[idx].name..","
        end
        
        if not usedCatCombos[catComboKey] then
            -- Check if this cat would match any poster
            local matchesAnyPoster = false
            for i = 1, #posters do
                if posters[i].isMatch(thisCatTraits) then
                    matchesAnyPoster = true
                    break
                end
            end
            
            if not matchesAnyPoster then
                usedCatCombos[catComboKey] = true
                add(cats, Cat.new(TUXEDO_CAT, thisCatTraits))
            end
        end
    end
    
    if #cats < catCount then
        printh("warning: only generated "..#cats.." unique cats (requested "..catCount..")")
    end
    
    -- Shuffle cats so they're not in the same order as posters
    shuffleArray(cats)
    
    -- printh("generated "..#cats.." cats and "..#posters.." posters")
    return posters, cats
end

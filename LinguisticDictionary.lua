---=============================================================================
-- REPLACE PRONOUNS
--=============================================================================
function KhajiitVoice:ReplaceFirstPronounOnly(text, selfRef)
    local result = text
    local replaced = false

    -- Replace first "I" occurrence only
    if not replaced then
        result, replaced = string.gsub(result, "(%f[%a])[Ii](%f[%A])", function(pre, post)
            if replaced then return pre .. "I" .. post end
            replaced = true
            return pre .. selfRef .. post
        end, 1)
    end

    -- If no "I" found, try contractions
    if not replaced then
        result = string.gsub(result, "(%f[%a])I'm(%f[%A])", selfRef .. " is", 1)
        result = string.gsub(result, "(%f[%a])I'll(%f[%A])", selfRef .. " will", 1)
        result = string.gsub(result, "(%f[%a])I've(%f[%A])", selfRef .. " has", 1)
        result = string.gsub(result, "(%f[%a])I'd(%f[%A])", selfRef .. " would", 1)
    end

    return result
end

function KhajiitVoice:ReplaceSelectivePronouns(text, selfRef)
    local result = text

    -- Strategy: Replace the first pronoun, then use alternatives for subsequent ones
    local pronounPositions = {}
    local lowerText = text:lower()

    -- Find all pronoun positions
    for start, ending in string.gmatch(lowerText, "()" .. "%f[%a]i%f[%A]" .. "()") do
        table.insert(pronounPositions, { start, ending, "I" })
    end

    -- Sort by position
    table.sort(pronounPositions, function(a, b) return a[1] < b[1] end)

    -- Replace strategically
    local replacements = 0
    local maxReplacements = math.min(2, #pronounPositions) -- Limit replacements

    for i, pos in ipairs(pronounPositions) do
        if replacements >= maxReplacements then break end

        local before = string.sub(text, 1, pos[1] - 1)
        local after = string.sub(text, pos[2])

        if i == 1 then
            -- First pronoun gets full replacement
            result = before .. selfRef .. after
            replacements = replacements + 1
        elseif math.random(1, 100) <= 30 then
            -- 30% chance to replace subsequent pronouns
            local alternatives = { "this one", "Khajiit" }
            local alt = alternatives[math.random(1, #alternatives)]
            result = before .. alt .. after
            replacements = replacements + 1
        end
    end

    -- Handle possessives and objects more conservatively
    result = self:ReplaceObjectPronouns(result, selfRef)
    result = self:ReplacePossessivePronouns(result, selfRef)

    return result
end

function KhajiitVoice:ReplaceSubjectPronouns(text, selfRef)
    local result = text
    -- Count total first-person pronouns to determine strategy
    local pronounCount = self:CountFirstPersonPronouns(result)

    -- Handle contractions first (they're the most obvious to replace)
    result = string.gsub(result, "^I'm ", selfRef .. " is ")
    result = string.gsub(result, " I'm ", " " .. selfRef .. " is ")
    result = string.gsub(result, "^I'll ", selfRef .. " will ")
    result = string.gsub(result, " I'll ", " " .. selfRef .. " will ")
    result = string.gsub(result, "^I've ", selfRef .. " has ")
    result = string.gsub(result, " I've ", " " .. selfRef .. " has ")
    result = string.gsub(result, "^I'd ", selfRef .. " would ")
    result = string.gsub(result, " I'd ", " " .. selfRef .. " would ")
    result = string.gsub(result, " What am I ", " " .. "What is " .. selfRef .. " ")
    result = string.gsub(result, " I deal ", selfRef .. " deals ")

    -- Handle "I am", "I have", etc.
    result = string.gsub(result, "I can handle myself", "The moons watch over " .. selfRef)
    result = string.gsub(result, "^I am ", selfRef .. " is ")
    result = string.gsub(result, " I am ", " " .. selfRef .. " is ")
    result = string.gsub(result, "^I have ", selfRef .. " has ")
    result = string.gsub(result, " I have ", " " .. selfRef .. " has ")
    result = string.gsub(result, "^I will ", selfRef .. " will ")
    result = string.gsub(result, " I will ", " " .. selfRef .. " will ")
    result = string.gsub(result, "^I can ", selfRef .. " can ")
    result = string.gsub(result, " I can ", " " .. selfRef .. " can ")

    -- NEW: Handle "I want", "I need", etc.
    result = string.gsub(result, "do I need([^%a])", "does " .. selfRef .. " need%1")
    result = string.gsub(result, "do I need$", "does " .. selfRef .. " need")
    result = string.gsub(result, "^I want ", selfRef .. " wants ")
    result = string.gsub(result, " I want ", " " .. selfRef .. " wants ")
    result = string.gsub(result, "^I need ", selfRef .. " needs ")
    result = string.gsub(result, " I need ", " " .. selfRef .. " needs ")
    result = string.gsub(result, "^I like ", selfRef .. " likes ")
    result = string.gsub(result, " I like ", " " .. selfRef .. " likes ")
    result = string.gsub(result, "^I love ", selfRef .. " loves ")
    result = string.gsub(result, " I love ", " " .. selfRef .. " loves ")
    result = string.gsub(result, "^I hate ", selfRef .. " hates ")
    result = string.gsub(result, " I hate ", " " .. selfRef .. " hates ")
    result = string.gsub(result, "^I feel ", selfRef .. " feels ")
    result = string.gsub(result, " I feel ", " " .. selfRef .. " feels ")
    result = string.gsub(result, "^I want ", selfRef .. " wants ")
    result = string.gsub(result, " me ", " " .. selfRef .. " ")
    result = string.gsub(result, "I think ", " " .. selfRef .. " thinks ")
    result = string.gsub(result, "I work ", " " .. selfRef .. " works ")
    result = string.gsub(result, " do I ", " does " .. selfRef .. " ")

    -- For multiple pronouns, be more selective with remaining "I" replacements
    if pronounCount > 2 then
        -- Replace only some "I" instances to avoid over-repetition
        local replacementCount = 0
        local maxReplacements = 2 -- Limit to 2 additional "I" replacements

        result = string.gsub(result, "^I ", function()
            if replacementCount < maxReplacements then
                replacementCount = replacementCount + 1
                return selfRef .. " "
            end
            return "I " -- Keep original
        end)

        result = string.gsub(result, " I ", function()
            if replacementCount < maxReplacements and math.random(1, 100) <= 70 then
                replacementCount = replacementCount + 1
                return " " .. selfRef .. " "
            end
            return " I " -- Keep original
        end)
    else
        -- For single/double pronouns, replace normally
        result = string.gsub(result, "^I ", selfRef .. " ")
        result = string.gsub(result, " I ", " " .. selfRef .. " ")
    end

    return result
end

function KhajiitVoice:ConjugateVerbs(text, selfRef)
    local result = text

    -- Only conjugate if we're using 3rd person (this one, Khajiit, character name)
    if selfRef == "I" then
        return result -- No conjugation needed
    end

    -- Handle specific patterns in order of specificity (most specific first)

    -- 1. Handle "do to" phrases first (most specific) - keep unchanged
    -- This pattern protects "do to" from being changed to "does to"
    local doToPlaceholder = "##DOTO##"
    result = string.gsub(result, "(%f[%w])do to(%f[%W])", doToPlaceholder)

    -- 2. Handle "Do" at start of questions
    result = string.gsub(result, "^Do ", "Does ")
    result = string.gsub(result, "([%.%!%?]%s+)Do ", "%1Does ")

    -- 3. Handle "do not" -> "does not"
    result = string.gsub(result, "(%f[%w])do not(%f[%W])", "does not")
    result = string.gsub(result, "(%f[%w])don't(%f[%W])", "doesn't")

    -- 4. Handle other "do" cases (least specific, so comes last)
    result = string.gsub(result, "(%f[%w])do(%f[%W])", "does")

    -- 5. Restore the "do to" phrases
    result = string.gsub(result, doToPlaceholder, "do to")

    -- Handle other common verb conjugations
    result = string.gsub(result, "(%f[%w])have(%f[%W])", "has")
    result = string.gsub(result, "(%f[%w])are(%f[%W])", "is") -- "this one are" -> "this one is"

    -- Handle more verbs that need conjugation
    result = string.gsub(result, "(%f[%w])go(%f[%W])", "goes")

    result = string.gsub(result, "(%f[%w])come(%f[%W])", "comes")
    result = string.gsub(result, "(%f[%w])want(%f[%W])", "wants")
    result = string.gsub(result, "(%f[%w])need(%f[%W])", "needs")
    result = string.gsub(result, "(%f[%w])like(%f[%W])", "likes")
    result = string.gsub(result, "(%f[%w])love(%f[%W])", "loves")
    result = string.gsub(result, "(%f[%w])hate(%f[%W])", "hates")
    result = string.gsub(result, "(%f[%w])feel(%f[%W])", "feels")
    result = string.gsub(result, "(%f[%w])think(%f[%W])", "thinks")
    result = string.gsub(result, "(%f[%w])know(%f[%W])", "knows")
    result = string.gsub(result, "(%f[%w])see(%f[%W])", "sees")
    result = string.gsub(result, "(%f[%w])hear(%f[%W])", "hears")
    result = string.gsub(result, "(%f[%w])understand(%f[%W])", "understands")
    result = string.gsub(result, "(%f[%w])believe(%f[%W])", "believes")
    result = string.gsub(result, "(%f[%w])hope(%f[%W])", "hopes")
    result = string.gsub(result, "(%f[%w])try(%f[%W])", "tries")
    result = string.gsub(result, "(%f[%w])work(%f[%W])", "works")
    result = string.gsub(result, "(%f[%w])live(%f[%W])", "lives")
    result = string.gsub(result, "(%f[%w])stay(%f[%W])", "stays")
    result = string.gsub(result, "(%f[%w])play(%f[%W])", "plays")
    result = string.gsub(result, "(%f[%w])fight(%f[%W])", "fights")
    result = string.gsub(result, "(%f[%w])run(%f[%W])", "runs")
    result = string.gsub(result, "(%f[%w])walk(%f[%W])", "walks")
    result = string.gsub(result, "(%f[%w])talk(%f[%W])", "talks")
    result = string.gsub(result, "(%f[%w])speak(%f[%W])", "speaks")
    result = string.gsub(result, "(%f[%w])say(%f[%W])", "says")
    result = string.gsub(result, "(%f[%w])tell(%f[%W])", "tells")
    result = string.gsub(result, "(%f[%w])ask(%f[%W])", "asks")
    result = string.gsub(result, "(%f[%w])answer(%f[%W])", "answers")
    result = string.gsub(result, "(%f[%w])help(%f[%W])", "helps")
    result = string.gsub(result, "(%f[%w])give(%f[%W])", "gives")
    result = string.gsub(result, "(%f[%w])take(%f[%W])", "takes")
    result = string.gsub(result, "(%f[%w])bring(%f[%W])", "brings")
    result = string.gsub(result, "(%f[%w])carry(%f[%W])", "carries")
    result = string.gsub(result, "(%f[%w])find(%f[%W])", "finds")
    result = string.gsub(result, "(%f[%w])look(%f[%W])", "looks")
    result = string.gsub(result, "(%f[%w])search(%f[%W])", "searches")
    result = string.gsub(result, "(%f[%w])buy(%f[%W])", "buys")
    result = string.gsub(result, "(%f[%w])sell(%f[%W])", "sells")
    result = string.gsub(result, "(%f[%w])pay(%f[%W])", "pays")
    result = string.gsub(result, "(%f[%w])cost(%f[%W])", "costs")
    result = string.gsub(result, "(%f[%w])own(%f[%W])", "owns")
    result = string.gsub(result, "(%f[%w])use(%f[%W])", "uses")
    result = string.gsub(result, "(%f[%w])make(%f[%W])", "makes")
    result = string.gsub(result, "(%f[%w])create(%f[%W])", "creates")
    result = string.gsub(result, "(%f[%w])build(%f[%W])", "builds")
    result = string.gsub(result, "(%f[%w])destroy(%f[%W])", "destroys")
    result = string.gsub(result, "(%f[%w])break(%f[%W])", "breaks")
    result = string.gsub(result, "(%f[%w])fix(%f[%W])", "fixes")
    result = string.gsub(result, "(%f[%w])repair(%f[%W])", "repairs")
    result = string.gsub(result, "(%f[%w])change(%f[%W])", "changes")
    result = string.gsub(result, "(%f[%w])move(%f[%W])", "moves")
    result = string.gsub(result, "(%f[%w])travel(%f[%W])", "travels")
    result = string.gsub(result, "(%f[%w])visit(%f[%W])", "visits")
    result = string.gsub(result, "(%f[%w])return(%f[%W])", "returns")
    result = string.gsub(result, "(%f[%w])leave(%f[%W])", "leaves")
    result = string.gsub(result, "(%f[%w])arrive(%f[%W])", "arrives")
    return result
end

function KhajiitVoice:ReplaceAllPronouns(text, selfRef, isQuestion)
    local result = text

    -- Handle contractions first (they're easier to get right)
    result = string.gsub(result, "(%f[%a])I'm(%f[%A])", selfRef .. " is")
    result = string.gsub(result, "(%f[%a])I'll(%f[%A])", selfRef .. " will")
    result = string.gsub(result, "(%f[%a])I've(%f[%A])", selfRef .. " has")
    result = string.gsub(result, "(%f[%a])I'd(%f[%A])", selfRef .. " would")

    -- Handle "I am", "I have", etc.

    result = string.gsub(result, "(%f[%a])I am(%f[%A])", selfRef .. " is")
    result = string.gsub(result, "(%f[%a])I have(%f[%A])", selfRef .. " has")
    result = string.gsub(result, "(%f[%a])I will(%f[%A])", selfRef .. " will")
    result = string.gsub(result, "(%f[%a])I can(%f[%A])", selfRef .. " can")
    result = string.gsub(result, "(%f[%a])I should(%f[%A])", selfRef .. " should")
    result = string.gsub(result, "(%f[%a])I would(%f[%A])", selfRef .. " would")
    result = string.gsub(result, "(%f[%a])I could(%f[%A])", selfRef .. " could")
    result = string.gsub(result, "(%f[%a])I head(%f[%A])", selfRef .. " heads")
    result = string.gsub(result, "(%f[%a])already know(%f[%A])", selfRef .. " already knows")
    result = string.gsub(result, "(%f[%a])do I(%f[%A])", "would" .. selfRef .. " ")

    result = string.gsub(result, "(%f[%a])Do(%f[%A])", "Does ")
    result = string.gsub(result, " have ", " has ")

    -- Handle remaining "I" instances
    result = string.gsub(result, "(%f[%a])I(%f[%A])", selfRef)

    -- Handle object and possessive pronouns with separate functions
    result = self:ReplaceObjectPronouns(result, selfRef)
    result = self:ReplacePossessivePronouns(result, selfRef)

    return result
end

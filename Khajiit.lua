-- ESO Khajiit Dialogue Replacer Addon
-- A contemplative approach to authentic Khajiit speech patterns

local ADDON_NAME = "KhajiitVoice"
KhajiitVoice = {}
KhajiitVoice.savedVars = nil

KhajiitVoice.currentDialogueReplacements = {}
KhajiitVoice.firstAppearanceCache = {}

local defaults = {
    enabled = true,
    pronounWeights = {
        thisOne = 70,  -- "This one" weight (humble, traditional)
        charName = 20, -- Character name weight (personal, confident)
        khajiit = 10   -- "Khajiit" weight (generic, formal)
    },
    personalityTraits = {
        replaceGoodbyes = false,
        cyrodiilicTone = 0,

        scholarlyTone = 0,
        kindSoulTone = 0
    },
}
local patterns = {
    subjectPronouns = {
        ["^[Ii] "] = true,
        [" [Ii] "] = true,
        ["^[Ii]'"] = true,
        [" [Ii]'"] = true
    },
    objectPronouns = {
        [" me"] = true,
        [" myself"] = true,
        ["^[Mm]e "] = true,
        ["^[Mm]yself "] = true
    },
    possessivePronouns = {
        [" my "] = true,
        [" mine"] = true,
        ["^[Mm]y "] = true,
        ["^[Mm]ine"] = true
    },
    khajiitExpressions = {
        farewell = {
            "May your road lead you to warm sands.",
            "Farewell.",
            "May Jone and Jode guide your steps.",
            "Until the moons bring us together again.",
            "May your path be lit by bright moons.",
        },
        greeting = {
            "Bright moons, walker - ",
            "The moons smile upon this meeting - ",
            "This one's whiskers twitch with joy at seeing you - ",
            "The winds brought whispers of your approach - ",
            "Ah, a familiar scent on the desert wind - ",
        },
        khajQuestion = {
            ", yes?"
        },

        -- Scholarly/poetic expressions
        scholarlyExpressions = {
            greetings = {
                "The moons illuminate our fateful meeting",
                "Like ancient scrolls unfurling, our paths converge",
                "The wisdom of ages whispers of your approach",
                "As ink flows upon parchment, so do our destinies intertwine",
                "The celestial dance brings us to this moment"
            },
            farewells = {
                "May the written word guide your journey's end",
                "The great library of existence awaits your next chapter",
                "As scribes preserve knowledge, so shall this one remember",
                "May your story be writ in starlight and moon-glow"
            },
            replacements = {
                ["I understand"] = "this one comprehends the deeper meaning",
                ["I know"] = "such knowledge rests within this one's learned mind",
                ["I think"] = "this one's scholarly contemplation suggests",
                ["yes"] = "indeed, as the ancient texts would agree",
                ["maybe"] = "perhaps, as the philosophers might ponder"
            },
            questionStarters = {
                -- Simple starters (for intensity < 50)
                simple = {
                    "This one wonders - ",
                    "This one is curious - ",
                    "This one must know - ",
                    "Tell this one - ",
                    "This one seeks to understand - "
                },
                -- Verbose starters (for intensity >= 50)
                verbose = {
                    "The wisdom of ages compels this one to ask - ",
                    "This one's learned mind seeks to understand - ",
                    "As the philosophers would inquire - ",
                    "This one's studies suggest the question - ",
                    "The scrolls of knowledge prompt this one to wonder - ",
                    "Curiosity drives this one to ask - ",
                    "This one begs the question - ",
                }
            }
        },
        kindSoulExpressions = {
            greetings = {
                "Blessings of the warm sands upon you, dear friend",
                "This one's heart brightens like morning sun at your presence",
                "What a lovely soul graces this one's path today",
                "Sweet stranger, the moons have brought us together with purpose",
                "This one feels such warmth in meeting you, gentle spirit",
                "Your kind aura touches this one's whiskers with joy",
                "Like a gentle breeze through the desert, you bring comfort"
            },
            farewells = {
                "May gentle winds carry you to happiness.",
                "This one's heart keeps a warm place for you always.",
                "Until we meet again",
                "May your path be lined with flowers and friendship.",
                "Soft moonlight guide your precious steps, cherished soul.",
                "This one sends you forth wrapped in warmest wishes.",
                "Go well, beautiful spirit, and know you are treasured."
            },
            replacements = {
                ["I'm sorry"] = "this one's heart aches with regret, dear friend",
                ["thank you"] = "this one's soul overflows with gratitude, sweet one",
                ["I hope"] = "this one's tender heart hopes with all its warmth",
                ["good luck"] = "may fortune smile upon your precious endeavors",
                ["I understand"] = "this one's caring heart comprehends completely",
                ["of course"] = "naturally, dear soul, with the greatest pleasure",
            },
            endearments = {
                ", friend",
                ", sweet soul",
                ", precious one",
                ", walker",
            },
            gentleActions = {
                beginnings = {
                    "<whiskers twitch with gentle joy> ",
                    "<ears flutter with tender concern> ",
                    "<eyes sparkling with warmth> ",
                    "<tail curled with affection> ",
                    "<head tilted> "
                },
                endings = {
                    " <purrs softly with contentment>",
                    " <whiskers trembling with emotion>",
                    " <eyes shining with kindness>",
                    " <tail swaying gently>",
                    " <paws placed over heart>",
                    " <soft sigh of compassion>"
                }
            },
            flowerySpeech = {
                intensifiers = {
                    ["very"] = "absolutely precious and",
                    ["really"] = "truly, from the depths of this one's heart,",
                    ["quite"] = "most beautifully",
                    ["pretty"] = "breathtakingly lovely",
                    ["nice"] = "wonderfully heartwarming",
                    ["good"] = "absolutely divine"
                }
            }
        },
    }
}

---=============================================================================
-- Utility Functions
--=============================================================================
local function getStableRandom(text, min, max)
    -- Create a stable seed based on the text content
    local seed = 0
    for i = 1, #text do
        seed = seed + string.byte(text, i)
    end

    -- Use the seed to get a deterministic "random" number
    math.randomseed(seed)
    local result = math.random(min, max)

    -- Reset random seed for other uses
    math.randomseed(os.time())
    return result
end

-- Helper function to find text element within an option
function KhajiitVoice:FindTextElement(option)
    -- Try direct properties first
    if option.text and option.text.GetText then
        return option.text
    elseif option.label and option.label.GetText then
        return option.label
    elseif option.optionText and option.optionText.GetText then
        return option.optionText
    elseif option.GetText then
        return option
    else
        -- Search through children for text elements
        for j = 1, option:GetNumChildren() do
            local child = option:GetChild(j)
            if child and child.GetText then
                local childText = child:GetText()
                if childText and childText ~= "" then
                    return child
                end
            end
        end
    end
    return nil
end

function KhajiitVoice:GetGenderedPronoun(pronounType, isSubject)
    local gender = GetUnitGender("player")
    local isMale = (gender == GENDER_MALE)

    if pronounType == "possessive" then
        return isMale and "his" or "her"
    elseif pronounType == "object" then
        return isMale and "him" or "her"
    elseif pronounType == "subject" and isSubject then
        return isMale and "he" or "she"
    else
        -- Default fallback
        return "this one"
    end
end

function KhajiitVoice:ContainsPlayerName(text)
    local playerName = GetUnitName("player")
    if not playerName or playerName == "" then
        return false
    end

    local lowerText = text:lower()
    local lowerPlayerName = playerName:lower()

    -- Check for player name as a whole word
    local pattern = "%f[%w]" .. lowerPlayerName:gsub("([^%w])", "%%%1") .. "%f[%W]"
    return string.find(lowerText, pattern) ~= nil
end

function KhajiitVoice:HandlePlayerNameCases(text)
    local playerName = GetUnitName("player")
    if not playerName or playerName == "" then
        return text
    end

    local result = text
    local lowerPlayerName = playerName:lower()

    -- Handle "I am [PlayerName]" -> "This one is [PlayerName]"
    local iAmNamePattern = "I am " .. playerName:gsub("([^%w])", "%%%1")
    result = string.gsub(result, iAmNamePattern, "This one is " .. playerName, 1)

    -- Handle case insensitive version
    local iAmNamePatternLower = "i am " .. lowerPlayerName:gsub("([^%w])", "%%%1")
    result = string.gsub(result, iAmNamePatternLower, "This one is " .. playerName, 1)

    -- Handle "My name is [PlayerName]" -> "This one's name is [PlayerName]"
    local myNamePattern = "My name is " .. playerName:gsub("([^%w])", "%%%1")
    result = string.gsub(result, myNamePattern, "This one's name is " .. playerName, 1)

    local myNamePatternLower = "my name is " .. lowerPlayerName:gsub("([^%w])", "%%%1")
    result = string.gsub(result, myNamePatternLower, "This one's name is " .. playerName, 1)

    -- Handle other common patterns
    local patterns = {
        { "I'm " .. playerName:gsub("([^%w])", "%%%1"),      "This one is " .. playerName },
        { "i'm " .. lowerPlayerName:gsub("([^%w])", "%%%1"), "This one is " .. playerName },
        { "I, " .. playerName:gsub("([^%w])", "%%%1"),       "This one, " .. playerName },
        { "i, " .. lowerPlayerName:gsub("([^%w])", "%%%1"),  "This one, " .. playerName },
    }

    for _, patternInfo in ipairs(patterns) do
        result = string.gsub(result, patternInfo[1], patternInfo[2], 1)
    end

    return result
end

---=============================================================================
-- SENTENCE STRUCTURE
--=============================================================================
function KhajiitVoice:ReduceRepetition(text, originalText)
    local result = text

    -- Count occurrences of "this one"
    local thisOneCount = 0
    for match in string.gmatch(result:lower(), "this one") do
        thisOneCount = thisOneCount + 1
    end

    -- If there are 3 or more "this one" references, replace some with alternatives
    if thisOneCount >= 3 then
        local replacements = 0
        local maxReplacements = math.floor(thisOneCount / 2) -- Replace up to half

        -- Replace some "this one" with alternatives, but skip the first one
        local foundFirst = false
        local replacementIndex = 0
        result = string.gsub(result, "this one", function(match)
            if not foundFirst then
                foundFirst = true
                return match -- Keep the first one
            end

            replacementIndex = replacementIndex + 1
            if replacements < maxReplacements and getStableRandom(originalText, 1, 100, "reduce" .. replacementIndex) <= 50 then
                replacements = replacements + 1
                local alternatives = { "Khajiit", "I" }
                local altIndex = getStableRandom(originalText, 1, #alternatives, "alt" .. replacementIndex)
                return alternatives[altIndex]
            end
            return match
        end)
    end

    return result
end

function KhajiitVoice:EnsurePunctuation(text)
    -- Clean up spaces
    local result = string.gsub(text, "%s+", " ")

    -- Trim whitespace
    result = string.gsub(result, "%s+$", "")
    result = string.gsub(result, "^%s+", "")

    -- Check if it already ends with punctuation
    if not string.find(result, "[%.%!%?]$") and not string.sub(result, -1) == ">" then
        result = result .. "."
    end

    -- Capitalize first letter
    result = string.gsub(result, "^(.)", function(firstChar)
        return string.upper(firstChar)
    end)

    -- Capitalize after sentence endings and clean whitespace around punctuation
    result = string.gsub(result, "([%.%!%?])%s+(.)", function(punct, nextChar)
        return punct .. " " .. string.upper(nextChar)
    end)

    -- Handle "this one" at sentence beginnings specifically
    result = string.gsub(result, "^this one", "This one")
    result = string.gsub(result, "([%.%!%?]%s+)this one", function(punctuation)
        return punctuation .. "This one"
    end)

    -- Remove any remaining multiple spaces
    result = string.gsub(result, "%s+", " ")

    return result
end

function KhajiitVoice:CountFirstPersonPronouns(text)
    local count = 0
    local lowerText = text:lower()

    -- Count "I" as whole word
    _, count = string.gsub(lowerText, "%f[%w]i%f[%W]", "")

    -- Count contractions
    local contractionCount = 0
    _, contractionCount = string.gsub(lowerText, "i'm", "")
    count = count + contractionCount
    _, contractionCount = string.gsub(lowerText, "i'll", "")
    count = count + contractionCount
    _, contractionCount = string.gsub(lowerText, "i've", "")
    count = count + contractionCount
    _, contractionCount = string.gsub(lowerText, "i'd", "")
    count = count + contractionCount

    -- Count other first-person pronouns
    _, contractionCount = string.gsub(lowerText, "%f[%w]my%f[%W]", "")
    count = count + contractionCount
    _, contractionCount = string.gsub(lowerText, "%f[%w]me%f[%W]", "")
    count = count + contractionCount
    _, contractionCount = string.gsub(lowerText, "%f[%w]myself%f[%W]", "")
    count = count + contractionCount
    return count
end

function KhajiitVoice:FixEdgeCases(text, selfRef)
    local result = text

    -- Only fix for 3rd person references
    if selfRef == "I" then
        return result
    end

    -- Helper function to handle both capitalized and lowercase versions
    local function fixPattern(text, pattern, replacement)
        -- Handle lowercase version
        text = string.gsub(text, pattern, replacement)
        -- Handle capitalized version (first letter capitalized)
        local capPattern = pattern:gsub("^%l", string.upper)
        local capReplacement = replacement:gsub("^%l", string.upper)
        text = string.gsub(text, capPattern, capReplacement)
        return text
    end

    -- Edge case fixes - add new ones here as you find them
    result = fixPattern(result, selfRef .. " just want", selfRef .. " just wants")
    result = fixPattern(result, selfRef .. " just need", selfRef .. " just needs")
    result = fixPattern(result, selfRef .. " just like", selfRef .. " just likes")
    result = fixPattern(result, selfRef .. " just love", selfRef .. " just loves")
    result = fixPattern(result, selfRef .. " just hate", selfRef .. " just hates")
    result = fixPattern(result, selfRef .. " just feel", selfRef .. " just feels")
    result = fixPattern(result, selfRef .. " just think", selfRef .. " just thinks")
    result = fixPattern(result, selfRef .. " just know", selfRef .. " just knows")

    -- Add more patterns as you discover them
    result = fixPattern(result, selfRef .. " really want", selfRef .. " really wants")
    result = fixPattern(result, selfRef .. " really need", selfRef .. " really needs")
    local genderedSubject = self:GetGenderedPronoun("object", true)
    result = fixPattern(result, " you want he", " you want " .. genderedSubject)
    result = fixPattern(result, " you want she", " you want " .. genderedSubject)
    result = fixPattern(result, " you need he", " you want " .. genderedSubject)
    result = fixPattern(result, " you need she", " you want " .. genderedSubject)
    result = fixPattern(result, "Does you ", "Do you ")
    result = fixPattern(result, "he go ", "he goes ")
    result = fixPattern(result, "she go ", "she goes ")
    result = fixPattern(result, "sent he ", "sent this one ")
    result = fixPattern(result, "she she ", "sent this one ")
    result = fixPattern(result, "prove he.", "prove himself.")
    result = fixPattern(result, "prove she.", "prove herself.")
    result = fixPattern(result, "introduce he.", "make introductions.")
    result = fixPattern(result, "introduce she.", "make introductions.")


    return result
end

-- Add this function to convert second pronouns to gendered ones
function KhajiitVoice:ConvertSecondPronounToGenderedSimple(text)
    local result = text

    -- Count "this one" occurrences in the text
    local thisOneCount = 0
    for match in string.gmatch(result:lower(), "this one") do
        thisOneCount = thisOneCount + 1
    end

    -- Only process if there are 2 or more "this one" references
    if thisOneCount >= 2 then
        local replacementCount = 0
        local targetReplacement = 2 -- Replace the 2nd occurrence

        -- Replace the second "this one" with gendered pronoun
        result = string.gsub(result, "([Tt]his one)", function(match)
            replacementCount = replacementCount + 1
            if replacementCount == targetReplacement then
                -- Determine if this is subject, object, or possessive context
                local beforeMatch = string.sub(result, 1, string.find(result, match, 1, true) - 1)
                local afterMatch = string.sub(result, string.find(result, match, 1, true) + #match)

                -- Check for possessive context (this one's -> his/her)
                if string.match(afterMatch, "^'s") or string.match(afterMatch, "^'") then
                    local genderedPossessive = self:GetGenderedPronoun("possessive", false)
                    return genderedPossessive
                end

                -- Check for object context (common patterns)
                local isObject = string.match(beforeMatch, "tell $") or
                    string.match(beforeMatch, "help $") or
                    string.match(beforeMatch, "show $") or
                    string.match(beforeMatch, "give $") or
                    string.match(beforeMatch, "bring $") or
                    string.match(beforeMatch, "send $") or
                    string.match(beforeMatch, "for $") or
                    string.match(beforeMatch, "to $") or
                    string.match(beforeMatch, "want $") or
                    string.match(beforeMatch, "need $")


                if isObject then
                    local genderedObject = self:GetGenderedPronoun("object", false)
                    -- Preserve capitalization
                    if string.match(match, "^T") then
                        return string.upper(genderedObject:sub(1, 1)) .. genderedObject:sub(2)
                    else
                        return genderedObject
                    end
                end

                -- Default to subject context (this one -> he/she)
                local genderedSubject = self:GetGenderedPronoun("subject", true)
                -- Preserve capitalization
                if string.match(match, "^T") then
                    return string.upper(genderedSubject:sub(1, 1)) .. genderedSubject:sub(2)
                else
                    return genderedSubject
                end
            else
                return match -- Keep other occurrences unchanged
            end
        end)

        -- Also handle any remaining possessive patterns that might have been missed
        -- Look for patterns like "his's" and fix them to just "his"
        result = string.gsub(result, "([Hh]is)'s", "%1")
        result = string.gsub(result, "([Hh]er)'s", "%1")
    end

    return result
end

-- Replaces WELL
function KhajiitVoice:ReplaceObjectPronouns(text, selfRef)
    local result = text
    local objectForm = (selfRef == "this one") and "this one" or selfRef

    -- Handle specific common phrases first  (these are more specific)
    result = string.gsub(result, "tell me", "tell " .. objectForm)
    result = string.gsub(result, "help me", "help " .. objectForm)
    result = string.gsub(result, "Tell me", "Tell " .. objectForm)
    result = string.gsub(result, "show me", "show " .. objectForm)
    result = string.gsub(result, "for me", "for " .. objectForm)
    result = string.gsub(result, "to me([^%w])", "to " .. objectForm .. "%1")
    result = string.gsub(result, " me%.", " " .. objectForm .. ".")

    result = string.gsub(result, "do I([^%w])", " does " .. objectForm .. "%1")
    result = string.gsub(result, "I don't", objectForm .. " does not ")
    result = string.gsub(result, "do I$", " does " .. objectForm)
    result = string.gsub(result, "to me$", "to " .. objectForm)
    result = string.gsub(result, "with me", "with " .. objectForm)
    result = string.gsub(result, "give me", "give " .. objectForm)
    result = string.gsub(result, "bring me", "bring " .. objectForm)
    result = string.gsub(result, "send me", "send " .. objectForm)
    result = string.gsub(result, "sent me%.", "sent " .. objectForm .. ".")
    result = string.gsub(result, "I understand.", objectForm .. " understands.")
    result = string.gsub(result, "I know", objectForm .. " knows")
    result = string.gsub(result, "I have", objectForm .. " has")
    result = string.gsub(result, "this one have", "this one has")

    -- Handle general "me" and "myself" with explicit word boundary checks
    -- This will match "me" only when it's a complete word
    result = string.gsub(result, "([^%w])me([^%w])", "%1" .. objectForm .. "%2")
    result = string.gsub(result, "^me([^%w])", objectForm .. "%1")
    result = string.gsub(result, "([^%w])me$", "%1" .. objectForm)
    result = string.gsub(result, "^me$", objectForm)

    result = string.gsub(result, "([^%w])myself([^%w])", "%1" .. objectForm .. "%2")
    result = string.gsub(result, "^myself([^%w])", objectForm .. "%1")
    result = string.gsub(result, "([^%w])myself$", "%1" .. objectForm)
    result = string.gsub(result, "^myself$", objectForm)

    return result
end

-- Replace possessive pronouns
function KhajiitVoice:ReplacePossessivePronouns(text, selfRef)
    local result = text
    local possessiveForm

    if selfRef == "this one" then
        possessiveForm = self:GetGenderedPronoun("possessive", false)
    elseif selfRef == "Khajiit" then
        possessiveForm = "Khajiit's"
    else
        possessiveForm = selfRef .. "'s"
    end

    result = string.gsub(result, " my ", " " .. possessiveForm .. " ")
    result = string.gsub(result, "^[Mm]y ", possessiveForm .. " ")
    result = string.gsub(result, " mine([%s%p])", " " .. possessiveForm .. "%1")
    result = string.gsub(result, "^[Mm]ine ", possessiveForm .. " ")

    return result
end

---=============================================================================
-- PERSONALITY
--=============================================================================
function KhajiitVoice:ApplyPersonalityTraits(text, originalText)
    local traits = KhajiitVoice.savedVars.personalityTraits
    local result = text

    if traits.kindSoulTone > 30 then
        result = self:ApplyKindSoulTone(result, originalText, traits.kindSoulTone)
    end
    if traits.scholarlyTone > 30 then
        result = self:ApplyScholarlyTone(result, originalText, traits.scholarlyTone)

        if traits.replaceGoodbyes then
            result = self:ReplaceFarewells(result, originalText)
        end
        result = self:ReplaceGreetings(result, originalText)
    end



    return result
end

function KhajiitVoice:ApplyKindSoulTone(text, originalText, intensity)
    local result = text
    local kindExpressions = patterns.khajiitExpressions.kindSoulExpressions
    local traits = KhajiitVoice.savedVars.personalityTraits
    -- Replace greetings with kind versions
    local isGreeting = string.find(originalText:lower(), "hello") or
        string.find(originalText:lower(), "hi") or
        string.find(originalText:lower(), "hey") or
        string.find(originalText:lower(), "greetings") or
        string.find(originalText:lower(), "good day")

    if isGreeting and getStableRandom(originalText, 1, 100, "kindgreet") <= intensity then
        local index = getStableRandom(originalText, 1, #kindExpressions.greetings, "kindgreetindex")
        local kindGreeting = kindExpressions.greetings[index]
        result = string.gsub(result, "^Hello%.?%s*", kindGreeting .. " ")
        result = string.gsub(result, "^Hi%.?%s*", kindGreeting .. " ")
        result = string.gsub(result, "^Hey%.?%s*", kindGreeting .. " ")
        result = string.gsub(result, "^Greetings%.?%s*", kindGreeting .. " ")
        result = string.gsub(result, "^Good day%.?%s*", kindGreeting .. " ")
    end

    -- Replace farewells with kind versions
    local isFarewell = string.find(originalText:lower(), "goodbye") or
        string.find(originalText:lower(), "farewell") or
        string.find(originalText:lower(), "see you") or
        string.find(originalText:lower(), "take care") or
        string.find(originalText:lower(), "bye")

    if traits.replaceGoodbyes then
        if isFarewell and math.random(1, 100) <= intensity then
            local index = math.random(1, #kindExpressions.farewells)
            local kindFarewell = kindExpressions.farewells[index]

            result = string.gsub(result, "^Farewell%.?%s*", kindFarewell .. " ")
            result = string.gsub(result, "^Goodbye%.?%s*", kindFarewell .. "")
            result = string.gsub(result, "^See you%.?%s*", kindFarewell .. " ")
            result = string.gsub(result, "^Take care%.?%s*", kindFarewell .. " ")
            result = string.gsub(result, "^Bye%.?%s*", kindFarewell .. " ")
        end
    end
    -- Apply flowery word replacements
    for pattern, replacement in pairs(kindExpressions.replacements) do
        if getStableRandom(originalText, 1, 100, "kind" .. pattern) <= (intensity / 2) then
            result = string.gsub(result, pattern, replacement)
        end
    end

    -- Apply flowery intensifiers
    for pattern, replacement in pairs(kindExpressions.flowerySpeech.intensifiers) do
        if getStableRandom(originalText, 1, 100, "kindintense" .. pattern) <= (intensity / 3) then
            result = string.gsub(result, "%f[%w]" .. pattern .. "%f[%W]", replacement)
        end
    end

    -- Add endearments to sentences (occasionally)
    if getStableRandom(originalText, 1, 100, "kindendear") <= (intensity / 4) then
        -- Skip endearments for store/vendor interactions
        if not string.find(result, "Store (", 1, true) then -- true = plain text search, case sensitive
            -- Check if endearments already exist
            local hasEndearment = false
            local endearments = kindExpressions.endearments

            for _, endearment in ipairs(endearments) do
                if string.find(result, endearment, 1, true) then
                    hasEndearment = true
                    break
                end
            end

            -- Only add if no endearment already exists
            if not hasEndearment then
                local npcName = GetUnitName("interact") or ""
                local index = getStableRandom(originalText .. npcName, 1, #endearments)

                local endearment = endearments[index]

                -- Add endearment before punctuation or at end
                if string.find(result, "[%.%!%?]$") then
                    result = string.gsub(result, "([%.%!%?])$", endearment .. "%1")
                else
                    result = result .. endearment
                end
            end
        end
    end
    return result
end

-- Apply scholarly tone
function KhajiitVoice:ApplyScholarlyTone(text, originalText, intensity)
    local result = text
    local scholarlyExpressions = patterns.khajiitExpressions.scholarlyExpressions
    local traits = KhajiitVoice.savedVars.personalityTraits

    -- Replace greetings with scholarly versions
    local isGreeting = string.find(originalText:lower(), "hello") or
        string.find(originalText:lower(), "hi") or
        string.find(originalText:lower(), "hey") or
        string.find(originalText:lower(), "greetings") or
        string.find(originalText:lower(), "good day")

    if isGreeting and getStableRandom(originalText, 1, 100, "scholarlygreet") <= intensity then
        local index = getStableRandom(originalText, 1, #scholarlyExpressions.greetings, "scholarlygreetindex")
        local scholarlyGreeting = scholarlyExpressions.greetings[index]
        result = string.gsub(result, "^Hello%.?%s*", scholarlyGreeting .. " ")
        result = string.gsub(result, "^Hi%.?%s*", scholarlyGreeting .. " ")
        result = string.gsub(result, "^Hey%.?%s*", scholarlyGreeting .. " ")
        result = string.gsub(result, "^Greetings%.?%s*", scholarlyGreeting .. " ")
        result = string.gsub(result, "^Good day%.?%s*", scholarlyGreeting .. " ")
    end

    -- NEW: Handle questions with scholarly starters (intensity-based complexity)
    local isQuestion = string.find(result, "%?%s*$")
    if isQuestion and getStableRandom(originalText, 1, 100, "scholarlyquestion") <= (intensity / 2) then
        -- Check if it already has a scholarly start
        local hasScholarlyStart = string.find(result:lower(), "^this one wonders") or
            string.find(result:lower(), "^the ancient texts") or
            string.find(result:lower(), "^scholarly contemplation") or
            string.find(result:lower(), "^the wisdom of ages") or
            string.find(result:lower(), "^as the philosophers") or
            string.find(result:lower(), "^this one is curious") or
            string.find(result:lower(), "^tell this one")

        if not hasScholarlyStart then
            local questionStarters

            -- Choose simple or verbose starters based on intensity
            if intensity <= 100 then
                questionStarters = scholarlyExpressions.questionStarters.simple
            else
                questionStarters = scholarlyExpressions.questionStarters.verbose
            end

            local index = getStableRandom(originalText, 1, #questionStarters, "scholarlyqstarter")
            local questionStarter = questionStarters[index]

            -- Convert first letter to lowercase and prepend starter
            result = questionStarter .. string.lower(result:sub(1, 1)) .. result:sub(2)
        end
    end

    -- Replace farewells with scholarly versions
    if traits.replaceGoodbyes then
        local isFarewell = string.find(originalText:lower(), "goodbye") or
            string.find(originalText:lower(), "farewell") or
            string.find(originalText:lower(), "see you") or
            string.find(originalText:lower(), "take care") or
            string.find(originalText:lower(), "bye")

        if isFarewell and math.random(1, 100) <= intensity then
            local index = math.random(1, #scholarlyExpressions.farewells)
            local scholarlyFarewell = scholarlyExpressions.farewells[index]
            result = string.gsub(result, "^Farewell%.?%s*", scholarlyFarewell .. " ")
            result = string.gsub(result, "^Goodbye%.?%s*", scholarlyFarewell .. "")
            result = string.gsub(result, "^See you%.?%s*", scholarlyFarewell .. " ")
            result = string.gsub(result, "^Take care%.?%s*", scholarlyFarewell .. " ")
            result = string.gsub(result, "^Bye%.?%s*", scholarlyFarewell .. " ")
        end
    end

    -- Apply scholarly word replacements
    for pattern, replacement in pairs(scholarlyExpressions.replacements) do
        if getStableRandom(originalText, 1, 100, "scholarlywrd" .. pattern) <= (intensity / 0.2) then
            result = string.gsub(result, pattern, replacement)
        end
    end

    return result
end

function KhajiitVoice:GetFarewellIndex()
    local farewells = patterns.khajiitExpressions.farewell
    -- Use true randomness for farewells to get variety
    return math.random(1, #farewells)
end

-- Stable randomization for self reference
function KhajiitVoice:GetSelfReference(originalText)
    -- If the original text already contains the player name, always use "this one"
    if self:ContainsPlayerName(originalText) then
        return "this one"
    end

    -- Otherwise use your normal weighted selection
    local weights = KhajiitVoice.savedVars.pronounWeights
    local total = weights.thisOne + weights.charName + weights.khajiit
    local roll = getStableRandom(originalText, 1, total, "selfref")

    if roll <= weights.thisOne then
        return "this one"
    elseif roll <= weights.thisOne + weights.charName then
        return GetUnitName("player")
    else
        return "Khajiit"
    end
end

function KhajiitVoice:ReplaceFarewells(text, originalText)
    local result = text

    -- Function to select a random farewell (truly random for variety)
    local function getRandomFarewell()
        local farewells = patterns.khajiitExpressions.farewell
        local index = math.random(#farewells) -- True randomness
        return farewells[index]
    end

    -- Handle "Farewell" patterns
    result = string.gsub(result, "^Farewell%.?%s*", function()
        return getRandomFarewell() .. " "
    end)

    result = string.gsub(result, "^Goodbye%.?%s*", function()
        return getRandomFarewell() .. " "
    end)

    return result
end

-- Stable greeting replacement
function KhajiitVoice:ReplaceGreetings(text, originalText)
    local result = text

    local function getStableGreeting()
        local greetings = patterns.khajiitExpressions.greeting
        local index = getStableRandom(originalText, 1, #greetings, "greeting")
        return greetings[index]
    end

    -- Replace various greeting patterns
    result = string.gsub(result, "^Hello%.?%s*", function()
        return getStableGreeting() .. " "
    end)

    result = string.gsub(result, "^Hi%.?%s*", function()
        return getStableGreeting() .. " "
    end)

    result = string.gsub(result, "^Hey%.?%s*", function()
        return getStableGreeting() .. " "
    end)

    result = string.gsub(result, "^Greetings%.?%s*", function()
        return getStableGreeting() .. " "
    end)

    result = string.gsub(result, "^Good day%.?%s*", function()
        return getStableGreeting() .. " "
    end)

    return result
end

function KhajiitVoice:HookDialogueSystem()
    -- Register for interaction events
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_BEGIN, function()
        KhajiitVoice:StartDialogueSession()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_END, function()
        KhajiitVoice:OnDialogueEnd()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GAME_CAMERA_DEACTIVATED, function()
        local interactionType = GetInteractionType()
        if interactionType == INTERACTION_CONVERSATION or interactionType == INTERACTION_QUEST then
            KhajiitVoice:StartDialogueSession()
        end
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INTERACTION_WINDOW_SHOWN, function()
        KhajiitVoice:StartDialogueSession()
    end)
end

function KhajiitVoice:StartDialogueSession()
    -- Clear previous dialogue replacements to start fresh
    self.currentDialogueReplacements = {}
    self.firstAppearanceCache = {}

    -- Reset session flags

    self.dialogueSessionStarted = true

    -- Hook SetText methods for interception
    self:HookSetTextMethods()
end

---=============================================================================
-- PROCESS DIALOGUE
--=============================================================================
-- Pass originalText to GetSelfReference
function KhajiitVoice:ProcessDialogue(originalText)
    if not KhajiitVoice.savedVars.enabled then
        return originalText
    end

    -- Check if we already have a complete replacement for this exact text
    if self.currentDialogueReplacements[originalText] then
        return self.currentDialogueReplacements[originalText]
    end

    -- Check if we should use Cyrodiilic tone (Imperial speech) instead of Khajiit speech
    local cyrodiilicTone = KhajiitVoice.savedVars.personalityTraits.cyrodiilicTone or 0

    -- Random chance to skip Khajiit speech processing based on Cyrodiilic tone
    if cyrodiilicTone > 0 and getStableRandom(originalText, 1, 100, "cyrodiilic") <= cyrodiilicTone then
        -- Store the original text as "processed" to prevent re-processing
        self.currentDialogueReplacements[originalText] = originalText
        return originalText
    end

    local processedText = originalText

    -- STEP 1: Handle player name cases first, before any other processing
    processedText = self:HandlePlayerNameCases(processedText)

    -- STEP 2: Get self-reference (this will force "this one" if name detected)
    local selfRef = self:GetSelfReference(originalText) -- Remove the duplicate line

    -- STEP 3: Replace pronouns
    processedText = self:ReplaceObjectPronouns(processedText, selfRef)
    processedText = self:ReplaceSubjectPronouns(processedText, selfRef)

    processedText = self:ReplacePossessivePronouns(processedText, selfRef)

    -- STEP 4: Conjugate verbs AFTER pronoun replacement
    processedText = self:ConjugateVerbs(processedText, selfRef)

    -- STEP 5: Handle questions
    processedText = self:HandleQuestions(processedText, originalText)

    -- STEP 6: Apply personality traits
    processedText = self:ApplyPersonalityTraits(processedText, originalText)
    processedText = self:EnsurePunctuation(processedText)
    processedText = self:ConvertSecondPronounToGenderedSimple(processedText)
    processedText = self:FixEdgeCases(processedText, selfRef)
    -- Store the complete transformation for this dialogue session
    self.currentDialogueReplacements[originalText] = processedText

    return processedText
end

-- Stable question handling
function KhajiitVoice:HandleQuestions(text, originalText)
    local result = text
    -- Split text into sentences for better handling
    local sentences = {}
    local currentSentence = ""

    -- Simple sentence splitting - fixed the pattern matching
    for word in string.gmatch(result, "[^%.%!%?]*[%.%!%?]?") do
        if word and word ~= "" then
            currentSentence = currentSentence .. word
            if string.match(word, "[%.%!%?]$") then
                local cleanSentence = string.gsub(currentSentence, "^%s<(.-)%s>$", "%1")
                if cleanSentence ~= "" then
                    table.insert(sentences, cleanSentence)
                end
                currentSentence = ""
            end
        end
    end
    -- Don't forget the last sentence if it doesn't end with punctuation
    if currentSentence ~= "" then
        local cleanSentence = string.gsub(currentSentence, "^%s<(.-)%s>$", "%1")
        if cleanSentence ~= "" then
            table.insert(sentences, cleanSentence)
        end
    end
    -- Process each sentence individually
    local processedSentences = {}
    for i, sentence in ipairs(sentences) do
        local processedSentence = sentence
        -- Only process questions (sentences ending with ?)
        if string.find(processedSentence, "%?%s*$") then
            -- Count how many "this one" references are already in the sentence
            local thisOneCount = 0
            for match in string.gmatch(processedSentence:lower(), "this one") do
                thisOneCount = thisOneCount + 1
            end
            -- Check if sentence already has Khajiit speech patterns
            local hasKhajiitStart = string.find(processedSentence:lower(), "^this one") or
                string.find(processedSentence:lower(), "^khajiit") or
                string.find(processedSentence:lower(), "^tell this one") or
                string.find(processedSentence:lower(), "^does this one") or
                string.find(processedSentence:lower(), "^can this one") or
                string.find(processedSentence:lower(), "^will this one") or
                string.find(processedSentence:lower(), "^should this one")
            -- Only add question starter if conditions met
            if not hasKhajiitStart and thisOneCount > 1 and getStableRandom(originalText, 1, 100, "question") <= 60 then
                local questionStarters = {
                    "This one wonders - ",
                    "This one must ask - ",
                    "Tell this one - ",
                    "This one is curious - ",
                    "", -- Sometimes use no starter
                    "", -- Increased chance of no starter
                    ""
                }
                local starterIndex = getStableRandom(originalText, 1, #questionStarters, "questionstarter")
                local starter = questionStarters[starterIndex]
                if starter ~= "" then
                    processedSentence = starter .. string.lower(processedSentence:sub(1, 1)) .. processedSentence:sub(2)
                    -- If we added a starter, reduce some "this one" repetitions in the embedded question
                    processedSentence = self:ReduceRepetition(processedSentence, originalText)
                end
            end
        end

        -- Process statements for ", yes?" confirmation phrases
        if string.find(processedSentence, "%.%s*$") or string.find(processedSentence, "%?%s*$") then
            local shouldAddYes = false

            -- Check for specific starting phrases
            if string.find(processedSentence:lower(), "^stay safe") then
                shouldAddYes = true
            elseif string.find(processedSentence, "You") and not string.find(processedSentence, "Your") then
                shouldAddYes = true
            elseif string.find(processedSentence:lower(), "^take care") then
                shouldAddYes = true
            end

            if shouldAddYes and getStableRandom(originalText, 1, 100, "yesconfirm") <= 60 then
                -- Replace the period with ", yes?"
                processedSentence = string.gsub(processedSentence, "[%.%?]%s*$", ", yes?")
            end
        end

        table.insert(processedSentences, processedSentence)
    end
    -- Rejoin sentences with proper spacing
    result = table.concat(processedSentences, " ")
    return result
end

-- Pre-hook SetText to intercept text before it's displayed
local originalSetText = {}

function KhajiitVoice:HookSetTextMethods()
    -- Store references to text elements we want to monitor
    self.hookedElements = self.hookedElements or {}

    -- Hook the SetText method for dialogue elements
    self:HookDialogueElements()
end

function KhajiitVoice:HookDialogueElements()
    -- Hook gamepad dialogue elements when they're created
    local function hookElement(element)
        if not element or not element.SetText then
            return
        end

        local elementId = tostring(element)
        if self.hookedElements[elementId] then
            return -- Already hooked
        end

        -- Store original SetText method
        originalSetText[elementId] = element.SetText

        -- Replace with our interceptor
        element.SetText = function(self, text)
            -- Process the text before it gets displayed
            local processedText = KhajiitVoice:InterceptAndProcessText(text, element)
            -- Call original SetText with processed text
            return originalSetText[elementId](self, processedText)
        end

        self.hookedElements[elementId] = true
    end

    -- Hook existing elements
    self:HookExistingDialogueElements(hookElement)

    -- Monitor for new elements (much less frequent than text monitoring)
    self:StartElementMonitoring(hookElement)
end

function KhajiitVoice:HookExistingDialogueElements(hookFunction)
    -- Hook gamepad scroll container elements
    local gamepadScrollContainer = ZO_InteractWindow_GamepadContainerInteractListScroll
    if gamepadScrollContainer then
        local numChildren = gamepadScrollContainer:GetNumChildren()
        for i = 1, numChildren do
            local option = gamepadScrollContainer:GetChild(i)
            if option then
                local textElement = self:FindTextElement(option)
                if textElement then
                    hookFunction(textElement)
                end
            end
        end
    end

    -- Hook named dialogue options
    for i = 1, 10 do
        local longOptionName = "ZO_InteractWindow_GamepadContainerInteractListScrollZO_ChatterOption_Gamepad" .. i
        local option = _G[longOptionName]
        if option then
            local textElement = self:FindTextElement(option)
            if textElement then
                hookFunction(textElement)
            end
        end

        local shortOptionName = "ZO_ChatterOption_Gamepad" .. i
        local option2 = _G[shortOptionName]
        if option2 then
            local textElement = self:FindTextElement(option2)
            if textElement then
                hookFunction(textElement)
            end
        end
    end
end

function KhajiitVoice:StartElementMonitoring(hookFunction)
    self.elementMonitoringActive = true

    local function monitorElements()
        if not self.elementMonitoringActive then
            return
        end

        -- Check for new elements to hook (much less frequent)
        self:HookExistingDialogueElements(hookFunction)

        -- Check again in 1 second (very infrequent)
        zo_callLater(monitorElements, 1000)
    end

    monitorElements()
end

function KhajiitVoice:StopElementMonitoring()
    self.elementMonitoringActive = false
end

function KhajiitVoice:InterceptAndProcessText(text, element)
    if not text or text == "" then
        return text
    end

    if not KhajiitVoice.savedVars or not KhajiitVoice.savedVars.enabled then
        return text
    end

    -- Check cache first for instant results
    if self.currentDialogueReplacements[text] then
        return self.currentDialogueReplacements[text]
    end

    -- Process the text
    local processedText = self:ProcessDialogue(text)

    -- Cache the result
    self.currentDialogueReplacements[text] = processedText

    return processedText
end

-- Restore original SetText methods when dialogue ends
function KhajiitVoice:UnhookSetTextMethods()
    if not self.hookedElements then
        return
    end

    for elementId, _ in pairs(self.hookedElements) do
        -- Find the element by scanning for matching IDs
        -- This is a bit hacky but necessary since we only have the string ID
        local found = false

        -- Check gamepad elements
        local gamepadScrollContainer = ZO_InteractWindow_GamepadContainerInteractListScroll
        if gamepadScrollContainer and not found then
            local numChildren = gamepadScrollContainer:GetNumChildren()
            for i = 1, numChildren do
                local option = gamepadScrollContainer:GetChild(i)
                if option then
                    local textElement = self:FindTextElement(option)
                    if textElement and tostring(textElement) == elementId then
                        if originalSetText[elementId] then
                            textElement.SetText = originalSetText[elementId]
                            originalSetText[elementId] = nil
                        end
                        found = true
                        break
                    end
                end
            end
        end

        -- Check named dialogue options if not found
        if not found then
            for i = 1, 10 do
                local longOptionName = "ZO_InteractWindow_GamepadContainerInteractListScrollZO_ChatterOption_Gamepad" ..
                    i
                local option = _G[longOptionName]
                if option then
                    local textElement = self:FindTextElement(option)
                    if textElement and tostring(textElement) == elementId then
                        if originalSetText[elementId] then
                            textElement.SetText = originalSetText[elementId]
                            originalSetText[elementId] = nil
                        end
                        found = true
                        break
                    end
                end

                local shortOptionName = "ZO_ChatterOption_Gamepad" .. i
                local option2 = _G[shortOptionName]
                if option2 then
                    local textElement = self:FindTextElement(option2)
                    if textElement and tostring(textElement) == elementId then
                        if originalSetText[elementId] then
                            textElement.SetText = originalSetText[elementId]
                            originalSetText[elementId] = nil
                        end
                        found = true
                        break
                    end
                end
            end
        end
    end

    self.hookedElements = {}
end

-- Called when dialogue ends to clean up
function KhajiitVoice:OnDialogueEnd()
    -- Stop element monitoring
    self:StopElementMonitoring()

    -- Unhook SetText methods
    self:UnhookSetTextMethods()

    -- Reset session flags

    self.dialogueSessionStarted = false

    -- Clear caches
    self.currentDialogueReplacements = {}
    self.firstAppearanceCache = {}
end

-- Function to restore original dialogue hooks (useful for cleanup)
function KhajiitVoice:RestoreDialogueHooks()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_CHATTER_BEGIN)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_CHATTER_END)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_GAME_CAMERA_DEACTIVATED)
end

-- Addon initialization
local function Initialize()
    -- Load saved variables using the same pattern as your working addon
    KhajiitVoice.savedVars = ZO_SavedVars:NewCharacterIdSettings("KhajiitVoiceSavedVars", 1, nil, defaults)

    zo_callLater(function()
        KhajiitVoice:CreateSettingsMenu()
    end, 100)
    -- Hook into dialogue system
    KhajiitVoice:HookDialogueSystem()
end

-- Cleanup function for proper addon management
local function OnAddOnUnloading()
    KhajiitVoice:RestoreDialogueHooks()
end

-- OnAddOnLoaded event (using the same pattern as your working addon)
local function OnAddOnLoaded(event, addonName)
    if addonName == ADDON_NAME then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

-- Register for addon loaded event
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_UNLOADING, OnAddOnUnloading)

-- ESO Khajiit Dialogue Replacer Addon
-- A contemplative approach to authentic Khajiit speech patterns

local ADDON_NAME = "KhajiitVoice"
local KhajiitVoice = {}
KhajiitVoice.name = ADDON_NAME
KhajiitVoice.version = "1.0.0"

-- Default settings (local table like your working addon)
local defaults = {
    enabled = true,
    selectedClassPreset = "Custom",
    pronounWeights = {
        thisOne = 70,  -- "This one" weight (humble, traditional)
        charName = 20, -- Character name weight (personal, confident)
        khajiit = 10   -- "Khajiit" weight (generic, formal)
    },
    personalityTraits = {
        replaceGoodbyes = true,
        formality = 50,           -- 0-100 scale
        moonSugarInfluence = 0,   -- 0-100 scale
        merchantTendency = 30,    -- 0-100 scale
        cyrodiilicTone = 0,
        physicalExpression = 0,   -- 0-100 scale (roleplay actions)
        intimidatingPresence = 0, -- 0-100 scale (threatening farewells)
        scholarlyTone = 0,
        naiveTone = 0,            -- 0-100 scale (innocent, uncertain)
        melancholyTone = 0,       -- 0-100 scale (sad, wistful)
        daftTone = 0,             -- 0-100 scale (confused, simple)
        lonerTone = 0,            -- 0-100 scale (poetic speech)
        kindSoulTone = 0
    },
}
local patterns = {
    -- Subject pronouns (when player is speaking about themselves)
    subjectPronouns = {
        ["^[Ii] "] = true,
        [" [Ii] "] = true,
        ["^[Ii]'"] = true,
        [" [Ii]'"] = true
    },

    -- Object pronouns
    objectPronouns = {
        [" me"] = true,
        [" myself"] = true,
        ["^[Mm]e "] = true,
        ["^[Mm]yself "] = true
    },

    -- Possessive pronouns
    possessivePronouns = {
        [" my "] = true,
        [" mine"] = true,
        ["^[Mm]y "] = true,
        ["^[Mm]ine"] = true
    },

    -- Khajiit-specific expressions
    khajiitExpressions = {
        farewell = {
            "May your road lead you to warm sands.",
            "Walk on warm sands.",
            "Safe travels, friend.",
            "May Jone and Jode guide your steps.",
            "Until the moons bring us together again.",
            "May your claws stay sharp and your heart warm.",
            "May your path be lit by bright moons.",
            "Go well, walker of many roads.",
        },
        greeting = {
            "Bright moons, walker - ",
            "The moons smile upon this meeting - ",
            "This one's whiskers twitch with joy at seeing you - ",
            "The winds brought whispers of your approach - ",
            "Ah, a familiar scent on the desert wind - ",
            "Hello"
        },
        merchant = {
            "This one has wares if you have coin",
            "Khajiit has many fine things for sale",
            "Perhaps something catches your eye?",
            "Come, see what treasures this one has gathered",
            "Khajiit's caravan brings wonders from distant lands",
            "For the right price, all things are possible",
            "This one's goods are as fine as moon-sugar",
            "Khajiit offers fair prices for quality wares",
            "These items have traveled far to reach your hands",
            "The best deals require the sharpest claws",
            "This one's reputation travels faster than caravans",
            "Quality goods deserve quality coin, yes?"
        },

        physicalActions = {
            beginnings = {
                "*This one's ears perk up* ",
                "*flicks tail thoughtfully* ",
                "*adjusts whiskers* ",
                "*stretches lazily* ",
                "*sharpens claws on nearby surface* ",
                "*sniffs the air curiously* ",
                "*sits back on haunches* "
            },
            endings = {
                " *swishes tail*",
                " *tilts head*",
                " *flexes claws*",
                " *twitches whiskers*",
                " *flicks ears*",
                " *yawns showing fangs*",
                " *grooms paw absent-mindedly*"
            },
            replacements = {
                ["I nod"] = "*this one nods, ears swiveling*",
                ["I agree"] = "*this one purrs in agreement*",
                ["I think"] = "*this one's whiskers twitch thoughtfully*",
                ["I'm ready"] = "*this one stretches, claws extending briefly*"
            }
        },

        -- NEW: Intimidating farewells
        intimidatingFarewells = {
            "This one's claws will remember your scent.",
            "May your enemies find you before this one does.",
            "The shadows know your name now.",
            "This one hopes we do not meet again... for your sake.",
            "Walk carefully - these sands hold many secrets.",
            "Khajiit's memory is long, and claws are sharp.",
            "The moons will watch your steps from now on.",
            "This one suggests you choose your next words... wisely.",
            "May fortune favor you more than it has this day."
        },

        -- NEW: Scholarly/poetic expressions
        scholarlyExpressions = {
            greetings = {
                "The twin moons illuminate our fateful meeting",
                "Like ancient scrolls unfurling, our paths converge",
                "The wisdom of ages whispers of your approach",
                "As ink flows upon parchment, so do our destinies intertwine",
                "The celestial dance brings us to this moment"
            },
            farewells = {
                "May the written word guide your journey's end",
                "Like pages turning, so must our time together close",
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
            }
        },
        naiveExpressions = {
            replacements = {
                ["I understand"] = "this one thinks this one understands... maybe?",
                ["I know"] = "this one believes this one knows",
                ["obviously"] = "this one supposes",
                ["of course"] = "naturally... yes?",
                ["certainly"] = "this one is quite sure... probably"
            },
            additions = {
                beginnings = {
                    "This one wonders... ",
                    "Perhaps this one misunderstands, but ",
                    "This one's simple mind thinks ",
                    "If this one may ask... "
                },
                endings = {
                    ""
                }
            }
        },
        melancholyExpressions = {
            farewells = {
                "Another parting... such is the way of things.",
                "Until fate decides our paths cross again.",
                "This one grows weary of goodbyes.",
                "May your journey bring more joy than this one's.",
                "The moons witness another farewell."
            },
            replacements = {
                ["I'm happy"] = "this one finds a moment's peace",
                ["great"] = "adequate, this one supposes",
                ["wonderful"] = "pleasant enough",
                ["excited"] = "mildly hopeful"
            },
            additions = {
                sighs = { " *sighs softly*", " *ears droop slightly*", " *gazes distantly*" }
            }
        },
        daftExpressions = {
            replacements = {
                ["I understand"] = "this one's whiskers tingle with... comprehension?",
                ["complex"] = "very... wordy",
                ["difficult"] = "makes this one's head hurt",
                ["strategy"] = "clever... thing?",
                ["obviously"] = "this one sees... something"
            },
            confusions = {
                "This one's brain feels fuzzy about this.",
                "These words are too big for this one's small head.",
                "This one will nod and hope for the best.",
                "Perhaps the smart people understand this?"
            }
        },
        lonerExpressions = {
            replacements = {
                ["%f[%w]we%f[%W]"] = "you... and this one, separately",
                ["%f[%w]together%f[%W]"] = "in proximity",
                ["%f[%w]friend%f[%W]"] = "...acquaintance",
                ["%f[%w]help%f[%W]"] = "briefly assist"
            },
            farewells = {
                "This one prefers the solitude anyway.",
                "Back to the quiet paths, then.",
                "The silence calls to this one.",
                "This one has... things to do. Alone.",
                "...",
                "..."
            },
            avoidance = {
                beginnings = {
                    "...",
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
                "May gentle winds carry you to happiness",
                "This one's heart keeps a warm place for you always",
                "Until we meet again, sweet friend of the journey",
                "May your path be lined with flowers and friendship",
                "Soft moonlight guide your precious steps, cherished soul",
                "This one sends you forth wrapped in warmest wishes",
                "Go well, beautiful spirit, and know you are treasured"
            },
            replacements = {
                ["I'm sorry"] = "this one's heart aches with regret, dear friend",
                ["thank you"] = "this one's soul overflows with gratitude, sweet one",
                ["please"] = "if it pleases your gentle heart",
                ["I hope"] = "this one's tender heart hopes with all its warmth",
                ["good luck"] = "may fortune smile upon your precious endeavors",
                ["I understand"] = "this one's caring heart comprehends completely",
                ["of course"] = "naturally, dear soul, with the greatest pleasure",
                ["help"] = "lovingly assist",
                ["fight"] = "protect those we hold dear",
                ["kill"] = "send to peaceful rest",
                ["problem"] = "gentle challenge",
                ["difficult"] = "requiring tender patience"
            },
            endearments = {
                ", dear friend",
                ", sweet soul",
                ", precious one",
                ", gentle spirit",
                ", cherished companion",
                ", beloved stranger",
                ", tender heart"
            },
            gentleActions = {
                beginnings = {
                    "*This one's whiskers twitch with gentle joy* ",
                    "*ears flutter with tender concern* ",
                    "*paws clasped with caring* ",
                    "*eyes sparkling with warmth* ",
                    "*tail curled with affection* ",
                    "*head tilted with loving attention* "
                },
                endings = {
                    " *purrs softly with contentment*",
                    " *whiskers trembling with emotion*",
                    " *eyes shining with kindness*",
                    " *tail swaying gently*",
                    " *paws placed over heart*",
                    " *soft sigh of compassion*"
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

local classPresets = {
    ["Dragonknight"] = {
        description = "Fierce warrior, master-at-arms",
        settings = {
            formality = 40,
            moonSugarInfluence = 10,
            merchantTendency = 20,
            cyrodiilicTone = 30,
            physicalExpression = 60,
            intimidatingPresence = 70,
            scholarlyTone = 20
        }
    },
    ["Sorcerer"] = {
        description = "Scholarly magic wielder",
        settings = {
            formality = 80,
            moonSugarInfluence = 20,
            merchantTendency = 40,
            cyrodiilicTone = 10,
            physicalExpression = 20,
            intimidatingPresence = 30,
            scholarlyTone = 85
        }
    },
    ["Nightblade"] = {
        description = "Stealthy and mysterious assassin",
        settings = {
            formality = 60,
            moonSugarInfluence = 40,
            merchantTendency = 70,
            cyrodiilicTone = 20,
            physicalExpression = 80,
            intimidatingPresence = 90,
            scholarlyTone = 30
        }
    },
    ["Templar"] = {
        description = "Holy warrior with noble bearing",
        settings = {
            formality = 90,
            moonSugarInfluence = 5,
            merchantTendency = 15,
            cyrodiilicTone = 40,
            physicalExpression = 30,
            intimidatingPresence = 20,
            scholarlyTone = 70
        }
    },
    ["Warden"] = {
        description = "Nature's' Guardian",
        settings = {
            formality = 30,
            moonSugarInfluence = 60,
            merchantTendency = 20,
            cyrodiilicTone = 10,
            physicalExpression = 90,
            intimidatingPresence = 40,
            scholarlyTone = 50
        }
    },
    ["Necromancer"] = {
        description = "Dark magic practitioner",
        settings = {
            formality = 70,
            moonSugarInfluence = 80,
            merchantTendency = 60,
            cyrodiilicTone = 5,
            physicalExpression = 50,
            intimidatingPresence = 95,
            scholarlyTone = 80
        }
    },
    ["Arcanist"] = {
        description = "Eldritch knowledge seeker",
        settings = {
            formality = 85,
            moonSugarInfluence = 70,
            merchantTendency = 30,
            cyrodiilicTone = 15,
            physicalExpression = 40,
            intimidatingPresence = 60,
            scholarlyTone = 95
        }
    }
}

KhajiitVoice.currentDialogueReplacements = {}
KhajiitVoice.firstAppearanceCache = {}
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

---=============================================================================
-- GENERAL REPLACERS
--=============================================================================
function KhajiitVoice:ReplaceAllPronouns(text, selfRef, isQuestion)
    local result = text
    -- Handle contractions first (they're easier to get right)
    result = string.gsub(result, "(%f[%a])I'm(%f[%A])", selfRef .. " is")
    result = string.gsub(result, "(%f[%a])I'll(%f[%A])", selfRef .. " will")
    result = string.gsub(result, "(%f[%a])I've(%f[%A])", selfRef .. " has")
    result = string.gsub(result, "(%f[%a])I'd(%f[%A])", selfRef .. " would")
    result = string.gsub(result, "(%f[%a])I'm(%f[%A])", selfRef .. " is")

    -- Handle "I am", "I have", etc.
    result = string.gsub(result, "(%f[%a])I am(%f[%A])", selfRef .. " is")
    result = string.gsub(result, "(%f[%a])I have(%f[%A])", selfRef .. " has")
    result = string.gsub(result, "(%f[%a])I will(%f[%A])", selfRef .. " will")
    result = string.gsub(result, "(%f[%a])I can(%f[%A])", selfRef .. " can")
    result = string.gsub(result, "(%f[%a])I should(%f[%A])", selfRef .. " should")
    result = string.gsub(result, "(%f[%a])I would(%f[%A])", selfRef .. " would")
    result = string.gsub(result, "(%f[%a])I could(%f[%A])", selfRef .. " could")

    -- Handle remaining "I" instances
    result = string.gsub(result, "(%f[%a])I(%f[%A])", selfRef)

    -- Handle object and possessive pronouns
    result = self:ReplaceObjectPronouns(result, selfRef)
    result = self:ReplacePossessivePronouns(result, selfRef)

    return result
end

KhajiitVoice.currentDialogueReplacements = {} -- Stores replacements for current dialogue session

---=============================================================================
-- GRAMMAR
--=============================================================================
function KhajiitVoice:EnsurePunctuation(text)
    -- Trim whitespace from the end
    local result = string.gsub(text, "%s+$", "")

    -- Check if it already ends with punctuation
    if not string.find(result, "[%.%!%?]$") then
        result = result .. "."
    end

    return result
end

function KhajiitVoice:ProcessSentenceWithContext(text)
    local result = text
    local selfRef = self:GetSelfReference()

    -- Split into sentences for individual processing
    local sentences = self:SplitIntoSentences(result)
    local processedSentences = {}

    for i, sentence in ipairs(sentences) do
        local processedSentence = sentence
        local isQuestion = string.find(processedSentence, "%?%s*$")

        if isQuestion then
            processedSentence = self:ProcessQuestionSentence(processedSentence, selfRef)
        else
            processedSentence = self:ProcessStatementSentence(processedSentence, selfRef)
        end

        table.insert(processedSentences, processedSentence)
    end
    return table.concat(processedSentences, " ")
end

function KhajiitVoice:SplitIntoSentences(text)
    local sentences = {}
    local currentSentence = ""

    -- Better sentence splitting that handles multiple punctuation
    for part in string.gmatch(text, "[^%.%!%?]*[%.%!%?]*") do
        if part and part ~= "" then
            currentSentence = currentSentence .. part
            -- If this part ends with sentence punctuation
            if string.match(part, "[%.%!%?]$") then
                -- Clean up whitespace and add to sentences
                local cleanSentence = string.gsub(currentSentence, "^%s*(.-)%s*$", "%1")
                if cleanSentence ~= "" then
                    table.insert(sentences, cleanSentence)
                end
                currentSentence = ""
            end
        end
    end

    -- Add remaining text if any
    if currentSentence ~= "" then
        local cleanSentence = string.gsub(currentSentence, "^%s*(.-)%s*$", "%1")
        if cleanSentence ~= "" then
            table.insert(sentences, cleanSentence)
        end
    end

    return sentences
end

function KhajiitVoice:ProcessQuestionSentence(sentence, selfRef)
    local result = sentence

    -- Check if it already starts with a Khajiit phrase
    local hasKhajiitStart = string.find(result:lower(), "^this one") or
        string.find(result:lower(), "^khajiit") or
        string.find(result:lower(), "^tell this one") or
        string.find(result:lower(), "^does this one") or
        string.find(result:lower(), "^can this one") or
        string.find(result:lower(), "^will this one") or
        string.find(result:lower(), "^should this one")

    if not hasKhajiitStart then
        -- Count pronouns to decide approach
        local pronounCount = self:CountFirstPersonPronouns(result)

        if pronounCount > 1 then
            -- Multiple pronouns - use question starter approach
            local questionStarters = {
                "This one wonders - ",
                "This one must ask - ",
                "Tell this one - ",
                "This one is curious - "
            }
            local starter = questionStarters[math.random(1, #questionStarters)]
            result = starter .. string.lower(result:sub(1, 1)) .. result:sub(2)

            -- Only replace the first pronoun in the embedded question
            result = self:ReplaceFirstPronounOnly(result, selfRef)
        else
            -- Single or no pronouns - direct replacement
            result = self:ReplaceAllPronouns(result, selfRef, true) -- true for question context
        end
    else
        -- Already has Khajiit start, just clean up any remaining pronouns
        result = self:ReplaceAllPronouns(result, selfRef, true)
    end

    return result
end

function KhajiitVoice:ProcessStatementSentence(sentence, selfRef)
    local result = sentence

    -- Count pronouns to determine strategy
    local pronounCount = self:CountFirstPersonPronouns(result)

    if pronounCount > 1 then
        -- Multiple pronouns - be more selective
        result = self:ReplaceSelectivePronouns(result, selfRef)
    else
        -- Single pronoun - replace normally
        result = self:ReplaceAllPronouns(result, selfRef, false)
    end
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

    -- Handle "I am", "I have", etc.
    result = string.gsub(result, "^I am ", selfRef .. " is ")
    result = string.gsub(result, " I am ", " " .. selfRef .. " is ")
    result = string.gsub(result, "^I have ", selfRef .. " has ")
    result = string.gsub(result, " I have ", " " .. selfRef .. " has ")
    result = string.gsub(result, "^I will ", selfRef .. " will ")
    result = string.gsub(result, " I will ", " " .. selfRef .. " will ")
    result = string.gsub(result, "^I can ", selfRef .. " can ")
    result = string.gsub(result, " I can ", " " .. selfRef .. " can ")

    -- NEW: Handle "I want", "I need", etc.
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

-- Replace object pronouns
function KhajiitVoice:ReplaceObjectPronouns(text, selfRef)
    local result = text
    local objectForm = (selfRef == "this one") and "this one" or selfRef

    -- Handle specific common phrases first
    result = string.gsub(result, "tell me", "tell " .. objectForm)
    result = string.gsub(result, "help me", "help " .. objectForm)
    result = string.gsub(result, "show me", "show " .. objectForm)

    -- Use word boundaries to avoid partial matches
    result = string.gsub(result, "(%f[%a])me(%f[%A])", objectForm)
    result = string.gsub(result, "(%f[%a])myself(%f[%A])", objectForm)

    return result
end

-- Replace possessive pronouns
function KhajiitVoice:ReplacePossessivePronouns(text, selfRef)
    local result = text
    local possessiveForm

    if selfRef == "this one" then
        possessiveForm = "this one's"
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
-- Racial Relations
function KhajiitVoice:GetNPCRaceRelationship()
    local raceId = GetUnitRaceId("interact")

    if not raceId or raceId == 0 then
        return "unknown", 1.0 -- Default neutral
    end

    local relationships = {
        [RACE_KHAJIIT] = { "khajiit", 1.5 },   -- Strong kinship
        [RACE_ARGONIAN] = { "argonian", 1.3 }, -- Beast race kinship
        [RACE_IMPERIAL] = { "imperial", 0.7 }, -- Historical tension
        [RACE_ALTMER] = { "altmer", 0.8 },     -- Slight wariness
        [RACE_DUNMER] = { "dunmer", 0.6 },     -- Historical slavery issues
        [RACE_NORD] = { "nord", 0.9 },         -- Neutral
        [RACE_REDGUARD] = { "redguard", 0.9 }, -- Neutral
        [RACE_BRETON] = { "breton", 0.9 },     -- Neutral
        [RACE_BOSMER] = { "bosmer", 1.1 },     -- Slight kinship (Elsweyr neighbors)
        [RACE_ORC] = { "orc", 1.0 }            -- Neutral
    }

    local relationship = relationships[raceId]
    if relationship then
        return relationship[1], relationship[2] -- race name, kinship multiplier
    end

    return "unknown", 1.0
end

function KhajiitVoice:ApplyRacialKinship(traits, npcRace, kinshipMultiplier)
    local modifiedTraits = {}

    -- Copy all existing traits
    for trait, value in pairs(traits) do
        modifiedTraits[trait] = value
    end

    -- Apply racial-specific modifications
    if npcRace == "khajiit" then
        -- Talking to another Khajiit - more traditional, formal, familial
        modifiedTraits.formality = math.min(100, modifiedTraits.formality + 20)
        modifiedTraits.physicalExpression = math.min(100, modifiedTraits.physicalExpression + 15)
        modifiedTraits.scholarlyTone = math.min(100, modifiedTraits.scholarlyTone + 10)
        -- Less intimidating to fellow Khajiit
        modifiedTraits.intimidatingPresence = math.max(0, modifiedTraits.intimidatingPresence - 20)
    elseif npcRace == "argonian" then
        -- Beast race kinship - more physical, less formal
        modifiedTraits.physicalExpression = math.min(100, modifiedTraits.physicalExpression + 20)
        modifiedTraits.formality = math.max(0, modifiedTraits.formality - 10)
        modifiedTraits.intimidatingPresence = math.max(0, modifiedTraits.intimidatingPresence - 10)
    elseif npcRace == "dunmer" then
        -- Historical tension - more cautious, less trusting
        modifiedTraits.intimidatingPresence = math.min(100, modifiedTraits.intimidatingPresence + 15)
        modifiedTraits.formality = math.min(100, modifiedTraits.formality + 15)
        modifiedTraits.physicalExpression = math.max(0, modifiedTraits.physicalExpression - 10)
        modifiedTraits.naiveTone = math.max(0, modifiedTraits.naiveTone - 20) -- Less naive around Dunmer
    elseif npcRace == "imperial" then
        -- Cyrodiilic influence - speak more like an Imperial
        modifiedTraits.cyrodiilicTone = math.min(100, modifiedTraits.cyrodiilicTone + 25)
        modifiedTraits.formality = math.min(100, modifiedTraits.formality + 10)
    elseif npcRace == "altmer" then
        -- High Elves - more formal, scholarly
        modifiedTraits.formality = math.min(100, modifiedTraits.formality + 15)
        modifiedTraits.scholarlyTone = math.min(100, modifiedTraits.scholarlyTone + 10)
    elseif npcRace == "bosmer" then
        -- Wood Elves - neighboring kinship, more relaxed
        modifiedTraits.formality = math.max(0, modifiedTraits.formality - 10)
        modifiedTraits.physicalExpression = math.min(100, modifiedTraits.physicalExpression + 10)
    end

    return modifiedTraits
end

local khajiitToKhajiitExpressions = {
    greetings = {
        "Bright moons, sibling of the sands",
        "This one's whiskers twitch with joy at meeting kin",
        "The moons smile upon this meeting of claws",
        "Well met, child of Alkosh",
        "Greetings, walker of the moonpath",
        "By Jone and Jode, another of the pride"
    },
    farewells = {
        "May Alkosh guide your steps, kinsman",
        "Until the moons bring us together again, sibling",
        "Walk well upon the moonpaths",
        "May your claws stay sharp, child of Elsweyr",
        "The pride remembers you, kin",
        "Sweet dreams under Jone and Jode's light"
    }
}

function KhajiitVoice:ApplyPersonalityTraits(text, originalText)
    local traits = KhajiitVoice.savedVars.personalityTraits
    local result = text

    -- Don't apply ANY effects if already processed (prevents stacking)
    if string.find(result:lower(), "prrr") or
        string.find(result:lower(), "hrrm") or
        string.find(result:lower(), "mrow") or
        string.find(result, "%*.*%*") then -- Check for physical expressions too
        return result
    end
    -- Special Khajiit-to-Khajiit expressions
    if npcRace == "khajiit" then
        result = self:ApplyKhajiitToKhajiitExpressions(result, originalText)
    end
    if traits.kindSoulTone > 30 then
        result = self:ApplyKindSoulTone(result, originalText, traits.kindSoulTone)
        -- Kind souls are less likely to be intimidating or melancholy
        traits.intimidatingPresence = math.max(0, traits.intimidatingPresence - 20)
        traits.melancholyTone = math.max(0, traits.melancholyTone - 15)
    end
    -- Apply scholarly tone FIRST (affects farewells and greetings)
    if traits.scholarlyTone > 30 then
        result = self:ApplyScholarlyTone(result, originalText, traits.scholarlyTone)
    else
        if traits.replaceGoodbyes then
            result = self:ReplaceFarewells(result, originalText)
        end
        result = self:ReplaceGreetings(result, originalText)
    end

    -- Apply intimidating presence (overrides normal farewells)
    if traits.intimidatingPresence > 40 then
        result = self:ApplyIntimidatingPresence(result, originalText, traits.intimidatingPresence)
    end

    -- Apply physical expressions
    if traits.physicalExpression > 20 then
        result = self:ApplyPhysicalExpressions(result, traits.physicalExpression, originalText)
    end
    if traits.naiveTone > 30 then
        result = self:ApplyNaiveTone(result, originalText, traits.naiveTone)
    end

    if traits.melancholyTone > 30 then
        result = self:ApplyMelancholyTone(result, originalText, traits.melancholyTone)
    end

    if traits.daftTone > 30 then
        result = self:ApplyDaftTone(result, originalText, traits.daftTone)
    end

    if traits.lonerTone > 30 then
        result = self:ApplyLonerTone(result, originalText, traits.lonerTone)
    end

    -- Existing personality traits with stable randomization
    if traits.formality > 70 then
        result = string.gsub(result, "Yeah", "Certainly")
    elseif traits.formality < 30 then
        result = string.gsub(result, "greetings", "hey there")
    end

    -- Merchant tendency
    if traits.merchantTendency > 60 and getStableRandom(originalText, 1, 100, "merchant") <= 20 then
        if string.find(result:lower(), "goodbye") or string.find(result:lower(), "farewell") then
            result = result .. " May your ventures be profitable!"
        end
    end

    -- Moon sugar influence
    if traits.moonSugarInfluence > 50 then
        local purringChance = getStableRandom(originalText, 1, 100, "purring")
        if purringChance <= 25 then
            local purrSounds = { "Hrrrm ", "Mrow ", "Purrr ", "Purrrr " }
            local index = getStableRandom(originalText, 1, #purrSounds, "purrsound")
            local purr = purrSounds[index]
            result = purr .. result
        elseif purringChance <= 35 then
            local endPurrs = { " ...prrr", " ...hrrm", " ...mrow" }
            local index = getStableRandom(originalText, 1, #endPurrs, "endpurr")
            local endPurr = endPurrs[index]
            result = result .. endPurr
        end

        if getStableRandom(originalText, 1, 100, "moonsugar") <= 15 then
            result = string.gsub(result, "I think", "this one believes")
            result = string.gsub(result, "perhaps", "yes, perhaps... or maybe not")
            result = string.gsub(result, "sure", "this one is... mostly sure")
        end
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
        if isFarewell and getStableRandom(originalText, 1, 100, "kindfare") <= intensity then
            local index = getStableRandom(originalText, 1, #kindExpressions.farewells, "kindfareindex")
            local kindFarewell = kindExpressions.farewells[index]
            result = string.gsub(result, "^Farewell%.?%s*", kindFarewell .. " ")
            result = string.gsub(result, "^Goodbye%.?%s*", kindFarewell .. " ")
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
                local index = getStableRandom(originalText, 1, #endearments, "kindendearindex")
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

function KhajiitVoice:ApplyKhajiitToKhajiitExpressions(text, originalText)
    local result = text
    local traits = KhajiitVoice.savedVars.personalityTraits

    -- Replace greetings with kinship versions
    local isGreeting = string.find(originalText:lower(), "hello") or
        string.find(originalText:lower(), "hi") or
        string.find(originalText:lower(), "hey") or
        string.find(originalText:lower(), "greetings") or
        string.find(originalText:lower(), "good day")

    if isGreeting and getStableRandom(originalText, 1, 100, "khajiitgreet") <= 70 then
        local index = getStableRandom(originalText, 1, #khajiitToKhajiitExpressions.greetings, "khajiitgreetindex")
        local khajiitGreeting = khajiitToKhajiitExpressions.greetings[index]
        result = string.gsub(result, "^Hello%.?%s*", khajiitGreeting .. " ")
        result = string.gsub(result, "^Hi%.?%s*", khajiitGreeting .. " ")
        result = string.gsub(result, "^Hey%.?%s*", khajiitGreeting .. " ")
        result = string.gsub(result, "^Greetings%.?%s*", khajiitGreeting .. " ")
        result = string.gsub(result, "^Good day%.?%s*", khajiitGreeting .. " ")
    end

    -- Replace farewells with kinship versions
    local isFarewell = string.find(originalText:lower(), "goodbye") or
        string.find(originalText:lower(), "farewell") or
        string.find(originalText:lower(), "see you") or
        string.find(originalText:lower(), "take care") or
        string.find(originalText:lower(), "bye")
    if traits.replaceGoodbyes then
        if isFarewell and getStableRandom(originalText, 1, 100, "khajiitfare") <= 70 then
            local index = getStableRandom(originalText, 1, #khajiitToKhajiitExpressions.farewells, "khajiitfareindex")
            local khajiitFarewell = khajiitToKhajiitExpressions.farewells[index]
            result = string.gsub(result, "^Farewell%.?%s*", khajiitFarewell .. "")
            result = string.gsub(result, "^Goodbye%.?%s*", khajiitFarewell)
            result = string.gsub(result, "^See you%.?%s*", khajiitFarewell .. "")
            result = string.gsub(result, "^Take care%.?%s*", khajiitFarewell .. "")
            result = string.gsub(result, "^Bye%.?%s*", khajiitFarewell .. "")
        end
    end
    return result
end

function KhajiitVoice:ApplyNaiveTone(text, originalText, intensity)
    local result = text
    local naiveExpressions = patterns.khajiitExpressions.naiveExpressions

    -- Apply naive word replacements
    for pattern, replacement in pairs(naiveExpressions.replacements) do
        if getStableRandom(originalText, 1, 100, "naive" .. pattern) <= (intensity / 2) then
            result = string.gsub(result, pattern, replacement)
        end
    end

    -- Add uncertain beginnings
    if getStableRandom(originalText, 1, 100, "naivebegin") <= (intensity / 3) then
        local beginnings = naiveExpressions.additions.beginnings
        local index = getStableRandom(originalText, 1, #beginnings, "naivebeginindex")
        local beginning = beginnings[index]
        result = beginning .. result
    end

    -- Add uncertain endings
    if getStableRandom(originalText, 1, 100, "naiveend") <= (intensity / 2) then
        local endings = naiveExpressions.additions.endings
        local index = getStableRandom(originalText, 1, #endings, "naiveendindex")
        local ending = endings[index]
        result = result .. ending
    end

    return result
end

-- NEW: Apply melancholy tone
function KhajiitVoice:ApplyMelancholyTone(text, originalText, intensity)
    local result = text
    local melancholyExpressions = patterns.khajiitExpressions.melancholyExpressions
    local traits = KhajiitVoice.savedVars.personalityTraits
    -- Replace farewells with melancholy versions
    local isFarewell = string.find(originalText:lower(), "goodbye") or
        string.find(originalText:lower(), "farewell") or
        string.find(originalText:lower(), "see you") or
        string.find(originalText:lower(), "take care") or
        string.find(originalText:lower(), "bye")
    if traits.replaceGoodbyes then
        if isFarewell and getStableRandom(originalText, 1, 100, "melancholyfare") <= intensity then
            local index = getStableRandom(originalText, 1, #melancholyExpressions.farewells, "melancholyfareindex")
            local melancholyFarewell = melancholyExpressions.farewells[index]
            result = string.gsub(result, "^Farewell%.?%s*", melancholyFarewell .. " ")
            result = string.gsub(result, "^Goodbye%.?%s*", melancholyFarewell .. " ")
            result = string.gsub(result, "^See you%.?%s*", melancholyFarewell .. " ")
            result = string.gsub(result, "^Take care%.?%s*", melancholyFarewell .. " ")
            result = string.gsub(result, "^Bye%.?%s*", melancholyFarewell .. " ")
        end
    end
    -- Apply melancholy word replacements
    for pattern, replacement in pairs(melancholyExpressions.replacements) do
        if getStableRandom(originalText, 1, 100, "melancholy" .. pattern) <= (intensity / 2) then
            result = string.gsub(result, pattern, replacement)
        end
    end
    return result
end

-- NEW: Apply daft tone
function KhajiitVoice:ApplyDaftTone(text, originalText, intensity)
    local result = text
    local daftExpressions = patterns.khajiitExpressions.daftExpressions

    -- Apply daft word replacements
    for pattern, replacement in pairs(daftExpressions.replacements) do
        if getStableRandom(originalText, 1, 100, "daft" .. pattern) <= (intensity / 2) then
            result = string.gsub(result, pattern, replacement)
        end
    end

    -- Add confusion expressions
    if getStableRandom(originalText, 1, 100, "daftconfusion") <= (intensity / 4) then
        local confusions = daftExpressions.confusions
        local index = getStableRandom(originalText, 1, #confusions, "daftconfusionindex")
        local confusion = confusions[index]
        result = confusion .. " " .. result
    end

    return result
end

-- NEW: Apply loner tone
function KhajiitVoice:ApplyLonerTone(text, originalText, intensity)
    local result = text
    local lonerExpressions = patterns.khajiitExpressions.lonerExpressions
    local traits = KhajiitVoice.savedVars.personalityTraits
    -- Replace farewells with loner versions
    local isFarewell = string.find(originalText:lower(), "goodbye") or
        string.find(originalText:lower(), "farewell") or
        string.find(originalText:lower(), "see you") or
        string.find(originalText:lower(), "take care") or
        string.find(originalText:lower(), "bye")
    if traits.replaceGoodbyes then
        if isFarewell and getStableRandom(originalText, 1, 100, "lonerfare") <= intensity then
            local index = getStableRandom(originalText, 1, #lonerExpressions.farewells, "lonerfareindex")
            local lonerFarewell = lonerExpressions.farewells[index]
            result = string.gsub(result, "^Farewell%.?%s*", lonerFarewell .. " ")
            result = string.gsub(result, "^Goodbye%.?%s*", lonerFarewell .. " ")
            result = string.gsub(result, "^See you%.?%s*", lonerFarewell .. " ")
            result = string.gsub(result, "^Take care%.?%s*", lonerFarewell .. " ")
            result = string.gsub(result, "^Bye%.?%s*", lonerFarewell .. " ")
        end
    end
    -- Apply loner word replacements
    for pattern, replacement in pairs(lonerExpressions.replacements) do
        if getStableRandom(originalText, 1, 100, "loner" .. pattern) <= (intensity / 2) then
            result = string.gsub(result, pattern, replacement)
        end
    end

    -- Add avoidance beginnings
    if getStableRandom(originalText, 1, 100, "loneravoidance") <= (intensity / 3) then
        local beginnings = lonerExpressions.avoidance.beginnings
        local index = getStableRandom(originalText, 1, #beginnings, "loneravoidanceindex")
        local beginning = beginnings[index]
        result = beginning .. result
    end

    return result
end

-- Apply intimidating presence (mainly affects farewells)
function KhajiitVoice:ApplyIntimidatingPresence(text, originalText, intensity)
    local result = text
    local intimidatingFarewells = patterns.khajiitExpressions.intimidatingFarewells
    local traits = KhajiitVoice.savedVars.personalityTraits
    -- Check if this is a farewell and replace with intimidating version
    local isFarewell = string.find(originalText:lower(), "goodbye") or
        string.find(originalText:lower(), "farewell") or
        string.find(originalText:lower(), "see you") or
        string.find(originalText:lower(), "take care") or
        string.find(originalText:lower(), "bye")
    if traits.replaceGoodbyes then
        if isFarewell and getStableRandom(originalText, 1, 100, "intimidating") <= intensity then
            -- Replace with intimidating farewell
            local index = getStableRandom(originalText, 1, #intimidatingFarewells, "intimidatingfarewell")
            local intimidatingFarewell = intimidatingFarewells[index]

            -- Pattern replacements for intimidating farewells
            result = string.gsub(result, "^Farewell%.?%s*", intimidatingFarewell .. " ")
            result = string.gsub(result, "^Goodbye%.?%s*", intimidatingFarewell .. " ")
            result = string.gsub(result, "^See you%.?%s*", intimidatingFarewell .. " ")
            result = string.gsub(result, "^Take care%.?%s*", intimidatingFarewell .. " ")
            result = string.gsub(result, "^Bye%.?%s*", intimidatingFarewell .. " ")
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

    -- Replace farewells with scholarly versions
    if traits.replaceGoodbyes then
        local isFarewell = string.find(originalText:lower(), "goodbye") or
            string.find(originalText:lower(), "farewell") or
            string.find(originalText:lower(), "see you") or
            string.find(originalText:lower(), "take care") or
            string.find(originalText:lower(), "bye")

        if isFarewell and getStableRandom(originalText, 1, 100, "scholarlyfare") <= intensity then
            local index = getStableRandom(originalText, 1, #scholarlyExpressions.farewells, "scholarlyfareindex")
            local scholarlyFarewell = scholarlyExpressions.farewells[index]
            result = string.gsub(result, "^Farewell%.?%s*", scholarlyFarewell .. " ")
            result = string.gsub(result, "^Goodbye%.?%s*", scholarlyFarewell .. " ")
            result = string.gsub(result, "^See you%.?%s*", scholarlyFarewell .. " ")
            result = string.gsub(result, "^Take care%.?%s*", scholarlyFarewell .. " ")
            result = string.gsub(result, "^Bye%.?%s*", scholarlyFarewell .. " ")
        end
    end

    -- Apply scholarly word replacements
    for pattern, replacement in pairs(scholarlyExpressions.replacements) do
        if getStableRandom(originalText, 1, 100, "scholarlywrd" .. pattern) <= (intensity / 2) then
            result = string.gsub(result, pattern, replacement)
        end
    end

    return result
end

function KhajiitVoice:ApplyPhysicalExpressions(text, intensity, originalText)
    local result = text
    local traits = KhajiitVoice.savedVars.personalityTraits

    -- Check if physical expressions already applied (prevent stacking)
    if string.find(result, "%*.*%*") then
        return result
    end

    -- Apply specific word/phrase replacements for physical actions
    local physicalActions = patterns.khajiitExpressions.physicalActions
    for pattern, replacement in pairs(physicalActions.replacements) do
        result = string.gsub(result, pattern, replacement)
    end

    -- Determine which type of physical actions to use based on active personality traits
    local actionPool = {}
    local actionType = "normal"

    -- Build action pool based on active personality traits
    if traits.kindSoulTone > 30 then
        -- Add gentle actions from kind soul
        local gentleActions = patterns.khajiitExpressions.kindSoulExpressions.gentleActions
        for _, action in ipairs(gentleActions.beginnings) do
            table.insert(actionPool, { type = "beginning", action = action })
        end
        for _, action in ipairs(gentleActions.endings) do
            table.insert(actionPool, { type = "ending", action = action })
        end
        actionType = "gentle"
    end

    if traits.melancholyTone > 30 then
        -- Add melancholy sighs and sad actions
        local melancholyActions = patterns.khajiitExpressions.melancholyExpressions.additions.sighs
        for _, action in ipairs(melancholyActions) do
            table.insert(actionPool, { type = "ending", action = action })
        end
        actionType = "melancholy"
    end

    if traits.intimidatingPresence > 50 then
        -- Add intimidating physical actions
        local intimidatingActions = {
            "*narrows eyes menacingly* ",
            "*claws extend slightly* ",
            "*tail lashes with irritation* ",
            "*ears flatten against head* ",
            "*whiskers twitch with annoyance* "
        }
        for _, action in ipairs(intimidatingActions) do
            table.insert(actionPool, { type = "beginning", action = action })
        end

        local intimidatingEndings = {
            " *shows fangs in warning*",
            " *tail bristles*",
            " *claws tap impatiently*"
        }
        for _, action in ipairs(intimidatingEndings) do
            table.insert(actionPool, { type = "ending", action = action })
        end
        actionType = "intimidating"
    end

    -- If no special personality actions, use default physical actions
    if #actionPool == 0 then
        for _, action in ipairs(physicalActions.beginnings) do
            table.insert(actionPool, { type = "beginning", action = action })
        end
        for _, action in ipairs(physicalActions.endings) do
            table.insert(actionPool, { type = "ending", action = action })
        end
    end

    return result
end

-- Add this helper function at the top of your file, after the patterns table
local function getStableRandom(text, min, max, salt)
    -- Create a stable seed based on the text content and optional salt
    local seed = 0
    local inputText = text .. (salt or "")
    for i = 1, #inputText do
        seed = seed + string.byte(inputText, i)
    end

    -- Use the seed to get a deterministic "random" number
    math.randomseed(seed)
    local result = math.random(min, max)

    -- Reset random seed for other uses
    math.randomseed(os.time())
    return result
end

-- Addon initialization
local function Initialize()
    -- Load saved variables using the same pattern as your working addon
    KhajiitVoice.savedVars = ZO_SavedVars:NewCharacterIdSettings("KhajiitVoiceSavedVars", 1, nil, defaults)
    SLASH_COMMANDS["/khajiitdebug"] = function()
        KhajiitVoice:DebugFirstAppearances()
    end
    -- Create settings menu
    KhajiitVoice:CreateSettingsMenu()
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




-- Hook into the dialogue system using events
function KhajiitVoice:HookDialogueSystem()
    -- Register for interaction events to process dialogue
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_BEGIN, function()
        KhajiitVoice:ProcessCurrentDialogue()
        -- Start monitoring for text changes
        KhajiitVoice:StartDialogueMonitoring()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_END, function()
        KhajiitVoice:OnDialogueEnd()
    end)

    -- Hook when camera deactivates (dialogue starts)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GAME_CAMERA_DEACTIVATED, function()
        local interactionType = GetInteractionType()
        if interactionType == INTERACTION_CONVERSATION or interactionType == INTERACTION_QUEST then
            KhajiitVoice:ProcessCurrentDialogue()
            KhajiitVoice:StartDialogueMonitoring()
        end
    end)

    -- Try to catch dialogue updates more aggressively
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_COMPLETE_DIALOG, function()
        KhajiitVoice:ProcessCurrentDialogue()
        KhajiitVoice:StartDialogueMonitoring()
    end)

    -- Hook into when interaction window shows
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INTERACTION_WINDOW_SHOWN, function()
        KhajiitVoice:ProcessCurrentDialogue()
        KhajiitVoice:StartDialogueMonitoring()
    end)
end

---=============================================================================
-- Dialog Monitoring
--=============================================================================
-- Monitoring loop
function KhajiitVoice:MonitorDialogueLoop()
    if not self.isMonitoringDialogue then
        return
    end
    -- Process current dialogue
    self:ProcessCurrentDialogue()
    -- Schedule next check
    zo_callLater(function()
        self:MonitorDialogueLoop()
    end, 1) -- Check every 100ms
end

-- Stop
function KhajiitVoice:StopDialogueMonitoring()
    self.isMonitoringDialogue = false
end

-- Process dialogue options that are currently displayed
function KhajiitVoice:ProcessCurrentDialogue()
    if not KhajiitVoice.savedVars or not KhajiitVoice.savedVars.enabled then
        return
    end

    -- Check if we're in gamepad mode
    local isGamepadMode = IsInGamepadPreferredMode()

    if isGamepadMode then
        -- Process gamepad/console dialogue
        self:ProcessGamepadDialogue()
    else
        -- Process keyboard dialogue
        self:ProcessKeyboardDialogue()
    end
end

-- Process keyboard dialogue
function KhajiitVoice:ProcessKeyboardDialogue()
    local optionsContainer = ZO_InteractWindowPlayerAreaOptions
    if not optionsContainer or optionsContainer:IsHidden() then
        return
    end

    local numChildren = optionsContainer:GetNumChildren()
    if numChildren == 0 then
        return
    end

    -- Process each dialogue option quickly
    for i = 1, numChildren do
        local option = optionsContainer:GetChild(i)
        if option then
            local textElement = self:FindTextElement(option)
            if textElement then
                self:ProcessAndReplaceText(textElement)
            end
        end
    end
end

-- Process gamepad/console dialogue
function KhajiitVoice:ProcessGamepadDialogue()
    -- Target the specific gamepad scroll container first
    local gamepadScrollContainer = ZO_InteractWindow_GamepadContainerInteractListScroll
    if gamepadScrollContainer and not gamepadScrollContainer:IsHidden() then
        local numChildren = gamepadScrollContainer:GetNumChildren()
        for i = 1, numChildren do
            local option = gamepadScrollContainer:GetChild(i)
            if option then
                local textElement = self:FindTextElement(option)
                if textElement then
                    self:ProcessAndReplaceText(textElement)
                end
            end
        end
    end

    for i = 1, 10 do
        local longOptionName = "ZO_InteractWindow_GamepadContainerInteractListScrollZO_ChatterOption_Gamepad" .. i
        local option = _G[longOptionName]
        if option and not option:IsHidden() then
            local textElement = self:FindTextElement(option)
            if textElement then
                self:ProcessAndReplaceText(textElement)
            end
        end
    end

    for i = 1, 10 do
        local shortOptionName = "ZO_ChatterOption_Gamepad" .. i
        local option = _G[shortOptionName]
        if option and not option:IsHidden() then
            local textElement = self:FindTextElement(option)
            if textElement then
                self:ProcessAndReplaceText(textElement)
            end
        end
    end
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

local function getStableRandom(text, min, max, salt)
    -- Create a stable seed based on the text content and optional salt
    local seed = 0
    local inputText = text .. (salt or "")
    for i = 1, #inputText do
        seed = seed + string.byte(inputText, i)
    end

    -- Use the seed to get a deterministic "random" number
    math.randomseed(seed)
    local result = math.random(min, max)

    -- Reset random seed for other uses
    math.randomseed(os.time())
    return result
end

-- Stable randomization for self reference
function KhajiitVoice:GetSelfReference(originalText)
    local weights = KhajiitVoice.savedVars.pronounWeights
    local total = weights.thisOne + weights.charName + weights.khajiit
    local roll = getStableRandom(originalText, 1, total, "selfref")

    if roll <= weights.thisOne then
        return "This one"
    elseif roll <= weights.thisOne + weights.charName then
        return GetUnitName("player")
    else
        return "Khajiit"
    end
end

function KhajiitVoice:ReplaceFarewells(text, originalText)
    local result = text

    -- Function to select a deterministic farewell
    local function getStableFarewell()
        local farewells = patterns.khajiitExpressions.farewell
        local index = getStableRandom(originalText, 1, #farewells, "farewell")
        return farewells[index]
    end

    -- Handle "Farewell" patterns (more formal)
    result = string.gsub(result, "^Farewell%.?%s*", function()
        return getStableFarewell() .. " "
    end)

    result = string.gsub(result, "%s+farewell%.?%s*", function()
        local farewell = getStableFarewell()
        return " " .. string.lower(farewell:sub(1, 1)) .. farewell:sub(2) .. " "
    end)

    -- Handle "See you" patterns (casual farewells)
    result = string.gsub(result, "^See you%.?%s*", function()
        return getStableFarewell() .. " "
    end)

    -- Handle "Take care" patterns
    result = string.gsub(result, "^Take care%.?%s*", function()
        return getStableFarewell() .. " "
    end)

    -- Handle "Bye" patterns (very casual)
    result = string.gsub(result, "^Bye%.?%s*", function()
        return getStableFarewell() .. " "
    end)

    result = string.gsub(result, "%s+bye%.?%s*", function()
        local farewell = getStableFarewell()
        return " " .. string.lower(farewell:sub(1, 1)) .. farewell:sub(2) .. " "
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

-- Pass originalText to GetSelfReference
function KhajiitVoice:ProcessDialogue(originalText)
    if not KhajiitVoice.savedVars.enabled then
        return originalText
    end

    -- Check if we already have a complete replacement for this exact text
    if self.currentDialogueReplacements[originalText] then
        return self.currentDialogueReplacements[originalText]
    end
    -- Get NPC race relationship
    local npcRace, kinshipMultiplier = self:GetNPCRaceRelationship()

    -- Get base traits and apply racial kinship modifiers
    local baseTraits = KhajiitVoice.savedVars.personalityTraits
    local modifiedTraits = self:ApplyRacialKinship(baseTraits, npcRace, kinshipMultiplier)

    -- Check if we should use Cyrodiilic tone (Imperial speech) instead of Khajiit speech
    local cyrodiilicTone = KhajiitVoice.savedVars.personalityTraits.cyrodiilicTone or 0

    -- Random chance to skip Khajiit speech processing based on Cyrodiilic tone
    if cyrodiilicTone > 0 and getStableRandom(originalText, 1, 100, "cyrodiilic") <= cyrodiilicTone then
        -- Store the original text as "processed" to prevent re-processing
        self.currentDialogueReplacements[originalText] = originalText
        return originalText
    end

    local processedText = originalText
    local selfRef = self:GetSelfReference(originalText) -- Pass originalText for stability

    -- Use the original working approach but with better logic
    processedText = self:ReplaceSubjectPronouns(processedText, selfRef)
    processedText = self:ReplaceObjectPronouns(processedText, selfRef)
    processedText = self:ReplacePossessivePronouns(processedText, selfRef)

    -- Handle questions with improved logic
    processedText = self:HandleQuestions(processedText, originalText) -- Pass originalText

    -- Apply personality-based modifications with original text for consistency
    processedText = self:ApplyPersonalityTraits(processedText, originalText)
    processedText = self:EnsurePunctuation(processedText)
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
                local cleanSentence = string.gsub(currentSentence, "^%s*(.-)%s*$", "%1")
                if cleanSentence ~= "" then
                    table.insert(sentences, cleanSentence)
                end
                currentSentence = ""
            end
        end
    end

    -- Don't forget the last sentence if it doesn't end with punctuation
    if currentSentence ~= "" then
        local cleanSentence = string.gsub(currentSentence, "^%s*(.-)%s*$", "%1")
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

        table.insert(processedSentences, processedSentence)
    end

    -- Rejoin sentences with proper spacing
    result = table.concat(processedSentences, " ")

    return result
end

function KhajiitVoice:ProcessAndReplaceText(textElement)
    local originalText = textElement:GetText()

    if originalText and originalText ~= "" then
        if textElement._khajiitAnimating then
            return
        end

        if self.firstAppearanceCache[originalText] then
            local lockedAppearance = self.firstAppearanceCache[originalText]
            local currentText = textElement:GetText()
            textElement:SetText(lockedAppearance)
            return
        end


        local processedText = self:ProcessDialogue(originalText)

        self.firstAppearanceCache[originalText] = processedText
        self.currentDialogueReplacements[originalText] = processedText

        textElement:SetText(processedText)
    end
end

-- Called when dialogue ends to clean up
function KhajiitVoice:OnDialogueEnd()
    -- Stop monitoring when dialogue ends
    self:StopDialogueMonitoring()


    self.currentDialogueReplacements = {}
    self.firstAppearanceCache = {}
end

-- Settings Menu Creation
function KhajiitVoice:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Speak Like Khajiit",
        displayName = "Speak Like Khajiit",
        author = "YFNatey",
        version = KhajiitVoice.version,
        slashCommand = "/khajiitvoice",
        registerForRefresh = true,
    }

    local optionsData = {
        {
            type = "header",
            name = "Basic Settings"
        },
        {
            type = "checkbox",
            name = "Enable Khajiit Dialogue",
            tooltip = "Toggle the entire addon on or off",
            getFunc = function() return KhajiitVoice.savedVars.enabled end,
            setFunc = function(value) KhajiitVoice.savedVars.enabled = value end,
        },
        {
            type = "header",
            name = "Personality Presets"
        },

        {
            type = "submenu",
            name = "Class Presets",
            tooltip = "Apply personality presets based on your character's class",
            controls = {
                {
                    type = "description",
                    text = "Click a class to apply its personality preset:",
                    width = "full"
                },
                {
                    type = "button",
                    name = "Dragonknight",
                    tooltip = "Fierce warrior with draconic pride",
                    func = function()
                        local preset = classPresets["Dragonknight"].settings
                        for trait, val in pairs(preset) do
                            if KhajiitVoice.savedVars.personalityTraits[trait] then
                                KhajiitVoice.savedVars.personalityTraits[trait] = val
                            end
                        end
                        KhajiitVoice.savedVars.selectedClassPreset = "Dragonknight"
                    end,
                    width = "half"
                },
                {
                    type = "button",
                    name = "Sorcerer",
                    tooltip = "Scholarly magic wielder",
                    func = function()
                        local preset = classPresets["Sorcerer"].settings
                        for trait, val in pairs(preset) do
                            if KhajiitVoice.savedVars.personalityTraits[trait] then
                                KhajiitVoice.savedVars.personalityTraits[trait] = val
                            end
                        end
                        KhajiitVoice.savedVars.selectedClassPreset = "Sorcerer"
                    end,
                    width = "half"
                },
                {
                    type = "button",
                    name = "Nightblade",
                    tooltip = "Stealthy and mysterious assassin",
                    func = function()
                        local preset = classPresets["Nightblade"].settings
                        for trait, val in pairs(preset) do
                            if KhajiitVoice.savedVars.personalityTraits[trait] then
                                KhajiitVoice.savedVars.personalityTraits[trait] = val
                            end
                        end
                        KhajiitVoice.savedVars.selectedClassPreset = "Nightblade"
                    end,
                    width = "half"
                },
                {
                    type = "button",
                    name = "Templar",
                    tooltip = "Holy warrior with noble bearing",
                    func = function()
                        local preset = classPresets["Templar"].settings
                        for trait, val in pairs(preset) do
                            if KhajiitVoice.savedVars.personalityTraits[trait] then
                                KhajiitVoice.savedVars.personalityTraits[trait] = val
                            end
                        end
                        KhajiitVoice.savedVars.selectedClassPreset = "Templar"
                    end,
                    width = "half"
                },
                {
                    type = "button",
                    name = "Warden",
                    tooltip = "Nature-connected guardian",
                    func = function()
                        local preset = classPresets["Warden"].settings
                        for trait, val in pairs(preset) do
                            if KhajiitVoice.savedVars.personalityTraits[trait] then
                                KhajiitVoice.savedVars.personalityTraits[trait] = val
                            end
                        end
                        KhajiitVoice.savedVars.selectedClassPreset = "Warden"
                    end,
                    width = "half"
                },
                {
                    type = "button",
                    name = "Necromancer",
                    tooltip = "Dark magic practitioner",
                    func = function()
                        local preset = classPresets["Necromancer"].settings
                        for trait, val in pairs(preset) do
                            if KhajiitVoice.savedVars.personalityTraits[trait] then
                                KhajiitVoice.savedVars.personalityTraits[trait] = val
                            end
                        end
                        KhajiitVoice.savedVars.selectedClassPreset = "Necromancer"
                    end,
                    width = "half"
                },
                {
                    type = "button",
                    name = "Arcanist",
                    tooltip = "Eldritch knowledge seeker",
                    func = function()
                        local preset = classPresets["Arcanist"].settings
                        for trait, val in pairs(preset) do
                            if KhajiitVoice.savedVars.personalityTraits[trait] then
                                KhajiitVoice.savedVars.personalityTraits[trait] = val
                            end
                        end
                        KhajiitVoice.savedVars.selectedClassPreset = "Arcanist"
                    end,
                    width = "half"
                }
            }
        },
        {
            type = "header",
            name = "Self-Reference Tendencies"
        },
        {
            type = "slider",
            name = "\"This one\"",
            tooltip = "How often to use 'this one' (humble, traditional, mysterious)",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.pronounWeights.thisOne end,
            setFunc = function(value) KhajiitVoice.savedVars.pronounWeights.thisOne = value end,
        },
        {
            type = "slider",
            name = "Character Name",
            tooltip = "How often to use your character's name (personal, confident)",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.pronounWeights.charName end,
            setFunc = function(value) KhajiitVoice.savedVars.pronounWeights.charName = value end,
        },
        {
            type = "slider",
            name = "\"Khajiit\"",
            tooltip = "How often to use 'Khajiit' (generic, formal, cautious)",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.pronounWeights.khajiit end,
            setFunc = function(value) KhajiitVoice.savedVars.pronounWeights.khajiit = value end,
        },
        {
            type = "slider",
            name = "Cyrodiilic Tone",
            tooltip =
            "Higher values make your character speak more like a Cyrodiilic Imperial (less Khajiit speech patterns)",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.cyrodiilicTone end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.cyrodiilicTone = value end,
        },

        {
            type = "header",
            name = "Personality Traits"
        },
        {
            type = "checkbox",
            name = "Replace Goodbyes",
            tooltip = "Replace goodbye/farewell text with Khajiit expressions",
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.replaceGoodbyes end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.replaceGoodbyes = value end,
        },
        {
            type = "slider",
            name = "Kind Soul",
            tooltip = "Gentle and caring - adds flowery language, endearments, and compassionate responses",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.kindSoulTone end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.kindSoulTone = value end,
        },
        {
            type = "slider",
            name = "Peddler",
            tooltip = "How often to include merchant-like phrases",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.merchantTendency end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.merchantTendency = value end,
        },
        {
            type = "slider",
            name = "Intimidating",
            tooltip = "How often to use threatening or ominous farewells and responses",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.intimidatingPresence end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.intimidatingPresence = value end,
        },
        {
            type = "slider",
            name = "Scholarly",
            tooltip = "How often to speak poetically and reference ancient wisdom",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.scholarlyTone end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.scholarlyTone = value end,
        },
        {
            type = "slider",
            name = "Naive",
            tooltip = "Innocent and uncertain - adds questioning, second-guessing, and simple-minded responses",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.naiveTone end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.naiveTone = value end,
        },
        {
            type = "slider",
            name = "Daft",
            tooltip = "Confused and simple - struggles with complex words and concepts",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.daftTone end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.daftTone = value end,
        },
        {
            type = "slider",
            name = "Melancholy",
            tooltip = "Sad and wistful - mutes positive emotions and adds sighing, distant expressions",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.melancholyTone end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.melancholyTone = value end,
        },
        {
            type = "slider",
            name = "Distant",
            tooltip = "Antisocial and distant - avoids group references, reluctant in social interactions",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.lonerTone end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.lonerTone = value end,
        },
        {
            type = "divider",
            width = "full"
        },
        {
            type = "slider",
            name = "Moon Sugar Influence",
            tooltip = "Subtle effects on speech patterns (use sparingly)",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.moonSugarInfluence end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.moonSugarInfluence = value end,
        },
        {
            type = "slider",
            name = "Physical",
            tooltip = "How often to include physical roleplay actions (*flicks tail*, *sharpens claws*, etc.)",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.physicalExpression end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.physicalExpression = value end,
        },
        {
            type = "divider",
            width = "full"
        },
        {
            type = "header",
            name = "Support"
        },
        {
            type = "description",
            text = "If you find this addon useful, consider supporting its development!",
            width = "full"
        },
        {
            type = "button",
            name = "Paypal",
            tooltip = "paypal.me/yfnatey",
            func = function() RequestOpenUnsafeURL("https://paypal.me/yfnatey") end,
            width = "half"
        },
        {
            type = "button",
            name = "Ko-fi",
            tooltip = "Ko-fi.me/yfnatey",
            func = function() RequestOpenUnsafeURL("https://Ko-fi.com/yfnatey") end,
            width = "half"
        },
    }

    LAM:RegisterAddonPanel("KhajiitVoicePanel", panelData)
    LAM:RegisterOptionControls("KhajiitVoicePanel", optionsData)
end

-- Start each dialogue with fresh state
function KhajiitVoice:StartDialogueMonitoring()
    -- Stop any existing monitoring
    self:StopDialogueMonitoring()

    -- Clear previous dialogue replacements AND first appearances to start fresh
    self.currentDialogueReplacements = {}
    self.firstAppearanceCache = {} -- NEW: Clear locked appearances

    -- Set monitoring flag
    self.isMonitoringDialogue = true

    -- Start the monitoring loop
    self:MonitorDialogueLoop()
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
    SLASH_COMMANDS["/khajiitdebug"] = function()
        KhajiitVoice:DebugFirstAppearances()
    end
    -- Create settings menu
    KhajiitVoice:CreateSettingsMenu()
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

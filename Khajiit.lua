-- ESO Khajiit Dialogue Replacer Addon
-- A contemplative approach to authentic Khajiit speech patterns

local ADDON_NAME = "KhajiitVoice"
local KhajiitVoice = {}
KhajiitVoice.name = ADDON_NAME
KhajiitVoice.version = "1.0.0"

-- Default settings (local table like your working addon)
local defaults = {
    enabled = true,
    pronounWeights = {
        thisOne = 70,  -- "This one" weight (humble, traditional)
        charName = 20, -- Character name weight (personal, confident)
        khajiit = 10   -- "Khajiit" weight (generic, formal)
    },
    personalityTraits = {
        formality = 50,         -- 0-100 scale
        moonSugarInfluence = 0, -- 0-100 scale
        merchantTendency = 30,  -- 0-100 scale
        clanPride = 40,         -- 0-100 scale
        cyrodiilicTone = 0
    },
    protectImmersion = false -- Allow all names by default
}

KhajiitVoice.currentDialogueReplacements = {}
-- Khajiit linguistic patterns and replacements
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
            "Goodbye."
        },
        greeting = {
            "Bright moons, walker",
            "The moons smile upon this meeting",
            "This one's whiskers twitch with joy at seeing you",
            "Greetings, walker",
            "The winds brought whispers of your approach",
            "Ah, a familiar scent on the desert wind",
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
        }
    }
}

-- Weighted pronoun selection based on personality
function KhajiitVoice:GetSelfReference()
    local weights = KhajiitVoice.savedVars.pronounWeights
    local total = weights.thisOne + weights.charName + weights.khajiit
    local roll = math.random(1, total)

    if roll <= weights.thisOne then
        return "this one"
    elseif roll <= weights.thisOne + weights.charName then
        -- Check immersion protection
        if KhajiitVoice.savedVars.protectImmersion and self:IsMemeNameDetected() then
            return "this one"
        end
        return GetUnitName("player")
    else
        return "Khajiit"
    end
end

-- Optional name filtering (disabled by default to allow creative expression)
function KhajiitVoice:IsMemeNameDetected()
    -- This one believes all names can carry authentic spirit
    -- Players may enable filtering through advanced settings if desired
    return false
end

-- Add this new property to your KhajiitVoice table initialization
-- Place this near the top with your other KhajiitVoice properties
KhajiitVoice.currentDialogueReplacements = {} -- Stores replacements for current dialogue session



function KhajiitVoice:ReplaceFarewells(text, originalText)
    local result = text

    -- Function to select a random farewell from your existing collection
    local function getRandomFarewell()
        local farewells = patterns.khajiitExpressions.farewell
        return farewells[math.random(1, #farewells)]
    end

    -- Store the original for comparison
    local originalResult = result



    -- Handle "Farewell" patterns (more formal)
    result = string.gsub(result, "^Farewell%.?%s*", function()
        return getRandomFarewell() .. " "
    end)

    result = string.gsub(result, "%s+farewell%.?%s*", function()
        local farewell = getRandomFarewell()
        return " " .. string.lower(farewell:sub(1, 1)) .. farewell:sub(2) .. " "
    end)

    -- Handle "See you" patterns (casual farewells)
    result = string.gsub(result, "^See you%.?%s*", function()
        return getRandomFarewell() .. " "
    end)

    -- Handle "Take care" patterns
    result = string.gsub(result, "^Take care%.?%s*", function()
        return getRandomFarewell() .. " "
    end)

    -- Handle "Bye" patterns (very casual)
    result = string.gsub(result, "^Bye%.?%s*", function()
        return getRandomFarewell() .. " "
    end)

    result = string.gsub(result, "%s+bye%.?%s*", function()
        local farewell = getRandomFarewell()
        return " " .. string.lower(farewell:sub(1, 1)) .. farewell:sub(2) .. " "
    end)

    return result
end

function KhajiitVoice:ReplaceGreetings(text, originalText)
    local result = text

    local function getRandomGreeting()
        local greetings = patterns.khajiitExpressions.greeting
        return greetings[math.random(1, #greetings)]
    end

    -- Store the original for comparison
    local originalResult = result

    -- Replace various greeting patterns
    result = string.gsub(result, "^Hello%.?%s*", function()
        return getRandomGreeting() .. " "
    end)

    result = string.gsub(result, "^Hi%.?%s*", function()
        return getRandomGreeting() .. " "
    end)

    result = string.gsub(result, "^Hey%.?%s*", function()
        return getRandomGreeting() .. " "
    end)

    result = string.gsub(result, "^Greetings%.?%s*", function()
        return getRandomGreeting() .. " "
    end)

    result = string.gsub(result, "^Good day%.?%s*", function()
        return getRandomGreeting() .. " "
    end)

    return result
end

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
    if cyrodiilicTone > 0 and math.random(1, 100) <= cyrodiilicTone then
        -- Store the original text as "processed" to prevent re-processing
        self.currentDialogueReplacements[originalText] = originalText
        return originalText
    end

    local processedText = originalText
    local selfRef = self:GetSelfReference()

    processedText = self:ReplaceSubjectPronouns(processedText, selfRef)
    processedText = self:ReplaceObjectPronouns(processedText, selfRef)
    processedText = self:ReplacePossessivePronouns(processedText, selfRef)

    processedText = self:HandleQuestions(processedText)

    -- Apply personality-based modifications with original text for consistency
    processedText = self:ApplyPersonalityTraits(processedText, originalText)

    -- Store the complete transformation for this dialogue session
    self.currentDialogueReplacements[originalText] = processedText

    return processedText
end

-- Replace subject pronouns with proper grammar handling
function KhajiitVoice:ReplaceSubjectPronouns(text, selfRef)
    local result = text

    -- Handle contractions first
    result = string.gsub(result, "^I'm ", selfRef .. " is ")
    result = string.gsub(result, " I'm ", " " .. selfRef .. " is ")
    result = string.gsub(result, "^I'll ", selfRef .. " will ")
    result = string.gsub(result, " I'll ", " " .. selfRef .. " will ")
    result = string.gsub(result, "^I've ", selfRef .. " has ")
    result = string.gsub(result, " I've ", " " .. selfRef .. " has ")
    result = string.gsub(result, "^I'd ", selfRef .. " would ")
    result = string.gsub(result, " I'd ", " " .. selfRef .. " would ")

    -- Handle "I am" -> "This one is" / "Khajiit is"
    result = string.gsub(result, "^I am ", selfRef .. " is ")
    result = string.gsub(result, " I am ", " " .. selfRef .. " is ")

    -- Handle "I have" -> "This one has"
    result = string.gsub(result, "^I have ", selfRef .. " has ")
    result = string.gsub(result, " I have ", " " .. selfRef .. " has ")

    -- Handle "I will" -> "This one will"
    result = string.gsub(result, "^I will ", selfRef .. " will ")
    result = string.gsub(result, " I will ", " " .. selfRef .. " will ")

    -- Handle "I can" -> "This one can"
    result = string.gsub(result, "^I can ", selfRef .. " can ")
    result = string.gsub(result, " I can ", " " .. selfRef .. " can ")

    -- General "I" replacement (with careful grammar consideration)
    result = string.gsub(result, "^I ", selfRef .. " ")
    result = string.gsub(result, " I ", " " .. selfRef .. " ")

    return result
end

-- Replace object pronouns
function KhajiitVoice:ReplaceObjectPronouns(text, selfRef)
    local result = text
    local objectForm = (selfRef == "this one") and "this one" or selfRef

    result = string.gsub(result, " me([%s%p])", " " .. objectForm .. "%1")
    result = string.gsub(result, "^[Mm]e ", objectForm .. " ")
    result = string.gsub(result, " myself([%s%p])", " " .. objectForm .. "%1")

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

    return result
end

function KhajiitVoice:ApplyPersonalityTraits(text, originalText)
    local traits = KhajiitVoice.savedVars.personalityTraits
    local result = text

    -- Don't apply purring if already processed (prevents stacking)
    if string.find(result:lower(), "prrr") or string.find(result:lower(), "hrrm") or string.find(result:lower(), "mrow") then
        return result
    end

    -- Replace farewells and greetings
    result = self:ReplaceFarewells(result, originalText)
    result = self:ReplaceGreetings(result, originalText)

    -- Add formality based on trait level
    if traits.formality > 70 then
        -- Very formal speech patterns
        result = string.gsub(result, "yes", "indeed")
        result = string.gsub(result, "Yeah", "Certainly")
    elseif traits.formality < 30 then
        -- Casual speech patterns
        result = string.gsub(result, "greetings", "hey there")
    end

    -- Merchant tendency - add commercial flair
    if traits.merchantTendency > 60 and math.random(1, 100) <= 20 then
        if string.find(result:lower(), "goodbye") or string.find(result:lower(), "farewell") then
            result = result .. " May your ventures be profitable!"
        end
    end

    -- Moon sugar influence (subtle purring and mannerisms)
    if traits.moonSugarInfluence > 50 then
        local purringChance = math.random(1, 100)
        if purringChance <= 25 then
            -- Add purring sounds at the beginning
            local purrSounds = { "Hrrrm ", "Mrow ", "Purrr ", "Purrrr " }
            local purr = purrSounds[math.random(1, #purrSounds)]
            result = purr .. result
        elseif purringChance <= 35 then
            -- Add purring at the end
            local endPurrs = { " ...prrr", " ...hrrm", " ...mrow" }
            local endPurr = endPurrs[math.random(1, #endPurrs)]
            result = result .. endPurr
        end

        -- Moon sugar affected speech patterns
        if math.random(1, 100) <= 15 then
            result = string.gsub(result, "I think", "this one believes")
            result = string.gsub(result, "perhaps", "yes, perhaps... or maybe not")
            result = string.gsub(result, "sure", "this one is... mostly sure")
        end
    end

    return result
end

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
        zo_callLater(function()
            KhajiitVoice:ProcessCurrentDialogue()
            KhajiitVoice:StartDialogueMonitoring()
        end, 25)
        zo_callLater(function()
            KhajiitVoice:ProcessCurrentDialogue()
        end, 75)
    end)
end

-- Start monitoring dialogue for changes
function KhajiitVoice:StartDialogueMonitoring()
    -- Stop any existing monitoring
    self:StopDialogueMonitoring()

    -- Set monitoring flag
    self.isMonitoringDialogue = true

    -- Start the monitoring loop
    self:MonitorDialogueLoop()
end

-- Monitoring loop using zo_callLater
function KhajiitVoice:MonitorDialogueLoop()
    if not self.isMonitoringDialogue then
        return
    end

    -- Process current dialogue
    self:ProcessCurrentDialogue()

    -- Schedule next check
    zo_callLater(function()
        self:MonitorDialogueLoop()
    end, 100) -- Check every 100ms
end

-- Stop monitoring dialogue
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

-- Process keyboard dialogue (existing code)
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

function KhajiitVoice:HandleQuestions(text)
    local result = text

    -- Split text into sentences (basic sentence splitting)
    local sentences = {}
    local currentSentence = ""

    -- Simple sentence splitting - look for periods, exclamation marks, and question marks followed by space or end
    for word in string.gmatch(result, "[^%.%!%?]*[%.%!%?]?") do
        if word and word ~= "" then
            currentSentence = currentSentence .. word
            -- If this word ends with punctuation, it's the end of a sentence
            if string.match(word, "[%.%!%?]$") then
                table.insert(sentences, currentSentence)
                currentSentence = ""
            end
        end
    end

    -- Don't forget the last sentence if it doesn't end with punctuation
    if currentSentence ~= "" then
        table.insert(sentences, currentSentence)
    end

    -- Process each sentence individually
    local processedSentences = {}
    for i, sentence in ipairs(sentences) do
        local processedSentence = string.gsub(sentence, "^%s*(.-)%s*$", "%1") -- trim whitespace

        -- Only add question starter if this specific sentence ends with ?
        if string.find(processedSentence, "%?%s*$") then
            -- Check if this sentence already has a question starter
            local alreadyHasStarter = string.find(processedSentence:lower(), "^this one wonders") or
                string.find(processedSentence:lower(), "^this one is curious") or
                string.find(processedSentence:lower(), "^khajiit asks") or
                string.find(processedSentence:lower(), "^this one must know") or
                string.find(processedSentence:lower(), "^tell this one") or
                string.find(processedSentence:lower(), "^this one") or
                string.find(processedSentence:lower(), "^khajiit")


            if not alreadyHasStarter then
                local questionStarters = {
                    "This one wonders - ",
                    "This one is curious - ",
                    "This one must know - ",
                    "Tell this one - ",
                    "",
                    "",
                    "",

                }
                local starter = questionStarters[math.random(1, #questionStarters)]
                processedSentence = starter .. string.lower(processedSentence:sub(1, 1)) .. processedSentence:sub(2)
            end
        end

        table.insert(processedSentences, processedSentence)
    end

    -- Rejoin sentences with appropriate spacing
    result = table.concat(processedSentences, " ")

    return result
end

function KhajiitVoice:ProcessAndReplaceText(textElement)
    local originalText = textElement:GetText()

    if originalText and originalText ~= "" then
        -- Don't process if already animating
        if textElement._khajiitAnimating then
            return
        end

        -- Check if we already have a replacement
        if self.currentDialogueReplacements[originalText] then
            local savedReplacement = self.currentDialogueReplacements[originalText]

            if textElement:GetText() ~= savedReplacement then
                -- Set flag to prevent re-animation
                textElement._khajiitAnimating = true

                -- Immediately replace text and fade in
                textElement:SetText(savedReplacement)
                textElement.khajiitProcessed = true
                textElement.khajiitProcessedText = savedReplacement
                textElement._khajiitAnimating = false
            end
            return
        end

        -- Process the text
        local processedText = self:ProcessDialogue(originalText)

        -- If ANY change occurred, immediately replace and fade
        if processedText ~= originalText then
            -- Save the replacement
            self.currentDialogueReplacements[originalText] = processedText

            -- Set flag to prevent re-animation
            textElement._khajiitAnimating = true

            -- Immediately replace text and fade in
            textElement:SetText(processedText)
            textElement.khajiitProcessed = true
            textElement.khajiitProcessedText = processedText
            textElement._khajiitAnimating = false
        else
            -- No change, save it to prevent reprocessing
            self.currentDialogueReplacements[originalText] = originalText
            textElement.khajiitProcessed = true
            textElement.khajiitProcessedText = originalText
        end
    end
end

-- Fade in text element smoothly
function KhajiitVoice:FadeInText(textElement)
    if not textElement then return end

    -- Start completely invisible
    textElement:SetAlpha(0)

    -- Create and start fade animation immediately

    local fadeAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("FadeSceneAnimation")
    zo_callLater(function()
        -- Ensure the element is still valid
        fadeAnimation:GetAnimation(1):SetAnimatedControl(textElement)
        fadeAnimation:GetAnimation(1):SetAlphaValues(0, 1)
        fadeAnimation:GetAnimation(1):SetDuration(900) -- Quick 300ms fade

        -- Clear flag when animation completes
        fadeAnimation:SetHandler("OnStop", function()
            textElement._khajiitAnimating = false
        end)

        -- Start the fade immediately
        fadeAnimation:PlayFromStart()
    end, 100)
end

-- Called when dialogue ends to clean up
function KhajiitVoice:OnDialogueEnd()
    -- Stop monitoring when dialogue ends
    self:StopDialogueMonitoring()

    -- CRITICAL: Clear the saved replacements for the next dialogue interaction
    self.currentDialogueReplacements = {}
end

-- ENHANCED: Start each dialogue with fresh state
function KhajiitVoice:StartDialogueMonitoring()
    -- Stop any existing monitoring
    self:StopDialogueMonitoring()

    -- Clear previous dialogue replacements to start fresh
    self.currentDialogueReplacements = {}

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
        }, {
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
            type = "slider",
            name = "Formality Level",
            tooltip = "How formal your Khajiit's speech should be",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.formality end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.formality = value end,
        },
        {
            type = "slider",
            name = "Merchant Tendency",
            tooltip = "How often to include merchant-like phrases",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return KhajiitVoice.savedVars.personalityTraits.merchantTendency end,
            setFunc = function(value) KhajiitVoice.savedVars.personalityTraits.merchantTendency = value end,
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

-- Addon initialization
local function Initialize()
    -- Load saved variables using the same pattern as your working addon
    KhajiitVoice.savedVars = ZO_SavedVars:NewCharacterIdSettings("KhajiitVoiceSavedVars", 1, nil, defaults)

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

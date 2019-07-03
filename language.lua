-- Table to translate LanguageID to a string
local tbl = {
    "american", "french",
    "german",   "italian",
    "spanish",  "portuguese",
    "polish",   "russian",
    "korean",   "chinese",
    "japanese", "mexican"
}

Citizen.CreateThread(function()
    local file = LoadResourceFile(GetCurrentResourceName(), "locales/" .. tbl[GetCurrentLanguageId()+1] .. ".json")
    Citizen.Trace(tbl[GetCurrentLanguageId()+1] .. ".json")

    local keyTabl = json.decode(file)

    for k,v in pairs(keyTabl) do
        AddTextEntry("serverVote:" .. k, v)
    end

    -- Chat suggestions
    TriggerEvent("chat:addSuggestion", "vote", GetLabelText("serverVote:vote_help"), nil)
    TriggerEvent("chat:addSuggestion", "checkvote", GetLabelText("serverVote:checkvote_help"), nil)
end)

RegisterNetEvent("serverVote:showSubtitle")
AddEventHandler("serverVote:showSubtitle", function(label, args, time)
    Citizen.Trace("Showing subtitle " .. label .. " with a " .. type(args) .. " argument")
    if (type(label) ~= "string") then
        Citizen.Trace("label isn't a string... Cannot show subtitle")
        return
    end
    
    label = "serverVote:" .. label

    BeginTextCommandPrint(label)

    if (args) then
        Citizen.Trace("Args exists")
        processArgs(args)
    end

    EndTextCommandPrint(5000, true)
end)

function processArgs(args)
    Citizen.Trace("Processing args")

    if (type(args) == "string") then
        Citizen.Trace("string: " .. args)
        AddTextComponentSubstringPlayerName(args)
    elseif (type(args) == "number") then
        -- Dirty check
        if (math.floor(math.abs(args)) == args) then -- It should be an int
            Citizen.Trace("int")
            AddTextComponentInteger(args)
        else
            Citizen.Trace("float")
            AddTextComponentFloat(args, 2) -- Force it to 2dp. Because why not
        end
    elseif (type(args) == "table") then
        Citizen.Trace("table")
        for __,v in ipairs(args) do
            processArgs(v)
        end
    else
        -- invalid data
        Citizen.Trace("arg of type \"" .. type(args) .. "\" is not supported")
    end
end

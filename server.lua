
local trackyServerId = "Paste_Your_Trackyserver_ID_here"
local trackyServerKey = "Paste_Your_Trackyserver_KEY_here"

local endpoints = {
    ["vote"] = "https://trackyserver.com/server/%d",
    ["status"] = "https://api.trackyserver.com/vote/?action=status&key=%s&steamid=%s",
    ["claim"] = "https://api.trackyserver.com/vote/?action=claim&key=%s&steamid=%s"
}

-- Load current player vote count from file
local voteCache = LoadResourceFile(GetCurrentResourceName(), "votes.json")
if (not voteCache) then
    voteCache = {}
else
    voteCache = json.decode(voteCache)
end

-- If user doesn't have the convars set. Tell them
if trackyServerId == -1 then
    print("Please set the convar \"serverVoter:serverId\" to your server ID from https://trackyserver.com")
end
if trackyServerKey == "nil" then
    print("Please set the convar \"serverVoter:serverKey\" to your server key from https://trackyserver.com")
end

--[[
    Register commands players can use
]]--
RegisterCommand("vote", function(src, args, raw)
    -- Send them the URL to vote
    TriggerClientEvent("serverVote:showSubtitle", src, "vote", string.format(endpoints["vote"], trackyServerId), 10000)
end, false)

RegisterCommand("checkvote", function(src, args, raw)
    -- TODO: Check steam identifier with the trackyserver API
    local source = src
    local steamIdOrig, steamIdentifier

    for k,v in pairs(GetPlayerIdentifiers(source)) do
        if (string.starts(v, "steam:")) then
            steamIdentifier = tonumber(string.sub(v, 7), 16)
            steamIdOrig = v
        end
    end

    if (steamIdentifier == nil) then
        TriggerClientEvent("serverVote:showSubtitle", source, "steam_not_found", nil)
        return
    end

    print("Checking if " .. steamIdentifier .. " has voted")

    local statusUrl = string.format(endpoints["status"], trackyServerKey, steamIdentifier)

    PerformHttpRequest(statusUrl, function(statusCode, responseText, _)
        --local source = source
        --local steamIdentifier = steamIdentifier
        if (statusCode ~= 200) then
            print("Error getting status: " .. statusCode .. " : " .. tostring(responseText))
            return
        end
        print("src = " .. tostring(source))
        if (responseText == "0") then
            print("not voted")
            -- Not yet voted
            TriggerClientEvent("serverVote:showSubtitle", source, "vote_not_found", string.format(endpoints["vote"], trackyServerId))
        elseif (responseText == "1") then
            print("claiming")
            -- Voted, not claimed
            -- Claim it
            PerformHttpRequest(string.format(endpoints["claim"], trackyServerKey, steamIdentifier), function(statusCode, responseText, _)
                if (statusCode ~= 200) then
                    print("Error claiming vote")
                    return
                end

                if (responseText == "0") then
                    TriggerClientEvent("serverVote:showSubtitle", source, "vote_not_found", string.format(endpoints["vote"], trackyServerId))
                elseif (responseText == "1") then
                    -- Just claimed it... Yey time for a reward
                    claimedVote(source, steamIdOrig)

                elseif (responseText == "2") then
                    -- already claimed.  shouldn't get this because of the checks above but, just in case
                    TriggerClientEvent("serverVote:showSubtitle", source, "vote_already_claimed")
                end
            end, "GET", "", {})

        elseif (responseText == "2") then
            print("already claimed")
            -- Have voted, and claimed
            TriggerClientEvent("serverVote:showSubtitle", source, "vote_already_claimed")
        end
    end, "GET", "", {})

end, false)

-- Utility functions

function claimedVote(playerId, steamId)

    if (voteCache[steamId]) then
        voteCache[steamId] = voteCache[steamId] + 1
    else
        voteCache[steamId] = 1
    end

    -- Save the updated data to file
    SaveResourceFile(GetCurrentResourceName(), "votes.json", json.encode(voteCache, {indent = true}))

    local amountOfVotes = voteCache[steamId]
    local playerName = GetPlayerName(playerId)
    print("Current vote " .. amountOfVotes)
    if Config.Rewards["@"] and type(Config.Rewards["@"] == "table") then
        for k,v in ipairs(Config.Rewards["@"]) do
            local command = v

            command = string.gsub(command, "{playername}", playerName)
            command = string.gsub(command, "{playerid}", playerId)

            ExecuteCommand(command)
        end
    end

    if Config.Rewards[tostring(amountOfVotes)] then
        for k,v in ipairs(Config.Rewards[tostring(amountOfVotes)]) do
            local command = v

            command = string.gsub(command, "{playername}", playerName)
            command = string.gsub(command, "{playerid}", playerId)

            ExecuteCommand(command)
        end
    end
end

-- Nicked from http://lua-users.org/wiki/StringRecipes
function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

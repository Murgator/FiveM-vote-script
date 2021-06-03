local endpoints = {
    ["vote"] = "https://trackyserver.com/server/%d",
    ["status"] = "https://api.trackyserver.com/vote/?action=status&key=%s&"..Config.identifier.."=%s&customid=%s",
    ["claim"] = "https://api.trackyserver.com/vote/?action=claim&key=%s&"..Config.identifier.."=%s&customid=%s"
}

-- Check for ESX and MySQL
ESX = nil
if (GetConvar('mysql_connection_string', 'Empty') ~= "Empty") then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

-- Load current player vote count from file
local voteCache = LoadResourceFile(GetCurrentResourceName(), "votes.json")
if (not voteCache) then
    voteCache = {}
else
    voteCache = json.decode(voteCache)
end

-- If user doesn't have the convars set. Tell them
if Config.trackyServerId == -1 then
    print("Please set Config.trackyServerId to your server ID from https://trackyserver.com in config.lua file")
end
if Config.trackyServerKey == "nil" then
    print("Please set Config.trackyServerKey to your server key from https://trackyserver.com in config.lua file")
end
if Config.identifier ~= "discordid" and Config.identifier ~= "steamid" then
    print("Please set Config.identifier to steamid or discordid in config.lua file")
end

--[[
    Register commands players can use
]]--
RegisterCommand("vote", function(src, args, raw)
    -- Send them the URL to vote
    TriggerClientEvent("serverVote:showSubtitle", src, "vote", string.format(endpoints["vote"], Config.trackyServerId), 10000)
end, false)

RegisterCommand("checkvote", function(src, args, raw)
    local source = src
    local Orig_Identifier, player_local_identifier, player_database_identifier
    -- Get xplayerid (database identifier)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            player_database_identifier = xPlayer.identifier
        end
    end
    -- Get player identifiers   
    for k,v in pairs(GetPlayerIdentifiers(source)) do       
        if Config.identifier == "steamid" then
            if (string.starts(v, "steam:")) then
                player_local_identifier = tonumber(string.sub(v, 7), 16)
                Orig_Identifier = v
            end
        elseif Config.identifier == "discordid" then
            if (string.starts(v, "discord:")) then
                player_local_identifier = string.gsub(v, "discord:", "")
                Orig_Identifier = player_local_identifier
            end
        end     
    end
    
    if (player_local_identifier == nil) then
        TriggerClientEvent("serverVote:showSubtitle", source, "steam_not_found", nil)
        return
    end

    local statusUrl = string.format(endpoints["status"], Config.trackyServerKey, player_local_identifier, player_database_identifier)
    
    PerformHttpRequest(statusUrl, function(statusCode, responseText, _)
        if (statusCode ~= 200) then
            print("Error getting status: " .. statusCode .. " : " .. tostring(responseText))
            return
        end
        if (responseText == "0") then
            -- Not yet voted
            TriggerClientEvent("serverVote:showSubtitle", source, "vote_not_found", string.format(endpoints["vote"], Config.trackyServerId))
        elseif (responseText == "1") then
            -- Voted, not claimed
            -- Claim it
            PerformHttpRequest(string.format(endpoints["claim"], Config.trackyServerKey, player_local_identifier, player_database_identifier), function(statusCode, responseText, _)
                if (statusCode ~= 200) then
                    print("Error claiming vote")
                    return
                end

                if (responseText == "0") then
                    TriggerClientEvent("serverVote:showSubtitle", source, "vote_not_found", string.format(endpoints["vote"], Config.trackyServerId))
                elseif (responseText == "1") then
                    -- Just claimed it... Yey time for a reward
                    claimedVote(source, Orig_Identifier, player_database_identifier)

                elseif (responseText == "2") then
                    -- already claimed.  shouldn't get this because of the checks above but, just in case
                    TriggerClientEvent("serverVote:showSubtitle", source, "vote_already_claimed")
                end
            end, "GET", "", {})

        elseif (responseText == "2") then
            -- Have voted, and claimed
            TriggerClientEvent("serverVote:showSubtitle", source, "vote_already_claimed")
        end
    end, "GET", "", {})

end, false)

-- Utility functions

function claimedVote(playerId, Orig_Identifier, player_database_identifier)
    if player_database_identifier then
        Orig_Identifier = player_database_identifier
    end
    if (voteCache[Orig_Identifier]) then
        voteCache[Orig_Identifier] = voteCache[Orig_Identifier] + 1
    else
        voteCache[Orig_Identifier] = 1
    end

    -- Save the updated data to file
    SaveResourceFile(GetCurrentResourceName(), "votes.json", json.encode(voteCache, {indent = true}))

    local amountOfVotes = voteCache[Orig_Identifier]
    local playerName = GetPlayerName(playerId)
    
    if Config.Rewards["@"] and type(Config.Rewards["@"] == "table") then
        for k,v in ipairs(Config.Rewards["@"]) do
            local command = v
            command = string.gsub(command, "{playername}", playerName)
            command = string.gsub(command, "{playerid}", playerId)
            command = string.gsub(command, "{xplayerid}", player_database_identifier)
            command = string.gsub(command, "{votescount}", tostring(amountOfVotes))                     
            ExecuteCommand(command)
        end
    end

    if Config.Rewards[tostring(amountOfVotes)] then
        for k,v in ipairs(Config.Rewards[tostring(amountOfVotes)]) do
            local command = v
            command = string.gsub(command, "{playername}", playerName)
            command = string.gsub(command, "{playerid}", playerId)
            command = string.gsub(command, "{xplayerid}", player_database_identifier)
            command = string.gsub(command, "{votescount}", tostring(amountOfVotes))         
            ExecuteCommand(command)
        end
    end
end

-- Nicked from http://lua-users.org/wiki/StringRecipes
function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

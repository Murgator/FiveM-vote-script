local endpoints = {
    ["vote"] = "https://trackyserver.com/server/%d",
    ["status"] = "https://api.trackyserver.com/vote/?action=status&key=%s&"..Config.identifier.."id=%s&customid=%s",
    ["claim"] = "https://api.trackyserver.com/vote/?action=claim&key=%s&"..Config.identifier.."id=%s&customid=%s"
}

-- Load current player vote count from file
local voteCache = LoadResourceFile(GetCurrentResourceName(), "votes.json")
if (not voteCache) then
    voteCache = {}
else
    voteCache = json.decode(voteCache)
end

-- If user doesn't have the convars set. Tell them
if Config.trackyServerId == "" then
    print("Please set Config.trackyServerId to your server ID from https://trackyserver.com in config.lua file")
end
if Config.trackyServerKey == "" then
    print("Please set Config.trackyServerKey to your server key from https://trackyserver.com in config.lua file")
end
if Config.identifier ~= "discord" and Config.identifier ~= "steam" then
    print("Please set Config.identifier to word steam or discord in config.lua file")
end

--[[
    Register commands players can use
]]--
RegisterCommand("vote", function(src, args, raw)
    -- Send them the URL to vote
    TriggerClientEvent("serverVote:showSubtitle", tonumber(src), "vote", string.format(endpoints["vote"], Config.trackyServerId), 10000)
end, false)

RegisterCommand("checkvote", function(src, args, raw)
    local source = tonumber(src)
    local Orig_Identifier, player_local_identifier, player_licence
    -- Get player identifiers 
    for k,v in pairs(GetPlayerIdentifiers(source)) do   
        if Config.identifier == "steam" then
            if (string.starts(v, "steam:")) then
                player_local_identifier = tonumber(string.sub(v, 7), 16)
                Orig_Identifier = v
            end
        elseif Config.identifier == "discord" then
            if (string.starts(v, "discord:")) then
                player_local_identifier = string.gsub(v, "discord:", "")
                Orig_Identifier = player_local_identifier
            end
		end
		-- Get player licence
		if (string.starts(v, "license:")) or (string.starts(v, "licence:")) then
			player_licence = string.gsub(v, "licence:", "")
			player_licence = string.gsub(v, "license:", "")
		end
    end
    
    if (player_local_identifier == nil) then
        TriggerClientEvent("serverVote:showSubtitle", source, "steam_not_found", nil)
        return
    end

    local statusUrl = string.format(endpoints["status"], Config.trackyServerKey, player_local_identifier, player_licence)
    
    PerformHttpRequest(statusUrl, function(statusCode, responseText, _)
        if (statusCode ~= 200) then
            print("Error getting status: " .. statusCode .. " : " .. tostring(responseText))
            return
        end
        if string.find(responseText, "0") then
            -- Not yet voted
            TriggerClientEvent("serverVote:showSubtitle", source, "vote_not_found", string.format(endpoints["vote"], Config.trackyServerId))
        elseif string.find(responseText, "1") then
            -- Voted, not claimed
            -- Claim it
            PerformHttpRequest(string.format(endpoints["claim"], Config.trackyServerKey, player_local_identifier, player_licence), function(statusCode, responseText, _)
                if (statusCode ~= 200) then
                    print("Error claiming vote")
                    return
                end

                if string.find(responseText, "0") then
                    TriggerClientEvent("serverVote:showSubtitle", source, "vote_not_found", string.format(endpoints["vote"], Config.trackyServerId))
                elseif string.find(responseText, "1") then
                    -- Just claimed it... Yey time for a reward
                    claimedVote(source, Orig_Identifier, player_licence)

                elseif string.find(responseText, "2") then
                    -- already claimed.  shouldn't get this because of the checks above but, just in case
                    TriggerClientEvent("serverVote:showSubtitle", source, "vote_already_claimed")
                end
            end, "GET", "", {})

        elseif string.find(responseText, "2") then
            -- Have voted, and claimed
            TriggerClientEvent("serverVote:showSubtitle", source, "vote_already_claimed")
        end
    end, "GET", "", {})

end, false)

-- Utility functions

function claimedVote(playerId, Orig_Identifier, player_licence)
    if player_licence then
        Orig_Identifier = player_licence
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
            command = string.gsub(command, "{playerlicence}", player_licence)
            command = string.gsub(command, "{votescount}", tostring(amountOfVotes))                     
            ExecuteCommand(command)
        end
    end

    if Config.Rewards[tostring(amountOfVotes)] then
        for k,v in ipairs(Config.Rewards[tostring(amountOfVotes)]) do
            local command = v
            command = string.gsub(command, "{playername}", playerName)
            command = string.gsub(command, "{playerid}", playerId)
            command = string.gsub(command, "{playerlicence}", player_licence)
            command = string.gsub(command, "{votescount}", tostring(amountOfVotes))         
            ExecuteCommand(command)
        end
    end
end

-- Nicked from http://lua-users.org/wiki/StringRecipes
function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

-- Give money command
RegisterCommand("qbgivemoney", function(src, args, raw)
	local msg_err = "This command must be executed by the server console or RCON client"	
	if src > 0 then
		print(msg_err);
		return false
	elseif #args < 3 then
		print("Usage: qbgivemoney [Player ID] [Type of money (cash, bank, crypto)] [amount]");
		return false
	end
	local QBCore = exports['qb-core']:GetCoreObject()	
	local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
	if Player then
		Player.Functions.AddMoney(tostring(args[2]), tonumber(args[3]))
	else
		print("Player is offline");
	end	
end, false)

-- Announcement command
RegisterCommand("announce", function(src, args, raw)
    if src > 0 then
        print("This command must be executed by the server console or RCON client\n");
        return false
    elseif #args < 2 then
        print("Usage: t4s_announce [announce-title] [text]\n");
        return false
    end
    local title = args[1]
    args[1] = ""
    local words = table.concat(args, " ")
    TriggerClientEvent('chatMessage', -1, "\n"..title, {255, 0, 0}, words.." \n ")  
    print("^5[t4s_announce] "..title..words.."^7\n");
end, false)

Config = {}

Config.trackyServerId = "Paste_Your_Trackyserver_ID_here"
Config.trackyServerKey = "Paste_Your_Trackyserver_KEY_here"
Config.identifier = "discordid" -- discordid OR steamid

--[[
    Add rewards for the votes here.

    It's simple to add rewards, as they're just commands.
    Just make sure the command is runnable by the console (ask the original developers about this)

    Format =  "numberofvotes" = array

    "numberofvotes" is the number of votes the player needs before they can get this reward
    the array is an array of commands to run.

    If the commands need them, they will be passed the following:
        {playerid} = The server ID of the player
        {xplayerid} = The ESX identifier of the player
        {playername} = The name of the player
]]
Config.Rewards = {
    ["@"] = { -- @ = all votes
        "t4s_addmoney {xplayerid} bank 100", -- add 100 to the player's bank account
        "t4s_announce [VOTE] {playername} has voted and won $100 ! Number of votes: {votescount}"
    },
    ["10"] = { -- When the player has 10 votes
        "t4s_addmoney {xplayerid} bank 1000", -- add 1000 to the player's bank account
        "t4s_announce [VOTE] {playername} has voted 10 times and won $1000 !"
    },
    ["100"] = {
        "t4s_announce [VOTE] {playername} has 100 votes !!!"
    }
}

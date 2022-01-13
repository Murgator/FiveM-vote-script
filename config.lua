Config = {}

Config.trackyServerId = ""
Config.trackyServerKey = ""
Config.identifier = "discordid" -- discordid OR steamid

--[[
    Add rewards for the votes here.

    It's simple to add rewards, as they're just commands.
    Just make sure the command is runnable by the console (ask the original developers about this)

    Format =  "numberofvotes" = array

    "numberofvotes" is the number of votes the player needs before they can get this reward
    the array is an array of commands to run.

    If the commands need them, they will be passed the following:
        {playerid} = The player server ID
        {playerlicence} = The player GTA licence
        {playername} = The player name
]]
Config.Rewards = {
    ["@"] = { -- @ = all votes
        "giveaccountmoney {playerid} bank 100", -- ESX framework command (ex_extended command)
        "qbgivemoney {playerid} bank 100", -- QBCore framework command
        "announce [VOTE] {playername} has voted and won $100 ! Number of votes: {votescount}. Type /vote to vote"
    },
    ["10"] = { -- When the player has 10 votes
        "announce [VOTE] {playername} has voted 10 times !"
    },
    ["100"] = {
        "announce [VOTE] {playername} has 100 votes !"
    }
}

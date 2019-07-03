Config = {}

--[[
    Add rewards for the votes here.

    It's simple to add rewards, as they're just commands.
    Just make sure the command is runnable by the console (ask the original developers about this)

    Format =  "numberofvotes" = array

    "numberofvotes" is the number of votes the player needs before they can get this reward
    the array is an array of commands to run.

    If the commands need them, they will be passed the following:
        {playerid} = The server ID of the player
        {playername} = The name of the player

]]
Config.Rewards = {
    ["@"] = { -- @ = all votes
        "moneyadd {playerid} 100", -- add 100 money for voting
        "say {playername} has voted!"
    },
    ["10"] = { -- When the player has 10 votes
        "moneyadd {playerid} 1000", -- Add an extra 1000 money to the player
        "say {playername} has voted 10 times!"
    },
    ["100"] = {
        "say {playername} has 100 votes!!!"
    }
}

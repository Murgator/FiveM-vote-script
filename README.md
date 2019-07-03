### fivem-serverVote

A simple plugin to allow players to vote and claim rewards for their favourite servers.


## Configuration

There's only two server convars needed to set up this resource.

`serverVoter:serverId` - The ID of your server on [TrackyServer](https://www.trackyserver.com/). This is must be a number.

`serverVoter:serverKey` - The key for the server on [TrackyServer](https://www.trackyserver.com/).

After you have set the convars in the CFG file, you can continue to modify the `config.lua` file to run commands when players vote for your server.


#### Config.lua

In the `config.lua` file you will see a table called `Config.Rewards`.
This is meant to contain the commands to be triggered when a certain number of votes are reached.
The `["@"]` array represents "all votes" and will always be triggered regardless of vote count.

If a command needs the player's server ID, you can put `{playerid}` in it's place.
The same goes for the player's name with `{playername}`.

Below is the default configuration for the rewards table.
```lua
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
```

Note: Commands **must** be executable by the console. Otherwise, you will get errors.

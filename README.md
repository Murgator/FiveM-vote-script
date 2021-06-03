## FiveM vote script for Trackyserver.com (ESX1 & 2)

A simple plugin to allow players to vote and claim rewards for their favourite servers.

#### Prevents abusive votes (This point only works if you are using ESX2)

When a player requests their reward with /checkvote, their ESX ID is sent to Trackyserver.com. It is the database identifier (gta license) which is used to check if the player has already vote and received his reward.
	
#### Installation

Open an account on [Trackyserver.com](https://trackyserver.com/) and add a FiveM server.

Download this script and extract it to your `/resources` folder on your FiveM server.

To start the script, add this line at the end of your resources in server.cfg: `ensure FiveM-vote-script-master` (if that doesn't work add this instead: `start FiveM-vote-script-master`)

Add this line in server.cfg to allow script to type commands in the console: `add_ace resource.FiveM-vote-script-master command allow`

#### Configuration

There's only tree server vars needed to set up this resource in `config.lua` file.

`Config.trackyServerId` - The ID of your server on [TrackyServer](https://www.trackyserver.com/). This is must be a number.

`Config.trackyServerKey` - The key for the server on [TrackyServer](https://www.trackyserver.com/).

`Config.identifier` - Must be **discordid** or **steamid**. The player will be recognized on the server with this identifier

#### Commands configuration

In the `config.lua` file you will see a table called `Config.Rewards`.
This is meant to contain the commands to be triggered when a certain number of votes are reached.
The `["@"]` array represents "all votes" and will always be triggered regardless of vote count.

If a command needs the player's live ID, you can put `{playerid}` in it's place.
The same goes for the player's name with `{playername}`.
Use `{xplayerid}` for the ESX database identifier

Below is the default configuration for the rewards table.
```lua
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
```

#### Requirements

Commands **must** be executable by the console. Otherwise, you will get errors.

You can use `t4s_addmoney` and `t4s_announce` and other commands by using this script:

[Custom commands for ESX](https://github.com/Murgator/esx-fivem-commands)

[Custom commands for ESX 2](https://github.com/Murgator/esx2-fivem-commands)

### Chat commands

`/vote` - To display the server's voting link.

`/checkvote` - Type this command after voting for the server to receive your reward.

#### Original repository

Thanks to TGRHavoc for developing this script for FiveM and Trackyserver.

https://github.com/TGRHavoc/fivem-serverVote

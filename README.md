## FiveM vote script for Trackyserver.com

A simple plugin to allow players to vote and claim rewards for their favourite servers.

#### Prevents abusive votes

When a player requests their reward with /checkvote, their licence is sent to Trackyserver.com. It is the database identifier (gta license) which is used to check if the player has already vote and received his reward.
	
#### Installation

Open an account on [Trackyserver.com](https://trackyserver.com/) and add a FiveM server.

Download this script and extract it to your `/resources` folder on your FiveM server.

To start the script, add this line ***at the end*** of your resources in server.cfg: `ensure FiveM-vote-script-master`

Add this line in server.cfg to allow script to type commands in the console: `add_ace resource.FiveM-vote-script-master command allow`

#### Configuration

There's only tree server vars needed to set up this resource in `config.lua` file.

`Config.trackyServerId` - The ID of your server on [TrackyServer](https://www.trackyserver.com/). This is must be a number.

`Config.trackyServerKey` - The key for the server on [TrackyServer](https://www.trackyserver.com/).

`Config.identifier` - If you want your players to vote with Steam on Trackyserver leave this variable to the word **steam**. If your players vote with Discord set this variable to the word **discord**

#### Commands configuration

In the `config.lua` file you will see a table called `Config.Rewards`.
This is meant to contain the commands to be triggered when a certain number of votes are reached.
The `["@"]` array represents "all votes" and will always be triggered regardless of vote count.

If a command needs the player's live ID, you can put `{playerid}` in it's place.
The same goes for the player's name with `{playername}`.
Use `{playerlicence}` for the player GTA licence

Below is the default configuration for the rewards table.
```lua
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
```

### Chat commands

`/vote` - To display the server's voting link.

`/checkvote` - Type this command after voting for the server to receive your reward.

### Example console commands you can use in the reward config

`qbgivemoney {playerid} [account_type(bank/crypto/cash)] [amount]` - Give money to a player for QBCore.

`announce [prefix] [message]` - Announcement visible to all players in the chat.

### ❓ FAQ

1. **The script doesn’t seem to work. What should I check?**
Make sure the script is properly loaded on your server. In your server.cfg, you should have: `ensure FiveM-vote-script-master`
Then check your server console/logs to confirm the script is starting without errors.

3. **I type /checkvote but nothing happens?**
You should always receive a chat message when using /checkvote, even if you haven’t voted yet.
If nothing appears, it likely means the script is not loaded. Go back to step 1 and confirm it’s properly started.

4. **How can I test if the vote command is working?**
In your config file, use this test command: `announce [VOTE] {playername} this is a test vote`
Then run /checkvote in-game to verify if the command reacts. If it doesn’t, double-check your configuration and script load.

5. **The script doesn’t recognize me. Why?**
Make sure your Discord or Steam account is linked with your FiveM account.
The script uses these identifiers to recognize players. If your account is not linked, it won’t detect your vote or trigger any related commands.

#### Original repository

Thanks to TGRHavoc for developing this script for FiveM and Trackyserver.

https://github.com/TGRHavoc/fivem-serverVote

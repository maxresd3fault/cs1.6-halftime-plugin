# Counter-Strike 1.6 Halftime AMX Mod X Plugin
[![AMX Mod X](http://www.amxmodx.org/images/amxx.jpg)](http://www.amxmodx.org/)

This is a fairly simple AMX Mod X plugin which adds a halftime team swap into the game.

## Features

- Choose which round to swap teams at
- Reset all player weapons
- Reset all player money to the value of `mp_startmoney`
- Swap CT and T scores
- Announce the last round of the half in the chat

## Requirements

- AMX Mod X (tested on 1.8.2, might work on other versions)
- [Orpheu Module](https://github.com/Arkshine/Orpheu) with installed signatures for the function: `InstallGameRules`, and memory vars: `m_iNumCTWins`, `m_iNumTerroristWins`

## CVARS

- `amx_halftime_at_round 16` - Specify which round to commence halftime on. The team swap will occur on the start of the round specified. Ex. set to 16 for a 30 round game.
- `amx_announce_swap 1` - Enable/disable the chat message annoucing the last round of the half.

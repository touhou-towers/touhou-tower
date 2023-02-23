##### touhou-tower

These were the server files for gmod tower that were leaked which I am now modifying for my own server. It's hard.


Due to various exploits that exist in the original code base and how convoluted it is, I have decided to not bother with this anymore because it's probably a lot more difficult to fix compared to writing it over from scratch (which I also will not do).

#### Running a Server

Due to some recent inquiries on how to run the server, I've done a bit of local testing to re-figure out the steps.

Setup:
1. Clone this repository
2. Get your hands on the original GMT assets and maps (look around, there is an official link)
3. Download [`tmysql4`](https://github.com/bkacjios/gm_tmysql4/releases/tag/R1.02)
    - It must be this version because [`4.1+`](https://github.com/SuperiorServers/gm_tmysql4/releases/tag/R1.1) includes breaking changes and the current code will error out at least in database initialization due to `tmysql.initalize -> tmysql.Connect`.
4. Download [`transmittools`](https://github.com/touhou-towers/gmodmodules/blob/master/gm_transmittools/Release%20-%20GM13/gmsv_transmittools_win32.dll)

Steps:
1. Set up a Garry's Mod dedicated server via [SteamCMD](https://wiki.facepunch.com/gmod/Downloading_a_Dedicated_Server)
2. Go into your server's directory and set up an add-ons folder e.g. `GarrysModDS/garrysmod/addons`
    - This is not strictly necessary but will allow us to keep the custom files separate from the base game. You can just merge all the folders if you want, but we will do it this way to be neat.
    1. Copy this repository's `addons/mediaplayer` folder into the `addons` folder
    2. Create two folders with any name (e.g. `gmtower` and `gmtowerassets`) in the `addons` folder
        - one will house this repository's contents and one will house the original GMT assets.
    3. Copy this repository's `addons/mediaplayer` folder into the `addons` folder
    4. Copy this repository's `gamemodes` contents into one of the addon folders
    5. Create a [`gmodtower.txt`](https://wiki.facepunch.com/gmod/Gamemode_Creation#gamemodetextfile) file in the gamemodes folder.
        - I think you need to match it with the folder name, and the minimum content is `"gmodtower"{}`
        - Why isn't this in the repository already?
    6. Copy the original GMT assets into the other addon folder
    - We should end up with a folder structure like this:
```
garrysmod/
└── addons/
    ├── gmtower/
    │   └── gamemodes/
    |       ├── gmodtower.txt
    |       └── .../
    ├── gmtowerassets/
    │   ├── gamemodes/
    │   ├── maps/
    │   ├── materials/
    │   └── .../
    └── mediaplayer/
        └── .../
```

3. Set up dependencies:
    1. Open the `garrysmod/lua/bin` folder and put the `tmysql4` and `transmittools` dlls in there. If the folder doesn't exist, you can make it.
        - If there is an error with loading the file even though it says `xxx.lua`, make sure the [file name is correct](https://wiki.facepunch.com/gmod/Creating_Binary_Modules:_CMake#naminglocation) for your platform.
4. Create a file to run the server with the correct gamemode and map e.g. `srcds.exe -console +gamemode gmodtower +map gmt_build0s2b`

Disclaimer: I did not try joining the server, but this resolves most of the initial Garry's Mod server specific set up errors. There may still be errors around the SQL database if it is not set up or cannot be connected to, errors around `GTowerLocation`, errors around materials/models, and one error about duplicate IDs.

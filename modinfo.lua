-- This information tells other players more about the mod
name = "Shovel Knight 0.20.0"
description = "A character for Don't Starve Together, who wields a Shovelblade!"
author = "BLsquared & Jade_KnightBlazer"
version = "0.20.0"

-- This is the URL name of the mod's thread on the forum; the part after the ? and before the first & in the url
forumthread = "/files/file/1035-character-shovel-knight-the-blue-burrower/"


-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = true
all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

local alpha = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local KEY_A = 97
local keyslist = {}
for i = 1,#alpha do keyslist[i] = {description = alpha[i],data = i + KEY_A - 1} end

configuration_options =
{
    {
        name = "RELICKEY",
        label = "Relic Button",
		hover = "The key you need to press activate a Relic.",
        options = keyslist,
        default = 114, --R
    },    
}

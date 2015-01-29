GLOBAL.STRINGS.NAMES.SHOVELBLADE = "Shovelblade"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SHOVELBLADE = "Both a worthy weapon and a digging tool."

PrefabFiles = {
	"winston", "skitemtemplate", "skitemmealticket", "skitemmanapotion",
	"skweaponshovelbladebasic","skweaponshovelbladechargehandle", "skweaponshovelbladetrenchblade", "skweaponshovelbladedropspark",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/winston.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/winston.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/winston.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/winston.xml" ),

    Asset( "IMAGE", "bigportraits/winston.tex" ),
    Asset( "ATLAS", "bigportraits/winston.xml" ),
	
	Asset( "IMAGE", "images/map_icons/winston.tex" ),
	Asset( "ATLAS", "images/map_icons/winston.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_winston.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_winston.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_winston.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_winston.xml" ),

	Asset( "IMAGE", "images/map_icons/skweaponshovelbladebasic.tex" ),
	Asset( "ATLAS", "images/map_icons/skweaponshovelbladebasic.xml" ),
	
	Asset( "IMAGE", "images/map_icons/skweaponshovelbladechargehandle.tex" ),
	Asset( "ATLAS", "images/map_icons/skweaponshovelbladechargehandle.xml" ),
	
	Asset( "IMAGE", "images/map_icons/skweaponshovelbladetrenchblade.tex" ),
	Asset( "ATLAS", "images/map_icons/skweaponshovelbladetrenchblade.xml" ),
	
	Asset( "IMAGE", "images/map_icons/skweaponshovelbladedropspark.tex" ),
	Asset( "ATLAS", "images/map_icons/skweaponshovelbladedropspark.xml" ),
}

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

-- Item Recipes
local OldIsRecipeValid = GLOBAL.IsRecipeValid
local function IsRecipeValid(recipe)
	return OldIsRecipeValid(recipe) and
		((GLOBAL.ThePlayer and GLOBAL.ThePlayer:HasTag(recipe.name.."_skbuilder")) or not recipe.tagneeded)
end
GLOBAL.IsRecipeValid = IsRecipeValid

local Recipe = GLOBAL.Recipe
local RECIPETABS = GLOBAL.RECIPETABS
local TECH = GLOBAL.TECH

local recipes = 
{
	Recipe("skitemtemplate", {Ingredient("berries", 2), Ingredient("carrot", 1)}, RECIPETABS.WAR, TECH.SCIENCE_ONE),
	Recipe("skitemmealticket", {Ingredient("red_cap", 2), Ingredient("plantmeat", 1), Ingredient("goldnugget", 5)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO),
	Recipe("skitemmanapotion", {Ingredient("blue_cap", 2), Ingredient("plantmeat", 1), Ingredient("goldnugget", 5)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO),
	Recipe("skweaponshovelbladechargehandle", {Ingredient("skweaponshovelbladebasic", 1, "images/inventoryimages/skweaponshovelbladebasic.xml"), Ingredient("houndstooth", 4), Ingredient("livinglog", 4)}, RECIPETABS.REFINE, TECH.MAGIC_TWO),
	Recipe("skweaponshovelbladetrenchblade", {Ingredient("skweaponshovelbladechargehandle", 1, "images/inventoryimages/skweaponshovelbladechargehandle.xml"), Ingredient("tentaclespike", 1), Ingredient("moonrocknugget", 4)}, RECIPETABS.REFINE, TECH.MAGIC_TWO),
	Recipe("skweaponshovelbladedropspark", {Ingredient("skweaponshovelbladetrenchblade", 1, "images/inventoryimages/skweaponshovelbladetrenchblade.xml"), Ingredient("walrus_tusk", 2), Ingredient("nightmarefuel", 4)}, RECIPETABS.REFINE, TECH.MAGIC_THREE),
}

for k,v in pairs(recipes) do
    v.tagneeded = true
    v.atlas = "images/inventoryimages/" .. v.name .. ".xml"
end

-- The character select screen lines
STRINGS.CHARACTER_TITLES.winston = "The Blue Burrower"
STRINGS.CHARACTER_NAMES.winston = "Winston"
STRINGS.CHARACTER_DESCRIPTIONS.winston = "*Equipped with awesome Shovelblade\n*Loves Turkey Dinners\n*Useful, yet irreplaceable armour"
STRINGS.CHARACTER_QUOTES.winston = "\"For Shovelry!\""

-- Custom speech strings
STRINGS.CHARACTERS.WINSTON = require "speech_winston"

-- The character's name as appears in-game 
STRINGS.NAMES.WINSTON = "Shovel Knight"

-- The default responses of examining the character
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WINSTON = 
{
	GENERIC = "It's the Shovel Knight!",
	ATTACKER = "That Shovel Knight looks shifty...",
	MURDERER = "Murderer!",
	REVIVER = "Shovel Knight, friend of ghosts.",
	GHOST = "The Shovel Knight could use a heart.",
}

--Needed Item Strings
STRINGS.RECIPE_DESC.SKITEMTEMPLATE = "A skitemtemplate."
STRINGS.RECIPE_DESC.SKITEMMEALTICKET = "Gastronomer's home cooking!"
STRINGS.RECIPE_DESC.SKITEMMANAPOTION = "Magicist's bubbling brew!"
STRINGS.RECIPE_DESC.SKWEAPONSHOVELBLADECHARGEHANDLE = "Shovelblade Upgrade: Charge Handle"
STRINGS.RECIPE_DESC.SKWEAPONSHOVELBLADETRENCHBLADE = "Shovelblade Upgrade: Trench Blade"
STRINGS.RECIPE_DESC.SKWEAPONSHOVELBLADEDROPSPARK = "Shovelblade Upgrade: Drop Spark"


-- Let the game know character is male, female, or robot
table.insert(GLOBAL.CHARACTER_GENDERS.MALE, "winston")  

local old_ACTIONPICKUP = GLOBAL.ACTIONS.PICKUP.fn
	GLOBAL.ACTIONS.PICKUP.fn = function(act)
		if act.doer.prefab == "winston" and act.target and act.target.components.equippable and act.target.components.inventoryitem and act.target.components.armor and not act.target:IsInLimbo() then
			act.doer.components.inventory:GiveItem(act.target, nil, act.target:GetPosition())
			return true
		else
			return old_ACTIONPICKUP(act)
		end
	end
	
--Turn off percent on certain Items	
--local function itemtile_post(self, invitem)
    -- save old function
    --self.old_SetPercent = self.SetPercent
 
    -- override with your own function
    --self.SetPercent = function(self, percent)
	
	    -- call old function first
		--self:old_SetPercent(percent)
		
		--print("Checking prefab")
		--if self.invitem and self.invitem.prefab == "skitemmealticket" then
            --local oldStr = self.percent:GetString()
			--print(oldStr)
			--self.percent:SetString(string.format("%2.0f", oldStr)) -- remove %
			--self.percent:SetString(string.sub(oldStr,1,-2))
			--local newStr = string.sub(oldStr,1,-2)
            --print(newStr)
			--self.percent:SetString(newStr)
		--end
    --end
--end
--AddClassPostConstruct("widgets/itemtile", itemtile_post)

AddMinimapAtlas("images/map_icons/winston.xml")
AddMinimapAtlas("images/map_icons/skweaponshovelbladebasic.xml")
AddMinimapAtlas("images/map_icons/skweaponshovelbladechargehandle.xml")
AddMinimapAtlas("images/map_icons/skweaponshovelbladetrenchblade.xml")
AddMinimapAtlas("images/map_icons/skweaponshovelbladedropspark.xml")

AddModCharacter("winston")


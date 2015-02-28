PrefabFiles = {
	"winston", "skitemtroupplefish", "skitemtroupplefishking",
	"skstructuresigntroupple", "skstructuretreetroupple",
	"sktiletroupplepond", "sktiletroupplepondborder", 
	"skitemmealticket", "skitemmanapotion", "skitemfishingrod", "skitemmusicsheet",
	"skweaponshovelbladebasic","skweaponshovelbladechargehandle", "skweaponshovelbladetrenchblade", "skweaponshovelbladedropspark",
	"skarmorstalwartplate", "skarmorfinalguard", "skarmorconjurerscoat", "skarmordynamomail", "skarmormailofmomentum", "skarmorornateplate",
	"skrelicfishingrod", "skrelictroupplechalice", "skrelictroupplechalicered", "skrelictroupplechaliceblue", "skrelictroupplechaliceyellow",
	"skfxchargehandle_shatter", "skfxdropspark_wave", "skfxornateplate_glitter", "skfxornateplate_trail", "skfxtrouppletree_orbglow",
	"skfxtroupplechalice_red", "skfxtroupplechalice_blue", "skfxtroupplechalice_yellow", "skfxichor_red", "skfxichor_blue", "skfxichor_yellow",
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
	
	Asset( "SOUNDPACKAGE", "sound/winston.fev" ), --SOUNDPACKAGE
    Asset( "SOUND", "sound/winston_bank00.fsb" ),

	Asset( "IMAGE", "images/map_icons/skweaponshovelbladebasic.tex" ),
	Asset( "ATLAS", "images/map_icons/skweaponshovelbladebasic.xml" ),
	
	Asset( "IMAGE", "images/map_icons/skweaponshovelbladechargehandle.tex" ),
	Asset( "ATLAS", "images/map_icons/skweaponshovelbladechargehandle.xml" ),
	
	Asset( "IMAGE", "images/map_icons/skweaponshovelbladetrenchblade.tex" ),
	Asset( "ATLAS", "images/map_icons/skweaponshovelbladetrenchblade.xml" ),
	
	Asset( "IMAGE", "images/map_icons/skweaponshovelbladedropspark.tex" ),
	Asset( "ATLAS", "images/map_icons/skweaponshovelbladedropspark.xml" ),
	
	Asset( "IMAGE", "images/map_icons/skarmorstalwartplate.tex" ),
	Asset( "ATLAS", "images/map_icons/skarmorstalwartplate.xml" ),
	
	Asset( "IMAGE", "images/map_icons/sktiletroupplepond.tex" ),
	Asset( "ATLAS", "images/map_icons/sktiletroupplepond.xml" ),
	Asset( "IMAGE", "images/map_icons/sktiletroupplepondfrozen.tex" ),
	Asset( "ATLAS", "images/map_icons/sktiletroupplepondfrozen.xml" ),
}

RemapSoundEvent( "dontstarve/characters/winston/shovelbladeequipped", "winston/characters/winston/shovelbladeequipped" )
RemapSoundEvent( "dontstarve/characters/winston/chargehandlecharged", "winston/characters/winston/chargehandlecharged" )
RemapSoundEvent( "dontstarve/characters/winston/chargehandlerelease", "winston/characters/winston/chargehandlerelease" )
RemapSoundEvent( "dontstarve/characters/winston/dropspark", "winston/characters/winston/dropspark" )
RemapSoundEvent( "dontstarve/characters/winston/jump", "winston/characters/winston/jump" )

local require = GLOBAL.require
local unpack = GLOBAL.unpack
local STRINGS = GLOBAL.STRINGS
 
local Recipe = GLOBAL.Recipe
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local TECH = GLOBAL.TECH

--Dedicated server Recipes
local recipes = 
{
	Recipe("skarmorornateplate", {Ingredient("goldnugget", 12), Ingredient("fireflies", 6)}, RECIPETABS.WAR, {SCIENCE = 2, MAGIC = 0, ANCIENT = 0}, nil, nil, nil, nil),
	Recipe("skarmormailofmomentum", {Ingredient("redgem", 2), Ingredient("nightmarefuel", 6)}, RECIPETABS.WAR, {SCIENCE = 0, MAGIC = 3, ANCIENT = 0}, nil, nil, nil, nil),
	Recipe("skarmordynamomail", {Ingredient("bluegem", 2), Ingredient("moonrocknugget", 6)}, RECIPETABS.WAR, {SCIENCE = 0, MAGIC = 2, ANCIENT = 0}, nil, nil, nil, nil),
	Recipe("skarmorconjurerscoat", {Ingredient("purplegem", 2), Ingredient("silk", 6)}, RECIPETABS.WAR, {SCIENCE = 0, MAGIC = 2, ANCIENT = 0}, nil, nil, nil, nil),
	Recipe("skarmorfinalguard", {Ingredient("redgem", 2), Ingredient("tentaclespots", 6)}, RECIPETABS.WAR, {SCIENCE = 2, MAGIC = 0, ANCIENT = 0}, nil, nil, nil, nil),
	Recipe("skweaponshovelbladedropspark", {Ingredient("skweaponshovelbladetrenchblade", 1, "images/inventoryimages/skweaponshovelbladetrenchblade.xml"), Ingredient("walrus_tusk", 2), Ingredient("nightmarefuel", 4)}, RECIPETABS.REFINE, {SCIENCE = 0, MAGIC = 3, ANCIENT = 0}, nil, nil, nil, nil),
	Recipe("skweaponshovelbladetrenchblade", {Ingredient("skweaponshovelbladechargehandle", 1, "images/inventoryimages/skweaponshovelbladechargehandle.xml"), Ingredient("tentaclespike", 1), Ingredient("moonrocknugget", 4)}, RECIPETABS.REFINE, {SCIENCE = 0, MAGIC = 2, ANCIENT = 0}, nil, nil, nil, nil),
	Recipe("skweaponshovelbladechargehandle", {Ingredient("skweaponshovelbladebasic", 1, "images/inventoryimages/skweaponshovelbladebasic.xml"), Ingredient("houndstooth", 4), Ingredient("livinglog", 4)}, RECIPETABS.REFINE, {SCIENCE = 0, MAGIC = 2, ANCIENT = 0}, nil, nil, nil, nil),
	Recipe("skitemmanapotion", {Ingredient("blue_cap", 2), Ingredient("plantmeat", 1), Ingredient("goldnugget", 5)}, RECIPETABS.SURVIVAL, {SCIENCE = 2, MAGIC = 0, ANCIENT = 0}, nil, nil, nil, nil),
	Recipe("skitemmealticket", {Ingredient("red_cap", 2), Ingredient("plantmeat", 1), Ingredient("goldnugget", 5)}, RECIPETABS.SURVIVAL, {SCIENCE = 2, MAGIC = 0, ANCIENT = 0}, nil, nil, nil, nil),
}

local sortkey = -110000
for k,v in pairs(recipes) do
    sortkey = sortkey - 1
    v.sortkey = sortkey
    v.builder_tag = v.name.."_builder"
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
STRINGS.RECIPE_DESC.SKITEMMEALTICKET = "Gastronomer's home cooking!"
STRINGS.RECIPE_DESC.SKITEMMANAPOTION = "Magicist's bubbling brew!"
STRINGS.RECIPE_DESC.SKWEAPONSHOVELBLADECHARGEHANDLE = "Shovelblade Upgrade: Charge Handle"
STRINGS.RECIPE_DESC.SKWEAPONSHOVELBLADETRENCHBLADE = "Shovelblade Upgrade: Trench Blade"
STRINGS.RECIPE_DESC.SKWEAPONSHOVELBLADEDROPSPARK = "Shovelblade Upgrade: Drop Spark"
STRINGS.RECIPE_DESC.SKARMORFINALGUARD = "Lose only half as much stuff during a death!"
STRINGS.RECIPE_DESC.SKARMORCONJURERSCOAT = "Harvest sanity from defeated foes!"
STRINGS.RECIPE_DESC.SKARMORDYNAMOMAIL = "Increase Shovelblade Upgrade powers!"
STRINGS.RECIPE_DESC.SKARMORMAILOFMOMENTUM = "Heavily plated, Can't be slowed!"
STRINGS.RECIPE_DESC.SKARMORORNATEPLATE = "Flashy! Acrobatic! Useless!"

local old_ACTIONPICKUP = GLOBAL.ACTIONS.PICKUP.fn
	GLOBAL.ACTIONS.PICKUP.fn = function(act)
		if act.doer.prefab == "winston" and act.target and act.target.components.equippable and act.target.components.inventoryitem and act.target.components.armor and not act.target:IsInLimbo() then
			act.doer.components.inventory:GiveItem(act.target, nil, act.target:GetPosition())
			return true
		else
			return old_ACTIONPICKUP(act)
		end
	end

--Fix Health Penalty From Resurrection
local function HealthPostInit(self)
	if self.prefab == winston then
		--print("I'm Shovel Knight! Now fix my Health!")
		local OldRecalculatePenalty = self.RecalculatePenalty
		local function RecalculatePenalty(self, forceupdatewidget)
			local mult = GLOBAL.TUNING.REVIVE_HEALTH_PENALTY_AS_MULTIPLE_OF_EFFIGY
			mult = mult * GLOBAL.TUNING.EFFIGY_HEALTH_PENALTY
				local maxrevives = (self.maxhealth - 30)/mult
				if self.numrevives > maxrevives then
					self.numrevives = maxrevives
				end
				OldRecalculatePenalty(self, forceupdatewidget)
		end
		self.RecalculatePenalty = RecalculatePenalty
	end
end
AddComponentPostInit('health', HealthPostInit)

--Custom Relic Key
GLOBAL.SKRELICKEY = GetModConfigData("RELICKEY")--Relic Toggle Key

local function IsDefaultScreen()
	return GLOBAL.TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil
end

local SKUSERELIC = GLOBAL.Action()
SKUSERELIC.str = "skUseRElic"
SKUSERELIC.id = "SKUSERELIC"
SKUSERELIC.fn = function(act)
	if not IsDefaultScreen() then return true end
	
	local silent = true
	if act.target.prefab == "winston" then
		if act.target.components.inventory.equipslots[GLOBAL.EQUIPSLOTS.HEAD] ~= nil then
			local relicItem = act.target.components.inventory.equipslots[GLOBAL.EQUIPSLOTS.HEAD]
			if relicItem.prefab == "skrelicfishingrod" or relicItem.prefab == "skrelictroupplechalice"
				or relicItem.prefab == "skrelictroupplechalicered" or relicItem.prefab == "skrelictroupplechaliceblue" or relicItem.prefab == "skrelictroupplechaliceyellow" then
				relicItem.components.useableitem:StartUsingItem()
				--act.target.components.talker:Say("Relic key was pressed")
			end
		end
	end
	return true
end
AddAction(SKUSERELIC) 

-- Let the game know character is male, female, or robot
table.insert(GLOBAL.CHARACTER_GENDERS.MALE, "winston")

AddMinimapAtlas("images/map_icons/winston.xml")
AddMinimapAtlas("images/map_icons/skweaponshovelbladebasic.xml")
AddMinimapAtlas("images/map_icons/skweaponshovelbladechargehandle.xml")
AddMinimapAtlas("images/map_icons/skweaponshovelbladetrenchblade.xml")
AddMinimapAtlas("images/map_icons/skweaponshovelbladedropspark.xml")
AddMinimapAtlas("images/map_icons/skarmorstalwartplate.xml")
AddMinimapAtlas("images/map_icons/sktiletroupplepond.xml")
AddMinimapAtlas("images/map_icons/sktiletroupplepondfrozen.xml")

AddModCharacter("winston", "MALE")


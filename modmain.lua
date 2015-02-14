local KEY_CTRL = GLOBAL.KEY_CTRL
local TheInput = GLOBAL.TheInput

PrefabFiles = {
	"winston", "skitemtemplate", 
	"skitemmealticket", "skitemmanapotion", "skitemfishingrod",
	"skitemmusicsheet",
	"skweaponshovelbladebasic","skweaponshovelbladechargehandle", "skweaponshovelbladetrenchblade", "skweaponshovelbladedropspark",
	"skarmorstalwartplate", "skarmorfinalguard", "skarmorconjurerscoat", "skarmordynamomail", "skarmormailofmomentum", "skarmorornateplate",
	"skfxchargehandle_shatter", "skfxdropspark_wave", "skfxornateplate_glitter", "skfxornateplate_trail",
	"skrelicfishingrod",
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
	
	Asset( "SOUNDPACKAGE", "sound/winston.fev" ),
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
}

RemapSoundEvent( "dontstarve/characters/winston/shovelbladeequipped", "winston/characters/winston/shovelbladeequipped" )
RemapSoundEvent( "dontstarve/characters/winston/chargehandlecharged", "winston/characters/winston/chargehandlecharged" )
RemapSoundEvent( "dontstarve/characters/winston/chargehandlerelease", "winston/characters/winston/chargehandlerelease" )
RemapSoundEvent( "dontstarve/characters/winston/dropspark", "winston/characters/winston/dropspark" )
RemapSoundEvent( "dontstarve/characters/winston/jump", "winston/characters/winston/jump" )

--Key Bind stuff
local RELICKEY = GetModConfigData("RELICKEY")--Relic Toggle Key
--local controls = nil
local keydown = false

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
	Recipe("skarmorfinalguard", {Ingredient("redgem", 2), Ingredient("heatrock", 6)}, RECIPETABS.WAR, TECH.SCIENCE_TWO),
	Recipe("skarmorconjurerscoat", {Ingredient("purplegem", 2), Ingredient("silk", 6)}, RECIPETABS.WAR, TECH.SCIENCE_TWO),
	Recipe("skarmordynamomail", {Ingredient("bluegem", 2), Ingredient("moonrocknugget", 6)}, RECIPETABS.WAR, TECH.SCIENCE_TWO),
	Recipe("skarmormailofmomentum", {Ingredient("redgem", 2), Ingredient("nightmarefuel", 6)}, RECIPETABS.WAR, TECH.SCIENCE_TWO),
	Recipe("skarmorornateplate", {Ingredient("goldnugget", 12), Ingredient("fireflies", 6)}, RECIPETABS.WAR, TECH.SCIENCE_TWO),
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
STRINGS.RECIPE_DESC.SKARMORFINALGUARD = "Lose half as much heat during the cold!"
STRINGS.RECIPE_DESC.SKARMORCONJURERSCOAT = "Harvest sanity from defeated foes!"
STRINGS.RECIPE_DESC.SKARMORDYNAMOMAIL = "Increase Shovelblade Upgrade powers!"
STRINGS.RECIPE_DESC.SKARMORMAILOFMOMENTUM = "Heavily plated, Can't be slowed!"
STRINGS.RECIPE_DESC.SKARMORORNATEPLATE = "Flashy! Acrobatic! Useless!"

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
local function IsDefaultScreen()
	return GLOBAL.TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil
end

local function ShowCastRelic()
	if keydown then return end
	keydown = true
	if not IsDefaultScreen() then return end
	
	if GLOBAL.ThePlayer.prefab == "winston" then
		if GLOBAL.ThePlayer.components.inventory.equipslots[GLOBAL.EQUIPSLOTS.HEAD] ~= nil then
			local relicItem = GLOBAL.ThePlayer.components.inventory.equipslots[GLOBAL.EQUIPSLOTS.HEAD]
			if relicItem.prefab == "skrelicfishingrod" then
				relicItem.components.useableitem:StartUsingItem()
			end
		end
	end
end

local function HideCastRelic()
	keydown = false
end

local function AddRelicToggleKey(self)
	--controls = self -- this just makes controls available in the rest of the modmain's functions
	
	GLOBAL.TheInput:AddKeyDownHandler(RELICKEY, ShowCastRelic)
	GLOBAL.TheInput:AddKeyUpHandler(RELICKEY, HideCastRelic)
	
	--local OldOnUpdate = controls.OnUpdate
	--local function OnUpdate(...)
		--OldOnUpdate(...)
		--if keydown then
		--end
	--end
	--controls.OnUpdate = OnUpdate
end
AddClassPostConstruct( "widgets/controls", AddRelicToggleKey )

--Fishing
--local random_loot = "log"

--local rod = _G.require "components/fishingrod"
--local hook = rod.Collect
--function rod:Collect(...)
	--local r=math.random()
	--local pr
	--if r<0.5 then
		--pr="gears"
	--else
		--r=r-0.5
		--if r<0.4 then
			--pr=random_loot
		--end
	--end
	--if pr and self.fisherman and self.fisherman.components.inventory then
		--self.fisherman.components.inventory:DropItem(_G.SpawnPrefab(pr), true, true)
	--end
	--return hook(self,...)
--end

AddMinimapAtlas("images/map_icons/winston.xml")
AddMinimapAtlas("images/map_icons/skweaponshovelbladebasic.xml")
AddMinimapAtlas("images/map_icons/skweaponshovelbladechargehandle.xml")
AddMinimapAtlas("images/map_icons/skweaponshovelbladetrenchblade.xml")
AddMinimapAtlas("images/map_icons/skweaponshovelbladedropspark.xml")
AddMinimapAtlas("images/map_icons/skarmorstalwartplate.xml")

AddModCharacter("winston")


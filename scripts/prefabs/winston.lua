
local MakePlayerCharacter = require "prefabs/player_common"


local assets = {

        Asset( "ANIM", "anim/player_basic.zip" ),
        Asset( "ANIM", "anim/player_idles_shiver.zip" ),
        Asset( "ANIM", "anim/player_actions.zip" ),
        Asset( "ANIM", "anim/player_actions_axe.zip" ),
        Asset( "ANIM", "anim/player_actions_pickaxe.zip" ),
        Asset( "ANIM", "anim/player_actions_shovel.zip" ),
        Asset( "ANIM", "anim/player_actions_blowdart.zip" ),
        Asset( "ANIM", "anim/player_actions_eat.zip" ),
        Asset( "ANIM", "anim/player_actions_item.zip" ),
        Asset( "ANIM", "anim/player_actions_uniqueitem.zip" ),
        Asset( "ANIM", "anim/player_actions_bugnet.zip" ),
        Asset( "ANIM", "anim/player_actions_fishing.zip" ),
        Asset( "ANIM", "anim/player_actions_boomerang.zip" ),
        Asset( "ANIM", "anim/player_bush_hat.zip" ),
        Asset( "ANIM", "anim/player_attacks.zip" ),
        Asset( "ANIM", "anim/player_idles.zip" ),
        Asset( "ANIM", "anim/player_rebirth.zip" ),
        Asset( "ANIM", "anim/player_jump.zip" ),
        Asset( "ANIM", "anim/player_amulet_resurrect.zip" ),
        Asset( "ANIM", "anim/player_teleport.zip" ),
        Asset( "ANIM", "anim/wilson_fx.zip" ),
        Asset( "ANIM", "anim/player_one_man_band.zip" ),
        Asset( "ANIM", "anim/shadow_hands.zip" ),
        Asset( "SOUND", "sound/sfx.fsb" ),
        Asset( "SOUND", "sound/wilson.fsb" ),
        Asset( "ANIM", "anim/beard.zip" ),

        Asset( "ANIM", "anim/winston.zip" ),
        Asset( "ANIM", "anim/ghost_winston_build.zip" ),
}
local prefabs = {}
local start_inv = {
	"skweaponshovelbladebasic",
}

--creates the relic in world
local function createRelic(relicPrefab, target)
	if relicPrefab then
		local relic = SpawnPrefab(relicPrefab)
		local theta = math.random() * 2 * PI
		local pt = Point(target.Transform:GetWorldPosition())
		relic.Transform:SetPosition(pt.x,pt.y,pt.z)
				 
		if relic.Physics then
			local angle = math.random()*2*PI
			relic.Physics:SetVel(2*math.cos(angle), 10, 2*math.sin(angle))

			if relic and relic.Physics and target and target.Physics then
				pt = pt + Vector3(math.cos(angle), 0, math.sin(angle))*((relic.Physics:GetRadius() or 1) + (target.Physics:GetRadius() or 1))
				relic.Transform:SetPosition(pt.x,pt.y,pt.z)
			end
				
			relic:DoTaskInTime(1,
			function() 
				if not (relic.components.inventoryitem and relic.components.inventoryitem:IsHeld()) then
					if not relic:IsOnValidGround() then
						SpawnPrefab("splash_ocean").Transform:SetPosition(relic.Transform:GetWorldPosition())
						--PlayFX(relic:GetPosition(), "splash", "splash_ocean", "idle")
						if relic:HasTag("irreplaceable") then
							local x,y,z = FindSafeSpawnLocation(relic.Transform:GetWorldPosition())								
							relic.Transform:SetPosition(x,y,z)
						else
							relic:Remove()
						end
					end
				end
			end)
		end
	end
end

-- Upgrades!
--local function applyupgrades(inst)
	--local levelMAX = 9
	--if inst.level < levelMAX then
		--inst.components.health:SetMaxHealth((inst.level*15)+80)
		--inst.components.locomotor.runspeed = 5+inst.level
		--inst.components.combat.damagemultiplier = 1+(inst.level*.5)
	--end
--end

--Needed on Load for Health
local function applyMealTicketUpdate(inst)
	local mealTicketMAX = 9
	if inst.mealTicket < mealTicketMAX then
		inst.components.health:SetMaxHealth((inst.mealTicket*15)+80)
		inst.components.health:DoDelta((inst.mealTicket*15)+80)
	end
end

--Needed on Load for Sanity
local function applyManaPotionUpdate(inst)
	local manaPotionMAX = 9
	if inst.manaPotion < manaPotionMAX then
		inst.components.sanity:SetMax((inst.manaPotion*10)+120)
		inst.components.sanity:DoDelta((inst.manaPotion*10)+120)
	end
end

--Full Health and Hunger
local function applyTurkeyDinnerUpdate(inst)
	inst.components.health:DoDelta((inst.mealTicket*15)+80)
	inst.components.hunger:DoDelta(150)
	inst.components.talker:Say(GetString(inst, "ANNOUNCE_EATTURKEYDINNER"))
end

local function oneat(inst, food)

	--Adds lvls with food template
	--if food and food.components.edible and food.prefab == "carrot" and inst.level < MealTicketMax then
		--inst.level = inst.level+1
		--applyupgrades(inst)
		--inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
	--end
	
	if food and food.components.edible and food.prefab == "turkeydinner" then
		applyTurkeyDinnerUpdate(inst)
		--inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
	end
end

local function onpreload(inst, data)
    if data ~= nil then
		if data.level ~= nil then
			inst.level = data.level
			--applyupgrades(inst)
		end
		
		--Loads up mealTicket and manaPotion upgrades
        if data.mealTicket ~= nil then
			inst.mealTicket = data.mealTicket
			applyMealTicketUpdate(inst)
		end
		
		if data.manaPotion ~= nil then
			inst.manaPotion = data.manaPotion
			applyManaPotionUpdate(inst)
		end
		
        --re-set these from the save data, because of load-order clipping issues
        if data.health and data.health.health then inst.components.health:SetCurrentHealth(data.health.health) end
        if data.hunger and data.hunger.hunger then inst.components.hunger.current = data.hunger.hunger end
        if data.sanity and data.sanity.current then inst.components.sanity.current = data.sanity.current end
        inst.components.health:DoDelta(0)
        inst.components.hunger:DoDelta(0)
        inst.components.sanity:DoDelta(0)
    end
end

local function onsave(inst, data)
	data.level = inst.level > 0 and inst.level or nil
	data.mealTicket = inst.mealTicket > 0 and inst.mealTicket or nil
	data.manaPotion = inst.manaPotion > 0 and inst.manaPotion or nil
	
	data.charge_time = inst.charge_time > 0 and inst.charge_time or nil
end

local function onworked(inst, data)
	if data.target and data.target.components.workable and data.target.components.workable.action == ACTIONS.DIG then
		local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equipped ~= nil then
			if equipped.prefab == "skweaponshovelbladetrenchblade" or equipped.prefab == "skweaponshovelbladedropspark" then
				--createRelic("carrot", data.target) --Creates the Relic
			end
		end
	end
end

local function ondeath(inst)
	--startovercharge(inst, inst.charge_time + TUNING.TOTAL_DAY_TIME * (.5 + .5 * math.random()))
	--Don't need Meal Tickets and Mana Potions removed on death
    --if inst.level > 0 then
        --inst.level = 0
        --applyupgrades(inst)
    --end
end

-- This initializes for both clients and the host
local common_postinit = function(inst) 
	-- choose which sounds this character will play
	inst.soundsname = "wolfgang"

	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "winston.tex" )
end

-- This initializes for the host only
local master_postinit = function(inst)

	--Personal Recipes
	inst:AddTag("skitemtemplate_skbuilder")
	inst:AddTag("skitemmealticket_skbuilder")
	inst:AddTag("skitemmanapotion_skbuilder")
	inst:AddTag("skweaponshovelbladechargehandle_skbuilder")
	inst:AddTag("skweaponshovelbladetrenchblade_skbuilder")
	inst:AddTag("skweaponshovelbladedropspark_skbuilder")
	
	--Personal Reading
	inst:AddComponent("reader")
	
	--inst:ListenForEvent("ACTIONS.DIG", function (inst) inst.components.sanity:DoDelta(-TUNING.SANITY_MED) end, inst)
	
	-- Stats
	inst.level = 0
	inst.mealTicket = 0
	inst.manaPotion = 0
	
	--local levelMAX = 9
	local mealTicketMAX = 9
	local manaPotionMAX = 9
	
	--Special Shovelblade Abilities
	inst.charge_time = 0
	inst.charged_task = nil
	
	inst.components.health:SetMaxHealth(80)
	inst.components.hunger:SetMax(150)
	inst.components.sanity:SetMax(120)
	inst.components.locomotor.runspeed = 5
	inst.components.combat.damagemultiplier = 1
	--inst.components.combat:SetAttackPeriod()
	inst.components.sanity.night_drain_mult = 1
	
	inst.components.eater:SetOnEatFn(oneat)
	
	inst.OnSave = onsave
	inst.OnPreLoad = onpreload
	inst:ListenForEvent("death", ondeath)
	inst:ListenForEvent("working", onworked)
	
	local function IsChestArmor(item)
        if item.components.armor and item.components.equippable.equipslot == EQUIPSLOTS.BODY then
            return true
        else
            return false
        end
    end 
	
	--local old_DoAttack = inst.components.combat.DoAttack 
		--inst.components.combat.DoAttack = function(self, target_override, weapon, projectile)
		--startovercharge(inst, inst.charge_time + 10)
		--return old_DoAttack(self, target_override, weapon, projectile)
	--end
	
	local old_Equip = inst.components.inventory.Equip
    inst.components.inventory.Equip = function(self, item, old_to_active)
        if IsChestArmor(item) then self.inst.components.talker:Say("My mighty armor is mightier") return false end
        return old_Equip(self, item, old_to_active)
    end
	
	local old_GetAttacked = inst.components.combat.GetAttacked 
		inst.components.combat.GetAttacked = function(self,attacker, damage, weapon)
		damage = 10
		return old_GetAttacked(self,attacker, damage, weapon)
	end
end

return MakePlayerCharacter("winston", prefabs, assets, common_postinit, master_postinit, start_inv)

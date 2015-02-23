local MakePlayerCharacter = require "prefabs/player_common"
local theInput = require("input")

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
		Asset( "ANIM", "anim/winston_finalguard.zip" ),
		Asset( "ANIM", "anim/winston_conjurerscoat.zip" ),
		Asset( "ANIM", "anim/winston_dynamomail.zip" ),
		Asset( "ANIM", "anim/winston_mailofmomentum.zip" ),
		Asset( "ANIM", "anim/winston_ornateplate.zip" ),		
        Asset( "ANIM", "anim/ghost_winston_build.zip" ),
		
}
local prefabs = {}
local start_inv = {
	"skweaponshovelbladebasic", --"turkeydinner", "skrelicfishingrod",
}

local function OnRelicKeyPressed(inst, data)
    if data.inst == ThePlayer then
        if data.key == RELICKEY then
            if TheWorld.ismastersim then
                BufferedAction(inst, inst, ACTIONS.SKUSERELIC):Do()
                -- Since we are the server, do the action on the server.
            else
                SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.SKUSERELIC.code, inst, ACTIONS.SKUSERELIC.mod_name)
            end
        end
    end
end

--11 Relics
local relicList = {
	"skrelicfishingrod", "skrelictroupplechalice", --"log", "goldnugget", "livinglog", "turkeydinner",
	--"blue_cap", "green_cap", "skitemmealticket", "skitemmanapotion", "tophat",
}

--Random vaulable loot list
local lootList = {
	"redgem", "bluegem", "orangegem", "yellowgem", "greengem", "purplegem", "goldnugget",
}

--Finds a relic to make
local function randomRelicGen()
	return relicList[math.random(#relicList)]
end

local function randomLootGen()
	return lootList[math.random(#lootList)]
end

--creates the relic and loot in world
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

--DropSpark Proj Damage Booster
local function bonusDamageDropSparkPerk(inst)
	local bonusDamage = 0
	if inst.components.inventory.equipslots[EQUIPSLOTS.BODY] ~= nil then
		local item = inst.components.inventory.equipslots[EQUIPSLOTS.BODY]
		if item.prefab == "skarmorstalwartplate" or item.prefab == "skarmorfinalguard" or item.prefab == "skarmorconjurerscoat"
			or item.prefab == "skarmordynamomail" or item.prefab == "skarmormailofmomentum" or item.prefab == "skarmorornateplate" then
			bonusDamage = item.armorDropSparkBooster --Saved on the Shovel Knight Armor
		end
	end
	return bonusDamage
end

--DropSpark Proj Creator
local function createDropSparkProjectile(inst, target, weapon)
	local proj = SpawnPrefab("skfxdropspark_wave")--Name of the projectile
	if proj then
		if proj.components.projectile then
			proj.owner = inst --Saves player to Projectile
			proj.projDamageBonus =  bonusDamageDropSparkPerk(inst)--Adds bonus damage from armor bonus --Need for Armor--
			proj.Transform:SetPosition(inst.Transform:GetWorldPosition())
			proj.components.projectile:Throw(weapon, target, inst)
			inst.SoundEmitter:PlaySound("winston/characters/winston/dropspark")
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
		--inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup") --Need the Food sound here--
	end
end

local function onupdate(inst, dt)
	inst.trenchBladeComboTime = inst.trenchBladeComboTime - dt
	inst.trenchBladeDebuffTime = inst.trenchBladeDebuffTime - dt
	inst.dropSparkDebuffTime = inst.dropSparkDebuffTime - dt
	inst.relicDebuffTime = inst.relicDebuffTime - dt
	
	--DropSpark Stuff
	if inst.dropSparkDebuffTime <= 0 then
		inst.dropSparkDebuffTime = 0
		if inst.components.health:IsHurt() == false then
			local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if equipped ~= nil then
				if equipped.prefab == "skweaponshovelbladedropspark" then
					equipped.components.weapon.attackrange = equipped.normalRangedRange --Make Range
					equipped.components.inventoryitem.atlasname = "images/inventoryimages/skweaponshovelbladedropsparkready.xml"
					equipped.components.inventoryitem:ChangeImageName("skweaponshovelbladedropsparkready")
				end
			end
		end
	else
		local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equipped ~= nil then
			if equipped.components.weapon.attackrange ~= equipped.normalMeleeRange then
				equipped.components.weapon.attackrange = equipped.normalMeleeRange
				equipped.components.inventoryitem.atlasname = "images/inventoryimages/skweaponshovelbladedropspark.xml"
				equipped.components.inventoryitem:ChangeImageName("skweaponshovelbladedropspark")
			end
		end
	end
	
	--Relic Stuff
	if inst.relicDebuffTime <= 0 then
		inst.relicDebuffTime = 0
		local relicEquipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
		if relicEquipped ~= nil then
			relicEquipped.components.inventoryitem.atlasname = "images/inventoryimages/"..relicEquipped.prefab..".xml"
			relicEquipped.components.inventoryitem:ChangeImageName(relicEquipped.prefab)
		end
	else
		local relicEquipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
		if relicEquipped ~= nil then
			relicEquipped.components.inventoryitem.atlasname = "images/inventoryimages/"..relicEquipped.prefab.."locked.xml"
			relicEquipped.components.inventoryitem:ChangeImageName(relicEquipped.prefab.."locked")
		end
	end
		
	--TrenchBlade Stuff
	if inst.trenchBladeComboBuilder > 0 and inst.trenchBladeComboTime <=0 and inst.trenchBladeDebuffTime <= 0 then
		inst.trenchBladeComboBuilder = 0
		inst.trenchBladeComboTime = 0
		inst.trenchBladeDebuffTime = 0
		--inst.components.talker:Say("Combo Lost")
		
	elseif inst.trenchBladeComboBuilder == 0 and inst.trenchBladeComboTime <=0 and inst.trenchBladeDebuffTime <= 0 and inst.dropSparkDebuffTime <=0 and inst.relicDebuffTime <=0 then
			inst.trenchBladeComboTime = 0
			inst.trenchBladeDebuffTime = 0
		if inst.trenchBladeClock_Task ~= nil then
			inst.trenchBladeClock_Task:Cancel()
			inst.trenchBladeClock_Task = nil
		end
		--inst.components.talker:Say("Dig Cooldown Dismiss")
	--else
	end
end

local function onlongupdate(inst, dt)
    inst.trenchBladeComboTime = math.max(0, inst.trenchBladeComboTime - dt)
	inst.trenchBladeDebuffTime = math.max(0, inst.trenchBladeDebuffTime - dt)
	inst.dropSparkDebuffTime = math.max(0, inst.dropSparkDebuffTime - dt)
	inst.relicDebuffTime = math.max(0, inst.relicDebuffTime - dt)
end

local function startovercharge(inst, duration)
	if duration == 11 then
		inst.trenchBladeDebuffTime = duration
		--inst.components.talker:Say("Dig Cooldown Active")
	elseif duration == 7 then
		inst.trenchBladeComboTime = duration
		--inst.components.talker:Say("Combo Enguaged")
	elseif duration == 9 then
		inst.dropSparkDebuffTime = duration
	elseif duration == 5 then
		inst.relicDebuffTime = duration
	end
	
	if inst.trenchBladeClock_Task == nil then
        inst.trenchBladeClock_Task = inst:DoPeriodicTask(1, onupdate, nil, 1)
        onupdate(inst, 0)
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

local function onload(inst, data)
	if data ~= nil and data.trenchBladeComboTime ~= nil then
        inst.trenchBladeComboTime = data.trenchBladeComboTime
    end
    if data ~= nil and data.trenchBladeDebuffTime ~= nil then
        inst.trenchBladeDebuffTime = data.trenchBladeDebuffTime
    end
	if data ~= nil and data.relicDebuffTime ~= nil then
        inst.relicDebuffTime = data.relicDebuffTime
    end
	startovercharge(inst, data.relicDebuffTime)
end

local function onsave(inst, data)
	data.level = inst.level > 0 and inst.level or nil
	data.mealTicket = inst.mealTicket > 0 and inst.mealTicket or nil
	data.manaPotion = inst.manaPotion > 0 and inst.manaPotion or nil
	
	data.trenchBladeComboTime = inst.trenchBladeComboTime > 0 and inst.trenchBladeComboTime or nil
	data.trenchBladeDebuffTime = inst.trenchBladeDebuffTime > 0 and inst.trenchBladeDebuffTime or nil
	data.dropSparkDebuffTime = inst.dropSparkDebuffTime > 0 and inst.dropSparkDebuffTime or nil
	data.relicDebuffTime = inst.relicDebuffTime > 0 and inst.relicDebuffTime or nil
end

local function onhealthupdate(inst, amount, overtime, cause, ignore_invincible, afflicter)
	local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if equipped ~= nil then
		if equipped.prefab == "skweaponshovelbladedropspark" then
			if inst.components.health:IsHurt() == false and inst.dropSparkDebuffTime <= 0 then
				equipped.components.weapon.attackrange = equipped.normalRangedRange --Makes range
				equipped.components.inventoryitem.atlasname = "images/inventoryimages/skweaponshovelbladedropsparkready.xml"
				equipped.components.inventoryitem:ChangeImageName("skweaponshovelbladedropsparkready")
			else
				equipped.components.weapon.attackrange = equipped.normalMeleeRange --Makes melee
				equipped.components.inventoryitem.atlasname = "images/inventoryimages/skweaponshovelbladedropspark.xml"
				equipped.components.inventoryitem:ChangeImageName("skweaponshovelbladedropspark")
			end
		end
	end
end

--Set the relic cooldown timer
local function onrelic(inst)
	startovercharge(inst, 5)
end

local function onworked(inst, data)
	if inst.trenchBladeDebuffTime <= 0 then
		if data.target and data.target.components.workable and data.target.components.workable.action == ACTIONS.DIG then
			local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if equipped ~= nil then
				if equipped.prefab == "skweaponshovelbladetrenchblade" or equipped.prefab == "skweaponshovelbladedropspark" then
					
					--Gen trenchBlade Relic and Loot
					local trenchBladeRelicFinder = equipped.trenchBladeRelicFind
					if math.random() <= trenchBladeRelicFinder then
						local relicGen = randomRelicGen() --Finds a random Relic
						if relicGen ~= nil then
							createRelic(relicGen, data.target) --Creates the Relic
						end
					elseif math.random() <= trenchBladeRelicFinder then
						local lootGen = randomLootGen() --Finds a random Loot
						if lootGen ~= nil then
							createRelic(lootGen, data.target) --Creates the Loot
						end
					end
					
					--trenchBlade Debuff
					if inst.trenchBladeComboBuilder == 0 then
						inst.trenchBladeComboBuilder = inst.trenchBladeComboBuilder +1
						startovercharge(inst, 7)
					else
						inst.trenchBladeComboBuilder = inst.trenchBladeComboBuilder +1
						inst.trenchBladeComboTime = 7
						if inst.trenchBladeComboBuilder >= 5 then
							inst.trenchBladeComboBuilder = 0
							inst.trenchBladeComboTime = 0
							startovercharge(inst, 11)	
						end
					end
				end
			end
		end
	end
end

local function onattack(inst, data, weapon, pro)
	if inst.components.health:IsHurt() == false and inst.dropSparkDebuffTime <= 0 then
		local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equipped ~= nil then
			if equipped.prefab == "skweaponshovelbladedropspark" then
				createDropSparkProjectile(inst, data.target, equipped)
				startovercharge(inst, 9)
			end
		end
	end
end

local function onrespawned(inst)
	if inst.components.inventory.equipslots[EQUIPSLOTS.BODY] ~= nil then
		inst.AnimState:SetBuild(inst.components.inventory.equipslots[EQUIPSLOTS.BODY].armorName)
		inst.components.locomotor.walkspeed = (TUNING.WILSON_WALK_SPEED * inst.components.inventory.equipslots[EQUIPSLOTS.BODY].armorMovement)
		inst.components.locomotor.runspeed = (TUNING.WILSON_RUN_SPEED * inst.components.inventory.equipslots[EQUIPSLOTS.BODY].armorMovement)
		--Special Gold Glow
		if inst.components.inventory.equipslots[EQUIPSLOTS.BODY].prefab == "skarmorornateplate" then
			inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
		end
	end
end

--local function ondeath(inst)
	
--end

local function ondeathkill(inst, deadthing)
	inst.components.sanity:DoDelta(5) --ConjurersCoat Perk: Gives sanity back for killing things
	
	--Don't need Meal Tickets and Mana Potions removed on death
    --if inst.level > 0 then
        --inst.level = 0
        --applyupgrades(inst)
    --end
end

-- This initializes for both clients and the host
local common_postinit = function(inst)

	--Relic Key
	inst:AddComponent("relickeyhandler")
    inst:ListenForEvent("relickeypressed", OnRelicKeyPressed)
	
	-- choose which sounds this character will play
	inst.soundsname = "wolfgang" --Need Shovel Knight Beeps--

	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "winston.tex" )
	
	--Creates Starting Armor for Shovel Knight
	inst._OnNewSpawn = inst.OnNewSpawn
    inst.OnNewSpawn = function()
		if inst.components.inventory ~= nil then
			inst.components.inventory.ignoresound = true
			local itemArmor = SpawnPrefab("skarmorstalwartplate")
			inst.components.inventory.activeitem = itemArmor
			inst.components.inventory:EquipActiveItem()
			inst.components.inventory:SetActiveItem(nil)
			inst.components.inventory.ignoresound = false
		end
	end
end

-- This initializes for the host only
local master_postinit = function(inst)
	--Personal Recipes
	inst:AddTag("skitemtemplate_builder")
	inst:AddTag("skitemmealticket_builder")
	inst:AddTag("skitemmanapotion_builder")
	inst:AddTag("skweaponshovelbladechargehandle_builder")
	inst:AddTag("skweaponshovelbladetrenchblade_builder")
	inst:AddTag("skweaponshovelbladedropspark_builder")
	inst:AddTag("skarmorfinalguard_builder")
	inst:AddTag("skarmorconjurerscoat_builder")
	inst:AddTag("skarmordynamomail_builder")
	inst:AddTag("skarmormailofmomentum_builder")
	inst:AddTag("skarmorornateplate_builder")
	
	--Personal Reading
	inst:AddComponent("reader")
	
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
	inst.normalAttackSpeed = inst.components.combat.min_attack_period --for ChargeHandle anim
	inst.components.sanity.night_drain_mult = 1
	inst.components.eater:SetOnEatFn(oneat)
	
	--TrenchBlade Combo and timer
	inst.trenchBladeComboBuilder = 0
	inst.trenchBladeComboTime = 0
	inst.trenchBladeDebuffTime = 0
	inst.trenchBladeClock_Task = nil
	
	--DropSpark timer
	inst.dropSparkDebuffTime = 0
	
	--Relic timer
	inst.relicDebuffTime = 0
	
	--Troupple Chalice Buffs
	inst.trouppleChaliceBuff = nil
	
	inst.OnLongUpdate = onlongupdate
	inst.OnSave = onsave
	inst.OnLoad = onload
	inst.OnPreLoad = onpreload
	
	inst:ListenForEvent("healthdelta", onhealthupdate)
	inst:ListenForEvent("ms_respawnedfromghost", onrespawned)
	inst:ListenForEvent("activateresurrection", onrespawned)
	--inst:ListenForEvent("death", ondeath)
	inst:ListenForEvent("working", onworked)
	inst:ListenForEvent("onhitother", onattack)
	inst:ListenForEvent("onmissother", onattack)
	inst:ListenForEvent("castrelic", onrelic)
	
	--Used when killing things
	inst._onplayerkillthing = function(player, data)
		ondeathkill(inst, data.victim)
    end
	
	--Locks the BODY Slot for only Shovel Knight armor to be swapable.
	local old_Unequip = inst.components.inventory.Unequip
	inst.components.inventory.Unequip = function(self, equipslot)
		if equipslot == EQUIPSLOTS.BODY then
			return false
		end
		return old_Unequip(self, equipslot)
	end
	
	--Limits Shovel Knight to special Armor and Relic slots
	local old_Equip = inst.components.inventory.Equip
    inst.components.inventory.Equip = function(self, item, old_to_active)
	
		--Checks to see if special armor is present
		if item.components.equippable.equipslot == EQUIPSLOTS.BODY then
			if item.prefab == "skarmorstalwartplate" or item.prefab == "skarmorfinalguard" or item.prefab == "skarmorconjurerscoat"
				or item.prefab == "skarmordynamomail" or item.prefab == "skarmormailofmomentum" or item.prefab == "skarmorornateplate" then
					
					--To restore Equippable for all armors
					local itemE = self.equipslots[EQUIPSLOTS.BODY]
					if itemE ~= nil then
						if itemE.prefab == "skarmorstalwartplate" or itemE.prefab == "skarmorfinalguard" or itemE.prefab == "skarmorconjurerscoat"
							or itemE.prefab == "skarmordynamomail" or itemE.prefab == "skarmormailofmomentum" or itemE.prefab == "skarmorornateplate" then
							
							--Special Armor Perk Removal armorMovement
							self.inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED
							self.inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
							
							--Spcial Armor Perk Removal for Final Guard
							if itemE.prefab == "skarmorfinalguard" then
								itemE.components.container:Close(self.inst)
								
								local itemEOld = itemE
								itemE = SpawnPrefab(itemE.prefab)
								self.equipslots[EQUIPSLOTS.BODY] = itemE
								
								for k, v in pairs(itemEOld.components.container.slots) do
									if v and v.prefab ~= nil then
										itemE.components.container:GiveItem(SpawnPrefab(v.prefab), k)
									end
								end
							end
							
							--Special Armor Perk Removal for ConjurersCoat
							if itemE.prefab == "skarmorconjurerscoat" then
								local ownerSanity = self.inst.components.sanity.current
								local ownerSanityMax = (self.inst.manaPotion*10)+120
								self.inst.components.sanity:SetMax((self.inst.manaPotion*10)+120)
								self.inst.components.sanity:DoDelta(ownerSanity - ownerSanityMax)
								self.inst:RemoveEventCallback("killed", self.inst._onplayerkillthing, self.inst)
							end
							
							--Special Armor Perk Removal for MailofMomentum
							if itemE.prefab == "skarmormailofmomentum" then
								self.inst:AddComponent("pinnable")
							end
							
							--Special Armor Perk Removal for OrnatePlate
							if itemE.prefab == "skarmorornateplate" then
								self.inst.AnimState:ClearBloomEffectHandle()
								if itemE.armorGlitter ~= nil then
									itemE.armorGlitter:Remove()
									itemE.armorGlitter = nil
								end
							end
							
							--Resets all the armor besides final guard
							if itemE.prefab ~= "skarmorfinalguard" then
								itemE = SpawnPrefab(itemE.prefab)
								self.equipslots[EQUIPSLOTS.BODY] = itemE
							end
						end
					end
				return old_Equip(self, item, old_to_active)
			else
			
			--Stops other BODY Slot Armor
			self:RemoveItem(item, true)
			if self:IsFull() then
				if not self.activeitem and not TheInput:ControllerAttached() then
					item.components.inventoryitem:OnPutInInventory(self.inst)
					self:SetActiveItem(item)
				else
					self:DropItem(inst, true, true)
					self:SetActiveItem(nil)
				end
			else
				self:RemoveItem(item, true)
				self.silentfull = true
				self:GiveItem(item)
				self.silentfull = false
				self:SetActiveItem(nil)
			end
			self.inst.components.talker:Say("My mighty armor is mightier")
			return false
			end
		end
		
		--Stops Hats from being equipped -Disabled till Relics come into play
		if item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
			if item.prefab == "skrelicfishingrod" or item.prefab == "skrelictroupplechalice"
				or item.prefab == "skrelictroupplechalicered" or item.prefab == "skrelictroupplechaliceblue" or item.prefab == "skrelictroupplechaliceyellow" then
				
				return old_Equip(self, item, old_to_active)
			else
			
			--Stops other Head Slot Hats
			self:RemoveItem(item, true)
			if self:IsFull() then
				if not self.activeitem and not TheInput:ControllerAttached() then
					item.components.inventoryitem:OnPutInInventory(self.inst)
					self:SetActiveItem(item)
				else
					self:DropItem(inst, true, true)
					self:SetActiveItem(nil)
				end
			else
				self:RemoveItem(item, true)
				self.silentfull = true
				self:GiveItem(item)
				self.silentfull = false
				self:SetActiveItem(nil)
			end
			self.inst.components.talker:Say("This is not a Relic!")
			return false
			end
		end
        return old_Equip(self, item, old_to_active)
    end
	
	local old_GetAttacked = inst.components.combat.GetAttacked 
		inst.components.combat.GetAttacked = function(self,attacker, damage, weapon)
		damage = 15
		if inst.components.inventory.equipslots[EQUIPSLOTS.BODY] ~= nil then
			local item = inst.components.inventory.equipslots[EQUIPSLOTS.BODY]
			if item.prefab == "skarmorstalwartplate" or item.prefab == "skarmorfinalguard" or item.prefab == "skarmorconjurerscoat"
				or item.prefab == "skarmordynamomail" or item.prefab == "skarmormailofmomentum" or item.prefab == "skarmorornateplate" then
				damage = item.armorProtection --Saved on the Shovel Knight Armor
				
				--Apply Non-Freeze and Non-Sleep MailofMomentum Armor Perk
				if item.prefab == "skarmormailofmomentum" then
					if inst.components.freezable then
						inst.components.freezable:Reset()
					end
					if inst.components.grogginess then
						inst.componets.grogginess:ComeTo()
					end
				end
			end
		end
		return old_GetAttacked(self,attacker, damage, weapon)
	end
end

return MakePlayerCharacter("winston", prefabs, assets, common_postinit, master_postinit, start_inv)

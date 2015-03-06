local assets=
{
    Asset("ANIM", "anim/skitemtroupplefishking.zip"),
	Asset("ANIM", "anim/skitemtroupplefishkinglay.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skitemtroupplefish.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemtroupplefish.tex"),
}

prefabs = {
}

local quoteList = {
	"red", "blue", "yellow",
}

--Random ichor Loot list
local ichorLootList = {
	"red", "blue", "yellow",
}

local function randomQuoteGen()
	return quoteList[math.random(#quoteList)]
end

local function randomIchorLootGen()
	return ichorLootList[math.random(#ichorLootList)]
end

local function trouppleKingShake(inst, shakeTime)
	if inst.kingHolder.prefab ~= nil then
		for i, v in ipairs(AllPlayers) do
			v:ShakeCamera(CAMERASHAKE.SIDE, shakeTime, .05, .1, inst.kingHolder, 40)
		end
	end
end

local function splashBigFx(inst)
	local fx = SpawnPrefab("splash")
    local pos = inst:GetPosition()
    fx.Transform:SetPosition(pos.x, pos.y, pos.z)
	fx.Transform:SetScale(3, 3, 3)
	inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
end

local function randomSplashFx(inst)
	local fx = SpawnPrefab("splash")
    local pos = inst.components.fishingrod.target:GetPosition()
	
	local a = math.random()*math.pi*2
	local x = math.sin(a)*1.4+math.random()*0.3
	local z = math.cos(a)*1.6+math.random()*0.3
	
	fx.Transform:SetPosition(pos.x + x, pos.y + 0, pos.z + z)
	inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
end

local function splashFx(inst)
	local fx = SpawnPrefab("splash")
    local pos = inst:GetPosition()
    fx.Transform:SetPosition(pos.x, pos.y, pos.z)
	inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
end

local function ontalk(inst, script)
	splashBigFx(inst)
end

local function clearTrouppleChaliceData(inst)
	inst.catcherChaliceSlot = nil
	inst.catcherTrouppleChalice = nil
	inst.finalguard = ""
	inst.finalguardChaliceSlot = nil
	inst.finalguardTrouppleChalice = nil
	inst.eESM = ""
	inst.eESMChaliceSlot = nil
	inst.eESMTrouppleChalice = nil
	inst.activeitem = ""
	inst.activeitemChalice = nil
	inst.relicChalice = nil
	inst.relicLocation = nil
	inst.ichorColor = "red" --Default
end

local function createIchorProjectile(inst, target)
	inst.ichorColor = randomIchorLootGen()
	local ichorShot = CreateEntity()
	ichorShot.name = "Ichor"
	ichorShot.entity:AddTransform()
	ichorShot:AddComponent("weapon")
	ichorShot.components.weapon:SetDamage(TUNING.SPAT_PHLEGM_DAMAGE)
	ichorShot.components.weapon:SetRange(TUNING.SPAT_PHLEGM_ATTACKRANGE)
	ichorShot.components.weapon:SetProjectile("spat_bomb")
	ichorShot:AddComponent("inventoryitem")
	ichorShot.persists = false
	ichorShot.components.inventoryitem:SetOnDroppedFn(inst.Remove)
	
	local proj = SpawnPrefab("skfxichor_"..inst.ichorColor)--Name of the projectile
	if proj then
		if proj.components.projectile then
			proj.Transform:SetScale(3, 3, 3)
			proj.owner = inst --Saves player to Projectile
			proj.Transform:SetPosition(inst.Transform:GetWorldPosition())
			proj.components.projectile:Throw(ichorShot, target, inst)
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spat/spit")
		end
	end
end

local function getPlayerChalice(inst, itemName, owner)
	--Checks if Active Item
    if owner.components.inventory.activeitem and owner.components.inventory.activeitem.prefab == itemName then
        inst.activeitemChalice = owner.components.inventory.activeitem
    end
	--Checks if Troupple Chalice is in Relic Slot
	if owner.components.inventory.equipslots[EQUIPSLOTS.HEAD] ~= nil then
		local relicItem = owner.components.inventory.equipslots[EQUIPSLOTS.HEAD]
		if relicItem.prefab == itemName then
			inst.relicChalice = relicItem
		end
	end
	--Checks for Final Guard
	if owner.components.inventory.equipslots[EQUIPSLOTS.BODY] ~= nil then
		local containerItem = owner.components.inventory.equipslots[EQUIPSLOTS.BODY]
		if containerItem.prefab == "skarmorfinalguard" then
			inst.finalguard = containerItem
			for k, v in pairs(inst.finalguard.components.container.slots) do
				if v and v.prefab == itemName then
					inst.finalguardChaliceSlot = k
					inst.finalguardTrouppleChalice = v
					break
				end
			end
		end
	end
	--Checks Main inventory
	for k, v in pairs(owner.components.inventory.itemslots) do
        if v and v.prefab == itemName then
                inst.catcherChaliceSlot = k
				inst.catcherTrouppleChalice = v
				break
        end
    end
	--Checks for Extra Equip Slots Mod Compatiblity
	if owner.components.inventory.equipslots[EQUIPSLOTS.BACK] ~= nil then
		local containerItem = owner.components.inventory.equipslots[EQUIPSLOTS.BACK]
		inst.eESM = containerItem
		for k, v in pairs(inst.eESM.components.container.slots) do
			if v and v.prefab == itemName then
				inst.eESMChaliceSlot = k
				inst.eESMTrouppleChalice = v
				break
			end
		end
	end
end

local function getPlayerChalicePre(inst, itemName, owner)
	local chaliceCount = 0
	--Checks if Active Item
    if owner.components.inventory.activeitem and owner.components.inventory.activeitem.prefab == itemName then
        chaliceCount = chaliceCount + 1
    end
	--Checks if Troupple Chalice is in Relic Slot
	if owner.components.inventory.equipslots[EQUIPSLOTS.HEAD] ~= nil then
		local relicItem = owner.components.inventory.equipslots[EQUIPSLOTS.HEAD]
		if relicItem.prefab == itemName then
			chaliceCount = chaliceCount + 1
		end
	end
	--Checks for Final Guard
	if owner.components.inventory.equipslots[EQUIPSLOTS.BODY] ~= nil then
		local containerItem = owner.components.inventory.equipslots[EQUIPSLOTS.BODY]
		if containerItem.prefab == "skarmorfinalguard" then
			inst.finalguard = containerItem
			for k, v in pairs(inst.finalguard.components.container.slots) do
				if v and v.prefab == itemName then
					chaliceCount = chaliceCount + 1
					--break
				end
			end
		end
	end
	--Checks Main inventory
	for k, v in pairs(owner.components.inventory.itemslots) do
        if v and v.prefab == itemName then
                chaliceCount = chaliceCount + 1
				--break
        end
    end
	--Checks for Extra Equip Slots Mod Compatiblity
	if owner.components.inventory.equipslots[EQUIPSLOTS.BACK] ~= nil then
		local containerItem = owner.components.inventory.equipslots[EQUIPSLOTS.BACK]
		inst.eESM = containerItem
		for k, v in pairs(inst.eESM.components.container.slots) do
			if v and v.prefab == itemName then
				chaliceCount = chaliceCount + 1
				--break
			end
		end
	end
	return chaliceCount
end

local function gounderwater(inst)
	splashBigFx(inst)
	if inst.kingHolder.plantKeeper.prefab ~= nil then
		inst.kingHolder.plantKeeper:PushEvent("splashWater")
	end
	if inst.kingHolder.prefab ~= nil then
		inst.kingHolder.kingIchorReset = inst.kingHolder.kingIchorReset - 1
	end
	trouppleKingShake(inst, 4)
	inst:Remove()
end

local function gounderwaterpre(inst)
	inst.AnimState:PlayAnimation("idle", true)
	inst:DoTaskInTime(1, gounderwater)
end

local function fishybehaviorcold(inst)
	inst.components.talker:Say("Winter is coming, all citizens back under the water!")
	inst:DoTaskInTime(3, gounderwaterpre)
end

local function fishybehaviorfarewell(inst)
	inst.components.talker:Say("Back to the depths I go!")
	inst:DoTaskInTime(3, gounderwaterpre)
end	

local function fishybehaviorcomebacktomorrow(inst)
	if inst.kingHolder.kingIchorReset == 1 then
		inst.components.talker:Say("Come back tomorrow Moral for another Ichor blessing!")
	else
		inst.components.talker:Say("Come back in "..inst.kingHolder.kingIchorReset.." days Moral for another Ichor blessing!")
	end
end

local function fishybehaviorcomeagain(inst)
	inst.components.talker:Say("Come back with another Troupple Chalice Moral for an Ichor blessing!")
end

local function fishybehaviorquotes(inst)
	if inst.target.prefab == "winston" then
		if inst.kingHolder ~= nil then
			if math.random() <= .35 then
				if inst.kingHolder.kingIchor > 0 then
					fishybehaviorcomeagain(inst)
					return
				else
					fishybehaviorcomebacktomorrow(inst)
					return
				end
			end
		end
	end
	inst.components.talker:Say(randomQuoteGen())
end

local function fishybehaviorangry(inst)
	inst.components.talker:Say("What do you think you're doing mortal!?")
	trouppleKingShake(inst, 4)
	if inst.kingHolder.plantKeeper.prefab ~= nil then
		inst.kingHolder.plantKeeper:PushEvent("splashWater")
	end
end

local function fishybehaviorgreet(inst)
	if inst.kingHolder.prefab ~= nil then --Stops the odd first load loop
		inst.AnimState:PlayAnimation("idle")
		inst.entity:Show()
		inst.components.talker:Say("I am the great Troupple King!")
		if inst.kingHolder.plantKeeper.prefab ~= nil then
			inst.kingHolder.plantKeeper:PushEvent("splashWater")
		end
	end
end

local function onfishedup(inst)
	trouppleKingShake(inst, 4)
	splashBigFx(inst)
	inst:DoTaskInTime(2, fishybehaviorgreet)
end

--============================
local function fishybehaviorfillchalice3(inst)
	inst.AnimState:SetBank("fish")
	inst.AnimState:SetBuild("skitemtroupplefishking")
    inst.AnimState:PlayAnimation("idle")
	trouppleKingShake(inst, 3)
	if inst.relicLocation == 1 then
		inst.activeitemChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.target.components.inventory:SetActiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor))
	end
	if inst.relicLocation == 2 then
		inst.relicChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.target.components.inventory:Equip(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor))
	end
	if inst.relicLocation == 3 then
		inst.finalguardTrouppleChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.finalguard.components.container:GiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor), inst.finalguardChaliceSlot)
	end
	if inst.relicLocation == 4 then
		inst.catcherTrouppleChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.target.components.inventory:GiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor), inst.catcherChaliceSlot)
	end
	if inst.relicLocation == 5 then
		inst.eESMTrouppleChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.eESM.components.container:GiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor), inst.eESMChaliceSlot)
	end
	--Clear stuff
	clearTrouppleChaliceData(inst)
	inst.chaliceCount = inst.chaliceCount - 1
	inst.kingHolder.kingIchor = inst.kingHolder.kingIchor - 1
	inst.isBusy = false
	inst:DoTaskInTime(1, fishybehaviorcomebacktomorrow)
end

local function fishybehaviorspitichor3(inst)
	inst.AnimState:SetBank("fish")
	inst.AnimState:SetBuild("skitemtroupplefishkinglay")
    inst.AnimState:PlayAnimation("dead", true)
	splashFx(inst)
	createIchorProjectile(inst, inst.target)
	inst:DoTaskInTime(0.5, fishybehaviorfillchalice3)
end

local function fishybehaviorinspect3(inst)
	--Check for Chalice
	getPlayerChalice(inst, "skrelictroupplechalice", inst.target)
	
	--For While active Item
	if inst.activeitemChalice ~= nil then
		inst.relicLocation = 1
		inst:DoTaskInTime(0.5, fishybehaviorspitichor3)
	--For Troupple Chalice in Relic Slot
	elseif inst.relicChalice ~= nil then
		inst.relicLocation = 2
		inst:DoTaskInTime(0.5, fishybehaviorspitichor3)
	--For Final Guard
	elseif inst.finalguardTrouppleChalice ~= nil then
		inst.relicLocation = 3
		inst:DoTaskInTime(0.5, fishybehaviorspitichor3)
	--For Main Inventory
	elseif inst.catcherTrouppleChalice ~= nil then
		inst.relicLocation = 4
		inst:DoTaskInTime(0.5, fishybehaviorspitichor3)
	--For Extra Equip Slots Mod
	elseif
		inst.eESMTrouppleChalice ~= nil then
		inst.relicLocation = 5
		inst:DoTaskInTime(0.5, fishybehaviorspitichor3)
	--Says Farewell
	else
		inst.isBusy = false
	end
end

local function fishybehaviorfillchalice2(inst)
	inst.AnimState:SetBank("fish")
	inst.AnimState:SetBuild("skitemtroupplefishking")
    inst.AnimState:PlayAnimation("idle")
	trouppleKingShake(inst, 3)
	if inst.relicLocation == 1 then
		inst.activeitemChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.target.components.inventory:SetActiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor))
	end
	if inst.relicLocation == 2 then
		inst.relicChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.target.components.inventory:Equip(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor))
	end
	if inst.relicLocation == 3 then
		inst.finalguardTrouppleChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.finalguard.components.container:GiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor), inst.finalguardChaliceSlot)
	end
	if inst.relicLocation == 4 then
		inst.catcherTrouppleChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.target.components.inventory:GiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor), inst.catcherChaliceSlot)
	end
	if inst.relicLocation == 5 then
		inst.eESMTrouppleChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.eESM.components.container:GiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor), inst.eESMChaliceSlot)
	end
	--Clear stuff
	clearTrouppleChaliceData(inst)
	
	inst.chaliceCount = inst.chaliceCount - 1
	inst.kingHolder.kingIchor = inst.kingHolder.kingIchor - 1
	if inst.kingHolder.kingIchor > 0 and inst.chaliceCount > 0 then
		inst:DoTaskInTime(1, fishybehaviorinspect3)
	elseif inst.kingHolder.kingIchor > 0 then
		inst.isBusy = false
		inst:DoTaskInTime(1, fishybehaviorcomeagain)
	else
		inst.isBusy = false
		inst:DoTaskInTime(1, fishybehaviorcomebacktomorrow)
	end
end

local function fishybehaviorspitichor2(inst)
	inst.AnimState:SetBank("fish")
	inst.AnimState:SetBuild("skitemtroupplefishkinglay")
    inst.AnimState:PlayAnimation("dead", true)
	splashFx(inst)
	createIchorProjectile(inst, inst.target)
	inst:DoTaskInTime(0.5, fishybehaviorfillchalice2)
end

local function fishybehaviorinspect2(inst)
	--Check for Chalice
	getPlayerChalice(inst, "skrelictroupplechalice", inst.target)
	
	--For While active Item
	if inst.activeitemChalice ~= nil then
		inst.relicLocation = 1
		inst:DoTaskInTime(0.5, fishybehaviorspitichor2)
	--For Troupple Chalice in Relic Slot
	elseif inst.relicChalice ~= nil then
		inst.relicLocation = 2
		inst:DoTaskInTime(0.5, fishybehaviorspitichor2)
	--For Final Guard
	elseif inst.finalguardTrouppleChalice ~= nil then
		inst.relicLocation = 3
		inst:DoTaskInTime(0.5, fishybehaviorspitichor2)
	--For Main Inventory
	elseif inst.catcherTrouppleChalice ~= nil then
		inst.relicLocation = 4
		inst:DoTaskInTime(0.5, fishybehaviorspitichor2)
	--For Extra Equip Slots Mod
	elseif
		inst.eESMTrouppleChalice ~= nil then
		inst.relicLocation = 5
		inst:DoTaskInTime(0.5, fishybehaviorspitichor2)
	--Says Farewell
	else
		inst.isBusy = false
	end
end

local function fishybehaviorfillchalice(inst)
	inst.AnimState:SetBank("fish")
	inst.AnimState:SetBuild("skitemtroupplefishking")
    inst.AnimState:PlayAnimation("idle")
	trouppleKingShake(inst, 3)
	if inst.relicLocation == 1 then
		inst.activeitemChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.target.components.inventory:SetActiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor))
	end
	if inst.relicLocation == 2 then
		inst.relicChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.target.components.inventory:Equip(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor))
	end
	if inst.relicLocation == 3 then
		inst.finalguardTrouppleChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.finalguard.components.container:GiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor), inst.finalguardChaliceSlot)
	end
	if inst.relicLocation == 4 then
		inst.catcherTrouppleChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.target.components.inventory:GiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor), inst.catcherChaliceSlot)
	end
	if inst.relicLocation == 5 then
		inst.eESMTrouppleChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.eESM.components.container:GiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor), inst.eESMChaliceSlot)
	end
	--Clear stuff
	clearTrouppleChaliceData(inst)
	
	inst.chaliceCount = inst.chaliceCount - 1
	inst.kingHolder.kingIchor = inst.kingHolder.kingIchor - 1
	if inst.kingHolder.kingIchor > 0 and inst.chaliceCount > 0 then
		inst:DoTaskInTime(1, fishybehaviorinspect2)
	elseif inst.kingHolder.kingIchor > 0 then
		inst.isBusy = false
		inst:DoTaskInTime(1, fishybehaviorcomeagain)
	else
		inst.isBusy = false
		inst:DoTaskInTime(1, fishybehaviorcomebacktomorrow)
	end
end

local function fishybehaviorspitichor(inst)
	inst.AnimState:SetBank("fish")
	inst.AnimState:SetBuild("skitemtroupplefishkinglay")
    inst.AnimState:PlayAnimation("dead", true)
	splashFx(inst)
	createIchorProjectile(inst, inst.target)
	inst:DoTaskInTime(0.5, fishybehaviorfillchalice)
end

local function fishybehaviorinspect(inst)
	--Check for Chalice
	getPlayerChalice(inst, "skrelictroupplechalice", inst.target)
	
	--For While active Item
	if inst.activeitemChalice ~= nil then
		inst.relicLocation = 1
		inst:DoTaskInTime(0.5, fishybehaviorspitichor)
	--For Troupple Chalice in Relic Slot
	elseif inst.relicChalice ~= nil then
		inst.relicLocation = 2
		inst:DoTaskInTime(0.5, fishybehaviorspitichor)
	--For Final Guard
	elseif inst.finalguardTrouppleChalice ~= nil then
		inst.relicLocation = 3
		inst:DoTaskInTime(0.5, fishybehaviorspitichor)
	--For Main Inventory
	elseif inst.catcherTrouppleChalice ~= nil then
		inst.relicLocation = 4
		inst:DoTaskInTime(0.5, fishybehaviorspitichor)
	--For Extra Equip Slots Mod
	elseif
		inst.eESMTrouppleChalice ~= nil then
		inst.relicLocation = 5
		inst:DoTaskInTime(0.5, fishybehaviorspitichor)
	--Says Farewell
	else
		inst.isBusy = false
	end
end
--===============================

local function fishybehaviorfillchalicemulti(inst)
	inst.components.talker:Say("That's pronounced Eye-core.")
	inst:DoTaskInTime(3, fishybehaviorinspect)
end

local function fishybehaviorichorcount(inst)
	if inst.lostTarget == false then
		if inst.chaliceCount == 1 then
			inst.components.talker:Say("I can fill it with magical Ichor.")
			inst:DoTaskInTime(3, fishybehaviorfillchalicemulti)
		elseif inst.chaliceCount > inst.kingHolder.kingIchor then
			inst.components.talker:Say("I can fill "..inst.kingHolder.kingIchor.." with magical Ichor.")
			inst:DoTaskInTime(3, fishybehaviorfillchalicemulti)
		else
			inst.components.talker:Say("I can fill all with magical Ichor.")
			inst:DoTaskInTime(3, fishybehaviorfillchalicemulti)
		end
	else
		inst.components.talker:Say("Oh... it seems your to busy for my blessing.?!")
		inst.isBusy = false
	end
end

local function fishybehaviorinspectpre(inst)
	if inst.chaliceCount ~= nil and inst.chaliceCount > 0 then
		if inst.chaliceCount > 1 then
			inst.components.talker:Say("I sense many Troupple Chalices!")
			inst:DoTaskInTime(3, fishybehaviorichorcount)
		else
			inst.components.talker:Say("I sense a Troupple Chalice!")
			inst:DoTaskInTime(3, fishybehaviorichorcount)
		end
	end
end

local function OnIsDay(inst, isday)
    if isday ~= inst.dayspawn then
       inst:DoTaskInTime(3, fishybehaviorfarewell)
    end
end

local function OnSnowLevel(inst, snowlevel, thresh)
	thresh = thresh or .02
	
	if inst.snowThresh ~= nil and inst.snowThresh > snowlevel then
		snowlevel = inst.snowThresh
		inst.snowThresh = nil
	end
	
	if snowlevel > thresh then
		inst:DoTaskInTime(0.5, fishybehaviorcold)
	else
		inst:DoTaskInTime(0.5, onfishedup)
	end
end

local function hasEvent(inst)
	if inst.kingHolder.kingEvent == 1 then
		--inst:AddComponent("workable")
		--inst.components.workable:SetWorkAction(ACTIONS.CHOP)
		--inst.components.workable:SetOnWorkCallback(chop_tree)
		--inst.components.workable:SetOnFinishCallback(chop_down_tree)
		--inst.AnimState:OverrideSymbol("eye", "skstructuretreetroupplefeature", "eye") --Orb thing
	else

	end
end

local function onload(inst, data, newents)
	if inst.kingHolder.prefab ~= nil then
		hasEvent(inst)
	end
	OnSnowLevel(inst, TheWorld.state.snowlevel)
end

local function OnLostTarget(inst)
	inst.lostTarget = true
end

local function OnNewTarget(inst, data)
	if data.target ~= nil then
		if inst.isBusy == false then
			inst.target = data.target
			inst.lostTarget = false
			if inst.target.prefab == "winston" then
				inst.components.talker:Say("Greetings Shovel Knight!")
				if inst.kingHolder ~= nil then
					local chaliceCountTemp = getPlayerChalicePre(inst, "skrelictroupplechalice", inst.target)
					if inst.kingHolder.kingIchor > 0 and chaliceCountTemp > 0 then
						inst.isBusy = true
						inst.chaliceCount = chaliceCountTemp
						inst:DoTaskInTime(3, fishybehaviorinspectpre)
					else
						inst:DoTaskInTime(3, fishybehaviorquotes)
					end
				end
			else
				--Get random quotes
				inst.components.talker:Say("Hello!")
				inst:DoTaskInTime(3, fishybehaviorquotes)
			end
		end
	end
end

local function NormalRetargetFn(inst)
    return FindEntity(inst, 6,
        function(guy)
            if not guy.LightWatcher or guy.LightWatcher:IsInLight() then
                return not guy.components.health:IsDead() and inst.components.combat:CanTarget(guy) and not 
                (guy:HasTag("abigail"))
            end
        end,
        {"player", "_health"} -- see entityreplica.lua
        )
end

local function NormalKeepTargetFn(inst, target)
    --give up on dead guys, or guys in the dark, or werepigs
	--inst.components.talker:Say("Target is "..inst:GetDistanceSqToInst(target))
    return inst.components.combat:CanTarget(target)
			and inst:GetDistanceSqToInst(target) < 45
			and (not target.LightWatcher or target.LightWatcher:IsInLight())
			and not (target.sg and target.sg:HasStateTag("transform") )
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()

	inst.Transform:SetScale(5, 5, 5)
	
	MakeObstaclePhysics(inst, 4.8, .5)
	
	inst:AddTag("largecreature")
	
	anim:SetBank("fish")
    anim:SetBuild("skitemtroupplefishking")
    anim:PlayAnimation("idle")
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
	inst.Physics:SetActive(false)
	inst.build = "skitemtroupplefishking"
	
	inst.kingHolder = ""
	inst.isBusy = false
	inst.frozen = false
	inst.snowThresh = nil
	
	--Needed for finding the Chalice
	inst.catcher = ""
	inst.catcherChaliceSlot = nil
	inst.catcherTrouppleChalice = nil
	inst.finalguard = ""
	inst.finalguardChaliceSlot = nil
	inst.finalguardTrouppleChalice = nil
	inst.eESM = ""
	inst.eESMChaliceSlot = nil
	inst.eESMTrouppleChalice = nil
	inst.activeitem = ""
	inst.activeitemChalice = nil
	inst.relicChalice = nil
	inst.relicLocation = nil
	inst.ichorColor = "red" --Default
	inst.target = nil
	inst.lostTarget = false
	inst.chaliceCount = nil
	
	inst.persists = false
    
	inst:AddComponent("talker")
	inst.components.talker.offset = Vector3(0,-140,0)
	inst.components.talker.ontalk = ontalk
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemtroupplefish.xml"
	inst.components.inventoryitem.imagename = "skitemtroupplefish"
	
	inst:AddComponent("combat")
	inst.components.combat:SetKeepTargetFunction(NormalKeepTargetFn)
	inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
    inst.components.combat:SetTarget(nil)
	
	inst.dayspawn = true
	inst:WatchWorldState("isday", OnIsDay)
	inst:WatchWorldState("snowlevel", OnSnowLevel)
	inst.OnLoad = onload
	
	inst:ListenForEvent("angryking", fishybehaviorangry)
	inst:ListenForEvent("newcombattarget", OnNewTarget)
	inst:ListenForEvent("losttarget", OnLostTarget)
	
	inst:DoTaskInTime(0.2, onload)
	
	MakeHauntableLaunch(inst)
		
    return inst
end

STRINGS.NAMES.SKITEMTROUPPLEFISHKING = "Troupple King"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMTROUPPLEFISHKING = "Ruler of the great Troupple Kingdom!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMTROUPPLEFISHKING = "What a huge looking apple... fish?!"


return  Prefab("common/objects/skitemtroupplefishking", fn, assets, prefabs)
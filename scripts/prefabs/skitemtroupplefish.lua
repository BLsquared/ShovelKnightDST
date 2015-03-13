local assets=
{
    Asset("ANIM", "anim/skitemtroupplefish.zip"),
	Asset("ANIM", "anim/skitemtroupplefishlay.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skitemtroupplefish.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemtroupplefish.tex"),
}

prefabs = {
}

--Random ichor Loot list
local ichorLootList = {
	"red", "blue", "yellow",
}

local function randomIchorLootGen()
	return ichorLootList[math.random(#ichorLootList)]
end

local function splashFx(inst)
	local fx = SpawnPrefab("splash")
    local pos = inst:GetPosition()
    fx.Transform:SetPosition(pos.x, pos.y, pos.z)
	inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
end

local function gounderwater(inst)
	splashFx(inst)
	inst:Remove()
end

local function fishybehaviorfarewell(inst)
	inst.components.talker:Say("Farewell, may you be blessed by the Troupple King!")
	splashFx(inst)
	inst:DoTaskInTime(3, gounderwater)
end

local function createIchorProjectile(inst, target)
	inst.ichorColor = randomIchorLootGen()
	local proj = SpawnPrefab("skfxichor_"..inst.ichorColor)--Name of the projectile
	if proj then
		if proj.components.projectile then
			proj.owner = inst --Saves player to Projectile
			proj.Transform:SetPosition(inst.Transform:GetWorldPosition())
			proj.components.projectile:Throw(inst, target, inst)
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spat/spit")
		end
	end
end

local function getPlayerChalice(inst, itemName, owner)
	
	--Checks if Active Item
    if inst.catcher.components.inventory.activeitem and inst.catcher.components.inventory.activeitem.prefab == itemName then
        inst.activeitemChalice = inst.catcher.components.inventory.activeitem
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

local function fishybehaviorfillchalice(inst)
	inst.AnimState:SetBank("fish")
	inst.AnimState:SetBuild("skitemtroupplefish")
	inst.AnimState:PlayAnimation("idle", true)
	--inst.components.talker:Say("Pthweep...") --Could be the random quotes here
	if inst.relicLocation == 1 then
		inst.activeitemChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.catcher.components.inventory:SetActiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor))
	end
	if inst.relicLocation == 2 then
		inst.relicChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.catcher.components.inventory:Equip(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor))
	end
	if inst.relicLocation == 3 then
		inst.finalguardTrouppleChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.finalguard.components.container:GiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor), inst.finalguardChaliceSlot)
	end
	if inst.relicLocation == 4 then
		inst.catcherTrouppleChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.catcher.components.inventory:GiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor), inst.catcherChaliceSlot)
	end
	if inst.relicLocation == 5 then
		inst.eESMTrouppleChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.eESM.components.container:GiveItem(SpawnPrefab("skrelictroupplechalice"..inst.ichorColor), inst.eESMChaliceSlot)
	end
	inst:DoTaskInTime(1, fishybehaviorfarewell)
end

local function fishybehaviorspitichor(inst)
	inst.AnimState:SetBank("fish")
	inst.AnimState:SetBuild("skitemtroupplefishlay")
	inst.AnimState:PlayAnimation("dead", true)
	splashFx(inst)
	createIchorProjectile(inst, inst.catcher)
	inst:DoTaskInTime(0.5, fishybehaviorfillchalice)
end

local function fishybehaviorinspect(inst)
	
	--Check for Chalice
	getPlayerChalice(inst, "skrelictroupplechalice", inst.catcher)
	
	--For While active Item
	if inst.activeitemChalice ~= nil then
		inst.components.talker:Say("You have an Empty Troupple Chalice!")
		splashFx(inst)
		inst.relicLocation = 1
		inst:DoTaskInTime(3, fishybehaviorspitichor)
	--For Troupple Chalice in Relic Slot
	elseif inst.relicChalice ~= nil then
		inst.components.talker:Say("You have an Empty Troupple Chalice!")
		splashFx(inst)
		inst.relicLocation = 2
		inst:DoTaskInTime(3, fishybehaviorspitichor)
	--For Final Guard
	elseif inst.finalguardTrouppleChalice ~= nil then
		inst.components.talker:Say("You have an Empty Troupple Chalice!")
		splashFx(inst)
		inst.relicLocation = 3
		inst:DoTaskInTime(3, fishybehaviorspitichor)
	--For Main Inventory
	elseif inst.catcherTrouppleChalice ~= nil then
		inst.components.talker:Say("You have an Empty Troupple Chalice!")
		splashFx(inst)
		inst.relicLocation = 4
		inst:DoTaskInTime(3, fishybehaviorspitichor)
	--For Extra Equip Slots Mod
	elseif
		inst.eESMTrouppleChalice ~= nil then
		inst.components.talker:Say("You have an Empty Troupple Chalice!")
		splashFx(inst)
		inst.relicLocation = 5
		inst:DoTaskInTime(3, fishybehaviorspitichor)
	--Says Farewell
	else
		inst.components.talker:Say("You seem to not have an Empty Troupple Chalice!")
		splashFx(inst)
		inst:DoTaskInTime(3, fishybehaviorfarewell)
	end
end

local function fishybehaviorgreet(inst)
	if inst.catcher.prefab ~= nil then --Stops the odd first load loop
		inst.components.talker:Say("Greetings brave Shovel Knight.")
		splashFx(inst)
		inst:DoTaskInTime(3, fishybehaviorinspect)
	end
end


local function onfishedup(inst)
	inst:DoTaskInTime(1, fishybehaviorgreet)
end

local function fn()
 
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()
	
	inst.Transform:SetFourFaced()
	inst.Transform:SetScale(.8, .8, .8)
	
	MakeInventoryPhysics(inst)
	
	anim:SetBank("fish")
    anim:SetBuild("skitemtroupplefish")
    anim:PlayAnimation("idle", true)
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
    
	inst.Physics:SetActive(false)
	inst.build = "skitemtroupplefish"
	
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
	
	inst:AddComponent("talker")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemtroupplefish.xml"
	inst.components.inventoryitem.imagename = "skitemtroupplefish"
     
	inst:AddComponent("inspectable")
	
	inst.OnLoad = gounderwater
	
	inst:DoTaskInTime(1, onfishedup)
	
	MakeHauntableLaunch(inst)
		
    return inst
end


STRINGS.NAMES.SKITEMTROUPPLEFISH = "Troupple Fish"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMTROUPPLEFISH = "A citizen of the great Troupple Kingdom!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMTROUPPLEFISH = "What a strange looking apple... fish?"


return  Prefab("common/inventory/skitemtroupplefish", fn, assets, prefabs)
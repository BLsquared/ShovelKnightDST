local assets=
{
    Asset("ANIM", "anim/skitemtroupplefish.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skitemtroupplefish.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemtroupplefish.tex"),
}

prefabs = {
}

local function gounderwater(inst)
    --inst.AnimState:PlayAnimation("idle")
	
	--Adds a neat splash effect
	local fx = SpawnPrefab("splash")
    local pos = inst:GetPosition()
    fx.Transform:SetPosition(pos.x, pos.y, pos.z)
	inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
	inst:Remove()
end

local function getPlayerChalice(inst, itemName, owner)
	
	--Checks if Active Item
    if inst.catcher.components.inventory.activeitem and inst.catcher.components.inventory.activeitem.prefab == itemName then
        inst.activeitemChalice = inst.catcher.components.inventory.activeitem
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

local function fishybehaviorinspect(inst)
	
	--Check for Chalice
	getPlayerChalice(inst, "log", inst.catcher)
	
	--For While active Item
	if inst.activeitemChalice ~= nil then
		inst.components.talker:Say("You have an Empty Troupple Chalice!")
		inst.activeitemChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.catcher.components.inventory:SetActiveItem(SpawnPrefab("goldnugget"))
		
	--For Final Guard
	elseif inst.finalguardTrouppleChalice ~= nil then
		inst.components.talker:Say("You have an Empty Troupple Chalice!")
		inst.finalguardTrouppleChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.finalguard.components.container:GiveItem(SpawnPrefab("goldnugget"), inst.finalguardChaliceSlot)
		--gounderwater(inst)
		
	--For Main Inventory
	elseif inst.catcherTrouppleChalice ~= nil then
		inst.components.talker:Say("You have an Empty Troupple Chalice!")
		inst.catcherTrouppleChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.catcher.components.inventory:GiveItem(SpawnPrefab("goldnugget"), inst.catcherChaliceSlot)
		--gounderwater(inst)
		
	--For Extra Equip Slots Mod
	elseif
		inst.eESMTrouppleChalice ~= nil then
		inst.components.talker:Say("You have an Empty Troupple Chalice!")
		inst.eESMTrouppleChalice.components.inventoryitem:RemoveFromOwner(true)
		inst.eESM.components.container:GiveItem(SpawnPrefab("goldnugget"), inst.eESMChaliceSlot)
		--gounderwater(inst)
		
	--Goes Back underwater
	else
		gounderwater(inst)
	end
	--inst.SoundEmitter:PlaySound("dontstarve/common/wendy")
	--inst:DoTaskInTime(2, fishybehaviorstill)
end

local function fishybehaviorgreet(inst)
	if inst.catcher.prefab ~= nil then --Stops the odd first load loop
		inst.components.talker:Say("Well hello "..inst.catcher.prefab)
		--inst.SoundEmitter:PlaySound("dontstarve/common/wendy")
		inst:DoTaskInTime(3, fishybehaviorinspect)
	end
end


local function onfishedup(inst)
	--Fish stuff
	inst:DoTaskInTime(1, fishybehaviorgreet)
end

local function fn()
 
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()
	
	inst.Transform:SetFourFaced()
	
	if not TheWorld.ismastersim then
        return inst
    end
	MakeInventoryPhysics(inst)
	
	anim:SetBank("fish")
    anim:SetBuild("skitemtroupplefish")
    anim:PlayAnimation("idle", true)
	
	inst.entity:SetPristine()
	MakeHauntableLaunch(inst)
    
	--inst.Transform:SetScale(4, 4, 4)
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
	
	inst:AddComponent("talker")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemtroupplefish.xml"
	inst.components.inventoryitem.imagename = "skitemtroupplefish"
     
	inst:AddComponent("inspectable")
	
	inst.OnLoad = gounderwater
	
	inst:DoTaskInTime(1, onfishedup)
	
    return inst
end


STRINGS.NAMES.SKITEMTROUPPLEFISH = "Troupple Fish"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMTROUPPLEFISH = "A citizen of the great Troupple Kingdom!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMTROUPPLEFISH = "What a strange looking apple... fish?"


return  Prefab("common/inventory/skitemtroupplefish", fn, assets, prefabs)
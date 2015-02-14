local assets=
{
    Asset("ANIM", "anim/skitemfishingrod.zip"),
    Asset("ANIM", "anim/swap_skitemfishingrod.zip"),
 
    Asset("ATLAS", "images/inventoryimages/skitemfishingrod.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemfishingrod.tex"),
}
prefabs = {
}

--Random vaulable fishLoot list
local fishLootList = {
	"log",
}

local fishRareLootList = {
	"skitemmusicsheet",
}

local function randomFishLootGen()
	return fishLootList[math.random(#fishLootList)]
end

local function randomFishRareLootGen()
	return fishRareLootList[math.random(#fishRareLootList)]
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_skitemfishingrod", "swap_fishingrod")
	owner.AnimState:OverrideSymbol("fishingline", "swap_skitemfishingrod", "fishingline")
	owner.AnimState:OverrideSymbol("FX_fishing", "swap_skitemfishingrod", "FX_fishing")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end
 
local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("fishingline")
    owner.AnimState:ClearOverrideSymbol("FX_fishing")
end

local function onfishholster(inst)
	if inst.fishHolster ~= nil and inst.fishOwner ~= nil then
		inst.fishOwner.components.inventory:Equip(inst.fishHolster)
	end
	inst:Remove()
end

local function onfished(inst)
	local owner = inst.components.inventoryitem.owner
	if math.random() <= inst.fishLootChance then
		local fishLootGen = randomFishLootGen() --Finds a random fishLoot
		if fishLootGen ~= nil then
			owner.components.inventory:DropItem(SpawnPrefab(fishLootGen), true, true)
		end
	elseif math.random() <= inst.fishRareLootChance then
		local fishRareLootGen = randomFishRareLootGen() --Finds a random fishLoot
		if fishRareLootGen ~= nil then
			owner.components.inventory:DropItem(SpawnPrefab(fishRareLootGen), true, true)
		end
	end
	
	--Equip old Hand Item
	if inst.fishHolster ~= nil then
		owner.components.inventory:Equip(inst.fishHolster)
	end
	
    inst.components.inventoryitem:RemoveFromOwner(true)
end

local function fn()

    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()
	
	MakeInventoryPhysics(inst)
     
    anim:SetBank("skitemfishingrod")
    anim:SetBuild("skitemfishingrod")
    anim:PlayAnimation("idle")
	inst.AnimState:SetMultColour(1, 1, 1, 0.6)
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
    MakeHauntableLaunch(inst)
 
	--Fishingrod Stuff
	inst.fishLootChance = 0.4 --40% chance
	inst.fishRareLootChance = 0.1 --10% chance
	inst.fishHolster = nil
	inst.fishOwner = nil
	
	inst:AddTag("show_spoilage")
	
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(20)
    inst.components.weapon:SetAttackCallback(onfishholster)

    inst:AddComponent("fishingrod")
    inst.components.fishingrod:SetWaitTimes(4, 40)
    inst.components.fishingrod:SetStrainTimes(0, 5)
    inst:ListenForEvent("fishingcollect", onfished)

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemfishingrod.xml"
	inst.components.inventoryitem.imagename = "skitemfishingrod"
	inst.components.inventoryitem.cangoincontainer = false
	inst.components.inventoryitem:SetOnDroppedFn(onfishholster)
	
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(50)
	inst.components.perishable:StartPerishing()
	inst.components.perishable:SetOnPerishFn(onfishholster)
	
    return inst
end


STRINGS.NAMES.SKITEMFISHINGROD = "Magical Fishing Rod"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMFISHINGROD = "A fishing rod by with magic!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMFISHINGROD = "It looks primitive."


return  Prefab("common/inventory/skitemfishingrod", fn, assets, prefabs)
local assets =
{
	Asset("ANIM", "anim/skarmorstalwartplate.zip"),
	Asset("ANIM", "anim/swap_skarmorstalwartplate.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skarmorstalwartplate.xml"),
    Asset("IMAGE", "images/inventoryimages/skarmorstalwartplate.tex"),
}
prefabs = {
}

local function buffarmor(inst, owner)
	inst.components.inventoryitem.keepondeath = true
	inst.components.equippable.walkspeedmult = inst.armorMovement
end

local function debuffarmor(inst)
	inst.components.inventoryitem.keepondeath = false
	inst.components.equippable.walkspeedmult = inst.armorMovementDebuff
end

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour") 
end

local function onequip(inst, owner) 
    --owner.AnimState:OverrideSymbol("swap_body", "skarmorstalwartplate", "swap_skarmorstalwartplate") --Don't Need
	owner.AnimState:SetBuild("winston") --Changes winston color
	if owner.prefab == "winston" then
		buffarmor(inst, owner)
		inst:RemoveComponent("equippable")
	else
		owner.components.talker:Say("Ugh... its so heavy!")
	end
    inst:ListenForEvent("blocked", OnBlocked, owner)
end

local function onunequip(inst, owner)
    --owner.AnimState:ClearOverrideSymbol("swap_skarmorstalwartplate") --Don't Need
	owner.AnimState:SetBuild(owner.prefab) --Changes player back
	debuffarmor(inst) --Resets the item back to normal
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
end

local function fn()

    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddTag("irreplaceable")
	inst.entity:SetPristine()
    MakeHauntableLaunch(inst)
	
	MakeInventoryPhysics(inst)
		
    anim:SetBank("skarmorstalwartplate")
    anim:SetBuild("skarmorstalwartplate")
    anim:PlayAnimation("idle")
    
    inst.foleysound = "dontstarve/movement/foley/metalarmour"
	
	--Armor Stats
	inst.armorProtection = 15
	inst.armorMovement = 1
	inst.armorMovementDebuff = 0.2
	
	inst.armorChargeHandleBooster = 0
	inst.armorDropSparkBooster = 0
	
	
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skarmorstalwartplate.xml"
	inst.components.inventoryitem.imagename = "skarmorstalwartplate"
    inst.components.inventoryitem.keepondeath = false --Stops equipped armor from falling off
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.walkspeedmult = inst.armorMovementDebuff
	
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    
	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("winston")
	
    return inst
end


STRINGS.NAMES.SKARMORSTALWARTPLATE = "Stalwart Plate"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKARMORSTALWARTPLATE = "Original armor, simple but study."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKARMORSTALWARTPLATE = "It looks quite heavy."


return Prefab("common/inventory/skarmorstalwartplate", fn, assets, prefabs)
local assets =
{
	Asset("ANIM", "anim/skarmorfinalguard.zip"),
	Asset("ANIM", "anim/swap_skarmorfinalguard.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skarmorfinalguard.xml"),
    Asset("IMAGE", "images/inventoryimages/skarmorfinalguard.tex"),
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
	--owner.AnimState:SetBuild("winston") --Changes winston color NEEDED
	if owner.prefab == "winston" then
		buffarmor(inst, owner)
	else
		owner.components.talker:Say("Ugh... its so heavy!")
	end
    inst:ListenForEvent("blocked", OnBlocked, owner)
end

local function onunequip(inst, owner) 
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
	
	inst.entity:SetPristine()
    MakeHauntableLaunch(inst)
	
	MakeInventoryPhysics(inst)
		
    anim:SetBank("skarmorstalwartplate")
    anim:SetBuild("skarmorfinalguard")
    anim:PlayAnimation("idle")
    
    inst.foleysound = "dontstarve/movement/foley/metalarmour"
	
	--Armor Stats
	inst.armorProtection = 15
	inst.armorMovement = 1.1
	inst.armorMovementDebuff = 0.2
	
	inst.armorChargeHandleBooster = 0
	inst.armorDropSparkBooster = 0
	
	--Special perks: Warmth
	inst:AddComponent("insulator")
	inst.components.insulator.insulation = 120
	
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skarmorfinalguard.xml"
	inst.components.inventoryitem.imagename = "skarmorfinalguard"
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


STRINGS.NAMES.SKARMORFINALGUARD = "Final Guard"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKARMORFINALGUARD = "Great to wear when visiting Polar Knight."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKARMORFINALGUARD = "It looks quite heavy."


return Prefab("common/inventory/skarmorfinalguard", fn, assets, prefabs)
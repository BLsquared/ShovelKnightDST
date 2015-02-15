local assets =
{
	Asset("ANIM", "anim/skarmormailofmomentum.zip"),
	Asset("ANIM", "anim/swap_skarmormailofmomentum.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skarmormailofmomentum.xml"),
    Asset("IMAGE", "images/inventoryimages/skarmormailofmomentum.tex"),
}
prefabs = {
}

local function buffarmor(inst, owner)
	inst.components.inventoryitem.keepondeath = true
	owner.components.locomotor.walkspeed = (TUNING.WILSON_WALK_SPEED * inst.armorMovement)
	owner.components.locomotor.runspeed = (TUNING.WILSON_RUN_SPEED * inst.armorMovement)
	--inst.components.equippable.walkspeedmult = inst.armorMovement
end

local function debuffarmor(inst)
	inst.components.inventoryitem.keepondeath = false
	inst.components.equippable.walkspeedmult = inst.armorMovementDebuff
end

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour") 
end

local function onequip(inst, owner) 
	owner.AnimState:SetBuild("winston_mailofmomentum") --Changes winston color NEEDED
	if owner.prefab == "winston" then
		buffarmor(inst, owner)
		owner:RemoveComponent("pinnable")
		inst:RemoveComponent("equippable")
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
    anim:SetBuild("skarmormailofmomentum")
    anim:PlayAnimation("idle")
    
    inst.foleysound = "dontstarve/movement/foley/metalarmour"
	
	--Armor Stats
	inst.armorProtection = 5
	inst.armorMovement = 0.7
	inst.armorMovementDebuff = 0.2
	
	inst.armorChargeHandleBooster = 0
	inst.armorDropSparkBooster = 0
	
	--Special perks: Can't be slowed (freeze and sleep)
	--Check under winston:old_GetAttacked()
	
	
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skarmormailofmomentum.xml"
	inst.components.inventoryitem.imagename = "skarmormailofmomentum"
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


STRINGS.NAMES.SKARMORMAILOFMOMENTUM = "Mail of Momentum"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKARMORMAILOFMOMENTUM = "Does Black Knight wear this armor?"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKARMORMAILOFMOMENTUM = "It looks quite heavy."


return Prefab("common/inventory/skarmormailofmomentum", fn, assets, prefabs)
local assets =
{
	Asset("ANIM", "anim/skarmordynamomail.zip"),
	Asset("ANIM", "anim/swap_skarmordynamomail.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skarmordynamomail.xml"),
    Asset("IMAGE", "images/inventoryimages/skarmordynamomail.tex"),
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
	owner.AnimState:SetBuild("winston_dynamomail") --Changes winston color
	if owner.prefab == "winston" then
		buffarmor(inst, owner)
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
    anim:SetBuild("skarmordynamomail")
    anim:PlayAnimation("idle")
    
    inst.foleysound = "dontstarve/movement/foley/metalarmour"
	
	--Armor Stats
	inst.armorName = "winston_dynamomail"
	inst.armorProtection = 10
	inst.armorMovement = 1.1
	inst.armorMovementDebuff = 0.2
	
	--Special perks: Charge Handle and Drop Spark damage increase
	--Check under winston:bonusDamageDropSparkPerk() and Shovelblade(s):bonusDamageChargeHandlePerk(attacker) 
	inst.armorChargeHandleBooster = 5
	inst.armorDropSparkBooster = 5
	
	
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skarmordynamomail.xml"
	inst.components.inventoryitem.imagename = "skarmordynamomail"
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


STRINGS.NAMES.SKARMORDYNAMOMAIL = "Dynamo Mail"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKARMORDYNAMOMAIL = "The best defense is a good offense!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKARMORDYNAMOMAIL = "It looks quite heavy."


return Prefab("common/inventory/skarmordynamomail", fn, assets, prefabs)
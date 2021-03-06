local assets =
{
	Asset("ANIM", "anim/skarmorornateplate.zip"),
	Asset("ANIM", "anim/swap_skarmorornateplate.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skarmorornateplate.xml"),
    Asset("IMAGE", "images/inventoryimages/skarmorornateplate.tex"),
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
	owner.AnimState:SetBuild("winston_ornateplate") --Changes winston color
	owner.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	if owner.prefab == "winston" then
		buffarmor(inst, owner)
		
		--Adds armorGlitter
		if inst.armorGlitter == nil then
			inst.armorGlitter = SpawnPrefab("skfxornateplate_glitter")
			--inst.fire.Transform:SetScale(.125, .125, .125)
			local follower = inst.armorGlitter.entity:AddFollower()
			follower:FollowSymbol(owner.GUID, "swap_body", 48, 64, 0)
		end
	
		inst:RemoveComponent("equippable")
	else
		owner.components.talker:Say("Ugh... its so heavy!")
	end
    inst:ListenForEvent("blocked", OnBlocked, owner)
end

local function onunequip(inst, owner) 
	owner.AnimState:SetBuild(owner.prefab) --Changes player back
	owner.AnimState:ClearBloomEffectHandle()
	debuffarmor(inst) --Resets the item back to normal
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
end

local function fn()
    
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()
	
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    anim:SetBank("skarmorstalwartplate")
    anim:SetBuild("skarmorornateplate")
    anim:PlayAnimation("idle")
    
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
    inst.foleysound = "dontstarve/movement/foley/metalarmour"
	
	--Armor Stats
	inst.armorName = "winston_ornateplate"
	inst.armorProtection = 15
	inst.armorMovement = 1.2
	inst.armorMovementDebuff = 0.2
	
	inst.armorChargeHandleBooster = 0
	inst.armorDropSparkBooster = 0
	
	--Special perks: Faster Movement speed and leaves a light trail behind
	--Check under winston:old_Equip
	inst.armorGlitter = nil
	
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skarmorornateplate.xml"
	inst.components.inventoryitem.imagename = "skarmorornateplate"
    inst.components.inventoryitem.keepondeath = false --Stops equipped armor from falling off
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.walkspeedmult = inst.armorMovementDebuff
	
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    
	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("winston")
	
	MakeHauntableLaunch(inst)
		
    return inst
end


STRINGS.NAMES.SKARMORORNATEPLATE = "Ornate Plate"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKARMORORNATEPLATE = "This armor is resplendent! King Knight Approved."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKARMORORNATEPLATE = "It looks quite heavy."


return Prefab("common/inventory/skarmorornateplate", fn, assets, prefabs)
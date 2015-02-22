local assets =
{
	Asset("ANIM", "anim/skarmorconjurerscoat.zip"),
	Asset("ANIM", "anim/swap_skarmorconjurerscoat.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skarmorconjurerscoat.xml"),
    Asset("IMAGE", "images/inventoryimages/skarmorconjurerscoat.tex"),
}
prefabs = {
}

--Allows player to harvest from kills
local function activate(owner)
	owner:ListenForEvent("killed", owner._onplayerkillthing, owner)
end

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
	owner.AnimState:SetBuild("winston_conjurerscoat") --Changes winston color
	if owner.prefab == "winston" then
		buffarmor(inst, owner)
		--Apply Perk
		local ownerSanity = owner.components.sanity.current
		local ownerSanityMax = (owner.manaPotion*10)+120 +inst.armorSanityMaxBooster
		owner.components.sanity:SetMax((owner.manaPotion*10)+120 +inst.armorSanityMaxBooster)
		owner.components.sanity:DoDelta(ownerSanity - ownerSanityMax)
		activate(owner)
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
	
	MakeInventoryPhysics(inst)
		
    anim:SetBank("skarmorstalwartplate")
    anim:SetBuild("skarmorconjurerscoat")
    anim:PlayAnimation("idle")
    
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
    inst.foleysound = "dontstarve/movement/foley/metalarmour"
	
	--Armor Stats
	inst.armorName = "winston_conjurerscoat"
	inst.armorProtection = 20
	inst.armorMovement = 1.1
	inst.armorMovementDebuff = 0.2
	
	inst.armorChargeHandleBooster = 0
	inst.armorDropSparkBooster = 0
	
	--Special perks: Sanity Increase and harvest sanity from kills
	--Check under winston:ondeathkill(inst, deadthing) and winston:old_Equip and manapotion:bonusSanityPerk(reader)
	inst.armorSanityMaxBooster = 50
	
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skarmorconjurerscoat.xml"
	inst.components.inventoryitem.imagename = "skarmorconjurerscoat"
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


STRINGS.NAMES.SKARMORCONJURERSCOAT = "Conjurer's Coat"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKARMORCONJURERSCOAT = "Armor with a touch of magic!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKARMORCONJURERSCOAT = "It looks quite heavy."


return Prefab("common/inventory/skarmorconjurerscoat", fn, assets, prefabs)
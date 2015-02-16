local assets =
{
	Asset("ANIM", "anim/skweaponshovelbladechargehandle.zip"),
	Asset("ANIM", "anim/swap_skweaponshovelbladechargehandle.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skweaponshovelbladechargehandle.xml"),
	Asset("IMAGE", "images/inventoryimages/skweaponshovelbladechargehandle.tex"),
	
	Asset("ATLAS", "images/map_icons/skweaponshovelbladechargehandle.xml"),
	Asset("IMAGE", "images/map_icons/skweaponshovelbladechargehandle.tex"),
}
prefabs = {
}

local nums = {"ONE", "TWO", "THREE", "FOUR" , "FIVE" , "SIX" , "SEVEN" , "EIGHT"}

local function GetEquipQuote(owner)
	local randomQuotePart = nums[math.random(#nums)]
	local randomQuote = "ANNOUNCE_SHOVELBLADE_EQUIP"..randomQuotePart
    return randomQuote
end

--Does chargeHandle fx
local function chargeHandleFx(attacker, target)
	local fx = SpawnPrefab("skfxchargehandle_shatter")
    fx.entity:SetParent(target.entity)
    fx.Transform:SetPosition(0, 0, 0)
end

local function onupdate(inst, dt)
	local owner = inst.components.inventoryitem.owner
	if owner ~= nil then
		inst.chargeHandleComboTime = inst.chargeHandleComboTime - dt
		inst.chargeHandleBuffTime = inst.chargeHandleBuffTime - dt
		
		if inst.chargeHandleComboBuilder > 0 and inst.chargeHandleComboTime <=0 and inst.chargeHandleBuffTime <= 0 then
			inst.chargeHandleComboBuilder = 0
			inst.chargeHandleComboTime = 0
			inst.chargeHandleBuffTime = 0
			if inst.chargeHandleClock_Task ~= nil then
				inst.chargeHandleClock_Task:Cancel()
				inst.chargeHandleClock_Task = nil
			end
			--owner.components.talker:Say("Combo Lost")
			
		elseif inst.chargeHandleComboBuilder == 0 and inst.chargeHandleComboTime <=0 and inst.chargeHandleBuffTime <= 0 then
			inst.chargeHandleComboTime = 0
			inst.chargeHandleBuffTime = 0
			if inst.chargeHandleClock_Task ~= nil then
				inst.chargeHandleClock_Task:Cancel()
				inst.chargeHandleClock_Task = nil
			end
			owner.components.combat:SetAttackPeriod(owner.normalAttackSpeed)
			owner.AnimState:SetHaunted(false)
			--owner.components.talker:Say("Charge Handle Dismiss")
		--else
		end
	end
end

local function onlongupdate(inst, dt)
    inst.chargeHandleComboTime = math.max(0, inst.chargeHandleComboTime - dt)
	inst.chargeHandleBuffTime = math.max(0, inst.chargeHandleBuffTime - dt)
end

local function startovercharge(inst, duration, attacker)
	if duration == 5 then
		inst.chargeHandleBuffTime = duration
		attacker.components.combat:SetAttackPeriod(1)--Slows down the Finisher
		attacker.AnimState:SetHaunted(true)
		attacker.SoundEmitter:PlaySound("winston/characters/winston/chargehandlecharged")
		--attacker.components.talker:Say("Charge Handle Enguaged")
	elseif duration == 7 then
		inst.chargeHandleComboTime = duration
		--attacker.components.talker:Say("Combo Enguaged")
	end
	
	if inst.chargeHandleClock_Task == nil then
        inst.chargeHandleClock_Task = inst:DoPeriodicTask(1, onupdate, nil, 1)
        onupdate(inst, 0)
    end
end

--ChangeHandle Damage Booster
local function bonusDamageChargeHandlePerk(attacker)
	local bonusDamage = 0
	if attacker.components.inventory.equipslots[EQUIPSLOTS.BODY] ~= nil then
		local item = attacker.components.inventory.equipslots[EQUIPSLOTS.BODY]
		if item.prefab == "skarmorstalwartplate" or item.prefab == "skarmorfinalguard" or item.prefab == "skarmorconjurerscoat"
			or item.prefab == "skarmordynamomail" or item.prefab == "skarmormailofmomentum" or item.prefab == "skarmorornateplate" then
			bonusDamage = item.armorChargeHandleBooster --Saved on the Shovel Knight Armor
		end
	end
	return bonusDamage
end

local function onattack(inst, attacker, target)
	if target ~= nil and attacker.prefab == "winston" then
		
		--Does ChargeHandle Abililty
		if inst.chargeHandleBuffTime > 0 then --Apply ChargeHandle Attack
			inst.chargeHandleComboBuilder = 0
			inst.chargeHandleComboTime = 0
			inst.chargeHandleBuffTime = 0
			inst.chargeHandleClock_Task:Cancel()
			inst.chargeHandleClock_Task = nil
			local chargeHandleDamage = 15 + bonusDamageChargeHandlePerk(attacker) --Charge Handle Damage
			attacker.AnimState:SetHaunted(false)
			target.components.combat:GetAttacked(attacker, chargeHandleDamage, inst) --Deals the damage
			attacker.components.combat:SetAttackPeriod(attacker.normalAttackSpeed)
			chargeHandleFx(attacker, target)
			attacker.SoundEmitter:PlaySound("winston/characters/winston/chargehandlerelease")
				
		elseif inst.chargeHandleBuffTime <= 0 then
			if inst.chargeHandleComboBuilder == 0 then
				inst.chargeHandleComboBuilder = inst.chargeHandleComboBuilder +1
				startovercharge(inst, 7, attacker)
			else
				inst.chargeHandleComboBuilder = inst.chargeHandleComboBuilder +1
				inst.chargeHandleComboTime = 7
				if inst.chargeHandleComboBuilder >= 2 then
					inst.chargeHandleComboBuilder = 0
					inst.chargeHandleComboTime = 0
					startovercharge(inst, 5, attacker)	
				end
			end
		end
	end
end

local function onpreload(inst, data)
    if data ~= nil and data.playEquippedSound ~= nil then
        inst.playEquippedSound = data.playEquippedSound
    end
end

local function onload(inst, data)
	if data ~= nil and data.chargeHandleComboTime ~= nil then
        startovercharge(inst, data.chargeHandleComboTime)
    end
    if data ~= nil and data.chargeHandleBuffTime ~= nil then
        startovercharge(inst, data.chargeHandleBuffTime)
    end
end

local function onsave(inst, data)
	data.playEquippedSound = inst.playEquippedSound > 0 and inst.playEquippedSound or nil
end

local function onequip(inst, owner)
		
		--Sets how strong this weapon is
		local shovelbladeDamageWinston = 30 --+15 damage with Charge Handle
		local shovelbladeDamageGeneric = 5
		
		owner.AnimState:OverrideSymbol("swap_object", "swap_skweaponshovelbladechargehandle", "swap_shovel")
		owner.AnimState:Show("ARM_carry") 
		owner.AnimState:Hide("ARM_normal") 
		
		--Makes the shovelblade strong only for Shovel Knight
		if owner.prefab == "winston" then
			inst.components.weapon:SetDamage(shovelbladeDamageWinston)
			
			owner.components.talker:Say(GetString(owner, GetEquipQuote(owner))) --Random Equip Quote
			
			--Plays special shovelblade EquippedSound
			inst.playEquippedSound = inst.playEquippedSound +1
			
			if inst.playEquippedSound == 1 then
				owner.SoundEmitter:PlaySound("winston/characters/winston/shovelbladeequipped")
			end
			if inst.playEquippedSound > 1 then --Stops the sound from player at load in
				inst.playEquippedSound = 0
			end
		end
		
		--Makes the shovelblade weak for other characters
		if owner.prefab ~= "winston" then
			inst.components.weapon:SetDamage(shovelbladeDamageGeneric)
		end
end

local function onunequip(inst, owner)
		inst.playEquippedSound = 0
		
		if owner.prefab == "winston" then
			--Take off buffs
			if inst.chargeHandleBuffTime > 0 then
			owner.AnimState:SetHaunted(false)
			end
			inst.chargeHandleComboBuilder = 0
			inst.chargeHandleComboTime = 0
			inst.chargeHandleBuffTime = 0
			if inst.chargeHandleClock_Task ~= nil then
				inst.chargeHandleClock_Task:Cancel()
				inst.chargeHandleClock_Task = nil
			end
			owner.components.combat:SetAttackPeriod(owner.normalAttackSpeed)
		end
			
		--Sets how strong this weapon is
		local shovelbladeDamageGeneric = 5
	
		owner.AnimState:Hide("ARM_carry") 
		owner.AnimState:Show("ARM_normal") 
		
		--Resets the Shovelblade damage back to normal
		inst.components.weapon:SetDamage(shovelbladeDamageGeneric)
end
	
local function fn(Sim)

	local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
    MakeHauntableLaunch(inst)
	
	inst.MiniMapEntity:SetIcon("skweaponshovelbladechargehandle.tex")

    MakeInventoryPhysics(inst)
	
	inst:AddTag("irreplaceable")

    anim:SetBank("shovel")
    anim:SetBuild("skweaponshovelbladechargehandle")
    anim:PlayAnimation("idle", true)

    --Makes this a Tool with actions
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.DIG)

    --Makes this a Weapon
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(5)
	inst.playEquippedSound = 0
	
	--ChargeHandle Combo and timer
	inst.chargeHandleComboBuilder = 0
	inst.chargeHandleComboTime = 0
	inst.chargeHandleBuffTime = 0
	inst.chargeHandleClock_Task = nil
	
	inst.OnLongUpdate = onlongupdate
	inst.OnSave = onsave
	inst.OnLoad = onload
	inst.OnPreLoad = onpreload
	
	inst.components.weapon:SetAttackCallback(onattack)

	--Makes this a Shovel
    inst:AddInherentAction(ACTIONS.DIG)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/skweaponshovelbladechargehandle.xml"
	inst.components.inventoryitem.imagename = "skweaponshovelbladechargehandle"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("winston")
	
    return inst
end

STRINGS.NAMES.SKWEAPONSHOVELBLADECHARGEHANDLE = "Shovelblade"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKWEAPONSHOVELBLADECHARGEHANDLE = "Charge Handle: Charge attack for a mighty slash!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKWEAPONSHOVELBLADECHARGEHANDLE = "A strange dirt moving tool..."

return Prefab("common/inventory/skweaponshovelbladechargehandle", fn, assets)
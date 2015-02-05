local assets =
{
	Asset("ANIM", "anim/skweaponshovelbladedropspark.zip"),
	Asset("ANIM", "anim/swap_skweaponshovelbladedropspark.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skweaponshovelbladedropspark.xml"),
	Asset("IMAGE", "images/inventoryimages/skweaponshovelbladedropspark.tex"),
	Asset("ATLAS", "images/inventoryimages/skweaponshovelbladedropsparkready.xml"),
	Asset("IMAGE", "images/inventoryimages/skweaponshovelbladedropsparkready.tex"),
	
	Asset("ATLAS", "images/map_icons/skweaponshovelbladedropspark.xml"),
	Asset("IMAGE", "images/map_icons/skweaponshovelbladedropspark.tex"),
}
prefabs = {
}

local function onupdate(inst, dt)
	if inst.owner ~= nil then
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
			--inst.owner.components.talker:Say("Combo Lost")
			
		elseif inst.chargeHandleComboBuilder == 0 and inst.chargeHandleComboTime <=0 and inst.chargeHandleBuffTime <= 0 then
			inst.chargeHandleComboTime = 0
			inst.chargeHandleBuffTime = 0
			if inst.chargeHandleClock_Task ~= nil then
				inst.chargeHandleClock_Task:Cancel()
				inst.chargeHandleClock_Task = nil
			end
			inst.owner.components.combat:SetAttackPeriod(inst.owner.normalAttackSpeed)
			inst.owner.AnimState:SetHaunted(false)
			--inst.owner.components.talker:Say("Charge Handle Dismiss")
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

local function onpreAttack(inst, attacker, target)
	if target ~= nil and attacker.prefab == "winston" then
		if inst.components.weapon.attackrange > (inst.normalRangedRange - inst.normalMeleeRange) and attacker..components.health:IsHurt() == false and attacker.dropSparkDebuffTime <= 0 then
			inst.components.weapon:SetDamage(0)
		else
			inst.components.weapon:SetDamage(30)
		end
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

local function onattacks(inst, attacker, target)
	if target ~= nil and attacker.prefab == "winston" then
		
		--Does ChargeHandle Abililty
		if inst.chargeHandleBuffTime > 0 then --Apply ChargeHandle Attack
			inst.chargeHandleComboBuilder = 0
			inst.chargeHandleComboTime = 0
			inst.chargeHandleBuffTime = 0
			inst.chargeHandleClock_Task:Cancel()
			inst.chargeHandleClock_Task = nil
			local chargeHandleDamage = 45 + bonusDamageChargeHandlePerk(attacker) --Charge Handle Damage
			attacker.AnimState:SetHaunted(false)
			target.components.combat:GetAttacked(attacker, chargeHandleDamage, inst) --Deals the damage
			attacker.components.combat:SetAttackPeriod(attacker.normalAttackSpeed)
			target.components.freezable:SpawnShatterFX()
			attacker.SoundEmitter:PlaySound("winston/characters/winston/chargehandlerelease")
			--target.components.burnable:Ignite(nil, attacker) --Fire for later with flare wand--
				
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
		inst.owner = owner
		
		--Sets how strong this weapon is
		local shovelbladeDamageWinston = 30 --+45 damage with Charge Handle
		local shovelbladeDamageGeneric = 5 --For Non winston Characters
		
		owner.AnimState:OverrideSymbol("swap_object", "swap_skweaponshovelbladedropspark", "swap_shovel")
		owner.AnimState:Show("ARM_carry") 
		owner.AnimState:Hide("ARM_normal") 
		
		--Makes the shovelblade strong only for winston and DropSpark Range
		if owner.prefab == "winston" then
			inst.components.weapon:SetDamage(shovelbladeDamageWinston)
			if owner.components.health:IsHurt() == false and owner.dropSparkDebuffTime <= 0 then
				inst.components.weapon.attackrange = inst.normalRangedRange
				inst.components.inventoryitem.atlasname = "images/inventoryimages/skweaponshovelbladedropsparkready.xml"
				inst.components.inventoryitem:ChangeImageName("skweaponshovelbladedropsparkready")
				
			else
				inst.components.weapon.attackrange = inst.normalMeleeRange
				inst.components.inventoryitem.atlasname = "images/inventoryimages/skweaponshovelbladedropspark.xml"
				inst.components.inventoryitem:ChangeImageName("skweaponshovelbladedropspark")
			end
			
			--Plays special shovelblade EquippedSound
			inst.playEquippedSound = inst.playEquippedSound +1
			owner.components.talker:Say("Lets get shoveling!")
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
		inst.components.weapon.attackrange = inst.normalMeleeRange
		inst.components.inventoryitem.atlasname = "images/inventoryimages/skweaponshovelbladedropspark.xml"
		inst.components.inventoryitem:ChangeImageName("skweaponshovelbladedropspark")
				
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
	
		--Reset Animation
		owner.AnimState:Hide("ARM_carry") 
		owner.AnimState:Show("ARM_normal") 
		
		--Resets the Shovelblade damage back to normal
		inst.components.weapon:SetDamage(shovelbladeDamageGeneric)
		inst.owner = nil
end

local function fn(Sim)
	
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
	
	local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("skweaponshovelbladedropspark.tex")
	
    MakeInventoryPhysics(inst)
	
	inst:AddTag("irreplaceable")

    anim:SetBank("shovel")
    anim:SetBuild("skweaponshovelbladedropspark")
    anim:PlayAnimation("idle", true)

    --Makes this a Tool with actions
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.DIG)
	inst.components.tool:SetAction(ACTIONS.MINE)

    --Makes this a Weapon
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(5)
	inst.playEquippedSound = 0
	
	--ChargeHandle Combo and timer
	inst.owner = nil
	inst.chargeHandleComboBuilder = 0
	inst.chargeHandleComboTime = 0
	inst.chargeHandleBuffTime = 0
	inst.chargeHandleClock_Task = nil
	
	--Trench Blade Relic Chance
	inst.trenchBladeRelicFind = 0.02
	
	--Drop Spark range
	inst.normalMeleeRange = inst.components.weapon.attackrange
	inst.normalRangedRange = 12
	
	inst.components.weapon:OnAttack(onpreAttack) --DropSpark anti-range damage Check
	inst.components.weapon:SetAttackCallback(onattacks) --ChargeHandle Check
	
	inst.OnLongUpdate = onlongupdate
	inst.OnSave = onsave
	inst.OnLoad = onload
	inst.OnPreLoad = onpreload
	
	--Makes this a Shovel
    inst:AddInherentAction(ACTIONS.DIG)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/skweaponshovelbladedropspark.xml"
	inst.components.inventoryitem.imagename = "skweaponshovelbladedropspark"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("winston")
	
    return inst
end

STRINGS.NAMES.SKWEAPONSHOVELBLADEDROPSPARK = "Shovelblade"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKWEAPONSHOVELBLADEDROPSPARK = "Drop Spark: Unleash a skating spark at full health!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKWEAPONSHOVELDROPSPARK = "A strange dirt moving tool..."

return Prefab("common/inventory/skweaponshovelbladedropspark", fn, assets)
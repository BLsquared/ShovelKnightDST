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




	


local function onupdate(inst, dt)
	if inst.owner ~= nil then
		inst.chargeTime = inst.chargeTime - dt
		if inst.chargeTime <= 0 then
			inst.chargeTime = 0
			if inst.charged_task ~= nil then
				inst.charged_task:Cancel()
				inst.charged_task = nil
			end
			--inst.owner.SoundEmitter:KillSound("overcharge_sound")
			--inst.owner.Light:Enable(false)
			--inst.owner.AnimState:SetBloomEffectHandle("")
			inst.owner.components.talker:Say("Charge Handle Dismiss")
		else
			--local rad = 3

			--inst.owner.Light:Enable(true)
			--inst.owner.Light:SetRadius(rad)
		end
	end
end

local function onlongupdate(inst, dt)
    inst.chargeTime = math.max(0, inst.chargeTime - dt)
end

local function startovercharge(inst, duration, attacker)
    inst.chargeTime = duration

    --inst.SoundEmitter:KillSound("overcharge_sound")
    --inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/charged", "overcharge_sound")
    --attacker.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	attacker.components.talker:Say("Charge Handle Enguaged")

    if inst.charged_task == nil then
        inst.charged_task = inst:DoPeriodicTask(1, onupdate, nil, 1)
        onupdate(inst, 0)
    end
end

local function onattack(inst, attacker, target)
	if target ~= nil and attacker.prefab == "winston" then
		
		--Does the special attack
		if inst.chargeTime > 0 then
			--Turn off ChargeHandle Buff
			inst.chargeHandleUpgrade = 0
			inst.chargeTime = 0
			inst.charged_task:Cancel()
			inst.charged_task = nil
			target.components.burnable:Ignite(nil, attacker)
				
		elseif inst.chargeTime == 0 then
				inst.chargeHandleUpgrade = inst.chargeHandleUpgrade +1
			
				--Enables special attack
			if inst.chargeHandleUpgrade >= 2 then
				inst.chargeHandleUpgrade = 0
				startovercharge(inst, 5, attacker) --How long the effect lasts
				--target.components.burnable:Ignite(nil, attacker)
			end
		end
	end
end

local function onload(inst, data)
    if data ~= nil and data.charge_time ~= nil then
        startovercharge(inst, data.charge_time)
    end
end

--local function resetshovelblade(inst)
	--Resets all the Charge Handle stats
	--inst.chargeHandleUpgrade = 0
	--inst.chargeTime = 0
	--inst.charged_task:Cancel()
	--inst.charged_task = nil
--end

local function fn(Sim)

	local function onequip(inst, owner)
	
		inst.owner = owner
		--inst.chargeHandleUpgrade = 0
		--inst.chargeTime = 0
		--inst.charged_task:Cancel()
		--inst.charged_task = nil
		
		--Sets how strong this weapon is
		local shovelbladeDamageWinston = 35 --+5 damage upgrade
		local shovelbladeDamageGeneric = 5
		
		owner.AnimState:OverrideSymbol("swap_object", "swap_skweaponshovelbladechargehandle", "swap_shovel")
		owner.AnimState:Show("ARM_carry") 
		owner.AnimState:Hide("ARM_normal") 
		
		--Makes the shovelblade strong only for Shovel Knight
		if owner.prefab == "winston" then
			inst.components.weapon:SetDamage(shovelbladeDamageWinston)
			owner.components.talker:Say("Lets get shoveling!")
			owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")   
		end
		
		--Makes the shovelblade weak for other characters
		if owner.prefab ~= "winston" then
			inst.components.weapon:SetDamage(shovelbladeDamageGeneric)
		end
	end

	local function onunequip(inst, owner)
		inst.owner = nil
		--inst.chargeHandleUpgrade = 0
		--inst.chargeTime = 0
		--inst.charged_task:Cancel()
		--inst.charged_task = nil
		
		--Sets how strong this weapon is
		local shovelbladeDamageGeneric = 5
	
		owner.AnimState:Hide("ARM_carry") 
		owner.AnimState:Show("ARM_normal") 
		
		--Resets the Shovelblade damage back to normal
		inst.components.weapon:SetDamage(shovelbladeDamageGeneric)
	end
	
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
    minimap:SetIcon("skweaponshovelbladechargehandle.tex")
	
    MakeInventoryPhysics(inst)
	
	inst:AddTag("irreplaceable")

    anim:SetBank("shovel")
    anim:SetBuild("skweaponshovelbladechargehandle")
    anim:PlayAnimation("idle", true)

    --Makes this a Tool with actions
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.DIG)
	inst.components.tool:SetAction(ACTIONS.MINE)
	--inst:AddInherentAction(ACTIONS.TERRAFORM)

    --Makes this a Weapon
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(5)
	
	--Special when attacking
	inst.owner = nil
	inst.chargeHandleUpgrade = 0
	inst.chargeTime = 0
	inst.charged_task = nil
	inst.OnLoad = onload
	inst.OnLongUpdate = onlongupdate
	inst.components.weapon:SetAttackCallback(onattack)

	--Makes this a Shovel
    inst:AddInherentAction(ACTIONS.DIG)
	
	--inst:AddComponent("terraformer")

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
--STRINGS.CHARACTERS.DROK.DESCRIBE.REDPAINT = "Drok use to paint!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKWEAPONSHOVELBLADECHARGEHANDLE = "A strange dirt moving tool..."

return Prefab("common/inventory/skweaponshovelbladechargehandle", fn, assets)
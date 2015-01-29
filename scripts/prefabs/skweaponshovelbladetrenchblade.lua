local assets =
{
	Asset("ANIM", "anim/skweaponshovelbladetrenchblade.zip"),
	Asset("ANIM", "anim/swap_skweaponshovelbladetrenchblade.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skweaponshovelbladetrenchblade.xml"),
	Asset("IMAGE", "images/inventoryimages/skweaponshovelbladetrenchblade.tex"),
	
	Asset("ATLAS", "images/map_icons/skweaponshovelbladetrenchblade.xml"),
	Asset("IMAGE", "images/map_icons/skweaponshovelbladetrenchblade.tex"),
}
prefabs = {
}

local function onattack(inst, owner, target)
    --if owner.components.health and not target:HasTag("wall") then
        --owner.components.sanity:DoDelta(-1)
    --end
end

local function fn(Sim)

	local function onequip(inst, owner)
	
		--Sets how strong this weapon is
		local shovelbladeDamageWinston = 40 --+10 damage upgrade
		local shovelbladeDamageGeneric = 5
		
		owner.AnimState:OverrideSymbol("swap_object", "swap_skweaponshovelbladetrenchblade", "swap_shovel")
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
    minimap:SetIcon("skweaponshovelbladetrenchblade.tex")
	
    MakeInventoryPhysics(inst)
	
	inst:AddTag("irreplaceable")

    anim:SetBank("shovel")
    anim:SetBuild("skweaponshovelbladetrenchblade")
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
	inst.components.weapon.onattack = onattack

	--Makes this a Shovel
    inst:AddInherentAction(ACTIONS.DIG)
	
	--inst:AddComponent("terraformer")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/skweaponshovelbladetrenchblade.xml"
	inst.components.inventoryitem.imagename = "skweaponshovelbladetrenchblade"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("winston")
	
    return inst
end

STRINGS.NAMES.SKWEAPONSHOVELBLADETRENCHBLADE = "Shovelblade"
--STRINGS.CHARACTERS.DROK.DESCRIBE.REDPAINT = "Drok use to paint!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKWEAPONSHOVELTRENCHBLADE = "A strange dirt moving tool..."

return Prefab("common/inventory/skweaponshovelbladetrenchblade", fn, assets)
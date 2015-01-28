local assets =
{
	Asset("ANIM", "anim/shovelblade.zip"),
	Asset("ANIM", "anim/goldenshovel.zip"),
	Asset("ANIM", "anim/swap_shovelblade.zip"),
	Asset("ANIM", "anim/swap_goldenshovel.zip"),
	Asset("ATLAS", "images/inventoryimages/shovelblade.xml")
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_shovelblade", "swap_shovel")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function onattack(inst, owner, target)
    if owner.components.health and not target:HasTag("wall") then
        owner.components.sanity:DoDelta(-1)
    end
end

local function fn(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst.AnimState:SetBank("shovel")
    inst.AnimState:SetBuild("shovelblade")
    inst.AnimState:PlayAnimation("idle")

    -----
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.DIG)
	inst.components.tool:SetAction(ACTIONS.MINE)
	--inst:AddInherentAction(ACTIONS.TERRAFORM)

    -----

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(30)
	inst.components.weapon.onattack = onattack

    inst:AddInherentAction(ACTIONS.DIG)
	
	--inst:AddComponent("terraformer")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/shovelblade.xml"
	
	--inst:AddComponent("dapperness")
    --inst.components.dapperness.dapperness = TUNING.CRAZINESS_SMALL

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

local function onequipgold(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_goldenshovel", "swap_goldenshovel")
	owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")     
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function golden(Sim)
	local inst = fn(Sim)

    if not TheWorld.ismastersim then
        return inst
    end

	inst.AnimState:SetBuild("goldenshovel")
	inst.AnimState:SetBank("goldenshovel")    
    inst.components.equippable:SetOnEquip(onequipgold)
    
	return inst
end


return Prefab("common/inventory/shovelblade", fn, assets),
	   Prefab("common/inventory/goldenshovelblade", golden, assets)
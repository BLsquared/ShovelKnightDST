local assets=
{
    Asset("ANIM", "anim/skitemtemplate.zip"),
    Asset("ANIM", "anim/swap_skitemtemplate.zip"),
 
    Asset("ATLAS", "images/inventoryimages/skitemtemplate.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemtemplate.tex"),
}
prefabs = {
}
local function fn()
 
    local function OnEquip(inst, owner)
        owner.AnimState:OverrideSymbol("swap_object", "swap_skitemtemplate", "swap_skitemtemplate")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end
 
    local function OnUnequip(inst, owner)
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
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
	
    MakeInventoryPhysics(inst)
     
    anim:SetBank("skitemtemplate")
    anim:SetBuild("skitemtemplate")
    anim:PlayAnimation("idle", true)
 
    --inst:AddComponent("stackable")
    --inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
     
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemtemplate.xml"
	inst.components.inventoryitem.imagename = "skitemtemplate"
     
	inst:AddComponent("inspectable")
	
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
 
    return inst
end


STRINGS.NAMES.SKITEMTEMPLATE = "skitemtemplate"
--STRINGS.CHARACTERS.DROK.DESCRIBE.REDPAINT = "Drok use to paint!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMTEMPLATE = "It looks primitive."


return  Prefab("common/inventory/skitemtemplate", fn, assets, prefabs)
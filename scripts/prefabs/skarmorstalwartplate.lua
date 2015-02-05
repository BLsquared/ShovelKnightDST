local assets =
{
	Asset("ANIM", "anim/skarmorstalwartplate.zip"),
	Asset("ANIM", "anim/swap_skarmorstalwartplate.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skarmorstalwartplate.xml"),
    Asset("IMAGE", "images/inventoryimages/skarmorstalwartplate.tex"),
}
prefabs = {
}

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour") 
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "skarmorstalwartplate", "swap_skarmorstalwartplate")
    inst:ListenForEvent("blocked", OnBlocked, owner)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_skarmorstalwartplate")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
end

local function fn()
	local inst = CreateEntity()
    
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddTag("irreplaceable")
	inst.entity:SetPristine()
    MakeHauntableLaunch(inst)
	
	MakeInventoryPhysics(inst)
		
    anim:SetBank("skarmorstalwartplate")
    anim:SetBuild("skarmorstalwartplate")
    anim:PlayAnimation("idle")
    
    inst.foleysound = "dontstarve/movement/foley/metalarmour"
	
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skarmorstalwartplate.xml"
	inst.components.inventoryitem.imagename = "skarmorstalwartplate"
    inst.components.inventoryitem.keepondeath = true --Stops equipped armor from falling off
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    
	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("winston")
	
    return inst
end


STRINGS.NAMES.SKARMORSTALWARTPLATE = "Stalwart Plate"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKARMORSTALWARTPLATE = "Offers basic protect."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKARMORSTALWARTPLATE = "It looks quite heavy."


return Prefab("common/inventory/skarmorstalwartplate", fn, assets, prefabs)
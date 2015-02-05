local assets =
{
	Asset("ANIM", "anim/skarmordynamomail.zip"),
	Asset("ANIM", "anim/swap_skarmordynamomail.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skarmordynamomail.xml"),
    Asset("IMAGE", "images/inventoryimages/skarmordynamomail.tex"),
}
prefabs = {
}

--local function onputinventory(inst)
	--local owner = inst.owner
	--if owner ~= nil and owner.components.inventory.equipslots[EQUIPSLOTS.BODY] == nil then
		--inst.components.equippable:Equip(owner)
	--end
--end

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour") 
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "skarmordynamomail", "swap_skarmorstalwartplate")
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
    anim:SetBuild("skarmordynamomail")
    anim:PlayAnimation("idle")
    
	--inst:AddTag("grass")
    
    inst.foleysound = "dontstarve/movement/foley/metalarmour"
	
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skarmordynamomail.xml"
	inst.components.inventoryitem.imagename = "skarmordynamomail"
    inst.components.inventoryitem.keepondeath = true --Stops equipped armor from falling off
	--inst.components.inventoryitem:SetOnPutInInventoryFn(onputinventory)
    --inst:AddComponent("armor")
    --inst.components.armor:InitCondition(TUNING.ARMORGRASS, TUNING.ARMORGRASS_ABSORPTION)
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    
	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("winston")
	
    return inst
end


STRINGS.NAMES.SKARMORDYNAMOMAIL = "Dynamo Mail"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKARMORDYNAMOMAIL = "Offers basic protect."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKARMORDYNAMOMAIL = "It looks quite heavy."


return Prefab("common/inventory/skarmordynamomail", fn, assets, prefabs)
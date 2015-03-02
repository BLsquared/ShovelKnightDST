local assets =
{
	Asset("ANIM", "anim/skitemtrouppleapple.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skitemtrouppleapple.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemtrouppleapple.tex"),
	Asset("ATLAS", "images/inventoryimages/skitemtrouppleapplecooked.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemtrouppleapplecooked.tex"),
}

local prefabs =
{
	"skitemtrouppleapple_cooked",
}    

local function commonfn(anim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("skitemtrouppleapple")
    inst.AnimState:SetBuild("skitemtrouppleapple")
    inst.AnimState:PlayAnimation(anim)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()
    
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("bait")
    
    inst:AddComponent("inspectable")
	
    MakeHauntableLaunchAndPerish(inst)

    return inst
end

local function defaultfn()
	local inst = commonfn("idle")

    if not TheWorld.ismastersim then
        return inst
    end

	inst.build = "skitemtrouppleapple"
	
	inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.MEAT
    inst.components.edible.healthvalue = TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.edible.sanityvalue = TUNING.SANITY_TINY

	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemtrouppleapple.xml"
	inst.components.inventoryitem.imagename = "skitemtrouppleapple"
	
    inst:AddComponent("cookable")
    inst.components.cookable.product = "skitemtrouppleapple_cooked"
	
	return inst
end

local function cookedfn()
	local inst = commonfn("cooked")

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
    inst.components.edible.healthvalue = TUNING.HEALING_MED
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
	inst.components.edible.sanityvalue = TUNING.SANITY_TINY
    
	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemtrouppleapplecooked.xml"
	inst.components.inventoryitem.imagename = "skitemtrouppleapplecooked"
	
	return inst
end

STRINGS.NAMES.SKITEMTROUPPLEAPPLE = "Troupple Apple"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMTROUPPLEAPPLE = "The forbidden fruit..."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMTROUPPLEAPPLE = "Looks like an apple, but smells like a fish..."

STRINGS.NAMES.SKITEMTROUPPLEAPPLE_COOKED = "Prepared Troupple Apple"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMTROUPPLEAPPLE_COOKED = "The fish smell is gone!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMTROUPPLEAPPLE_COOKED = "The fish smell is gone!"


return Prefab("common/inventory/skitemtrouppleapple", defaultfn, assets, prefabs),
		Prefab("common/inventory/skitemtrouppleapple_cooked", cookedfn, assets)
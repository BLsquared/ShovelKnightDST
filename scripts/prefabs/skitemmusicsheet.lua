local assets=
{
    Asset("ANIM", "anim/skitemmusicsheet.zip"),
	
    Asset("ATLAS", "images/inventoryimages/skitemmusicsheet.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemmusicsheet.tex"),
}
prefabs = {
}

local function stopkicking(inst)
    inst.AnimState:PlayAnimation("idle")
end

local function fn()
 
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()
	
	
	if not TheWorld.ismastersim then
        return inst
    end
	MakeInventoryPhysics(inst)
	
	anim:SetBank("skitemmusicsheet")
    anim:SetBuild("skitemmusicsheet")
    anim:PlayAnimation("fished")
	
	inst.entity:SetPristine()
	MakeHauntableLaunch(inst)
    
	inst.build = "skitemmusicsheet"
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemmusicsheet.xml"
	inst.components.inventoryitem.imagename = "skitemmusicsheet"
     
	inst:AddComponent("inspectable")
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 5
		
	--Burn
	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	
	inst:DoTaskInTime(0.7, stopkicking)
	inst.OnLoad = stopkicking
	
    return inst
end


STRINGS.NAMES.SKITEMMUSICSHEET = "Music Sheet"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMMUSICSHEET = "Bravissimo!!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMMUSICSHEET = "A single score..."


return  Prefab("common/inventory/skitemmusicsheet", fn, assets, prefabs)
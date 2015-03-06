local assets=
{
    Asset("ANIM", "anim/skitemtrouppleorb.zip"),
	Asset("SOUND", "sound/plant.fsb"),
	
    Asset("ATLAS", "images/inventoryimages/skitemtrouppleorb.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemtrouppleorb.tex"),
}

local loot = {"lightbulb", "plantmeat"}

local function OnDropped(inst)
	inst.AnimState:OverrideSymbol("eye", "", "eye") --Orb thing
	if inst.orbGlow == nil then
		inst.orbGlow = SpawnPrefab("skfxtrouppletree_orbglow")
		local follower = inst.orbGlow.entity:AddFollower()
		follower:FollowSymbol(inst.GUID, "eye", 0, -100, 0)
	end
end

local function OnPickup(inst)
	inst.AnimState:ClearOverrideSymbol("eye")
	if inst.orbGlow ~= nil then
		inst.orbGlow:Remove()
		inst.orbGlow = nil
	end
end

local function hasLight(inst)
	if inst.components.inventoryitem.owner == nil then
		OnDropped(inst)
	end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()
	
	MakeInventoryPhysics(inst)
	
	anim:SetBank("skitemtrouppleorb")
    anim:SetBuild("skitemtrouppleorb")
    anim:PlayAnimation("idle")
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
	inst.orbGlow = nil
	
	inst:AddTag("show_spoilage")
	
	inst:AddComponent("inspectable")
		
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemtrouppleorb.xml"
	inst.components.inventoryitem.imagename = "skitemtrouppleorb"
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPickupFn(OnPickup)
	
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
	
	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(1)
	--inst.components.health.murdersound = "dontstarve/creatures/eyeplant/eye_central_hurt"
	
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot(loot)
						
	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	
	MakeHauntableLaunchAndPerish(inst)
	
	inst:DoTaskInTime(0.2, hasLight)
	
    return inst
end

STRINGS.NAMES.SKITEMTROUPPLEORB= "Troupple Orb"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMTROUPPLEORB = "The sacred treasure grown from the Troupple Tree!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMTROUPPLEORB = "A strangely shaped object that fell from the Troupple Tree..."


return  Prefab("common/inventory/skitemtrouppleorb", fn, assets)
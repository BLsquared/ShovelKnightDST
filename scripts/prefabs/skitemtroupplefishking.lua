local assets=
{
    Asset("ANIM", "anim/skitemtroupplefishking.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skitemtroupplefish.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemtroupplefish.tex"),
}

prefabs = {
}

--local function OnGoingHome(inst)
    --local fx = SpawnPrefab("splash")
    --local pos = inst:GetPosition()
    --fx.Transform:SetPosition(pos.x, pos.y, pos.z)

	--local splash = PlayFX(Vector3(inst.Transform:GetWorldPosition() ), "splash", "splash", "splash")
	--inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
--end

--local function stopkicking(inst)
    --inst.AnimState:PlayAnimation("idle")
--end

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
	
	inst:AddTag("largecreature")
	
	anim:SetBank("fish")
    anim:SetBuild("skitemtroupplefishking")
    anim:PlayAnimation("idle", true)
	
	inst.entity:SetPristine()
	MakeHauntableLaunch(inst)
    
	inst.Transform:SetScale(4, 4, 4)
	
	inst.build = "skitemtroupplefishking"
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemtroupplefish.xml"
	inst.components.inventoryitem.imagename = "skitemtroupplefish"
     
	inst:AddComponent("inspectable")
	
	--inst:AddComponent("knownlocations")
	--inst:ListenForEvent("goinghome", OnGoingHome)
	 
	--inst:AddComponent("stackable")
	--inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	--inst:AddComponent("tradable")
    --inst.components.tradable.goldvalue = 5
		
	--Burn
	--inst:AddComponent("fuel")
    --inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	
	--inst:DoTaskInTime(0.7, stopkicking)
	--inst.OnLoad = stopkicking
	
    return inst
end


STRINGS.NAMES.SKITEMTROUPPLEFISHKING = "Troupple King"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMTROUPPLEFISHKING = "Ruler of the great Troupple Kingdom!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMTROUPPLEFISHKING = "What a huge looking apple... fish?!"


return  Prefab("common/inventory/skitemtroupplefishking", fn, assets, prefabs)
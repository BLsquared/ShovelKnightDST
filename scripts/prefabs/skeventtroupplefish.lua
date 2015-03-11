local assets =
{
	Asset("ANIM", "anim/skitemtroupplefish.zip"),
	Asset("ANIM", "anim/skitemtroupplefishlay.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skitemtroupplefish.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemtroupplefish.tex"),
}

local prefabs =
{
	"skeventtroupplefishskip",
	"skeventtroupplefishfly",
	"skeventtroupplefishfall",
	"skeventtroupplefishgrow"
}   

local function splashFx(inst)
	local fx = SpawnPrefab("splash")
    local pos = inst:GetPosition()
    fx.Transform:SetPosition(pos.x, pos.y, pos.z)
	inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
end

local function gounderwater(inst)
	splashFx(inst)
	inst:Remove()
end

local function flyend(inst)
	inst.entity:Hide()
	if inst.fishtype == 3 then
		local fish = SpawnPrefab("skeventtroupplefishfall")
		local posSpawn = inst:GetPosition()
		fish.Transform:SetPosition(posSpawn.x, posSpawn.y, posSpawn.z)
	end
	inst:Remove()
end

local function phydelay(inst)
	inst.entity:Show()
	splashFx(inst)
	inst.Physics:SetActive(false)
	inst:DoTaskInTime(3, gounderwater)
end

local function onfishedup(inst)
	if inst.fishtype == 2 then --skip fish
		inst:DoTaskInTime(0.7, phydelay)
	elseif inst.fishtype == 3 or inst.fishtype == 5 then --fly fish
		inst:DoTaskInTime(0.1, flyend)
	elseif inst.fishtype == 4 then --fall fish
		inst.Physics:SetActive(false)
		inst:DoTaskInTime(0.1, gounderwater)
	else
		inst:DoTaskInTime(1, gounderwater)
	end
end

local function commonfn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()
	
	anim:SetBank("fish")
    anim:SetBuild("skitemtroupplefish")
    anim:PlayAnimation("idle", true)
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
	inst.persists = false
	
    return inst
end

local function fn()
	local inst = commonfn()

	MakeInventoryPhysics(inst)
	
    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.Physics:SetActive(false)
	
	inst.fishtype = 1
	
	inst:DoTaskInTime(0.5, onfishedup)
	
	return inst
end

local function fn2()
	local inst = commonfn()

	MakeInventoryPhysics(inst)
	
    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:Hide()
	inst.fishtype = 2
	
	inst:DoTaskInTime(0.5, onfishedup)
	
	return inst
end

local function fn3()
	local inst = commonfn()
	
	MakeObstaclePhysics(inst, 3, 0.5) --aoe jump

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.fishtype = 3
	
	splashFx(inst)
	
	inst:DoTaskInTime(0.5, onfishedup)
	
	return inst
end

local function fn4()
	local inst = commonfn()

	MakeInventoryPhysics(inst)
	
    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.fishtype = 4
	
	inst:DoTaskInTime(0.1, onfishedup)
	
	return inst
end

local function fn5()
	local inst = commonfn()
	
	MakeObstaclePhysics(inst, 0.1, 0.1) --aoe jump

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.fishtype = 5
	
	splashFx(inst)
	
	inst:DoTaskInTime(0.5, onfishedup)
	
	return inst
end

return  Prefab("common/objects/skeventtroupplefish", fn, assets, prefabs),
		Prefab("common/objects/skeventtroupplefishskip", fn2, assets),
		Prefab("common/objects/skeventtroupplefishfly", fn3, assets),
		Prefab("common/objects/skeventtroupplefishfall", fn4, assets),
		Prefab("common/objects/skeventtroupplefishgrow", fn5, assets)
local assets =
{
	Asset("ANIM", "anim/sktiletroupplepondborder.zip"),
	Asset("ANIM", "anim/splash.zip"),
}

local prefabs =
{
	"sktiletroupplepondborder",
	"skitemmusicsheet",
	"fish",
	"eel",
}

local function onpreload(inst, data)
    if data ~= nil then
        if data.orb ~= nil then
			inst.orb = data.orb
		end
    end
end

local function onsave(inst, data)
	data.orb = inst.orb >= 0 and inst.orb or nil
end

local function OnIsDay(inst, isday)
    if not TheWorld.state.iswinter and inst.orb == 0 then
        inst.orb = 1
		if inst.orbKeeper.prefab ~= nil then
			inst.orbKeeper:PushEvent("growOrb")
		end
    end
end

local function OnSnowLevel(inst, snowlevel, thresh)
	thresh = thresh or .02
	
	inst.snowThresh = snowlevel
	
	if snowlevel > thresh and not inst.frozen then
		inst.frozen = true
		inst.AnimState:PlayAnimation("frozen")
		inst.components.fishable:Freeze()

        inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.ITEMS)

	elseif snowlevel < thresh and inst.frozen then
		inst.frozen = false
		inst.AnimState:PlayAnimation("idle")
		inst.components.fishable:Unfreeze()

		inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.ITEMS)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	end
end

local function onload(inst, data, newents)
	OnIsDay(inst, TheWorld.state.isday)
	OnSnowLevel(inst, TheWorld.state.snowlevel)
end

--Creates the Border around the Troupple Pond
local function spawnBorder(inst)
	--Grow Orb
	OnIsDay(inst, TheWorld.state.isday)
	
	--Make Border
	local border = SpawnPrefab("sktiletroupplepondborder")
	local posSpawn = inst:GetPosition()
	border.Transform:SetPosition(posSpawn.x - 3.2, posSpawn.y, posSpawn.z + 1.5)
	border.snowThresh = inst.snowThresh
	
	--Make Tree
	local tree = SpawnPrefab("skstructuretreetroupple")
	local posSpawn2 = inst:GetPosition()
	tree.Transform:SetPosition(posSpawn2.x - 3.5, posSpawn2.y, posSpawn2.z + 1.7)
	inst.orbKeeper = tree
	tree.orbHolder = inst
	tree.snowThresh = inst.snowThresh
	
	--Make Sign
	local sign = SpawnPrefab("skstructuresigntroupple")
	local posSpawn3 = inst:GetPosition()
	sign.Transform:SetPosition(posSpawn3.x + 4.3, posSpawn3.y, posSpawn3.z - 3.3)
	
	inst:DoTaskInTime(0.2, onload)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst.Transform:SetScale(1, 1, 1)
	inst.Transform:SetRotation(180)
	
	MakeObstaclePhysics(inst, 4)
	
    inst.AnimState:SetBuild("sktiletroupplepondborder")
    inst.AnimState:SetBank("marsh_tile")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    --inst.AnimState:SetLayer(LAYER_BACKGROUND)
    --inst.AnimState:SetSortOrder(3)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

	inst.Physics:SetActive(false)
	
	--Orb Stuff
	inst.orb = 0
	inst.orbKeeper = ""
	
	inst.frozen = false
	inst.snowThresh = nil
	
    inst:AddComponent("inspectable")
	
    inst.no_wet_prefix = true

	--Add Fish
	inst:AddComponent("fishable")
	inst.components.fishable:SetRespawnTime(TUNING.FISH_RESPAWN_TIME)
	--inst.components.fishable:AddFish("skitemmusicsheet")
	inst.components.fishable:AddFish("fish")
	inst.components.fishable:AddFish("eel")
	
	inst:WatchWorldState("isday", OnIsDay)
	inst:WatchWorldState("snowlevel", OnSnowLevel)
	
	inst.OnSave = onsave
	inst.OnLoad = onload
	inst.OnPreLoad = onpreload
	
	inst:DoTaskInTime(0.2, spawnBorder)
	
	return inst
end

STRINGS.NAMES.SKTILETROUPPLEPOND = "Large Pond"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKTILETROUPPLEPOND = "The realm of the Troupple Kingdom!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKTILETROUPPLEPOND = "What a huge pond... that smells like apples?!"


return Prefab("marsh/objects/sktiletroupplepond", fn, assets, prefabs)
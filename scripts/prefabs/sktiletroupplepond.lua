local assets =
{
	Asset("ANIM", "anim/sktiletroupplepond.zip"),
	Asset("ANIM", "anim/splash.zip"),
}

local prefabs =
{
	"sktiletroupplepondborder",
	"skitemtrouppleapple",
	"skitemmusicsheet",
}

local function onupdate(inst, dt)
	if inst.kingKeeper.prefab ~= nil then
		--Angry King
		inst.fishPrev = inst.fishCurrent
		inst.fishCurrent = inst.components.fishable.fishleft
		if inst.fishCurrent < inst.fishPrev then
			inst.kingKeeper:PushEvent("angryking")
		end
		--Troupple Dance
		if TheWorld.state.temperature >= 30 and inst.kingEvent == -1 then --Reset troupple dance, Reset is at -1
			inst.kingEvent = 1
		elseif TheWorld.state.temperature < 30 and inst.kingEvent ~= 0 then
			inst.kingEvent = -1
		end
	else
		if inst.kingClock_Task ~= nil then
			inst.kingClock_Task:Cancel()
			inst.kingClock_Task = nil
		end
	end
end

local function onpreload(inst, data)
    if data ~= nil then
        if data.orb ~= nil then
			inst.orb = data.orb
		end
		if data.plant ~= nil then
			inst.plant = data.plant
		end
		if data.kingIchor ~= nil then
			inst.kingIchor = data.kingIchor
		end
		if data.kingIchorReset ~= nil then
			inst.kingIchorReset = data.kingIchorReset
		end
		if data.kingEventFirst ~= nil then
			inst.kingEventFirst = data.kingEventFirst
		end
		if data.kingEvent ~= nil then
			inst.kingEvent = data.kingEvent
		end
    end
end

local function onsave(inst, data)
	data.orb = inst.orb >= 0 and inst.orb or nil
	data.plant = inst.plant > 0 and inst.plant or nil
	data.kingIchor = inst.kingIchor >= 0 and inst.kingIchor or nil
	data.kingIchorReset = inst.kingIchorReset >= 0 and inst.kingIchorReset or nil
	data.kingEventFirst = inst.kingEventFirst > 0 and inst.kingEventFirst or nil
	data.kingEvent = inst.kingEvent >= 0 and inst.kingEvent or nil
end

local function OnIsDay(inst, isday)
    if not TheWorld.state.iswinter and inst.orb == 0 then
        inst.orb = 1
		if inst.orbKeeper.prefab ~= nil then
			inst.orbKeeper:PushEvent("growOrb")
		end
    end
	--Make Troupple King
	if not TheWorld.state.iswinter and isday then
		if inst.plantKeeper.prefab ~= nil then
			inst.plantKeeper:PushEvent("bubbleWater")
			
			local king = SpawnPrefab("skitemtroupplefishking")
			local posSpawn2 = inst:GetPosition()
			king.Transform:SetPosition(posSpawn2.x - 0.5 , posSpawn2.y - 1, posSpawn2.z + 1)
			king.entity:Hide()
			inst.kingKeeper = king
			king.kingHolder = inst
			king.snowThresh = inst.snowThresh
			--Ichor fill event
			if inst.kingIchorReset <= 0 then -- Refills Chalice, Reset is at 0
				inst.kingIchorReset = 3
				inst.kingIchor = 3
			end
			--Angry King event
			inst.kingClock_Task = inst:DoPeriodicTask(1, onupdate, nil, 1)
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
		inst.kingIchorReset = 0
		inst.kingEvent = -1
		
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
	--Make Border
	local border = SpawnPrefab("sktiletroupplepondborder")
	local posSpawn = inst:GetPosition()
	border.Transform:SetPosition(posSpawn.x - 3.2, posSpawn.y, posSpawn.z + 1.5)
	inst.plantKeeper = border
	border.plantHolder = inst
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
	inst.signKeeper = sign
	inst:DoTaskInTime(0.3, onload)
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
	
    inst.AnimState:SetBuild("sktiletroupplepond")
    inst.AnimState:SetBank("marsh_tile")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

	inst.Physics:SetActive(false)
	
	--Fish stuff
	inst.fishPrev = 0
	inst.fishCurrent = 0
	
	--Orb Stuff
	inst.orb = 0
	inst.orbKeeper = "" --Stores Troupple Tree
	
	--Sing Stuff
	inst.signKeeper = "" --Stores Troupple Sign
	
	--Plant Stuff
	inst.plant = 0
	inst.plantKeeper = "" --Stores Troupple Pond Border
	
	--Troupple King
	inst.kingIchor = 0 --Troupple Chalice Refills
	inst.kingIchorReset = 0 --Hits 3 days, resets kingIchor
	inst.kingEventFirst = 0 --Very first Dance
	inst.kingEvent = 0 --Dance event
	inst.kingKeeper = "" --Stores Troupple King
	inst.kingClock_Task = nil
	
	inst.frozen = false
	inst.snowThresh = nil
	
    inst:AddComponent("inspectable")
	
    inst.no_wet_prefix = true

	--Add Fish
	inst:AddComponent("fishable")
	inst.components.fishable:SetRespawnTime(TUNING.FISH_RESPAWN_TIME)
	inst.components.fishable:AddFish("skitemtrouppleapple")
	
	inst:WatchWorldState("isday", OnIsDay)
	inst:WatchWorldState("snowlevel", OnSnowLevel)
	
	inst.OnSave = onsave
	--inst.OnLoad = onload
	inst.OnPreLoad = onpreload
	
	inst:DoTaskInTime(0.2, spawnBorder)
	
	return inst
end

STRINGS.NAMES.SKTILETROUPPLEPOND = "Large Pond"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKTILETROUPPLEPOND = "The realm of the Troupple Kingdom!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKTILETROUPPLEPOND = "What a huge pond... that smells like apples?!"


return Prefab("marsh/objects/sktiletroupplepond", fn, assets, prefabs)
local assets =
{
	Asset("ANIM", "anim/sktiletroupplepondborder.zip"),
	Asset("ANIM", "anim/splash.zip"),
	
	Asset("ATLAS", "images/map_icons/sktiletroupplepond.xml"),
	Asset("IMAGE", "images/map_icons/sktiletroupplepond.tex"),
	Asset("ATLAS", "images/map_icons/sktiletroupplepondfrozen.xml"),
	Asset("IMAGE", "images/map_icons/sktiletroupplepondfrozen.tex"),
}

local prefabs =
{
	"marsh_plant",
}

--local function ReturnChildren(inst)
	--for k,child in pairs(inst.components.childspawner.childrenoutside) do
		--if child.components.homeseeker then
			--child.components.homeseeker:GoHome()
		--end
		--child:PushEvent("gohome")
	--end
--end

local function createRealPlants(inst, name, x, y, z)
	local plant = SpawnPrefab(name)
	local posSpawn = inst:GetPosition()
	plant.Transform:SetPosition(posSpawn.x + x, posSpawn.y + y, posSpawn.z + z)
end

local function growRealPlant(inst)
	if inst.plantHolder.plant == 0 then
		inst.plantHolder.plant = 1
		
		createRealPlants(inst, "grass", 5.5, 0, 7) --Grass 1
		createRealPlants(inst, "grass", 1, 0, 9) --Grass 2
		createRealPlants(inst, "grass", -3, 0, 8.5) --Grass 3
		createRealPlants(inst, "grass", -5, 0, -5.5) --Grass 4
		createRealPlants(inst, "grass", 2, 0, -9) --Grass 5
		createRealPlants(inst, "grass", 3, 0, -8) --Grass 6
		
		createRealPlants(inst, "reeds", 9, 0, 1) --Reed 1
		createRealPlants(inst, "reeds", 8.5, 0, 2.5) --Reed 2
		createRealPlants(inst, "reeds", 7.5, 0, 5) --Reed 3
		createRealPlants(inst, "reeds", -6, 0, 7) --Reed 4
		createRealPlants(inst, "reeds", -7, 0, 5) --Reed 5
		createRealPlants(inst, "reeds", -8, 0, 1) --Reed 6
		createRealPlants(inst, "reeds", -6, 0, -4) --Reed 7
		createRealPlants(inst, "reeds", 4.5, 0, -7.5) --Reed 8
		createRealPlants(inst, "reeds", 6.5, 0, -7) --Reed 9
	end
end

local function SpawnPlants(inst, plantname)
	if inst.decor then
		for i,item in ipairs(inst.decor) do
			item:Remove()
		end
	end
	inst.decor = {}

	local plant_offsets = {}

	for i=1,math.random(6,8) do
		local a = math.random()*math.pi*2
		local x = math.sin(a)*3.8+math.random()*0.3 --1.9
		local z = math.cos(a)*4.2+math.random()*0.3 --2.1
		table.insert(plant_offsets, {x,0,z})
	end

	for k, offset in pairs( plant_offsets ) do
		local plant = SpawnPrefab( plantname )
		plant.entity:SetParent( inst.entity )
		plant.Transform:SetPosition( offset[1], offset[2], offset[3] )
		table.insert( inst.decor, plant )
	end
end

local function OnSnowLevel(inst, snowlevel, thresh)
	thresh = thresh or .02
	
	if inst.snowThresh ~= nil and inst.snowThresh > snowlevel then
		snowlevel = inst.snowThresh
		inst.snowThresh = nil
	end
	
	if snowlevel > thresh and not inst.frozen then
		inst.frozen = true
		inst.AnimState:PlayAnimation("frozen")
		inst.SoundEmitter:PlaySound("dontstarve/winter/pondfreeze")
		inst.MiniMapEntity:SetIcon("sktiletroupplepondfrozen.tex")
	    --inst.components.childspawner:StopSpawning()

        inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.ITEMS)

		for i,item in ipairs(inst.decor) do
			item:Remove()
		end
		inst.decor = {}
	elseif snowlevel < thresh and inst.frozen then
		inst.frozen = false
		inst.AnimState:PlayAnimation("idle_mos")
		inst.MiniMapEntity:SetIcon("sktiletroupplepond.tex")
	    --inst.components.childspawner:StartSpawning()

		inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.ITEMS)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)

		SpawnPlants(inst, inst.planttype)
	end
end

local function onload(inst, data, newents)
	if inst.plantHolder.prefab ~= nil then
		growRealPlant(inst)
	end
	OnSnowLevel(inst, TheWorld.state.snowlevel)
end

local function OnIsDay(inst, isday)
    --if isday ~= inst.dayspawn then
        --inst.components.childspawner:StopSpawning()
        --ReturnChildren(inst)
    --elseif not TheWorld.state.iswinter then
        --inst.components.childspawner:StartSpawning()
    --end
end

local function calmPond(inst)
	inst.AnimState:PushAnimation("idle_mos", true)
end

local function startSplash(inst)
	inst.AnimState:PlayAnimation("splash_mos", true)
	inst:DoTaskInTime(1, calmPond)
end

local function startBubble(inst)
	inst.AnimState:PlayAnimation("bubble_mos", true)
	inst:DoTaskInTime(4, calmPond)
end

local function spawnChestLoot(inst, chest)
	local rot = SpawnPrefab("spoiled_food")
	local rot2 = SpawnPrefab("spoiled_food")
	local rot3 = SpawnPrefab("spoiled_food")
	local rot4 = SpawnPrefab("spoiled_food")
	local rot5 = SpawnPrefab("spoiled_food")
	local rot6 = SpawnPrefab("spoiled_food")
	local chaliceRed = SpawnPrefab("skrelictroupplechalicered")
	local chaliceBlue = SpawnPrefab("skrelictroupplechaliceblue")
	local chaliceYellow = SpawnPrefab("skrelictroupplechaliceyellow")
	
	chest.components.container:GiveItem(rot, 1)
	chest.components.container:GiveItem(rot2, 2)
	chest.components.container:GiveItem(rot3, 3)
	chest.components.container:GiveItem(chaliceRed, 4)
	chest.components.container:GiveItem(chaliceBlue, 5)
	chest.components.container:GiveItem(chaliceYellow, 6)
	chest.components.container:GiveItem(rot4, 7)
	chest.components.container:GiveItem(rot5, 8)
	chest.components.container:GiveItem(rot6, 9)
end

local function spawnChest(inst)
	if inst.plantHolder.kingKeeper.prefab ~= nil then
		inst.plantHolder.kingKeeper.components.talker:Say("Please choose an Ichor filled Chalice!")
	end
	local chest = SpawnPrefab("skstructurechesttroupple")
	local posSpawn = inst:GetPosition()
	chest.Transform:SetPosition(posSpawn.x + 9.5, posSpawn.y, posSpawn.z - 4.5)
	inst.chestKeeper = chest
	chest.chestHolder = inst
	spawnChestLoot(inst, chest)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst.Transform:SetScale(2.2, 2.2, 2.2)
	inst.Transform:SetRotation(180)
	
    MakeObstaclePhysics(inst, 17.1) --1.95 --17.1
	
    inst.AnimState:SetBuild("sktiletroupplepondborder")
    inst.AnimState:SetBank("marsh_tile")
    inst.AnimState:PlayAnimation("idle_mos", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.MiniMapEntity:SetIcon("sktiletroupplepond.tex")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

	--Add Creatures
	--inst:AddComponent( "childspawner" )
	--inst.components.childspawner.childname = "frog"
	--inst.components.childspawner.childname = "mosquito"
	--inst.components.childspawner:SetRegenPeriod(TUNING.POND_REGEN_TIME)
	--inst.components.childspawner:SetSpawnPeriod(TUNING.POND_SPAWN_TIME)
	--inst.components.childspawner:SetMaxChildren(math.random(3,4))
	--inst.components.childspawner:StartRegen()

	inst.plantHolder = ""
	inst.chestKeeper = ""
	
	inst.frozen = false
	inst.snowThresh = nil
	
    inst:AddComponent("inspectable")
	
    inst.no_wet_prefix = true
	
	--Add Plants
    inst.planttype = "marsh_plant"
	--inst.planttype = "pond_algae"
	SpawnPlants(inst, inst.planttype)
	
	inst.persists = false
	
	inst.dayspawn = true
    inst:WatchWorldState("isday", OnIsDay)
	inst:WatchWorldState("snowlevel", OnSnowLevel)
	
	inst.OnLoad = onload
	
	inst:ListenForEvent("bubbleWater", startBubble)
	inst:ListenForEvent("splashWater", startSplash)
	inst:ListenForEvent("spawnChest", spawnChest)
	
	inst:DoTaskInTime(0.2, onload)
	
	return inst
end

STRINGS.NAMES.SKTILETROUPPLEPONDBORDER = "Large Pond"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKTILETROUPPLEPONDBORDER = "The realm of the Troupple Kingdom!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKTILETROUPPLEPONDBORDER = "What a huge pond... that smells like apples?!"


return Prefab("marsh/objects/sktiletroupplepondborder", fn, assets, prefabs)
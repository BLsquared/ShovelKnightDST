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
	
	if inst.snowTresh ~= nil and inst.snowThresh > snowlevel then
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
	
	inst:DoTaskInTime(0.2, onload)
	
	return inst
end

STRINGS.NAMES.SKTILETROUPPLEPONDBORDER = "Large Pond"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKTILETROUPPLEPONDBORDER = "The realm of the Troupple Kingdom!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKTILETROUPPLEPONDBORDER = "What a huge pond... that smells like apples?!"


return Prefab("marsh/objects/sktiletroupplepondborder", fn, assets, prefabs)
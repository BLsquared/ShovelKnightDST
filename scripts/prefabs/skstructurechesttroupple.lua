require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/skstructurechest.zip"),
	Asset("ANIM", "anim/ui_chest_3x2.zip"),
	
	Asset("ATLAS", "images/map_icons/skstructurechesttroupple.xml"),
	Asset("IMAGE", "images/map_icons/skstructurechesttroupple.tex"),
}

local function onopen(inst) 
	inst.AnimState:PlayAnimation("open") 
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end 

local function onclose(inst) 
	inst.AnimState:PlayAnimation("close") 
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")		
end 

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
end

local function destroyChest(inst)
	inst.components.container:DestroyContents()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")	
	inst:DoTaskInTime(0.2, inst.Remove)
end

local function onitemlose(inst, data)
	if data.slot ~= nil then
		if data.slot == 4 or data.slot == 5 or data.slot == 6 then
			inst:DoTaskInTime(0.2, destroyChest)
		end
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()
	
	MakeObstaclePhysics(inst, 0.5)
		
	inst.MiniMapEntity:SetIcon("skstructurechesttroupple.tex")
	inst.MiniMapEntity:SetPriority(1)
	
	inst:AddTag("structure")
		
	inst.AnimState:SetBank("chest")
	inst.AnimState:SetBuild("skstructurechest")
	inst.AnimState:PlayAnimation("place")

	MakeSnowCoveredPristine(inst)

	if not TheWorld.ismastersim then
		return inst
	end

	inst.entity:SetPristine()

	inst.chestHolder = ""
	
	inst.persists = false
	
	inst:AddComponent("inspectable")
		
	inst:AddComponent("container")
	inst.components.container:WidgetSetup("treasurechest")
	inst.components.container.onopenfn = onopen
	inst.components.container.onclosefn = onclose

	inst:ListenForEvent("itemlose", onitemlose)
	
	MakeSnowCovered(inst)
	
	MakeHauntablePanic(inst)
	
	return inst
end

STRINGS.NAMES.SKSTRUCTURECHESTTROUPPLE = "Troupple Chest"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKSTRUCTURECHESTTROUPPLE = "A gift from the Troupple King awaits inside!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKSTRUCTURECHESTTROUPPLE = "What wonders could be inside?!"


return Prefab("common/objects/skstructurechesttroupple", fn, assets)
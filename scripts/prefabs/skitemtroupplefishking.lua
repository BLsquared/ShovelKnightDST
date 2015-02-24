local assets=
{
    Asset("ANIM", "anim/skitemtroupplefishking.zip"),
	Asset("ANIM", "anim/skitemtroupplefishkinglay.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skitemtroupplefish.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemtroupplefish.tex"),
}

prefabs = {
}

local function randomSplashFx(inst)
	local fx = SpawnPrefab("splash")
    local pos = inst.components.fishingrod.target:GetPosition()
	
	local a = math.random()*math.pi*2
	local x = math.sin(a)*1.4+math.random()*0.3
	local z = math.cos(a)*1.6+math.random()*0.3
	
	fx.Transform:SetPosition(pos.x + x, pos.y + 0, pos.z + z)
	inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
end

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

local function fishybehaviorfarewell(inst)
	inst.components.talker:Say("Back to the deeps I go!")
	splashFx(inst)
	inst:DoTaskInTime(3, gounderwater)
end

local function fishybehaviorgreet(inst)
	if inst.catcher.prefab ~= nil then --Stops the odd first load loop
		inst.entity:Show()
		inst.components.talker:Say("I am the great Troupple King!")
		splashFx(inst)
		--inst:DoTaskInTime(3, fishybehaviorinspect)
		inst:DoTaskInTime(3, fishybehaviorfarewell)
	end
end

local function onfishedup(inst)
	inst:DoTaskInTime(1, fishybehaviorgreet)
end

local function fn()
 
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()
	
	inst.Transform:SetFourFaced()
	inst.Transform:SetScale(4, 4, 4)
	
	MakeInventoryPhysics(inst)
	
	inst:AddTag("largecreature")
	
	anim:SetBank("fish")
    --anim:SetBuild("skitemtroupplefishking")
    --anim:PlayAnimation("idle", true)
	anim:SetBuild("skitemtroupplefishkinglay")
    anim:PlayAnimation("dead", true)
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
	inst.Physics:SetActive(false)
	inst.build = "skitemtroupplefishking"
	
	inst.catcher = ""
	
	inst:AddComponent("talker")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemtroupplefish.xml"
	inst.components.inventoryitem.imagename = "skitemtroupplefish"
     
	inst:AddComponent("inspectable")
	
	inst.OnLoad = gounderwater
	
	inst:DoTaskInTime(1, onfishedup)
	
	MakeHauntableLaunch(inst)
		
    return inst
end


STRINGS.NAMES.SKITEMTROUPPLEFISHKING = "Troupple King"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMTROUPPLEFISHKING = "Ruler of the great Troupple Kingdom!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMTROUPPLEFISHKING = "What a huge looking apple... fish?!"


return  Prefab("common/inventory/skitemtroupplefishking", fn, assets, prefabs)
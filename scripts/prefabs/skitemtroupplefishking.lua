local assets=
{
    Asset("ANIM", "anim/skitemtroupplefishking.zip"),
	Asset("ANIM", "anim/skitemtroupplefishkinglay.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skitemtroupplefish.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemtroupplefish.tex"),
}

prefabs = {
}

local function trouppleKingShake(inst, shakeTime)
	if inst.kingHolder.prefab ~= nil then
		for i, v in ipairs(AllPlayers) do
			v:ShakeCamera(CAMERASHAKE.SIDE, shakeTime, .05, .1, inst.kingHolder, 40)
		end
	end
end

local function splashBigFx(inst)
	local fx = SpawnPrefab("splash")
    local pos = inst:GetPosition()
    fx.Transform:SetPosition(pos.x, pos.y, pos.z)
	fx.Transform:SetScale(3, 3, 3)
	inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
end

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

local function sayVoiceBox(inst, say)
	if inst.voiceBoxKeeper.prefab ~= nil then
		inst.voiceBoxKeeper.components.talker:Say(say)
	end
end

local function gounderwater(inst)
	splashBigFx(inst)
	if inst.kingHolder.plantKeeper.prefab ~= nil then
		inst.kingHolder.plantKeeper:PushEvent("splashWater")
	end
	trouppleKingShake(inst, 4)
	if inst.voiceBoxKeeper ~= nil then
		inst.voiceBoxKeeper:Remove()
	end
	inst:Remove()
end

local function gounderwaterpre(inst)
	inst.AnimState:PlayAnimation("idle", true)
	inst:DoTaskInTime(1, gounderwater)
end

local function fishybehaviorcold(inst)
	sayVoiceBox(inst, "Winter is coming, all citizens back under the water!")
	splashBigFx(inst)
	inst:DoTaskInTime(3, gounderwaterpre)
end

local function fishybehaviorfarewell(inst)
	sayVoiceBox(inst, "Back to the deeps I go!")
	splashBigFx(inst)
	inst:DoTaskInTime(3, gounderwaterpre)
end	

local function fishybehaviorgreet(inst)
	if inst.kingHolder.prefab ~= nil then --Stops the odd first load loop
		inst.AnimState:PlayAnimation("idle")
		inst.entity:Show()
		sayVoiceBox(inst, "I am the great Troupple King!")
		splashBigFx(inst)
		if inst.kingHolder.plantKeeper.prefab ~= nil then
			inst.kingHolder.plantKeeper:PushEvent("splashWater")
		end
	end
end

local function onfishedup(inst)
	trouppleKingShake(inst, 4)
	splashBigFx(inst)
	inst:DoTaskInTime(2, fishybehaviorgreet)
end

local function OnIsDay(inst, isday)
    if isday ~= inst.dayspawn then
       inst:DoTaskInTime(3, fishybehaviorfarewell)
    end
end

local function OnSnowLevel(inst, snowlevel, thresh)
	thresh = thresh or .02
	
	if inst.snowThresh ~= nil and inst.snowThresh > snowlevel then
		snowlevel = inst.snowThresh
		inst.snowThresh = nil
	end
	
	if snowlevel > thresh then
		inst:DoTaskInTime(0.5, fishybehaviorcold)
	else
		inst:DoTaskInTime(0.5, onfishedup)
	end
end

local function hasEvent(inst)
	if inst.kingHolder.kingEvent == 1 then
		--inst:AddComponent("workable")
		--inst.components.workable:SetWorkAction(ACTIONS.CHOP)
		--inst.components.workable:SetOnWorkCallback(chop_tree)
		--inst.components.workable:SetOnFinishCallback(chop_down_tree)
		--inst.AnimState:OverrideSymbol("eye", "skstructuretreetroupplefeature", "eye") --Orb thing
	else

	end
end

local function createVoiceBox(inst)
	local voiceBox = SpawnPrefab("skeventtroupplefish")
	local posSpawn = inst:GetPosition()
	voiceBox.Transform:SetPosition(posSpawn.x, posSpawn.y, posSpawn.z)
	voiceBox.Transform:SetScale(1.7, 1.7, 1.7)
	voiceBox.entity:Hide()
	inst.voiceBoxKeeper = voiceBox
end

local function onload(inst, data, newents)
	if inst.kingHolder.prefab ~= nil then
		hasEvent(inst)
	end
	createVoiceBox(inst)
	OnSnowLevel(inst, TheWorld.state.snowlevel)
	
end

local function ontradeforgold(inst, item)
    --inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingThrowGold")
    
    --for k = 1, item.components.tradable.goldvalue do
        --local nug = SpawnPrefab("goldnugget")
        --local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0, 4.5, 0)
        
        --nug.Transform:SetPosition(pt:Get())
        --local down = TheCamera:GetDownVec()
        --local angle = math.atan2(down.z, down.x) + (math.random() * 60 - 30) * DEGREES
        --local angle = (math.random() * 60 - 30 - TUNING.CAM_ROT - 90) / 180 * PI
        --local sp = math.random() * 4 + 2
        --nug.Physics:SetVel(sp * math.cos(angle), math.random() * 2 + 8, sp * math.sin(angle))
    --end
end

local function OnGetItemFromPlayer(inst, giver, item)
    if item.components.tradable.goldvalue > 0 then
        --inst.AnimState:PlayAnimation("cointoss")
        --inst.AnimState:PushAnimation("happy")
        --inst.AnimState:PushAnimation("idle", true)
        inst:DoTaskInTime(20/30, ontradeforgold, item)
       -- inst:DoTaskInTime(1.5, onplayhappysound)
       -- inst.happy = true
        --if inst.endhappytask ~= nil then
            --inst.endhappytask:Cancel()
        --end
        --inst.endhappytask = inst:DoTaskInTime(5, onendhappytask)
    end
end

local function OnRefuseItem(inst, giver, item)
	sayVoiceBox(inst, "No thanks!")
	--inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingReject")
    --inst.AnimState:PlayAnimation("unimpressed")
	--inst.AnimState:PushAnimation("idle", true)
	--inst.happy = false
end

local function AcceptTest(inst, item)
    return item.components.tradable.goldvalue > 0
end

local function fn()
 
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()

	inst.Transform:SetScale(5, 5, 5)
	
	MakeObstaclePhysics(inst, 4.8, .5)
	
	inst:AddTag("largecreature")
	
	anim:SetBank("fish")
    anim:SetBuild("skitemtroupplefishking")
    anim:PlayAnimation("idle")
	--anim:SetBuild("skitemtroupplefishkinglay")
    --anim:PlayAnimation("dead", true)
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
	inst.Physics:SetActive(false)
	inst.build = "skitemtroupplefishking"
	
	inst.kingHolder = ""
	inst.frozen = false
	inst.snowThresh = nil
	
	--Used for angry at fishing
	inst.catcher = ""
	
	--Voice Box
	inst.voiceBoxKeeper = ""
	
	inst.persists = false
     
	inst:AddComponent("inspectable")
	
	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(AcceptTest)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
	
	inst.dayspawn = true
	inst:WatchWorldState("isday", OnIsDay)
	inst:WatchWorldState("snowlevel", OnSnowLevel)
	inst.OnLoad = onload
	
	inst:DoTaskInTime(0.2, onload)
	
	MakeHauntableLaunch(inst)
		
    return inst
end

STRINGS.NAMES.SKITEMTROUPPLEFISHKING = "Troupple King"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMTROUPPLEFISHKING = "Ruler of the great Troupple Kingdom!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMTROUPPLEFISHKING = "What a huge looking apple... fish?!"


return  Prefab("common/objects/skitemtroupplefishking", fn, assets, prefabs)
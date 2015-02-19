local assets = 
{
   Asset("ANIM", "anim/skfxtroupplechalicebubble_blue.zip")
}
prefabs = {
}

--Blue Ichor functions
local function makemortal(inst, owner)
    owner.components.health:SetInvincible(false) 
end

local function makeinvincible(inst, owner)
    owner.components.health:SetInvincible(true) 
end

local function kill_fx(inst)
    inst.AnimState:PlayAnimation("close")
	inst.buffedOwner.trouppleChaliceBuff = nil
    inst:DoTaskInTime(0.6, inst.Remove)
end

local function onupdate(inst, dt)
	inst.buffedDuration = inst.buffedDuration - dt
	
	if inst.buffedDuration <= 0 then
		inst.buffedDuration = 0
		
		makemortal(inst, inst.buffedOwner) --Remove invincible
		
		if inst.buffedClock_Task ~= nil then
			inst.buffedClock_Task:Cancel()
			inst.buffedClock_Task = nil
		end
		kill_fx(inst)
	end
end

local function onlongupdate(inst, dt)
	inst.buffedDuration = math.max(0, inst.buffedDuration - dt)
end

local function startovercharge(inst, duration)
	if duration == inst.buffedDurationTotal then
		inst.buffedDuration = duration
	end
	
	if inst.buffedClock_Task == nil then
        inst.buffedClock_Task = inst:DoPeriodicTask(1, onupdate, nil, 1)
        onupdate(inst, 0)
    end
end

local function onactivate(inst)
	if inst.buffedOwner.prefab ~= nil then --Stops the odd first load loop
		startovercharge(inst, inst.buffedDurationTotal)
		makeinvincible(inst, inst.buffedOwner)
	end
end

local function onstart(inst)
	inst:DoTaskInTime(0.1, onactivate)
end

local function fn(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetBank("forcefield")
    inst.AnimState:SetBuild("skfxtroupplechalicebubble_blue")
    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("idle_loop", true)

	inst.Transform:SetScale(0.6, 0.6, 0.6)
	
	inst.SoundEmitter:PlaySound("dontstarve/wilson/forcefield_LP", "loop")

    inst.buffedOwner = ""
	inst.buffedDurationTotal = 10 --10 sec
	inst.buffedDuration = 0
	inst.buffedClock_Task = nil
	
	inst.OnLongUpdate = onlongupdate
	inst.OnLoad = kill_fx
	inst:DoTaskInTime(0.1, onstart)
	
    return inst
end

return Prefab("common/inventory/skfxtroupplechalice_blue", fn, assets, prefabs)
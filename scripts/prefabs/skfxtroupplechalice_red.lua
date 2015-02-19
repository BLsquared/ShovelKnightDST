local assets = 
{
   Asset("ANIM", "anim/skfxtroupplechalicebubble_red.zip")
}
prefabs = {
}

local function healthtoheal (inst,owner)
	inst.buffedOwnerHealthHeal = owner.components.health.maxhealth / 9
end

local function sanitytoheal(inst, owner)
	inst.buffedOwnerSanityHeal = owner.components.sanity.max / 9
end

--Red Ichor functions
local function healup(inst, owner, destroy)
    owner.components.health:DoDelta(inst.buffedOwnerHealthHeal)
	--local bonusSanityMax = bonusSanityPerk(owner)
	owner.components.sanity:DoDelta(inst.buffedOwnerSanityHeal)
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
		healthtoheal(inst, inst.buffedOwner)
		sanitytoheal(inst, inst.buffedOwner)
		inst.task = inst:DoPeriodicTask(0.33, healup, nil, inst.buffedOwner)
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
    inst.AnimState:SetBuild("skfxtroupplechalicebubble_red")
    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("idle_loop", true)

	inst.Transform:SetScale(0.6, 0.6, 0.6)
	
	inst.SoundEmitter:PlaySound("dontstarve/wilson/forcefield_LP", "loop")

    inst.buffedOwner = ""
	inst.buffedDurationTotal = 3 --3 sec
	inst.buffedDuration = 0
	inst.buffedClock_Task = nil
	
	--Restore Stuff
	inst.buffedOwnerHealthHeal = 0
	inst.buffedOwnerSanityHeal = 0
	
	inst.OnLongUpdate = onlongupdate
	inst.OnLoad = kill_fx
	inst:DoTaskInTime(0.1, onstart)
	
    return inst
end

return Prefab("common/inventory/skfxtroupplechalice_red", fn, assets, prefabs)
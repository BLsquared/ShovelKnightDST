local assets = 
{
   Asset("ANIM", "anim/skfxtroupplechalicebubble_yellow.zip")
}
prefabs = {
}

--Yellow Ichor functions
local function getitem(player, amulet, item, destroy)
    --Ichor Effect will only ever pick up items one at a time. Even from stacks.
    local fx = SpawnPrefab("small_puff")
    fx.Transform:SetPosition(item.Transform:GetWorldPosition())
    fx.Transform:SetScale(0.5, 0.5, 0.5)
        
	if item.components.stackable then
		item = item.components.stackable:Get()
	end
        
	if item.components.trap and item.components.trap:IsSprung() then
		item.components.trap:Harvest(player)
		return
	end
        
	player.components.inventory:GiveItem(item)
end

local function pickup(inst, owner, destroy)
    local pt = owner:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 4)

    for k,v in pairs(ents) do
        if v.components.inventoryitem and v.components.inventoryitem.canbepickedup and v.components.inventoryitem.cangoincontainer and not
            v.components.inventoryitem:IsHeld() then

            if not owner.components.inventory:IsFull() then
                --Your inventory isn't full, you can pick something up.
                getitem(owner, inst, v, destroy)
                if not destroy then return end

            elseif v.components.stackable then
                --Your inventory is full, but the item you're trying to pick up stacks. Check for an exsisting stack.
                --An acceptable stack should: Be of the same item type, not be full already and not be in the "active item" slot of inventory.
                local stack = owner.components.inventory:FindItem(function(item) return (item.prefab == v.prefab and not item.components.stackable:IsFull()
                    and item ~= owner.components.inventory.activeitem) end)
                if stack then
                    getitem(owner, inst, v, destroy)
                    if not destroy then return end
                end
            elseif destroy then
                getitem(owner, inst, v, destroy)
            end
        end
    end
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
		inst.task = inst:DoPeriodicTask(0.33, pickup, nil, inst.buffedOwner)
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
    inst.AnimState:SetBuild("skfxtroupplechalicebubble_yellow")
    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("idle_loop", true)

	inst.Transform:SetScale(0.6, 0.6, 0.6)
	
	inst.SoundEmitter:PlaySound("dontstarve/wilson/forcefield_LP", "loop")

    inst.buffedOwner = ""
	inst.buffedDurationTotal = 120 --1min
	inst.buffedDuration = 0
	inst.buffedClock_Task = nil
	
	inst.OnLongUpdate = onlongupdate
	inst.OnLoad = kill_fx
	inst:DoTaskInTime(0.1, onstart)
	
    return inst
end

return Prefab("common/inventory/skfxtroupplechalice_yellow", fn, assets, prefabs)
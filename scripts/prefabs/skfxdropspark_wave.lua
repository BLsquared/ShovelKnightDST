local assets =
{
	Asset("ANIM", "anim/skfxdropspark_attack.zip"),
	Asset("SOUND", "sound/chess.fsb"),
}

local function shovelbladeRangeResetAnim(inst, owner)
	if inst.owner == owner then
		owner.dropSparkActive = false
		if owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil then
			local equipped = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if equipped ~= nil then
				if equipped.prefab == "skweaponshovelbladedropspark" then
					if owner.components.health.currenthealth == owner.components.health.maxhealth then
						equipped.components.weapon.attackrange = equipped.normalRangedRange
					else
						equipped.components.weapon.attackrange = equipped.normalMeleeRange
					end
				end
			end
		end
	end
end

local function shovelbladeRangeReset(inst, owner, target)
	if inst.owner == owner then
		owner.dropSparkActive = false
		if owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil then
			local equipped = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if equipped ~= nil then
				if equipped.prefab == "skweaponshovelbladedropspark" then
					if owner.components.health.currenthealth == owner.components.health.maxhealth then
						equipped.components.weapon.attackrange = equipped.normalRangedRange
					else
						equipped.components.weapon.attackrange = equipped.normalMeleeRange
					end
				end
			end
		end
	end
end

local function OnHit(inst, owner, target)
	--Reset Shovelblade
	--shovelbladeRangeReset (inst, owner, target)

	
	target.components.health:DoDelta(-(inst.projDamage + inst.projDamageBounus))
    SpawnPrefab("skfxdropspark_wave_hit").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function OnMiss(inst, owner, target)
	--Reset Shovelblade
	--shovelbladeRangeReset (inst, owner, target)
	
    --local pt = Vector3(inst.Transform:GetWorldPosition())

    --local poop = SpawnPrefab("poop")
    --poop.Transform:SetPosition(pt.x, pt.y, pt.z)

    inst:Remove()
end

--local function OnAnimOver(inst, owner)
	--inst.owner.dropSparkActive = false
	--inst:DoTaskInTime(0, inst.Remove)
--end

--local function OnThrown(inst)
    --inst:ListenForEvent("animover", OnAnimOver)
--end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst.Transform:SetFourFaced()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("bishop_attack")
    inst.AnimState:SetBuild("skfxdropspark_attack")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("projectile")
	
    inst.persists = false

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(5)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(.2)
    inst.components.projectile:SetOnHitFn(OnHit)
	inst.components.projectile:SetOnMissFn(OnMiss)
    --inst.components.projectile:SetOnMissFn(inst.Remove)
    --inst.components.projectile:SetOnThrownFn(OnThrown)
	inst.components.projectile.range = 20
	--inst.components.projectile:SetLaunchOffset()
	
	inst.owner = nil
	inst.projDamage = 5
	inst.projDamageBounus = 0
	
    return inst
end

--local function PlayHitSound(proxy)
    --local inst = CreateEntity()

    --[[Non-networked entity]]

    --inst.entity:AddTransform()
    --inst.entity:AddSoundEmitter()

    --inst.Transform:SetFromProxy(proxy.GUID)

    --inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shotexplo")

    --inst:Remove()
--end

local function hit_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        --Delay one frame in case we are about to be removed
        --inst:DoTaskInTime(0, PlayHitSound)
    end

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddTag("FX")
    inst.persists = false
    inst:DoTaskInTime(0.5, inst.Remove)

	
	
    return inst
end

return Prefab("common/inventory/skfxdropspark_wave", fn, assets),
    Prefab("common/inventory/skfxdropspark_wave_hit", hit_fn)
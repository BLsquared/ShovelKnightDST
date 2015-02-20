local assets =
{
	Asset("ANIM", "anim/skfxdropspark_attack.zip"),
	Asset("SOUND", "sound/chess.fsb"),
}

local function OnHit(inst, owner, target)
	--Deals the damage
	target.components.combat:GetAttacked(owner, (inst.projDamage + inst.projDamageBonus), nil)
	
	--Create special Animation + hit sound
    SpawnPrefab("skfxdropspark_wave_hit").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

--Keep for template for other Projs
--local function OnMiss(inst, owner, target)
    --inst:Remove()
--end

local function OnThrown(inst, data)
	--Give it light
	inst.Light:Enable(true)
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(197 / 255, 197 / 255, 50 / 255)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetRadius(2)
    --inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	inst.entity:AddLight()
	
	inst.Transform:SetFourFaced()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetBank("skfxdropspark_attack")
    inst.AnimState:SetBuild("skfxdropspark_attack")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("projectile")
	
    inst.persists = false

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(6)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(.01) --Hitbox
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetOnThrownFn(OnThrown)
	inst.components.projectile.range = 20 --How far it will go if it misses
	
	inst.owner = nil
	inst.projDamage = 10 --1/3 the damage of the Shovelblade
	inst.projDamageBonus = 0 --Bonus damage from armor perk
	
    return inst
end

local function PlayHitSound(proxy)
    local inst = CreateEntity()

    --[[Non-networked entity]]

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shotexplo")

    inst:Remove()
end

local function hit_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        --Delay one frame in case we are about to be removed
        inst:DoTaskInTime(0, PlayHitSound)
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
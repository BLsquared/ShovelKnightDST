local assets =
{
	Asset("ANIM", "anim/skfxichor_yellow.zip"),
	Asset("SOUND", "sound/beefalo.fsb"),
}

local function OnHit(inst, owner, target)
	inst.SoundEmitter:PlaySound("dontstarve/creatures/spat/spit_hit")
    inst:Remove()
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	
	inst.Transform:SetFourFaced()
	inst.Transform:SetScale(1.5, 1.5, 1.5)

	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetBank("skfxichor")
    inst.AnimState:SetBuild("skfxichor_yellow")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("projectile")
	
    inst.persists = false

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(5)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetHitDist(.01) --Hitbox
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(inst.Remove)
	
	inst.owner = nil
	
    return inst
end

return Prefab("common/inventory/skfxichor_yellow", fn, assets)
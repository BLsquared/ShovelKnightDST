local assets =
{
	Asset("ANIM", "anim/skfxchargehandle_shatter.zip"),
}

local function fn(sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetBank("frozen_shatter")
    inst.AnimState:SetBuild("skfxchargehandle_shatter")
    inst.AnimState:PlayAnimation("small")
	
    inst.persists = false
    return inst
end

return Prefab("common/inventory/skfxchargehandle_shatter", fn, assets)
local assets =
{
	Asset("ANIM", "anim/skstructuresign.zip"),
}
    
local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)
    
    inst.AnimState:SetBank("sign_home")
    inst.AnimState:SetBuild("skstructuresign")
    inst.AnimState:PlayAnimation("idle")

    MakeSnowCoveredPristine(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

	inst.persists = false
	
    inst:AddComponent("inspectable")

 	MakeSnowCovered(inst)

    return inst
end

STRINGS.NAMES.SKSTRUCTURESIGNTROUPPLE = "Old Sign"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKSTRUCTURESIGNTROUPPLE = "Troupple Pond: No Fishing Allowed"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKSTRUCTURESIGNTROUPPLE = "Troupple Pond: No Fishing Allowed"

return Prefab("common/objects/skstructuresigntroupple", fn, assets)
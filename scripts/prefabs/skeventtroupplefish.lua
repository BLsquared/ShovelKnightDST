local assets =
{
	Asset("ANIM", "anim/skitemtroupplefish.zip"),
	Asset("ANIM", "anim/skitemtroupplefishlay.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skitemtroupplefish.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemtroupplefish.tex"),
}
    
local function fn()
 
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()
	
	MakeObstaclePhysics(inst, 0.1)
	
	anim:SetBank("fish")
    anim:SetBuild("skitemtroupplefish")
    anim:PlayAnimation("idle")
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
	inst.persists = false
	
	inst:AddComponent("talker")
	
    return inst
end

return  Prefab("common/objects/skeventtroupplefish", fn, assets)
local assets=
{
    Asset("ANIM", "anim/skitemmealtickettest.zip"),
 
    Asset("ATLAS", "images/inventoryimages/skitemmealtickettest.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemmealtickettest.tex"),
}
prefabs = {
}

local function setonuse(inst)
	local owner = inst.components.inventoryitem.owner
	--if owner ~= nil then
		--if owner == "winston" then
			--owner.components.talker:Say(GetString(owner, "ANNOUNCE_SKITEMMEALTICKETFOUNDTWO"))
		--end
	--else
		inst.components.useableitem:StopUsingItem()
	--end
end

local function fn()
 
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
    MakeInventoryPhysics(inst)
     
    anim:SetBank("skitemtemplate")
    anim:SetBuild("skitemmealtickettest")
    anim:PlayAnimation("idle", true)
     
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemmealtickettest.xml"
	inst.components.inventoryitem.imagename = "skitemmealtickettest"
     
	inst:AddComponent("inspectable")
	
	--inst.AddComponent("useableitem")
	--inst.components.useableitem:SetOnUseFn(setonuse)
	
    return inst
end


STRINGS.NAMES.SKITEMMEALTICKETTEST = "skitemmealtickettest"
--STRINGS.CHARACTERS.DROK.DESCRIBE.REDPAINT = "Drok use to paint!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMMEALTICKETTEST = "It looks primitive."


return  Prefab("common/inventory/skitemmealtickettest", fn, assets, prefabs)
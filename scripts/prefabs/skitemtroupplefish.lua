local assets=
{
    Asset("ANIM", "anim/skitemtroupplefish.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skitemtroupplefish.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemtroupplefish.tex"),
}

prefabs = {
}

local function gounderwater(inst)
    --inst.AnimState:PlayAnimation("idle")
	
	--Adds a neat splash effect
	local fx = SpawnPrefab("splash")
    local pos = inst:GetPosition()
    fx.Transform:SetPosition(pos.x, pos.y, pos.z)
	inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
	inst:Remove()
end

local function getPlayerChalice(inst, itemName, owner)
	
	for k, v in pairs(owner.components.inventory.itemslots) do
        if v and v.prefab == itemName then
                inst.catcherChaliceSlot = k
				break
        end
    end

    --if inst.catcher.components.inventory.activeitem andinst.catcher.components.inventory.activeitem.prefab == item then
        --if self.activeitem.components.stackable ~= nil then
            --num_found = num_found + self.activeitem.components.stackable:StackSize()
        --else
            --num_found = num_found + 1
        --end
    --end

    --local overflow = inst.catcher.components.inventory:GetOverflowContainer()
    --if overflow ~= nil then
        --local overflow_enough, overflow_found = overflow:Has(item, amount)
        --num_found = num_found + overflow_found
    --end
	
end

local function fishybehaviorinspect(inst)
	--inst.components.talker:Say("Lets see if you have a Troupple Chalice!")
	
	--Check for Chalice
	--local chaliceItem = spa
	--getPlayerChalice(inst, "log", inst.catcher)
	if inst.catcherChaliceSlot ~= nil then
		inst.components.talker:Say("You have an Empty Troupple Chalice!")
	else
		gounderwater(inst)
	end
	--local chaliceItem = 
	--inst.SoundEmitter:PlaySound("dontstarve/common/wendy")
	--inst:DoTaskInTime(2, fishybehaviorstill)
end

local function fishybehaviorgreet(inst)
	inst.components.talker:Say("Well hello "..inst.catcher)
	--inst.SoundEmitter:PlaySound("dontstarve/common/wendy")
	inst:DoTaskInTime(3, fishybehaviorinspect)
end


local function onfishedup(inst)
	--Fish stuff
	--
	inst.catcherChaliceSlot = nil
	inst:DoTaskInTime(1, fishybehaviorgreet)
end

local function fn()
 
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()
	
	inst.Transform:SetFourFaced()
	
	if not TheWorld.ismastersim then
        return inst
    end
	MakeInventoryPhysics(inst)
	
	anim:SetBank("fish")
    anim:SetBuild("skitemtroupplefish")
    anim:PlayAnimation("idle", true)
	
	inst.entity:SetPristine()
	MakeHauntableLaunch(inst)
    
	--inst.Transform:SetScale(4, 4, 4)
	inst.Physics:SetActive(false)
	inst.build = "skitemtroupplefish"
	
	inst.catcher = ""
	
	inst:AddComponent("talker")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemtroupplefish.xml"
	inst.components.inventoryitem.imagename = "skitemtroupplefish"
     
	inst:AddComponent("inspectable")
	
	inst.OnLoad = gounderwater
	
	inst:DoTaskInTime(1, onfishedup)
	
    return inst
end


STRINGS.NAMES.SKITEMTROUPPLEFISH = "Troupple Fish"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMTROUPPLEFISH = "A citizen of the great Troupple Kingdom!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMTROUPPLEFISH = "What a strange looking apple... fish?"


return  Prefab("common/inventory/skitemtroupplefish", fn, assets, prefabs)
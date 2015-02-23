local assets=
{
    Asset("ANIM", "anim/skrelictroupplechalice.zip"),
 
    Asset("ATLAS", "images/inventoryimages/skrelictroupplechalice.xml"),
    Asset("IMAGE", "images/inventoryimages/skrelictroupplechalice.tex"),
	
	Asset("ATLAS", "images/inventoryimages/skrelictroupplechalicelocked.xml"),
    Asset("IMAGE", "images/inventoryimages/skrelictroupplechalicelocked.tex"),
}
prefabs = {
}

local function setstopuse(inst, owner)
	inst.components.useableitem:StopUsingItem()
end
	
local function setonuse(inst)
	local owner = inst.components.inventoryitem.owner
	if owner ~= nil then
		if owner.prefab == "winston" then
			if owner.relicDebuffTime <= 0 then
				if owner.components.sanity.current >= inst.relicCastCost then
				
					owner.components.talker:Say("This Troupple Chalice is empty, need to refill it.")
	
					owner:PushEvent("castrelic") --Starts the cooldown at winston:onrelic(inst)
				else
					--owner.components.talker:Say("Don't have enough Sanity to cast Relic.")
				end
			else
				--owner.components.talker:Say("Relic still on cooldown.") --Add a sound effect?
			end
		else
			owner.components.talker:Say("It is empty and smells odd...")
		end
	end
	inst.components.useableitem:StopUsingItem()
end

local function onequip(inst, owner) 
	setstopuse(inst, owner)
end

local function onunequip(inst, owner)
	inst.components.inventoryitem.atlasname = "images/inventoryimages/skrelictroupplechalice.xml"
	inst.components.inventoryitem:ChangeImageName("skrelictroupplechalice")
	setstopuse(inst, owner)
end

local function fn()
 
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()
	
    MakeInventoryPhysics(inst)
     
    anim:SetBank("skrelictroupplechalice")
    anim:SetBuild("skrelictroupplechalice")
    anim:PlayAnimation("idle")
    
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
	--Relic Stats
	inst.relicCastCost = 0 --How much Sanity Cost to Cast
	
	inst:AddComponent("inspectable")
		
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skrelictroupplechalice.xml"
	inst.components.inventoryitem.imagename = "skrelictroupplechalice"
	
	inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	inst:AddComponent("useableitem")
	inst.components.useableitem:SetOnUseFn(setonuse)
	
	inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 1
	
	MakeHauntableLaunch(inst)
	
    return inst
end


STRINGS.NAMES.SKRELICTROUPPLECHALICE = "Troupple Chalice"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKRELICTROUPPLECHALICE = "A vessel for storing mythical Ichor."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKRELICTROUPPLECHALICE = "A rather large drinking glass."


return  Prefab("common/inventory/skrelictroupplechalice", fn, assets, prefabs)
local assets=
{
    Asset("ANIM", "anim/skrelictroupplechaliceblue.zip"),
 
    Asset("ATLAS", "images/inventoryimages/skrelictroupplechaliceblue.xml"),
    Asset("IMAGE", "images/inventoryimages/skrelictroupplechaliceblue.tex"),
	
	Asset("ATLAS", "images/inventoryimages/skrelictroupplechalicebluelocked.xml"),
    Asset("IMAGE", "images/inventoryimages/skrelictroupplechalicebluelocked.tex"),
}
prefabs = {
}

--Replace with Empty Troupple Chalice
local function equipTrouppleChalice(inst, owner)
	inst.components.inventoryitem:RemoveFromOwner(true)
	
    local emptyTrouppleChalice = SpawnPrefab("skrelictroupplechalice")
	owner.components.inventory:Equip(emptyTrouppleChalice)
end

local function useTrouppleChalice(inst, owner)
	if owner.trouppleChaliceBuff ~= nil then
		--Special Blue Ichor remover
		if owner.trouppleChaliceBuff.prefab == "skfxtroupplechalice_blue" then
			owner.components.health:SetInvincible(false)
		end
		owner.trouppleChaliceBuff:Remove()
		owner.trouppleChaliceBuff = nil
	end
	
	if owner.trouppleChaliceBuff == nil then
		local trouppleChalicefx = SpawnPrefab("skfxtroupplechalice_blue")
		trouppleChalicefx.entity:SetParent(owner.entity)
		trouppleChalicefx.Transform:SetPosition(0, 0.2, 0)
		trouppleChalicefx.buffedOwner = owner
		
		owner.trouppleChaliceBuff = trouppleChalicefx
	end
end

local function setstopuse(inst, owner)
	inst.components.useableitem:StopUsingItem()
end
	
local function setonuse(inst)
	local owner = inst.components.inventoryitem.owner
	if owner ~= nil then
		if owner.prefab == "winston" then
			if owner.relicDebuffTime <= 0 then
				if owner.components.sanity.current >= inst.relicCastCost then
				
					--Special Runic Feature
					useTrouppleChalice(inst, owner) --This Ichor special effect
	
					owner:PushEvent("castrelic") --Starts the cooldown at winston:onrelic(inst)
					
					--Needed Relic stuff
					equipTrouppleChalice(inst, owner) --Replace with Empty Troupple Chalice
				else
					--owner.components.talker:Say("Don't have enough Sanity to cast Relic.")
				end
			else
				--owner.components.talker:Say("Relic still on cooldown.") --Add a sound effect?
			end
		else
			owner.components.talker:Say("No way I am drinking that!")
		end
	end
	inst.components.useableitem:StopUsingItem()
end

local function onequip(inst, owner) 
	setstopuse(inst, owner)
end

local function onunequip(inst, owner)
	inst.components.inventoryitem.atlasname = "images/inventoryimages/skrelictroupplechaliceblue.xml"
	inst.components.inventoryitem:ChangeImageName("skrelictroupplechaliceblue")
	setstopuse(inst, owner)
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
	MakeHauntableLaunch(inst)
	
    MakeInventoryPhysics(inst)
     
    anim:SetBank("skrelictroupplechalice")
    anim:SetBuild("skrelictroupplechaliceblue")
    anim:PlayAnimation("idle")
    
	--Relic Stats
	inst.relicCastCost = 0 --How much Sanity Cost to Cast
	
	inst:AddComponent("inspectable")
		
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skrelictroupplechaliceblue.xml"
	inst.components.inventoryitem.imagename = "skrelictroupplechaliceblue"
    
	inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	inst:AddComponent("useableitem")
	inst.components.useableitem:SetOnUseFn(setonuse)
	
	inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 2
	
    return inst
end


STRINGS.NAMES.SKRELICTROUPPLECHALICEBLUE = "Ichor of Boldness"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKRELICTROUPPLECHALICEBLUE = "Become invincible for a few seconds."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKRELICTROUPPLECHALICEBLUE = "A rather large drinking glass, filled with..."


return  Prefab("common/inventory/skrelictroupplechaliceblue", fn, assets, prefabs)
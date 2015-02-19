local assets=
{
    Asset("ANIM", "anim/skrelictroupplechalicered.zip"),
 
    Asset("ATLAS", "images/inventoryimages/skrelictroupplechalicered.xml"),
    Asset("IMAGE", "images/inventoryimages/skrelictroupplechalicered.tex"),
	
	Asset("ATLAS", "images/inventoryimages/skrelictroupplechaliceredlocked.xml"),
    Asset("IMAGE", "images/inventoryimages/skrelictroupplechaliceredlocked.tex"),
}
prefabs = {
}

--Max Sanity Booster
local function bonusSanityPerk(owner)
	local bonusSanity = 0
	if owner.components.inventory.equipslots[EQUIPSLOTS.BODY] ~= nil then
		local item = owner.components.inventory.equipslots[EQUIPSLOTS.BODY]
		if item.prefab == "skarmorconjurerscoat" then
			bonusSanity = item.armorSanityMaxBooster --Saved on the Shovel Knight Armor
		end
	end
	return bonusSanity
end

--Replace with Empty Troupple Chalice
local function equipTrouppleChalice(inst, owner)
	inst.components.inventoryitem:RemoveFromOwner(true)
	
    local emptyTrouppleChalice = SpawnPrefab("skrelictroupplechalice")
	owner.components.inventory:Equip(emptyTrouppleChalice)
end

local function useTrouppleChalice(inst, owner)
	owner.components.health:DoDelta((owner.mealTicket*15)+80)
	local bonusSanityMax = bonusSanityPerk(owner)
	owner.components.sanity:DoDelta((owner.manaPotion*10)+120 +bonusSanityMax)
	
	--Needs FX Here
	
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
	inst.components.inventoryitem.atlasname = "images/inventoryimages/skrelictroupplechalicered.xml"
	inst.components.inventoryitem:ChangeImageName("skrelictroupplechalicered")
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
    anim:SetBuild("skrelictroupplechalicered")
    anim:PlayAnimation("idle")
    
	--Relic Stats
	inst.relicCastCost = 0 --How much Sanity Cost to Cast
	
	inst:AddComponent("inspectable")
		
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skrelictroupplechalicered.xml"
	inst.components.inventoryitem.imagename = "skrelictroupplechalicered"
    
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


STRINGS.NAMES.SKRELICTROUPPLECHALICERED = "Ichor of Renewal"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKRELICTROUPPLECHALICERED = "Refills all health and Sanity."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKRELICTROUPPLECHALICERED = "A rather large drinking glass, filled with..."


return  Prefab("common/inventory/skrelictroupplechalicered", fn, assets, prefabs)
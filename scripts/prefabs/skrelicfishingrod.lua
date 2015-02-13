local assets=
{
    Asset("ANIM", "anim/skrelicfishingrod.zip"),
 
    Asset("ATLAS", "images/inventoryimages/skrelicfishingrod.xml"),
    Asset("IMAGE", "images/inventoryimages/skrelicfishingrod.tex"),
	
	Asset("ATLAS", "images/inventoryimages/skrelicfishingrodlocked.xml"),
    Asset("IMAGE", "images/inventoryimages/skrelicfishingrodlocked.tex"),
}
prefabs = {
}

--Create a Magical Fishing Rod
local function equipFishingRod(inst, owner)
    local magicalFishingRod = SpawnPrefab("skitemfishingrod")
	magicalFishingRod.fishHolster = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) --stores old Equipped Item
	magicalFishingRod.fishOwner = owner
	owner.components.inventory:Equip(magicalFishingRod)
end

local function setstopuse(inst, owner)
	inst.components.useableitem:StopUsingItem()
end
	
local function setonuse(inst)
	local owner = inst.components.inventoryitem.owner
	if owner ~= nil then
		if owner.prefab == "winston" then
			local itemCurrent = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			
			--If Player is holding something
			if itemCurrent ~= nil then
				if owner.relicDebuffTime <= 0 and itemCurrent.prefab ~= "skitemfishingrod" then
					if owner.components.sanity.current >= inst.relicCastCost then
					
						--Needed Relic stuff
						inst.components.finiteuses:Use(1)
						owner.components.sanity:DoDelta(-inst.relicCastCost)--Reduce Sanity after casting
						--owner.components.talker:Say("Cast Relic "..inst.prefab.."!")
					
						--Special Runic Feature
						equipFishingRod(inst, owner)
	
						owner:PushEvent("castrelic") --Starts the cooldown at winston:onrelic(inst)
					else
						owner.components.talker:Say("Don't have enough Sanity to cast Relic.")
					end
				else
				--owner.components.talker:Say("Relic still on cooldown.") --Add a sound effect?
				end
				
			--If Player is Not holding something
			else
				if owner.relicDebuffTime <= 0 then
					if owner.components.sanity.current >= inst.relicCastCost then
					
						--Needed Relic stuff
						inst.components.finiteuses:Use(1)
						owner.components.sanity:DoDelta(-inst.relicCastCost)--Reduce Sanity after casting
					
						--Special Runic Feature
						equipFishingRod(inst, owner)
	
						owner:PushEvent("castrelic") --Starts the cooldown at winston:onrelic(inst)
					else
						owner.components.talker:Say("Don't have enough Sanity to cast Relic.")
					end
				else
				--owner.components.talker:Say("Relic still on cooldown.") --Add a sound effect?
				end
			end
		end
	end
	inst.components.useableitem:StopUsingItem()
end

local function onfinished(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
    inst:Remove()
end

local function onequip(inst, owner) 
	setstopuse(inst, owner)
end

local function onunequip(inst, owner)
	inst.components.inventoryitem.atlasname = "images/inventoryimages/skrelicfishingrod.xml"
	inst.components.inventoryitem:ChangeImageName("skrelicfishingrod")
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
     
    anim:SetBank("skrelicfishingrod")
    anim:SetBuild("skrelicfishingrod")
    anim:PlayAnimation("idle")
    
	--Relic Stats
	inst.relicCastCost = 6 --How much Sanity Cost to Cast
	
	inst:AddComponent("inspectable")
		
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skrelicfishingrod.xml"
	inst.components.inventoryitem.imagename = "skrelicfishingrod"
    
	inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	inst:AddComponent("useableitem")
	inst.components.useableitem:SetOnUseFn(setonuse)
	
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(50)
    inst.components.finiteuses:SetUses(50)
    inst.components.finiteuses:SetOnFinished(onfinished)
	
    return inst
end


STRINGS.NAMES.SKRELICFISHINGROD = "Fishing Rod"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKRELICFISHINGROD = "Cast into a pit, and wait for a bite!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKRELICFISHINGROD = "It looks very old."


return  Prefab("common/inventory/skrelicfishingrod", fn, assets, prefabs)
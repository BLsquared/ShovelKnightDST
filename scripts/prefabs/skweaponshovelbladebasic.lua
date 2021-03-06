local assets =
{
	Asset("ANIM", "anim/skweaponshovelbladebasic.zip"),
	Asset("ANIM", "anim/swap_skweaponshovelbladebasic.zip"),
	
	Asset("ATLAS", "images/inventoryimages/skweaponshovelbladebasic.xml"),
	Asset("IMAGE", "images/inventoryimages/skweaponshovelbladebasic.tex"),
	
	Asset("ATLAS", "images/map_icons/skweaponshovelbladebasic.xml"),
	Asset("IMAGE", "images/map_icons/skweaponshovelbladebasic.tex"),
}
prefabs = {
}

local nums = {"ONE", "TWO", "THREE", "FOUR" , "FIVE" , "SIX" , "SEVEN" , "EIGHT"}

local function GetEquipQuote(owner)
	local randomQuotePart = nums[math.random(#nums)]
	local randomQuote = "ANNOUNCE_SHOVELBLADE_EQUIP"..randomQuotePart
    return randomQuote
end

local function onpreload(inst, data)
    if data ~= nil and data.playEquippedSound ~= nil then
        inst.playEquippedSound = data.playEquippedSound
    end
end

local function onsave(inst, data)
	data.playEquippedSound = inst.playEquippedSound > 0 and inst.playEquippedSound or nil
end

local function fn(Sim)

	local function onequip(inst, owner)
		
		--Sets how strong this weapon is
		local shovelbladeDamageWinston = 30
		local shovelbladeDamageGeneric = 5
		
		owner.AnimState:OverrideSymbol("swap_object", "swap_skweaponshovelbladebasic", "swap_shovel")
		owner.AnimState:Show("ARM_carry") 
		owner.AnimState:Hide("ARM_normal") 
		
		--Makes the shovelblade strong only for Shovel Knight
		if owner.prefab == "winston" then
			inst.components.weapon:SetDamage(shovelbladeDamageWinston)
			
			owner.components.talker:Say(GetString(owner, GetEquipQuote(owner))) --Random Equip Quote
			
			--Plays special shovelblade EquippedSound
			inst.playEquippedSound = inst.playEquippedSound +1
			
			if inst.playEquippedSound == 1 then
				owner.SoundEmitter:PlaySound("winston/characters/winston/shovelbladeequipped")
			end
			if inst.playEquippedSound > 1 then --Stops the sound from player at load in
				inst.playEquippedSound = 0
			end
		end
		
		--Makes the shovelblade weak for other characters
		if owner.prefab ~= "winston" then
			inst.components.weapon:SetDamage(shovelbladeDamageGeneric)
		end
	end

	local function onunequip(inst, owner)
		inst.owner = nil
		inst.playEquippedSound = 0
		
		--Sets how strong this weapon is
		local shovelbladeDamageGeneric = 5
	
		owner.AnimState:Hide("ARM_carry") 
		owner.AnimState:Show("ARM_normal") 
		
		--Resets the Shovelblade damage back to normal
		inst.components.weapon:SetDamage(shovelbladeDamageGeneric)
	end
	
	local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()
	
	inst.MiniMapEntity:SetIcon("skweaponshovelbladebasic.tex")
	
    MakeInventoryPhysics(inst)

	inst:AddTag("irreplaceable")
	
    anim:SetBank("shovel")
    anim:SetBuild("skweaponshovelbladebasic")
    anim:PlayAnimation("idle", true)

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
    --Makes this a Tool with actions
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.DIG)

    --Makes this a Weapon
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(5)
	inst.playEquippedSound = 0
	
	inst.OnSave = onsave
	inst.OnPreLoad = onpreload
	
	--Makes this a Shovel
    inst:AddInherentAction(ACTIONS.DIG)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/skweaponshovelbladebasic.xml"
	inst.components.inventoryitem.imagename = "skweaponshovelbladebasic"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("winston")
	
	MakeHauntableLaunch(inst)
		
    return inst
end

STRINGS.NAMES.SKWEAPONSHOVELBLADEBASIC = "Shovelblade"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKWEAPONSHOVELBLADEBASIC = "Both a worthy weapon and a digging tool."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKWEAPONSHOVELBLADEBASIC = "A strange dirt moving tool..."

return Prefab("common/inventory/skweaponshovelbladebasic", fn, assets)
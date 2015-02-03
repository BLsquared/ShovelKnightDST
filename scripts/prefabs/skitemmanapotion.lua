local assets=
{
    Asset("ANIM", "anim/skitemmanapotion.zip"),
 
    Asset("ATLAS", "images/inventoryimages/skitemmanapotion.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemmanapotion.tex"),
}
prefabs = {
}

local function usemanapotion(inst, reader)
	if reader.manaPotion ~= nil then
		local manaPotionLVL = reader.manaPotion
		local manaPotionMAX = 8
		
		if manaPotionLVL < manaPotionMAX then
			reader.manaPotion = reader.manaPotion+1
			
			local manaPotionMAXM = 9
			local manaPotionFound = reader.manaPotion
			
			if reader.manaPotion < manaPotionMAXM then
				reader.components.sanity:SetMax((reader.manaPotion*10)+120)
				reader.components.sanity:DoDelta((reader.manaPotion*10)+120)
				inst.bookuses = 0
				
				--Shovel Knight Speaks
				if manaPotionFound == 1 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMANAPOTIONFOUNDONE"))
					elseif manaPotionFound == 2 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMANAPOTIONFOUNDTWO"))
					elseif manaPotionFound == 3 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMANAPOTIONFOUNDTHREE"))
					elseif manaPotionFound == 4 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMANAPOTIONFOUNDFOUR"))
					elseif manaPotionFound == 5 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMANAPOTIONFOUNDFIVE"))
					elseif manaPotionFound == 6 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMANAPOTIONFOUNDSIX"))
					elseif manaPotionFound == 7 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMANAPOTIONFOUNDSEVEN"))
					elseif manaPotionFound == 8 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMANAPOTIONMAX"))
				end
				inst.components.inventoryitem:RemoveFromOwner(true)
				return true
			end
		end
	end
	return false
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
     
    anim:SetBank("skitemmanapotion")
    anim:SetBuild("skitemmanapotion")
    anim:PlayAnimation("idle", true)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemmanapotion.xml"
	inst.components.inventoryitem.imagename = "skitemmanapotion"
     
	inst:AddComponent("inspectable")
	
	--Burn
	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	
	--Makes it a book
	inst:AddComponent("book")
    inst.components.book.onread = usemanapotion
	
	--Only Readable by Shovel Knight
	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("winston")

	MakeHauntableLaunch(inst)
	
    return inst
end


STRINGS.NAMES.SKITEMMANAPOTION = "Mana Potion"
--STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMMANAPOTION = "Is this even drinkable?"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMMANAPOTION = "Strange liquid in a bottle..."


return  Prefab("common/inventory/skitemmanapotion", fn, assets, prefabs)
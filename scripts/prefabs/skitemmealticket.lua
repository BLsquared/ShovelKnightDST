local assets=
{
    Asset("ANIM", "anim/skitemmealticket.zip"),
 
    Asset("ATLAS", "images/inventoryimages/skitemmealticket.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemmealticket.tex"),
}
prefabs = {
}

local function usemealticket(inst, reader)
	if reader.mealTicket ~= nil then
		local mealTicketLVL = reader.mealTicket
		local mealTicketMAX = 8
		
		if mealTicketLVL < mealTicketMAX then
			reader.mealTicket = reader.mealTicket+1
			
			local mealTicketMAXM = 9
			local mealTicketFound = reader.mealTicket
			
			if reader.mealTicket < mealTicketMAXM then
				reader.components.health:SetMaxHealth((reader.mealTicket*15)+80)
				reader.components.health:DoDelta((reader.mealTicket*15)+80)
				inst.bookuses = 0
				
				--Shovel Knight Speaks
				if mealTicketFound == 1 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMEALTICKETFOUNDONE"))
					elseif mealTicketFound == 2 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMEALTICKETFOUNDTWO"))
					elseif mealTicketFound == 3 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMEALTICKETFOUNDTHREE"))
					elseif mealTicketFound == 4 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMEALTICKETFOUNDFOUR"))
					elseif mealTicketFound == 5 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMEALTICKETFOUNDFIVE"))
					elseif mealTicketFound == 6 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMEALTICKETFOUNDSIX"))
					elseif mealTicketFound == 7 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMEALTICKETFOUNDSEVEN"))
					elseif mealTicketFound == 8 then
					reader.components.talker:Say(GetString(reader, "ANNOUNCE_SKITEMMEALTICKETMAX"))
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
     
    anim:SetBank("skitemmealticket")
    anim:SetBuild("skitemmealticket")
    anim:PlayAnimation("idle", true)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemmealticket.xml"
	inst.components.inventoryitem.imagename = "skitemmealticket"
     
	inst:AddComponent("inspectable")
	
	--Burn
	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	
	--Makes it a book
	inst:AddComponent("book")
    inst.components.book.onread = usemealticket
	
	--Only Readable by Shovel Knight
	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("winston")

	MakeHauntableLaunch(inst)
	
    return inst
end


STRINGS.NAMES.SKITEMMEALTICKET = "Meal Ticket"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMMEALTICKET = "A great meal awaits!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMMEALTICKET = "A golden food coupon?"


return  Prefab("common/inventory/skitemmealticket", fn, assets, prefabs)
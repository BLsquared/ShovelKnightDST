local assets=
{
    Asset("ANIM", "anim/skitemfishingrod.zip"),
    Asset("ANIM", "anim/swap_skitemfishingrod.zip"),
 
    Asset("ATLAS", "images/inventoryimages/skitemfishingrod.xml"),
    Asset("IMAGE", "images/inventoryimages/skitemfishingrod.tex"),
}
prefabs = {
}

--Random vaulable fishLoot list
local fishLootList = {
	"skitemtroupplefish", 
}

local fishRareLootList = {
	"skitemmusicsheet",
}

local function randomFishLootGen()
	return fishLootList[math.random(#fishLootList)]
end

local function randomFishRareLootGen()
	return fishRareLootList[math.random(#fishRareLootList)]
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_skitemfishingrod", "swap_fishingrod")
	owner.AnimState:OverrideSymbol("fishingline", "swap_skitemfishingrod", "fishingline")
	owner.AnimState:OverrideSymbol("FX_fishing", "swap_skitemfishingrod", "FX_fishing")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end
 
local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("fishingline")
    owner.AnimState:ClearOverrideSymbol("FX_fishing")
end

local function onfishholster(inst)
	if inst.fishHolster ~= nil and inst.fishOwner ~= nil then
		inst.fishOwner.components.inventory:Equip(inst.fishHolster)
	end
	inst:Remove()
end

local function onfishcatch(inst)
	local owner = inst.components.inventoryitem.owner
	
	--Adds a neat splash effect
	local fx = SpawnPrefab("splash")
    local pos = inst.components.fishingrod.target:GetPosition()
    fx.Transform:SetPosition(pos.x, pos.y, pos.z)
	inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
	
	if math.random() <= inst.fishLootChance then
		local fishLootGen = randomFishLootGen() --Finds a common random fishLoot
		if fishLootGen ~= nil then
			inst.components.fishingrod.target.components.fishable:RemoveFish(inst.components.fishingrod.caughtfish)
			inst.components.fishingrod.caughtfish = SpawnPrefab(fishLootGen)
			inst.fishLootFinal = fishLootGen
		end
	elseif math.random() <= inst.fishRareLootChance then
		local fishRareLootGen = randomFishRareLootGen() --Finds a rare random fishLoot
		if fishRareLootGen ~= nil then
			inst.components.fishingrod.target.components.fishable:RemoveFish(inst.components.fishingrod.caughtfish)
			inst.components.fishingrod.caughtfish = SpawnPrefab(fishRareLootGen)
			inst.fishLootFinal = fishRareLootGen
		end
		
	--elseif math.random() <= inst.fishVeryRareLootChance then
		--local fishVeryRareLootGen = "skitemtroupplefishking" --Very rare Troupple King summon
		--inst.components.fishingrod.caughtfish = SpawnPrefab(fishVeryRareLootGen)
		--inst.fishLootFinal = fishVeryRareLootGen
			
		--Do special effects
		--owner:ShakeCamera(CAMERASHAKE.SIDE, 4, .05, .1, inst, 40)
			
		--local fx2 = SpawnPrefab("splash")
		--local pos2 = inst.components.fishingrod.target:GetPosition()
		--fx2.Transform:SetPosition(pos2.x + 2, pos2.y + 2, pos2.z + 2)
		--inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
	
		--local fx3 = SpawnPrefab("splash")
		--local pos3 = inst.components.fishingrod.target:GetPosition()
		--fx3.Transform:SetPosition(pos3.x - 2, pos3.y - 2, pos3.z - 2)
		--inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
	end
end

local function onfished(inst)
	local owner = inst.components.inventoryitem.owner
	if inst.fishLootFinal ~= nil then
		inst.components.fishingrod.caughtfish:Remove()
		
		--Checks for Troupple fish Event
		if inst.fishLootFinal == "skitemtroupplefish" then
			local troupplefish = SpawnPrefab("skitemtroupplefish")
			troupplefish.catcher = inst.components.fishingrod.fisherman
			
			if troupplefish ~= nil then
				--Works but not the best, Would have to create an Entity + animations for better.
				local posSpawn = inst.components.fishingrod.target:GetPosition()
				troupplefish.Transform:SetPosition(posSpawn.x, posSpawn.y, posSpawn.z)
				rotatetotarget(troupplefish, owner)
				
				inst.fishLootFinal = nil
			end
			
		--Normal Loot Event
		else
			owner.components.inventory:DropItem(SpawnPrefab(inst.fishLootFinal), true, true)
			inst.fishLootFinal = nil
		end
	end
	
	--Equip old Hand Item
	if inst.fishHolster ~= nil then
		owner.components.inventory:Equip(inst.fishHolster)
	end
	
    inst.components.inventoryitem:RemoveFromOwner(true)
end

function rotatetotarget(troupplefish, dest)
	local current = Vector3(dest.Transform:GetWorldPosition() )
	local wanttogo = Vector3(troupplefish.Transform:GetWorldPosition() )
	local direction = (wanttogo - current ):GetNormalized()
    local angle = math.acos(direction:Dot(Vector3(1, 0, 0) ) ) / DEGREES
    troupplefish.Transform:SetRotation(angle)
end

local function fn()

    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    local sound = inst.entity:AddSoundEmitter()
	
	MakeInventoryPhysics(inst)
     
    anim:SetBank("skitemfishingrod")
    anim:SetBuild("skitemfishingrod")
    anim:PlayAnimation("idle")
	inst.AnimState:SetMultColour(1, 1, 1, 0.6)
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
    MakeHauntableLaunch(inst)
 
	--Fishingrod Stuff
	inst.fishLootChance = 0.4 --40% chance
	inst.fishRareLootChance = 0.1 --10% chance
	inst.fishVeryRareLootChance = 0.01 --1% chance
	inst.fishLootFinal = nil
	inst.fishHolster = nil
	inst.fishOwner = nil
	inst.fishyFish = nil
	
	inst:AddTag("show_spoilage")
	
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(20)
    inst.components.weapon:SetAttackCallback(onfishholster)

    inst:AddComponent("fishingrod")
    inst.components.fishingrod:SetWaitTimes(4, 40)
    inst.components.fishingrod:SetStrainTimes(0, 5)
	inst:ListenForEvent("fishingcatch", onfishcatch)
    inst:ListenForEvent("fishingcollect", onfished)
	
	
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skitemfishingrod.xml"
	inst.components.inventoryitem.imagename = "skitemfishingrod"
	inst.components.inventoryitem.cangoincontainer = false
	inst.components.inventoryitem:SetOnDroppedFn(onfishholster)
	
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(50)
	inst.components.perishable:StartPerishing()
	inst.components.perishable:SetOnPerishFn(onfishholster)
	
    return inst
end


STRINGS.NAMES.SKITEMFISHINGROD = "Magical Fishing Rod"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMFISHINGROD = "A fishing rod by with magic!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMFISHINGROD = "It looks primitive."


return  Prefab("common/inventory/skitemfishingrod", fn, assets, prefabs)
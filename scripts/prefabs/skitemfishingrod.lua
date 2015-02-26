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

local function trouppleKingShake(inst, pond)
    for i, v in ipairs(AllPlayers) do
        v:ShakeCamera(CAMERASHAKE.SIDE, 3, .05, .1, pond, 40)
    end
end

local function randomSplashFx(inst)
	local fx = SpawnPrefab("splash")
    local pos = inst.components.fishingrod.target:GetPosition()
	
	local a = math.random()*math.pi*2
	local x = math.sin(a)*1.4+math.random()*0.3
	local z = math.cos(a)*1.6+math.random()*0.3
	
	fx.Transform:SetPosition(pos.x + x, pos.y + 0, pos.z + z)
	inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
end

local function splashFx(inst)
	local fx = SpawnPrefab("splash")
    local pos = inst.components.fishingrod.target:GetPosition()

	fx.Transform:SetPosition(pos.x, pos.y, pos.z)
	inst.SoundEmitter:PlaySound("dontstarve/frog/splash")
end

local function onfishcatch(inst)
	local owner = inst.components.inventoryitem.owner
	
	if inst.components.fishingrod.target.prefab ~= "sktiletroupplepond" then
		--Adds a neat splash effect
		splashFx(inst)
		
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
			
		elseif math.random() <= inst.fishVeryRareLootChance then
			local fishVeryRareLootGen = "skitemtroupplefishking" --Very rare Troupple King summon
			inst.components.fishingrod.target.components.fishable:RemoveFish(inst.components.fishingrod.caughtfish)
			inst.components.fishingrod.caughtfish = SpawnPrefab(fishVeryRareLootGen)
			inst.fishLootFinal = fishVeryRareLootGen
		end
	end
end

local function onfished(inst)
	local owner = inst.components.inventoryitem.owner
	
	--Special Loot Creator
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
				
				--local dest = Vector3(inst.components.fishingrod.fisherman.Transform:GetWorldPosition() )
				rotatetotarget(troupplefish, owner)
				--troupplefish.Transform:SetRotation(180)
				--rotatetotarget(dest, troupplefish)
				
				
				inst.fishLootFinal = nil
			end
		
		--Checks for Troupple fish King Event
		elseif inst.fishLootFinal == "skitemtroupplefishking" then
			local troupplefishking = SpawnPrefab("skitemtroupplefishking")
			troupplefishking.catcher = inst.components.fishingrod.fisherman
			
			if troupplefishking ~= nil then
				--Works but not the best, Would have to create an Entity + animations for better.
				local posSpawn = inst.components.fishingrod.target:GetPosition()
				troupplefishking.Transform:SetPosition(posSpawn.x, posSpawn.y, posSpawn.z)
				
				--rotatetotarget(troupplefishking, owner)
				troupplefishking.entity:Hide()
				
				--Shake Screen
				trouppleKingShake(inst, inst.components.fishingrod.target)
				
				--if ThePlayer ~= nil then
					--ThePlayer:ShakeCamera(CAMERASHAKE.FULL, .7, .02, .5, proxy, 40)
				--end
				
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

--Old Hackish
function rotatetotarget(troupplefish, dest)
	local current = Vector3(dest.Transform:GetWorldPosition() )
	local wanttogo = Vector3(troupplefish.Transform:GetWorldPosition() )
	local direction = (wanttogo - current ):GetNormalized()
    local angle = math.acos(direction:Dot(Vector3(1, 0, 0) ) ) / DEGREES
    troupplefish.Transform:SetRotation(angle)
end

--Working on
--function rotatetotarget(dest, troupplefish)
    --local current = Vector3(troupplefish.Transform:GetWorldPosition() )
    --local direction = (dest - current):GetNormalized()
    --local angle = math.acos(direction:Dot(Vector3(1, 0, 0) ) ) / DEGREES
    --troupplefish.Transform:SetRotation(angle)
    --troupplefish:FacePoint(dest)
--end

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
 
	--Fishingrod Stuff
	inst.fishLootChance = 0.99 --40% chance
	inst.fishRareLootChance = 0.1 --10% chance
	inst.fishVeryRareLootChance = 0.99 --1% chance
	inst.fishLootFinal = nil
	inst.fishHolster = nil
	inst.fishOwner = nil
	
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
	
	MakeHauntableLaunch(inst)
		
    return inst
end


STRINGS.NAMES.SKITEMFISHINGROD = "Magical Fishing Rod"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKITEMFISHINGROD = "A fishing rod by with magic!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKITEMFISHINGROD = "It looks primitive."


return  Prefab("common/inventory/skitemfishingrod", fn, assets, prefabs)
--local MakeFx = require "prefabs/fx"

local assets =
{
	Asset("ANIM", "anim/skstructuretreetroupplerequired.zip"), --Bank: tree_leaf_monster
	Asset("ANIM", "anim/skstructuretreetrouppleleaf.zip"), --troupple fish top
	Asset("ANIM", "anim/skstructuretreetrouppleleafgreen.zip"), --green top
    Asset("ANIM", "anim/skstructuretreetrouppletrunk.zip"), --trunk build (winter leaves build)
	Asset("ANIM", "anim/skstructuretreetroupplefeature.zip"), --is the Legs
	
	--Asset("ANIM", "anim/tree_leaf_fx_green.zip"), --partical
	
    Asset("ANIM", "anim/dust_fx.zip"),
}

local prefabs =
{
    --"green_leaves",
    --"green_leaves_chop",
	"pine_needles"
}
--local function makeanims(stage)
	--return {
            --idle="idle_tall",
            --sway1="sway_loop_agro",
            --sway2="sway_loop_agro",
            --swayaggropre="sway_agro_pre",
            --swayaggro="sway_loop_agro",
            --swayaggropst="sway_agro_pst",
            --swayaggroloop="idle_loop_agro",
            --swayfx="swayfx_tall",
            --chop="chop_tall_monster",
            --fallleft="fallleft_tall_monster",
            --fallright="fallright_tall_monster",
            --stump="stump_tall_monster",
           -- burning="burning_loop_tall",
            --burnt="burnt_tall",
            --chop_burnt="chop_burnt_tall",
            --idle_chop_burnt="idle_chop_burnt_tall",
            --dropleaves = "drop_leaves_tall",
            --growleaves = "grow_leaves_tall",
        --}
--end

local function createTrouppleLoot(lootPrefab, target)
	if lootPrefab then
		local loot = SpawnPrefab(lootPrefab)
		local theta = math.random() * 2 * PI
		local pt = Point(target.Transform:GetWorldPosition())
		loot.Transform:SetPosition(pt.x,pt.y,pt.z)
		
		if loot.Physics then
			local angle = math.random()*2*PI
			loot.Physics:SetVel(2*math.cos(angle), 10, 2*math.sin(angle))

			if loot and loot.Physics and target and target.Physics then
				pt = pt + Vector3(math.cos(angle), 0, math.sin(angle))*((loot.Physics:GetRadius() or 1) + (target.Physics:GetRadius() or 1))
				loot.Transform:SetPosition(pt.x,pt.y,pt.z)
			end
				
			loot:DoTaskInTime(1,
			function() 
				if not (loot.components.inventoryitem and loot.components.inventoryitem:IsHeld()) then
					if not loot:IsOnValidGround() then
						SpawnPrefab("splash_ocean").Transform:SetPosition(loot.Transform:GetWorldPosition())
						if loot:HasTag("irreplaceable") then
							local x,y,z = FindSafeSpawnLocation(loot.Transform:GetWorldPosition())								
							loot.Transform:SetPosition(x,y,z)
						else
							loot:Remove()
						end
					end
				end
			end)
		end
	end
end

local function SpawnLeafFX(inst, waittime, chop)
    if waittime then
        inst:DoTaskInTime(waittime, function(inst, chop) SpawnLeafFX(inst, nil, chop) end)
		return
	end

    local fx = nil
    fx = SpawnPrefab("pine_needles")

    if fx then
        local x, y, z= inst.Transform:GetWorldPosition()
        if chop then y = y + (math.random()*2) end --Randomize height a bit for chop FX
        fx.Transform:SetPosition(x,y,z)
    end
end

local function dancefishskip(inst, data)
	if data.amount ~= nil then
		for k = 1, data.amount, 1 do
			createTrouppleLoot("skeventtroupplefishskip", inst)
		end
	end
end

local function dancefishfly(inst, data)
	if data.amount ~= nil then
		for k = 1, data.amount, 1 do
			createTrouppleLoot("skeventtroupplefishfly", inst)
		end
	end
end

local function danceEnd3(inst)
	inst.AnimState:PlayAnimation("sway_agro_pre") --4 legged
	inst.AnimState:PushAnimation("idle_loop_agro", true) --4 legged
	inst.AnimState:ClearOverrideSymbol("swap_leaves")
	inst.AnimState:OverrideSymbol("swap_leaves", "skstructuretreetrouppleleaf", "swap_leaves") --Top color
	SpawnLeafFX(inst, nil, true)
end

local function danceEnd2(inst)
	for k = 0, 5, 1 do
		createTrouppleLoot("skeventtroupplefishgrow", inst)
	end
	inst:DoTaskInTime(0.5, danceEnd3)
end

local function danceEnd(inst)
	inst.AnimState:PlayAnimation("idle_loop_agro", true) --4 legged
	inst:DoTaskInTime(0.4, danceEnd2)
end

local function danceStart3(inst)
	inst.AnimState:PlayAnimation("chop_tall_monster", true)
end

local function danceStart2(inst)
	inst.AnimState:ClearOverrideSymbol("swap_leaves")
	inst.AnimState:OverrideSymbol("swap_leaves", "skstructuretreetrouppleleafgreen", "swap_leaves") --Top color
	inst.AnimState:PlayAnimation("idle_loop_agro", true) --4 legged
	for k = 0, 5, 1 do
		createTrouppleLoot("skeventtroupplefishfall", inst)
	end
	inst:DoTaskInTime(1, danceStart3)
end

local function danceStart(inst)
	inst.AnimState:PlayAnimation("sway_loop_agro") --4 legged
	inst:DoTaskInTime(1.2, danceStart2)
end

local function danceStartPre(inst)
	inst:DoTaskInTime(0.4, danceStart)
end

--===============================
local function springStart4(inst)
	inst.AnimState:PlayAnimation("sway_agro_pre") --4 legged
	inst.AnimState:PushAnimation("idle_loop_agro", true) --4 legged
	inst.AnimState:ClearOverrideSymbol("swap_leaves")
	inst.AnimState:OverrideSymbol("swap_leaves", "skstructuretreetrouppleleaf", "swap_leaves") --Top color
	SpawnLeafFX(inst, nil, true)
end

local function springStart3(inst)
	for k = 0, 5, 1 do
		createTrouppleLoot("skeventtroupplefishgrow", inst)
	end
	inst:DoTaskInTime(0.5, springStart4)
end

local function springStart2(inst)
	inst.AnimState:ClearOverrideSymbol("swap_leaves")
	inst.AnimState:OverrideSymbol("swap_leaves", "skstructuretreetrouppleleafgreen", "swap_leaves") --Top color
	SpawnLeafFX(inst, nil, true)
	inst:DoTaskInTime(0.2, springStart3)
end

local function springStart(inst)
	inst.AnimState:PlayAnimation("sway_agro_pst") --4 legged
	inst.AnimState:PushAnimation("idle_loop_agro", true) --4 legged
	inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
	inst:DoTaskInTime(0.2, springStart2)
end

local function winterStart4(inst)
	inst.AnimState:ClearOverrideSymbol("swap_leaves")
	inst.AnimState:OverrideSymbol("swap_leaves", "", "swap_leaves") --Top color
	SpawnLeafFX(inst, nil, true)
end

local function winterStart3(inst)
	inst.AnimState:PlayAnimation("sway_agro_pst")
	inst.SoundEmitter:PlaySound("dontstarve/forest/treeWilt")
	inst:DoTaskInTime(0.2, winterStart4)
end

local function winterStart2(inst)
	inst.AnimState:ClearOverrideSymbol("swap_leaves")
	inst.AnimState:OverrideSymbol("swap_leaves", "skstructuretreetrouppleleafgreen", "swap_leaves") --Top color
	inst.AnimState:PlayAnimation("idle_loop_agro", true) --4 legged
	for k = 0, 5, 1 do
		createTrouppleLoot("skeventtroupplefishfall", inst)
	end
	inst:DoTaskInTime(1.2, winterStart3)
end

local function winterStart(inst)
	inst.AnimState:PlayAnimation("sway_loop_agro") --4 legged
	inst:DoTaskInTime(1.2, winterStart2)
end
--===============================

local function OnSnowLevel(inst, snowlevel, thresh)
	thresh = thresh or .02
	
	if inst.snowThresh ~= nil and inst.snowThresh > snowlevel then
		snowlevel = inst.snowThresh
		inst.snowThresh = nil
	end
	
	if snowlevel > thresh and not inst.frozen then
		inst.frozen = true
		winterStart(inst)

	elseif snowlevel < thresh and inst.frozen then
		inst.frozen = false
		springStart(inst)
	end
end

local function chop_tree(inst, chopper, chops)
    if not chopper or (chopper and not chopper:HasTag("playerghost")) then
        if chopper and chopper.components.beaverness and chopper.components.beaverness:IsBeaver() then
    		inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/beaver_chop_tree")
			chopper.components.beaverness:DoDelta(20)
    	else
    		inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
			
			local equipped = chopper.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if equipped ~= nil then
				--Unbreakable or rare Items
				if equipped:HasTag("irreplaceable") then
					if equipped.prefab == "lucy" and equipped.components.talker then
						equipped.components.talker:Say("Ouch ouch ouch! What is this tree made of?!")
					else
						chopper.components.talker:Say("Ouch! I felt that through the handle.")
					end
					chopper.components.health:DoDelta(-10)
				--Golden type tools
				elseif equipped.prefab == "goldenaxe" or equipped.prefab == "multitool_axe_pickaxe" then
					if equipped.components.finiteuses then
						equipped.components.finiteuses:Use(20)
					else
						equipped.components.inventoryitem:RemoveFromOwner(true)
					end
				--Normal tools
				else
					inst.components.workable.workleft = inst.components.workable.workleft + 1
					chopper.components.talker:Say("Wow, not even a scratch was made!")
					if equipped.components.finiteuses then
						equipped.components.finiteuses:SetUses(0)
					else
						equipped.components.inventoryitem:RemoveFromOwner(true)
					end
				end
			--Unequipped
			else
				inst.components.workable.workleft = inst.components.workable.workleft + 1
				chopper.components.talker:Say("Ouch! That hurt and not even a scratch was made!")
				chopper.components.health:DoDelta(-10)
			end
    	end
    end
	
	SpawnLeafFX(inst, nil, true)
    inst.AnimState:PlayAnimation("sway_loop_agro")
	if inst.frozen == false then
		inst.AnimState:PushAnimation("idle_loop_agro", true) --4 legged
	end

	---tell any nearby leifs to wake up
	--local ents = TheSim:FindEntities(x, y, z, TUNING.LEIF_REAWAKEN_RADIUS, {"leif"})
	--for k,v in pairs(ents) do
		--if v.components.sleeper and v.components.sleeper:IsAsleep() then
			--v:DoTaskInTime(math.random(), function() v.components.sleeper:WakeUp() end)
		--end
		--v.components.combat:SuggestTarget(chopper)
	--end
end

local function chop_down_tree(inst, chopper)
	inst.orbHolder.orb = 0
	inst:RemoveComponent("workable")
	inst.AnimState:ClearOverrideSymbol("eye")
	if inst.orbGlow ~= nil then
		inst.orbGlow:Remove()
		inst.orbGlow = nil
	end
    --inst.SoundEmitter:PlaySound("dontstarve/forest/treefall") --drop glow sound
	createTrouppleLoot("skitemtrouppleorb", inst)
end

local function hasOrb(inst)
	if inst.orbHolder.orb == 1 then
		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.CHOP)
		inst.components.workable:SetOnWorkCallback(chop_tree)
		inst.components.workable:SetOnFinishCallback(chop_down_tree)
		inst.AnimState:OverrideSymbol("eye", "skstructuretreetroupplefeature", "eye") --Orb thing
		if inst.orbGlow == nil then
			inst.orbGlow = SpawnPrefab("skfxtrouppletree_orbglow")
			local follower = inst.orbGlow.entity:AddFollower()
			follower:FollowSymbol(inst.GUID, "eye", 0, 0, 0)
		end
	else
		inst:RemoveComponent("workable")
		inst.AnimState:ClearOverrideSymbol("eye")
		if inst.orbGlow ~= nil then
			inst.orbGlow:Remove()
			inst.orbGlow = nil
		end
	end
end

local function onload(inst, data, newents)
	if inst.orbHolder.prefab ~= nil then
		hasOrb(inst)
	end
	OnSnowLevel(inst, TheWorld.state.snowlevel)
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	MakeObstaclePhysics(inst, .25)

    inst.AnimState:SetBuild("skstructuretreetrouppletrunk") --Main Base
	inst.AnimState:SetBank("tree_leaf_monster") --4 legged
	inst.AnimState:PlayAnimation("idle_loop_agro", true) --4 legged

	inst.AnimState:OverrideSymbol("swap_leaves", "skstructuretreetrouppleleaf", "swap_leaves") --Top color
	inst.AnimState:OverrideSymbol("legs", "skstructuretreetroupplefeature", "legs") --Legs
    inst.AnimState:OverrideSymbol("legs_mouseover", "skstructuretreetroupplefeature", "legs_mouseover") --Legs
	
	if not TheWorld.ismastersim then
		return inst
	end

	inst.entity:SetPristine()
	
	inst.orbHolder = ""
	inst.orbGlow = nil
	inst.frozen = false
	inst.snowThresh = nil
	
	--MakeFx("green_leaves_chop", "tree_leaf_fx", "tree_leaf_fx_green","chop", nil, nil, nil, nil, nil, nil, nil, nil, nil)
	
	inst.color = 0.5 + math.random() * 0.5
	inst.AnimState:SetMultColour(inst.color, inst.color, inst.color, 1)
	
	inst.persists = false
	
	inst:AddComponent("inspectable")

	inst.AnimState:SetTime(math.random()*2)

	inst:WatchWorldState("snowlevel", OnSnowLevel)
	inst.OnLoad = onload
	
	inst:ListenForEvent("growOrb", hasOrb)
	inst:ListenForEvent("danceStart", danceStartPre)
	inst:ListenForEvent("danceEnd", danceEnd)
	inst:ListenForEvent("danceFishSkip", dancefishskip)
	inst:ListenForEvent("danceFishFly", dancefishfly)
	
	MakeHauntablePanic(inst)
	
	inst:DoTaskInTime(0.2, onload)
	
	return inst
end  

STRINGS.NAMES.SKSTRUCTURETREETROUPPLE = "Great Troupple Tree"
STRINGS.CHARACTERS.WINSTON.DESCRIBE.SKSTRUCTURETREETROUPPLE = "Where Troupple fish grow from."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKSTRUCTURETREETROUPPLE = "What an large tree... are those fish or apples?!"

   --{
	    --name = "green_leaves_chop", 
	    --bank = "tree_leaf_fx", 
	    --build = "tree_leaf_fx_green", 
	    --anim = "chop",
	    --sound = "dontstarve_DLC001/fall/leaf_rustle",
	    --dlc = true,
    --},
	
return Prefab("common/objects/skstructuretreetroupple", fn, assets, prefabs)

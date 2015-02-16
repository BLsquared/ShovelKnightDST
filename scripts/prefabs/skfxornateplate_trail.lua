local assets =
{
	Asset("ANIM", "anim/skfxornateplate_glitter.zip"),
}

------Trail Stuff
local function onupdate(inst)
	if inst.ilimit == false then
		inst.i = inst.i + 0.2
		if inst.i >= .8 then
			inst.ilimit = true
		end
	else
		inst.i = inst.i - 0.2
		if inst.i <= 0 then
			inst:Remove()
		end
	end
    inst.Light:SetIntensity(inst.i) 
end

local function fn()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()

	inst.AnimState:SetBank("star")
    inst.AnimState:SetBuild("skfxornateplate_glitter")
	inst.AnimState:PlayAnimation("idle_loop", true)
	
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetRayTestOnBB(true)
	
    inst.Light:Enable(true)
    inst.Light:SetRadius(.27)
    inst.Light:SetFalloff(.9)
    inst.Light:SetIntensity(0.6)
    inst.Light:SetColour(180/255, 195/255, 150/255)

    inst.i = 0.6
	inst.ilimit = false
    inst:DoPeriodicTask(0.5, onupdate)
	
	return inst
end

return Prefab("common/fx/skfxornateplate_trail", fn, assets)
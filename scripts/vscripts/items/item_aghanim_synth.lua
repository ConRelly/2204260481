--[[	Author: d2imba
		Date:	19.11.2016	]]



function AghanimsSynthCast( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier_synth = keys.modifier_synth
	local modifier_stats = keys.modifier_stats
	local sound_cast = keys.sound_cast

	-- If the caster already has the synth buff, do nothing
	-- if caster:HasModifier(modifier_synth) or caster:HasModifier("modifier_arc_warden_tempest_double") then
	if caster:HasModifier("modifier_arc_warden_tempest_double") then
		return nil
	end

	-- Otherwise, apply the synth buff and the stats buff
	if not caster:HasModifier(modifier_synth) then
		caster:AddNewModifier(caster, nil, modifier_synth, {})
	end	
	if caster:HasModifier(modifier_stats) then
		local modifier = caster:FindModifierByName(modifier_stats)
		modifier:SetStackCount(modifier:GetStackCount() + 1)
	else
		ability:ApplyDataDrivenModifier(caster, caster, modifier_stats, {})
		local modifier = caster:FindModifierByName(modifier_stats)
		modifier:SetStackCount(modifier:GetStackCount() + 1)
	end	
	-- Play sound
	caster:EmitSound(sound_cast)

	-- Spend the item's only charge
	ability:SetCurrentCharges( ability:GetCurrentCharges() - 1 )
	caster:RemoveItem(ability)

	-- Create a regular scepter for one game frame to prevent regular dota interactions from going bad
	local dummy_scepter = CreateItem("item_ultimate_scepter", caster, caster)
	caster:AddItem(dummy_scepter)
	Timers:CreateTimer(0.01, function()
		caster:RemoveItem(dummy_scepter)
	end)
end
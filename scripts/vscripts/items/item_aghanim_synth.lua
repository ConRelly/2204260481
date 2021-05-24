<<<<<<< Updated upstream
LinkLuaModifier("modifier_super_scepter", "items/item_aghanim_synth.lua", LUA_MODIFIER_MOTION_NONE)

function AghanimsSynthCast(keys)
=======
--[[	Author: d2imba
		Date:	19.11.2016	]]



function AghanimsSynthCast( keys )
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
	if caster:HasModifier(modifier_stats) then
		local modifier = caster:FindModifierByName(modifier_stats)
		modifier:SetStackCount(modifier:GetStackCount() + 1)
	else
		ability:ApplyDataDrivenModifier(caster, caster, modifier_stats, {})
		local modifier = caster:FindModifierByName(modifier_stats)
		modifier:SetStackCount(1)
	end
	if caster:HasModifier(modifier_stats) and caster:FindModifierByName(modifier_stats):GetStackCount() > 2 then
		caster:AddNewModifier(caster, nil, "modifier_super_scepter", {})
	else
		if caster:HasModifier("modifier_super_scepter") then
			caster:RemoveModifierByName("modifier_super_scepter")
		end
	end
	caster:EmitSound("Hero_Alchemist.Scepter.Cast")
	caster:RemoveItem(ability)
end

modifier_super_scepter = modifier_super_scepter or class({})
function modifier_super_scepter:IsDebuff() return false end
function modifier_super_scepter:IsHidden() return true end
function modifier_super_scepter:IsPurgable() return false end
function modifier_super_scepter:GetEffectName() return "particles/custom/items/super_scepter/super_scepter_amb.vpcf" end
function modifier_super_scepter:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_super_scepter:OnDestroy()
--	if IsServer() then
		if self:GetCaster():HasModifier(modifier_stats) and self:GetCaster():FindModifierByName(modifier_stats):GetStackCount() > 2 then
			self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_super_scepter", {})
		else
			if self:GetCaster():HasModifier("modifier_super_scepter") then
				self:GetCaster():RemoveModifierByName("modifier_super_scepter")
			end
		end
--	end
end
=======

	-- Otherwise, apply the synth buff and the stats buff
	caster:AddNewModifier(caster, nil, modifier_synth, {})
	ability:ApplyDataDrivenModifier(caster, caster, modifier_stats, {})

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
>>>>>>> Stashed changes

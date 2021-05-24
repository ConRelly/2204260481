LinkLuaModifier("modifier_super_scepter", "items/item_aghanim_synth.lua", LUA_MODIFIER_MOTION_NONE)

function AghanimsSynthCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier_synth = keys.modifier_synth
	local modifier_stats = keys.modifier_stats
	
	if caster:HasModifier("modifier_arc_warden_tempest_double") then return nil end
	
	if not caster:HasModifier(modifier_synth) then
		caster:AddNewModifier(caster, nil, modifier_synth, {})
	end
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

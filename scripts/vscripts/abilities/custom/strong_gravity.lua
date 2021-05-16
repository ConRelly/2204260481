LinkLuaModifier( "modifier_spectre_strong_gravity", "heroes/hero_spectre/strong_gravity.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_spectre_strong_gravity_buff", "heroes/hero_spectre/strong_gravity.lua", LUA_MODIFIER_MOTION_NONE )

spectre_strong_gravity = class({})

function spectre_strong_gravity:GetIntrinsicModifierName()
	return "modifier_spectre_strong_gravity"
end

function spectre_strong_gravity:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	EmitSoundOn("Hero_Spectre.Haunt", caster)
	caster:AddNewModifier(caster, self, "modifier_spectre_strong_gravity_buff", {duration = duration})
end

modifier_spectre_strong_gravity = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
--		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
--		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
--		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
--		MODIFIER_PROPERTY_MODEL_SCALE,
		} end,
})

function modifier_spectre_strong_gravity:OnCreated()
	if IsServer() then
		local grow_interval = self:GetAbility():GetSpecialValueFor("grow_interval")
		self:StartIntervalThink(grow_interval)
	end
end

function modifier_spectre_strong_gravity:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
--		local grow_stat = ability:GetSpecialValueFor("grow_stat")
		
		if caster and caster:IsAlive() then
--			self:SetStackCount(self:GetStackCount() + grow_stat)
			self:IncrementStackCount()
			caster:CalculateStatBonus(false)

			EmitSoundOn("Hero_Spectre.HauntCast", caster)
			local effect = "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf"
			local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, parent)
			ParticleManager:ReleaseParticleIndex(pfx)
		end
	end
end

function modifier_spectre_strong_gravity:GetModifierStatusResistance()
	local ability = self:GetAbility()
	local bonus_status_resist = ability:GetSpecialValueFor("bonus_status_resist")
	if self:GetCaster():HasModifier("modifier_spectre_strong_gravity_buff") then
		bonus_status_resist = bonus_status_resist * 1.5
	end
	return bonus_status_resist
end

function modifier_spectre_strong_gravity:GetModifierHealthBonus()
	local multiplier = 1
	if self:GetCaster():HasModifier("modifier_spectre_strong_gravity_buff") then
		multiplier = self:GetAbility():GetSpecialValueFor("stat_mult")
	end
	return self:GetAbility():GetSpecialValueFor("stack_health")*self:GetStackCount()*multiplier
end

function modifier_spectre_strong_gravity:GetModifierConstantHealthRegen()
	local multiplier = 1
	if self:GetCaster():HasModifier("modifier_spectre_strong_gravity_buff") then
		multiplier = self:GetAbility():GetSpecialValueFor("stat_mult")
	end
	return self:GetAbility():GetSpecialValueFor("stack_regen")*self:GetStackCount()*multiplier
end

function modifier_spectre_strong_gravity:GetModifierBonusStats_Strength()
	local multiplier = 1
	if self:GetCaster():HasModifier("modifier_spectre_strong_gravity_buff") then
		multiplier = self:GetAbility():GetSpecialValueFor("stat_mult")
	end
	return self:GetStackCount()*multiplier
end

function modifier_spectre_strong_gravity:GetModifierBonusStats_Agility()
	local multiplier = 1
	if self:GetCaster():HasModifier("modifier_spectre_strong_gravity_buff") then
		multiplier = self:GetAbility():GetSpecialValueFor("stat_mult")
	end
	return self:GetStackCount()*multiplier
end

function modifier_spectre_strong_gravity:GetModifierBonusStats_Intellect()
	local multiplier = 1
	if self:GetCaster():HasModifier("modifier_spectre_strong_gravity_buff") then
		multiplier = self:GetAbility():GetSpecialValueFor("stat_mult")
	end
	return self:GetStackCount()*multiplier
end

function modifier_spectre_strong_gravity:GetModifierModelScale()
	local scale = self:GetStackCount()*self.model_scale
	if scale > 5 then scale = 5 end
	return scale
end

modifier_spectre_strong_gravity_buff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	})
function modifier_spectre_strong_gravity_buff:GetEffectName()
	return "particles/econ/items/spectre/spectre_transversant_soul/spectre_transversant_spectral_dagger_path_owner.vpcf"
end
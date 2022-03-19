LinkLuaModifier("modifier_wr_windrun", "heroes/hero_windranger/windrun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wr_windrun_slow", "heroes/hero_windranger/windrun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wr_windrun_exclusive", "heroes/hero_windranger/windrun", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_wr_shackleshot_immortal_cascade", "heroes/hero_windranger/windrun", LUA_MODIFIER_MOTION_NONE)

local wr_exclusive_item = "wr_exclusive_item_modifier"

-------------
-- Windrun --
-------------
wr_windrun = class({})
function wr_windrun:GetIntrinsicModifierName()
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_wr_shackleshot_immortal_cascade") and FindWearables(self:GetCaster(), "models/items/windrunner/sylvan_cascade/sylvan_cascade.vmdl") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_wr_shackleshot_immortal_cascade", {})
		end
    end
	return
end
function wr_windrun:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_wr_shackleshot_immortal_cascade") then
        return "windrunner_windrun_sylvan"
    end
    return "windrunner_windrun"
end
function wr_windrun:GetAOERadius()
	return self:GetSpecialValueFor("radius") + talent_value(self:GetCaster(), "special_bonus_wr_windrun_radius")
end
function wr_windrun:OnSpellStart()
	self:GetCaster():EmitSound("Ability.Windrun")
	
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_wr_windrun", {duration = self:GetSpecialValueFor("duration")})
end

----------------------
-- Windrun Modifier --
----------------------
modifier_wr_windrun = class({})
function modifier_wr_windrun:IsPurgable() if self:GetCaster():HasScepter() then return false else return true end end
function modifier_wr_windrun:GetEffectName() return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf" end

function modifier_wr_windrun:OnCreated()
	if self:GetAbility() then
		self.movespeed_bonus_pct = self:GetAbility():GetSpecialValueFor("movespeed_bonus_pct")
		self.evasion_pct = self:GetAbility():GetSpecialValueFor("evasion_pct")
		self.radius = self:GetAbility():GetSpecialValueFor("radius") + talent_value(self:GetCaster(), "special_bonus_wr_windrun_radius")
	end

	if not IsServer() then return end

	if self:GetCaster():HasModifier(wr_exclusive_item) then
		if not self.freezing_field_particle then
			self.freezing_field_particle = ParticleManager:CreateParticle("particles/custom/abilities/heroes/wr_windrun/windrun_exclusive_aoe.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())

			ParticleManager:SetParticleControl(self.freezing_field_particle, 0, self:GetCaster():GetAbsOrigin())
			ParticleManager:SetParticleControl(self.freezing_field_particle, 1, Vector(self.radius, 0, 0))
			ParticleManager:SetParticleControl(self.freezing_field_particle, 5, Vector(self.radius, 0, 0))

			self:StartIntervalThink(FrameTime())
		end
	end
end
function modifier_wr_windrun:OnIntervalThink()
	if self.freezing_field_particle then
		ParticleManager:SetParticleControl(self.freezing_field_particle, 0, self:GetCaster():GetAbsOrigin())
	end
	if self:GetCaster():HasModifier(wr_exclusive_item) then
		for _, target in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			if self:GetCaster() == self:GetParent() then
				target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_wr_windrun_exclusive", {duration = 1})
			end
		end
	end
end
function modifier_wr_windrun:OnRefresh()
	self:OnCreated()
end
function modifier_wr_windrun:OnDestroy()
	if not IsServer() then return end
	self:GetCaster():StopSound("Ability.Windrun")
	if self.freezing_field_particle then
		ParticleManager:DestroyParticle(self.freezing_field_particle, false)
		ParticleManager:ReleaseParticleIndex(self.freezing_field_particle)
	end
end

function modifier_wr_windrun:CheckState()
	local state = {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,}
	if self:GetCaster():HasModifier(wr_exclusive_item) then
		state[MODIFIER_STATE_UNSLOWABLE] = true
	end
	return state
end

function modifier_wr_windrun:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
	}
end

function modifier_wr_windrun:GetActivityTranslationModifiers() return "windrun" end
function modifier_wr_windrun:GetModifierMoveSpeedBonus_Percentage() return self.movespeed_bonus_pct end
function modifier_wr_windrun:GetModifierEvasion_Constant() return self.evasion_pct end


function modifier_wr_windrun:IsAura() return true end
function modifier_wr_windrun:IsAuraActiveOnDeath() return false end
function modifier_wr_windrun:GetModifierAura() return "modifier_wr_windrun_slow" end
function modifier_wr_windrun:GetAuraRadius()		return self.radius end
function modifier_wr_windrun:GetAuraSearchFlags()	return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_wr_windrun:GetAuraSearchTeam()	return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_wr_windrun:GetAuraSearchType()	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_wr_windrun:GetAuraDuration()		return 1 end

---------------------------
-- Windrun Slow Modifier --
---------------------------
modifier_wr_windrun_slow = class({})
function modifier_wr_windrun_slow:GetEffectName() return "particles/units/heroes/hero_windrunner/windrunner_windrun_slow.vpcf" end
function modifier_wr_windrun_slow:OnCreated()
	if self:GetAbility() then
		self.enemy_movespeed_bonus_pct = self:GetAbility():GetSpecialValueFor("enemy_movespeed_bonus_pct")
		self.miss_chance = 0
		if self:GetCaster():HasScepter() then
			self.enemy_movespeed_bonus_pct = self.enemy_movespeed_bonus_pct + self:GetAbility():GetSpecialValueFor("scepter_movespeed_bonus_pct")
			self.miss_chance = self:GetAbility():GetSpecialValueFor("scepter_blind")
		end
	end
end
function modifier_wr_windrun_slow:OnRefresh()
	self:OnCreated()
end
function modifier_wr_windrun_slow:DeclareFunctions()	
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_wr_windrun_slow:GetModifierMoveSpeedBonus_Percentage() return self.enemy_movespeed_bonus_pct end
function modifier_wr_windrun_slow:GetModifierMiss_Percentage() return self.miss_chance end

--------------------------------
-- Windrun Exclusive Modifier --
--------------------------------
modifier_wr_windrun_exclusive = class({})
function modifier_wr_windrun_exclusive:IsHidden() return true end
function modifier_wr_windrun_exclusive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.5)
end
function modifier_wr_windrun_exclusive:OnIntervalThink()
	if not IsServer() then return end
	if self:GetParent():HasModifier("modifier_wr_exclusive_frozen") then return end
	self:GetParent():AddChill(self:GetAbility(), self:GetCaster(), 0.75, 1)
	if self:GetParent():GetChillCount() >= 10 then
		self:GetParent():RemoveChill()
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_wr_exclusive_frozen", {duration = 2})
	end
end


modifier_wr_shackleshot_immortal_cascade = class({})
function modifier_wr_shackleshot_immortal_cascade:IsHidden() return true end
function modifier_wr_shackleshot_immortal_cascade:IsPurgable() return false end
function modifier_wr_shackleshot_immortal_cascade:RemoveOnDeath() return false end






-- Необходимо перенести в предмет
LinkLuaModifier("modifier_wr_exclusive_frozen", "heroes/hero_windranger/windrun", LUA_MODIFIER_MOTION_NONE)

modifier_wr_exclusive_frozen = class({})
function modifier_wr_exclusive_frozen:IsHidden() return false end
function modifier_wr_exclusive_frozen:IsDebuff() return true end
function modifier_wr_exclusive_frozen:IsPurgeException() return true end
function modifier_wr_exclusive_frozen:GetTexture() return "winter_wyvern_cold_embrace" end
function modifier_wr_exclusive_frozen:GetStatusEffectName() return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_dire.vpcf" end
function modifier_wr_exclusive_frozen:StatusEffectPriority() return 11 end
function modifier_wr_exclusive_frozen:GetEffectName() return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf" end

function modifier_wr_exclusive_frozen:OnCreated()
	if self:GetParent():IsMagicImmune() then self:Destroy() return end
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_wr_exclusive_frozen:OnIntervalThink()
	if self:GetParent():IsChilled() then
		self:GetParent():RemoveChill()
	end
end
function modifier_wr_exclusive_frozen:OnDestroy()
	if not IsServer() then return end
	local shatter = true
	if self:GetParent():IsMagicImmune() then
		shatter = false
	end
	if shatter then
		local damage = self:GetParent():GetMaxHealth() / 100
		if self:GetStackCount() == 1 then
			damage = damage * 2
		end
		local radius = 900
--[[
		local shatter_crack = ParticleManager:CreateParticle("particles/item/skadi/skadi_ground.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleAlwaysSimulate(shatter_crack)
		ParticleManager:SetParticleControl(shatter_crack, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(shatter_crack, 2, Vector(radius * 1.15, 1, 1))
		ParticleManager:ReleaseParticleIndex(shatter_crack)
]]
		local shatter_crack = ParticleManager:CreateParticle("particles/custom/items/wr_exclusive/wr_exclusive_frozen_broke.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(shatter_crack, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(shatter_crack, 1, Vector(radius, self:GetRemainingTime(), radius))
		ParticleManager:ReleaseParticleIndex(shatter_crack)

		EmitSoundOn("Hero_Ancient_Apparition.IceBlast.Target", self:GetParent())

		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, target in pairs(enemies) do
			if target:IsMagicImmune() then return end
			ApplyDamage({
				victim = target,
				attacker = self:GetCaster(),
				ability = self:GetAbility(),
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR,
			})
		end
	end
end
function modifier_wr_exclusive_frozen:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_FROZEN] = true, [MODIFIER_STATE_ROOTED] = true, [MODIFIER_STATE_INVISIBLE] = false}
end
function modifier_wr_exclusive_frozen:DeclareFunctions()
	return {MODIFIER_PROPERTY_CASTTIME_PERCENTAGE, MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE}
end
function modifier_wr_exclusive_frozen:GetModifierPercentageCasttime() return -95 end
function modifier_wr_exclusive_frozen:GetModifierTurnRate_Percentage() return -95 end




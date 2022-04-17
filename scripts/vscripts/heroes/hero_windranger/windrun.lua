LinkLuaModifier("modifier_wr_windrun", "heroes/hero_windranger/windrun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wr_windrun_slow", "heroes/hero_windranger/windrun", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_wr_windrun_exclusive", "heroes/hero_windranger/windrun", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_traxexs_necklace_chill", "items/traxexs_necklace", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_wr_windrun_immortal_cascade", "heroes/hero_windranger/windrun", LUA_MODIFIER_MOTION_NONE)

-------------
-- Windrun --
-------------
wr_windrun = class({})
function wr_windrun:GetIntrinsicModifierName()
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_wr_windrun_immortal_cascade") and FindWearables(self:GetCaster(), "models/items/windrunner/sylvan_cascade/sylvan_cascade.vmdl") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_wr_windrun_immortal_cascade", {})
		end
    end
	return
end
function wr_windrun:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_wr_windrun_immortal_cascade") then
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

	if self:GetCaster():GetUnitName() == "npc_dota_hero_windrunner" and self:GetCaster():HasModifier("modifier_traxexs_necklace") then
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
--[[
	if self:GetCaster():GetUnitName() == "npc_dota_hero_windrunner" and self:GetCaster():HasModifier("modifier_traxexs_necklace") then
		for _, target in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			if self:GetCaster() == self:GetParent() then
				target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_wr_windrun_exclusive", {duration = 1})
			end
		end
	end
]]
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
	if self:GetCaster():GetUnitName() == "npc_dota_hero_windrunner" and self:GetCaster():HasModifier("modifier_traxexs_necklace") then
		state[MODIFIER_STATE_UNSLOWABLE] = true
	end
	return state
end

function modifier_wr_windrun:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
	}
end

function modifier_wr_windrun:GetActivityTranslationModifiers() return "windrun" end
function modifier_wr_windrun:GetModifierMoveSpeedBonus_Percentage() return self.movespeed_bonus_pct end
function modifier_wr_windrun:GetModifierEvasion_Constant() return self.evasion_pct end

function modifier_wr_windrun:OnAttackFail(keys)
	if not IsServer() then return end
	if self:GetCaster():GetUnitName() == "npc_dota_hero_windrunner" and self:GetCaster():HasModifier("modifier_traxexs_necklace") then
		if keys.attacker:GetTeam() == self:GetCaster():GetTeam() then return end
		if keys.attacker:HasModifier("modifier_traxexs_necklace_frozen") then return end
		if self:GetCaster() == keys.target then
			local TraxexNecklace = self:GetCaster():FindItemInInventory("item_traxexs_necklace")
			local chill = keys.attacker:AddNewModifier(self:GetCaster(), TraxexNecklace, "modifier_traxexs_necklace_chill", {duration = 2})
			chill:SetStackCount(chill:GetStackCount() + RandomInt(1, 150))
		end
	end
end


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

--[[
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
	if self:GetParent():HasModifier("modifier_traxexs_necklace_frozen") then return end
	local chill = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_traxexs_necklace_chill", {duration = 2})
	chill:SetStackCount(chill:GetStackCount() + RandomInt(1, 150))
end
]]


modifier_wr_windrun_immortal_cascade = class({})
function modifier_wr_windrun_immortal_cascade:IsHidden() return true end
function modifier_wr_windrun_immortal_cascade:IsPurgable() return false end
function modifier_wr_windrun_immortal_cascade:RemoveOnDeath() return false end







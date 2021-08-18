LinkLuaModifier("modifier_sacred_blink_buff", "heroes/hero_piety/sacred_blink", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_divinity_activated", "heroes/hero_piety/divine_cancel", LUA_MODIFIER_MOTION_NONE)

------------------
-- Sacred Blink --
------------------
sacred_blink = class({})
--function sacred_blink:ProcsMagicStick() return false end
function sacred_blink:GetAOERadius()
	return self:GetSpecialValueFor("search_radius")
end
function sacred_blink:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_divinity_activated") then
		return self.BaseClass.GetCooldown(self, level) / self:GetCaster():GetCooldownReduction()
	end
	return self.BaseClass.GetCooldown(self, level) / self:GetCaster():GetCooldownReduction()
end
function sacred_blink:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local caster_pos = caster:GetAbsOrigin()
		local radius = self:GetSpecialValueFor("search_radius")
		local buff_duration = self:GetSpecialValueFor("buff_duration")
		local units_target = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
		local target_flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
		local position_end = self:GetEndPosition(caster, radius, target_flag)

		if caster:HasSuperScepter() then
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 150, DOTA_UNIT_TARGET_TEAM_BOTH, units_target, target_flag + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 0, false)
			for _,target in pairs(targets) do
				ProjectileManager:ProjectileDodge(target)
				FindClearSpaceForUnit(target, position_end, true)
			end
		else
			FindClearSpaceForUnit(caster, position_end, true)
		end

		caster:EmitSoundParams("Sacred_Blink", 1, 1, 0)

		if caster:HasTalent("special_bonus_unique_sacred_blink_building") then
			units_target = units_target + DOTA_UNIT_TARGET_BUILDING
		end
		local units = FindUnitsInRadius(caster:GetTeamNumber(), position_end, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, units_target, target_flag, FIND_CLOSEST, false)
		for _,unit in pairs(units) do
			if unit:GetTeamNumber() == caster:GetTeamNumber() and caster:HasModifier("modifier_item_aghanims_shard") then
				buff_duration = self:GetSpecialValueFor("buff_duration") + 2
			end
			unit:AddNewModifier(caster, self, "modifier_sacred_blink_buff", {duration = buff_duration})
		end

		local start_blink = ParticleManager:CreateParticle("particles/custom/abilities/sacred_blink/sacred_blink_end.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(start_blink, 0, caster_pos)
		ParticleManager:SetParticleControl(start_blink, 1, position_end)
		ParticleManager:ReleaseParticleIndex(start_blink)

		local buff_radius = ParticleManager:CreateParticle("particles/custom/abilities/sacred_blink/sacred_blink.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(buff_radius, 2, Vector(radius, radius, radius))
		ParticleManager:ReleaseParticleIndex(buff_radius)
	end
end
function sacred_blink:GetEndPosition(caster, radius, target_flag)
	if IsServer() then
		if caster:HasTalent("special_bonus_unique_sacred_blink_building") then
			target = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING
		else
			target = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
		end
		if self:GetCaster():HasModifier("modifier_divinity_activated") then
			target_flag = target_flag + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_DEAD
		else
			target_flag = target_flag + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
		end
		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetCursorPosition(), nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, target, target_flag, FIND_CLOSEST, false)
		for i, unit in pairs(units) do
			if units ~= nil and unit ~= caster then
				return caster:GetCursorPosition()
			end
		end
		return caster:GetAbsOrigin()
	end
end

-----------------------
-- Sacred Blink Buff --
-----------------------
modifier_sacred_blink_buff = class({})
function modifier_sacred_blink_buff:IsHidden() return false end
function modifier_sacred_blink_buff:IsPurgable() return false end
function modifier_sacred_blink_buff:IsBuff() return true end
function modifier_sacred_blink_buff:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_sacred_blink_buff:GetModifierAttackSpeedPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("buff_pct") end
end
function modifier_sacred_blink_buff:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then
		if self:GetParent() == self:GetCaster() then
			return self:GetAbility():GetSpecialValueFor("buff_pct")
		else
			return self:GetAbility():GetSpecialValueFor("buff_pct") / 2
		end
	end
end

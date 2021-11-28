LinkLuaModifier("modifier_earthshaker_aftershock_lua", "lua_abilities/earthshaker_aftershock_lua/earthshaker_aftershock_lua", LUA_MODIFIER_MOTION_NONE)


earthshaker_aftershock_lua = class({})
function earthshaker_aftershock_lua:GetCastRange(location, target)
	return self:GetSpecialValueFor("aftershock_range") + talent_value(self:GetCaster(), "special_bonus_unique_earthshaker_5") - self:GetCaster():GetCastRangeBonus()
end
function earthshaker_aftershock_lua:GetIntrinsicModifierName() return "modifier_earthshaker_aftershock_lua" end


modifier_earthshaker_aftershock_lua = class({})
function modifier_earthshaker_aftershock_lua:IsHidden() return true end
function modifier_earthshaker_aftershock_lua:IsPurgable() return false end
function modifier_earthshaker_aftershock_lua:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end
function modifier_earthshaker_aftershock_lua:OnAbilityFullyCast(params)
	if IsServer() then
		if not self:GetAbility() then self:Destroy() return end
--		local abilityName = params.ability:GetAbilityName()
--		if self.banned[abilityName] then return end
		if self:GetCaster():PassivesDisabled() then return end
		if params.ability:IsToggle() then return end
		if params.unit ~= self:GetParent() or params.ability:IsItem() then return end
		if params.ability:GetCooldown(params.ability:GetLevel()) <= 0 then return end

		local aftershock_range = self:GetAbility():GetSpecialValueFor("aftershock_range") + talent_value(self:GetCaster(), "special_bonus_unique_earthshaker_5")
		local aftershock_damage = self:GetAbility():GetSpecialValueFor("aftershock_damage")
		local duration = self:GetAbility():GetSpecialValueFor("duration")
		local str_damage = self:GetCaster():GetStrength() * (self:GetAbility():GetTalentSpecialValueFor("str_multiplier") + talent_value(self:GetCaster(), "special_bonus_unique_earthshaker_2"))
		local damage = aftershock_damage + str_damage

		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, aftershock_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = duration})

			ApplyDamage({
				victim = enemy,
				attacker = self:GetCaster(),
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self:GetAbility(),
			})
		end

		local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_aftershock.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControl(effect_cast, 1, Vector(aftershock_range, aftershock_range, aftershock_range))
		ParticleManager:ReleaseParticleIndex(effect_cast)
	end
end


modifier_earthshaker_aftershock_lua.banned = {
	["invoker_invoke"] = true,
	["elder_titan_return_spirit"] = true,
	["mjz_dragon_knight_elder_dragon_relieve"] = true,
	["mjz_lycan_shapeshift_relieve"] = true,
	["mjz_terrorblade_metamorphosis_relieve"] = true,
}

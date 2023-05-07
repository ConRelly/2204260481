LinkLuaModifier("modifier_craggy_exterior", "heroes/hero_tiny/craggy_exterior", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_tiny_craggy_exterior_stunned", "heroes/hero_tiny/craggy_exterior", LUA_MODIFIER_MOTION_NONE)


---------------------
-- Craggy Exterior --
---------------------
mjz_tiny_craggy_exterior = class({})
function mjz_tiny_craggy_exterior:GetIntrinsicModifierName() return "modifier_craggy_exterior" end
function mjz_tiny_craggy_exterior:GetAOERadius() return self:GetSpecialValueFor("radius") end

------------------------------
-- Craggy Exterior Modifier --
------------------------------
modifier_craggy_exterior = class({})
function modifier_craggy_exterior:IsHidden() return true end
function modifier_craggy_exterior:IsPurgable() return false end
function modifier_craggy_exterior:RemoveOnDeath() return false end
function modifier_craggy_exterior:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,MODIFIER_EVENT_ON_ATTACKED}
end
function modifier_craggy_exterior:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_craggy_exterior:GetModifierMagicalResistanceBonus() return self:GetAbility():GetSpecialValueFor("bonus_magic_res") end
function modifier_craggy_exterior:GetModifierStatusResistanceStacking() return talent_value(self:GetParent(), "special_bonus_craggy_exterior_status_resist") end
function modifier_craggy_exterior:OnAttacked(params)
	if IsServer() then
		local target = params.target
		local attacker = params.attacker
		if target == self:GetParent():GetTeamNumber() then return end
		if target ~= self:GetParent() then return end
		if attacker == nil then return end
		local stun_chance = self:GetAbility():GetSpecialValueFor("stun_chance")
		if self:GetParent():IsRangedAttacker() then
			stun_chance = stun_chance / 2
		end
		local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
		local damage = self:GetAbility():GetSpecialValueFor("return_damage")
		local damage_phys = self:GetParent():GetPhysicalArmorValue(false) * self:GetAbility():GetSpecialValueFor("armor_multiplier")
		if (self:GetParent():GetAbsOrigin() - attacker:GetAbsOrigin()):Length2D() <= self:GetAbility():GetSpecialValueFor("radius") then
			if RollPercentage(stun_chance) then
				if self:GetParent():HasTalent("special_bonus_craggy_exterior_attack") then
					self:GetParent():PerformAttack(attacker, true, true, true, true, false, false, false)
				end
				ApplyDamage({attacker = self:GetParent(), victim = attacker, ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_PURE})
				ApplyDamage({attacker = self:GetParent(), victim = attacker, ability = self:GetAbility(), damage = damage_phys, damage_type = DAMAGE_TYPE_PHYSICAL})

				attacker:EmitSound("Hero_Tiny.CraggyExterior")
				attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_mjz_tiny_craggy_exterior_stunned", {duration = stun_duration * (1 - attacker:GetStatusResistance())})
			end
		end
	end
end

-----------------------------------
-- Craggy Exterior Stun Modifier --
-----------------------------------
modifier_mjz_tiny_craggy_exterior_stunned = class({})
function modifier_mjz_tiny_craggy_exterior_stunned:IsHidden() return false end
function modifier_mjz_tiny_craggy_exterior_stunned:IsPurgeException() return true end
function modifier_mjz_tiny_craggy_exterior_stunned:IsStunDebuff() return true end
function modifier_mjz_tiny_craggy_exterior_stunned:GetTexture() return "mjz_tiny_craggy_exterior" end
function modifier_mjz_tiny_craggy_exterior_stunned:CheckState() if self:GetParent().bAbsoluteNoCC then return end return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_mjz_tiny_craggy_exterior_stunned:GetEffectName() return "particles/generic_gameplay/generic_stunned.vpcf" end
function modifier_mjz_tiny_craggy_exterior_stunned:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_mjz_tiny_craggy_exterior_stunned:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_mjz_tiny_craggy_exterior_stunned:GetOverrideAnimation() return ACT_DOTA_DISABLED end

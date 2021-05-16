if clinkz_infernal_breath == nil then clinkz_infernal_breath = class({}) end
LinkLuaModifier("modifier_clinkz_infernal_breath", "heroes/hero_clinkz/infernal_breath.lua", LUA_MODIFIER_MOTION_NONE)
function clinkz_infernal_breath:GetIntrinsicModifierName() return "modifier_clinkz_infernal_breath" end

if modifier_clinkz_infernal_breath == nil then modifier_clinkz_infernal_breath = class({}) end
function modifier_clinkz_infernal_breath:IsHidden() return true end
function modifier_clinkz_infernal_breath:IsPurgable() return false end
function modifier_clinkz_infernal_breath:RemoveOnDeath() return false end
function modifier_clinkz_infernal_breath:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_clinkz_infernal_breath:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_clinkz_infernal_breath:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("health") end
end
function modifier_clinkz_infernal_breath:GetModifierBaseAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("base_damage") end
end
function modifier_clinkz_infernal_breath:OnAttackLanded(keys)
	if self:GetCaster():HasScepter() then
	local target = keys.target
	local dmg = keys.damage
	local scepter_mag_damage = self:GetAbility():GetSpecialValueFor("scepter_mag_damage")
	local scepter_damage = dmg * (scepter_mag_damage * 0.01)
		if keys.attacker == self:GetParent() then
			if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("scepter_chance"), self:GetAbility()) then
				ApplyDamage({
					victim = target,
					damage = scepter_damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
					attacker = self:GetParent(),
					ability = self:GetAbility()
					})
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, scepter_damage, nil)
				local particleName = "particles/custom/abilities/clinkz_infernal_breath/clinkz_infernal_breath_hit.vpcf"
				local pfx = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
				ParticleManager:SetParticleControlEnt(pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			end
		end
	end
end

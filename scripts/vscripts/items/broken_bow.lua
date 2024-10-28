require("lib/mys")

LinkLuaModifier("modifier_item_broken_bow", "items/broken_bow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_willbreaker_debuff", "items/broken_bow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_broken_bow_count", "items/broken_bow.lua", LUA_MODIFIER_MOTION_NONE)

-- Crossbow --
item_broken_bow = class({})
function item_broken_bow:GetIntrinsicModifierName() return "modifier_item_broken_bow" end


modifier_item_broken_bow = class({})
function modifier_item_broken_bow:IsHidden() return true end
function modifier_item_broken_bow:IsPurgable() return false end
function modifier_item_broken_bow:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetParent():GetProjectileSpeed())
		local modifier = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_broken_bow_count", {})
		modifier:SetStackCount(0)
	end
end
function modifier_item_broken_bow:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_item_broken_bow_count")
	end
end
function modifier_item_broken_bow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,

		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_item_broken_bow:GetModifierBonusStats_Agility()
	if self:GetAbility() then
		local lvl = self:GetParent():GetLevel()
		return self:GetAbility():GetSpecialValueFor("lvlbonus_agi") * lvl
 	end
end
function modifier_item_broken_bow:GetModifierBonusStats_Intellect()
	if self:GetAbility() then
		local lvl = self:GetParent():GetLevel()
		return self:GetAbility():GetSpecialValueFor("lvlbonus_int") * lvl
	end
end
function modifier_item_broken_bow:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	end
end
function modifier_item_broken_bow:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("movement_speed_bonus")
	end
end
function modifier_item_broken_bow:GetModifierConstantManaRegen()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
	end
end
function modifier_item_broken_bow:GetModifierBaseAttack_BonusDamage()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
end
function modifier_item_broken_bow:GetModifierAttackRangeBonus()
	if self:GetAbility() then
		if self:GetParent():IsRangedAttacker() then
			return self:GetAbility():GetSpecialValueFor("bonus_range")
		end
		return 0
	end
end
function modifier_item_broken_bow:GetModifierProjectileSpeedBonus()
	if self:GetAbility() then
		if self:GetParent():IsRangedAttacker() then
			return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("projectile_increase") / 100
		end
		return 0
	end
end
function modifier_item_broken_bow:OnAttackLanded(keys)
	if IsServer() then
		local attacker = keys.attacker
		local parent = self:GetParent()
		local target = keys.target
		if attacker == parent and not attacker:IsNull() and attacker:IsRangedAttacker() and attacker:IsAlive() and not attacker:IsIllusion() and target and IsValidEntity(target) and target:IsAlive() then
			local ability = self:GetAbility()
			if ability == nil then return end
			local chance = ability:GetSpecialValueFor("chance_hit")
			if RollPercentage(chance) then
				local target_hp = ability:GetSpecialValueFor("target_hp")
				local stack_count = parent:FindModifierByName("modifier_item_broken_bow_count")				
				local attacks_needed = (ability:GetSpecialValueFor("attacks_needed") - 2) or 1
				if stack_count:GetStackCount() > attacks_needed then
					if target:IsAlive() then
						local damage = math.floor(target:GetHealth() / target_hp)
						stack_count:SetStackCount(0)
						local iParticle = ParticleManager:CreateParticle("particles/msg_fx/msg_spell.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
						ParticleManager:SetParticleControlEnt(iParticle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
						ParticleManager:SetParticleControl(iParticle, 1, Vector(0, damage, 6))
						ParticleManager:SetParticleControl(iParticle, 2, Vector(1, math.floor(math.log10(damage))+2, 100))
						ParticleManager:SetParticleControl(iParticle, 3, Vector(165,66,179))
						ParticleManager:ReleaseParticleIndex( iParticle )
						parent:PerformAttack(target, true, true, true, true, true, false, false)

						ApplyDamage({
							attacker = parent,
							victim = target,
							ability = ability,
							damage = damage,
							damage_type = DAMAGE_TYPE_MAGICAL,
						})
					end
				else
					stack_count:SetStackCount(stack_count:GetStackCount() + 1)	
				end	
			end
			if ability:IsCooldownReady() then
				if attacker == parent and not target:IsNull() and target:IsAlive() then 
					if not target:HasModifier("modifier_item_willbreaker_debuff") then
						--print(durationz .. " duration")
						local armor_reduction = target:GetPhysicalArmorBaseValue() * self:GetAbility():GetSpecialValueFor("armor_reduc") / 100
						local dubuff_modifier = target:AddNewModifier(attacker, ability, "modifier_item_willbreaker_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration") * (1 + parent:GetStatusResistance())})
						dubuff_modifier:SetStackCount(armor_reduction)
						ability:UseResources(false, false, false, true)
						local particle = ParticleManager:CreateParticle("particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_ti8_immortal_pitofmalice_burst_spark.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
						ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
						ParticleManager:ReleaseParticleIndex(particle)
					end	
				end
			end			
		end
	end	
end

-- Willbreaker Debuff --
modifier_item_willbreaker_debuff = class({})
function modifier_item_willbreaker_debuff:IsHidden() return false end
function modifier_item_willbreaker_debuff:IsPurgable() return false end
function modifier_item_willbreaker_debuff:GetTexture() return "crossbow" end
function modifier_item_willbreaker_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET
	}
end
function modifier_item_willbreaker_debuff:GetModifierPhysicalArmorBonus()
	return -self:GetStackCount()
end
function modifier_item_willbreaker_debuff:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("magic_resist_redu")
end
function modifier_item_willbreaker_debuff:GetModifierHealAmplify_PercentageTarget() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("heal_redu") * (-1) end end
-- Broken Bow Count --
modifier_item_broken_bow_count = class({})
function modifier_item_broken_bow_count:IsPurgable() return false end
function modifier_item_broken_bow_count:GetTexture() return "item_ForaMon/broken_bow" end
function modifier_item_broken_bow_count:RemoveOnDeath() return false end

------------------
-- Water Blades --
------------------
item_water_blades = item_water_blades or class({})
LinkLuaModifier("modifier_water_blades", "items/water_blades.lua", LUA_MODIFIER_MOTION_NONE)
function item_water_blades:GetIntrinsicModifierName() return "modifier_water_blades" end
-- Water Blades Modifier
modifier_water_blades = modifier_water_blades or class({})
function modifier_water_blades:IsHidden() return true end
function modifier_water_blades:IsPurgable() return false end
function modifier_water_blades:RemoveOnDeath() return false end
function modifier_water_blades:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_water_blades:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_water_blades:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_water_blades:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_as") end
function modifier_water_blades:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("agi") end
function modifier_water_blades:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("hp_regen") end
function modifier_water_blades:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetCaster()
		local reflect = self:GetAbility():GetSpecialValueFor("reflect")
		local target = params.unit
		local attacker = params.attacker
		local damage = params.damage
		local damage_type = params.damage_type
		local reflect_damage = damage * (reflect / 100)
		if attacker ~= nil and target == caster and reflect_damage ~= 0 then
			if not caster:IsIllusion() then
				if attacker ~= caster and attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
					local wb = ParticleManager:CreateParticle("particles/custom/items/water_blades/water_blades.vpcf", PATTACH_ABSORIGIN, caster)
					ParticleManager:SetParticleControlEnt(wb, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetOrigin(), true)
					ApplyDamage({victim = attacker, attacker = caster, damage = reflect_damage, damage_type = damage_type, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, ability = self:GetAbility()})
				end
			end
		end
	end
end

--------------------
-- Water Blades 2 --
--------------------
item_water_blades_2 = item_water_blades_2 or class({})
LinkLuaModifier("modifier_water_blades_2", "items/water_blades.lua", LUA_MODIFIER_MOTION_NONE)
function item_water_blades_2:GetIntrinsicModifierName() return "modifier_water_blades_2" end
-- Water Blades 2 Modifier
modifier_water_blades_2 = modifier_water_blades_2 or class({})
function modifier_water_blades_2:IsHidden() return true end
function modifier_water_blades_2:IsPurgable() return false end
function modifier_water_blades_2:RemoveOnDeath() return false end
function modifier_water_blades_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_water_blades_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_water_blades_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_water_blades_2:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_as") end
function modifier_water_blades_2:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("agi") end
function modifier_water_blades_2:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("hp_regen") end
function modifier_water_blades_2:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetCaster()
		local reflect = self:GetAbility():GetSpecialValueFor("reflect")
		local target = params.unit
		local attacker = params.attacker
		local damage = params.damage
		local damage_type = params.damage_type
		local reflect_damage = damage * (reflect / 100)
		if attacker ~= nil and target == caster and reflect_damage ~= 0 then
			if not caster:IsIllusion() then
				if attacker ~= caster and attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
					local wb = ParticleManager:CreateParticle("particles/custom/items/water_blades/water_blades.vpcf", PATTACH_ABSORIGIN, caster)
					ParticleManager:SetParticleControlEnt(wb, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetOrigin(), true)
					ApplyDamage({victim = attacker, attacker = caster, damage = reflect_damage, damage_type = damage_type, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, ability = self:GetAbility()})
				end
			end
		end
	end
end

--------------------
-- Water Blades 3 --
--------------------
item_water_blades_3 = item_water_blades_3 or class({})
LinkLuaModifier("modifier_water_blades_3", "items/water_blades.lua", LUA_MODIFIER_MOTION_NONE)
function item_water_blades_3:GetIntrinsicModifierName() return "modifier_water_blades_3" end
-- Water Blades 3 Modifier
modifier_water_blades_3 = modifier_water_blades_3 or class({})
function modifier_water_blades_3:IsHidden() return true end
function modifier_water_blades_3:IsPurgable() return false end
function modifier_water_blades_3:RemoveOnDeath() return false end
function modifier_water_blades_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_water_blades_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_water_blades_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_water_blades_3:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_as") end
function modifier_water_blades_3:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("agi") end
function modifier_water_blades_3:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("hp_regen") end
function modifier_water_blades_3:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetCaster()
		local reflect = self:GetAbility():GetSpecialValueFor("reflect")
		local target = params.unit
		local attacker = params.attacker
		local damage = params.damage
		local damage_type = params.damage_type
		local reflect_damage = damage * (reflect / 100)
		if attacker ~= nil and target == caster and reflect_damage ~= 0 then
			if not caster:IsIllusion() then
				if attacker ~= caster and attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
					local wb = ParticleManager:CreateParticle("particles/custom/items/water_blades/water_blades.vpcf", PATTACH_ABSORIGIN, caster)
					ParticleManager:SetParticleControlEnt(wb, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetOrigin(), true)
					ApplyDamage({victim = attacker, attacker = caster, damage = reflect_damage, damage_type = damage_type, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, ability = self:GetAbility()})
				end
			end
		end
	end
end


--------------------
-- Water Carapace --
--------------------
item_water_carapace = item_water_carapace or class({})
LinkLuaModifier("modifier_water_carapace", "items/water_blades.lua", LUA_MODIFIER_MOTION_NONE)
function item_water_carapace:GetIntrinsicModifierName() return "modifier_water_carapace" end
-- Water Carapace Modifier
modifier_water_carapace = modifier_water_carapace or class({})
function modifier_water_carapace:IsHidden() return true end
function modifier_water_carapace:IsPurgable() return false end
function modifier_water_carapace:RemoveOnDeath() return false end
function modifier_water_carapace:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_water_carapace:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_water_carapace:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_water_carapace:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_as") end
function modifier_water_carapace:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("agi") end
function modifier_water_carapace:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("hp_regen") end
function modifier_water_carapace:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("damage") end
function modifier_water_carapace:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("armor") end
function modifier_water_carapace:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetCaster()
		local reflect = self:GetAbility():GetSpecialValueFor("reflect")
		local target = params.unit
		local attacker = params.attacker
		local damage = params.damage
		local damage_type = params.damage_type
		local reflect_damage = damage * (reflect / 100)
		if attacker ~= nil and target == caster and reflect_damage ~= 0 then
			if not caster:IsIllusion() then
				if attacker ~= caster and attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
					local wb = ParticleManager:CreateParticle("particles/custom/items/water_blades/water_blades.vpcf", PATTACH_ABSORIGIN, caster)
					ParticleManager:SetParticleControlEnt(wb, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetOrigin(), true)
					ApplyDamage({victim = attacker, attacker = caster, damage = reflect_damage, damage_type = damage_type, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, ability = self:GetAbility()})
				end
			end
		end
	end
end


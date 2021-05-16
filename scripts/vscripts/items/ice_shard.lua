---------------
-- Ice Shard --
---------------
if item_ice_shard == nil then item_ice_shard = class({}) end
LinkLuaModifier("modifier_ice_shard", "items/ice_shard.lua", LUA_MODIFIER_MOTION_NONE)
function item_ice_shard:GetIntrinsicModifierName() return "modifier_ice_shard" end

-- Ice Shard Modifier --
if modifier_ice_shard == nil then modifier_ice_shard = class({}) end
function modifier_ice_shard:IsHidden() return true end
function modifier_ice_shard:IsDebuff() return false end
function modifier_ice_shard:IsPurgable() return false end
function modifier_ice_shard:IsPermanent() return true end
function modifier_ice_shard:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ice_shard:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_CASTTIME_PERCENTAGE}
end
function modifier_ice_shard:GetModifierPercentageManacostStacking() return self:GetAbility():GetSpecialValueFor("mcst_red") end
function modifier_ice_shard:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("hp_regen") end
function modifier_ice_shard:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_ice_shard:GetModifierPercentageCasttime() return self:GetAbility():GetSpecialValueFor("cast_time") end

-----------------
-- Ice Shard 2 --
-----------------
if item_ice_shard_2 == nil then item_ice_shard_2 = class({}) end
LinkLuaModifier("modifier_ice_shard_2", "items/ice_shard.lua", LUA_MODIFIER_MOTION_NONE)
function item_ice_shard_2:GetIntrinsicModifierName() return "modifier_ice_shard_2" end

-- Ice Shard Modifier --
if modifier_ice_shard_2 == nil then modifier_ice_shard_2 = class({}) end
function modifier_ice_shard_2:IsHidden() return true end
function modifier_ice_shard_2:IsDebuff() return false end
function modifier_ice_shard_2:IsPurgable() return false end
function modifier_ice_shard_2:IsPermanent() return true end
function modifier_ice_shard_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ice_shard_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_CASTTIME_PERCENTAGE}
end
function modifier_ice_shard_2:GetModifierPercentageManacostStacking() return self:GetAbility():GetSpecialValueFor("mcst_red") end
function modifier_ice_shard_2:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("hp_regen") end
function modifier_ice_shard_2:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_ice_shard_2:GetModifierPercentageCasttime() return self:GetAbility():GetSpecialValueFor("cast_time") end

-----------------
-- Ice Shard 3 --
-----------------
if item_ice_shard_3 == nil then item_ice_shard_3 = class({}) end
LinkLuaModifier("modifier_ice_shard_3", "items/ice_shard.lua", LUA_MODIFIER_MOTION_NONE)
function item_ice_shard_3:GetIntrinsicModifierName() return "modifier_ice_shard_3" end

-- Ice Shard Modifier --
if modifier_ice_shard_3 == nil then modifier_ice_shard_3 = class({}) end
function modifier_ice_shard_3:IsHidden() return true end
function modifier_ice_shard_3:IsDebuff() return false end
function modifier_ice_shard_3:IsPurgable() return false end
function modifier_ice_shard_3:IsPermanent() return true end
function modifier_ice_shard_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ice_shard_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_CASTTIME_PERCENTAGE}
end
function modifier_ice_shard_3:GetModifierPercentageManacostStacking() return self:GetAbility():GetSpecialValueFor("mcst_red") end
function modifier_ice_shard_3:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("hp_regen") end
function modifier_ice_shard_3:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_ice_shard_3:GetModifierPercentageCasttime() return self:GetAbility():GetSpecialValueFor("cast_time") end







-----------------
-- Ice Aluneth --
-----------------
if item_ice_aluneth == nil then item_ice_aluneth = class({}) end
LinkLuaModifier("modifier_ice_aluneth", "items/ice_shard.lua", LUA_MODIFIER_MOTION_NONE)
function item_ice_aluneth:GetIntrinsicModifierName() return "modifier_ice_aluneth" end
function item_ice_aluneth:OnSpellStart()
	if self:GetCurrentCharges() > 0 then
		self:SetCurrentCharges(self:GetCurrentCharges()-1)
		local caster = self:GetCaster()
		local rotationAngle = caster:GetAngles()
		rotationAngle.y = rotationAngle.y - 180*RandomInt(0,1)
		print(rotationAngle)
		local relPos = Vector(0, -250, 0)
		relPos = RotatePosition( Vector(0,0,0), rotationAngle, relPos )
		local absPos = GetGroundPosition(relPos + caster:GetAbsOrigin(), caster)
		local shift_pfx = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_event_glitch.vpcf", PATTACH_ABSORIGIN, caster)
		local center = caster:GetAbsOrigin() - ((caster:GetAbsOrigin()-absPos)/2)
		print(center)
		ParticleManager:SetParticleControl(shift_pfx,0,center)
		caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
		caster:SetAbsOrigin(absPos)
		FindClearSpaceForUnit(caster, absPos, false)
		ProjectileManager:ProjectileDodge(caster)
	end
end

-- Ice Aluneth Modifier --
if modifier_ice_aluneth == nil then modifier_ice_aluneth = class({}) end
function modifier_ice_aluneth:IsHidden() return true end
function modifier_ice_aluneth:IsDebuff() return false end
function modifier_ice_aluneth:IsPurgable() return false end
function modifier_ice_aluneth:IsPermanent() return true end
function modifier_ice_aluneth:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ice_aluneth:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
		MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
end
function modifier_ice_aluneth:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_str") end
function modifier_ice_aluneth:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agi") end
function modifier_ice_aluneth:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end
function modifier_ice_aluneth:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_amp") end
function modifier_ice_aluneth:GetModifierPercentageManacostStacking() return self:GetAbility():GetSpecialValueFor("mcst_red") end
function modifier_ice_aluneth:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("mana_regen") end
function modifier_ice_aluneth:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_ice_aluneth:GetModifierCastRangeBonusStacking() return self:GetAbility():GetSpecialValueFor("cast_range") end
function modifier_ice_aluneth:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("hp_regen") end
function modifier_ice_aluneth:GetModifierPercentageCasttime() return self:GetAbility():GetSpecialValueFor("cast_time") end
function modifier_ice_aluneth:GetModifierMPRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("mp_regen_amp") end
function modifier_ice_aluneth:GetModifierSpellLifestealRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_lifesteal_amp") end
function modifier_ice_aluneth:OnAbilityExecuted(params)
	if IsServer() then
        if not self:GetCaster():IsIllusion() then
            if params.unit == self:GetCaster() then
				if not params.ability:IsItem() and not params.ability:IsToggle() then
					if self:GetAbility():GetCurrentCharges() < 10 then
						self:GetAbility():SetCurrentCharges(self:GetAbility():GetCurrentCharges()+1)
					end
                end
            end
        end
    end
	return 0
end
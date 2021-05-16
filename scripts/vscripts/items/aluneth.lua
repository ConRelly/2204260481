if item_aluneth == nil then item_aluneth = class({}) end
LinkLuaModifier( "modifier_aluneth", "items/aluneth.lua", LUA_MODIFIER_MOTION_NONE )
function item_aluneth:GetIntrinsicModifierName() return "modifier_aluneth" end
function item_aluneth:OnSpellStart()
	if self:GetCurrentCharges() > 0 then
		self:SetCurrentCharges(self:GetCurrentCharges()-1)
		local caster = self:GetCaster()
		local rotationAngle = caster:GetAngles()
		rotationAngle.y = rotationAngle.y - 180*RandomInt(0,1)
		print(rotationAngle)
		local relPos = Vector(0, -150, 0)
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

if modifier_aluneth == nil then modifier_aluneth = class({}) end
function modifier_aluneth:IsHidden() return true end
function modifier_aluneth:IsDebuff() return false end
function modifier_aluneth:IsPurgable() return false end
function modifier_aluneth:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_aluneth:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
		MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
end
function modifier_aluneth:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_str") end
function modifier_aluneth:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agi") end
function modifier_aluneth:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end
function modifier_aluneth:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_amp") end
function modifier_aluneth:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("mana_regen") end
function modifier_aluneth:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_aluneth:GetModifierCastRangeBonusStacking() return self:GetAbility():GetSpecialValueFor("cast_range") end
function modifier_aluneth:GetModifierMPRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("mp_regen_amp") end
function modifier_aluneth:GetModifierSpellLifestealRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_lifesteal_amp") end
function modifier_aluneth:OnAbilityExecuted(params)
	if IsServer() then
        if not self:GetCaster():IsIllusion() then
            if params.unit == self:GetCaster() then
				if not params.ability:IsItem() and not params.ability:IsToggle() then
					if self:GetAbility():GetCurrentCharges() < 5 then
						self:GetAbility():SetCurrentCharges(self:GetAbility():GetCurrentCharges()+1)
					end
                end
            end
        end
    end
	return 0
end
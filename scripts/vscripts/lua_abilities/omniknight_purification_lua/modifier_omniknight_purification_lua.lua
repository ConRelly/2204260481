--------------------------------------------------------------------------------
modifier_omniknight_purification_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_omniknight_purification_lua:IsHidden()
	return false
end

function modifier_omniknight_purification_lua:IsDebuff()
	return false
end

function modifier_omniknight_purification_lua:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_omniknight_purification_lua:OnCreated( kv )
	-- references
	self.armor = self:GetCaster():GetStrength() * self:GetAbility():GetSpecialValueFor( "armor_str_multiplier" )
	self:SetStackCount(1)
end

function modifier_omniknight_purification_lua:OnRefresh( kv )
	-- references
	self.armor = self:GetCaster():GetStrength() * self:GetAbility():GetSpecialValueFor( "armor_str_multiplier" )
	self:IncrementStackCount()
end

function modifier_omniknight_purification_lua:OnRemoved()
end

function modifier_omniknight_purification_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_omniknight_purification_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}

	return funcs
end

function modifier_omniknight_purification_lua:GetModifierMagicalResistanceBonus()
	return self:GetStackCount() * self.armor
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_omniknight_purification_lua:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf"
end

function modifier_omniknight_purification_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

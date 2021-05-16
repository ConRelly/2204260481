modifier_omniknight_repel_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_omniknight_repel_lua:IsHidden()
	return true
end

function modifier_omniknight_repel_lua:IsDebuff()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_omniknight_repel_lua:OnCreated( kv )
	-- references
	self.repel_chance = self:GetAbility():GetSpecialValueFor( "repel_chance" )
end

function modifier_omniknight_repel_lua:OnRefresh( kv )
	-- references
	self.repel_chance = self:GetAbility():GetSpecialValueFor( "repel_chance" )
end

function modifier_omniknight_repel_lua:OnRemoved()
end

function modifier_omniknight_repel_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_omniknight_repel_lua:IsAura()
	return true
end

function modifier_omniknight_repel_lua:GetModifierAura()
	return "modifier_omniknight_repel_lua_effect"
end

function modifier_omniknight_repel_lua:GetAuraRadius()
	-- cancel if break
	if self:GetParent():PassivesDisabled() then return 0 end
	return self:GetAbility():GetSpecialValueFor( "radius" )
end

function modifier_omniknight_repel_lua:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_omniknight_repel_lua:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end
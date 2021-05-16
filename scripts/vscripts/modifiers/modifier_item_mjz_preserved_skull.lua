-- Project Name: 	Siltbreaker Hard Mode
-- Author:			BroFrank
-- SteamAccountID:	144490770

modifier_item_mjz_preserved_skull = class({})


function modifier_item_mjz_preserved_skull:IsHidden() 
	return true
end


function modifier_item_mjz_preserved_skull:IsPurgable()
	return false
end


function modifier_item_mjz_preserved_skull:IsAura()
	return true
end


function modifier_item_mjz_preserved_skull:GetModifierAura()
	return  "modifier_item_mjz_preserved_skull_buff"
end


function modifier_item_mjz_preserved_skull:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end


function modifier_item_mjz_preserved_skull:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end
function modifier_item_mjz_preserved_skull:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

function modifier_item_mjz_preserved_skull:GetAuraRadius()
	return self.radius
end


function modifier_item_mjz_preserved_skull:OnCreated( kv )
	self.bonus_health = self:GetAbility():GetSpecialValueFor( "bonus_health" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.bonus_intelligence = self:GetAbility():GetSpecialValueFor( "bonus_intelligence" )
	
	-- "particles/new_custom/items/item_preserved_skull/item_preserved_skull_caster.vpcf"
	--local p = "particles/items/item_mjz_preserved_skull/item_mjz_preserved_skull_caster.vpcf"
	--self.FX = ParticleManager:CreateParticle( p, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end


function modifier_item_mjz_preserved_skull:OnDestroy( kv )
	--ParticleManager:DestroyParticle( self.FX, false )
end


function modifier_item_mjz_preserved_skull:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end


function modifier_item_mjz_preserved_skull:GetModifierBonusStats_Intellect( params )
	return self.bonus_intelligence
end

--------------------------------------------------------------------------------

function modifier_item_mjz_preserved_skull:GetModifierHealthBonus( params )
	return self.bonus_health
end



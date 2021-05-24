-- Project Name: 	Siltbreaker Hard Mode
-- Author:			BroFrank
-- SteamAccountID:	144490770

modifier_item_mjz_preserved_skull_effect = class({})

----------------------------------------

function modifier_item_mjz_preserved_skull_effect:GetTexture()
	return "item_mjz_preserved_skull"
end

----------------------------------------

function modifier_item_mjz_preserved_skull_effect:OnCreated( kv )
	self.cooldown_reduction_pct = self:GetAbility():GetSpecialValueFor( "cooldown_reduction_pct" )
	self.aura_mana_regen = self:GetAbility():GetSpecialValueFor( "aura_mana_regen" )
	
	-- "particles/new_custom/items/item_preserved_skull/item_preserved_skull_target.vpcf"
	local p = "particles/items/item_mjz_preserved_skull/item_mjz_preserved_skull_target.vpcf"
	self.FX = ParticleManager:CreateParticle( p, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end

----------------------------------------

function modifier_item_mjz_preserved_skull_effect:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_item_mjz_preserved_skull_effect:OnDestroy( kv )
	ParticleManager:DestroyParticle( self.FX, false )
end

----------------------------------------

function modifier_item_mjz_preserved_skull_effect:GetModifierConstantManaRegen( params )
	return self.aura_mana_regen
end

----------------------------------------

function modifier_item_mjz_preserved_skull_effect:GetModifierPercentageCooldown( params )
	return self.cooldown_reduction_pct
end




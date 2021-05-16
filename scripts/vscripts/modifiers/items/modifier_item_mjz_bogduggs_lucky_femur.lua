modifier_item_mjz_bogduggs_lucky_femur = class({})

function modifier_item_mjz_bogduggs_lucky_femur:IsHidden() return true end

function modifier_item_mjz_bogduggs_lucky_femur:IsPurgable() return false end

function modifier_item_mjz_bogduggs_lucky_femur:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
	return funcs
end

function modifier_item_mjz_bogduggs_lucky_femur:GetModifierBonusStats_Intellect( params )
	return self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
end

function modifier_item_mjz_bogduggs_lucky_femur:GetModifierManaBonus( params )
	return self:GetAbility():GetSpecialValueFor( "bonus_mana" )
end

function modifier_item_mjz_bogduggs_lucky_femur:GetModifierConstantManaRegen( params )
	return self:GetAbility():GetSpecialValueFor( "bonus_mana_regen" )
end

function modifier_item_mjz_bogduggs_lucky_femur:OnAbilityFullyCast( params )
	if IsServer() then
		local use_unit = params.unit
		local use_ability = params.ability
		local ability = self:GetAbility()

		if not ability then return 0 end
		if not ability:IsCooldownReady() then return 0 end
		if use_unit ~= self:GetParent() then return 0 end
		if use_ability == nil then return 0 end
		if use_ability:IsItem() then return 0 end
		if not use_ability:IsRefreshable() then return 0 end
		if use_ability:GetCooldownTimeRemaining() == 0 then return 0 end

		local refresh_pct = self:GetAbility():GetSpecialValueFor( "refresh_pct" )
		if RollPercentage( refresh_pct ) then
			local cooldown = ability:GetCooldown(ability:GetLevel())
			ability:EndCooldown()
			ability:StartCooldown(cooldown)
			
			self.use_ability = use_ability
			self:StartIntervalThink(0.25)
		end
	end
	return 0
end


if IsServer() then
	function modifier_item_mjz_bogduggs_lucky_femur:OnIntervalThink()
		local use_ability = self.use_ability
		use_ability:EndCooldown()

		local p_name = "particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf"
		local nFXIndex = ParticleManager:CreateParticle( p_name, PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 2, 1 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		EmitSoundOn( "Hero_OgreMagi.Fireblast.x1", self:GetParent() )

		self:StartIntervalThink(-1)
	end
end



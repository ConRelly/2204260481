LinkLuaModifier("modifier_item_mjz_bogduggs_lucky_femur", "items/item_mjz_bogduggs_lucky_femur", LUA_MODIFIER_MOTION_NONE)

item_mjz_bogduggs_lucky_femur = class({})
item_mjz_bogduggs_lucky_femur_2 = class({})
item_mjz_bogduggs_lucky_femur_3 = class({})
item_mjz_bogduggs_lucky_femur_4 = class({})
item_mjz_bogduggs_lucky_femur_5 = class({})

function item_mjz_bogduggs_lucky_femur:GetIntrinsicModifierName() return "modifier_item_mjz_bogduggs_lucky_femur" end
function item_mjz_bogduggs_lucky_femur_2:GetIntrinsicModifierName() return "modifier_item_mjz_bogduggs_lucky_femur" end
function item_mjz_bogduggs_lucky_femur_3:GetIntrinsicModifierName() return "modifier_item_mjz_bogduggs_lucky_femur" end
function item_mjz_bogduggs_lucky_femur_4:GetIntrinsicModifierName() return "modifier_item_mjz_bogduggs_lucky_femur" end
function item_mjz_bogduggs_lucky_femur_5:GetIntrinsicModifierName() return "modifier_item_mjz_bogduggs_lucky_femur" end

modifier_item_mjz_bogduggs_lucky_femur = class({})
function modifier_item_mjz_bogduggs_lucky_femur:IsHidden() return true end
function modifier_item_mjz_bogduggs_lucky_femur:IsPurgable() return false end
function modifier_item_mjz_bogduggs_lucky_femur:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
end
function modifier_item_mjz_bogduggs_lucky_femur:GetModifierBonusStats_Intellect(params)
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end
function modifier_item_mjz_bogduggs_lucky_femur:GetModifierManaBonus(params)
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end
function modifier_item_mjz_bogduggs_lucky_femur:GetModifierConstantManaRegen(params)
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end
function modifier_item_mjz_bogduggs_lucky_femur:OnAbilityFullyCast(params)
	if IsServer() then
		local use_unit = params.unit
		local use_ability = params.ability
		local ability = self:GetAbility()
		
		if IsExcludeAbility(use_ability) then return false end

		if not ability then return 0 end
		if not ability:IsCooldownReady() then return 0 end
		if use_unit ~= self:GetParent() then return 0 end
		if use_ability == nil then return 0 end
		if use_ability:IsItem() then return 0 end
		if not use_ability:IsRefreshable() then return 0 end
		if use_ability:GetCooldownTimeRemaining() == 0 then return 0 end
		if not use_ability:ProcsMagicStick() then return end

		local refresh_pct = self:GetAbility():GetSpecialValueFor("refresh_pct")
		if RollPercentage(refresh_pct) then
			local cooldown = ability:GetCooldown(ability:GetLevel())
			ability:EndCooldown()
			ability:StartCooldown(cooldown)

			Timers:CreateTimer(0.25, function()
				use_ability:EndCooldown()
				local p_name = "particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf"
				local nFXIndex = ParticleManager:CreateParticle(p_name, PATTACH_OVERHEAD_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 2, 1))
				ParticleManager:ReleaseParticleIndex(nFXIndex)

				EmitSoundOn("Hero_OgreMagi.Fireblast.x1", self:GetParent())
			end)

			self:StartIntervalThink(0.25)
		end
	end
	return 0
end


function IsExcludeAbility(ability)
	local list = {
		"mjz_phoenix_sun_ray_toggle_move",
		"mjz_phoenix_sun_ray_cancel",
		"phoenix_launch_fire_spirit",
		"rubick_telekinesis_land",
		"tusk_launch_snowball",
		"obsidian_destroyer_arcane_orb",
		"wisp_tether_break",
		"arcane_supremacy",
	}
	local abilityName = ability:GetAbilityName()
	for _,name in pairs(list) do
		if abilityName == name then
			return true
		end
	end
	return false
end

LinkLuaModifier("modifier_medusa_custom_stone_arrows", "abilities/heroes/medusa_custom_stone_arrows.lua", LUA_MODIFIER_MOTION_NONE)


medusa_custom_stone_arrows = class({})
function medusa_custom_stone_arrows:GetIntrinsicModifierName() return "modifier_medusa_custom_stone_arrows" end


modifier_medusa_custom_stone_arrows = class({})
function modifier_medusa_custom_stone_arrows:IsHidden() return true end
function modifier_medusa_custom_stone_arrows:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end
function modifier_medusa_custom_stone_arrows:GetModifierBaseAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("extra_damage")
end
function modifier_medusa_custom_stone_arrows:GetModifierAttackSpeedPercentage()
	local attack_speed = self:GetAbility():GetSpecialValueFor("attack_speed_loss")
	if self:GetCaster():HasItemInInventory("item_skadi_bow") then
		attack_speed = attack_speed - 10
	end
    return attack_speed * (-1)
end
function modifier_medusa_custom_stone_arrows:GetModifierMoveSpeedBonus_Percentage()
	local movement_speed = self:GetAbility():GetSpecialValueFor("move_speed_loss")
	if self:GetCaster():HasItemInInventory("item_skadi_bow") then
		movement_speed = movement_speed - 10
	end
    return movement_speed * (-1)
end
function modifier_medusa_custom_stone_arrows:OnAttackLanded(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local target = keys.target
		if caster ~= keys.attacker then return end
		if not caster:HasScepter() then return end
		local StoneGaze = caster:FindAbilityByName("medusa_stone_gaze")
		if caster:HasAbility("medusa_stone_gaze") and StoneGaze:IsTrained() then
			local GazeChance = self:GetAbility():GetSpecialValueFor("stone_gaze_chance")
			if RollPercentage(GazeChance) then
				local GazeDuration = self:GetAbility():GetSpecialValueFor("stone_gaze_duration")
				if caster:HasModifier("modifier_super_scepter") then
					GazeDuration = GazeDuration * 2
				end
				local bonus_physical_damage = StoneGaze:GetSpecialValueFor("bonus_physical_damage")
				target:AddNewModifier(caster, StoneGaze, "modifier_medusa_stone_gaze_stone", {bonus_physical_damage = bonus_physical_damage, duration = GazeDuration})
			end
		end
	end
end

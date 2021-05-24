LinkLuaModifier("modifier_mjz_night_stalker_hunter_in_the_night","abilities/hero_night_stalker/mjz_night_stalker_hunter_in_the_night.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_night_stalker_hunter_in_the_night_mspeed","abilities/hero_night_stalker/mjz_night_stalker_hunter_in_the_night.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_night_stalker_hunter_in_the_night_aspeed","abilities/hero_night_stalker/mjz_night_stalker_hunter_in_the_night.lua", LUA_MODIFIER_MOTION_NONE)

mjz_night_stalker_hunter_in_the_night = class({})
local ability_class = mjz_night_stalker_hunter_in_the_night

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_night_stalker_hunter_in_the_night"
end


---------------------------------------------------------------------------------------

modifier_mjz_night_stalker_hunter_in_the_night = class({})
local modifier_class = modifier_mjz_night_stalker_hunter_in_the_night

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
    function modifier_class:OnCreated()
        self.double = self:GetAbility():GetSpecialValueFor("bonus_double_in_night") or 0
        self:OnIntervalThink()
        self:StartIntervalThink(2.5)
    end
    function modifier_class:OnIntervalThink()
       
        self:BonusModifier("bonus_movement_speed_pct", "modifier_mjz_night_stalker_hunter_in_the_night_mspeed")
        self:BonusModifier("bonus_attack_speed", "modifier_mjz_night_stalker_hunter_in_the_night_aspeed")
    end

    function modifier_class:BonusModifier( specialName, modifierName )
        local hCaster = self:GetCaster()
        local hAbility = self:GetAbility()
        local hParent = self:GetParent()
        local bonus = hAbility:GetTalentSpecialValueFor(specialName)

        if self.double > 0 then
            if not GameRules:IsDaytime() then
                bonus = bonus * 2
            end
        end

        if hParent:PassivesDisabled() then
            bonus = 0
        end

        local modifier = nil
        if not hParent:HasModifier(modifierName) then
            modifier = hParent:AddNewModifier(hCaster, hAbility, modifierName, {})
        end
        if modifier == nil then
            modifier = hParent:FindModifierByName(modifierName)
        end
        if modifier ~= nil then
            if modifier:GetStackCount() ~= bonus then
                modifier:SetStackCount(bonus)
            end
        end
    end
end

-----------------------------------------------------------------------------------------

modifier_mjz_night_stalker_hunter_in_the_night_mspeed = class({})
local modifier_mspeed = modifier_mjz_night_stalker_hunter_in_the_night_mspeed

function modifier_mspeed:IsPassive() return true end
function modifier_mspeed:IsHidden() return true end
function modifier_mspeed:IsPurgable() return false end

function modifier_mspeed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_mspeed:GetModifierMoveSpeedBonus_Percentage( )
    return self:GetStackCount()
end

-----------------------------------------------------------------------------------------

modifier_mjz_night_stalker_hunter_in_the_night_aspeed = class({})
local modifier_aspeed = modifier_mjz_night_stalker_hunter_in_the_night_aspeed

function modifier_aspeed:IsPassive() return true end
function modifier_aspeed:IsHidden() return true end
function modifier_aspeed:IsPurgable() return false end

function modifier_aspeed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_aspeed:GetModifierAttackSpeedBonus_Constant( )
    return self:GetStackCount()
end
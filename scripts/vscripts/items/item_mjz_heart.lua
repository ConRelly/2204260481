LinkLuaModifier( "modifier_item_mjz_heart", "items/item_mjz_heart", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_heart_buff", "items/item_mjz_heart", LUA_MODIFIER_MOTION_NONE )

---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------

item_mjz_heart_2 = class({})

function item_mjz_heart_2:GetIntrinsicModifierName()
	return "modifier_item_mjz_heart"
end

---------------------------------------------------------------------------------------

item_mjz_heart_3 = class({})

function item_mjz_heart_3:GetIntrinsicModifierName()
	return "modifier_item_mjz_heart"
end

---------------------------------------------------------------------------------------

item_mjz_heart_4 = class({})

function item_mjz_heart_4:GetIntrinsicModifierName()
	return "modifier_item_mjz_heart"
end

---------------------------------------------------------------------------------------

item_mjz_heart_5 = class({})

function item_mjz_heart_5:GetIntrinsicModifierName()
	return "modifier_item_mjz_heart"
end

---------------------------------------------------------------------------------------

if modifier_item_mjz_heart == nil then modifier_item_mjz_heart = class({}) end
-- function modifier_item_mjz_heart:IsPassive() return true end
function modifier_item_mjz_heart:IsHidden() return true end
function modifier_item_mjz_heart:IsPurgable() return false end
function modifier_item_mjz_heart:GetAttributes() 
	return MODIFIER_ATTRIBUTE_MULTIPLE              -- 多个龙芯属性加成叠加
end

function modifier_item_mjz_heart:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		-- MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		-- MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		-- MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        -- MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        -- MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return decFuncs
end

-- function modifier_item_mjz_heart:GetModifierMoveSpeedBonus_Percentage()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
-- end
function modifier_item_mjz_heart:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_strength")
end
-- function modifier_item_mjz_heart:GetModifierBonusStats_Agility()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_agility")
-- end
-- function modifier_item_mjz_heart:GetModifierBonusStats_Intellect()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
-- end
-- function modifier_item_mjz_heart:GetModifierAttackSpeedBonus_Constant()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
-- end
-- function modifier_item_mjz_heart:GetModifierPhysicalArmorBonus()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_armor")
-- end
function modifier_item_mjz_heart:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end


if IsServer() then
    function modifier_item_mjz_heart:OnCreated(table)
        local parent = self:GetParent()
        if IsValidEntity(parent) and parent:IsRealHero() then
            -- self.modifiers = {}
            self:StartIntervalThink(1.0)
        end
    end

    function modifier_item_mjz_heart:OnIntervalThink()
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        if IsValidEntity(parent) and parent:IsRealHero() then
            local mt = {
                "modifier_item_mjz_heart_buff",
            }

            for _,mname in pairs(mt) do
                if not parent:HasModifier(mname) then
                    parent:AddNewModifier(caster, ability, mname, {})
                end
            end
        end
    end

    function modifier_item_mjz_heart:OnDestroy()
        local parent = self:GetParent()
        if IsValidEntity(parent) and parent:IsAlive() then
            local mt = {
                "modifier_item_mjz_heart_buff",
            }

            for _,mname in pairs(mt) do
                parent:RemoveModifierByName(mname)
            end
        end
    end

end


-------------------------------------------------------------------------------

modifier_item_mjz_heart_buff = class({})
function modifier_item_mjz_heart_buff:IsHidden() return true end
function modifier_item_mjz_heart_buff:IsPurgable() return false end
function modifier_item_mjz_heart_buff:IsBuff() return true end
function modifier_item_mjz_heart_buff:GetTexture() 
    return "item_mjz_heart" 
end

function modifier_item_mjz_heart_buff:DeclareFunctions()
	local decFuncs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	}
	return decFuncs
end

function modifier_item_mjz_heart_buff:GetModifierHealthRegenPercentage()
    local ability = self:GetAbility()
    if IsValidEntity(ability) then
	    return ability:GetSpecialValueFor("health_regen_rate")
    end
end
function modifier_item_mjz_heart_buff:GetModifierHPRegenAmplify_Percentage()
    local ability = self:GetAbility()
    if IsValidEntity(ability) then
	    return ability:GetSpecialValueFor("hp_regen_amp")
    end
end


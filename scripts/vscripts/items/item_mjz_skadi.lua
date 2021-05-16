LinkLuaModifier( "modifier_item_mjz_skadi", "items/item_mjz_skadi", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_skadi_cold_attack", "items/item_mjz_skadi", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_skadi_debuff", "items/item_mjz_skadi", LUA_MODIFIER_MOTION_NONE )
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------

item_mjz_skadi_2 = class({})

function item_mjz_skadi_2:GetIntrinsicModifierName()
	return "modifier_item_mjz_skadi"
end

---------------------------------------------------------------------------------------

item_mjz_skadi_3 = class({})

function item_mjz_skadi_3:GetIntrinsicModifierName()
	return "modifier_item_mjz_skadi"
end

---------------------------------------------------------------------------------------

item_mjz_skadi_4 = class({})

function item_mjz_skadi_4:GetIntrinsicModifierName()
	return "modifier_item_mjz_skadi"
end

---------------------------------------------------------------------------------------

item_mjz_skadi_5 = class({})

function item_mjz_skadi_5:GetIntrinsicModifierName()
	return "modifier_item_mjz_skadi"
end

---------------------------------------------------------------------------------------

if modifier_item_mjz_skadi == nil then modifier_item_mjz_skadi = class({}) end
-- function modifier_item_mjz_skadi:IsPassive() return true end
function modifier_item_mjz_skadi:IsHidden() return true end
function modifier_item_mjz_skadi:IsPurgable() return false end
function modifier_item_mjz_skadi:GetAttributes() 
	return MODIFIER_ATTRIBUTE_MULTIPLE              -- 多个龙芯属性加成叠加
end

function modifier_item_mjz_skadi:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		-- MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        -- MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        -- MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
	}
	return decFuncs
end

-- function modifier_item_mjz_skadi:GetModifierMoveSpeedBonus_Percentage()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
-- end
function modifier_item_mjz_skadi:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")  -- bonus_strength
end
function modifier_item_mjz_skadi:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats") -- bonus_agility
end
function modifier_item_mjz_skadi:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats") -- bonus_intellect
end
-- function modifier_item_mjz_skadi:GetModifierAttackSpeedBonus_Constant()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
-- end
-- function modifier_item_mjz_skadi:GetModifierPhysicalArmorBonus()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_armor")
-- end
function modifier_item_mjz_skadi:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end
function modifier_item_mjz_skadi:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

if IsServer() then
    function modifier_item_mjz_skadi:OnCreated(table)
        local parent = self:GetParent()
        if IsValidEntity(parent) and parent:IsRealHero() then
            self:StartIntervalThink(1.0)
        end
    end

    function modifier_item_mjz_skadi:OnIntervalThink()
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        if IsValidEntity(parent) and parent:IsRealHero() then
            local mt = {
                "modifier_item_mjz_skadi_cold_attack",
            }

            for _,mname in pairs(mt) do
                if not parent:HasModifier(mname) then
                    parent:AddNewModifier(caster, ability, mname, {})
                end
            end
        end
    end

    function modifier_item_mjz_skadi:OnDestroy()
        local parent = self:GetParent()
        if IsValidEntity(parent) and parent:IsAlive() then
            local mt = {
                "modifier_item_mjz_skadi_cold_attack",
            }

            for _,mname in pairs(mt) do
                parent:RemoveModifierByName(mname)
            end
        end
    end

end


-------------------------------------------------------------------------------


if modifier_item_mjz_skadi_cold_attack == nil then modifier_item_mjz_skadi_cold_attack = class({}) end
-- function modifier_item_mjz_skadi:IsPassive() return true end
function modifier_item_mjz_skadi_cold_attack:IsHidden() return true end
function modifier_item_mjz_skadi_cold_attack:IsPurgable() return false end

if IsServer() then
    function modifier_item_mjz_skadi_cold_attack:DeclareFunctions()
        local decFuncs = {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
        return decFuncs
    end

    function modifier_item_mjz_skadi_cold_attack:OnAttackLanded(keys)
        local target = keys.target
		local attacker = keys.attacker
		if attacker == self:GetParent() then
            local ability = self:GetAbility()
            local duration = ability:GetSpecialValueFor("cold_duration_melee")
            if IsValidEntity(target) and target:IsAlive() then
                if target:IsRangedAttacker() then
                    duration = ability:GetSpecialValueFor("cold_duration_ranged")
                end
			    target:AddNewModifier(attacker, ability, "modifier_item_mjz_skadi_debuff", {duration = duration})
            end
		end
    end

    function modifier_item_mjz_skadi_cold_attack:OnCreated()
        if self:GetParent():IsRangedAttacker() then 
            -- self:GetParent():SetRangedProjectileName("particles/items2_fx/skadi_projectile.vpcf") 
        end 
	end

    function modifier_item_mjz_skadi_cold_attack:OnDestroy()
        
	end

end


-------------------------------------------------------------------------------

modifier_item_mjz_skadi_debuff = class({})
function modifier_item_mjz_skadi_debuff:IsHidden() return false end
function modifier_item_mjz_skadi_debuff:IsPurgable() return true end
function modifier_item_mjz_skadi_debuff:IsDebuff() return true end
function modifier_item_mjz_skadi_debuff:GetTexture() 
    return "item_mjz_skadi" 
end

function modifier_item_mjz_skadi_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf" 
end
function modifier_item_mjz_skadi_debuff:StatusEffectPriority()
    return 11 
end
    
function modifier_item_mjz_skadi_debuff:DeclareFunctions()
	local decFuncs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return decFuncs
end

function modifier_item_mjz_skadi_debuff:GetModifierAttackSpeedBonus_Constant()
    local ability = self:GetAbility()
    if IsValidEntity(ability) then
	    return ability:GetSpecialValueFor("cold_attack_speed")
    end
end
function modifier_item_mjz_skadi_debuff:GetModifierMoveSpeedBonus_Percentage()
    local ability = self:GetAbility()
    if IsValidEntity(ability) then
	    return ability:GetSpecialValueFor("cold_movement_speed")
    end
end


LinkLuaModifier( "modifier_item_mjz_assault", "items/item_mjz_assault", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_assault_aura_friendly", "items/item_mjz_assault", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_assault_aura_enemy", "items/item_mjz_assault", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_assault_buff", "items/item_mjz_assault", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_assault_debuff", "items/item_mjz_assault", LUA_MODIFIER_MOTION_NONE )

---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------

item_mjz_assault_2 = class({})

function item_mjz_assault_2:GetIntrinsicModifierName()
	return "modifier_item_mjz_assault"
end

---------------------------------------------------------------------------------------

item_mjz_assault_3 = class({})

function item_mjz_assault_3:GetIntrinsicModifierName()
	return "modifier_item_mjz_assault"
end

---------------------------------------------------------------------------------------

item_mjz_assault_4 = class({})

function item_mjz_assault_4:GetIntrinsicModifierName()
	return "modifier_item_mjz_assault"
end

---------------------------------------------------------------------------------------

item_mjz_assault_5 = class({})

function item_mjz_assault_5:GetIntrinsicModifierName()
	return "modifier_item_mjz_assault"
end

---------------------------------------------------------------------------------------

if modifier_item_mjz_assault == nil then modifier_item_mjz_assault = class({}) end
-- function modifier_item_mjz_assault:IsPassive() return true end
function modifier_item_mjz_assault:IsHidden() return true end
function modifier_item_mjz_assault:IsPurgable() return false end

function modifier_item_mjz_assault:DeclareFunctions()
	local decFuncs = {
		-- MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		-- MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		-- MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		-- MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return decFuncs
end

-- function modifier_item_mjz_assault:GetModifierMoveSpeedBonus_Percentage()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
-- end
-- function modifier_item_mjz_assault:GetModifierBonusStats_Strength()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_strength")
-- end
-- function modifier_item_mjz_assault:GetModifierBonusStats_Agility()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_agility")
-- end
-- function modifier_item_mjz_assault:GetModifierBonusStats_Intellect()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
-- end
function modifier_item_mjz_assault:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end
function modifier_item_mjz_assault:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

if IsServer() then
    function modifier_item_mjz_assault:OnCreated(table)
        local parent = self:GetParent()
        if IsValidEntity(parent) and parent:IsRealHero() then
            -- self.modifiers = {}
            self:StartIntervalThink(1.0)
        end
    end

    function modifier_item_mjz_assault:OnIntervalThink()
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        if IsValidEntity(parent) and parent:IsRealHero() then
            local mt = {
                "modifier_item_mjz_assault_aura_friendly",
                "modifier_item_mjz_assault_aura_enemy",
            }

            for _,mname in pairs(mt) do
                if not parent:HasModifier(mname) then
                    parent:AddNewModifier(caster, ability, mname, {})
                end
            end
        end
    end

    function modifier_item_mjz_assault:OnDestroy()
        local parent = self:GetParent()
        if IsValidEntity(parent) and parent:IsAlive() then
            local mt = {
                "modifier_item_mjz_assault_aura_friendly",
                "modifier_item_mjz_assault_aura_enemy",
            }

            for _,mname in pairs(mt) do
                parent:RemoveModifierByName(mname)
            end
        end
    end

end

----------------------------------------------------------------------

modifier_item_mjz_assault_aura_friendly = class({})
local modifier_aura_friendly = modifier_item_mjz_assault_aura_friendly

function modifier_aura_friendly:IsHidden() return true end
function modifier_aura_friendly:IsPurgable() return false end
------------------------------------------------

function modifier_aura_friendly:IsAura() return true end

function modifier_aura_friendly:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
    -- return self:GetAbility():GetAOERadius()
end

function modifier_aura_friendly:GetModifierAura()
    return "modifier_item_mjz_assault_buff"
end

function modifier_aura_friendly:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY -- DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_aura_friendly:GetAuraEntityReject(target)
    return self:GetParent():IsIllusion()
end

function modifier_aura_friendly:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC --  DOTA_UNIT_TARGET_ALL -- 
end

function modifier_aura_friendly:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE -- DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES  -- DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE 
end

function modifier_aura_friendly:GetAuraDuration()
    return 0.25
end

------------------------------------------------


----------------------------------------------------------------------

modifier_item_mjz_assault_aura_enemy = class({})
local modifier_aura_enemy = modifier_item_mjz_assault_aura_enemy

function modifier_aura_enemy:IsHidden() return true end
function modifier_aura_enemy:IsPurgable() return false end
------------------------------------------------

function modifier_aura_enemy:IsAura() return true end

function modifier_aura_enemy:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
    -- return self:GetAbility():GetAOERadius()
end

function modifier_aura_enemy:GetModifierAura()
    return "modifier_item_mjz_assault_debuff"
end

function modifier_aura_enemy:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY -- DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_aura_enemy:GetAuraEntityReject(target)
    return self:GetParent():IsIllusion()
end

function modifier_aura_enemy:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC --  DOTA_UNIT_TARGET_ALL -- 
end

function modifier_aura_enemy:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES  -- DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE  -- DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_aura_friendly:GetAuraDuration()
    return 0.25
end

------------------------------------------------


-------------------------------------------------------------------------------

modifier_item_mjz_assault_buff = class({})
function modifier_item_mjz_assault_buff:IsHidden() return false end
function modifier_item_mjz_assault_buff:IsBuff() return true end
function modifier_item_mjz_assault_buff:GetTexture() 
    return "item_mjz_assault" 
end

function modifier_item_mjz_assault_buff:DeclareFunctions()
	local decFuncs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return decFuncs
end

function modifier_item_mjz_assault_buff:GetModifierAttackSpeedBonus_Constant()
    local ability = self:GetAbility()
    if IsValidEntity(ability) then
	    return ability:GetSpecialValueFor("aura_attack_speed")
    end
end
function modifier_item_mjz_assault_buff:GetModifierPhysicalArmorBonus()
    local ability = self:GetAbility()
    if IsValidEntity(ability) then
	    return ability:GetSpecialValueFor("aura_positive_armor")
    end
end

-------------------------------------------------------------------------------

modifier_item_mjz_assault_debuff = class({})
function modifier_item_mjz_assault_debuff:IsHidden() return false end
function modifier_item_mjz_assault_debuff:IsDebuff() return true end
function modifier_item_mjz_assault_debuff:GetTexture() 
    return "item_mjz_assault" 
end

function modifier_item_mjz_assault_debuff:DeclareFunctions()
	local decFuncs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return decFuncs
end

function modifier_item_mjz_assault_debuff:GetModifierPhysicalArmorBonus()
    local ability = self:GetAbility()
    if IsValidEntity(ability) then
	    return ability:GetSpecialValueFor("aura_negative_armor")
    end
end
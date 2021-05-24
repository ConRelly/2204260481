LinkLuaModifier("modifier_item_mjz_guardian_greaves_holy_light", "items/item_mjz_guardian_greaves_holy_light.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mjz_guardian_greaves_holy_light_aura", "items/item_mjz_guardian_greaves_holy_light.lua", LUA_MODIFIER_MOTION_NONE)

item_mjz_guardian_greaves_holy_light = class({})
local item_class = item_mjz_guardian_greaves_holy_light

function item_class:GetIntrinsicModifierName()
    return "modifier_item_mjz_guardian_greaves_holy_light"
end

function item_class:OnSpellStart()
    local abiltiy = self
    local caster = self:GetCaster()
    local replenish_radius = abiltiy:GetSpecialValueFor('replenish_radius')
    local replenish_health_pct = abiltiy:GetSpecialValueFor('replenish_health_pct')
    local replenish_mana_pct = abiltiy:GetSpecialValueFor('replenish_mana_pct')

    -- caster:EmitSound("sounds/items/guardian_greaves.vsnd")
    caster:EmitSound('Item.GuardianGreaves.Activate')

    local friends = FindTargets(caster, caster:GetAbsOrigin(), replenish_radius)
    for _,unit in pairs(friends) do
        local flAmount_health = unit:GetMaxHealth() * (replenish_health_pct / 100.0)
        local flAmount_mana = unit:GetMaxMana() * (replenish_mana_pct / 100.0)

        HealTarget(unit, flAmount_health, abiltiy)

        ReplenishMana(unit, flAmount_mana)

        -- unit:Purge(bRemovePositiveBuffs, bRemoveDebuffs, bFrameOnly, bRemoveStuns, bRemoveExceptions)
        unit:Purge(false, true, false, true, false)

        unit:EmitSound('Item.GuardianGreaves.Target')
    end
end

function HealTarget(unit, flAmount, abiltiy)
    unit:Heal(flAmount, abiltiy)

    local iParticle1 = ParticleManager:CreateParticle("particles/msg_fx/msg_heal.vpcf", PATTACH_POINT_FOLLOW, unit)
    ParticleManager:SetParticleControl(iParticle1, 1, Vector(0, flAmount, 0))
    ParticleManager:SetParticleControl(iParticle1, 2, Vector(1, 4, 200))
    ParticleManager:SetParticleControl(iParticle1, 3, Vector(60, 255, 60))
    ParticleManager:ReleaseParticleIndex(iParticle1)

    if flAmount > 250 then
		ParticleManager:CreateParticle("particles/econ/events/ti6/mekanism_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
	else
		ParticleManager:CreateParticle("particles/items2_fx/mekanism.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
	end
end

function ReplenishMana( unit, flAmount)
    local mana = unit:GetMana() + flAmount
    if mana > unit:GetMaxMana() then
        unit:SetMana(unit:GetMaxMana())
    else
        unit:SetMana(mana)
    end

    local iParticle1 = ParticleManager:CreateParticle("particles/msg_fx/msg_mana_add.vpcf", PATTACH_POINT_FOLLOW, unit)
	ParticleManager:SetParticleControl(iParticle1, 1, Vector(0, math.floor(flAmount), 0))
	ParticleManager:SetParticleControl(iParticle1, 2, Vector(1, 2+math.floor(math.log10(flAmount)), 500))
	ParticleManager:SetParticleControl(iParticle1, 3, Vector(20, 20, 100))	
    ParticleManager:ReleaseParticleIndex(iParticle1)
end


-- 搜索目标位置所有的敌人单位
function FindTargets(unit, point, radius)
    local iTeamNumber = unit:GetTeamNumber()
    local vPosition = point   				-- 搜索中心点
    local hCacheUnit = nil                  -- 通常值
    local flRadius = radius                 -- 搜索范围
    local iTeamFilter = DOTA_UNIT_TARGET_TEAM_FRIENDLY  -- 目标是敌人单位
    -- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP           
	-- 忽视建筑物、支持魔法免疫
    local iFlagFilter = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE   
    local iOrder = FIND_CLOSEST                         -- 寻找最近的
    local bCanGrowCache = false             -- 通常值
    return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
        flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
end

----------------------------------------------------------------------------------------

modifier_item_mjz_guardian_greaves_holy_light = class({})
local modifier_class = modifier_item_mjz_guardian_greaves_holy_light

function modifier_class:IsHidden() return true end
function modifier_class:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_class:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,
        MODIFIER_PROPERTY_MANA_BONUS,
    }
end

function modifier_class:GetModifierBonusStats_Strength( )
    return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_class:GetModifierBonusStats_Agility( )
    return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_class:GetModifierBonusStats_Intellect( )
    return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_class:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor( "bonus_armor" )
end
function modifier_class:GetModifierMoveSpeedBonus_Percentage_Unique( )
    return self:GetAbility():GetSpecialValueFor("bonus_movement")
end
function modifier_class:GetModifierManaBonus( )
    return self:GetAbility():GetSpecialValueFor("bonus_mana")
end


--------------------------------------------------------------

function modifier_class:IsAura()
	return true
end

function modifier_class:GetModifierAura()
	return "modifier_item_mjz_guardian_greaves_holy_light_aura"
end

function modifier_class:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_class:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_class:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_class:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor( "aura_radius" )
end


-------------------------------------------------------------------

modifier_item_mjz_guardian_greaves_holy_light_aura = class({})
local modifier_aura = modifier_item_mjz_guardian_greaves_holy_light_aura

function modifier_aura:IsHidden()
    return false
end
function modifier_aura:IsPurgable()	-- 能否被驱散
	return false
end
function modifier_aura:GetTexture()
	return "item_mjz_guardian_greaves_holy_light"
end

function modifier_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
end
function modifier_aura:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor( "aura_armor" )
end
function modifier_aura:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor( "aura_health_regen" )
end

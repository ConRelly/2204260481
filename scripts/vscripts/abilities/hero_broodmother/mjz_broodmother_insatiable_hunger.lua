local THIS_LUA = "abilities/hero_broodmother/mjz_broodmother_insatiable_hunger.lua"
LinkLuaModifier("modifier_mjz_broodmother_insatiable_hunger", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_broodmother_insatiable_hunger_damage", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_broodmother_insatiable_hunger_aspeed", THIS_LUA, LUA_MODIFIER_MOTION_NONE)


-----------------------------------------------------------------------------------------


mjz_broodmother_insatiable_hunger = class({})
local ability_class = mjz_broodmother_insatiable_hunger


function ability_class:OnSpellStart()
    if not IsServer() then return end
    local hCaster = self:GetCaster()
    local hAbility = self
    local duration = hAbility:GetTalentSpecialValueFor("duration")
    local M_NAME = "modifier_mjz_broodmother_insatiable_hunger"


    hCaster:AddNewModifier(hCaster, hAbility, M_NAME, {Duration = duration})

    if hCaster:HasScepter() then
        local spiders = {}
        local hSS = hCaster:FindAbilityByName("mjz_broodmother_spawn_spiderlings")
        if hSS and hSS:GetLevel() > 0 then
            spiders = hSS:GetSpiders()
        end

        for _,spider in pairs(spiders) do
            spider:AddNewModifier(hCaster, hAbility, M_NAME, {Duration = duration})
        end
    end
end


---------------------------------------------------------------------------------------

modifier_mjz_broodmother_insatiable_hunger = class({})
local modifier_buff = modifier_mjz_broodmother_insatiable_hunger

function modifier_buff:IsHidden() return false end
function modifier_buff:IsPurgable() return false end

function modifier_buff:GetStatusEffectName()
    return "particles/units/heroes/hero_broodmother/broodmother_hunger_hero_effect.vpcf"
end

function modifier_buff:StatusEffectPriority()
    return 10
end

if IsServer() then
    function modifier_buff:DeclareFunctions()
        local funcs = { 
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
        return funcs
    end
    
    function modifier_buff:OnAttackLanded(params)
        if params.attacker == self:GetParent() then
            if not self:GetParent():IsHero() then return end
            local parent = self:GetParent()
            local damageDealt = params.damage or 0

            local lifesteal_pct = self:GetAbility():GetTalentSpecialValueFor("lifesteal_pct")

            local lifesteal = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
            ParticleManager:SetParticleControlEnt(lifesteal, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(lifesteal, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(lifesteal)
                
	        local flHeal = damageDealt * lifesteal_pct / 100
	        parent:HealEventOnly( flHeal, parent, parent )

        end
    end

    function modifier_buff:OnCreated()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        
        self.caster = caster
        self.ability = ability
        self.target = parent

        local P_NAME = "particles/units/heroes/hero_broodmother/broodmother_hunger_buff.vpcf"
        self.pfx = ParticleManager:CreateParticle(P_NAME, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_thorax", self:GetParent():GetAbsOrigin(), true)
        
        if parent:IsHero() then
            parent:EmitSound("Hero_Broodmother.InsatiableHunger")
        end


        local duration = self:GetDuration()
        local m_damage = parent:AddNewModifier(caster, ability, "modifier_mjz_broodmother_insatiable_hunger_damage", {duration = duration})
        local m_aspeed = parent:AddNewModifier(caster, ability, "modifier_mjz_broodmother_insatiable_hunger_aspeed", {duration = duration})
        
        m_damage:SetStackCount(ability:GetTalentSpecialValueFor("bonus_damage"))
        m_aspeed:SetStackCount(ability:GetTalentSpecialValueFor("bonus_attack_speed"))
        
    end
    
    function modifier_buff:OnDestroy()
        local parent = self:GetParent()
        if parent:IsHero() then
            parent:StopSound("Hero_Broodmother.InsatiableHunger")
        end
    
        if self.pfx then
            ParticleManager:DestroyParticle(self.pfx, false)
            ParticleManager:ReleaseParticleIndex(self.pfx)
        end
    end
end

---------------------------------------------------------------------------------------

modifier_mjz_broodmother_insatiable_hunger_damage = class({})
local modifier_buff_damage = modifier_mjz_broodmother_insatiable_hunger_damage

function modifier_buff_damage:IsHidden() return true end
function modifier_buff_damage:IsPurgable() return false end

function modifier_buff_damage:DeclareFunctions()
    local funcs = { 
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,    
    }
    return funcs
end

function modifier_buff_damage:GetModifierBaseAttack_BonusDamage()
    return self:GetStackCount()
end

---------------------------------------------------------------------------------------

modifier_mjz_broodmother_insatiable_hunger_aspeed = class({})
local modifier_buff_aspeed= modifier_mjz_broodmother_insatiable_hunger_aspeed

function modifier_buff_aspeed:IsHidden() return true end
function modifier_buff_aspeed:IsPurgable() return false end

function modifier_buff_aspeed:DeclareFunctions()
    local funcs = { 
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,    
    }
    return funcs
end

function modifier_buff_aspeed:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount()
end


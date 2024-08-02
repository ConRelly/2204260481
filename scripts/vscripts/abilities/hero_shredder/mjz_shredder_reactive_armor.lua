
local THIS_LUA = 'abilities/hero_shredder/mjz_shredder_reactive_armor.lua'
local MODIFIER_INIT_NAME = 'modifier_mjz_shredder_reactive_armor'
local MODIFIER_PHYSICAL_NAME = 'modifier_mjz_shredder_reactive_armor_physical'
local MODIFIER_MAGIC_NAME = 'modifier_mjz_shredder_reactive_armor_magic'
local MODIFIER_REGEN_NAME = 'modifier_mjz_shredder_reactive_armor_regen'

LinkLuaModifier(MODIFIER_INIT_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_PHYSICAL_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_MAGIC_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_REGEN_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)

mjz_shredder_reactive_armor = class({})
local ability_class = mjz_shredder_reactive_armor

function ability_class:GetIntrinsicModifierName()
    return MODIFIER_INIT_NAME
end

---------------------------------------------------------------------------------------

modifier_mjz_shredder_reactive_armor = class({})
local modifier_class = modifier_mjz_shredder_reactive_armor

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

if IsServer() then
    function modifier_class:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_TAKEDAMAGE,
        }
        return funcs
    end

    function modifier_class:OnTakeDamage(keys)
        if keys.unit ~= self:GetParent() then return nil end
        if keys.unit:PassivesDisabled() then return nil end

        local damge = keys.damage
        local damage_type = keys.damage_type
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local stack_limit = GetTalentSpecialValueFor(ability, 'stack_limit')
        local stack_duration = GetTalentSpecialValueFor(ability, 'stack_duration')

        local modifier_list = {
            MODIFIER_PHYSICAL_NAME,
            MODIFIER_MAGIC_NAME,
            MODIFIER_REGEN_NAME,
        }

        local stack_count = self:GetStackCount()
        if stack_count < stack_limit then
            stack_count = stack_count + 1
            self:SetStackCount(stack_count)
            self:RefreshStackCount()
        end

        if (GameRules:GetGameTime() - self.OnTakeDamageTime) > 1 then
            self.OnTakeDamageTime = GameRules:GetGameTime()
            self:StartIntervalThink(stack_duration)
        end
    end

    function modifier_class:OnCreated(table)
        local ability = self:GetAbility()
        self.OnTakeDamageTime = 0
    end

    function modifier_class:OnIntervalThink()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local stack_duration = GetTalentSpecialValueFor(ability, 'stack_duration')
        local modifier_list = {
            MODIFIER_PHYSICAL_NAME,
            MODIFIER_MAGIC_NAME,
            MODIFIER_REGEN_NAME,
        }

        local stack_count = self:GetStackCount()
        if stack_count > 0 then
            self:SetStackCount(0)
        end

        self:RefreshStackCount()

        self:StartIntervalThink(-1)
    end

    function modifier_class:RefreshStackCount()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local modifier_list = {
            MODIFIER_PHYSICAL_NAME,
            MODIFIER_MAGIC_NAME,
            MODIFIER_REGEN_NAME,
        }

        local stack_count = self:GetStackCount()

        for _,m_name in pairs(modifier_list) do
            if not parent:HasModifier(m_name) then
                parent:AddNewModifier(parent, ability, m_name, {})  -- {duration = stack_duration}       
            end
            local m = parent:FindModifierByName(m_name)
            if m:GetStackCount() ~= stack_count then
                m:SetStackCount(stack_count)
            end
        end
    end
end

-----------------------------------------------------------------------------------------

modifier_mjz_shredder_reactive_armor_physical = modifier_mjz_shredder_reactive_armor_physical or class({})

function modifier_mjz_shredder_reactive_armor_physical:IsDebuff() return false end
function modifier_mjz_shredder_reactive_armor_physical:IsHidden() return true end
function modifier_mjz_shredder_reactive_armor_physical:IsPurgable() return false end
function modifier_mjz_shredder_reactive_armor_physical:RemoveOnDeath() return false end

function modifier_mjz_shredder_reactive_armor_physical:GetAttributes()
	local attributes = {
		MODIFIER_ATTRIBUTE_MULTIPLE
	}
	return attributes
end

function modifier_mjz_shredder_reactive_armor_physical:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end

function modifier_mjz_shredder_reactive_armor_physical:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor") * self:GetStackCount()
end

-----------------------------------------------------------------------------------------

modifier_mjz_shredder_reactive_armor_magic = modifier_mjz_shredder_reactive_armor_magic or class({})

function modifier_mjz_shredder_reactive_armor_magic:IsDebuff() return false end
function modifier_mjz_shredder_reactive_armor_magic:IsHidden() return true end
function modifier_mjz_shredder_reactive_armor_magic:IsPurgable() return false end
function modifier_mjz_shredder_reactive_armor_magic:RemoveOnDeath() return false end

function modifier_mjz_shredder_reactive_armor_magic:GetAttributes()
	local attributes = {
		MODIFIER_ATTRIBUTE_MULTIPLE
	}
	return attributes
end

function modifier_mjz_shredder_reactive_armor_magic:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
end

function modifier_mjz_shredder_reactive_armor_magic:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_magic_resist") * self:GetStackCount()
end

-----------------------------------------------------------------------------------------

modifier_mjz_shredder_reactive_armor_regen = modifier_mjz_shredder_reactive_armor_regen or class({})

function modifier_mjz_shredder_reactive_armor_regen:IsDebuff() return false end
function modifier_mjz_shredder_reactive_armor_regen:IsHidden() return true end
function modifier_mjz_shredder_reactive_armor_regen:IsPurgable() return false end
function modifier_mjz_shredder_reactive_armor_regen:RemoveOnDeath() return false end

function modifier_mjz_shredder_reactive_armor_regen:GetAttributes()
	local attributes = {
		MODIFIER_ATTRIBUTE_MULTIPLE
	}
	return attributes
end

function modifier_mjz_shredder_reactive_armor_regen:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
	return funcs
end

function modifier_mjz_shredder_reactive_armor_regen:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_hp_regen") * self:GetStackCount()
end

-----------------------------------------------------------------------------------------


function KillTreesInRadius(caster, center, radius)
    local particles = {
        "particles/newplayer_fx/npx_tree_break.vpcf",
        "particles/newplayer_fx/npx_tree_break_b.vpcf",
    }
    local particle = GetRandomTableElement(particles)

    local trees = GridNav:GetAllTreesAroundPoint(center, radius, true)
    for _,tree in pairs(trees) do
        local particle_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_fx, 0, tree:GetAbsOrigin())
        tree:Kill()
    end
    GridNav:DestroyTreesAroundPoint(center, radius, true)
end


-- 是否学习了指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local bonusOperation
    local kv = ability:GetAbilityKeyValues()
    
    if kv.AbilityValues then
        local valueData = kv.AbilityValues[value]
        if type(valueData) == "table" then
            talentName = valueData.LinkedSpecialBonus
            bonusOperation = valueData.LinkedSpecialBonusOperation
        end
    end
    
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            local bonusValue = talent:GetSpecialValueFor("value")
            
            if bonusOperation then
                if bonusOperation == "SPECIAL_BONUS_ADD" or bonusOperation == "SPECIAL_BONUS_SUBTRACT" then
                    base = base + bonusValue -- For subtraction, bonusValue should already be negative
                elseif bonusOperation == "SPECIAL_BONUS_MULTIPLY" then
                    base = base * bonusValue
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_ADD" then
                    base = base * (1 + bonusValue / 100)
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_SUBTRACT" then
                    base = base * (1 - bonusValue / 100)
                end
            else
                -- Default behavior if no operation is specified
                base = base + bonusValue
            end
        end
    end
    
    return base
end
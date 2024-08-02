
local MODIFIER_LUA = "modifiers/hero_slardar/modifier_mjz_slardar_slithereen_crush.lua"
local MODIFIER_AURA_EFFECT_FRIENDLY_NAME = 'modifier_mjz_slardar_slithereen_crush_aura_effect_friendly'
local MODIFIER_AURA_EFFECT_ENEMY_NAME = 'modifier_mjz_slardar_slithereen_crush_aura_effect_enemy'
LinkLuaModifier(MODIFIER_AURA_EFFECT_FRIENDLY_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_AURA_EFFECT_ENEMY_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)


----------------------------------------------------------------------

modifier_mjz_slardar_slithereen_crush_radius_talent = class({})
function modifier_mjz_slardar_slithereen_crush_radius_talent:IsHidden() return true end
function modifier_mjz_slardar_slithereen_crush_radius_talent:IsPurgable() return false end
function modifier_mjz_slardar_slithereen_crush_radius_talent:RemoveOnDeath() return false end

----------------------------------------------------------------------

modifier_mjz_slardar_slithereen_crush_dummy = class({})

function modifier_mjz_slardar_slithereen_crush_dummy:IsHidden() return true end
function modifier_mjz_slardar_slithereen_crush_dummy:IsPurgable() return false end

function modifier_mjz_slardar_slithereen_crush_dummy:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}
	return state
end

if IsServer() then
    function modifier_mjz_slardar_slithereen_crush_dummy:OnCreated(table)
        local ability = self:GetAbility()
        local parent = self:GetParent()
        local radius = GetTalentSpecialValueFor(ability, 'puddle_radius')
        local p_name = "particles/units/heroes/hero_slardar/slardar_water_puddle.vpcf"

        local particle_index = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN, parent)
        ParticleManager:SetParticleControl(particle_index, 0, parent:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_index, 1, Vector(radius, 1, 1))
        self.particle_index = particle_index
    end

    function modifier_mjz_slardar_slithereen_crush_dummy:OnDestroy()
        local parent = self:GetParent()

        if self.particle_index then
            ParticleManager:DestroyParticle(self.particle_index, false)
            ParticleManager:ReleaseParticleIndex(self.particle_index)
        end
    end
end


----------------------------------------------------------------------

modifier_mjz_slardar_slithereen_crush_aura_friendly = class({})
local modifier_aura_friendly = modifier_mjz_slardar_slithereen_crush_aura_friendly

function modifier_aura_friendly:IsHidden() return true end
function modifier_aura_friendly:IsPurgable() return false end

------------------------------------------------

function modifier_aura_friendly:IsAura() return true end

function modifier_aura_friendly:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("puddle_radius")
    --return self:GetAbility():GetAOERadius()
end

function modifier_aura_friendly:GetModifierAura()
    return MODIFIER_AURA_EFFECT_FRIENDLY_NAME
end

function modifier_aura_friendly:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY -- DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_aura_friendly:GetAuraEntityReject(target)
    if target == self:GetCaster() then
        return false
    end
    return true
    --return self:GetParent():IsIllusion()
end

function modifier_aura_friendly:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL -- DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_aura_friendly:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES  -- DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE -- DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_aura_friendly:GetAuraDuration()
    return 0.25
end

------------------------------------------------

----------------------------------------------------------------------

modifier_mjz_slardar_slithereen_crush_aura_enemy = class({})
local modifier_aura_enemy = modifier_mjz_slardar_slithereen_crush_aura_enemy

function modifier_aura_enemy:IsHidden() return true end
function modifier_aura_enemy:IsPurgable() return false end

------------------------------------------------

function modifier_aura_enemy:IsAura() return true end

function modifier_aura_enemy:GetAuraRadius()
    -- return self:GetAbility():GetSpecialValueFor("radius")
    return self:GetAbility():GetAOERadius()
end

function modifier_aura_enemy:GetModifierAura()
    return MODIFIER_AURA_EFFECT_ENEMY_NAME
end

function modifier_aura_enemy:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY -- DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_aura_enemy:GetAuraEntityReject(target)
    return self:GetParent():IsIllusion()
end

function modifier_aura_enemy:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL -- DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_aura_enemy:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES  -- DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE -- DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_aura_enemy:GetAuraDuration()
    return 0.2
end

------------------------------------------------

----------------------------------------------------------------------

modifier_mjz_slardar_slithereen_crush_aura_effect_enemy = class({})
local modifier_effect_enemy = modifier_mjz_slardar_slithereen_crush_aura_effect_enemy

function modifier_effect_enemy:IsHidden() return false end
function modifier_effect_enemy:IsPurgable() return false end

function modifier_effect_enemy:CheckState()
	local state = {
		--[MODIFIER_STATE_STUNNED] = true,
		--[MODIFIER_STATE_FROZEN] = true,
	}
	return state
end

if IsServer() then
    function modifier_effect_enemy:OnCreated()
        if self:GetParent().bAbsoluteNoCC then return end
        local parent = self:GetParent()
        parent:InterruptMotionControllers(false)
    end
end

----------------------------------------------------------------------

modifier_mjz_slardar_slithereen_crush_aura_effect_friendly = class({})
local modifier_effect_friendly = modifier_mjz_slardar_slithereen_crush_aura_effect_friendly

function modifier_effect_friendly:IsHidden() return false end
function modifier_effect_friendly:IsPurgable() return false end

function modifier_effect_friendly:CheckState()
	local state = {
        -- [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end

function modifier_effect_friendly:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING		-- 状态抗性（可以叠加）	
	}
	return funcs
end

function modifier_effect_friendly:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("puddle_armor")
end

function modifier_effect_friendly:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("puddle_regen")
end

function modifier_effect_friendly:GetModifierStatusResistanceStacking()
	return self:GetAbility():GetSpecialValueFor("puddle_status_resistance")
end


if IsServer() then
    function modifier_effect_friendly:OnCreated()
        --local p_name = "particles/units/heroes/hero_slardar/slardar_chrono_speed.vpcf"
		--self.nFXIndex = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		--self:AddParticle(self.nFXIndex, false, false, -1, false, false)
	end
end

----------------------------------------------------------------------


function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
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

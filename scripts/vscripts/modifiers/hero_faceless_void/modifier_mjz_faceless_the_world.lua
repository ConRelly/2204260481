
local MODIFIER_LUA = "modifiers/hero_faceless_void/modifier_mjz_faceless_the_world.lua"
local MODIFIER_AURA_EFFECT_FRIENDLY_NAME = 'modifier_mjz_faceless_the_world_aura_effect_friendly'
local MODIFIER_AURA_EFFECT_ENEMY_NAME = 'modifier_mjz_faceless_the_world_aura_effect_enemy'
LinkLuaModifier(MODIFIER_AURA_EFFECT_FRIENDLY_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_AURA_EFFECT_ENEMY_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)


----------------------------------------------------------------------

modifier_mjz_faceless_the_world_radius_talent = class({})
function modifier_mjz_faceless_the_world_radius_talent:IsHidden() return true end
function modifier_mjz_faceless_the_world_radius_talent:IsPurgable() return false end
function modifier_mjz_faceless_the_world_radius_talent:RemoveOnDeath() return false end

----------------------------------------------------------------------

modifier_mjz_faceless_the_world_dummy = class({})

function modifier_mjz_faceless_the_world_dummy:IsHidden() return true end
function modifier_mjz_faceless_the_world_dummy:IsPurgable() return false end

function modifier_mjz_faceless_the_world_dummy:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}
	return state
end

if IsServer() then
    function modifier_mjz_faceless_the_world_dummy:OnCreated(table)
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        local radius = GetTalentSpecialValueFor(ability, 'radius')
        local p_name = "particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf"
        local p_name_ball = "particles/econ/items/faceless_void/faceless_void_mace_of_aeons/fv_chronosphere_aeons.vpcf"

        if IsMakerHero and IsMakerHero(caster) then
            local nFXIndex = ParticleManager:CreateParticle(p_name_ball, PATTACH_ABSORIGIN, self:GetParent())
            ParticleManager:SetParticleControl(nFXIndex, 0, self:GetParent():GetOrigin())
            ParticleManager:SetParticleControl(nFXIndex, 1, Vector(radius, radius, radius))
            ParticleManager:SetParticleControl(nFXIndex, 4, self:GetParent():GetOrigin())
            ParticleManager:SetParticleControl(nFXIndex, 6, self:GetParent():GetOrigin())
            ParticleManager:SetParticleControl(nFXIndex, 10, self:GetParent():GetOrigin())
            self.particle_index = nFXIndex
        else
            local particle_index = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN, parent)
            ParticleManager:SetParticleControl(particle_index, 0, parent:GetAbsOrigin())
            ParticleManager:SetParticleControl(particle_index, 1, Vector(radius, radius, radius))
            self.particle_index = particle_index
        end
        
    end

    function modifier_mjz_faceless_the_world_dummy:OnDestroy()
        local parent = self:GetParent()

        if self.particle_index then
            ParticleManager:DestroyParticle(self.particle_index, false)
            ParticleManager:ReleaseParticleIndex(self.particle_index)
        end
    end
end


----------------------------------------------------------------------

modifier_mjz_faceless_the_world_aura_friendly = class({})
local modifier_aura_friendly = modifier_mjz_faceless_the_world_aura_friendly

function modifier_aura_friendly:IsHidden() return true end
function modifier_aura_friendly:IsPurgable() return false end

------------------------------------------------

function modifier_aura_friendly:IsAura() return true end

function modifier_aura_friendly:GetAuraRadius()
    -- return self:GetAbility():GetSpecialValueFor("radius")
    return self:GetAbility():GetAOERadius()
end

function modifier_aura_friendly:GetModifierAura()
    return MODIFIER_AURA_EFFECT_FRIENDLY_NAME
end

function modifier_aura_friendly:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY -- DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_aura_friendly:GetAuraEntityReject(target)
    return self:GetParent():IsIllusion()
end

function modifier_aura_friendly:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL -- DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_aura_friendly:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES  -- DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE -- DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_aura_friendly:GetAuraDuration()
    return 0.2
end

------------------------------------------------

----------------------------------------------------------------------

modifier_mjz_faceless_the_world_aura_enemy = class({})
local modifier_aura_enemy = modifier_mjz_faceless_the_world_aura_enemy

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

modifier_mjz_faceless_the_world_aura_effect_enemy = class({})
local modifier_effect_enemy = modifier_mjz_faceless_the_world_aura_effect_enemy

function modifier_effect_enemy:IsHidden() return false end
function modifier_effect_enemy:IsPurgable() return false end

function modifier_effect_enemy:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
	}
	return state
end

if IsServer() then
    function modifier_effect_enemy:OnCreated()
        local parent = self:GetParent()
        parent:InterruptMotionControllers(false)
    end
end

----------------------------------------------------------------------

modifier_mjz_faceless_the_world_aura_effect_friendly = class({})
local modifier_effect_friendly = modifier_mjz_faceless_the_world_aura_effect_friendly

function modifier_effect_friendly:IsHidden() return false end
function modifier_effect_friendly:IsPurgable() return false end

function modifier_effect_friendly:CheckState()
	local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end

function modifier_effect_friendly:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
	}
	return funcs
end

function modifier_effect_friendly:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_effect_friendly:GetModifierMoveSpeed_Max()
	return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_effect_friendly:GetModifierMoveSpeed_Absolute()
	return self:GetAbility():GetSpecialValueFor("speed")
end


if IsServer() then
    function modifier_effect_friendly:OnCreated()
        local p_name = "particles/units/heroes/hero_faceless_void/faceless_void_chrono_speed.vpcf"
		self.nFXIndex = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(self.nFXIndex, false, false, -1, false, false)
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
    local valueName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                    valueName = m["LinkedSpecialBonusField"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            valueName = valueName or 'value'
            base = base + talent:GetSpecialValueFor(valueName) 
        end
    end
    return base
end

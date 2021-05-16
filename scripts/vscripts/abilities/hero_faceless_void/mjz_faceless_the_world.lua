
local THIS_LUA = "abilities/hero_faceless_void/mjz_faceless_the_world.lua"
local MODIFIER_LUA = "modifiers/hero_faceless_void/modifier_mjz_faceless_the_world.lua"


local MODIFIER_DUMMY_NAME = 'modifier_mjz_faceless_the_world_dummy'
local MODIFIER_AURA_FRIENDLY_NAME = 'modifier_mjz_faceless_the_world_aura_friendly'
local MODIFIER_AURA_ENEMY_NAME = 'modifier_mjz_faceless_the_world_aura_enemy'
local MODIFIER_RADIUS_TALENT_NAME = 'modifier_mjz_faceless_the_world_radius_talent'
local MODIFIER_RADIUS_TALENT_VALUE = 575

LinkLuaModifier(MODIFIER_DUMMY_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_AURA_FRIENDLY_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_AURA_ENEMY_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_RADIUS_TALENT_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

mjz_faceless_the_world = class({})
local ability_class = mjz_faceless_the_world

function ability_class:GetAOERadius()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor('radius')
	local has_talent = caster:HasModifier(MODIFIER_RADIUS_TALENT_NAME)
	if has_talent then
		radius = radius + MODIFIER_RADIUS_TALENT_VALUE
	else
		if IsServer() then
			self:CheckRadius()
		end
	end
	return radius
end


if IsServer() then
	function ability_class:CheckRadius()
		local ability = self
		local caster = self:GetCaster()

		if HasTalentBy(ability, 'radius') then
			if not caster:HasModifier(MODIFIER_RADIUS_TALENT_NAME)  then
				caster:AddNewModifier(caster, abiltiy, MODIFIER_RADIUS_TALENT_NAME, nil)
			end
		else
			if caster:HasModifier(MODIFIER_RADIUS_TALENT_NAME) then
				caster:RemoveModifierByName(MODIFIER_RADIUS_TALENT_NAME)
			end
		end
	end

	function ability_class:OnSpellStart()
		local ability = self
		local caster = self:GetCaster()
		local target_point = caster:GetAbsOrigin()
		self:Chronosphere(target_point)

		EmitSoundOn("Hero_FacelessVoid.Chronosphere", caster)
	end

	function ability_class:Chronosphere( target_point )
		local ability = self
		local caster = self:GetCaster()
	
		local radius = GetTalentSpecialValueFor(ability, 'radius')
		local vision_radius = GetTalentSpecialValueFor(ability, 'vision_radius')
		local duration_normal = ability:GetSpecialValueFor('duration')
		local duration_scepter = ability:GetSpecialValueFor('duration_scepter')
		local duration = value_if_scepter(caster, duration_scepter, duration_normal)

		-- Dummy
		local dummy_name = 'npc_dota_invisible_vision_source' -- npc_dummy_unit
		local dummy = CreateUnitByName(dummy_name, target_point, false, caster, caster, caster:GetTeam())
		dummy:AddNewModifier(caster, nil, "modifier_phased", {})
		dummy:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
		dummy:AddNewModifier(caster, ability, "modifier_item_gem_of_true_sight", {duration = duration})
		dummy:AddNewModifier(caster, ability, MODIFIER_DUMMY_NAME, {duration = duration})
		dummy:AddNewModifier(caster, ability, MODIFIER_AURA_FRIENDLY_NAME, {duration = duration})
		dummy:AddNewModifier(caster, ability, MODIFIER_AURA_ENEMY_NAME, {duration = duration})
	
		-- Vision
		AddFOWViewer(caster:GetTeamNumber(), target_point, vision_radius, duration, false)
	
	end
end


----------------------------------------------------------------------

function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
end

function HasTalentBy(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        return talent and talent:GetLevel() > 0 
    end
    return false
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

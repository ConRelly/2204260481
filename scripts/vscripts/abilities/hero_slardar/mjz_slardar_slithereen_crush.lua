
local THIS_LUA = "abilities/hero_slardar/mjz_slardar_slithereen_crush.lua"
local MODIFIER_LUA = "modifiers/hero_slardar/modifier_mjz_slardar_slithereen_crush.lua"

local MODIFIER_AURA_FRIENDLY_NAME = 'modifier_mjz_slardar_slithereen_crush_aura_friendly'
local MODIFIER_AURA_ENEMY_NAME = 'modifier_mjz_slardar_slithereen_crush_aura_enemy'

LinkLuaModifier("modifier_mjz_slardar_slithereen_crush_slow", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier(MODIFIER_ATTACK_SPEED_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_slardar_slithereen_crush_dummy", MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_AURA_FRIENDLY_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_AURA_ENEMY_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

mjz_slardar_slithereen_crush = class({})
local ability_class = mjz_slardar_slithereen_crush

function ability_class:GetAOERadius()
	local radius = self:GetSpecialValueFor('radius')
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		radius = radius + 75
	end
	return radius
end

if IsServer() then
	function ability_class:OnSpellStart()
		local ability = self
		local caster = self:GetCaster()
		local radius = ability:GetSpecialValueFor('radius')
		local base_damage = GetTalentSpecialValueFor(ability, 'base_damage')
		local str_damage_pct = GetTalentSpecialValueFor(ability, 'str_damage_pct')
		local stun_duration = GetTalentSpecialValueFor(ability, 'stun_duration')
		local slow_duration = GetTalentSpecialValueFor(ability, 'slow_duration')
		local particle_hit = "particles/units/heroes/hero_slardar/slardar_crush_entity.vpcf"
		local particle_splash  = "particles/units/heroes/hero_slardar/slardar_crush.vpcf"

		if caster:HasModifier("modifier_item_aghanims_shard") then
			radius = radius + 75
		end

		local damage = base_damage + caster:GetStrength() * (str_damage_pct / 100.0)
		local damageTable = {
			victim = nil,
			attacker = caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			ability = ability,
		}
		
		EmitSoundOn("Hero_SlardarSlithereen_Crush.", caster)

		local nFXIndex = ParticleManager:CreateParticle(particle_splash, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(nFXIndex, 0, caster:GetOrigin())
		ParticleManager:SetParticleControl(nFXIndex, 1, Vector(radius, radius, radius))
		ParticleManager:DestroyParticle(nFXIndex, false)
		ParticleManager:ReleaseParticleIndex(nFXIndex)

		local unit_list = FindUnitsInRadius(
			caster:GetTeamNumber(),
			caster:GetAbsOrigin(),
			nil, radius,
			ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),
			ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER, false
        )
		if IsServer() then
			if caster:HasModifier("modifier_item_aghanims_shard") and caster:FindAbilityByName("corrosive_haze") and caster:FindAbilityByName("corrosive_haze"):GetLevel() > 0 then
				self.shard = true
			else
				self.shard = false
			end
		end
        
        for _,unit in pairs(unit_list) do
			if unit then
				local particle_hit_fx = ParticleManager:CreateParticle(particle_hit, PATTACH_ABSORIGIN, unit)
				ParticleManager:SetParticleControl(particle_hit_fx, 0, unit:GetAbsOrigin())
				ParticleManager:DestroyParticle(particle_hit_fx, false)
				ParticleManager:ReleaseParticleIndex( particle_hit_fx )

				damageTable.victim = unit
				ApplyDamage(damageTable)

				if self.shard then
					unit:AddNewModifier(caster, ability, "modifier_corrosive_haze", {duration = slow_duration})
					unit:FindModifierByName("modifier_corrosive_haze"):SetStackCount(caster:CustomValue("corrosive_haze", "armor_reduction"))
				end

				unit:AddNewModifier(caster, ability, 'modifier_stunned', {duration = stun_duration})
				unit:AddNewModifier(caster, ability, "modifier_mjz_slardar_slithereen_crush_slow", {duration = stun_duration + slow_duration})
            end
		end
		
		if caster:HasScepter() then
			local target_point = caster:GetAbsOrigin()
			self:Puddle(target_point)
		end
	end

	function ability_class:Puddle(target_point)
		local ability = self
		local caster = self:GetCaster()
		local duration = GetTalentSpecialValueFor(ability, 'puddle_duration')
		local puddle_radius = GetTalentSpecialValueFor(ability, 'puddle_radius')
		
		-- Dummy
		local dummy_name = 'npc_dota_invisible_vision_source' -- npc_dummy_unit
		local dummy = CreateUnitByName(dummy_name, target_point, false, caster, caster, caster:GetTeam())
		dummy:AddNewModifier(caster, nil, "modifier_phased", {})
		dummy:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
		dummy:AddNewModifier(caster, ability, "modifier_item_gem_of_true_sight", {duration = duration})
		dummy:AddNewModifier(caster, ability, "modifier_mjz_slardar_slithereen_crush_dummy", {duration = duration})
		dummy:AddNewModifier(caster, ability, MODIFIER_AURA_FRIENDLY_NAME, {duration = duration})
		--dummy:AddNewModifier(caster, ability, MODIFIER_AURA_ENEMY_NAME, {duration = duration})
		
	end

end

----------------------------------------------------------------------

modifier_mjz_slardar_slithereen_crush_slow = class({})
function modifier_mjz_slardar_slithereen_crush_slow:IsDebuff() return true end
function modifier_mjz_slardar_slithereen_crush_slow:IsHidden() return false end
function modifier_mjz_slardar_slithereen_crush_slow:IsPurgable() return true end
function modifier_mjz_slardar_slithereen_crush_slow:OnCreated()
	if self:GetAbility() then
		self.move_speed_slow = self:GetAbility():GetSpecialValueFor("move_speed_slow") + talent_value(self:GetCaster(), "special_bonus_unique_mjz_slardar_slithereen_crush_slow")
		self.attack_speed_slow = self:GetAbility():GetSpecialValueFor("attack_speed_slow") + talent_value(self:GetCaster(), "special_bonus_unique_mjz_slardar_slithereen_crush_slow")
	end
end
function modifier_mjz_slardar_slithereen_crush_slow:OnRefresh()
	self:OnCreated()
end
function modifier_mjz_slardar_slithereen_crush_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_mjz_slardar_slithereen_crush_slow:GetModifierMoveSpeedBonus_Percentage() return self.move_speed_slow end
function modifier_mjz_slardar_slithereen_crush_slow:GetModifierAttackSpeedBonus_Constant() return self.attack_speed_slow end

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

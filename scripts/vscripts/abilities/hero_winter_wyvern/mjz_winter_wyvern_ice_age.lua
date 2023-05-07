LinkLuaModifier("modifier_mjz_winter_wyvern_ice_age_prisoner", "abilities/hero_winter_wyvern/mjz_winter_wyvern_ice_age.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_winter_wyvern_ice_age_debuff", "abilities/hero_winter_wyvern/mjz_winter_wyvern_ice_age.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_winter_wyvern_ice_age_dummy", "abilities/hero_winter_wyvern/mjz_winter_wyvern_ice_age.lua", LUA_MODIFIER_MOTION_NONE)

mjz_winter_wyvern_ice_age = class({})
local ability_class = mjz_winter_wyvern_ice_age

function ability_class:GetIntrinsicModifierName()
	-- return "modifier_mjz_winter_wyvern_ice_age"
end

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end


function ability_class:OnSpellStart()	
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self
		local radius = GetTalentSpecialValueFor(ability, "radius")
		local duration = GetTalentSpecialValueFor(ability, "duration")
		local target_pos = self:GetCursorPosition()

		EmitSoundOn("Hero_Winter_Wyvern.WintersCurse.Cast", caster)

		self:_Dummy(target_pos)

		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(), 
			target_pos, 
			nil, radius, 
			ability:GetAbilityTargetTeam(), 
			ability:GetAbilityTargetType(), 
			ability:GetAbilityTargetFlags(), 
			FIND_CLOSEST, false
		)
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil then
					self:_WintersCurse(enemy)
				end
			end
		end
	end
end

if IsServer() then
	function ability_class:_Dummy( target_pos )
		local caster = self:GetCaster()
		local ability = self
		local radius = GetTalentSpecialValueFor(ability, "radius")
		local duration = GetTalentSpecialValueFor(ability, "duration")

		-- Dummy
		local dummy_name = 'npc_dota_invisible_vision_source' -- npc_dummy_unit
		local dummy = CreateUnitByName(dummy_name, target_pos, false, caster, caster, caster:GetTeam())
		dummy:AddNewModifier(caster, nil, "modifier_phased", {})
		dummy:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
		dummy:AddNewModifier(caster, ability, "modifier_item_gem_of_true_sight", {duration = duration})
		dummy:AddNewModifier(caster, ability, "modifier_mjz_winter_wyvern_ice_age_dummy", {duration = duration})


		local target = dummy	

		EmitSoundOn("Hero_Winter_Wyvern.WintersCurse.Target", target)

		local startFX = ParticleManager:CreateParticle("particles/units/heroes/hero_winter_wyvern/wyvern_winters_curse_ground.vpcf", PATTACH_POINT, target)
		ParticleManager:SetParticleControl(startFX, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(startFX, 2, Vector(radius, radius, radius))
		ParticleManager:ReleaseParticleIndex(startFX)
	end

	function ability_class:_WintersCurse(target)
		-- if target:TriggerSpellAbsorb( self ) then return end
		local caster = self:GetCaster()
		local ability = self
		local radius = GetTalentSpecialValueFor(ability, "radius")
		local duration = GetTalentSpecialValueFor(ability, "duration")

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_winter_wyvern/wyvern_winters_curse_ring_rope.vpcf", PATTACH_POINT, target)
		ParticleManager:SetParticleControl(nfx, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx, 2, Vector(radius, radius, radius))
		ParticleManager:ReleaseParticleIndex(nfx)

		ParticleManager:CreateParticle( "particles/units/heroes/hero_winter_wyvern/wyvern_winters_curse_start.vpcf", PATTACH_POINT_FOLLOW, target )
		target:AddNewModifier( target, ability, "modifier_mjz_winter_wyvern_ice_age_prisoner", {duration = duration} )
		target:AddNewModifier( target, ability, "modifier_mjz_winter_wyvern_ice_age_debuff", {duration = duration} )
    end
	
end

---------------------------------------------------------------------------------------

modifier_mjz_winter_wyvern_ice_age_prisoner = class({})
local modifier_class_prisoner = modifier_mjz_winter_wyvern_ice_age_prisoner

-- function modifier_class_prisoner:IsPassive() return true end
function modifier_class_prisoner:IsDebuff() return true end
function modifier_class_prisoner:IsHidden() return false end
function modifier_class_prisoner:IsPurgable() return false end

function modifier_class_prisoner:CheckState()
	if self:GetParent().bAbsoluteNoCC then return end
	local state = { [MODIFIER_STATE_STUNNED] = true,
					[MODIFIER_STATE_FROZEN] = true,
					--[MODIFIER_STATE_SPECIALLY_DENIABLE] = true,
				}
	return state
end

function modifier_class_prisoner:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_winters_curse_status.vpcf"
end

function modifier_class_prisoner:GetStatusEffectName()
	return "particles/status_fx/status_effect_wyvern_curse_target.vpcf"
end

function modifier_class_prisoner:StatusEffectPriority()
	return 10
end


-----------------------------------------------------------------------------------------

modifier_mjz_winter_wyvern_ice_age_debuff = class({})
local modifier_class_debuff = modifier_mjz_winter_wyvern_ice_age_debuff

function modifier_class_debuff:IsDebuff() return true end
function modifier_class_debuff:IsHidden() return true end
function modifier_class_debuff:IsPurgable() return false end

function modifier_class_debuff:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_winters_curse_buff.vpcf"
end

function modifier_class_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_wyvern_curse_buff.vpcf"
end

function modifier_class_debuff:StatusEffectPriority()
	return 10
end


if IsServer() then	

	function modifier_class_debuff:OnCreated( keys )
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local tick_interval = ability:GetSpecialValueFor('tick_rate')

		self:StartIntervalThink( tick_interval )
	end

	function modifier_class_debuff:OnIntervalThink(keys)
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local tick_interval = ability:GetSpecialValueFor('tick_rate')

		local base_damage = GetTalentSpecialValueFor(ability, 'damage')
		local percent_damage = GetTalentSpecialValueFor(ability, 'percent_damage')
		local damage = base_damage + (percent_damage / 100 * parent:GetMaxHealth())
		damage = damage * tick_interval

		local postDmg = ApplyDamage({
			victim = parent, 
			attacker = caster, 
			damage = damage, 
			damage_type = ability:GetAbilityDamageType()
		})
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, parent, postDmg, caster)
	end
	
end

-----------------------------------------------------------------------------------------

modifier_mjz_winter_wyvern_ice_age_dummy = class({})
local modifier_dummy = modifier_mjz_winter_wyvern_ice_age_dummy

function modifier_dummy:IsHidden() return true end
function modifier_dummy:IsPurgable() return false end

function modifier_dummy:CheckState()
    local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
    return state  
end

-----------------------------------------------------------------------------------------


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
        if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
    end
    return base
end

--[[
    A quick function to create popups.
    Example:
    create_popup({
        target = target,
        value = value,
        color = Vector(255, 20, 147),
        type = "spell_custom"
	}) 
	伤害类型的颜色：
		物理：Vector(174, 47, 40)
		魔法：Vector(91, 147, 209)
		纯粹：Vector(216, 174, 83)
	spell_custom: 
		block | crit | damage | evade | gold | heal | mana_add | mana_loss | miss | poison | spell | xp
	Color:	
		red 	={255,0,0},
		orange	={255,127,0},
		yellow	={255,255,0},
		green 	={0,255,0},
		blue 	={0,0,255},
		indigo 	={0,255,255},
		purple 	={255,0,255},
]]
function create_popup(data)
    local target = data.target
    local value = math.floor(data.value)

    local type = data.type or "miss"
    local color = data.color or Vector(255, 255, 255)
    local duration = data.duration or 1.0

    local size = string.len(value)

    local pre = data.pre or nil
    if pre ~= nil then
        size = size + 1
    end

    local pos = data.pos or nil
    if pos ~= nil then
        size = size + 1
    end

    local particle_path = "particles/msg_fx/msg_" .. type .. ".vpcf"
    local particle = ParticleManager:CreateParticle(particle_path, PATTACH_OVERHEAD_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 1, Vector(pre, value, pos))
    ParticleManager:SetParticleControl(particle, 2, Vector(duration, size, 0))
    ParticleManager:SetParticleControl(particle, 3, color)
	ParticleManager:ReleaseParticleIndex(particle)
end

function create_popup_by_damage_type(data, ability)
    local damage_type = ability:GetAbilityDamageType()
    if damage_type == DAMAGE_TYPE_PHYSICAL then
        data.color = Vector(174, 47, 40)
    elseif damage_type == DAMAGE_TYPE_MAGICAL then
        data.color = Vector(91, 147, 209)
    elseif damage_type == DAMAGE_TYPE_PURE then
        data.color = Vector(216, 174, 83)
    else
        data.color = Vector(255, 255, 255)
    end
    create_popup(data)
end


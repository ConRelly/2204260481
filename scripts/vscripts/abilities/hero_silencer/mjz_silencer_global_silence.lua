LinkLuaModifier("modifier_mjz_silencer_global_silence_debuff", "abilities/hero_silencer/mjz_silencer_global_silence.lua", LUA_MODIFIER_MOTION_NONE)

mjz_silencer_global_silence = class({})
local ability_class = mjz_silencer_global_silence

function ability_class:IsRefreshable() return true end
function ability_class:IsStealable() return true end	-- 是否可以被法术偷取。

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('radius')
end


if IsServer() then
	function ability_class:OnSpellStart()
		local ability = self
		local caster = self:GetCaster()

		local radius = self:GetSpecialValueFor('radius')
		local duration = GetTalentSpecialValueFor(ability, 'duration')

		local modifier_debuff_name = "modifier_mjz_silencer_global_silence_debuff"

		EmitSoundOn("Hero_Silencer.GlobalSilence.Cast", caster)

		local p_name = "particles/units/heroes/hero_silencer/silencer_global_silence.vpcf"
		local particle = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl( particle, 0, caster:GetAbsOrigin() )
		ParticleManager:ReleaseParticleIndex(particle)

		local enemy_list = FindTargetEnemy(caster, caster:GetAbsOrigin(), radius)
		for _,enemy in pairs(enemy_list) do
            enemy:AddNewModifier(caster, ability, modifier_debuff_name, { duration = duration })
			-- EmitSoundOn("Hero_Silencer.GlobalSilence.Effect", enemy)            
        end
        
		EmitSoundOn("Hero_Silencer.GlobalSilence.Effect", caster)
	end

end

-----------------------------------------------------------------------------------------


modifier_mjz_silencer_global_silence_debuff = class({})
local modifier_debuff = modifier_mjz_silencer_global_silence_debuff

function modifier_debuff:IsHidden() return false end
function modifier_debuff:IsPurgable() return true end
function modifier_debuff:IsDebuff() return true end

function modifier_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_silence.vpcf"
end
function modifier_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}
	return state
end
if IsServer() then
    function modifier_debuff:DeclareFunctions()
        return {
            MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        }
    end

    function modifier_debuff:GetModifierMoveSpeedBonus_Percentage()
        return self:GetAbility():GetSpecialValueFor('slow_movement_speed_pct')
    end

    function modifier_debuff:GetModifierAttackSpeedBonus_Constant()
        return self:GetAbility():GetSpecialValueFor('slow_attack_speed')
    end
end

-----------------------------------------------------------------------------------------


-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(caster, point, radius)
	local iTeamNumber = caster:GetTeamNumber()
	local vPosition = point 				-- 搜索中心点
	local hCacheUnit = nil                  -- 通常值
	local flRadius = radius                 -- 搜索范围
	local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
	-- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
	local iFlagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES     -- 无视魔法免疫
	local iOrder = FIND_CLOSEST                         -- 寻找最近的
	local bCanGrowCache = false             -- 通常值
	return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
		flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
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
LinkLuaModifier("modifier_mjz_sandking_epicenter_slow","modifiers/hero_sand_king/modifier_mjz_sandking_epicenter.lua", LUA_MODIFIER_MOTION_NONE)


modifier_mjz_sandking_epicenter = class({})
local modifier_class = modifier_mjz_sandking_epicenter

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
    function modifier_class:DeclareFunctions()
		return {
			-- MODIFIER_EVENT_ON_DEATH,     -- 如果持续施法成功，伤害震击就不再被打断，即使是沙王死亡也不会
		}
	end

	function modifier_class:OnDeath()
        if self:IsNull() then return end
		self:Destroy()
    end
    
    function modifier_class:OnCreated(table)
        local ability = self:GetAbility()
        local parent = self:GetParent()
        local epicenter_pulses = GetTalentSpecialValueFor(ability, 'epicenter_pulses')
        -- local pulses_interval = ability:GetSpecialValueFor('epicenter_pulses_interval')
        self.current_pulses = 0
        -- 该技能在初始延迟后释放所有震击需要3秒
        local flInterval = (6 * 0.5 + 0.25) / epicenter_pulses

        EmitSoundOn("Ability.SandKing_Epicenter", self:GetParent())
        self:OnIntervalThink()
        self:StartIntervalThink(flInterval)
    end

    function modifier_class:OnRemoved()
		StopSoundOn("Ability.SandKing_Epicenter", self:GetParent())
	end
	
	function modifier_class:OnDestroy()
		StopSoundOn("Ability.SandKing_Epicenter", self:GetParent())
	end

    function modifier_class:OnIntervalThink()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        local radius_min = ability:GetSpecialValueFor('epicenter_radius_min')
        local radius_max = ability:GetSpecialValueFor('epicenter_radius_max')
        local radius_increase = ability:GetSpecialValueFor('epicenter_radius_increase')
        local epicenter_pulses = GetTalentSpecialValueFor(ability, 'epicenter_pulses')
        local epicenter_damage = ability:GetSpecialValueFor('epicenter_damage')
        local str_damage_pct = GetTalentSpecialValueFor(ability, 'str_damage_pct')
        local slow_duration = ability:GetSpecialValueFor('epicenter_slow_duration')

		if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
			epicenter_damage = epicenter_damage + ability:GetSpecialValueFor("epicenter_shard_dmg_inc")
			str_damage_pct = str_damage_pct + ability:GetSpecialValueFor("epicenter_shard_str_dmg_inc")
		end

        local damage = epicenter_damage + parent:GetStrength() * (str_damage_pct / 100.0)

        self.current_pulses = self.current_pulses + 1

        local radius = radius_min + (self.current_pulses * radius_increase)
        if radius > radius_max then radius = radius_max end
        
        local enemy_list = self:_FindEnemyList(radius)
        for _,enemy in pairs(enemy_list) do
            local damageTable = {
                victim = enemy,
                attacker = parent,
                damage = damage,
                damage_type = ability:GetAbilityDamageType(),
                ability = ability,
            }
			ApplyDamage(damageTable)
            
            enemy:AddNewModifier(parent, ability, 'modifier_mjz_sandking_epicenter_slow', {duration = slow_duration})
        end

        local p_name = "particles/units/heroes/hero_sandking/sandking_epicenter.vpcf"
        local particle = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN, parent)
	    ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_origin", parent:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(particle, 1, Vector(radius, radius, radius))
        ParticleManager:ReleaseParticleIndex(particle)

        if self.current_pulses >= epicenter_pulses then
            self:StartIntervalThink(-1)
            if self:IsNull() then return end
            self:Destroy()
        end
    end

    -- 搜索目标位置所有的敌人单位
    function modifier_class:_FindEnemyList(radius)
        local caster = self:GetParent()
        local point = caster:GetAbsOrigin()
        local iTeamNumber = caster:GetTeamNumber()
        local vPosition = point 				-- 搜索中心点
        local hCacheUnit = nil                  -- 通常值
        local flRadius = radius                 -- 搜索范围
        local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
        -- 目标单位类型
        local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
        local iFlagFilter = DOTA_UNIT_TARGET_FLAG_NONE
        local iOrder = FIND_CLOSEST                         -- 寻找最近的
        local bCanGrowCache = false             -- 通常值
        return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
            flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
    end
end




-----------------------------------------------------------------------------


modifier_mjz_sandking_epicenter_slow = class({})
local modifier_slow = modifier_mjz_sandking_epicenter_slow

function modifier_slow:IsHidden() return false end
function modifier_slow:IsPurgable() return true end


function modifier_slow:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_slow:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_slow:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor('epicenter_slow')
end

function modifier_slow:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor('epicenter_slow_as')
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


local THIS_LUA = "abilities/hero_templar_assassin/mjz_templar_assassin_trap_teleport.lua"
LinkLuaModifier("modifier_mjz_templar_assassin_trap_teleport_debuff", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_templar_assassin_trap_teleport_psionic_trap", THIS_LUA, LUA_MODIFIER_MOTION_NONE)

-- local MODIFIER_DUMMY_THINKER = 'modifier_dummy_thinker_v1' 
-- LinkLuaModifier(MODIFIER_DUMMY_THINKER, 'modifiers/modifier_dummy_thinker_v1.lua', LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------------

function mjz_templar_assassin_self_trap( keys )
    if IsServer() then
        local caster = keys.caster
        local ability = keys.ability
        local hero = caster:GetOwner()
        local tAbility = hero:FindAbilityByName("mjz_templar_assassin_trap_teleport")
        if tAbility then
            local trap = caster
            tAbility:ApplyDestroyEffect(hero, trap)
            tAbility:ApplySlowAndDamage(trap:GetAbsOrigin())
            trap:ForceKill(true)
        end

    end
end

--------------------------------------------------------------------------------------


mjz_templar_assassin_trap_teleport = class({})
local ability_class = mjz_templar_assassin_trap_teleport

function ability_class:OnUpgrade()
    if IsServer() then
        if self:GetLevel() == 1 then
            self:ToggleAutoCast()
        end
    end
end

function ability_class:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self
		local pos = self:GetCursorPosition()
		
		
		-- EmitSoundOn("Hero_TemplarAssassin.Trap.Cast", caster)
        -- EmitSoundOn("Hero_TemplarAssassin.Trap", caster)
        

        if ability:GetAutoCastState() then
            self:_Teleport(pos)

            self:CreateTrap(pos)
        else
            self:CreateTrap(pos)
        end

        
	end
end


if IsServer() then
    function ability_class:CalcDamage(point, multi)
        local caster = self:GetCaster()
        local ability = self
        local trap_radius = ability:GetSpecialValueFor("trap_radius")
        local trap_bonus_damage = GetTalentSpecialValueFor(ability, "trap_bonus_damage")
        local trap_count = 0

        if multi then
            local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, trap_radius, 
                DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
            for i,unit in pairs(units) do
                if unit.GetUnitName and unit:GetUnitName() == "npc_dota_templar_assassin_psionic_trap" then
                    trap_count = trap_count + 1
                    unit:ForceKill(true)
                end
            end
        end

        -- print("trap_count: " .. trap_count)
        return trap_bonus_damage + trap_bonus_damage * trap_count
    end

	function ability_class:_Teleport(point)
		local caster = self:GetCaster()
		local ability = self
		local duration = 0.25

		local sound_name = "Hero_Zuus.GodsWrath.Target"
		-- local thinker = CreateModifierThinker(caster, ability, 'MODIFIER_DUMMY_THINKER', {duration = 1.0}, pos, caster:GetTeamNumber(), false)
		local dummy_name = 'npc_dota_invisible_vision_source' -- npc_dummy_unit
		-- local dummy = CreateUnitByName(dummy_name, point, false, caster, caster, caster:GetTeam())
		-- dummy:AddNewModifier(caster, nil, "modifier_phased", {})
		-- dummy:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
		-- dummy:AddNewModifier(caster, ability, "modifier_item_gem_of_true_sight", {duration = duration})
		-- dummy:AddNewModifier(caster, ability, MODIFIER_DUMMY_THINKER, {})

		-- local unit = dummy
		-- FindClearSpaceForUnit(unit, point, true)

		-- EmitSoundOn(sound_name, unit)
        -- ApplyEffect2(caster, unit)
        

		FindClearSpaceForUnit(caster, point, true)

        self:ApplyDestroyEffect(caster, caster)
        self:ApplySlowAndDamage(point, true)
	end

	function ability_class:ApplyDestroyEffect(caster, target, notEmitSound)
		local p_name = "particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf"

        local emitSound = not notEmitSound
        if emitSound then
            EmitSoundOn("Hero_TemplarAssassin.Trap.Trigger", target)
            EmitSoundOn("Hero_TemplarAssassin.Trap.Explode", target)
        end

        local particle = ParticleManager:CreateParticle(p_name, PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 2, target:GetAbsOrigin())
        ParticleManager:DestroyParticle(particle, false)
		ParticleManager:ReleaseParticleIndex(particle)
	end

    function ability_class:ApplySlowAndDamage(point, multi)
        local caster = self:GetCaster()
        local ability = self
        local trap_radius = ability:GetSpecialValueFor("trap_radius")
        local trap_duration = ability:GetSpecialValueFor("trap_duration")
        local debuffName = "modifier_mjz_templar_assassin_trap_teleport_debuff"

        local damage = self:CalcDamage(point, multi)

        local damageTable = {
			victim = nil,
			attacker = caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			ability = ability,
		}

        -- Units in the slow radius
        local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, trap_radius, 
            ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)

        -- Applies the debuff to the targets
        for i,unit in ipairs(units) do
            unit:AddNewModifier(caster, ability, debuffName, {duration = trap_duration})

            damageTable.victim = unit
			ApplyDamage(damageTable)
        end
    end
    
    function ability_class:CreateTrap( point )
        local caster = self:GetCaster()
        local ability = self
        local pName = "particles/units/heroes/hero_templar_assassin/templar_assassin_trap_portrait.vpcf"

        local max_traps = GetTalentSpecialValueFor(ability, "max_traps")
        if IsInToolsMode() and IsInDev then
            max_traps = 3
        end
	
        -- Creates the list of traps and total_traps global variables
        if ability.total_traps == nil then
            ability.total_traps = 0
            ability.traps = {}
        end

        if ability.total_traps == max_traps then
            local trap = ability.traps[1]
            self:ApplyDestroyEffect(caster, trap, true)
            self:ApplySlowAndDamage(trap:GetAbsOrigin())
            trap:ForceKill(true)
        end
        
        -- Ensures there are fewer than the maximum traps
        if ability.total_traps < max_traps then
            -- Creates a new trap
            local trap = CreateUnitByName("npc_dota_templar_assassin_psionic_trap", point, true, caster, nil, caster:GetTeam())
            
            -- Places the trap in the list and increments the total
            -- ability.total_traps = ability.total_traps + 1
            -- ability.traps[ability.total_traps-1] = trap
            table.insert( ability.traps, trap )
            ability.total_traps = #ability.traps

            -- Applies the modifier to the trap
            trap:AddNewModifier(caster, ability, "modifier_mjz_templar_assassin_trap_teleport_psionic_trap", {})
            

            trap:SetOwner(caster)
            trap:SetControllableByPlayer(caster:GetPlayerID(), true)
            
            -- Removes the default trap ability and adds both new abilities
            trap:RemoveAbility("templar_assassin_self_trap")
            
            -- caster:AddAbility("trap_datadriven")
            -- caster:FindAbilityByName("trap_datadriven"):UpgradeAbility(true)
            
            trap:AddAbility("mjz_templar_assassin_self_trap")
            trap:FindAbilityByName("mjz_templar_assassin_self_trap"):UpgradeAbility(true)
        
            -- Plays the sounds
            EmitSoundOn("Hero_TemplarAssassin.Trap.Cast", caster)
            EmitSoundOn("Hero_TemplarAssassin.Trap", trap)

            
            -- Renders the trap particle on the target position (it is not a model particle, so cannot be attached to the unit)
            trap.particle = ParticleManager:CreateParticle(pName, PATTACH_WORLDORIGIN, caster)
            ParticleManager:SetParticleControl(trap.particle, 0, trap:GetAbsOrigin())
            ParticleManager:SetParticleControl(trap.particle, 1, trap:GetAbsOrigin())
            ParticleManager:SetParticleControl(trap.particle, 2, trap:GetAbsOrigin())

        end
        
    end

    function ability_class:RemoveTrap( trap )
        if IsValidEntity(trap) then
            local ability = self
            if ability.traps then
                local pos = nil
                for i,t in pairs(ability.traps) do
                    if t == trap then
                        pos = i
                        break
                    end
                end
                if pos ~= nil then
                    table.remove( ability.traps, pos )
                    ability.total_traps = #ability.traps

                    if trap.particle then
                        ParticleManager:DestroyParticle(trap.particle, true)
                    end
                end
            end
        end
    end

end

-----------------------------------------------------------------------------------------

modifier_mjz_templar_assassin_trap_teleport_debuff = class({})

function modifier_mjz_templar_assassin_trap_teleport_debuff:IsHidden() return false end
function modifier_mjz_templar_assassin_trap_teleport_debuff:IsPurgable() return true end

function modifier_mjz_templar_assassin_trap_teleport_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,		-- 当拥有modifier的单位攻击到某个目标时
    }
end

function modifier_mjz_templar_assassin_trap_teleport_debuff:GetModifierMoveSpeedBonus_Percentage( ... )
    return self:GetAbility():GetSpecialValueFor("movement_speed")
end

-----------------------------------------------------------------------------------------

modifier_mjz_templar_assassin_trap_teleport_psionic_trap = class({})

function modifier_mjz_templar_assassin_trap_teleport_psionic_trap:IsHidden() return true end
function modifier_mjz_templar_assassin_trap_teleport_psionic_trap:IsPurgable() return false end

function modifier_mjz_templar_assassin_trap_teleport_psionic_trap:CheckState() 
    return {
        [MODIFIER_STATE_LOW_ATTACK_PRIORITY]  	= true,
        [MODIFIER_STATE_NO_UNIT_COLLISION]      = true,
    } 
end

if IsServer() then
    function modifier_mjz_templar_assassin_trap_teleport_psionic_trap:OnDestroy()
        local ability = self:GetAbility()
        local trap = self:GetParent()
        ability:RemoveTrap(trap)
    end    
end


-----------------------------------------------------------------------------------------
-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(caster, point, radius)
	local iTeamNumber = caster:GetTeamNumber()
	local vPosition = point					-- 搜索中心点
	local hCacheUnit = nil                  -- 通常值
	local flRadius = radius                 -- 搜索范围
	local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
	-- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
	local iFlagFilter = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE -- 忽视建筑物
	local iOrder = FIND_CLOSEST                         -- 寻找最近的
	iOrder = FIND_ANY_ORDER								-- 随机
	local bCanGrowCache = false             -- 通常值
	return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
		flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
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


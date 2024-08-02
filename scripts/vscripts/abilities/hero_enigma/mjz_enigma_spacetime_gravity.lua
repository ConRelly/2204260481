LinkLuaModifier("modifier_mjz_enigma_spacetime_gravity", "abilities/hero_enigma/mjz_enigma_spacetime_gravity.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_enigma_spacetime_gravity_buff", "abilities/hero_enigma/mjz_enigma_spacetime_gravity.lua", LUA_MODIFIER_MOTION_NONE)

local MODIFIER_DUMMY_THINKER = 'modifier_dummy_thinker_v1' 
LinkLuaModifier(MODIFIER_DUMMY_THINKER, 'modifiers/modifier_dummy_thinker_v1.lua', LUA_MODIFIER_MOTION_NONE)


mjz_enigma_spacetime_gravity = class({})
local ability_class = mjz_enigma_spacetime_gravity


function ability_class:GetAOERadius()
	return self:GetSpecialValueFor("radius_per_level") * self:GetCaster():GetLevel()
	-- return self:GetSpecialValueFor('radius')
end

function ability_class:OnChannelFinish()
	if IsServer() then
		self:SpellFinish()
	end
end

function ability_class:OnChannelInterrupted()
	if IsServer() then
		self:SpellFinish()
	end
end


function ability_class:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self
		local point  = self:GetCursorPosition()
		local duration = ability:GetSpecialValueFor("duration")
        
		-- local sight_radius = ability:GetSpecialValueFor("sight_radius")
		-- local sight_duration = ability:GetSpecialValueFor("sight_duration")
		
		EmitSoundOn("Hero_Enigma.Black_Hole", caster)

		-- EmitSoundOn("Hero_Zuus.GodsWrath", caster)
		-- local p_name = "particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start_bolt_parent.vpcf"
		-- local p_index = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, caster)
		-- ParticleManager:SetParticleControl(p_index, 1, caster:GetAbsOrigin())
		-- ParticleManager:ReleaseParticleIndex(p_index)

		-- -- AddFOWViewer(caster:GetTeam(), caster:GetAbsOrigin(), sight_radius, sight_duration, false)

		-- self:_ApplyDamage()
		local thinker = self:_Thinker(point, duration, "modifier_mjz_enigma_spacetime_gravity")
		self.point_entity = thinker
	end
end

if IsServer() then
	function ability_class:SpellFinish()
		local ability = self
		local caster = self:GetCaster()
		StopSoundOn("Hero_Enigma.Black_Hole", caster)

		if ability.point_entity and ability.point_entity:IsNull() == false then
			ability.point_entity:RemoveModifierByName("modifier_mjz_enigma_spacetime_gravity")
			ability.point_entity:ForceKill(false)
		end
	end

	function ability_class:_Thinker(pos, duration, mName)
		local caster = self:GetCaster()
		local ability = self
		-- local duration = 0.25

		-- local thinker = CreateModifierThinker(caster, ability, 'MODIFIER_DUMMY_THINKER', {duration = 1.0}, pos, caster:GetTeamNumber(), false)
		local dummy_name = 'npc_dota_invisible_vision_source' -- npc_dummy_unit
		local dummy = CreateUnitByName(dummy_name, pos, false, caster, caster, caster:GetTeam())
		dummy:AddNewModifier(caster, nil, "modifier_phased", {})
		dummy:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
		dummy:AddNewModifier(caster, ability, "modifier_item_gem_of_true_sight", {duration = duration})
		dummy:AddNewModifier(caster, ability, MODIFIER_DUMMY_THINKER, {})
		if mName then
			dummy:AddNewModifier(caster, ability, mName, {duration = duration})
		end

		FindClearSpaceForUnit(dummy, pos, true)

		return dummy
	end


	function ability_class:_ApplyDamage(target)
		local caster = self:GetCaster()
		local ability = self
		local point  = self:GetCursorPosition()      
		local radius = self:GetAOERadius()
		local base_damage = ability:GetSpecialValueFor("base_damage") * caster:GetLevel()
		local intelligence_damage = GetTalentSpecialValueFor(ability, "intelligence_damage")
		local damage = base_damage + caster:GetIntellect(false) * (intelligence_damage * caster:GetLevel())
        --print(damage .. " damage")
		local sound_name = "Hero_Zuus.GodsWrath.Target"
		local units = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			point,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)		
		--local units = FindUnitsInRadius(caster, caster:GetAbsOrigin(), radius)
		for _,unit in pairs(units) do
			ApplyEffect2(caster, unit)

			EmitSoundOn(sound_name, unit)

			ApplyDamage({
				attacker = caster,
				victim = unit,
				ability = ability,
				damage_type = ability:GetAbilityDamageType(),
				damage = damage
			})	
		end
	end

end
-----------------------------------------------------------------------------------------

modifier_mjz_enigma_spacetime_gravity = class({})
local modifier_class = modifier_mjz_enigma_spacetime_gravity

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
	function modifier_class:OnCreated()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		self.particles = {}
		if ability == nil then return end
		local base_damage = ability:GetSpecialValueFor("damage_per_level") * caster:GetLevel()
		local intelligence_damage = GetTalentSpecialValueFor(ability, "intelligence_damage")
		self.damage = math.ceil((base_damage + caster:GetIntellect(false) * (intelligence_damage * caster:GetLevel())) * 0.35)
		self.radius = ability:GetSpecialValueFor("radius_per_level") * caster:GetLevel()
        --print(self.damage .. " created damage")
		local visionRange = ability:GetAOERadius()
		parent:SetDayTimeVisionRange(visionRange)
		parent:SetNightTimeVisionRange(visionRange)
		self.last_use = GameRules:GetGameTime()
		self.ch_duration = ability:GetSpecialValueFor("duration")
		self:ApplyEffect()
		self:StartIntervalThink(0.35)
	end

	function modifier_class:OnIntervalThink()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if ability == nil then return end
        local current_time = GameRules:GetGameTime()
		if self.ch_duration == nil then
        	self.ch_duration = ability:GetSpecialValueFor("duration")  
		end 
        if self.last_use == nil then
            print("not self last use")
            self.last_use = GameRules:GetGameTime()
        end    
        if self.last_use and ability and (current_time - self.last_use > self.ch_duration) then
			ability:SpellFinish()
			if self then
            	self:Destroy()
			end	
            return
        end 
		if not caster:IsChanneling() then
			ability:SpellFinish()
		end
		if caster:IsChanneling() then	
			local caster = self:GetAbility():GetCaster()
			local target = self:GetParent()
			local target_location = target:GetAbsOrigin()
			local ability = self:GetAbility()

			-- Takes note of the point entity, so we know what to remove the thinker from when the channel ends
			--ability.point_entity = target
			local damage = self.damage
            --print(damage .. " on interval dmg")
			-- Ability variables
			local speed = 85
			local radius = self.radius

			-- Targeting variables
			local target_teams = DOTA_UNIT_TARGET_TEAM_ENEMY
			local target_types = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
			local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

			-- Units to be caught in the black hole
			local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, radius, target_teams, target_types, target_flags, 0, false)

			-- Calculate the position of each found unit in relation to the center
			for i,unit in ipairs(units) do
				local unit_location = unit:GetAbsOrigin()
				local vector_distance = target_location - unit_location
				local distance = (vector_distance):Length2D()
				local direction = (vector_distance):Normalized()

       

				-- If the target is greater than 40 units from the center, we move them 40 units towards it, otherwise we move them directly to the center
				if distance >= 100 then
					unit:SetAbsOrigin(unit_location + direction * speed)
				end
				ApplyDamage({victim = unit, attacker = self:GetAbility():GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_PURE})
			end
		end		
	end

	function modifier_class:OnDestroy()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		for _,p in pairs(self.particles) do
			ParticleManager:DestroyParticle(p, true)
		end
		StopSoundOn("Hero_Enigma.Black_Hole.Stop", parent)
	end

	function modifier_class:ApplyEffect()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local point = parent:GetAbsOrigin()
		local radius = ability:GetAOERadius()


		local particleName = "particles/units/heroes/hero_enigma/enigma_blackhole.vpcf"
		local particleName_ti5 = "particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5.vpcf"
		local particle = ParticleManager:CreateParticle(particleName_ti5, PATTACH_WORLDORIGIN, parent)
		--控制点0，1是特效位置
		ParticleManager:SetParticleControl(particle, 0, point)
		ParticleManager:SetParticleControl(particle, 1, point)

		local p_name = "particles/units/heroes/hero_enigma/enigma_midnight_pulse.vpcf"
		local p_pulse = ParticleManager:CreateParticle(p_name, PATTACH_WORLDORIGIN, parent)
		ParticleManager:SetParticleControl(p_pulse, 0, point)
		ParticleManager:SetParticleControl(p_pulse, 1, Vector(radius, 0, 0)) -- sets size of particle


		table.insert( self.particles, particle )
		table.insert( self.particles, p_pulse )
	end
end

------------------------------------------------

function modifier_class:IsAura() return true end

function modifier_class:GetAuraRadius()
	local caster = self:GetAbility():GetCaster()
	local ability = self:GetAbility()
	local radius = ability:GetSpecialValueFor("radius_per_level") * caster:GetLevel()
    -- return self:GetAbility():GetSpecialValueFor("radius")
    return radius --self:GetAbility():GetAOERadius()
end

function modifier_class:GetModifierAura()
    return "modifier_mjz_enigma_spacetime_gravity_buff"
end

function modifier_class:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY -- DOTA_UNIT_TARGET_TEAM_FRIENDLY -- DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_class:GetAuraEntityReject(target)
    return self:GetParent():IsIllusion()
end

function modifier_class:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL -- DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_class:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE  -- DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE -- DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_class:GetAuraDuration()
    return 0.25
end

------------------------------------------------

-----------------------------------------------------------------------------------------

modifier_mjz_enigma_spacetime_gravity_buff = class({})

function modifier_mjz_enigma_spacetime_gravity_buff:IsHidden() return false end
function modifier_mjz_enigma_spacetime_gravity_buff:IsPurgable() return false end

 function modifier_mjz_enigma_spacetime_gravity_buff:CheckState()
 	local state = {
-- 		[MODIFIER_STATE_INVISIBLE] = false,
		[MODIFIER_STATE_STUNNED ]            = false,
		[MODIFIER_STATE_SILENCED ]           = false,   
 	}				   
 	return state	
 end

function modifier_mjz_enigma_spacetime_gravity_buff:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end


function modifier_mjz_enigma_spacetime_gravity_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_mjz_enigma_spacetime_gravity_buff:GetModifierIncomingDamage_Percentage()
	return -75
end	

--[[function modifier_mjz_enigma_spacetime_gravity_buff:OnTakeDamage( params )
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local spell = self:GetAbility()
	local Attacker = params.attacker
	local Target = params.unit
	local Ability = params.inflictor
	local flDamage = params.damage
	local attacker = params.attacker
	local target = params.attacker
	local damage = params.damage

	if params.unit ~= self:GetParent() or Target == nil then
		-- print("OnTakeDamage: params.unit ~= self:GetParent()")
		return 0
	end
	if params.attacker == params.unit then return end
	-- if params.attacker:IsMagicImmune() then return end

	-- local unit = parent
	-- if unit:GetHealth() < self. then
	-- 	-- body
	-- end
	-- unit:SetHealth(newHealth)
end]]



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


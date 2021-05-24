

local THIS_LUA = "abilities/hero_axe/mjz_axe_berserkers_call.lua"

LinkLuaModifier("modifier_mjz_axe_berserkers_call_caster",THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_axe_berserkers_call_armor_bonus", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_axe_berserkers_call_enemy", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_axe_berserkers_call_radius_talent", THIS_LUA, LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------------------------------------

mjz_axe_berserkers_call = class({})
local ability_class = mjz_axe_berserkers_call

function ability_class:GetAOERadius()
	local caster = self:GetCaster()
	local abiltiy = self
	local modifer_talent = 'modifier_mjz_axe_berserkers_call_radius_talent'
	local talent_value = 100
	local radius = abiltiy:GetSpecialValueFor('radius')
	local has_talent = caster:HasModifier(modifer_talent)
	if has_talent then
		radius = radius + talent_value
	end
	return radius
end


if IsServer() then
	function ability_class:OnSpellStart()
		local caster = self:GetCaster()
		local ability = self
		local duration = ability:GetSpecialValueFor('duration')

		local modifier_caster_name = 'modifier_mjz_axe_berserkers_call_caster'
		caster:AddNewModifier(caster, ability, modifier_caster_name, {duration = duration})

		self:AttachEffect()
		self:FindEnemy()

		EmitSoundOn("Hero_Axe.Berserkers_Call", caster)

		self:CheckRadius()
	end

	function ability_class:FindEnemy( )
		local caster = self:GetCaster()
		local ability = self
		local modifier_name = "modifier_mjz_axe_berserkers_call_enemy"
	
		local duration = ability:GetSpecialValueFor('duration')
		local radius = GetTalentSpecialValueFor(ability, 'radius')
	
		local enemy_list = FindTargetEnemy(caster, caster:GetAbsOrigin(), radius)
	
		for _,enemy in pairs(enemy_list) do
			enemy:AddNewModifier(caster, ability, modifier_name, {duration = duration})
		end
	end
	
	function ability_class:AttachEffect( )
		local caster = self:GetCaster()
		local ability = self
	
		local radius = GetTalentSpecialValueFor(ability, 'radius')
	
		-- "particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf"
		local EffectName = "particles/econ/items/axe/axe_helm_shoutmask/axe_beserkers_call_owner_shoutmask.vpcf"
		local p = ParticleManager:CreateParticle(EffectName, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(p, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(p, 2, Vector(radius, 1, 1))
		ParticleManager:ReleaseParticleIndex(p)
	end

	function ability_class:CheckRadius()
		local caster = self:GetCaster()
		local ability = self
		local modifer_talent = 'modifier_mjz_axe_berserkers_call_radius_talent'

		if HasTalentBy(ability, 'radius') then
			if not caster:HasModifier(modifer_talent)  then
				caster:AddNewModifier(caster, abiltiy, modifer_talent, nil)
			end
		else
			if caster:HasModifier(modifer_talent) then
				caster:RemoveModifierByName(modifer_talent)
			end
		end
	end
end


-----------------------------------------------------------------------------------------

modifier_mjz_axe_berserkers_call_caster = class({})
local modifier_caster = modifier_mjz_axe_berserkers_call_caster

function modifier_caster:IsHidden() return false end
function modifier_caster:IsPurgable() return false end
function modifier_caster:IsBuff() return true end


if IsServer() then
	function modifier_caster:OnCreated(table)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		self.modifier_bonus_name = 'modifier_mjz_axe_berserkers_call_armor_bonus'

		caster:AddNewModifier(caster, ability, self.modifier_bonus_name, {})
	end

	function modifier_caster:OnDestroy()
		local caster = self:GetCaster()
		if caster:HasModifier(self.modifier_bonus_name) then
			caster:RemoveModifierByName(self.modifier_bonus_name)
		end		
	end

	function modifier_caster:OnRemoved()
		local caster = self:GetCaster()
		if caster:HasModifier(self.modifier_bonus_name) then
			caster:RemoveModifierByName(self.modifier_bonus_name)
		end		
	end
end

--------------------------------------------------------------------------------------------

modifier_mjz_axe_berserkers_call_armor_bonus = class({})
local modifier_bonus = modifier_mjz_axe_berserkers_call_armor_bonus

function modifier_bonus:IsHidden() return true end
function modifier_bonus:IsPurgable() return false end
function modifier_bonus:IsBuff() return true end

function modifier_bonus:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS		
    }
    return funcs
end

function modifier_bonus:GetModifierPhysicalArmorBonus( params )
	return self:GetStackCount()
end

if IsServer() then
	function modifier_bonus:OnCreated( kv )
		local unit = self:GetParent()
		local ability = self:GetAbility()
	
		local bonus_armor_base = ability:GetSpecialValueFor( "bonus_armor")
		local bonus_armor_per = ability:GetSpecialValueFor( "bonus_armor_per")
	
		local current_armor = unit:GetPhysicalArmorValue(false)
		
		local bonus_armor = bonus_armor_base + current_armor * (bonus_armor_per / 100.0)
		self:SetStackCount(bonus_armor)
	end
end

--------------------------------------------------------------------------------------------

modifier_mjz_axe_berserkers_call_enemy = class({})
local modifier_debuff = modifier_mjz_axe_berserkers_call_enemy

function modifier_debuff:IsHidden() return false end
function modifier_debuff:IsPurgable() return false end
function modifier_debuff:IsDebuff() return true end

-- Status Effects
function modifier_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end

-- Graphics & Animations
function modifier_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end
function modifier_debuff:StatusEffectPriority(  )
	return 10
end

if IsServer() then
	function modifier_debuff:OnCreated( kv )
		self:GetParent():SetForceAttackTarget( self:GetCaster() ) 
		self:GetParent():MoveToTargetToAttack( self:GetCaster() ) 
	end

	function modifier_debuff:OnRemoved()
		self:GetParent():SetForceAttackTarget( nil )
		self:GetParent():Stop()
	end

	function modifier_debuff:OnDestroy()
		self:GetParent():SetForceAttackTarget( nil )
		self:GetParent():Stop()
	end

	-- Forces the target to attack the caster 
	function BerserkersCall(  )
		local caster = self:GetCaster()
		local target = self:GetParent()

		-- Clear the force attack target
		target:SetForceAttackTarget(nil)

		-- Give the attack order if the caster is alive
		-- otherwise forces the target to sit and do nothing
		if caster:IsAlive() then
			local order = 
			{
				UnitIndex = target:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = caster:entindex()
			}

			ExecuteOrderFromTable(order)
		else
			target:Stop()
		end

		-- Set the force attack target to be the caster
		target:SetForceAttackTarget(caster)
	end

end

-----------------------------------------------------------------------------

modifier_mjz_axe_berserkers_call_radius_talent = class({})
function modifier_mjz_axe_berserkers_call_radius_talent:IsHidden() return true end
function modifier_mjz_axe_berserkers_call_radius_talent:IsPurgable() return false end


-----------------------------------------------------------------------------

-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(unit, point, radius)
    local iTeamNumber = unit:GetTeamNumber()
    local vPosition = point   				-- 搜索中心点
    local hCacheUnit = nil                  -- 通常值
    local flRadius = radius                 -- 搜索范围
    local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
    -- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP           
	-- 支持魔法免疫
    local iFlagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE   
    local iOrder = FIND_CLOSEST                         -- 寻找最近的
    local bCanGrowCache = false             -- 通常值
    return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
        flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
end


-- 是否学习指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
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

-- 获得天赋技能的数据值
function FindTalentValue(unit, talentName)
    if unit:HasAbility(talentName) then
        return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return nil
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






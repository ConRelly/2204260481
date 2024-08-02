LinkLuaModifier("modifier_mjz_gyrocopter_rocket_barrage", "abilities/hero_gyrocopter/mjz_gyrocopter_rocket_barrage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_gyrocopter_rocket_barrage_mana", "abilities/hero_gyrocopter/mjz_gyrocopter_rocket_barrage.lua", LUA_MODIFIER_MOTION_NONE)

mjz_gyrocopter_rocket_barrage = class({})
local ability_class = mjz_gyrocopter_rocket_barrage


function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('radius')
end

function ability_class:GetAbilityTextureName()
    return "mjz_gyrocopter_rocket_barrage"
end

-- function ability_class:GetIntrinsicModifierName()
-- 	return "modifier_mjz_gyrocopter_rocket_barrage"
-- end

function ability_class:OnToggle()
	if IsServer() then
        local caster = self:GetCaster()
		local ability = self
		local modifier_name = 'modifier_mjz_gyrocopter_rocket_barrage'
		local modifier_mana_name = 'modifier_mjz_gyrocopter_rocket_barrage_mana'
		if ability:GetToggleState() then
			EmitSoundOn("Hero_Gyrocopter.Rocket_Barrage", caster)
			caster:AddNewModifier(caster, ability, modifier_name, {})
			caster:AddNewModifier(caster, ability, modifier_mana_name, {})
		else
			caster:RemoveModifierByName(modifier_name)
			caster:RemoveModifierByName(modifier_mana_name)
		end
	end
end

if IsServer() then
	function ability_class:_IsReady( )
        return self:GetToggleState() and self:_IsCooldownReady()
	end

	function ability_class:_IsCooldownReady()    
        local caster = self:GetCaster()
        local ability = self
        local isCooldownReady = ability:IsCooldownReady()
        return isCooldownReady
    end
	
end



---------------------------------------------------------------------------------------

modifier_mjz_gyrocopter_rocket_barrage = class({})
local modifier_class = modifier_mjz_gyrocopter_rocket_barrage

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

function modifier_class:GetEffectName()
    return "particles/econ/items/gyrocopter/hero_gyrocopter_atomic/gyro_rocket_barrage_atomic_hit.vpcf"
end

if IsServer() then
    function modifier_class:OnCreated( kv )
        local parent = self:GetParent()
        local ability = self:GetAbility()
        
		if parent:IsIllusion() then return nil end

		local interval = ability:GetSpecialValueFor('interval')
		self:StartIntervalThink(interval)		
	end

	function modifier_class:OnIntervalThink( )
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
		local radius = ability:GetSpecialValueFor('radius')
		radius = radius + parent:GetCastRangeBonus()

		EmitSoundOn("Hero_Gyrocopter.Rocket_Barrage.Launch", parent)

		local enemy_list = FindUnitsInRadius(
			parent:GetTeamNumber(), 
			parent:GetAbsOrigin(), 
			nil, radius, 
			ability:GetAbilityTargetTeam(), 
			ability:GetAbilityTargetType(), 
			ability:GetAbilityTargetFlags(), 
			FIND_CLOSEST, false
		)

		for _,enemy in pairs(enemy_list) do
			self:_ApplyDamage(enemy)
			self:_FireEffect(enemy)
		end
	end

	function modifier_class:_ApplyDamage(target )
		local parent = self:GetParent()
		local ability = self:GetAbility()

		local rocket_damage = GetTalentSpecialValueFor(ability, 'rocket_damage')
		local agi_damage_pct = GetTalentSpecialValueFor(ability, 'agi_damage_pct')
		local damage = rocket_damage + parent:GetAgility() * (agi_damage_pct / 100.0)

		ApplyDamage({
			attacker = parent,
			victim = target,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			ability = ability
		})
	end
	
	function modifier_class:_FireEffect(target )
        local parent = self:GetParent()
		local ability = self:GetAbility()
		
		EmitSoundOn("Hero_Gyrocopter.Rocket_Barrage.Impact", target)

		local p_name = "particles/units/heroes/hero_gyrocopter/gyro_rocket_barrage.vpcf"
		ProjectileManager:CreateTrackingProjectile({
            Ability = ability,
            Target = target,
            Source = parent,
            EffectName = p_name,
            iMoveSpeed = 1000,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bDodgeable = false,
            flExpireTime = GameRules:GetGameTime() + 5.0,
        })
	end
end

---------------------------------------------------------------------------------------

modifier_mjz_gyrocopter_rocket_barrage_mana = class({})
local modifier_mana = modifier_mjz_gyrocopter_rocket_barrage_mana

function modifier_mana:IsHidden() return true end
function modifier_mana:IsPurgable() return false end

if IsServer() then
    function modifier_mana:OnCreated()
        local ability = self:GetAbility()
        self:StartIntervalThink(1.0)
    end


    function modifier_mana:OnIntervalThink()
        local ability = self:GetAbility()
        local parent = self:GetParent()

        local mana_cost = ability:GetManaCost(ability:GetLevel())
        if parent:GetMana() >= mana_cost then
            parent:SpendMana(mana_cost, ability)
        else
            ability:ToggleAbility()
        end
    end
end


-----------------------------------------------------------------------------------------


-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(unit, point, radius)
    local iTeamNumber = unit:GetTeamNumber()
    local vPosition = point   				-- 搜索中心点
    local hCacheUnit = nil                  -- 通常值
    local flRadius = radius                 -- 搜索范围
    local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
    -- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP           
	-- 仅针对可见的单位、忽视建筑物、支持魔法免疫
    local iFlagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE   
    local iOrder = FIND_CLOSEST                         -- 寻找最近的
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
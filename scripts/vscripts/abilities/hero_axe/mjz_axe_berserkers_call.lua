LinkLuaModifier("modifier_mjz_axe_berserkers_call_caster","abilities/hero_axe/mjz_axe_berserkers_call.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_axe_berserkers_call_armor_bonus", "abilities/hero_axe/mjz_axe_berserkers_call.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_axe_berserkers_call_enemy", "abilities/hero_axe/mjz_axe_berserkers_call.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_axe_berserkers_call_radius_talent", "abilities/hero_axe/mjz_axe_berserkers_call.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_axe_berserkers_call_enemy_cd", "abilities/hero_axe/mjz_axe_berserkers_call.lua", LUA_MODIFIER_MOTION_NONE)
-----------------------------------------------------------------------------------------
mjz_axe_berserkers_call = class({})
function mjz_axe_berserkers_call:OnAbilityPhaseStart()
	if IsServer() then
		EmitSoundOn("Hero_Axe.BerserkersCall.Start", self:GetCaster())
	end
	return true
end
function mjz_axe_berserkers_call:GetAOERadius()
	local caster = self:GetCaster()
	local abiltiy = self
	local modifer_talent = 'modifier_mjz_axe_berserkers_call_radius_talent'
	local talent_value = 100
	local radius = abiltiy:GetSpecialValueFor('radius')
	local has_talent = caster:HasModifier(modifer_talent)
	if has_talent then radius = radius + talent_value end
	return radius
end
if IsServer() then
	function mjz_axe_berserkers_call:OnSpellStart()
		local caster = self:GetCaster()
		local ability = self
		local duration = ability:GetSpecialValueFor('duration')

		local modifier_mjz_axe_berserkers_call_caster_name = 'modifier_mjz_axe_berserkers_call_caster'
		caster:AddNewModifier(caster, ability, modifier_mjz_axe_berserkers_call_caster_name, {duration = duration})

		self:AttachEffect()
		self:FindEnemy()

		EmitSoundOn("Hero_Axe.Berserkers_Call", caster)

		self:CheckRadius()
	end
	function mjz_axe_berserkers_call:FindEnemy( )
		local caster = self:GetCaster()
		local ability = self
		local modifier_name = "modifier_mjz_axe_berserkers_call_enemy"
		local modifier_CD = "modifier_mjz_axe_berserkers_call_enemy_cd"
	
		local duration = ability:GetSpecialValueFor('duration')
		local radius = GetTalentSpecialValueFor(ability, 'radius')
	
		local enemy_list = FindTargetEnemy(caster, caster:GetAbsOrigin(), radius)
	
		for _,enemy in pairs(enemy_list) do
			if enemy and not enemy:HasModifier(modifier_CD) then
				enemy:AddNewModifier(caster, ability, modifier_name, {duration = duration})
				enemy:AddNewModifier(caster, ability, modifier_CD, {duration = duration + (duration * 0.75)})
				if caster:HasAbility("axe_battle_hunger") and caster:HasShard() then
					local ability = caster:FindAbilityByName("axe_battle_hunger")
					if ability then
						caster:SetCursorCastTarget(enemy)
						ability:OnSpellStart()
					end	
				end	
			end	
		end
	end
	function mjz_axe_berserkers_call:AttachEffect( )
		local caster = self:GetCaster()
		local ability = self
	
		local radius = GetTalentSpecialValueFor(ability, 'radius')
	
		-- "particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf"
		local EffectName = "particles/econ/items/axe/axe_helm_shoutmask/axe_beserkers_call_owner_shoutmask.vpcf"
		local p = ParticleManager:CreateParticle(EffectName, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(p, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(p, 2, Vector(radius, 1, 1))
		ParticleManager:DestroyParticle(p, false)
		ParticleManager:ReleaseParticleIndex(p)
	end
	function mjz_axe_berserkers_call:CheckRadius()
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
function modifier_mjz_axe_berserkers_call_caster:IsHidden() return false end
function modifier_mjz_axe_berserkers_call_caster:IsPurgable() return false end
function modifier_mjz_axe_berserkers_call_caster:IsBuff() return true end
if IsServer() then
	function modifier_mjz_axe_berserkers_call_caster:OnCreated(table)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		self.modifier_mjz_axe_berserkers_call_armor_bonus_name = 'modifier_mjz_axe_berserkers_call_armor_bonus'
		caster:AddNewModifier(caster, ability, self.modifier_mjz_axe_berserkers_call_armor_bonus_name, {})
	end
	function modifier_mjz_axe_berserkers_call_caster:OnDestroy()
		local caster = self:GetCaster()
		if caster:HasModifier(self.modifier_mjz_axe_berserkers_call_armor_bonus_name) then
			caster:RemoveModifierByName(self.modifier_mjz_axe_berserkers_call_armor_bonus_name)
		end		
	end
	function modifier_mjz_axe_berserkers_call_caster:OnRemoved()
		local caster = self:GetCaster()
		if caster:HasModifier(self.modifier_mjz_axe_berserkers_call_armor_bonus_name) then
			caster:RemoveModifierByName(self.modifier_mjz_axe_berserkers_call_armor_bonus_name)
		end		
	end
end

--------------------------------------------------------------------------------------------
modifier_mjz_axe_berserkers_call_armor_bonus = class({})
function modifier_mjz_axe_berserkers_call_armor_bonus:IsHidden() return true end
function modifier_mjz_axe_berserkers_call_armor_bonus:IsPurgable() return false end
function modifier_mjz_axe_berserkers_call_armor_bonus:IsBuff() return true end

function modifier_mjz_axe_berserkers_call_armor_bonus:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_mjz_axe_berserkers_call_armor_bonus:GetModifierPhysicalArmorBonus(params) return self:GetStackCount() end
if IsServer() then
	function modifier_mjz_axe_berserkers_call_armor_bonus:OnCreated( kv )
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
function modifier_mjz_axe_berserkers_call_enemy:IsHidden() return false end
function modifier_mjz_axe_berserkers_call_enemy:IsPurgable() return false end
function modifier_mjz_axe_berserkers_call_enemy:IsDebuff() return true end
function modifier_mjz_axe_berserkers_call_enemy:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true}
end

function modifier_mjz_axe_berserkers_call_enemy:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end
function modifier_mjz_axe_berserkers_call_enemy:StatusEffectPriority()
	return 10
end

if IsServer() then
	function modifier_mjz_axe_berserkers_call_enemy:OnCreated(kv)
		self:GetParent():SetForceAttackTarget(self:GetCaster()) 
		self:GetParent():MoveToTargetToAttack(self:GetCaster()) 
	end
	function modifier_mjz_axe_berserkers_call_enemy:OnRemoved()
		self:GetParent():SetForceAttackTarget(nil)
		self:GetParent():Stop()
	end
	function modifier_mjz_axe_berserkers_call_enemy:OnDestroy()
		self:GetParent():SetForceAttackTarget(nil)
		self:GetParent():Stop()
	end

	function BerserkersCall()
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
------------------------------------------------------------------ debuff to prevent perma call
modifier_mjz_axe_berserkers_call_enemy_cd = class({})
function modifier_mjz_axe_berserkers_call_enemy_cd:IsHidden() return false end
function modifier_mjz_axe_berserkers_call_enemy_cd:IsPurgable() return false end
--function modifier_mjz_axe_berserkers_call_enemy_cd:IsDebuff() return false end
-----------------------------------------------------------------------------

-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(unit, point, radius)
	local iTeamNumber = unit:GetTeamNumber()
	local vPosition = point   				-- 搜索中心点
	local hCacheUnit = nil				  -- 通常值
	local flRadius = radius				 -- 搜索范围
	local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
	-- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP		   
	-- 支持魔法免疫
	local iFlagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE   
	local iOrder = FIND_CLOSEST						 -- 寻找最近的
	local bCanGrowCache = false			 -- 通常值
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







local MODIFIER_LUA = "modifiers/hero_viper/modifier_mjz_viper_nethertoxin.lua"
local MODIFIER_DEBUFF_NAME = 'modifier_mjz_viper_nethertoxin_debuff'
local MODIFIER_MAGIC_RESISTANCE_NAME = 'modifier_mjz_viper_nethertoxin_debuff_magic_resistance'

LinkLuaModifier(MODIFIER_DEBUFF_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_MAGIC_RESISTANCE_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)


modifier_mjz_viper_nethertoxin = class({})
local modifier_class = modifier_mjz_viper_nethertoxin

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
	function modifier_class:OnCreated(table)
		self:StartIntervalThink(1.0)
	end

	function modifier_class:OnIntervalThink()
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local parent = self:GetParent()

        if not ability:GetAutoCastState() then return nil end
        if not ability:IsFullyCastable() then return nil end
		if not ability:IsCooldownReady() then return nil end
		if parent:IsIllusion() then return nil end
		if not parent:IsRealHero() then return nil end
		if parent:IsChanneling() then return nil end		-- 施法中
		if parent:IsSilenced() then return nil end		-- 沉默中

		local radius_auto = ability:GetSpecialValueFor("radius_auto")
		local pos = parent:GetAbsOrigin()
		
		local enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
			ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER, false)

        if #enemy_list > 0 then
			local first_enemy = enemy_list[1]
			
			--[[
				parent:SetCursorCastTarget(first_enemy)
				ability:OnSpellStart()
				ability:StartCooldown(ability:GetCooldownTimeRemaining())
			]]
			
			--[[
				local order = {
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					UnitIndex = parent:entindex(),
					Position = first_enemy:GetAbsOrigin(),
					AbilityIndex = ability:entindex()
				}
				ExecuteOrderFromTable(order)
			]]
			
			parent:CastAbilityOnPosition(first_enemy:GetAbsOrigin(), ability, parent:GetPlayerOwnerID())
        end
	end
end

-----------------------------------------------------------------------------------------


modifier_mjz_viper_nethertoxin_thinker = class({})
local modifier_thinker = modifier_mjz_viper_nethertoxin_thinker

function modifier_thinker:IsHidden() 			return true end
function modifier_thinker:IsPurgable() 			return false end

if IsServer() then
	function modifier_thinker:OnCreated()
		local ability = self:GetAbility()
		self.radius = ability:GetSpecialValueFor("radius")

		EmitSoundOn("Hero_Viper.Nethertoxin.Cast", self:GetParent())

		local nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_viper/viper_nethertoxin.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(nFX, 0, (Vector(0, 0, 0)))
		ParticleManager:SetParticleControl(nFX, 1, (Vector(self.radius, 1, 1)))
		ParticleManager:SetParticleControl(nFX, 15, (Vector(25, 150, 25)))
		ParticleManager:SetParticleControl(nFX, 16, (Vector(0, 0, 0)))
		self:AddParticle(nFX, false, false, 0, false, false)
		
	end

	function modifier_thinker:OnDestroy()
		StopSoundOn("Hero_Viper.Nethertoxin.Cast", self:GetParent())
	end
	
end

---------------------------------------------------------------

function modifier_thinker:IsAura() return true end
-- function modifier_thinker:GetAuraDuration() return 0.5 end
function modifier_thinker:GetModifierAura()
	return MODIFIER_DEBUFF_NAME
end
function modifier_thinker:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor( "radius" )
end
function modifier_thinker:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()		-- DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_thinker:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()		-- DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_thinker:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags() 	-- DOTA_UNIT_TARGET_FLAG_NONE
end

---------------------------------------------------------------


-----------------------------------------------------------------------------------------

modifier_mjz_viper_nethertoxin_debuff = class({})
local modifier_debuff = modifier_mjz_viper_nethertoxin_debuff

function modifier_debuff:IsHidden() 	return true end
function modifier_debuff:IsPurgable() 	return false end

function modifier_debuff:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_nethertoxin_debuff.vpcf"
end

if IsServer() then
	function modifier_debuff:OnCreated()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local parent = self:GetParent()

		parent:AddNewModifier(caster, ability, MODIFIER_MAGIC_RESISTANCE_NAME, {})

		self:OnIntervalThink()
		self:StartIntervalThink( 1.0 )
	end

	function modifier_debuff:OnDestroy()
		local parent = self:GetParent()
		parent:RemoveModifierByName(MODIFIER_MAGIC_RESISTANCE_NAME)		
	end

	function modifier_debuff:OnIntervalThink()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local damage = GetTalentSpecialValueFor(ability, "damage")
		local magic_resistance = GetTalentSpecialValueFor(ability, "magic_resistance")

		local modifier = parent:FindModifierByName(MODIFIER_MAGIC_RESISTANCE_NAME)
		if modifier then
			if modifier:GetStackCount() ~= magic_resistance then
				modifier:SetStackCount(magic_resistance)
			end
		end

		DealDamage(ability, caster, parent, damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )

		parent:EmitSound("Hero_Viper.NetherToxin.Damage")
	end
	
end

-----------------------------------------------------------------------------------------


modifier_mjz_viper_nethertoxin_debuff_magic_resistance = class({})
local modifier_magic_resistance = modifier_mjz_viper_nethertoxin_debuff_magic_resistance

function modifier_magic_resistance:IsHidden() 	return false end
function modifier_magic_resistance:IsPurgable() 	return false end

function modifier_magic_resistance:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end

function modifier_magic_resistance:GetModifierMagicalResistanceBonus()
	return self:GetStackCount()
end


-----------------------------------------------------------------------------------------

function IsChanneling(unit)
	local ability_count = unit:GetAbilityCount()
	for i=0,(ability_count-1) do
		local ability = unit:GetAbilityByIndex(i)
		if ability ~= nil then
			if ability:IsChanneling() then
				return true
			end
		end
	end
	for itemSlot = 0, 5, 1 do
		local Item = unit:GetItemInSlot( itemSlot )
		if Item ~= nil then
			if Item:IsChanneling() then
				return true
			end
		end
	end
	return false
end

function DealDamage(ability, attacker, victim, damage, data, spellText)
	--OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, OVERHEAD_ALERT_DAMAGE, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, OVERHEAD_ALERT_MANA_LOSS
	if ability:IsNull() or victim:IsNull() or attacker:IsNull() then return end
	local internalData = data or {}
	local damageType =  internalData.damage_type or ability:GetAbilityDamageType() or DAMAGE_TYPE_MAGICAL
	local damageFlags = internalData.damage_flags or DOTA_DAMAGE_FLAG_NONE
	local localdamage = damage or ability:GetAbilityDamage() or 0
	local spellText = spellText or 0
	local ability = ability or internalData.ability
	local returnDamage = ApplyDamage({victim = victim, attacker = attacker, ability = ability, damage_type = damageType, damage = localdamage, damage_flags = damageFlags})
	if spellText > 0 then
		SendOverheadEventMessage(attacker:GetPlayerOwner(),spellText,victim,returnDamage,attacker:GetPlayerOwner()) --Substract the starting health by the new health to get exact damage taken values.
	end
	return returnDamage
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

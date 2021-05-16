

local MODIFIER_CASTER_NAME = 'modifier_mjz_ember_spirit_flame_guard'
local MODIFIER_CASTER_DAMAGE_NAME = 'modifier_mjz_ember_spirit_flame_guard_damage'


LinkLuaModifier(MODIFIER_CASTER_NAME, "abilities/hero_ember_spirit/mjz_ember_spirit_flame_guard.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_CASTER_DAMAGE_NAME, "abilities/hero_ember_spirit/mjz_ember_spirit_flame_guard.lua", LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------------

mjz_ember_spirit_flame_guard = class({})
local ability_class = mjz_ember_spirit_flame_guard

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('radius')
end

if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local duration = ability:GetSpecialValueFor('duration')

		if caster:HasModifier(MODIFIER_CASTER_NAME) then
			caster:RemoveModifierByName(MODIFIER_CASTER_NAME)
		end
		caster:AddNewModifier(caster, ability, MODIFIER_CASTER_NAME, {duration = duration})

		caster:EmitSound("Hero_EmberSpirit.FlameGuard.Cast")
	end

end

-----------------------------------------------------------------------------------------


modifier_mjz_ember_spirit_flame_guard = class({})
local modifier_class = modifier_mjz_ember_spirit_flame_guard

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return true end

function modifier_class:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf"
end

function modifier_class:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_class:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end

function modifier_class:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_reduction_pct")
end


if IsServer() then
	function modifier_class:OnCreated(table)
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local tick_interval = ability:GetSpecialValueFor('tick_interval')
		local bonus_damage_pct = GetTalentSpecialValueFor(ability, 'bonus_damage_pct')

		EmitSoundOn("Hero_EmberSpirit.FlameGuard.Loop", parent)

		parent:AddNewModifier(parent, ability, MODIFIER_CASTER_DAMAGE_NAME, {})
		parent:SetModifierStackCount(MODIFIER_CASTER_DAMAGE_NAME, parent, bonus_damage_pct)

		self:StartIntervalThink(tick_interval)
	end

	function modifier_class:OnIntervalThink()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local radius = ability:GetSpecialValueFor('radius')
		local tick_interval = ability:GetSpecialValueFor('tick_interval')
		local damage_per_second = GetTalentSpecialValueFor(ability, 'damage_per_second')
		
		local damage = damage_per_second * tick_interval

		local enemy_list = FindUnitsInRadius(
			parent:GetTeam(), 
			parent:GetAbsOrigin(), 
			nil, radius, 
			ability:GetAbilityTargetTeam(), 
			ability:GetAbilityTargetType(), 
			ability:GetAbilityTargetFlags(), 
			FIND_ANY_ORDER, false
		)

		for _,enemy in pairs(enemy_list) do
			ApplyDamage({
				attacker = parent,
				victim = enemy,
				damage = damage,
				damage_type = ability:GetAbilityDamageType(),
				ability = ability,
			})
		end
	end

	function modifier_class:OnDestroy()
		local parent = self:GetParent()

		parent:RemoveModifierByName(MODIFIER_CASTER_DAMAGE_NAME)
		StopSoundEvent( "Hero_EmberSpirit.FlameGuard.Loop", parent )
	end
end


-----------------------------------------------------------------------------------------

modifier_mjz_ember_spirit_flame_guard_damage = class({})
local modifier_damage = modifier_mjz_ember_spirit_flame_guard_damage

function modifier_damage:IsHidden() return true end
function modifier_damage:IsPurgable() return false end

function modifier_damage:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_damage:GetModifierDamageOutgoing_Percentage()
	return self:GetStackCount()
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
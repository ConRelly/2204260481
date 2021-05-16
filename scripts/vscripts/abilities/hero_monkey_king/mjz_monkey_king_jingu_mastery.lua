LinkLuaModifier("modifier_mjz_monkey_king_jingu_mastery_counter","abilities/hero_monkey_king/mjz_monkey_king_jingu_mastery.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_monkey_king_jingu_mastery_hit","abilities/hero_monkey_king/mjz_monkey_king_jingu_mastery.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_monkey_king_jingu_mastery_bonuses","abilities/hero_monkey_king/mjz_monkey_king_jingu_mastery.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_monkey_king_jingu_mastery_bonus_damage","abilities/hero_monkey_king/mjz_monkey_king_jingu_mastery.lua", LUA_MODIFIER_MOTION_NONE)

local MODIFIER_HIT_NAME = "modifier_mjz_monkey_king_jingu_mastery_hit"
local MODIFIER_BUFF_NAME = "modifier_mjz_monkey_king_jingu_mastery_bonuses"

mjz_monkey_king_jingu_mastery = class({})
local ability_class = mjz_monkey_king_jingu_mastery

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_monkey_king_jingu_mastery_counter"
end

---------------------------------------------------------------------------------------

modifier_mjz_monkey_king_jingu_mastery_counter = class({})
local modifier_counter = modifier_mjz_monkey_king_jingu_mastery_counter

function modifier_counter:IsHidden() return true end
function modifier_counter:IsPurgable() return false end

if IsServer() then
    function modifier_counter:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end

    function modifier_counter:OnAttackLanded(keys)
        if keys.attacker ~= self:GetParent() then return nil end
        if keys.attacker:PassivesDisabled() then return nil end
        if not self:_IsEnemy(keys.target) then return nil end

        local attacker = keys.attacker
        local target = keys.target

        local ability = self:GetAbility()
        local required_hits = ability:GetSpecialValueFor("required_hits")
        local counter_duration = ability:GetSpecialValueFor("counter_duration")
        local max_duration = ability:GetSpecialValueFor("max_duration")

        local not_has_modifier_hit = not attacker:HasModifier(MODIFIER_HIT_NAME)
        local not_has_modifier_buff = not attacker:HasModifier(MODIFIER_BUFF_NAME)
        if not_has_modifier_hit and not_has_modifier_buff then
            attacker:AddNewModifier(attacker, ability, MODIFIER_HIT_NAME, {duration = counter_duration})
        end

        local modifier_hit = attacker:FindModifierByName(MODIFIER_HIT_NAME)
        if modifier_hit then
            modifier_hit:SetDuration(counter_duration, true)
            modifier_hit:IncrementStackCount()
            if modifier_hit:GetStackCount() >= required_hits then
                modifier_hit:Destroy()
                attacker:AddNewModifier(attacker, ability, MODIFIER_BUFF_NAME, {duration = max_duration})
            end
        end
    end

    function modifier_counter:_IsEnemy(target)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local nTargetTeam = ability:GetAbilityTargetTeam()
		local nTargetType = ability:GetAbilityTargetType()
		local nTargetFlags = ability:GetAbilityTargetFlags()
		local nTeam = caster:GetTeamNumber()
		local ufResult = UnitFilter(target, nTargetTeam, nTargetType, nTargetFlags, nTeam)
		return ufResult == UF_SUCCESS
	end
end


-----------------------------------------------------------------------------------------


modifier_mjz_monkey_king_jingu_mastery_hit = class({})
local modifier_hit = modifier_mjz_monkey_king_jingu_mastery_hit

function modifier_hit:IsHidden() return false end
function modifier_hit:IsPurgable() return false end
function modifier_hit:IsBuff() return true end

if IsServer() then
    function modifier_hit:OnStackCountChanged(count)
        ParticleManager:SetParticleControl(self.effect, 1, Vector(0, count + 1, 0))
    end

    function modifier_hit:OnCreated(keys)
		local parent = self:GetParent()
		local p_name = "particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_stack.vpcf"
        self.effect = ParticleManager:CreateParticle(p_name, PATTACH_OVERHEAD_FOLLOW, parent)
        ParticleManager:SetParticleControl(self.effect, 0, parent:GetAbsOrigin())
    end

    function modifier_hit:OnDestroy()
        ParticleManager:DestroyParticle(self.effect, false)
        ParticleManager:ReleaseParticleIndex(self.effect)
    end
end

-----------------------------------------------------------------------------------------


modifier_mjz_monkey_king_jingu_mastery_bonuses = class({})
local modifier_bonuses = modifier_mjz_monkey_king_jingu_mastery_bonuses

function modifier_bonuses:IsHidden() return false end
function modifier_bonuses:IsPurgable() return false end
function modifier_bonuses:IsBuff() return true end

function modifier_bonuses:GetEffectName()
    -- return "particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_debuff.vpcf"
    return "particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_overhead.vpcf"
end
function modifier_bonuses:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end


if IsServer() then
	function modifier_bonuses:OnCreated()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local parent = self:GetParent()

		local charges = self:GetAbility():GetSpecialValueFor("charges")
		-- self:SetStackCount(charges)

		self.modifier_bonus_damage = 'modifier_mjz_monkey_king_jingu_mastery_bonus_damage'
		parent:AddNewModifier(caster, ability, self.modifier_bonus_damage, {})
	end
	
	function modifier_bonuses:OnDestroy()
		local parent = self:GetParent()
		parent:RemoveModifierByName(self.modifier_bonus_damage)
	end

	function modifier_bonuses:DisplayHitEffect(target)
		local heal_effect_name = "particles/generic_gameplay/generic_lifesteal.vpcf"
        local heal_effect = ParticleManager:CreateParticle(heal_effect_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:ReleaseParticleIndex(heal_effect)

		local hit_effect_name = "particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_hit.vpcf"
        local hit_effect = ParticleManager:CreateParticle(hit_effect_name, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(hit_effect, 1, target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(hit_effect)
    end

	function modifier_bonuses:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_ATTACK_LANDED,
		}
	end

    function modifier_bonuses:OnAttackLanded(keys)
        if keys.attacker == self:GetParent() then
            local lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal") * 0.01

            local parent = self:GetParent()
            parent:Heal(keys.damage * lifesteal, parent)

			self:DisplayHitEffect(keys.target)

            --[[
                self:DecrementStackCount()
                if self:GetStackCount() <= 0 then
                    self:Destroy() 
                end
            ]]
			
        end
	end

end

-----------------------------------------------------------------------------------------

modifier_mjz_monkey_king_jingu_mastery_bonus_damage = class({})
local modifier_bonus_damage = modifier_mjz_monkey_king_jingu_mastery_bonus_damage

function modifier_bonus_damage:IsHidden() return true end
function modifier_bonus_damage:IsPurgable() return false end
function modifier_bonus_damage:IsBuff() return true end

function modifier_bonus_damage:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end
function modifier_bonus_damage:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount()
end

if IsServer() then
	function modifier_bonus_damage:OnCreated(table)
		local ability = self:GetAbility()
		local bonus_damage = GetTalentSpecialValueFor(ability, "bonus_damage")
		self:SetStackCount(bonus_damage)
	end
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
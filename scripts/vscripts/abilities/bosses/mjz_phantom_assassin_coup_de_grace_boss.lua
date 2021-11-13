
local THIS_LUA = "abilities/bosses/mjz_phantom_assassin_coup_de_grace_boss.lua"
local MODIFIER_INIT_NAME = 'modifier_mjz_phantom_assassin_coup_de_grace'
local MODIFIER_BONUS_NAME = 'modifier_mjz_phantom_assassin_coup_de_grace_bonus'

LinkLuaModifier(MODIFIER_INIT_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_BONUS_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------------

mjz_phantom_assassin_coup_de_grace_boss = class({})

function mjz_phantom_assassin_coup_de_grace_boss:GetIntrinsicModifierName()
	return 'modifier_mjz_phantom_assassin_coup_de_grace'
end

--------------------------------------------------------------------------------------

modifier_mjz_phantom_assassin_coup_de_grace = class({})
local modifier_class = modifier_mjz_phantom_assassin_coup_de_grace

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
    function modifier_class:DeclareFunctions()
        local func = {
			MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
			MODIFIER_EVENT_ON_ATTACK,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
        return func
    end

	function modifier_class:GetModifierPreAttack_CriticalStrike(event)
		local target = event.target 
		local attacker = event.attacker
		if self:GetAbility() then
			local ability = self:GetAbility()
			if ability.crit then
				local crit_bonus = GetTalentSpecialValueFor(ability, "crit_bonus")
				return crit_bonus
			end
		end	
	end

	function modifier_class:OnAttack( event )
		if event.attacker ~= self:GetParent() then return end
		local target = event.target 
		local attacker = event.attacker
        local caster = self:GetCaster()
		local ability = self:GetAbility()

		if ability.crit then
			ability.crit = false

			if not attacker:IsRangedAttacker() then
				ability.cleave = true
			end	

			if attacker:HasScepter() then
				ability.magical = true
			end

			PlayEffect(attacker, target)

			local bonus_duration = ability:GetSpecialValueFor('bonus_duration')
			attacker:AddNewModifier(caster, ability, MODIFIER_BONUS_NAME, {duration = bonus_duration})
		end

		local can = self:_CheckAttack(attacker, target, ability)
		if can then
			local crit_chance = GetTalentSpecialValueFor(ability, "crit_chance")
			local crit_bonus = GetTalentSpecialValueFor(ability, "crit_bonus")
			if RollPercentage(crit_chance) then
				ability.crit = true
			end
		end
	end

	function modifier_class:OnAttackLanded(event)
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local target = event.target
		local attacker = event.attacker
		local attack_damage = event.original_damage

		if attacker:IsIllusion() then return nil end

		local can = self:_CheckAttack(attacker, target, ability)
		if can then
			if ability.magical then
				ability.magical = false
				self:_MagicalAttack(target, attack_damage)
			end

			if ability.cleave then
				ability.cleave = false
				local vToCaster = attacker:GetAbsOrigin() - target:GetAbsOrigin()
				local flDistance = vToCaster:Length2D()
				local attack_range = attacker:GetBaseAttackRange() + 50
				if flDistance <= attack_range then
					_DoCleaveAttack(attacker, ability, target, attack_damage)
				end
			end
		end
	end
		
	function modifier_class:_CheckAttack(attacker, target, ability )
		if attacker ~= self:GetParent() then return nil end
		if attacker:PassivesDisabled() then return nil end

		local nResult = UnitFilter(
			target,
			ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),
			ability:GetAbilityTargetFlags(),
			attacker:GetTeamNumber()
		)
		return nResult == UF_SUCCESS
	end

	function modifier_class:_MagicalAttack(target, attack_damage)
		if target:IsMagicImmune() then return nil end

		local caster = self:GetCaster()
        local parent = self:GetParent()
		local ability = self:GetAbility()
		local magical_damage = ability:GetSpecialValueFor('magical_damage_scepter')
		local damage = attack_damage * (magical_damage / 100.0)
		
		local damageTable = {
			victim = target,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			attacker = caster,
			ability = ability
		}
		ApplyDamage(damageTable)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, damage, nil)
	end

end

function PlayEffect( caster, target)
	
	EmitSoundOn('Hero_PhantomAssassin.CoupDeGrace', target)

	local effect_name = GetEffectName(caster, target)

	local nFXIndex = ParticleManager:CreateParticle( effect_name, PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
	ParticleManager:SetParticleControl( nFXIndex, 1, target:GetOrigin() )
	ParticleManager:SetParticleControlForward( nFXIndex, 1, -caster:GetForwardVector())
	ParticleManager:SetParticleControlEnt( nFXIndex, 10, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	
end

function GetEffectName( caster, target )
	local effect_crit_impact_dagger_mechanical = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_dagger_mechanical.vpcf"
	local effect_crit_impact_dagger_mechanical_arcana = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/phantom_assassin_crit_impact_dagger_mechanical_arcana.vpcf"

	local effect_desat = {
		crit_impact = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf",
		crit_impact_dagger = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_dagger.vpcf",
		crit_impact_dagger_arcana = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/phantom_assassin_crit_impact_dagger_arcana.vpcf",
	}

	local effect_self = {
		crit_impact = "particles/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf",
		crit_impact_dagger = "particles/hero_phantom_assassin/phantom_assassin_crit_impact_dagger.vpcf",
		crit_impact_dagger_arcana = "particles/hero_phantom_assassin/phantom_assassin_crit_impact_dagger_arcana.vpcf",
	}

	return effect_self.crit_impact
end

function _DoCleaveAttack(caster, ability, target, attack_damage)
	local cleave_percent = GetTalentSpecialValueFor(ability, "cleave_damage")
	local cleave_start_radius = GetTalentSpecialValueFor(ability, "cleave_starting_width")
	local cleave_end_radius = GetTalentSpecialValueFor(ability, "cleave_ending_width")
	local cleave_distance = GetTalentSpecialValueFor(ability, "cleave_distance")

	local cleaveDamage = attack_damage * (cleave_percent / 100.0)

	local cleave_effect_kunkka = "particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf"
	local cleave_effect_kunkka_fxset = "particles/econ/items/kunkka/divine_anchor/hero_kunkka_dafx_weapon/kunkka_spell_tidebringer_fxset.vpcf"
	local cleave_effect_sven = "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf"
	local cleave_effect_sven_ti7_crit  = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_crit.vpcf"
	local cleave_effect_sven_ti7_gods_crit = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength_crit.vpcf"

	local cleave_effectName = cleave_effect_sven_ti7_gods_crit

	DoCleaveAttack(caster, target, ability, cleaveDamage, cleave_start_radius, cleave_end_radius, cleave_distance, cleave_effectName)
end

--------------------------------------------------------------------------------------


modifier_mjz_phantom_assassin_coup_de_grace_bonus = class({})
local modifier_bonus = modifier_mjz_phantom_assassin_coup_de_grace_bonus

function modifier_bonus:IsHidden() return false end
function modifier_bonus:IsPurgable() return false end

function modifier_bonus:DeclareFunctions()
	local func = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
	return func
end

function modifier_bonus:GetModifierDamageOutgoing_Percentage(event)
	return self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
end


--------------------------------------------------------------------------------------

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

LinkLuaModifier('modifier_mjz_nyx_assassin_mana_burn', "abilities/hero_nyx_assassin/mjz_nyx_assassin_mana_burn.lua", LUA_MODIFIER_MOTION_NONE)


mjz_nyx_assassin_mana_burn = class({})
local ability_class = mjz_nyx_assassin_mana_burn

function ability_class:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
	return self.BaseClass.GetBehavior( self )
end

function ability_class:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor('radius_scepter')
	else
		return self:GetSpecialValueFor('cast_range')
	end
end

function ability_class:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor('cast_range')
end


if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local radius_scepter = ability:GetSpecialValueFor('radius_scepter')

		EmitSoundOn('Hero_NyxAssassin.ManaBurn.Cast', caster)
        EmitSoundOn('Hero_NyxAssassin.ManaBurn.Target', caster)
		local target_list = {}

		if caster:HasScepter() then
			target_list = FindUnitsInRadius(
				caster:GetTeamNumber(),
				target:GetAbsOrigin(),
				nil, radius_scepter,
				ability:GetAbilityTargetTeam(),
				ability:GetAbilityTargetType(),
				ability:GetAbilityTargetFlags(),
				FIND_ANY_ORDER, false
			)
		else
			table.insert( target_list, target)
		end

		for _,enemy in pairs(target_list) do
			if enemy then
				enemy:AddNewModifier(caster, ability, 'modifier_mjz_nyx_assassin_mana_burn', {})
			end
		end
	end
end


----------------------------------------------------------------------------

modifier_mjz_nyx_assassin_mana_burn = class({})
local modifier_class = modifier_mjz_nyx_assassin_mana_burn

function modifier_class:IsPassive() return false end
function modifier_class:IsPurgable() return false end
function modifier_class:IsHidden() return true end

function modifier_class:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

if IsServer() then
	function modifier_class:OnCreated(table)
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local target = self:GetParent()
		local int_damage_pct = GetTalentSpecialValueFor(ability, 'int_damage_pct')
		local number_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_msg.vpcf"
		local burn_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf"

		local target_mana = target:GetMana()
		local caster_int = caster:GetIntellect()
		
		local mana_to_burn = math.min( target_mana, caster_int * (int_damage_pct / 100.0) )
		local life_time = 2.0
		local digits = string.len( math.floor( mana_to_burn ) ) + 1

		if target:IsMagicImmune() then
			mana_to_burn = 0
		end

		-- Apply effect of ability
		target:ReduceMana( mana_to_burn )
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = mana_to_burn,
			damage_type = ability:GetAbilityDamageType(),
			ability = ability,
		}
		ApplyDamage( damageTable )

		self.numberIndex = ParticleManager:CreateParticle( number_particle_name, PATTACH_OVERHEAD_FOLLOW, target )
		ParticleManager:SetParticleControl( self.numberIndex, 1, Vector( 1, mana_to_burn, 0 ) )
		ParticleManager:SetParticleControl( self.numberIndex, 2, Vector( life_time, digits, 0 ) )
		self.burnIndex = ParticleManager:CreateParticle( burn_particle_name, PATTACH_ABSORIGIN, target )

		--EmitSoundOn('Hero_NyxAssassin.ManaBurn.Target', target)

		self:StartIntervalThink(life_time)
	end

	function modifier_class:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		if self.numberIndex then
			ParticleManager:DestroyParticle( self.numberIndex, false )
		end
		if self.burnIndex then
			ParticleManager:DestroyParticle( self.burnIndex, false)
		end
		
		self:StartIntervalThink(-1)
		self:Destroy()
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
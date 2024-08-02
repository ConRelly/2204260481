LinkLuaModifier( "modifier_mjz_slark_dark_pact", "abilities/hero_slark/mjz_slark_dark_pact.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mjz_slark_dark_pact_effect", "abilities/hero_slark/mjz_slark_dark_pact.lua" ,LUA_MODIFIER_MOTION_NONE )

mjz_slark_dark_pact = class({})
local ability_class = mjz_slark_dark_pact

if IsServer() then
	function ability_class:OnSpellStart()
		local ability = self
		local caster = self:GetCaster()
		local delay = ability:GetSpecialValueFor('delay')
		local pulse_duration = ability:GetSpecialValueFor('pulse_duration')

		EmitSoundOn("Hero_Slark.DarkPact.PreCast", caster)

		caster:AddNewModifier(caster, ability, 'modifier_mjz_slark_dark_pact', {duration = delay})
	end
	
end

----------------------------------------------------------------------------

modifier_mjz_slark_dark_pact = class({})
local modifier_class = modifier_mjz_slark_dark_pact

function modifier_class:IsHidden( ) return true end
function modifier_class:IsPurgable() return false end

function modifier_class:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

if IsServer() then
	function modifier_class:OnCreated( kv )
		local parent = self:GetParent()
		local p_name = "particles/units/heroes/hero_slark/slark_dark_pact_start.vpcf"
		local p_index = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(p_index, 1, parent, PATTACH_ABSORIGIN_FOLLOW, nil, parent:GetAbsOrigin(), true)
		ParticleManager:DestroyParticle(p_index, false)
		ParticleManager:ReleaseParticleIndex(p_index)
	end

	function modifier_class:OnDestroy()
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		if ability and not ability:IsNull() then
			local pulse_duration = ability:GetSpecialValueFor('pulse_duration')
			
			EmitSoundOn("Hero_Slark.DarkPact.Cast", caster)
			parent:AddNewModifier(caster, ability, "modifier_mjz_slark_dark_pact_effect", {duration = pulse_duration})
		end	
	end
end


----------------------------------------------------------------------------

modifier_mjz_slark_dark_pact_effect = class({})
local modifier_effect = modifier_mjz_slark_dark_pact_effect

function modifier_effect:IsHidden( ) return true end
function modifier_effect:IsPurgable() return false end	

function modifier_effect:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


if IsServer() then
	function modifier_effect:OnCreated()
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local base_damage = ability:GetSpecialValueFor("base_damage")
		local health_damage_pct = GetTalentSpecialValueFor(ability, "health_damage_pct")
		self.damage = base_damage + parent:GetHealth() * (health_damage_pct / 100.0)
		self.rate = ability:GetSpecialValueFor("pulse_interval")
		self.radius = ability:GetSpecialValueFor("radius")
		self.particleFire = 0
		self:StartIntervalThink(self.rate)
	end

	function modifier_effect:OnIntervalThink()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local damage = self.damage * self.rate
		local self_damage = damage / 5

		if self.particleFire <= 0 then
			local p_name = "particles/units/heroes/hero_slark/slark_dark_pact_pulses.vpcf"
			local p_index = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, parent)
            ParticleManager:SetParticleControlEnt(p_index, 1, parent, PATTACH_ABSORIGIN_FOLLOW, nil, parent:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(p_index, 2, Vector(self.radius, self.radius, self.radius))
			ParticleManager:DestroyParticle(p_index, false)
			ParticleManager:ReleaseParticleIndex(p_index)

			self.particleFire = 1
		else
			self.particleFire = self.particleFire - self.rate
		end

		local damageTable = {
			victim = nil,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			attacker = parent,
			ability = ability
		}
		
		local enemies = FindUnitsInRadius(
			parent:GetTeamNumber(),
			parent:GetAbsOrigin(),
			nil, self.radius,
			ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),
			ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER, false
		)

		for _, enemy in ipairs( enemies ) do
			damageTable.victim = enemy
			ApplyDamage(damageTable)
		end

		-- 强驱散
		parent:Purge(false, true, false, true, true)
		-- 弱驱散
		-- parent:Purge(false, true, false, false, false)

		ApplyDamage({
			victim = parent,
			damage = self_damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			attacker = parent,
			ability = ability,
		})
	end
end


------------------------------------------------------------------------------------------

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
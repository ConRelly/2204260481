LinkLuaModifier("modifier_mjz_riki_backstab", "abilities/hero_riki/mjz_riki_backstab.lua", LUA_MODIFIER_MOTION_NONE)

mjz_riki_backstab = class({})
local ability_class = mjz_riki_backstab

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_riki_backstab"
end

---------------------------------------------------------------------------------------

modifier_mjz_riki_backstab = class({})
local modifier_class = modifier_mjz_riki_backstab

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,	
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
	if IsServer() then
		return funcs
	else
		return {
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		}
	end
end

function modifier_class:GetModifierConstantHealthRegen( )
	return self:GetAbility():GetSpecialValueFor('health_regen')
end
function modifier_class:GetModifierPreAttack_BonusDamage( )
	return self:GetStackCount()
end

if IsServer() then

	function modifier_class:OnCreated(table)
		self:_Update_BonusDamage()
	end

	function modifier_class:OnAttackStart( keys )
		self:_Update_BonusDamage()
	end

	function modifier_class:OnAttackLanded(keys)
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local attacker = keys.attacker
	
		if attacker == self:GetParent() then
			local target = keys.target

			local particle_effect = "particles/units/heroes/hero_riki/riki_backstab.vpcf"
			local particle = ParticleManager:CreateParticle(particle_effect, PATTACH_ABSORIGIN_FOLLOW, target) 
			ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
			ParticleManager:ReleaseParticleIndex(particle)
			
			-- self:_Update_BonusDamage()
		end
	end

	function modifier_class:_Update_BonusDamage( )
		local parent = self:GetParent()
		local ability = self:GetAbility()
		
		local agility_damage = ability:GetSpecialValueFor('agility_damage')
		local bonus_damage = parent:GetAgility() * (agility_damage / 100.0)
		bonus_damage = math.abs( bonus_damage )

		if self:GetStackCount() ~= bonus_damage then
			self:SetStackCount(bonus_damage)
		end
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
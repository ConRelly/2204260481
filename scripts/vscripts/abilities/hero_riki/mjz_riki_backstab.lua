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
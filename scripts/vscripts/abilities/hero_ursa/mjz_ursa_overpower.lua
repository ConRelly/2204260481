LinkLuaModifier("modifier_mjz_ursa_overpower","abilities/hero_ursa/mjz_ursa_overpower.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_ursa_overpower_bonus_str_agi","abilities/hero_ursa/mjz_ursa_overpower.lua", LUA_MODIFIER_MOTION_NONE)
mjz_ursa_overpower = class({})
local ability_class = mjz_ursa_overpower


if IsServer() then
	function ability_class:OnSpellStart()
		local ability = self
		local caster = self:GetCaster()
		local duration = ability:GetSpecialValueFor('duration')
		local bonus = ability:GetSpecialValueFor('bonus')
		local modifier_name = 'modifier_mjz_ursa_overpower'
		local name = caster:GetUnitName()
		if name == "npc_dota_hero_ursa" then
			bonus = bonus * 3
		end	
		local modifier = caster:FindModifierByName(modifier_name)
		if modifier then
			modifier:SetDuration(duration, true)
			modifier:ForceRefresh()
		else
			caster:AddNewModifier(caster, ability, modifier_name, {duration = duration})
		end
		if caster:HasModifier("modifier_super_scepter") then
			if RollPercentage(50) then
				if IsValidEntity(caster) and caster:IsAlive() then
					if caster:HasModifier("modifier_marci_unleash_flurry") then
						bonus = bonus * 2
					end						
					caster:ModifyAgility(bonus)
					caster:ModifyStrength(bonus)	
					if caster:HasModifier("modifier_mjz_ursa_overpower_bonus_str_agi") then
						local modifier = caster:FindModifierByName("modifier_mjz_ursa_overpower_bonus_str_agi")
						modifier:SetStackCount(modifier:GetStackCount() + bonus)
					else
						caster:AddNewModifier(caster, ability, "modifier_mjz_ursa_overpower_bonus_str_agi", {})
						caster:FindModifierByName("modifier_mjz_ursa_overpower_bonus_str_agi"):SetStackCount(bonus)
						self:ApplyRetroactiveBonus(caster)
					end										
				end	
			end				
		end	
		EmitSoundOn("Hero_Ursa.Overpower", caster)
	end

	function ability_class:ApplyRetroactiveBonus(caster)
		local ability = self
		local bonus = ability:GetSpecialValueFor("bonus")
		local modifier_name = "modifier_mjz_ursa_overpower_bonus_str_agi"
		local time = GameRules:GetGameTime()
		local cd_reduction = caster:GetCooldownReduction()
		local interval = 30 * cd_reduction
		--print("Retroactive bonus applied at time: " .. time .. ", interval: " .. interval)
		local stack = math.floor(time / interval) * bonus
		--25% chance for double stacks
		if RollPercentage(25) then
			stack = stack * 2
		end
		if caster:GetUnitName() == "npc_dota_hero_ursa" then
			stack = math.floor(time / interval) * (bonus * 3)
		end
		if stack > 0 then
			local modifier = caster:FindModifierByName(modifier_name)
			if modifier then
				modifier:SetStackCount(modifier:GetStackCount() + stack)
			else
				caster:AddNewModifier(caster, ability, modifier_name, {})
				caster:FindModifierByName(modifier_name):SetStackCount(stack)
			end
			caster:ModifyAgility(stack)
			caster:ModifyStrength(stack)
			--print("Retroactive bonus applied: " .. stack .. " stacks to " .. caster:GetUnitName())
		end
	end

end


if modifier_mjz_ursa_overpower_bonus_str_agi == nil then modifier_mjz_ursa_overpower_bonus_str_agi = class({}) end
local modifier_overpower_bonus_stat = modifier_mjz_ursa_overpower_bonus_str_agi

function modifier_overpower_bonus_stat:IsHidden() return false end
function modifier_overpower_bonus_stat:IsPurgable() return false end
function modifier_overpower_bonus_stat:IsDebuff() return false end
function modifier_overpower_bonus_stat:RemoveOnDeath() return false end
function modifier_overpower_bonus_stat:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_overpower_bonus_stat:OnTooltip()
	return self:GetStackCount()
end

---------------------------------------------------------------------------------------

modifier_mjz_ursa_overpower = class({})
local modifier_class = modifier_mjz_ursa_overpower

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end
function modifier_class:IsBuff() return true end

function modifier_class:GetStatusEffectName()
	return "particles/status_fx/status_effect_overpower.vpcf"
end
function modifier_class:StatusEffectPriority(  )
	return 10
end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
	return funcs
end

function modifier_class:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
	end
end

function modifier_class:GetModifierSpellAmplify_Percentage()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local amp = 0
	if ability then
		amp = ability:GetSpecialValueFor('bonus_spell_amp')
	end
	if parent and parent:HasModifier("modifier_super_scepter") then
		local lvl = parent:GetLevel()
		if lvl > 0 then
			amp = amp + lvl * 1
			if lvl > 100 then
				amp = amp + (lvl - 100) * 9 
			end
		end
	end
	return amp
end


if IsServer() then
	function modifier_class:OnCreated(table)
		local parent = self:GetParent()
		local origin = parent:GetOrigin()

		local p_name = "particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf"
		local index = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControlEnt(index, 0, parent, PATTACH_POINT_FOLLOW, "attach_head", origin, true)
        ParticleManager:SetParticleControlEnt(index, 2, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", origin, true)
        ParticleManager:SetParticleControlEnt(index, 3, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", origin, true)

        self:AddParticle(index, false, false, -1, false, false)
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
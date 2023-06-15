LinkLuaModifier("modifier_mjz_ursa_overpower","abilities/hero_ursa/mjz_ursa_overpower.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_ursa_overpower_bonus_str_agi","abilities/hero_ursa/mjz_ursa_overpower.lua", LUA_MODIFIER_MOTION_NONE)
mjz_ursa_overpower = class({})
local ability_class = mjz_ursa_overpower


if IsServer() then
	function ability_class:OnSpellStart( )
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
					end										
				end	
			end				
		end	
		EmitSoundOn("Hero_Ursa.Overpower", caster)
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

function modifier_class:GetModifierAttackSpeedBonus_Constant( )
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor('bonus_attack_speed') end
end

function modifier_class:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor('bonus_spell_amp') end
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
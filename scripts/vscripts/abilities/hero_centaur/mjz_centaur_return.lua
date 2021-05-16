
LinkLuaModifier('modifier_mjz_centaur_return', "abilities/hero_centaur/mjz_centaur_return.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_mjz_centaur_return_aura', "abilities/hero_centaur/mjz_centaur_return.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_mjz_centaur_return_buff', "abilities/hero_centaur/mjz_centaur_return.lua", LUA_MODIFIER_MOTION_NONE)

----------------------------------------------------------------------------

mjz_centaur_return = class({})

function mjz_centaur_return:GetIntrinsicModifierName()
	return 'modifier_mjz_centaur_return'
end

function mjz_centaur_return:GetAOERadius()
	local MODIFIER_AURA_NAME = 'modifier_mjz_centaur_return_aura'
	if self:GetCaster():HasModifier(MODIFIER_AURA_NAME) then
		return self:GetSpecialValueFor('aura_radius')
	end
end

----------------------------------------------------------------------------

modifier_mjz_centaur_return = class({})

function modifier_mjz_centaur_return:IsPassive()
	return true
end
function modifier_mjz_centaur_return:IsPurgable()
	return false
end
function modifier_mjz_centaur_return:IsHidden()
	return true
end

if IsServer() then
	function modifier_mjz_centaur_return:OnCreated(table)
		self:StartIntervalThink(1.0)
	end

	function modifier_mjz_centaur_return:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local aura_enabled = GetTalentSpecialValueFor(ability, 'aura_enabled')
		local MODIFIER_AURA_NAME = 'modifier_mjz_centaur_return_aura'
		local MODIFIER_BUFF_NAME = 'modifier_mjz_centaur_return_buff'

		if aura_enabled > 0 then
			if not caster:HasModifier(MODIFIER_AURA_NAME) then
				caster:RemoveModifierByName(MODIFIER_BUFF_NAME)
				caster:AddNewModifier(caster, ability, MODIFIER_AURA_NAME, {})
			end
		else
			if not caster:HasModifier(MODIFIER_BUFF_NAME) then
				caster:AddNewModifier(caster, ability, MODIFIER_BUFF_NAME, {})
			end
		end
	end
end

----------------------------------------------------------------------------

modifier_mjz_centaur_return_aura = class({})

function modifier_mjz_centaur_return_aura:IsPurgable()
	return false
end
function modifier_mjz_centaur_return_aura:IsHidden()
	return true
end

------------------------------------------------

function modifier_mjz_centaur_return_aura:IsAura()
	return true
end

function modifier_mjz_centaur_return_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_mjz_centaur_return_aura:GetModifierAura()
    return "modifier_mjz_centaur_return_buff"
end

function modifier_mjz_centaur_return_aura:GetEffectName()
    return "particles/custom/aura_thorns.vpcf"
end

function modifier_mjz_centaur_return_aura:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
   
function modifier_mjz_centaur_return_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_mjz_centaur_return_aura:GetAuraEntityReject(target)
    return self:GetParent():IsIllusion()
end

function modifier_mjz_centaur_return_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_mjz_centaur_return_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_mjz_centaur_return_aura:GetAuraDuration()
    return 0.5
end

------------------------------------------------

----------------------------------------------------------------------------


modifier_mjz_centaur_return_buff = class({})

function modifier_mjz_centaur_return_buff:IsPurgable()
	return false
end
function modifier_mjz_centaur_return_buff:IsHidden()
	return false
end

if IsServer() then
	function modifier_mjz_centaur_return_buff:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_ATTACKED,
		}
	end

	function modifier_mjz_centaur_return_buff:OnAttacked(event)
		local target = event.target
		local attacker = event.attacker
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local caster = self:GetCaster()

		if target ~= parent then return nil end
		if attacker:GetTeamNumber() == parent:GetTeamNumber() then return nil end
		if parent:IsIllusion() then return nil end
		if caster:IsIllusion() then return nil end
		if caster:PassivesDisabled() then return nil end

		local p_name = "particles/units/heroes/hero_centaur/centaur_return.vpcf"
		local particle = ParticleManager:CreateParticle(p_name, PATTACH_CUSTOMORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle)

		ReturnDamage(caster, ability, attacker)
	end

	function ReturnDamage(caster, ability, attacker )
		local caster_str = caster:GetStrength()
		local str_return = GetTalentSpecialValueFor(ability, "strength_pct")
		local damage = ability:GetSpecialValueFor("return_damage")
	
		local return_damage = damage + caster_str * (str_return / 100.0)
		ApplyDamage({ 
			victim = attacker, attacker = caster, ability = ability, 
			damage = return_damage, damage_type = ability:GetAbilityDamageType() 
		})
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


-- 是否学习了天赋技能
function HasTalentSpecialValueFor(ability, value)
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
		return talent and talent:GetLevel() > 0 
    end
    return false
end


modifier_mjz_ember_spirit_sleight_of_fist_caster = class({})
local modifier_caster = modifier_mjz_ember_spirit_sleight_of_fist_caster

function modifier_caster:IsHidden() return true end
function modifier_caster:IsPurgable() return false end

function modifier_caster:CheckState()
    local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        --[MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_ROOTED] = true,
	}
    return state  
end

---------------------------------------------------------------------------------------

modifier_mjz_ember_spirit_sleight_of_fist_dummy = class({})
local modifier_dummy = modifier_mjz_ember_spirit_sleight_of_fist_dummy

function modifier_dummy:IsHidden() return true end
function modifier_dummy:IsPurgable() return false end

function modifier_dummy:CheckState()
    local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
    return state  
end

if IsServer() then
    function modifier_dummy:OnCreated(table)
        local parent = self:GetParent()
        local p_name = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_caster.vpcf"
        local remenantFx = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControlForward(remenantFx, 1, parent:GetForwardVector())
        self.remenantFx = remenantFx
    end

    function modifier_dummy:OnDestroy( )
        if self.remenantFx then
            ParticleManager:DestroyParticle(self.remenantFx, false)
            ParticleManager:ReleaseParticleIndex(self.remenantFx)
        end
    end
end

---------------------------------------------------------------------------------------

modifier_mjz_ember_spirit_sleight_of_fist_target = class({})
local modifier_target = modifier_mjz_ember_spirit_sleight_of_fist_target

function modifier_target:IsHidden() return true end
function modifier_target:IsPurgable() return false end

function modifier_target:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_targetted_marker.vpcf"
end
function modifier_target:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end


---------------------------------------------------------------------------------------

modifier_mjz_ember_spirit_sleight_of_fist_crit = class({})
local modifier_crit = modifier_mjz_ember_spirit_sleight_of_fist_crit

function modifier_crit:IsHidden() return true end
function modifier_crit:IsPurgable() return false end

if IsServer() then
    function modifier_crit:DeclareFunctions()
        local func = {
            MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
            MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        }
        return func
    end

    function modifier_crit:GetModifierPreAttack_BonusDamage()
        if self:GetAbility() then
            local base = self:GetAbility():GetSpecialValueFor("bonus_damage")
            local parent = self:GetParent()
            if parent:HasModifier("modifier_super_scepter") then
                local lvl = parent:GetLevel()
                base = base * lvl
            end    
    	    return base
        end
    end

    function modifier_crit:GetModifierPreAttack_CriticalStrike()
        local crit_chance = self:GetAbility():GetSpecialValueFor("crit_chance")
        local crit_bonus = self:GetAbility():GetSpecialValueFor("crit_bonus")
        local parent = self:GetParent()
        if parent:HasModifier("modifier_super_scepter") then
            local lvl = parent:GetLevel()
            crit_bonus = crit_bonus + (lvl * 45)
        end    
        if RollPercentage(crit_chance) then
            return crit_bonus
        end
    end
end

---------------------------------------------------------------------------------------

modifier_mjz_ember_spirit_sleight_of_fist_charge_counter = class({})
local modifier_charge_counter = modifier_mjz_ember_spirit_sleight_of_fist_charge_counter

function modifier_charge_counter:IsHidden()
    if self:GetStackCount() > 0 then
        return false
    end
    return true
end
function modifier_charge_counter:IsPurgable() return false end
function modifier_charge_counter:RemoveOnDeath() return false end

---------------------------------------------------------------------------------------

modifier_mjz_ember_spirit_sleight_of_fist_charge = class({})
local modifier_charge = modifier_mjz_ember_spirit_sleight_of_fist_charge

function modifier_charge:IsHidden() return false end
function modifier_charge:IsPurgable() return false end
function modifier_charge:RemoveOnDeath() return false end

-- function modifier_charge:GetAttributes()
--     return MODIFIER_ATTRIBUTE_MULTIPLE
-- end

if IsServer() then

    function modifier_charge:OnRefresh(table)
        local ability = self:GetAbility()
        local parent = self:GetParent()
        local current_charge = ability._current_charge or 0
        self:SetStackCount(current_charge)
    end

    function modifier_charge:OnCreated()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        local charge_count = GetTalentSpecialValueFor(ability, 'charge_count')
 
        self.m_name = 'modifier_mjz_ember_spirit_sleight_of_fist_charge_counter'
        parent:RemoveModifierByName(self.m_name)

        local current_charge = ability._current_charge or 0
        self:SetStackCount(current_charge)
    end

    function modifier_charge:OnDestroy()
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local charge_count = GetTalentSpecialValueFor(ability, 'charge_count')
        local charge_restore_time = ability:GetSpecialValueFor('charge_restore_time') * parent:GetCooldownReduction()
        local modifier_self = self:GetName()

        local new_charge_count = ability._current_charge + 1

        if new_charge_count < charge_count then
            ability._current_charge = new_charge_count
			parent:AddNewModifier(caster, ability, modifier_self, {duration = charge_restore_time})
        else
            ability._current_charge = charge_count
            if not parent:HasModifier(self.m_name) then
			    parent:AddNewModifier(caster, ability, self.m_name, {})
            end
            parent:SetModifierStackCount(self.m_name, caster, ability._current_charge)
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

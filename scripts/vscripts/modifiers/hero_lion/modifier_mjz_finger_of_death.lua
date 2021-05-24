LinkLuaModifier("modifier_mjz_finger_of_death_creature", "modifiers/hero_lion/modifier_mjz_finger_of_death.lua", LUA_MODIFIER_MOTION_NONE)


modifier_mjz_finger_of_death_bonus = class({})
function modifier_mjz_finger_of_death_bonus:IsBuff() return true end
function modifier_mjz_finger_of_death_bonus:IsPermanent() return true end
function modifier_mjz_finger_of_death_bonus:IsPurgable() return false end
function modifier_mjz_finger_of_death_bonus:RemoveOnDeath() return false end

function modifier_mjz_finger_of_death_bonus:DeclareFunctions()
    local funcs = {
            MODIFIER_PROPERTY_TOOLTIP
        }
    return funcs 
end
function modifier_mjz_finger_of_death_bonus:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("damage_per_kill") * self:GetStackCount()
end

---------------------------------------------------------------------------------

modifier_mjz_finger_of_death_creature = class({})
function modifier_mjz_finger_of_death_creature:IsHidden() return true end
function modifier_mjz_finger_of_death_creature:IsPermanent() return true end
function modifier_mjz_finger_of_death_creature:IsPurgable() return false end
function modifier_mjz_finger_of_death_creature:RemoveOnDeath() return false end

---------------------------------------------------------------------------------

modifier_mjz_finger_of_death_death = class({})
function modifier_mjz_finger_of_death_death:IsDebuff()
    return true
end
function modifier_mjz_finger_of_death_death:IsPurgable()	-- 能否被驱散
	return false
end

function modifier_mjz_finger_of_death_death:DeclareFunctions()
    local funcs = {
            MODIFIER_PROPERTY_TOOLTIP,
            MODIFIER_EVENT_ON_DEATH,
        }
    return funcs 
end

function modifier_mjz_finger_of_death_death:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("damage_per_kill")
end

function modifier_mjz_finger_of_death_death:OnDeath(event)
    if IsServer() then
        if event.unit == self:GetParent() then
            local unit = event.unit
            self:OnTargetDeath(unit)
        end
    end
end	

if IsServer() then
    function modifier_mjz_finger_of_death_death:OnTargetDeath( target )
        if target:IsIllusion() then return end

        local owner = self:GetCaster()
        local ability = self:GetAbility()
        local victim = target
        local can_charge = false

        if victim:IsRealHero() then
            can_charge = true
        else
            can_charge = self:OnCreatureDeath(victim)
        end

        if can_charge then
            local modifier_name = 'modifier_mjz_finger_of_death_bonus'
            local kill_count = owner:GetModifierStackCount(modifier_name, nil)
            kill_count = kill_count + 1
            
            SetModifierStackCount(owner, ability, modifier_name, kill_count)         
        end
    end

    function modifier_mjz_finger_of_death_death:OnCreatureDeath( target )
        local owner = self:GetCaster()
        local ability = self:GetAbility()
        local victim = target
        local can_charge = false
        local creature_enabled = ability:GetSpecialValueFor("creature_enabled")
        local creature_health = ability:GetSpecialValueFor("creature_health")
        local modifier_creature_name = 'modifier_mjz_finger_of_death_creature'

        if creature_enabled and creature_enabled > 0 then
            local victim_health = victim:GetMaxHealth()
            if victim_health > creature_health then
                can_charge = true
            else
                local creature_total = owner:GetModifierStackCount(modifier_creature_name, nil)

                if (creature_total + victim_health) > creature_health then
                    can_charge = true
                    creature_total = 0
                else
                    can_charge = false
                    creature_total = creature_total + victim_health
                end

                SetModifierStackCount(owner, ability, modifier_creature_name, creature_total)  
            end
        end
        return can_charge
    end
end

function SetModifierStackCount(owner, ability, modifier_name, count)
    if not owner:HasModifier(modifier_name) then
        owner:AddNewModifier(owner, ability, modifier_name, {})            
    end
    owner:SetModifierStackCount(modifier_name, owner, count)    
end
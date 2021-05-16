
--     modifier_undying_flesh_golem

function undying_attack( keys )

    local attacker = keys.attacker
    local target = keys.target
    local ability = keys.ability

    if IsInFleshGolemStatus(attacker) then
        ability:SetActivated(true)
        ability:MarkAbilityButtonDirty()
    else
        ability:SetActivated(false)
        ability:MarkAbilityButtonDirty()
        return nil
    end


    ability.hp_leech_percent = ability:GetLevelSpecialValueFor("hp_leech_percent", ability:GetLevel() - 1)
    local feast_modifier = keys.feast_modifier 

    local damage = attacker:GetHealth() * (ability.hp_leech_percent / 100)

    -- this sets the number of stacks of damage
    ability:ApplyDataDrivenModifier(attacker, attacker, feast_modifier, {})
    attacker:SetModifierStackCount(feast_modifier, ability, damage)
end

function undying_heal( keys )
	if not IsInFleshGolemStatus(keys.attacker) then return nil end

	local attacker = keys.attacker
	local target = keys.target
	local ability = keys.ability

	ability.hp_leech_percent = ability:GetLevelSpecialValueFor("hp_leech_percent", ability:GetLevel() - 1)
	local damage = attacker:GetHealth() * (ability.hp_leech_percent / 100)

	attacker:Heal(damage, ability)
end

function IsInFleshGolemStatus(unit)
	return unit and unit:HasModifier('modifier_undying_flesh_golem') 
end
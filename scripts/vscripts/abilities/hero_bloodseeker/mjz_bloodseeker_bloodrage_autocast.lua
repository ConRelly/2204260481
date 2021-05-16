
function Autocast( keys )
    if not IsServer() then return nil end

    local caster = keys.caster
    local ability = keys.ability

    local ability_bloodrage = caster:FindAbilityByName('bloodseeker_bloodrage')
    if ability_bloodrage and ability_bloodrage:IsFullyCastable() then
        if not caster:HasModifier('modifier_bloodseeker_bloodrage') then
            -- caster:AddNewModifier(caster, ability, 'modifier_bloodseeker_bloodrage', {}) 
            -- ability_bloodrage:StartCooldown(ability_bloodrage:GetCooldownTime())
        
            local order = {
                OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                UnitIndex = caster:entindex(),
                TargetIndex = caster:entindex(),
                AbilityIndex = ability_bloodrage:entindex()
            }
            ExecuteOrderFromTable(order)

        end 
    end
end
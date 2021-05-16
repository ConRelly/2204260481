
--Increases the stack count of Flesh Heap.
function StackCountIncrease( keys )
    local caster = keys.caster
    local ability = keys.ability
    local fleshHeapStackModifier = "modifier_meatboy_fleshheap"
    local currentStacks = caster:GetModifierStackCount(fleshHeapStackModifier, ability)

    caster:SetModifierStackCount(fleshHeapStackModifier, ability, (currentStacks + 1))
end

--Adjusts the strength provided by the modifiers on ability upgrade
function StrenghtHeapAdjust( keys )
    local caster = keys.caster
    local ability = keys.ability
    local fleshHeapModifier = "modifier_strenght_heap_bonus_datadriven"
    local fleshHeapStackModifier = "modifier_strenght_heap_collector"
    local currentStacks = caster:GetModifierStackCount(fleshHeapStackModifier, ability)

    -- Remove the old modifiers
    for i = 1, currentStacks do
        caster:RemoveModifierByName(fleshHeapModifier)
    end

    -- Add the same amount of new ones
    for i = 1, currentStacks do
        ability:ApplyDataDrivenModifier(caster, caster, fleshHeapModifier, {}) 
    end
end


function LightningShardConsume(keys)
    local caster = keys.caster
    local ability = keys.ability
	caster:EmitSound("Item.MoonShard.Consume")
    AddStacks(ability, caster, caster, "modifier_lightning_shard_consume", 1, true)
    local maxSpeed = GameRules:GetGameModeEntity():GetMaximumAttackSpeed()
    maxSpeed = maxSpeed * 105
    GameRules:GetGameModeEntity():SetMaximumAttackSpeed(maxSpeed + 50)
	caster:RemoveItem(ability)
end
function AddStacks(ability, caster, unit, modifier, stack_amount, refresh)
    if unit:HasModifier(modifier) then
        if refresh then ability:ApplyDataDrivenModifier(caster, unit, modifier, {}) end
        unit:SetModifierStackCount(modifier, ability, unit:GetModifierStackCount(modifier, nil) + stack_amount)
    else
        ability:ApplyDataDrivenModifier(caster, unit, modifier, {})
        unit:SetModifierStackCount(modifier, ability, stack_amount)
    end
end
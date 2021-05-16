


function QuickDraw( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local ability = event.ability
	local modifier_name = event.modifier_name
	local max_stacks = ability:GetLevelSpecialValueFor( "max_stacks" , ability:GetLevel() - 1  )

	local stack_count = caster:GetLevel()
	if stack_count > max_stacks then
		stack_count = max_stacks
	end

	local duration = -1
	local target = caster
	local modifier = caster:FindModifierByName(modifier_name)
	if modifier then
		target:SetModifierStackCount(modifier_name, caster, stack_count)
        modifier:SetDuration(duration, true)
	else
		ability:ApplyDataDrivenModifier(caster, target, modifier_name, { duration = duration })
        target:SetModifierStackCount(modifier_name, caster, 1) 
	end

end
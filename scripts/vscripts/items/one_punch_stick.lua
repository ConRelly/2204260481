function onepunch(keys)
	keys.target:EmitSound("Hero_Dark_Seer.NormalPunch.Lv3")
--[[
	if keys.target:GetTeamNumber() == keys.caster:GetTeamNumber() then
		damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL
	else
		damage_flags = DOTA_DAMAGE_FLAG_NONE
		keys.target:Kill(keys.ability, keys.caster)
	end
]]
	if not keys.caster:HasAbility("aghanim_blink2") then
		keys.caster:AddAbility("aghanim_blink2")
	end
	if not keys.target:HasModifier("modifier_nyx_assassin_vendetta_break") then
		keys.target:AddNewModifier(keys.caster, keys.ability, "modifier_nyx_assassin_vendetta_break", {duration = 5})
	end
--	keys.target:AddNewModifier(keys.caster, keys.ability, "modifier_stunned", {duration = 2})
--	ApplyDamage({victim = keys.target, attacker = keys.caster, ability = keys.ability, damage = keys.target:GetMaxHealth(), damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})
end
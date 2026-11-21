return function(ability)
	local caster = ability:GetCaster()
	local level = caster:GetLevel()
	if level > 100 then level = 100 + (level - 100) * 10 end
	local strengthRatio = ability:GetSpecialValueFor("effective_level_str_pct") / 100
	return caster:GetStrength() * level * strengthRatio
end

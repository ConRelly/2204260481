return function(caster)
	local level = caster:GetLevel()
	if level > 100 then level = 100 + (level - 100) * 10 end
	return 1 + level * 0.02
end

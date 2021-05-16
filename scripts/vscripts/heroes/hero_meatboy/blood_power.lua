

function BloodPowerProc( event )
	local damage = event.DamageTaken
	local caster = event.caster
	local ability = event.ability
	local duration = ability:GetSpecialValueFor("duration")
	local hp_proc = caster:GetMaxHealth()*ability:GetSpecialValueFor("hp_proc") / 100
	
	if caster.damage_taken == nil then
		caster.damage_taken = 0
	end
--	print(hp_proc)
--	print(caster.damage_taken)
	caster.damage_taken = caster.damage_taken + damage
	if caster.damage_taken > hp_proc then 
		caster.damage_taken = 0
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_meatboy_blood_power", {duration = duration})
		EmitSoundOn("hero_bloodseeker.bloodRage",caster)
	end

end


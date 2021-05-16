require("lib/timers")
require("lib/my")


custom_freezing_field_warning = class({})


function custom_freezing_field_warning:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	find_item(caster, "item_black_king_bar_boss"):CastAbility()
	find_item(caster, "item_black_king_bar_boss"):EndCooldown()
	local particle = ParticleManager:CreateParticle("particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova_g2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
	EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	Timers:CreateTimer(
		delay, 
		function()
			caster:CastAbilityNoTarget(caster:FindAbilityByName("custom_freezing_field"), -1)
			caster:FindAbilityByName("custom_freezing_field"):SetChanneling(true)
			caster:FindAbilityByName("custom_freezing_field"):EndCooldown()
		end
	)
end

require("lib/notifications")

if IsServer() then
	function OnSpellStart(keys)
		local hero = keys.caster
		local ability = keys.ability
		local unit = keys.unit

		if hero:HasModifier("modifier_arc_warden_tempest_double") then
			ability:SetActivated(false)
			return nil
		end
		if hero:IsRealHero() then
			--print("real hero check")
			local doomskill = hero:FindAbilityByName("temporary_slot_used")
			if doomskill == nil then return end
			local abilityName = doomskill:GetName()
			local number = doomskill:GetAbilityIndex()
			--print(number .. " index")
			if number > 6 and doomskill and doomskill:GetName() == "temporary_slot_used" then
				hero:RemoveAbility(abilityName)
				ability:SpendCharge()
			elseif (number == 3 or number == 4) and doomskill and doomskill:GetName() == "temporary_slot_used" then
				hero:RemoveAbility(abilityName)
				hero:AddAbility("generic_hidden")
				ability:SpendCharge()
			else
				Notifications:Top(PlayerResource:GetPlayer(hero:GetPlayerID()), {text="Move your empty skill first into a place higher then your last keybind (default is R) or into 4/5 ability place (default is D/F)", duration=5, style={color="red"}})
			end
		end
	end
end

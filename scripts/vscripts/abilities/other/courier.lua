require("lib/timers")

function courier_spell(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_courier_invincibility", {})
end

function courier_moveto(keys)
	local caster = keys.caster
	Timers:CreateTimer(
		0.5, 
		function()
			caster:SetAbsOrigin(Vector(-60000,-6000,0))
		end
	)

	-- caster:UpgradeToFlyingCourier()
	--PrintTable(caster)

	local playerID = caster:GetPlayerOwnerID()
	local player   = caster:GetPlayerOwner()
	-- player.origin_courier = caster
	-- print("Courier playerID: " .. playerID)

	local pID = #PLAYERS_COURIER + 1
	PLAYERS_COURIER[pID] = caster
end

function remove_courier(keys)
	keys.caster:RemoveSelf()
end
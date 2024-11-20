function OnUnequip(keys)
	local item = keys.ability
	local caster = keys.caster
	local vLocation = caster:GetAbsOrigin()
	local vRandomVector = RandomVector(50)
	local container = item:GetContainer()
	if container then
		container:SetRenderColor(139,69,13)
		item:LaunchLoot(false, 150, 0.5, vLocation + vRandomVector, nil)
	end
end

function CheckForStats(keys)
	local item = keys.ability
	local caster = keys.caster
	local vLocation = caster:GetAbsOrigin()
	if not caster:HasModifier("modifier_arc_warden_tempest_double")and caster:IsRealHero() then
		if 	caster:HasModifier("modifier_fire_rapier_passive_bonus") or
			caster:HasModifier("modifier_wind_rapier_passive_bonus") or
			caster:HasModifier("modifier_item_obsidian_rapier") or
			caster:HasModifier("modifier_item_imba_skadi") then

			GameRules:SendCustomMessage("#Game_notification_earth_rapier_request_message1",0,0)
			Timers:CreateTimer(0.001, function() caster:DropItemAtPositionImmediate(item, vLocation) end)
		end
	end
end

-- apply_modifier.lua
function ApplyEarthRapierBuff(event)
    local caster = event.caster
    local ability = event.ability
    local duration = ability:GetSpecialValueFor("buff_duration") 

    if caster and ability then
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_earth_rapier_buff", { duration = duration })
    end
end
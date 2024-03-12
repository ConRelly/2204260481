
require("libraries/replaystuff")
LinkLuaModifier("modifier_replay", "modifiers/modifier_replay.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_recording", "modifiers/modifier_recording.lua", LUA_MODIFIER_MOTION_NONE)


function StartRecordingVideo(keys)
	local caster = keys.caster
	local ability = keys.ability

	if not ability.isRecording then
		SetupPlayerClone(caster, ability)
		caster:AddNewModifier(caster, ability, "modifier_recording", {duration = 25})
		ability.isRecording = true
		ability.recordedActions = {}
	elseif caster:HasModifier("modifier_recording") then
		caster:RemoveModifierByName("modifier_recording")
	end
end


function PlayVideoFile(keys)
	PlayVideo(keys)
	local caster = keys.caster
	local ability = keys.ability
	local bonuscd = true
	ability:StartCooldown(50)
	
	if checkautocast(caster) then
		caster:TakeItem(ability)
		--caster:RemoveItem(ability)
		bonuscd = false
	end	
	startcool(caster, bonuscd)
end

function checkautocast(caster)
	if caster:HasAbility("obs_replay") then
		local ability = caster:FindAbilityByName("obs_replay")
		if ability:GetAutoCastState() then
			return false
		end	
	end
	return true	
end

function startcool(caster, bonuscd)
	if caster:HasAbility("obs_replay") then
		local ability = caster:FindAbilityByName("obs_replay")
		local extra = 1
		local cd = ability.recordTime 
		ability:EndCooldown()
		if bonuscd then
			cd = 50
		end
	
		ability:StartCooldown(cd)
	end	

end	
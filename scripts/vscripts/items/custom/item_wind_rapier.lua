LinkLuaModifier("modifier_wind_rapier_agility_buff", "items/custom/item_wind_rapier.lua", LUA_MODIFIER_MOTION_NONE)

function OnUnequip(keys)
	local item = keys.ability
	local caster = keys.caster
	local vLocation = caster:GetAbsOrigin()
	local vRandomVector = RandomVector(50)
	local container = item:GetContainer()
	if container then
		container:SetRenderColor(192,192,192)
		item:LaunchLoot(false, 150, 0.5, vLocation + vRandomVector, nil)
	end
end

function CheckForStats (keys)
	local item = keys.ability
	local caster = keys.caster
	local vLocation = caster:GetAbsOrigin()
	
	local stats_required = item:GetSpecialValueFor("stats_required")
--	GameRules:SendCustomMessage("stats_required:"..stats_required,0,0)
	local item_stats_sum = item:GetSpecialValueFor("rapier_str") + item:GetSpecialValueFor("rapier_agi") + item:GetSpecialValueFor("rapier_int")
	local stats_sum = caster:GetStrength() + caster:GetAgility() + caster:GetIntellect(false)
	local hero_stats_sum = stats_sum - item_stats_sum
	
--	GameRules:SendCustomMessage("stats_sum:"..stats_sum,0,0)
--	GameRules:SendCustomMessage("item_stats_sum:"..item_stats_sum,0,0)
--	GameRules:SendCustomMessage("hero_stats_sum:"..hero_stats_sum,0,0)
	
	if not caster:HasModifier("modifier_arc_warden_tempest_double")and caster:IsRealHero() then
		--[[if stats_required > hero_stats_sum then
			Timers:CreateTimer(0.001, function() caster:DropItemAtPositionImmediate(item, vLocation) end)
			GameRules:SendCustomMessage("#Game_notification_wind_rapier_request_message",0,0)	
			GameRules:SendCustomMessage("<font color='#FFD700'>NOT ENOUGH </font><font color='#C0C0C0'>".. stats_required-hero_stats_sum .."</font>",0,0)	
			
		end]]
		
		if 	caster:HasModifier("modifier_fire_rapier_passive_bonus") or
			caster:HasModifier("modifier_earth_rapier_passive_bonus") or
			caster:HasModifier("modifier_item_imba_skadi") then

			GameRules:SendCustomMessage("#Game_notification_wind_rapier_request_message1",0,0)
			Timers:CreateTimer(0.001, function() caster:DropItemAtPositionImmediate(item, vLocation) end)
		end
	end
end

function WindRapierProc(keys)
	if not IsServer() then return end
	local caster = keys.caster
	local ability = keys.ability
	local max_stacks = ability:GetSpecialValueFor("max_stacks")
	local StackModifier = "modifier_wind_rapier_agility_buff"
	local currentStacks = caster:GetModifierStackCount(StackModifier, ability)
	local agility = caster:GetAgility()
	local buff_duration = ability:GetSpecialValueFor("stack_duration")
	local proc_bonus = ability:GetSpecialValueFor("proc_bonus")
	local agility_gain = proc_bonus * 0.01 * agility
	caster:AddNewModifier(caster, ability, StackModifier, {Duration = buff_duration, agility_gain = agility_gain})
	if currentStacks <= (max_stacks - 1) then
		caster:SetModifierStackCount(StackModifier, ability, (currentStacks + 1))
--	else
--		caster:SetModifierStackCount(StackModifier, ability, (max_stacks))
	end
end

--------------------------------------------------------------------------------
modifier_wind_rapier_agility_buff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return false end,
	IsBuff         = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	DeclareFunctions		= function(self) return 
		{--	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end,
})
-------------------------------------------
function modifier_wind_rapier_agility_buff:OnCreated(params)
	if not IsServer() then return end
	self.agility_gain = params.agility_gain
end
--[[
function modifier_wind_rapier_agility_buff:GetModifierAttackSpeedBonus_Constant()
	return -self:GetStackCount()*self.agility_gain
end
]]
function modifier_wind_rapier_agility_buff:GetModifierBonusStats_Agility() return self:GetStackCount() * self.agility_gain end


require("libraries/replaystuff")
LinkLuaModifier("modifier_replay", "abilities/custom/obs_replay.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_replay_thinker", "abilities/custom/obs_replay.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_recording", "abilities/custom/obs_replay.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_obs_replay", "abilities/custom/obs_replay.lua", LUA_MODIFIER_MOTION_NONE)
obs_replay = obs_replay or class({})
function obs_replay:GetIntrinsicModifierName() return "modifier_obs_replay" end
function obs_replay:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self
	if ability:GetAutoCastState() and replaycheck(caster) then
		playfirst(caster)
		if caster:HasModifier("modifier_recording") then
			caster:RemoveModifierByName("modifier_recording")
		end
	elseif replaycheck(caster) then
		playfirst(caster)
		if caster:HasModifier("modifier_recording") then
			caster:RemoveModifierByName("modifier_recording")
		end
	elseif not ability.isRecording then
		SetupPlayerClone(caster, ability)
		caster:AddNewModifier(caster, ability, "modifier_recording", {duration = 25})
		ability.isRecording = true
		ability.recordedActions = {}
	elseif caster:HasModifier("modifier_recording") then
		caster:RemoveModifierByName("modifier_recording")
	end
end

if IsServer() then
	function replaycheck(unit)
		for itemSlot = 0, 15 do
			local Item = unit:GetItemInSlot(itemSlot)
			if Item ~= nil then
				if (Item:GetName() == "item_video_file") then
					--Item:OnSpellStart()
					return true
				end
			end
		end
	end
	function playfirst(unit)
		for itemSlot = 0, 15 do
			local Item = unit:GetItemInSlot(itemSlot)
			if Item ~= nil then
				if Item:GetName() == "item_video_file" then
					Item:OnSpellStart()
					return
				end
			end
		end
	end
end
--[[
function modifier_obs_replay:PlayVideoFile(keys)
	PlayVideo(keys)
	local caster = keys.caster
	local ability = keys.ability

	ability:StartCooldown(ability.recordTime * 2)
 
	caster:RemoveItem(ability)

end
]] 


modifier_obs_replay = modifier_obs_replay or class({})
--function modifier_obs_replay:IsPermanent() return true end
function modifier_obs_replay:RemoveOnDeath() return false end
function modifier_obs_replay:IsHidden() return false end	-- we can hide the modifier
function modifier_obs_replay:IsDebuff() return true end	-- make it red or green
function modifier_obs_replay:IsPurgable() return false end
function modifier_obs_replay:AllowIllusionDuplicate() return true end
--function modifier_obs_replay:GetTexture() return "obs_studio1" end
function modifier_obs_replay:OnCreated()
	if not IsServer() then return end
	local parent = self:GetParent()
	local modifier = "modifier_obs_replay"
	if parent:HasModifier(modifier) then
		local time = GameRules:GetGameTime() / 60
		if time > 1 then
			local mbuff = parent:FindModifierByName(modifier)	
			local stack = math.floor(time * 15)
			mbuff:SetStackCount(stack)
		end
	end
	if parent:IsIllusion() or parent:HasModifier("modifier_arc_warden_tempest_double") then
	-- print("ilusion")
		local mod1 = "modifier_obs_replay"
		local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
		if owner then	  
			if parent:HasModifier(mod1) then
				local modifier1 = parent:FindModifierByName(mod1)
				if owner:HasModifier(mod1) then
					local modifier2 = owner:FindModifierByName(mod1)
					modifier1:SetStackCount(modifier2:GetStackCount())
				end	
			end
		end
	end
end
function modifier_obs_replay:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_obs_replay:GetModifierBonusStats_Strength() return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("str_stack") end
function modifier_obs_replay:GetModifierBonusStats_Agility() return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("agi_stack") end
function modifier_obs_replay:GetModifierBonusStats_Intellect() return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("int_stack") end


modifier_recording = modifier_recording or class({})
function modifier_recording:IsPermanent() return true end
function modifier_recording:RemoveOnDeath() return false end
function modifier_recording:IsHidden() return false end
function modifier_recording:IsDebuff() return false end
function modifier_recording:IsPurgable() return false end
function modifier_recording:GetEffectName() return "particles/custom/record_button.vpcf" end
function modifier_recording:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_recording:DeclareFunctions() return {MODIFIER_EVENT_ON_ORDER} end
function modifier_recording:OnOrder(event)
	if event.unit == self:GetParent() then 
		AddRecordedAction(self, event)
	end
end
function modifier_recording:OnDestroy(event)
	if not IsServer() then return end

	local modifier = self
	local time = modifier:GetDuration() - modifier:GetRemainingTime()

	local parent = self:GetParent()
	local ability = self:GetAbility()
	ability.recordTime = time
	
	--print("Recording stopped with duration " .. time)

	local newItem = CreateItem("item_video_file", parent, parent)
	newItem.cloneData = ability.cloneData
	newItem.recordedActions = ability.recordedActions
	newItem.recordTime = ability.recordTime
	parent:AddItem(newItem)
	newItem:SetPurchaseTime(-10)

	--ability:StartCooldown(ability.recordTime)
	ability.isRecording = false
	ability.recordedActions = {}
end


modifier_replay = modifier_replay or class({})
function modifier_replay:IsPermanent() return true end
function modifier_replay:RemoveOnDeath() return false end
function modifier_replay:IsHidden() return false end
function modifier_replay:IsDebuff() return false end
function modifier_replay:IsPurgable() return false end
function modifier_replay:GetTexture() return "item_video_file" end
function modifier_replay:GetEffectName() return "particles/custom/play_button.vpcf" end
function modifier_replay:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_replay:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_COMMAND_RESTRICTED] = true}
end
function modifier_replay:DeclareFunctions() return {MODIFIER_PROPERTY_CASTTIME_PERCENTAGE} end
function modifier_replay:GetModifierPercentageCasttime() return 100 end
function modifier_replay:OnCreated()
	if IsServer() then
		local parent = self:GetParent()
		if parent and not parent:IsNull() and parent:IsIllusion() then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_replay_thinker", {})
		end
	end
end
function modifier_replay:OnDestroy() 
	if not IsServer() then return end
	local parent = self:GetParent()
	if not parent:IsNull() and parent:IsAlive() then 
		parent:AddNewModifier(parent, nil, "modifier_illusion", {duration = 1})
		parent:ForceKill(false)
	end
end


modifier_replay_thinker = class({})
function modifier_replay_thinker:IsHidden() return true end
function modifier_replay_thinker:IsPurgable() return false end
function modifier_replay_thinker:OnCreated()
	if not IsServer() then return end
	self.parent = self:GetParent()
end

function modifier_replay_thinker:DeclareFunctions()
	if not IsServer() then return end
	return {
		--MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_EVENT_ON_DEATH,
	}
end
function modifier_replay_thinker:OnAbilityExecuted(keys)
	if not IsServer() then return end
	if keys.unit ~= self.parent and keys.ability:GetCooldown(keys.ability:GetLevel()) > 7 then
		self.allowcount = true 
	end

	if keys.unit == self.parent and keys.ability:GetCooldown(keys.ability:GetLevel()) > 8 and self.allowcount then
		local parent = self:GetParent()
		if parent:IsIllusion() then
			local extra_staks = math.floor(keys.ability:GetCooldown(keys.ability:GetLevel()) / 7)
			local mod1 = "modifier_obs_replay"
		-- print("ilusion")
			local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
			if owner then	  
				if parent:HasModifier("modifier_replay_thinker") then
					if parent:HasModifier("modifier_underdog") then
						extra_staks = extra_staks + 1
					end
					--local modifier1 = parent:FindModifierByName(mod1)
					if owner:HasModifier(mod1) then
						local modifier2 = owner:FindModifierByName(mod1)
						modifier2:SetStackCount(modifier2:GetStackCount() + extra_staks)
					end	
					self.allowcount = false
				end
			end
		end
	end
end
function modifier_replay_thinker:OnDeath(event)
	if not IsServer() then return end
	if event.attacker ~= self:GetParent() then return end

	local caster = self:GetCaster()
	--local ability = self:GetAbility()
	local hVictim = event.unit
	local hKiller = event.attacker
	self:OnEnemyDied(hVictim, hKiller, event)
end
function modifier_replay_thinker:OnEnemyDied(hVictim, hKiller, kv)
	if not IsServer() then return end
	if hVictim == nil or hKiller == nil or hVictim:IsIllusion() then
		return
	end
	if hVictim:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS then
		return
	end

	local parent = self:GetParent()

	if parent:IsIllusion() then
		local mod1 = "modifier_obs_replay"
		local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
		if owner then
			local neutral_kills = 1
			if parent:HasModifier("modifier_replay_thinker") then
				if parent:HasModifier("modifier_underdog") then
					neutral_kills = neutral_kills + 1
				end
				if owner:HasModifier(mod1) then	
					local modifier2 = owner:FindModifierByName(mod1)
					modifier2:SetStackCount(modifier2:GetStackCount() + neutral_kills)
				end	
			end
		end
	end
end

--[[
function modifier_replay:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_MODIFIER_ADDED,
	}
end

function modifier_replay:OnTakeDamage(event)
	if event.unit == self:GetParent() then 
		for k,v in pairs(event) do 
			print(k,v)
		end
	end
end


function modifier_replay:OnModifierAdded(event)
	if event.unit == self:GetParent() then 
		for k,v in pairs(event) do 
			print(k,v)
		end
	end
end
]]

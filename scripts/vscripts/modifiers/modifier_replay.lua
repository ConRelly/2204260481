--require("libraries/replaystuff")

LinkLuaModifier("modifier_replay", "modifiers/modifier_replay.lua", LUA_MODIFIER_MOTION_NONE)
modifier_replay = modifier_replay or class({})

function modifier_replay:IsPermanent() return true end
function modifier_replay:RemoveOnDeath() return false end
function modifier_replay:IsHidden() return false end 	-- we can hide the modifier
function modifier_replay:IsDebuff() return false end 	-- make it red or green
function modifier_replay:IsPurgable() return false end
function modifier_replay:GetTexture() return "item_video_file" end


function modifier_replay:GetEffectName() return "particles/custom/play_button.vpcf" end
function modifier_replay:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end


function modifier_replay:CheckState() 
	local states = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}

	return states
end


function modifier_replay:DeclareFunctions()
    --if IsServer() then
    local funcs = {
        MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
         
    }
    return funcs
    --end    
end
function modifier_replay:GetModifierPercentageCasttime()
    return 100
end 


function modifier_replay:OnCreated()
	if IsServer() then
		local parent = self:GetParent()

		if parent and parent:IsIllusion() then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_replay_thinker", {})
		end
	end
end

function modifier_replay:OnDestroy() 
	if not IsServer() then return end

	local parent = self:GetParent()

	if parent:IsAlive() then 
		parent:AddNewModifier(parent, nil, "modifier_illusion", {duration = 1})
		parent:ForceKill(false)
	end

end

LinkLuaModifier("modifier_replay_thinker", "modifiers/modifier_replay.lua", LUA_MODIFIER_MOTION_NONE)

modifier_replay_thinker = class({})


function modifier_replay_thinker:IsHidden()
    return true
end

function modifier_replay_thinker:IsPurgable()
	return false
end

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
						modifier2:SetStackCount(modifier2:GetStackCount() + extra_staks )
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



function modifier_replay_thinker:OnEnemyDied( hVictim, hKiller, kv )
	if not IsServer() then return end
	if hVictim == nil or hKiller == nil or hVictim:IsIllusion()  then
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
				local modifier2 = owner:FindModifierByName(mod1)
				modifier2:SetStackCount(modifier2:GetStackCount() + neutral_kills )
			end    
		end    
	end
end


-- function modifier_replay:DeclareFunctions()
-- 	local funcs = {
-- 		MODIFIER_EVENT_ON_TAKEDAMAGE,
-- 		MODIFIER_EVENT_ON_MODIFIER_ADDED,
-- 	}

-- 	return funcs
-- end

-- function modifier_replay:OnTakeDamage(event)
-- 	if event.unit == self:GetParent() then 
-- 		for k,v in pairs(event) do 
-- 			print(k,v)
-- 		end
-- 	end
-- end


-- function modifier_replay:OnModifierAdded(event)
-- 	if event.unit == self:GetParent() then 
-- 		for k,v in pairs(event) do 
-- 			print(k,v)
-- 		end
-- 	end
-- end
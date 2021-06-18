require("lib/mys")
item_aegis_lua = class({})
LinkLuaModifier("modifier_aegis", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aegis_up", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aegis_buff", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)
-- Link a lua-defined modifier with the associated class (className, fileName, LuaModifierType).

local ReincarnateTime = 7					-- Seconds
local ReincarnateBuffTime = 14				-- Seconds
local AegisBuffDMGIncoming = 85 * (-1)		-- % Incoming Damage
local AegisBuffDMGOutgoing = 25				-- % Outgoing Damage
--[[
function item_aegis_lua:GetIntrinsicModifierName() return "modifier_aegis_up" end
modifier_aegis_up = class({})
function modifier_aegis_up:IsHidden() return true end
function modifier_aegis_up:IsPurgable() return false end
function modifier_aegis_up:RemoveOnDeath() return false end
function modifier_aegis_up:OnCreated()
	if IsServer() then self:StartIntervalThink(FrameTime()) end
end
function modifier_aegis_up:OnIntervalThink()
	if IsServer() then
		if self:GetAbility():GetCurrentCharges() >= self:GetAbility():GetSpecialValueFor("aegis_up") then
			self:GetCaster():RemoveItem(self:GetAbility())
			self:GetCaster():AddItemByName("item_inf_aegis")
		end
	end
end
]]
function item_aegis_lua:OnSpellStart()
	if IsServer() then
		local hCaster = self:GetCaster()
		local hPlayer = hCaster:GetPlayerOwner()
		if hCaster and hCaster:IsRealHero() and not hCaster:IsTempestDouble() and not hCaster:HasModifier("modifier_arc_warden_tempest_double_lua") then
			if self:GetCurrentCharges() >= self:GetSpecialValueFor("aegis_up") then
				hCaster:RemoveItem(self)
				hCaster:AddItemByName("item_inf_aegis")
				return
			end
			if hCaster:HasModifier("modifier_aegis") then
				local hModifierAegis = hCaster:FindModifierByName("modifier_aegis")
				local nCurrentStack = hModifierAegis:GetStackCount()
				hModifierAegis:SetStackCount(nCurrentStack+1)
			else
				local hModifierAegis = hCaster:AddNewModifier(hCaster, nil, "modifier_aegis", {})
				hModifierAegis:SetStackCount(1)
			end
			self:SpendCharge()
			EmitSoundOn("DOTA_Item.Refresher.Activate", hCaster)
			local nParticle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
			ParticleManager:ReleaseParticleIndex(nParticle)
		end
	end
end
modifier_aegis = class({})
function modifier_aegis:IsHidden() return (self:GetStackCount()<=0) end
function modifier_aegis:GetTexture() return "item_aegis" end
function modifier_aegis:IsPermanent() return true end
function modifier_aegis:IsPurgable() return false end
function modifier_aegis:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_REINCARNATION}
end
function modifier_aegis:ReincarnateTime()
	local nPlayerID
	if self:GetParent().GetPlayerOwnerID then
		nPlayerID = self:GetParent():GetPlayerOwnerID()
	end

	local nTeamID = PlayerResource:GetTeam(nPlayerID)

	if nPlayerID and nTeamID and PlayerResource:GetConnectionState(nPlayerID) == DOTA_CONNECTION_STATE_ABANDONED and GameRules.teamAbandonMap[nTeamID] then
		return nil
	end

	if self:GetStackCount()<=0 then
		return nil
	end

	if true~=self:GetParent().bJoiningPvp then
		return ReincarnateTime
	else
		return nil
	end
end
function modifier_aegis:GetModifierIncomingDamage_Percentage(params)
	local nPlayerID
	if self:GetParent().GetPlayerOwnerID then
		nPlayerID = self:GetParent():GetPlayerOwnerID()
	end

	local nTeamID = PlayerResource:GetTeam(nPlayerID)

	if nPlayerID and nTeamID and PlayerResource:GetConnectionState(nPlayerID) == DOTA_CONNECTION_STATE_ABANDONED and GameRules.teamAbandonMap[nTeamID] then
		return 5000
	else
		return 0
	end
end
function modifier_aegis:OnDeath(keys)
	if IsServer() then
		if keys.unit == self:GetParent() then
			if not Util:IsReincarnationWork(self:GetParent()) and self:GetStackCount()>=1 then
				local hCaster = self:GetParent()
				local hAbility = self:GetAbility()
				Timers:CreateTimer({
						endTime = ReincarnateTime,
						callback = function()
						 local nParticle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
						 ParticleManager:SetParticleControl(nParticle, 1, Vector(0, 0, 0))
						 ParticleManager:SetParticleControl(nParticle, 3, hCaster:GetAbsOrigin())
						 ParticleManager:ReleaseParticleIndex(nParticle)
					end
				})
				Timers:CreateTimer({
						endTime = ReincarnateTime+0.11, 
						callback = function()
						hCaster:AddNewModifier(hCaster, hAbility, "modifier_aegis_buff", {duration = ReincarnateBuffTime})
					end
				})
				local nStackCount = self:GetStackCount()
				self:SetStackCount(nStackCount-1)
			end
		end
	end
end

modifier_aegis_buff = class({})
function modifier_aegis_buff:IsDebuff() return false end
function modifier_aegis_buff:GetTexture() return "omniknight_repel" end
function modifier_aegis_buff:IsPurgable() return false end
function modifier_aegis_buff:IsHidden() return false end
function modifier_aegis_buff:OnCreated(table)
	if not IsServer() then return nil end
	local parent = self:GetParent()
	Timers:CreateTimer({
		endTime = 0.01,
		callback = function()
			if parent ~= nil and not parent:IsIllusion() then
				local nWingsParticleIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControl(nWingsParticleIndex, 0, self:GetParent():GetAbsOrigin())
				ParticleManager:SetParticleControlEnt(nWingsParticleIndex, 5, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
				self:AddParticle(nWingsParticleIndex, false, false, -1, false, false)
				-- Halo particle
				local nHaloParticleIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_guardian_angel_halo_buff.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
				--ParticleS(parent)
				ParticleManager:SetParticleControlEnt(nHaloParticleIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
				self:AddParticle(nHaloParticleIndex, false, false, -1, false, false)
			end
		end
	})
end
function modifier_aegis_buff:DeclareFunctions()
 return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_aegis_buff:GetModifierIncomingDamage_Percentage() return AegisBuffDMGIncoming end
function modifier_aegis_buff:GetModifierTotalDamageOutgoing_Percentage() return AegisBuffDMGOutgoing end

local FormatScriptError = require("lib/script_error")
item_aegis_lua = class({})
LinkLuaModifier("modifier_aegis", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aegis_up", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aegis_buff", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)
-- Link a lua-defined modifier with the associated class (className, fileName, LuaModifierType).

local ReincarnateTime = 7					-- Seconds
local ReincarnateBuffTime = 14				-- Seconds
local AegisBuffDMGIncoming = 85				-- % Incoming Damage
local AegisBuffDMGOutgoing = 25				-- % Outgoing Damage

function item_aegis_lua:GetCooldown(level)
	return self.BaseClass.GetCooldown(self, level) / self:GetCaster():GetCooldownReduction()
end
function item_aegis_lua:OnSpellStart()
	if IsServer() then
		local hCaster = self:GetCaster()
		local hPlayer = hCaster:GetPlayerOwner()
		if hCaster and hCaster:IsRealHero() and not hCaster:IsTempestDouble() and not hCaster:HasModifier("modifier_arc_warden_tempest_double_lua") then
			if self:GetCurrentCharges() >= self:GetSpecialValueFor("aegis_up") then
				--hCaster:RemoveItem(self)
				hCaster:TakeItem(self)
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
			self:SpendCharge(0.01)
			EmitSoundOn("DOTA_Item.Refresher.Activate", hCaster)
			local nParticle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
			ParticleManager:ReleaseParticleIndex(nParticle)
		end
	end
end
function item_aegis_lua:OnSpellStart_skill(caster)
	if IsServer() then
		local hCaster = caster
		local hPlayer = hCaster:GetPlayerOwner()
		if hCaster and hCaster:IsRealHero() and not hCaster:IsTempestDouble() and not hCaster:HasModifier("modifier_arc_warden_tempest_double_lua") then
			--create an 1s internal cooldown
			if not self.timer_limit then
				self.timer_limit = GameRules:GetGameTime() + 1
			elseif GameRules:GetGameTime() < self.timer_limit then
				print("CD: "..self.timer_limit-GameRules:GetGameTime().."s")
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
			self.timer_limit = GameRules:GetGameTime() + 1
			self:SpendCharge(0.01)
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
	return {MODIFIER_PROPERTY_REINCARNATION, MODIFIER_EVENT_ON_RESPAWN}
end

local function PlayAegisReincarnation(hero, delay)
	local position = hero:GetAbsOrigin()
	local deathFX = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	ParticleManager:SetParticleAlwaysSimulate(deathFX)
	ParticleManager:SetParticleControl(deathFX, 0, position)
	ParticleManager:SetParticleControl(deathFX, 1, Vector(delay, 0, 0))
	ParticleManager:SetParticleControl(deathFX, 11, Vector(200, 0, 0))
	ParticleManager:ReleaseParticleIndex(deathFX)
	local timerFX = ParticleManager:CreateParticle("particles/items_fx/aegis_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	ParticleManager:SetParticleControl(timerFX, 1, Vector(0, 0, 0))
	ParticleManager:SetParticleControl(timerFX, 3, position)
	ParticleManager:ReleaseParticleIndex(timerFX)
	local vision = GameRules:IsDaytime() and hero:GetDayTimeVisionRange() or hero:GetNightTimeVisionRange()
	AddFOWViewer(hero:GetTeamNumber(), position, vision, delay, true)
	hero:EmitSound("Aegis.Timer")
end

function modifier_aegis:ReincarnateTime()
	if not IsServer() then return end
	local hero = self:GetParent()
	if not hero:IsRealHero() or hero:IsReincarnating() or hero:GetHealth() >= 1 then return end
	local now = GameRules:GetGameTime()
	if self.reincarnationAt == now then return self.reincarnationDelay end

	local delay
	local fromInfinity = false
	if self:GetStackCount() > 0 then
		delay = _G._playerNumber and _G._playerNumber < 2 and 5 or ReincarnateTime
		self:DecrementStackCount()
	else
		local infinity = hero:FindModifierByName("modifier_inf_aegis")
		if not infinity then return end
		delay = infinity:TryReincarnate()
		if not delay then return end
		fromInfinity = true
	end
	self.fromInfinity = fromInfinity
	self.reincarnationAt = now
	self.reincarnationDelay = delay

	-- Cosmetic errors must not prevent the engine from receiving the delay.
	local ok, err = pcall(PlayAegisReincarnation, hero, delay)
	if not ok then
		print("[Aegis] Reincarnation effects failed: " .. FormatScriptError(err))
	end
	return delay
end

function modifier_aegis:OnRespawn(keys)
	if not IsServer() or keys.unit ~= self:GetParent() or not self.reincarnationDelay then return end
	local hero = keys.unit
	local fromInfinity = self.fromInfinity
	self.reincarnationAt = nil
	self.reincarnationDelay = nil
	self.fromInfinity = nil
	if fromInfinity then
		local stats = hero:FindModifierByName("modifier_inf_aegis_stats")
		if stats then stats:AddResurrectionStack() end
	end
	hero:AddNewModifier(hero, nil, "modifier_aegis_buff", {duration = ReincarnateBuffTime})
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

modifier_aegis_buff = class({})
function modifier_aegis_buff:IsDebuff() return false end
function modifier_aegis_buff:GetTexture() return "omniknight_repel" end
function modifier_aegis_buff:IsPurgable() return false end
function modifier_aegis_buff:IsHidden() return false end
function modifier_aegis_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
local function AddAegisProtectionEffects(modifier, hero)
	local position = hero:GetAbsOrigin()
	local wings = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	modifier:AddParticle(wings, false, false, -1, false, false)
	ParticleManager:SetParticleControl(wings, 0, position)
	ParticleManager:SetParticleControlEnt(wings, 5, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", position, true)
	local halo = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_guardian_angel_halo_buff.vpcf", PATTACH_OVERHEAD_FOLLOW, hero)
	modifier:AddParticle(halo, false, false, -1, false, false)
	ParticleManager:SetParticleControl(halo, 0, position)
	ParticleManager:SetParticleControlEnt(halo, 5, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", position, true)
end

function modifier_aegis_buff:OnCreated()
	if not IsServer() then return end
	local hero = self:GetParent()
	if not hero or hero:IsNull() or hero:IsIllusion() then return end
	local ok, err = pcall(AddAegisProtectionEffects, self, hero)
	if not ok then print("[Aegis Protection] Effects failed: " .. FormatScriptError(err)) end
end
function modifier_aegis_buff:DeclareFunctions()
 return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_aegis_buff:GetModifierIncomingDamage_Percentage() return AegisBuffDMGIncoming * (-1) end
function modifier_aegis_buff:GetModifierTotalDamageOutgoing_Percentage() return AegisBuffDMGOutgoing end

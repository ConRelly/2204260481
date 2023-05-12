item_aegis_lua = class({})
LinkLuaModifier("modifier_aegis", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aegis_up", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aegis_buff", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)
-- Link a lua-defined modifier with the associated class (className, fileName, LuaModifierType).

local ReincarnateTime = 7					-- Seconds
local ReincarnateBuffTime = 14				-- Seconds
local AegisBuffDMGIncoming = 85				-- % Incoming Damage
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
	return {MODIFIER_PROPERTY_REINCARNATION}
end
function modifier_aegis:OnCreated()
	if IsServer() then
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
	end
end
function modifier_aegis:ReincarnateTime()
	if IsServer() then
		if self.caster:IsRealHero() and not self.caster:IsReincarnating() then
			if self.caster:GetHealth() < 1 then
				if self:GetStackCount() >= 1 then
					if _G._playerNumber and _G._playerNumber < 2 then
						ReincarnateTime = 5
					end	
					particle_death_fx = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
					ParticleManager:SetParticleAlwaysSimulate(particle_death_fx)
					ParticleManager:SetParticleControl(particle_death_fx, 0, self.caster:GetAbsOrigin())
					ParticleManager:SetParticleControl(particle_death_fx, 1, Vector(ReincarnateTime, 0, 0))
					ParticleManager:SetParticleControl(particle_death_fx, 11, Vector(200, 0, 0))
					ParticleManager:ReleaseParticleIndex(particle_death_fx)
					particle_aegis_timer = ParticleManager:CreateParticle("particles/items_fx/aegis_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
					ParticleManager:SetParticleControl(particle_aegis_timer, 1, Vector(0, 0, 0))
					ParticleManager:SetParticleControl(particle_aegis_timer, 3, self.caster:GetAbsOrigin())
					ParticleManager:ReleaseParticleIndex(particle_aegis_timer)
					if GameRules:IsDaytime() then
						AddFOWViewer(self.caster:GetTeamNumber(), self.caster:GetAbsOrigin(), self.caster:GetDayTimeVisionRange(), ReincarnateTime, true)
					else
						AddFOWViewer(self.caster:GetTeamNumber(), self.caster:GetAbsOrigin(), self.caster:GetNightTimeVisionRange(), ReincarnateTime, true)
					end
					self.caster:EmitSound("Aegis.Timer")
					Timers:CreateTimer(ReincarnateTime + 0.08, function()
						if self.caster and not self.caster:IsNull() then
							self.caster:AddNewModifier(self.caster, nil, "modifier_aegis_buff", {duration = ReincarnateBuffTime})
							--self.caster:AddNewModifier(self.caster, nil, "modifier_aegis_buff", {duration = 3})
						end	
					end)
					self:SetStackCount(self:GetStackCount() - 1)
					return ReincarnateTime
				end
			end
		end
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

modifier_aegis_buff = class({})
function modifier_aegis_buff:IsDebuff() return false end
function modifier_aegis_buff:GetTexture() return "omniknight_repel" end
function modifier_aegis_buff:IsPurgable() return false end
function modifier_aegis_buff:IsHidden() return false end
function modifier_aegis_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_aegis_buff:OnCreated(table)
	if not IsServer() then return nil end
	local parent = self:GetParent()
	--Timers:CreateTimer(0.01, function()
		if parent ~= nil and not parent:IsNull() and not parent:IsIllusion() and not parent:IsNull() then
			if self:GetParent():IsNull() then return end
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
	--end)
end
function modifier_aegis_buff:DeclareFunctions()
 return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_aegis_buff:GetModifierIncomingDamage_Percentage() return AegisBuffDMGIncoming * (-1) end
function modifier_aegis_buff:GetModifierTotalDamageOutgoing_Percentage() return AegisBuffDMGOutgoing end

require("lib/data")
local PendantDelay = require("abilities/other/courier_resurrection_delay")
local FormatScriptError = require("lib/script_error")
LinkLuaModifier("modifier_aegis_buff", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_resurrection_pendant", "items/custom/item_resurection_pendant", LUA_MODIFIER_MOTION_NONE)

item_resurection_pendant = class({})
function item_resurection_pendant:GetIntrinsicModifierName() return "modifier_resurrection_pendant" end
function item_resurection_pendant:IsStealable() return false end
function item_resurection_pendant:GetChannelTime()
	return PendantDelay:GetChannelTime(self:GetCaster())
end
function item_resurection_pendant:GetAbilityTextureName()
	if self:GetCaster() then
		if self:GetCaster():HasModifier("modifier_super_scepter") then
			return "custom/resurection_pendant_super_scepter"
		elseif self:GetCaster():HasScepter() then
			return "custom/resurection_pendant_scepter"
		end
	end
	return "custom/resurection_pendant"
end
function item_resurection_pendant:OnChannelThink(interval)
    self:GetCaster():StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)
end

if IsServer() then
    function item_resurection_pendant:OnChannelFinish(interrupted)
		local caster = self:GetCaster()
		if not caster or not PlayerResource:IsValidPlayerID(caster:GetPlayerID()) then return end
		caster:RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)
		if not interrupted and not caster:HasModifier("modifier_arc_warden_tempest_double") then
			self:Used(caster)
		end	
    end

    function item_resurection_pendant:Used(caster)
		local ressurected = self:RessurectAll(caster)
		if ressurected > 0 then
			player_data_modify_value(caster:GetPlayerID(), "saves", ressurected)

			caster:EmitSound("Hero_Treant.Overgrowth.Cast")

			item_resurection_pendant:DestroyTrees()

			local base_cooldown = self:GetSpecialValueFor("base_cooldown")
			local extra_cooldown = self:GetSpecialValueFor(caster:HasModifier("modifier_super_scepter")
				and "extra_cooldown_ss" or "extra_cooldown")
			self:StartCooldown(base_cooldown + extra_cooldown * ressurected)
		else
			caster:Interrupt()
			caster:InterruptChannel()
			self:RefundManaCost()
			self:EndCooldown()
		end
    end

	function item_resurection_pendant:RessurectAll(caster)
		local ressurected = 0
		local resurrectAll = inventory_slot1(caster)
		for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
			if PlayerResource:HasSelectedHero(playerID) and (resurrectAll or PlayerResource:IsValidPlayerID(playerID)) then
				local hero = PlayerResource:GetSelectedHeroEntity(playerID)
				if hero and not hero:IsNull() and not hero:IsAlive() and not hero:IsReincarnating() then
					local rezPosition = hero:GetAbsOrigin()
					hero:RespawnHero(false, false)
					if hero:IsAlive() then
						GameRules.GameMode:RunSpawnCallback("ArmSpawnProtection", hero, true)
						hero:SetAbsOrigin(rezPosition)
						hero:AddNewModifier(caster, self, "modifier_aegis_buff", {duration = 10})
						ressurected = ressurected + 1
						local ok, err = pcall(self.RessurectEffect, self, hero)
						if not ok then print("[Resurrection Pendant] Effects failed: " .. FormatScriptError(err)) end
					end
				end
			end
		end
		return ressurected
	end

    function item_resurection_pendant:RessurectEffect(target)
        local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_holy_persuasion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:ReleaseParticleIndex(effect)

        target:EmitSound("Hero_Treant.Overgrowth.Target")
    end


    function item_resurection_pendant:DestroyTrees()
        GridNav:DestroyTreesAroundPoint(Vector(0, 0, 0), 3900, false)
    end
    function inventory_slot1(unit)
		local Item = unit:GetItemInSlot(0)
		if Item ~= nil and IsValidEntity(Item) then
			if Item:GetName() == "item_resurection_pendant" then
				return true	
			end	
		end
		return false		
    end

end


modifier_resurrection_pendant = class({})
function modifier_resurrection_pendant:IsHidden() return true end
function modifier_resurrection_pendant:IsPurgable() return false end
function modifier_resurrection_pendant:RemoveOnDeath() return false end
function modifier_resurrection_pendant:GetTexture()
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		return "custom/resurection_pendant_super_scepter_modifier"
	elseif self:GetCaster():HasScepter() then
		return "custom/resurection_pendant_scepter_modifier"
	end
	return "custom/resurection_pendant_modifier"
end
function modifier_resurrection_pendant:OnCreated()
	if IsServer() then
		if not self:GetAbility() then
			self:Destroy()
			return
		end
		self:StartIntervalThink(0)
	end
end

local ignoredHeroes = {
	["npc_playerhelp"] = true,
	["npc_dota_target_dummy"] = true,
	["npc_dummy_unit"] = true,
	["npc_dota_hero_target_dummy"] = true,
	["npc_courier_replacement"] = true,
	["npc_dota_totem_item_holder"] = true,
}

function modifier_resurrection_pendant:OnIntervalThink()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	if not caster:HasScepter() or not ability or ability:IsNull() or ability:GetCaster() ~= caster
		or not ability:IsCooldownReady() or not PlayerResource:IsValidPlayerID(caster:GetPlayerID()) then
		self.autoReviveAt = nil
		return
	end

	for _, hero in ipairs(HeroList:GetAllHeroes()) do
		if hero:IsRealHero() and not ignoredHeroes[hero:GetUnitName()] and not hero:HasModifier("modifier_fountain_invulnerability") then
			if hero:IsAlive() or hero:IsReincarnating() then
				self.autoReviveAt = nil
				return
			end
		end
	end

	local now = GameRules:GetGameTime()
	if not self.autoReviveAt then
		-- Start one countdown per wipe and snapshot the delay for this activation.
		self.autoReviveAt = now + ability:GetChannelTime()
	elseif now >= self.autoReviveAt then
		self.autoReviveAt = nil
		if ability:IsChanneling() then caster:InterruptChannel() end
		ability:Used(caster)
	end
end

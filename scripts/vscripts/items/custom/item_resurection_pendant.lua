require("lib/timers")
require("lib/data")
LinkLuaModifier("modifier_aegis_buff", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_resurrection_pendant", "items/custom/item_resurection_pendant", LUA_MODIFIER_MOTION_NONE)

item_resurection_pendant = class({})
function item_resurection_pendant:GetIntrinsicModifierName() return "modifier_resurrection_pendant" end
function item_resurection_pendant:IsStealable() return false end
function item_resurection_pendant:GetChannelTime()
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		return self:GetSpecialValueFor("channel") / 2
	else
		return self:GetSpecialValueFor("channel")
	end
end
function item_resurection_pendant:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		return "custom/resurection_pendant_super_scepter"
	elseif self:GetCaster():HasScepter() then
		return "custom/resurection_pendant_scepter"
	end
	return "custom/resurection_pendant"
end
function item_resurection_pendant:OnChannelThink(interval)
    self:GetCaster():StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)
end

if IsServer() then
    function item_resurection_pendant:OnChannelFinish(interrupted)
	self:GetCaster():RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)
        if not interrupted and not self:GetParent():HasModifier("modifier_arc_warden_tempest_double") then
			local base_cooldown = self:GetSpecialValueFor("base_cooldown")
			local extra_cooldown = self:GetSpecialValueFor("extra_cooldown")
			if self:GetCaster():HasModifier("modifier_super_scepter") then
				extra_cooldown = self:GetSpecialValueFor("extra_cooldown_ss")
			end	
			self:Used(self:GetCaster(), self, base_cooldown, extra_cooldown)
        end
    end

    function item_resurection_pendant:Used(caster, ability, base_cooldown, extra_cooldown)
		local ressurected = item_resurection_pendant:RessurectAll()
		if ressurected > 0 then
			player_data_modify_value(caster:GetPlayerID(), "saves", ressurected)

			caster:EmitSound("Hero_Treant.Overgrowth.Cast")

			item_resurection_pendant:DestroyTrees()

			ability:StartCooldown(base_cooldown + extra_cooldown * ressurected)
		else
			caster:Interrupt()
			caster:InterruptChannel()
			ability:RefundManaCost()
			ability:EndCooldown()
		end
    end

    function item_resurection_pendant:RessurectAll()
        local ressurected = 0

        for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
            if PlayerResource:HasSelectedHero(playerID) then
                local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                if not hero:IsAlive() then
					if not hero:IsReincarnating() then
						local rezPosition = hero:GetAbsOrigin()
						hero:RespawnHero(false, false)
						hero:SetAbsOrigin(rezPosition)
						item_resurection_pendant:RessurectEffect(hero)
						hero:AddNewModifier(hCaster, hAbility, "modifier_aegis_buff", {duration = 10})
						ressurected = ressurected + 1
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
	if IsServer() then if not self:GetAbility() then self:Destroy() end self:StartIntervalThink(FrameTime()) end
end
function modifier_resurrection_pendant:OnIntervalThink()
	if self:GetParent():HasScepter() then
		local NotRegister = {
			["npc_playerhelp"] = true,
			["npc_dota_target_dummy"] = true,
			["npc_dummy_unit"] = true,
			["npc_dota_hero_target_dummy"] = true,
			["npc_courier_replacement"] = true,
		}

		local heroes = HeroList:GetAllHeroes()
		local PlayersID = self:GetParent():GetPlayerID()
		local channel = self:GetAbility():GetChannelTime()
		local base_cooldown = self:GetAbility():GetSpecialValueFor("base_cooldown")
		local extra_cooldown = self:GetAbility():GetSpecialValueFor("extra_cooldown")
		if self:GetParent():HasModifier("modifier_super_scepter") then
			extra_cooldown = self:GetAbility():GetSpecialValueFor("extra_cooldown_ss")
		end

		local LivingHeroes = 0
		
		for i = 1, #heroes do
			local inf_aegis_ready = false
			for itemSlot = 0, 5 do
				local item = heroes[i]:GetItemInSlot(itemSlot)
				if item and item:GetName() == "item_inf_aegis" then
					if item:IsCooldownReady() or item:GetCooldownTimeRemaining() > item:GetSpecialValueFor("cooldown") - channel then
						inf_aegis_ready = true
					end
				end
			end
			if heroes[i]:IsRealHero() and (heroes[i]:IsAlive() or heroes[i]:IsReincarnating() or inf_aegis_ready) and not NotRegister[heroes[i]:GetUnitName()] then
				LivingHeroes = i
			end
		end

--		self:SetStackCount(LivingHeroes)

		if LivingHeroes == 0 and self:GetAbility():IsCooldownReady() then
			Timers:CreateTimer(channel + (FrameTime() * (PlayersID + 1)), function()
				local LivingHeroes = 0
				for i = 1, #heroes do
					if heroes[i]:IsRealHero() and (heroes[i]:IsAlive() or heroes[i]:IsReincarnating()) then
						LivingHeroes = i
					end
				end
				if LivingHeroes == 0 and self:GetAbility():IsCooldownReady() then
					item_resurection_pendant:Used(self:GetParent(), self:GetAbility(), base_cooldown, extra_cooldown)
				end
			end)
		end
	end
end

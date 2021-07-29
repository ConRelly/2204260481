require("lib/timers")
require("lib/data")
LinkLuaModifier("modifier_aegis_buff", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_resurrection_pendant", "items/custom/item_resurection_pendant", LUA_MODIFIER_MOTION_NONE)

item_resurection_pendant = class({})
function item_resurection_pendant:GetIntrinsicModifierName() return "modifier_resurrection_pendant" end
function item_resurection_pendant:IsStealable() return false end
function item_resurection_pendant:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		return "maiar_pendant_super_scepter"
	elseif self:GetCaster():HasScepter() then
		return "maiar_pendant_scepter"
	end
	return "maiar_pendant"
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
                    local rezPosition = hero:GetAbsOrigin()
                    hero:RespawnHero(false, false)
                    hero:SetAbsOrigin(rezPosition)
                    item_resurection_pendant:RessurectEffect(hero)
                    hero:AddNewModifier(hCaster, hAbility, "modifier_aegis_buff", {duration = 10})
                    ressurected = ressurected + 1
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
function modifier_resurrection_pendant:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end self:StartIntervalThink(FrameTime()) end
end
function modifier_resurrection_pendant:OnIntervalThink()
	if self:GetCaster():HasScepter() then
		local dead_heroes = {}
		local heroes = HeroList:GetAllHeroes()
		local channel = self:GetAbility():GetChannelTime()
		local base_cooldown = self:GetAbility():GetSpecialValueFor("base_cooldown")
		local extra_cooldown = self:GetAbility():GetSpecialValueFor("extra_cooldown")
		if self:GetCaster():HasModifier("modifier_super_scepter") then
			channel = self:GetAbility():GetChannelTime() / 2
		end
		for i=1, #heroes do
			if heroes[i]:IsRealHero() and not heroes[i]:IsAlive() then
				table.insert(dead_heroes,heroes[i])
			end
		end
		if #dead_heroes == #heroes then
			if can_be_triggered then
				can_be_triggered = false
				Timers:CreateTimer(channel, function()
					item_resurection_pendant:Used(self:GetCaster(), self:GetAbility(), base_cooldown, extra_cooldown)
				end)
			end
		else
			can_be_triggered = true
		end
	end
end

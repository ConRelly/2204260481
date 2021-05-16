require("lib/timers")
require("lib/data")
LinkLuaModifier( "modifier_aegis_buff", "items/custom/item_aegis_lua", LUA_MODIFIER_MOTION_NONE)

item_resurection_pendant = class({})


function item_resurection_pendant:IsStealable()
    return false
end


function item_resurection_pendant:OnChannelThink(interval)
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)
end


if IsServer() then
    function item_resurection_pendant:OnChannelFinish(interrupted)
        local parent = self:GetParent()
        if not interrupted and not parent:HasModifier("modifier_arc_warden_tempest_double") then --and parent:IsRealHero()
            local caster = self:GetCaster()
            local ressurected = self:RessurectAll()

            if ressurected > 0 then
                player_data_modify_value(caster:GetPlayerID(), "saves", ressurected)

                caster:EmitSound("Hero_Treant.Overgrowth.Cast")

                self:DestroyTrees()
                --if parent:IsRealHero() then
                --    self:Suicide(0.05)
                --end    

                self:StartCooldown(self:GetSpecialValueFor("base_cooldown") + self:GetSpecialValueFor("extra_cooldown") * ressurected)
            else
                caster:Interrupt()
                caster:InterruptChannel()
                self:RefundManaCost()
                self:EndCooldown()
            end
        end
    end


    function item_resurection_pendant:RessurectEffect(target)
        local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_holy_persuasion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:ReleaseParticleIndex(effect)

        target:EmitSound("Hero_Treant.Overgrowth.Target")
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
                    self:RessurectEffect(hero)
                    hero:AddNewModifier(hCaster, hAbility, "modifier_aegis_buff", {duration = 10})
                    ressurected = ressurected + 1
                end
            end
        end

        return ressurected
    end

    function item_resurection_pendant:Suicide(delay)
        Timers:CreateTimer(
            delay, 
            function()
                local caster = self:GetCaster()
                if caster:IsAlive() then
                    caster:ForceKill(false)
                end
            end
        )
    end


    function item_resurection_pendant:DestroyTrees()
        GridNav:DestroyTreesAroundPoint(Vector(0, 0, 0), 3900, false)
    end
end

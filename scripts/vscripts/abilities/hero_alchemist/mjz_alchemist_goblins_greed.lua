
LinkLuaModifier("modifier_mjz_alchemist_goblins_greed", "abilities/hero_alchemist/mjz_alchemist_goblins_greed.lua", LUA_MODIFIER_MOTION_NONE)


mjz_alchemist_goblins_greed = class({})

function mjz_alchemist_goblins_greed:GetIntrinsicModifierName()
    return "modifier_mjz_alchemist_goblins_greed"
end


modifier_mjz_alchemist_goblins_greed = class({})

function modifier_mjz_alchemist_goblins_greed:IsHidden() return true end
function modifier_mjz_alchemist_goblins_greed:IsPurgable() return false end

if IsServer() then

    function modifier_mjz_alchemist_goblins_greed:OnCreated(table)
        local parent = self:GetParent()
        local ability = self:GetAbility()
        if parent:IsRealHero() then
            local flInterval = ability:GetSpecialValueFor("interval")
            self:StartIntervalThink(flInterval)
        end
    end
    function modifier_mjz_alchemist_goblins_greed:OnIntervalThink()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        -- local exp = ability:GetSpecialValueFor("exp")
        local gold = ability:GetSpecialValueFor("gold")

        -- parent:AddExperience(exp, DOTA_ModifyGold_Unspecified, false, false) ---给触发者增加经验

        parent:ModifyGold(gold, true, 0)
        -- local playerid = parent:GetPlayerID()
        -- PlayerResource:ModifyGold(playerid, gold, false, 0)

        -- parent:EmitSound("General.CoinsBig")
        -- parent:EmitSound("DOTA_Item.Hand_Of_Midas")
        -- parent:EmitSound('Hero_BountyHunter.Jinada')

    end

end
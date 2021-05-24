-- LinkLuaModifier( "modifier_item_mjz_chinese_gold", "items/modifier_item_mjz_chinese_gold", LUA_MODIFIER_MOTION_NONE )

---------------------------------------------------------------------------------------

function item_mjz_chinese_gold_CastTarget( item, target )
    
end

---------------------------------------------------------------------------------------

item_mjz_ability_point = class({})

function item_mjz_ability_point:OnSpellStart()
    if IsServer() then
        local item = self
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        
        if target and IsValidEntity(target) and target:IsRealHero() then
            target:SetAbilityPoints(target:GetAbilityPoints() + 1)
            caster:RemoveItem(item)
            target:EmitSound("Hero_Alchemist.Scepter.Cast")
        end
    end
end

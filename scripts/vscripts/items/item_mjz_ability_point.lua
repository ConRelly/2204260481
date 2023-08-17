-- LinkLuaModifier( "modifier_item_mjz_chinese_gold", "items/modifier_item_mjz_chinese_gold", LUA_MODIFIER_MOTION_NONE )

---------------------------------------------------------------------------------------

function item_mjz_chinese_gold_CastTarget( item, target )
    
end

---------------------------------------------------------------------------------------

item_mjz_ability_point = class({})

function item_mjz_ability_point:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        
        if caster and IsValidEntity(caster) then
            caster:SetAbilityPoints(caster:GetAbilityPoints() + 1)
            caster:RemoveItem(self)
            caster:EmitSound("DOTA_Item.HotD.Activate")
        end
    end
end

item_mjz_ability_point_2 = class({})

function item_mjz_ability_point_2:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        
        if caster and IsValidEntity(caster) and caster:IsRealHero() then
            caster:SetAbilityPoints(caster:GetAbilityPoints() + 5)
            caster:RemoveItem(self)
            caster:EmitSound("DOTA_Item.HotD.Activate")
        end
    end
end

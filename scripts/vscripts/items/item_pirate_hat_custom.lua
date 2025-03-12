
LinkLuaModifier("modifier_pirate_hat_passive", "items/item_pirate_hat_custom.lua", LUA_MODIFIER_MOTION_NONE)


item_pirate_hat_custom = class({})

function item_pirate_hat_custom:GetIntrinsicModifierName()
    return "modifier_pirate_hat_passive"
end

function item_pirate_hat_custom:OnSpellStart()  
    self.pfx = ParticleManager:CreateParticle("particles/econ/events/ti9/shovel_dig.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(self.pfx, 0, self:GetCursorPosition())
end


function item_pirate_hat_custom:OnChannelFinish(bInterrupted)
    print("item_pirate_hat_custom:OnChannelFinish called, bInterrupted:", bInterrupted)
    if not bInterrupted then
        
        local pfx2 = ParticleManager:CreateParticle("particles/econ/events/ti9/shovel_revealed_generic.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(pfx2, 0, self:GetCursorPosition())
        ParticleManager:ReleaseParticleIndex(pfx2)

        CreateRune(self:GetCursorPosition(), DOTA_RUNE_BOUNTY)
        print("Creating rune at", self:GetCursorPosition())
    end

    if self.pfx then
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
        print("Destroing digging particle, pfx")
        self.pfx = nil
    end
end

modifier_pirate_hat_passive = class({})

function modifier_pirate_hat_passive:IsHidden() return true end
function modifier_pirate_hat_passive:IsPurgable() return false end

function modifier_pirate_hat_passive:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_pirate_hat_passive:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
end
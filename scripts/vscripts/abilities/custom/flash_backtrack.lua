LinkLuaModifier("modifier_flash_backtrack", "abilities/custom/flash_backtrack.lua", 0)
LinkLuaModifier("modifier_flash_double_attack", "abilities/custom/flash_backtrack.lua", 0)

flash_backtrack = class({
    GetIntrinsicModifierName = function() return "modifier_flash_backtrack" end
})

modifier_flash_backtrack = class({
    IsHidden = function() return true end,
    IsPurgable = function() return false end,
    --RemoveOnDeath = function() return false end,
    IsDebuff = function() return false end
})

function modifier_flash_backtrack:GetEffectName() return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_debuff.vpcf" end
function modifier_flash_backtrack:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_flash_backtrack:OnCreated()
    if IsServer() then
        --self.dodge_chance_pct = self:GetAbility():GetSpecialValueFor("dodge_chance_pct")
        --self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_faceless_void_backtrack", {dodge_chance_pct = dodge_chance_pct})
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_flash_double_attack", nil)
    end
end
function modifier_flash_backtrack:DeclareFunctions()
	return {MODIFIER_PROPERTY_AVOID_DAMAGE}
end
function modifier_flash_backtrack:GetModifierAvoidDamage(params)
	if IsServer() then
        local parent = self:GetParent()
        if parent then
            if parent:HasModifier("modifier_spellbook_destruction_pierce_evasion") then
                return 0
            end
            if parent:PassivesDisabled() then
                local randomSeed = math.random(1, 100)
                local chance = 35
                if randomSeed <= chance then
                    --local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
                    --ParticleManager:ReleaseParticleIndex(iParticleID)
                    return 1
                end  
            else
                local randomSeed = math.random(1, 100)
                local chance = 65
                if randomSeed <= chance then
                    --local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
                    --ParticleManager:ReleaseParticleIndex(iParticleID)
                    return 1
                end				   
            end             
        end
        return 0 
	end	
end


function modifier_flash_backtrack:OnRefresh()
	self:OnCreated()
end

modifier_flash_double_attack = class({
    IsHidden = function() return true end,
    --RemoveOnDeath = function() return false end,
    IsPurgable = function() return false end,
    DeclareFunctions = function() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
})

function modifier_flash_double_attack:OnAttackLanded(params)
    local roll = self:GetAbility():GetSpecialValueFor("double_attack_chance")
    --if self:GetCaster():HasModifier("modifier_flash_speedforce_power") then roll = roll + self:GetCaster():FindAbilityByName("flash_speedforce_power"):GetSpecialValueFor("ultimate_bonus_pct") end

    if params.attacker == self:GetParent() and params.target:IsMagicImmune() == false and RollPercentage(roll) and IsServer() then
        self:GetCaster():PerformAttack(params.target, true, true, true, true, false, false, false)
        --EmitSoundOn("Hero_FacelessVoid.TimeLockImpact", params.target)
        --params.attacker:EmitSoundParams("Hero_FacelessVoid.TimeLockImpact", 0, 0.1, 0)
        --local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_timedialate.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        --ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
        --ParticleManager:ReleaseParticleIndex(particle)
    end
end

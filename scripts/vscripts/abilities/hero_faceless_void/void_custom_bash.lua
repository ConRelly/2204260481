if void_custom_bash == nil then
    void_custom_bash = class({})
end

LinkLuaModifier( "modifier_custom_bash", "abilities/hero_faceless_void/void_custom_bash.lua", LUA_MODIFIER_MOTION_NONE )

function void_custom_bash:GetIntrinsicModifierName()
    return "modifier_custom_bash"
end
    
    -- void_custom_bash.lua
if modifier_custom_bash == nil then
    modifier_custom_bash = class({})
end
    
function modifier_custom_bash:IsHidden()
    return true
end
    
function modifier_custom_bash:IsPurgable()
    return false
end
function modifier_custom_bash:OnCreated()
end    
function modifier_custom_bash:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
    }
    return funcs
end
    
function modifier_custom_bash:GetModifierProcAttack_Feedback( params )
    if IsServer() then
        local parent = self:GetParent()
        local target = params.target
        if not parent:IsRealHero() then return end 
        local ability = self:GetAbility()
        if not ability then return end        
        local bash_chance = ability:GetSpecialValueFor( "bash_chance" )
        local randomSeed = math.random(1, 100)
        if randomSeed <= bash_chance then            
            if not target:IsAlive() then return end
            local bash_dmg_mult =  (ability:GetSpecialValueFor( "bash_damage_ptc" ) + talent_value(parent, "special_bonus_void_custom_bash")) / 100
            local bash_damage = parent:GetBaseDamageMax()  * bash_dmg_mult
            -- Apply damage
            local damageTable = {
                victim = target,
                attacker = parent,
                damage = bash_damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability = ability
            }
            
            ApplyDamage(damageTable)
            
            -- Apply an attack
            -- sound and particle effect
            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_lock_bash.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle) 
            local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_lock_bash.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:SetParticleControl(particle2, 0, self:GetCaster():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle2)             
            EmitSoundOn("Hero_FacelessVoid.TimeLockImpact", target)
            parent:PerformAttack(target, true, true, true, false, false, false, false)              
        end
        
    end
end
    

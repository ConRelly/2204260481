if void_custom_bash == nil then
    void_custom_bash = class({})
end

LinkLuaModifier( "modifier_custom_bash", "abilities/hero_faceless_void/void_custom_bash.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_custom_bash_proc", "abilities/hero_faceless_void/void_custom_bash.lua", LUA_MODIFIER_MOTION_NONE )

function void_custom_bash:GetIntrinsicModifierName()
    return "modifier_custom_bash"
end
modifier_custom_bash_proc = class({})
function modifier_custom_bash_proc:IsHidden()
    return true
end
function modifier_custom_bash_proc:IsPurgable()
    return false
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
    if IsServer() then
        self:StartIntervalThink(0.4)
    end    
end 
function modifier_custom_bash:OnIntervalThink()
    if IsServer() then
        local parent = self:GetParent()
        if parent:IsAlive() and parent:HasModifier("modifier_faceless_void_time_walk_shardbuff") then
            --attack everything in a 700 aoe range
            local enemies = FindUnitsInRadius(parent:GetTeamNumber(), parent:GetAbsOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
            for _, enemy in pairs(enemies) do
                if enemy:IsAlive() then
                    --add void custom bash proc modifier
                    enemy:AddNewModifier(parent, self:GetAbility(), "modifier_custom_bash_proc", {duration = 0.03})
                    parent:PerformAttack(enemy, true, true, true, false, false, false, true)              
                end    
            end    
        end    
    end
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
        if randomSeed <= bash_chance or target:HasModifier("modifier_custom_bash_proc") then            
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
            if target:HasModifier("modifier_custom_bash_proc") then
                target:RemoveModifierByName("modifier_custom_bash_proc")
            end                        
            EmitSoundOn("Hero_FacelessVoid.TimeLockImpact", target)
            parent:PerformAttack(target, true, true, true, false, false, false, false)                
        end
        
    end
end
    

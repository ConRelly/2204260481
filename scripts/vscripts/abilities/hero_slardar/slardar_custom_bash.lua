if slardar_custom_bash == nil then
    slardar_custom_bash = class({})
end

LinkLuaModifier( "modifier_slardar_custom_bash", "abilities/hero_slardar/slardar_custom_bash.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_armor_reduction_bash", "abilities/hero_slardar/slardar_custom_bash.lua", LUA_MODIFIER_MOTION_NONE )  
LinkLuaModifier( "modifier_armor_reduction_bash_stacks", "abilities/hero_slardar/slardar_custom_bash.lua", LUA_MODIFIER_MOTION_NONE ) 

function slardar_custom_bash:GetIntrinsicModifierName()
    return "modifier_slardar_custom_bash"
end
    
if modifier_slardar_custom_bash == nil then
    modifier_slardar_custom_bash = class({})
end
    
function modifier_slardar_custom_bash:IsHidden()
    return true
end
    
function modifier_slardar_custom_bash:IsPurgable()
    return false
end
function modifier_slardar_custom_bash:OnCreated()
    if IsServer()then
        self.brake_armor_count = 10
    end   
end    
function modifier_slardar_custom_bash:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
    }
    return funcs
end
    
function modifier_slardar_custom_bash:GetModifierProcAttack_Feedback( params )
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
            local bonus_damage = 0
            local bash_damage = ability:GetSpecialValueFor( "bash_damage" )
            -- Apply and -armor modifier
            local armor_modifier = "modifier_armor_reduction_bash"
            local armor_modifier_bonus = "modifier_armor_reduction_bash_stacks"
            local armor_duration = ability:GetSpecialValueFor( "armor_duration" )
            if not target:HasModifier(armor_modifier) then
                target:AddNewModifier(parent, ability, armor_modifier, {duration = armor_duration})
                self.brake_armor_count = 10
            elseif self.brake_armor_count > 0 and target:HasModifier(armor_modifier) then
                self.brake_armor_count = self.brake_armor_count - 1
                local modif = target:FindModifierByName(armor_modifier)
                modif:SetStackCount(modif:GetStackCount()+ RandomInt(1,20))
            elseif target:HasModifier(armor_modifier) and parent:HasModifier("modifier_super_scepter") then 
                local modif = target:FindModifierByName(armor_modifier)
                local stacks_nr = math.ceil(modif:GetStackCount() / 10)
                if parent:HasModifier(armor_modifier_bonus) then
                    local modif_bonus = parent:FindModifierByName(armor_modifier_bonus)
                    local modif_stacks = modif_bonus:GetStackCount()
                    modif_bonus:SetStackCount(modif_stacks + stacks_nr)
                    bonus_damage = modif_stacks * parent:GetLevel()
                else
                    parent:AddNewModifier(parent, ability, armor_modifier_bonus, {})
                    local modif_bonus = parent:FindModifierByName(armor_modifier_bonus)
                    local modif_stacks = modif_bonus:GetStackCount()
                    modif_bonus:SetStackCount(modif_bonus:GetStackCount()+ stacks_nr)
                    bonus_damage = modif_stacks * parent:GetLevel()
                end   
            end
            -- Apply damage
            local damageTable = {
                victim = target,
                attacker = parent,
                ability = ability,
                damage = bash_damage + bonus_damage,
                damage_type = DAMAGE_TYPE_PHYSICAL,
            }
            ApplyDamage(damageTable) 

            --local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_slardar/slardar_bash.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            --ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
            --ParticleManager:ReleaseParticleIndex(particle)  
            EmitSoundOn("Hero_Slardar.Bash", target)                    
        end
    end
end


modifier_armor_reduction_bash = class({})
function modifier_armor_reduction_bash:IsHidden()
    return false
end   
function modifier_armor_reduction_bash:IsPurgable()
    return false
end
function modifier_armor_reduction_bash:IsDebuff()
    return true
end
function modifier_armor_reduction_bash:GetTexture()
    return "slardar_custom_bash3"
end

function modifier_armor_reduction_bash:OnCreated()

end

function modifier_armor_reduction_bash:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
    return funcs
end

function modifier_armor_reduction_bash:GetModifierPhysicalArmorBonus()
    return -self:GetStackCount()
end


modifier_armor_reduction_bash_stacks = class({})
function modifier_armor_reduction_bash_stacks:IsHidden()
    return false
end   
function modifier_armor_reduction_bash_stacks:IsPurgable()
    return false
end
function modifier_armor_reduction_bash_stacks:RemoveOnDeath()
    return false
end
function modifier_armor_reduction_bash_stacks:GetTexture()
    return "slardar_custom_bash3"
end
function modifier_armor_reduction_bash_stacks:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,MODIFIER_PROPERTY_TOOLTIP, MODIFIER_PROPERTY_TOOLTIP2}
end
function modifier_armor_reduction_bash_stacks:GetModifierBaseAttack_BonusDamage()
	return self:GetStackCount() * 2
end
function modifier_armor_reduction_bash_stacks:OnTooltip()
    return self:GetStackCount() * 2
end
function modifier_armor_reduction_bash_stacks:OnTooltip2()
    return self:GetStackCount() * self:GetParent():GetLevel()
end
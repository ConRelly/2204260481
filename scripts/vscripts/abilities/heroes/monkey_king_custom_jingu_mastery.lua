

--local hud_modifier = "modifier_monkey_king_custom_jingu_mastery_hit"


monkey_king_custom_jingu_mastery = class({})


function monkey_king_custom_jingu_mastery:GetIntrinsicModifierName()
    return "modifier_monkey_king_custom_jingu_mastery_thinker"
end



LinkLuaModifier("modifier_monkey_king_custom_jingu_mastery_thinker", "abilities/heroes/monkey_king_custom_jingu_mastery.lua", LUA_MODIFIER_MOTION_NONE)

modifier_monkey_king_custom_jingu_mastery_thinker = class({})


function modifier_monkey_king_custom_jingu_mastery_thinker:IsHidden()
    return true
end
function modifier_monkey_king_custom_jingu_mastery_thinker:OnCreated()
    if not IsServer() then return end
    if self:GetAbility():GetLevel() > 0 then 
        self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("interval"))
    end       
end
function modifier_monkey_king_custom_jingu_mastery_thinker:OnRefresh()
    self:OnCreated()
end    
function modifier_monkey_king_custom_jingu_mastery_thinker:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local buf_duration = ability:GetSpecialValueFor("buf_duration")
    local modif_dmg = "modifier_monkey_king_custom_jingu_mastery_buff"
    local modif_spell = "modifier_monkey_king_custom_jingu_mastery_spell"
    local level = parent:GetLevel()

    local bonuns_stats = ability:GetSpecialValueFor("bonus_stats")
    local base_spell_amp = ability:GetSpecialValueFor("spell_amp")
    self.spell_amp = 0
    if HasSuperScepter(parent) then
        bonuns_stats = bonuns_stats * 2
        base_spell_amp = base_spell_amp * 2
        buf_duration = buf_duration * (1 + parent:GetStatusResistance())
    end
    if parent:IsAlive() and parent:IsRealHero() and parent:HasScepter() then
        parent:ModifyAgility(bonuns_stats)
        parent:ModifyStrength(bonuns_stats)
        if parent:GetPrimaryAttribute() == 2 then
            self.spell_amp = base_spell_amp
        end    
    end  
    if parent:IsAlive() then      
        parent:AddNewModifier(parent, ability, modif_dmg, {duration = buf_duration})
        if parent:HasModifier(modif_dmg) then
            local modifier_1 = parent:FindModifierByName(modif_dmg)
            modifier_1:SetStackCount(level)
        end
        parent:AddNewModifier(parent, ability, modif_spell, {duration = buf_duration})
        if parent:HasModifier(modif_spell) then
            local modifier_2 = parent:FindModifierByName(modif_spell)
            modifier_2:SetStackCount(self.spell_amp)
        end
    end           
end 

--[[if IsServer() then
    function modifier_monkey_king_custom_jingu_mastery_thinker:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end  
    function modifier_monkey_king_custom_jingu_mastery_thinker:OnAttackLanded(keys)
        local attacker = keys.attacker
        if attacker == self:GetParent() then
            local ability = self:GetAbility()

            if not attacker:HasModifier(hud_modifier) then
                attacker:AddNewModifier(attacker, ability, hud_modifier, {})
            end

            local modifier_handler = attacker:FindModifierByName(hud_modifier)
            modifier_handler:IncrementStackCount()

            if modifier_handler:GetStackCount() == ability:GetSpecialValueFor("attack_count") - 1 then
                attacker:AddNewModifier(attacker, ability, "modifier_monkey_king_custom_jingu_mastery_buff", {})
            end
			if modifier_handler:GetStackCount() == ability:GetSpecialValueFor("attack_count") then
                modifier_handler:Destroy()	
			end
        end
    end
end]]



--[[LinkLuaModifier("modifier_monkey_king_custom_jingu_mastery_hit", "abilities/heroes/monkey_king_custom_jingu_mastery.lua", LUA_MODIFIER_MOTION_NONE)

modifier_monkey_king_custom_jingu_mastery_hit = class({})


function modifier_monkey_king_custom_jingu_mastery_hit:IsBuff()
    return true
end


if IsServer() then
    function modifier_monkey_king_custom_jingu_mastery_hit:OnStackCountChanged(count)
        ParticleManager:SetParticleControl(self.effect, 1, Vector(1, count + 1, 1))
    end


    function modifier_monkey_king_custom_jingu_mastery_hit:OnCreated(keys)
        local parent = self:GetParent()
        self.effect = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, parent)
        ParticleManager:SetParticleControl(self.effect, 0, parent:GetAbsOrigin())
    end


    function modifier_monkey_king_custom_jingu_mastery_hit:OnDestroy()
        ParticleManager:DestroyParticle(self.effect, false)
        ParticleManager:ReleaseParticleIndex(self.effect)
    end
end]]



LinkLuaModifier("modifier_monkey_king_custom_jingu_mastery_buff", "abilities/heroes/monkey_king_custom_jingu_mastery.lua", LUA_MODIFIER_MOTION_NONE)

modifier_monkey_king_custom_jingu_mastery_buff = class({})





function modifier_monkey_king_custom_jingu_mastery_buff:IsBuff()
    return true
end
function modifier_monkey_king_custom_jingu_mastery_buff:GetEffectName()
    return "particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_overhead.vpcf"
end
function modifier_monkey_king_custom_jingu_mastery_buff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_monkey_king_custom_jingu_mastery_buff:DeclareFunctions()
    return {
        --MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_monkey_king_custom_jingu_mastery_buff:GetModifierPreAttack_BonusDamage()
    if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_damage") * self:GetStackCount() end
end




LinkLuaModifier("modifier_monkey_king_custom_jingu_mastery_spell", "abilities/heroes/monkey_king_custom_jingu_mastery.lua", LUA_MODIFIER_MOTION_NONE)

modifier_monkey_king_custom_jingu_mastery_spell = class({})


function modifier_monkey_king_custom_jingu_mastery_spell:IsBuff()
    return true
end
function modifier_monkey_king_custom_jingu_mastery_spell:IsHidden()
    return true
end
function modifier_monkey_king_custom_jingu_mastery_spell:DeclareFunctions()
    return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_monkey_king_custom_jingu_mastery_spell:GetModifierSpellAmplify_Percentage()
    if self:GetAbility() then return self:GetStackCount() end
end


--[[if IsServer() then
    function modifier_monkey_king_custom_jingu_mastery_buff:DisplayHitEffect(target)
        local heal_effect = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:ReleaseParticleIndex(heal_effect)
    end


    function modifier_monkey_king_custom_jingu_mastery_buff:OnAttackLanded(keys)
        if keys.attacker == self:GetParent() then
            local lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal") * 0.01

            local parent = self:GetParent()
            parent:Heal(keys.damage * lifesteal, parent)
			local hit_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
			ParticleManager:SetParticleControl(hit_effect, 1, keys.target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(hit_effect)
            self:DisplayHitEffect(keys.target)
            self:Destroy()  
        end
    end
end]]

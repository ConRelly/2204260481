if item_custom_spellbook == nil then
    item_custom_spellbook = class({})
end

LinkLuaModifier("modifier_custom_spellbook_passive", "items/book_preawaken.lua", LUA_MODIFIER_MOTION_NONE)

function item_custom_spellbook:GetIntrinsicModifierName()
    return "modifier_custom_spellbook_passive"
end

modifier_custom_spellbook_passive = class({})

function modifier_custom_spellbook_passive:IsHidden()
    return true
end

function modifier_custom_spellbook_passive:IsPurgable()
    return false
end

function modifier_custom_spellbook_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }
    return funcs
end

function modifier_custom_spellbook_passive:GetModifierBonusStats_Intellect()
    if self:GetAbility() == nil then return end
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_custom_spellbook_passive:GetModifierConstantHealthRegen()
    if self:GetAbility() == nil then return end
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_custom_spellbook_passive:GetModifierConstantManaRegen()
    if self:GetAbility() == nil then return end
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_custom_spellbook_passive:GetModifierBonusStats_Strength()
    if self:GetAbility() == nil then return end
    return self:GetAbility():GetSpecialValueFor("bonus_strength")
end
function modifier_custom_spellbook_passive:GetModifierSpellAmplify_Percentage()
    if self:GetAbility() == nil then return end
    return self:GetAbility():GetSpecialValueFor("bonus_spell_amplify")
end
function modifier_custom_spellbook_passive:OnAbilityExecuted(keys)
    if not IsServer() then return end
    if keys.ability and self:GetAbility() and keys.ability:GetCooldown(keys.ability:GetLevel() - 1) > 0 then
        local ability = self:GetAbility()
        local cooldown = math.ceil(keys.ability:GetCooldown(keys.ability:GetLevel() - 1))
        if cooldown > 150 then
            cooldown = 150
        end
        if keys.ability and keys.ability:GetName() == "phantom_lancer_phantom_edge" then
            keys.ability:EndCooldown()
            keys.ability:StartCooldown(1.0)
        end
        local caster = self:GetCaster()
        local charges = ability:GetCurrentCharges()
        local has_ss = caster:HasModifier("modifier_super_scepter")
        local marci_ult = caster:HasModifier("modifier_marci_unleash_flurry")
        local bonus_ch = 1  
        local limit = ability:GetSpecialValueFor("charge_awaken") 
        local evolve = (charges >= limit)
        if has_ss then
            bonus_ch = 10
            if marci_ult then
                bonus_ch = bonus_ch * 2
                cooldown = cooldown * 2	
            end            							
        end	            
        ability:SetCurrentCharges(charges + cooldown)
        if evolve then
            if ability and not ability.evolve_check then
                local zeus_ultimate_particle = "particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf" 
                local particle = "particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf"
                local zeus_ultimate_sound = "Hero_Zuus.GodsWrath"
                --Renders the particle on the target
                local particle_eff = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, caster)
                -- Raise 1000 value if you increase the camera height above 1000
                ParticleManager:SetParticleControl(particle_eff, 0, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
                ParticleManager:SetParticleControl(particle_eff, 1, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,1000 ))
                ParticleManager:SetParticleControl(particle_eff, 2, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
                ParticleManager:ReleaseParticleIndex(particle_eff)
                ParticleManager:DestroyParticle(particle_eff, false)
                EmitSoundOn(zeus_ultimate_sound, caster)                    
                caster:EmitSoundParams(zeus_ultimate_sound, 1, 3.0, 0)   
                -- Remove the old item and add the evolved item
                ability.evolve_check = true

                --caster:RemoveItem(ability)
                caster:TakeItem(ability)
                caster:AddItemByName("item_spellbook_destruction"):SetCurrentCharges(bonus_ch)                                                     
            end  
        end                        
    end	
end
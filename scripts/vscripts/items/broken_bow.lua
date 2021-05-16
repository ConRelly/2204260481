
require("lib/mys")
item_broken_bow = class({})


function item_broken_bow:GetIntrinsicModifierName()
    return "modifier_item_broken_bow"
end



LinkLuaModifier("modifier_item_broken_bow", "items/broken_bow.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_broken_bow = class({})



function modifier_item_broken_bow:OnCreated(keys)
    if IsServer() then
        local parent = self:GetParent()

        if parent then
            parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_broken_bow_thinker", {})
        end
    end    
end
function modifier_item_broken_bow:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        if parent and parent:HasModifier("modifier_item_broken_bow_thinker") then
            parent:RemoveModifierByName("modifier_item_broken_bow_thinker")    
        end    
        if parent and parent:HasModifier("modifier_item_broken_bow_count") then
            parent:RemoveModifierByName("modifier_item_broken_bow_count")
        end   
    end
end



function modifier_item_broken_bow:IsHidden()
    return true
end
function modifier_item_broken_bow:IsPurgable()
	return false
end

--function modifier_item_broken_bow:GetAttributes()
--    return MODIFIER_ATTRIBUTE_MULTIPLE
--end


function modifier_item_broken_bow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    }
end


function modifier_item_broken_bow:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agility")
end


function modifier_item_broken_bow:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_int")
end


function modifier_item_broken_bow:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end


function modifier_item_broken_bow:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("movement_speed_bonus")
end

function modifier_item_broken_bow:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_broken_bow:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_broken_bow:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_range")
end


LinkLuaModifier("modifier_item_willbreaker_debuff", "items/broken_bow.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_willbreaker_debuff = class({})

function modifier_item_willbreaker_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
end
function modifier_item_willbreaker_debuff:IsHidden()
    return false
end

function modifier_item_willbreaker_debuff:IsPurgable()
	return false
end
function modifier_item_willbreaker_debuff:GetTexture()
	return "crossbow"
end
function modifier_item_willbreaker_debuff:GetModifierPhysicalArmorBonus()
    return -self:GetStackCount()
end
function modifier_item_willbreaker_debuff:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("magic_resist_redu")
end
function modifier_item_willbreaker_debuff:OnCreated()

end
function modifier_item_willbreaker_debuff:OnDestroy()

end



LinkLuaModifier("modifier_item_broken_bow_thinker", "items/broken_bow.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_broken_bow_thinker = class({})


function modifier_item_broken_bow_thinker:IsHidden()
    return true
end
function modifier_item_broken_bow_thinker:IsPurgable()
	return false
end

function modifier_item_broken_bow_thinker:RemoveOnDeath()
    return false
end



function modifier_item_broken_bow_thinker:DeclareFunctions()
    if IsServer() then
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end     
end
	
function modifier_item_broken_bow_thinker:OnCreated()
    if IsServer() then
        self.parent = self:GetParent()
        self.attacks_needed = self:GetAbility():GetSpecialValueFor("attacks_needed")
        self.stack_count = 0
        --Timers:CreateTimer(321, function() SetSteckCount(self.parent) end) 
        self.count_modifier = self.parent:AddNewModifier(self.parent, self, "modifier_item_broken_bow_count", {}) 
        self.armor_reduction = self:GetAbility():GetSpecialValueFor("armor_reduc")
        self.duration = self:GetAbility():GetSpecialValueFor("duration")
    end   
end
function modifier_item_broken_bow_thinker:OnAttackLanded(keys)
    if IsServer() then
        local attacker = keys.attacker
        if attacker == self.parent and not attacker:IsNull() and attacker:IsRangedAttacker() and attacker:IsAlive() and not attacker:IsIllusion() then
            local ability = self:GetAbility()
            local chance = ability:GetSpecialValueFor("chance_hit")
            local target_hp = ability:GetSpecialValueFor("target_hp")
            local target = keys.target
            if RollPercentage(chance) then
                self.stack_count = self.stack_count + 1
                if self.stack_count > self.attacks_needed - 1 then
                    if target:IsAlive() then
                        local damage = math.floor(target:GetHealth() / target_hp)
                        self.stack_count = -1
                        self.count_modifier:SetStackCount(self.stack_count)
                        Timers:CreateTimer({
                            endTime = 0.02, 
                            callback = function()
                                ApplyDamage({
                                    attacker = attacker,
                                    victim = target,
                                    ability = ability,
                                    damage = damage,
                                    damage_type = DAMAGE_TYPE_MAGICAL,
                                })				
                            end
                        }) 
                        local iParticle = ParticleManager:CreateParticle("particles/msg_fx/msg_spell.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
                        ParticleManager:SetParticleControlEnt(iParticle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
                        ParticleManager:SetParticleControl(iParticle, 1, Vector(0, damage, 6))
                        ParticleManager:SetParticleControl(iParticle, 2, Vector(1, math.floor(math.log10(damage))+2, 100))
                        ParticleManager:SetParticleControl(iParticle, 3, Vector(85+80,26+40,139+40))                                                 
                        attacker:PerformAttack(target, true, true, true, true, true, false, false)
                    end     
                else 
                    self.count_modifier:SetStackCount(self.stack_count)
                end
            end
            if attacker == self.parent and not target:IsNull() and target:IsAlive() then 
                if ability:IsCooldownReady() then
                    if not target:HasModifier("modifier_item_willbreaker_debuff") then
                        local durationz = self.duration * (1 + self.parent:GetStatusResistance())
                        --print(durationz .. " duration")
                        local modifier = target:AddNewModifier(
                            attacker,
                            ability,
                            "modifier_item_willbreaker_debuff", -- modifier name
                            {duration = durationz} -- kv
                        )
                        modifier:SetStackCount(target:GetPhysicalArmorBaseValue() * self.armor_reduction)
                        ability:UseResources(false, false, true)
                        local particle = ParticleManager:CreateParticle("particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_ti8_immortal_pitofmalice_burst_spark.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
                        ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
                        ParticleManager:ReleaseParticleIndex(particle)
                    end	
                end
            end            
        end
    end    
end




LinkLuaModifier("modifier_item_broken_bow_count", "items/broken_bow.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_broken_bow_count = class({})

function modifier_item_broken_bow_count:IsPurgable()
	return false
end
function modifier_item_broken_bow_count:GetTexture()
    return "item_ForaMon/broken_bow"
end
function modifier_item_broken_bow_count:RemoveOnDeath()
    return false
end

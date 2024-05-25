-- Register the item
LinkLuaModifier("modifier_thunder_gods_might", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_thunder_gods_might2", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_god_might_immune", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_god_might_speed", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_god_might_aura", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_god_might_aura_debuff", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_god_might_aura2", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_god_might_aura_debuff2", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_physical", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_magical", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_pure", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_cd_limit", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)


item_thunder_gods_might = item_thunder_gods_might or class({})
local item = item_thunder_gods_might

item_thunder_gods_might2 = class(item_thunder_gods_might)
local item2 = item_thunder_gods_might2

function item:GetIntrinsicModifierName()
    return "modifier_thunder_gods_might"
end
function item2:GetIntrinsicModifierName()
    return "modifier_thunder_gods_might2"
end

function item:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    if caster and caster:IsAlive() and ability then
        local duration = ability:GetSpecialValueFor("static_dur")
        local cd_limiter = caster:HasModifier("modifier_item_thunder_cd_limit")
        if not cd_limiter then
            caster:AddNewModifier(caster, ability, "modifier_item_thunder_god_might_immune", {duration = duration})
            caster:AddNewModifier(caster, ability, "modifier_item_thunder_cd_limit", {duration = duration * 1.7})
        end   

        -- Apply the movespeed bonus and remove the movespeed limit
        caster:AddNewModifier(caster, ability, "modifier_item_thunder_god_might_speed", {duration = duration})

        -- Apply the modifier aura that affects enemys: every 0.3s deals damage_per_tick as physical damage that ignores base armor
        caster:AddNewModifier(caster, ability, "modifier_item_thunder_god_might_aura", {duration = duration})

        -- play a sound based on the selected damage type

        local sound_name = "DOTA_Item.Mjolnir.Activate"
        EmitSoundOn(sound_name, caster)  
    end  

end
---Awkened version
function item2:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    if caster and caster:IsAlive() and ability then
        local duration = ability:GetSpecialValueFor("static_dur")
        local cd_limiter = caster:HasModifier("modifier_item_thunder_cd_limit")
        if not cd_limiter then
            caster:AddNewModifier(caster, ability, "modifier_item_thunder_god_might_immune", {duration = duration})
            caster:AddNewModifier(caster, ability, "modifier_item_thunder_cd_limit", {duration = duration * 1.7})
        end   

        -- Apply the movespeed bonus and remove the movespeed limit
        caster:AddNewModifier(caster, ability, "modifier_item_thunder_god_might_speed", {duration = duration})

        -- Apply the modifier aura that affects enemys: every 0.3s deals damage_per_tick as physical damage that ignores base armor
        caster:AddNewModifier(caster, ability, "modifier_item_thunder_god_might_aura2", {duration = duration})

        -- play a sound based on the selected damage type

        local sound_name = "DOTA_Item.Mjolnir.Activate"
        EmitSoundOn(sound_name, caster)  
    end  

end
modifier_thunder_gods_might = modifier_thunder_gods_might or class({})
local modifier_item = modifier_thunder_gods_might
function modifier_item:IsHidden() return true end
function modifier_item:IsPurgable() return false end
function modifier_item:RemoveOnDeath() return false end
function modifier_item:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PROCATTACK_FEEDBACK}
end
function modifier_item:OnCreated()
    self.last_use = 0   
end

-- bonus dmg_ptc, As and all stats bonus
function modifier_item:GetModifierBaseDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_damage_ptc") end
end
function modifier_item:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
end
function modifier_item:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end
end
function modifier_item:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end
end
function modifier_item:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end
end
function modifier_item:GetModifierProcAttack_Feedback(keys)
	if IsServer() then
        local parent = self:GetParent()
        local target = keys.target
        --if parent ~= keys.attacker then return end
        if not parent:IsRealHero() then return end 
        local ability = self:GetAbility()
        if not ability then return end
        -- Check if enough time has passed since the last usage , self.last_use is first saved as 0 in OnCreated()
        local current_time = GameRules:GetGameTime()        
        if self.last_use and current_time - self.last_use < 0.15 then
            return
        end           
        local chance = ability:GetSpecialValueFor("static_chance")
        local randomSeed = math.random(1, 100)
        if randomSeed <= chance then
            local caster = self:GetCaster()
            if not target then return end
            if not target:IsAlive() then return end
            if not caster:IsAlive() then return end
            self.last_use = current_time            
            local static_radius = ability:GetSpecialValueFor("static_radius")
            local static_strikes = ability:GetSpecialValueFor("static_strikes")
            local damage_typ = DAMAGE_TYPE_PHYSICAL
            local damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
            local stats_mult = ability:GetSpecialValueFor("stats_mult_dmg")
            local attack_dmg_mult = ability:GetSpecialValueFor("chain_damage") / 100
            local ss_spell_amp = ability:GetSpecialValueFor("ss_spell_amp") / 100        
            local all_stats = (caster:GetAgility() + caster:GetStrength() + caster:GetIntellect(true)) * stats_mult
            local caster_attack = caster:GetAverageTrueAttackDamage(target) * attack_dmg_mult
            local damage = caster_attack + all_stats            
            local particleName = "particles/econ/events/ti8/maelstorm_ti8.vpcf" --"particles/items_fx/chain_lightning.vpcf"
            local has_ss = caster:HasModifier("modifier_super_scepter")
            -- uses 20% of the spell amp
            if has_ss then
                damage = damage * (1 + caster:GetSpellAmplification(false) * ss_spell_amp)
                damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_IGNORES_BASE_PHYSICAL_ARMOR
            end 
            -- Create the chain lightning particle effect
            local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
            ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
            -- Get a list of all nearby enemies within a 900 range
            local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, static_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
            local enemies_hit = 0
            caster:EmitSoundParams("Item.Maelstrom.Chain_Lightning.Jump", 1, 0.7, 0)
            -- For each enemy found, repeat the damage and particle effect on them
            for _, enemy in pairs(enemies) do
                -- Check if the number of enemies hit is less than 4
                if enemies_hit < static_strikes then
                    local damageTable = {
                    attacker = caster,
                    victim = enemy,
                    damage = damage,
                    damage_type = damage_typ,
                    damage_flags = damage_flag,
                    ability = ability,
                    }
                    ApplyDamage(damageTable)
                   
                    -- Create the chain lightning particle effect , from enemy to the rest in his aoe(not really a chain effect)
                    local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
                    ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
                    ParticleManager:SetParticleControlEnt(particle, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
                    ParticleManager:DestroyParticle(particle, false)
                    ParticleManager:ReleaseParticleIndex(particle)
                    enemies_hit = enemies_hit + 1
                    target = enemy
                end
            end
            local bonus_charge = 1
            local marci_ult = caster:HasModifier("modifier_marci_unleash_flurry")
            local charges = ability:GetCurrentCharges()
            local limit = ability:GetSpecialValueFor("charge_awaken") 
            local evolve = (charges >= limit)
			local underdog10 = caster:HasModifier("modifier_bottom_10")
			local underdog20 = caster:HasModifier("modifier_bottom_20")
			local underdog50 = caster:HasModifier("modifier_bottom_50")
			if underdog10 then
				bonus_charge = bonus_charge + 1
			elseif underdog20 then
				bonus_charge = bonus_charge + 1
			elseif underdog50 then
				bonus_charge = bonus_charge + 1
			end	
			if has_ss and marci_ult then
				bonus_charge = bonus_charge + 1								
			end	            
			ability:SetCurrentCharges(charges + bonus_charge)               
            if evolve then
                if not self.evolve_check then
                    local zeus_ultimate_particle = "particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf" 
                    local particle = "particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf"
                    local zeus_ultimate_sound = "Hero_Zuus.GodsWrath"
                    --Renders the particle on the target
                    local particle_eff = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, caster)
                    -- Raise 1000 value if you increase the camera height above 1000
                    ParticleManager:SetParticleControl(particle_eff, 0, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
                    ParticleManager:SetParticleControl(particle_eff, 1, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,1000 ))
                    ParticleManager:SetParticleControl(particle_eff, 2, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
                    ParticleManager:DestroyParticle(particle_eff, false)
                    ParticleManager:ReleaseParticleIndex(particle_eff)                    
                    EmitSoundOn(zeus_ultimate_sound, caster)                    
                    caster:EmitSoundParams(zeus_ultimate_sound, 1, 3.0, 0)   
                    -- Remove the old item and add the evolved item
                    --caster:RemoveItem(ability)
                    caster:TakeItem(ability)
                    caster:AddItemByName("item_thunder_gods_might2")                                                      
                    self.evolve_check = true
                end  
            end        
        end   
	end
end
----Awekend version -----
modifier_thunder_gods_might2 = modifier_thunder_gods_might2 or class({})
local modifier_item2 = modifier_thunder_gods_might2
function modifier_item2:IsHidden() return true end
function modifier_item2:IsPurgable() return false end
function modifier_item2:RemoveOnDeath() return false end
function modifier_item2:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PROCATTACK_FEEDBACK}
end
function modifier_item2:OnCreated() 
    self.orig_dmg = 0 
    self.last_use = 0    
end
-- bonus dmg_ptc, As and all stats bonus
function modifier_item2:GetModifierBaseDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_damage_ptc") end
end
function modifier_item2:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
end
function modifier_item2:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end
end
function modifier_item2:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end
end
function modifier_item2:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end
end
function modifier_item2:GetModifierProcAttack_Feedback(keys)
	if IsServer() then
        local parent = self:GetParent()
        local target = keys.target       
        if not parent:IsRealHero() then return end 
        local ability = self:GetAbility()
        if not ability then return end
        -- Check if enough time has passed since the last usage , self.last_use is first saved as 0 in OnCreated()
        local current_time = GameRules:GetGameTime()
        if self.last_use and current_time - self.last_use < 0.15 then
            return
        end       
        local chance = ability:GetSpecialValueFor("static_chance")
        local randomSeed = math.random(1, 100)
        if randomSeed <= chance then
            local caster = self:GetCaster()
            if not target then return end
            if not target:IsAlive() then return end
            if not caster:IsAlive() then return end 
            -- Store the time when the ability was used
            self.last_use = current_time            
            local static_radius = ability:GetSpecialValueFor("static_radius") 
            local static_strikes = ability:GetSpecialValueFor("static_strikes")
            local damage_typ = DAMAGE_TYPE_PHYSICAL
            local damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
            local ss_spell_amp = ability:GetSpecialValueFor("ss_spell_amp") / 100  
            local charges = ability:GetCurrentCharges() or 0
            if charges and charges > 3000 then
                charges = 2700 + math.floor(charges / 10)
            end              
            local stats_mult = ability:GetSpecialValueFor("stats_mult_dmg") * ( charges / 20)
            local attack_dmg_mult = (ability:GetSpecialValueFor("chain_damage") / 100) + (charges / 2000)      
            local all_stats = (caster:GetAgility() + caster:GetStrength() + caster:GetIntellect(true)) * stats_mult
            local caster_attack = keys.original_damage * attack_dmg_mult
            local damage = 0
            if all_stats > caster_attack then
                damage = all_stats
            else
                damage = caster_attack
            end                
            local particleName = "particles/econ/events/ti9/maelstorm_ti9.vpcf" --"particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_maelstrom_v2_item.vpcf" --"particles/particle_test/chain_lightning_red.vpcf"
            local has_modifier = caster:HasModifier("modifier_super_scepter")
            -- uses 15% of the spell amp
            if has_modifier then
                damage = damage * (1 + caster:GetSpellAmplification(false) * ss_spell_amp)
                damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_IGNORES_BASE_PHYSICAL_ARMOR
            end 
            -- Create the chain lightning particle effect
            local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
            ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
            -- Get a list of all nearby enemies in range
            local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, static_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
            local enemies_hit = 0
            caster:EmitSoundParams("Item.Maelstrom.Chain_Lightning.Jump", 1, 0.7, 0)
            -- For each enemy found, repeat the damage and particle effect on them
            for _, enemy in pairs(enemies) do
                -- Check if the number of enemies hit is less than 4
                if enemies_hit < static_strikes then
                    local damageTable = {
                    attacker = caster,
                    victim = enemy,
                    damage = damage,
                    damage_type = damage_typ,
                    damage_flags = damage_flag,
                    ability = ability,
                    }
                    ApplyDamage(damageTable)
                   
                    -- Create the chain lightning particle effect , from enemy to the rest in his aoe(not really a chain effect)
                    local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
                    ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
                    ParticleManager:SetParticleControlEnt(particle, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
                    ParticleManager:DestroyParticle(particle, false)
                    ParticleManager:ReleaseParticleIndex(particle)
                    enemies_hit = enemies_hit + 1
                    target = enemy
                end
            end 
            local bonus_charge = 1
            local has_ss = caster:HasModifier("modifier_super_scepter")
            local marci_ult = caster:HasModifier("modifier_marci_unleash_flurry")
            --local limit = ability:GetSpecialValueFor("charge_awaken") 
            --local evolve = (charges >= limit)
            if has_ss and marci_ult then
                bonus_charge = 2								
            end	
            charges = ability:GetCurrentCharges()            
			ability:SetCurrentCharges(charges + bonus_charge)                   
        end   
	end
end


--------Aura------
modifier_item_thunder_god_might_aura = modifier_item_thunder_god_might_aura or class({})

function modifier_item_thunder_god_might_aura:IsAura() return true end
function modifier_item_thunder_god_might_aura:IsAuraActiveOnDeath() return false end
function modifier_item_thunder_god_might_aura:IsHidden() return true end
function modifier_item_thunder_god_might_aura:GetAuraDuration() return 0.2 end
function modifier_item_thunder_god_might_aura:GetModifierAura() return "modifier_item_thunder_god_might_aura_debuff" end
function modifier_item_thunder_god_might_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_thunder_god_might_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_item_thunder_god_might_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_item_thunder_god_might_aura:GetAuraRadius() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("chain_radius") end end



modifier_item_thunder_god_might_aura_debuff = modifier_item_thunder_god_might_aura_debuff or class({})
local modifier_effect = modifier_item_thunder_god_might_aura_debuff

function modifier_effect:IsHidden() return false end
function modifier_effect:IsPurgable() return false end
function modifier_effect:IsDebuff() return true end
function modifier_effect:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

if IsServer() then
	function modifier_effect:OnCreated()
        if self:GetAbility() then
		    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("chain_delay")) 
        end   
	end

	function modifier_effect:OnIntervalThink()
        if not IsServer() then return end
		if not self:GetAbility() then return end
		if self:GetAbility():IsNull() then return end
        if not self:GetCaster() then return end
        if not self:GetParent() then return end
        if not self:GetParent():IsAlive() then return end
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local damage_typ = DAMAGE_TYPE_PHYSICAL --ability:GetAbilityDamageType()
        local damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
        local stats_mult = self:GetAbility():GetSpecialValueFor("stats_mult_dmg")
        local attack_dmg_mult = self:GetAbility():GetSpecialValueFor("chain_damage") / 100
        local ss_spell_amp = self:GetAbility():GetSpecialValueFor("ss_spell_amp") / 100        
        local all_stats = 0
        local caster_attack = caster:GetAverageTrueAttackDamage(caster) * attack_dmg_mult
        local damage = caster_attack
        if caster:IsHero() then
            all_stats = (caster:GetAgility() + caster:GetStrength() + caster:GetIntellect(true)) * stats_mult
            damage = caster_attack + all_stats
        end   
        local damage_per_tick = damage 
        local has_ss_modif = caster:HasModifier("modifier_super_scepter")
         -- uses 20% of the spell amp with SS
        if has_ss_modif then
            damage_per_tick = damage_per_tick * (1 + caster:GetSpellAmplification(false)* ss_spell_amp )
            damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_IGNORES_BASE_PHYSICAL_ARMOR
        end    
        local damageTable = {
            attacker = caster,
            victim = parent,
            damage = damage_per_tick,
            damage_type = damage_typ,
            damage_flags = damage_flag,
            ability = ability,
        } 
        ApplyDamage(damageTable)
        local particleName = "particles/econ/events/ti8/maelstorm_ti8.vpcf" --"particles/particle_test/chain_lightning_green.vpcf" 
        local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)   
        self:AddParticle(particle, false, false, -1, false, false)  
        --ParticleManager:ReleaseParticleIndex(particle)   
	end
end

--------Aura Awaken------
modifier_item_thunder_god_might_aura2 = modifier_item_thunder_god_might_aura2 or class({})

function modifier_item_thunder_god_might_aura2:IsAura() return true end
function modifier_item_thunder_god_might_aura2:IsAuraActiveOnDeath() return false end
function modifier_item_thunder_god_might_aura2:IsHidden() return true end
function modifier_item_thunder_god_might_aura2:GetAuraDuration() return 0.2 end
function modifier_item_thunder_god_might_aura2:GetModifierAura() return "modifier_item_thunder_god_might_aura_debuff2" end
function modifier_item_thunder_god_might_aura2:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_thunder_god_might_aura2:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_item_thunder_god_might_aura2:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_item_thunder_god_might_aura2:GetAuraRadius() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("chain_radius") end end



modifier_item_thunder_god_might_aura_debuff2 = modifier_item_thunder_god_might_aura_debuff2 or class({})
local modifier_effect2 = modifier_item_thunder_god_might_aura_debuff2

function modifier_effect2:IsHidden() return false end
function modifier_effect2:IsPurgable() return false end
function modifier_effect2:IsDebuff() return true end
function modifier_effect2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
if IsServer() then
	function modifier_effect2:OnCreated()
        if self:GetAbility() then
		    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("chain_delay")) 
        end   
	end

	function modifier_effect2:OnIntervalThink()
		if not self:GetAbility() then return end
		if self:GetAbility():IsNull() then return end
        if not self:GetCaster() then return end
        if not self:GetParent() then return end
        if not self:GetParent():IsAlive() then return end
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local damage_typ = DAMAGE_TYPE_PHYSICAL --ability:GetAbilityDamageType()
        local damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
        local ss_spell_amp = self:GetAbility():GetSpecialValueFor("ss_spell_amp") / 100        
        local charges = ability:GetCurrentCharges() or 0
        if charges and charges > 3000 then
            charges = 2700 + math.floor(charges / 10)
        end              
        local stats_mult = ability:GetSpecialValueFor("stats_mult_dmg") * ( charges / 20)
        local attack_dmg_mult = (ability:GetSpecialValueFor("static_damage") / 100) + (charges / 500)      
        local all_stats = 0
        local caster_attack = caster:GetAverageTrueAttackDamage(caster) * attack_dmg_mult
        local damage = 0
        if caster:IsHero() then
            all_stats = (caster:GetAgility() + caster:GetStrength() + caster:GetIntellect(true)) * stats_mult
        end        
        if all_stats > caster_attack then
            damage = all_stats
        else
            damage = caster_attack
        end 
        local hp_ptc_dmg = self:GetAbility():GetSpecialValueFor("static_ptc_dmg") / 100 
        local damage_per_tick = damage + (parent:GetHealth() * hp_ptc_dmg)
        local has_ss_modif = caster:HasModifier("modifier_super_scepter")
         -- uses 20% of the spell amp with SS
        if has_ss_modif then
            damage_per_tick = damage_per_tick * (1 + caster:GetSpellAmplification(false) * ss_spell_amp )
            damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_IGNORES_BASE_PHYSICAL_ARMOR
        end    
        local damageTable = {
            attacker = caster,
            victim = parent,
            damage = damage_per_tick,
            damage_type = damage_typ,
            damage_flags = damage_flag,
            ability = ability,
        } 
        ApplyDamage(damageTable)
        local particleName = "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_maelstrom_v2_item.vpcf" --"particles/particle_test/chain_lightning_red.vpcf"  
        local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
        --ParticleManager:ReleaseParticleIndex(particle) 
        self:AddParticle(particle, false, false, -1, false, false)
	end
end

---------modifier damage type imune ---

modifier_item_thunder_god_might_immune = modifier_item_thunder_god_might_immune or class({})

function modifier_item_thunder_god_might_immune:IsHidden() return false end
function modifier_item_thunder_god_might_immune:IsPurgable() return false end
function modifier_item_thunder_god_might_immune:IsBuff() return true end
function modifier_item_thunder_god_might_immune:RemoveOnDeath() return true end
function modifier_item_thunder_god_might_immune:DeclareFunctions()
    return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE}
end

function modifier_item_thunder_god_might_immune:OnCreated()   
    if IsServer() then           
        local sound_name = "DOTA_Item.Mjollnir.Activate"
        local caster = self:GetCaster()
        local random_index = RandomInt(1, 4)
        local particle_name = ""
        local name0 = "particles/items2_fx/mjollnir_shield_unused.vpcf" -- no sparks blue aura
        --local name1 = "particles/econ/events/fall_2022/mjollnir/mjollnir_shield_fall2022.vpcf" -- dark orange 
        --local name2 = "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_mjollnir_shield.vpcf"  --purple /phys deff color
        local name3 = "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_mjollnir_shield_v2.vpcf" --more redis/phys
        local name4 = "particles/econ/events/spring_2021/mjollnir_shield_spring_2021.vpcf" -- rainbow
        local name5 = "particles/econ/events/ti9/mjollnir_shield_ti9.vpcf" --better purple effect
        local name6 = "particles/econ/events/ti10/mjollnir_shield_ti10.vpcf" -- yellow
        --local name7 = "particles/econ/events/ti8/mjollnir_shield_ti8.vpcf" --green

        if not self:GetAbility() then return end
        --local duration = self:GetAbility():GetSpecialValueFor("static_dur") + 10
        if not caster:IsAlive() then return end
        if random_index == 1 then
            caster:AddNewModifier(caster, nil, "modifier_item_thunder_physical", {})
            particle_name = name3
        elseif random_index == 2 then
            caster:AddNewModifier(caster, nil, "modifier_item_thunder_magical", {})
            particle_name = name5
            self.blue_particle = ParticleManager:CreateParticle(name0, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            self:AddParticle(self.blue_particle, false, false, -1, false, false)
        elseif random_index == 3 then
            caster:AddNewModifier(caster, nil, "modifier_item_thunder_pure", {})
            particle_name = name6
        elseif random_index == 4 then 
            caster:AddNewModifier(caster, nil, "modifier_item_thunder_physical", {})
            caster:AddNewModifier(caster, nil, "modifier_item_thunder_magical", {})
            caster:AddNewModifier(caster, nil, "modifier_item_thunder_pure", {})
            particle_name = name4
        end    
        self.shield_particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        self:AddParticle(self.shield_particle, false, false, -1, false, false)

        caster:EmitSound(sound_name)
        caster:EmitSound("DOTA_Item.Mjollnir.Loop")      
    end
end

function modifier_item_thunder_god_might_immune:GetTexture()
    --all_color_resit
    local phy_modif = self:GetParent():HasModifier("modifier_item_thunder_physical")
    local magic_modif = self:GetParent():HasModifier("modifier_item_thunder_magical")
    local pure_modif = self:GetParent():HasModifier("modifier_item_thunder_pure")
    if phy_modif and magic_modif and pure_modif then    
        return "all_color_resit"
    elseif phy_modif then 
        return "spirit_orb_red"
    elseif magic_modif then
        return "spirit_orb_blue"
    elseif pure_modif then
        return "spirit_orb"
    end
end 
function modifier_item_thunder_god_might_immune:OnRefresh()
    self:OnCreated()
end   


function modifier_item_thunder_god_might_immune:OnDestroy()
    if IsServer() then
        if self.shield_particle then
            ParticleManager:DestroyParticle(self.shield_particle, false)
            ParticleManager:ReleaseParticleIndex(self.shield_particle)
        end 
        if self.blue_particle then
            ParticleManager:DestroyParticle(self.blue_particle, false)
            ParticleManager:ReleaseParticleIndex(self.blue_particle)
        end    
        self:GetCaster():StopSound("DOTA_Item.Mjollnir.Loop")
        local physical = self:GetParent():HasModifier("modifier_item_thunder_physical")
        local magical = self:GetParent():HasModifier("modifier_item_thunder_magical")
        local pure = self:GetParent():HasModifier("modifier_item_thunder_pure")
        if physical then
            self:GetParent():RemoveModifierByName("modifier_item_thunder_physical")
        end
        if magical then
            self:GetParent():RemoveModifierByName("modifier_item_thunder_magical")            
        end
        if pure then
            self:GetParent():RemoveModifierByName("modifier_item_thunder_pure")
        end                       
    end
end

function modifier_item_thunder_god_might_immune:GetAbsoluteNoDamagePhysical()
    local pass = self:GetParent():HasModifier("modifier_item_thunder_physical")
    if pass then
        return 1
    end
    return 0   
end

function modifier_item_thunder_god_might_immune:GetAbsoluteNoDamageMagical()
    local pass = self:GetParent():HasModifier("modifier_item_thunder_magical")
    if pass then
        return 1
    end 
    return 0    
end

function modifier_item_thunder_god_might_immune:GetAbsoluteNoDamagePure()
    local pass = self:GetParent():HasModifier("modifier_item_thunder_pure")
    if pass then
        return 1
    end 
    return 0    
end

---speed modifier ---
modifier_item_thunder_god_might_speed = modifier_item_thunder_god_might_speed or class({})
local modifier_item_speed = modifier_item_thunder_god_might_speed
function modifier_item_speed:IsHidden() return true end
function modifier_item_speed:IsPurgable() return false end
function modifier_item_speed:RemoveOnDeath() return true end
function modifier_item_speed:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT}
end
function modifier_item_speed:GetModifierMoveSpeedBonus_Constant() return 1000 end
function modifier_item_speed:GetModifierIgnoreMovespeedLimit() return 1 end
    
----immune type indicators modifiers---
--physical--
modifier_item_thunder_physical = modifier_item_thunder_physical or class({})
local physical = modifier_item_thunder_physical
function physical:IsHidden() return true end
function physical:IsPurgable() return false end
function physical:RemoveOnDeath() return true end

--magical-
modifier_item_thunder_magical = modifier_item_thunder_magical or class({})
local magical = modifier_item_thunder_magical
function magical:IsHidden() return true end
function magical:IsPurgable() return false end
function magical:RemoveOnDeath() return true end

--pure--
modifier_item_thunder_pure = modifier_item_thunder_pure or class({})
local pure = modifier_item_thunder_pure
function pure:IsHidden() return true end
function pure:IsPurgable() return false end
function pure:RemoveOnDeath() return true end

----Internal CD buff limiter---

modifier_item_thunder_cd_limit = modifier_item_thunder_cd_limit or class({})
local cd_buff = modifier_item_thunder_cd_limit
function cd_buff:IsHidden() return false end
function cd_buff:IsPurgable() return false end
function cd_buff:RemoveOnDeath() return false end
function cd_buff:IsDebuff() return true end

------------------
--LIGHT CROSSBOW--
------------------
LinkLuaModifier("modifier_light_crossbow_1", "items/light_crossbow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_light_crossbow_1_aura", "items/light_crossbow.lua", LUA_MODIFIER_MOTION_NONE)
if item_light_crossbow == nil then item_light_crossbow = class({}) end
function item_light_crossbow:GetIntrinsicModifierName() return "modifier_light_crossbow_1" end

if modifier_light_crossbow_1 == nil then modifier_light_crossbow_1 = class({}) end
function modifier_light_crossbow_1:IsHidden() return true end
function modifier_light_crossbow_1:IsPurgable() return false end
function modifier_light_crossbow_1:RemoveOnDeath() return false end
function modifier_light_crossbow_1:DeclareFunctions()
	return { MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,}
end
function modifier_light_crossbow_1:GetModifierProcAttack_Feedback(keys)
	if IsServer() then
        local parent = self:GetParent()
        local target = keys.target
        --if parent ~= keys.attacker then return end
        if not parent:IsRealHero() then return end 
        local ability = self:GetAbility()
        if not ability then return end
        local chance = ability:GetSpecialValueFor("static_chance")
        local randomSeed = math.random(1, 100)
        if randomSeed <= chance then
            local caster = self:GetCaster()
            if not target then return end
            if not target:IsAlive() then return end
            if not caster:IsAlive() then return end
			local static_radius = ability:GetSpecialValueFor("static_radius")
			local static_strikes = ability:GetSpecialValueFor("static_strikes")
            local damage_typ = DAMAGE_TYPE_PHYSICAL
            local damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
            local attack_dmg_mult = ability:GetSpecialValueFor("chain_damage") / 100        
            local caster_attack = caster:GetAverageTrueAttackDamage(target) * attack_dmg_mult
            local damage = caster_attack           
            local particleName = "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_maelstrom_v2_item.vpcf" --"particles/items_fx/chain_lightning.vpcf"
            -- Create the chain lightning particle effect
            local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
            ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
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
                    ParticleManager:ReleaseParticleIndex(particle)
                    enemies_hit = enemies_hit + 1
                end
            end
            local bonus_charge = 1
            local has_ss = caster:HasModifier("modifier_super_scepter")
            local marci_ult = caster:HasModifier("modifier_marci_unleash_flurry")
            local charges = ability:GetCurrentCharges()
            local limit = ability:GetSpecialValueFor("charge_awaken") 
            local evolve = (charges >= limit)
            if has_ss and marci_ult then
                bonus_charge = 2								
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
                    EmitSoundOn(zeus_ultimate_sound, caster)                    
                    caster:EmitSoundParams(zeus_ultimate_sound, 1, 3.0, 0)   
                    -- Remove the old item and add the evolved item
                    caster:RemoveItem(ability)
                    caster:AddItemByName("item_light_crossbow_2")                                                      
                    self.evolve_check = true
                end  
            end        
        end   
	end
end

function modifier_light_crossbow_1:IsAura() return true end
function modifier_light_crossbow_1:IsAuraActiveOnDeath() return false end
function modifier_light_crossbow_1:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_light_crossbow_1:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_light_crossbow_1:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_light_crossbow_1:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_light_crossbow_1:GetAuraDuration() return FrameTime() end
function modifier_light_crossbow_1:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_light_crossbow_1:GetModifierAura() return "modifier_light_crossbow_1_aura" end
-----------------------
--LIGHT CROSSBOW AURA--
-----------------------
if modifier_light_crossbow_1_aura == nil then modifier_light_crossbow_1_aura = class({}) end
function modifier_light_crossbow_1_aura:IsHidden() return false end
function modifier_light_crossbow_1_aura:IsDebuff() return false end
function modifier_light_crossbow_1_aura:IsPurgable() return false end
function modifier_light_crossbow_1_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_light_crossbow_1_aura:DeclareFunctions()
	return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end
function modifier_light_crossbow_1_aura:GetModifierBaseDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_aura") end
end
function modifier_light_crossbow_1_aura:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_aura") end
end
function modifier_light_crossbow_1_aura:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ms_aura") end
end

-------------------
--LIGHT CROSSBOW2--
-------------------
LinkLuaModifier("modifier_light_crossbow_2", "items/light_crossbow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_light_crossbow_2_aura", "items/light_crossbow.lua", LUA_MODIFIER_MOTION_NONE)
if item_light_crossbow_2 == nil then item_light_crossbow_2 = class({}) end
function item_light_crossbow_2:GetIntrinsicModifierName() return "modifier_light_crossbow_2" end

if modifier_light_crossbow_2 == nil then modifier_light_crossbow_2 = class({}) end
function modifier_light_crossbow_2:IsHidden() return true end
function modifier_light_crossbow_2:IsPurgable() return false end
function modifier_light_crossbow_2:RemoveOnDeath() return false end
function modifier_light_crossbow_2:DeclareFunctions()
	return { MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,}
end
function modifier_light_crossbow_2:GetModifierProcAttack_Feedback(keys)
	if IsServer() then
        local parent = self:GetParent()
        local target = keys.target
        --if parent ~= keys.attacker then return end
        if not parent:IsRealHero() then return end 
        local ability = self:GetAbility()
        if not ability then return end
        local chance = ability:GetSpecialValueFor("static_chance")
        local randomSeed = math.random(1, 100)
        if randomSeed <= chance then
            local caster = self:GetCaster()
            if not target then return end
            if not target:IsAlive() then return end
            if not caster:IsAlive() then return end
			local static_radius = ability:GetSpecialValueFor("static_radius")
			local static_strikes = ability:GetSpecialValueFor("static_strikes")
            local damage_typ = DAMAGE_TYPE_PHYSICAL
            local damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
            local attack_dmg_mult = ability:GetSpecialValueFor("chain_damage") / 100        
            local caster_attack = caster:GetAverageTrueAttackDamage(target) * attack_dmg_mult
            local damage = caster_attack           
            local particleName = "particles/econ/events/ti10/maelstrom_ti10.vpcf" --"particles/items_fx/chain_lightning.vpcf"
            -- Create the chain lightning particle effect
            local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
            ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
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
                    ParticleManager:ReleaseParticleIndex(particle)
                    enemies_hit = enemies_hit + 1
                end
            end
            local bonus_charge = 1
            local has_ss = caster:HasModifier("modifier_super_scepter")
            local marci_ult = caster:HasModifier("modifier_marci_unleash_flurry")
            local charges = ability:GetCurrentCharges()
            local limit = ability:GetSpecialValueFor("charge_awaken") 
            local evolve = (charges >= limit)
            if has_ss and marci_ult then
                bonus_charge = 2								
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
                    EmitSoundOn(zeus_ultimate_sound, caster)                    
                    caster:EmitSoundParams(zeus_ultimate_sound, 1, 3.0, 0)   
                    -- Remove the old item and add the evolved item
                    caster:RemoveItem(ability)
                    caster:AddItemByName("item_light_crossbow_3")                                                      
                    self.evolve_check = true
                end  
            end        
        end   
	end
end
function modifier_light_crossbow_2:IsAura() return true end
function modifier_light_crossbow_2:IsAuraActiveOnDeath() return false end
function modifier_light_crossbow_2:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_light_crossbow_2:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_light_crossbow_2:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_light_crossbow_2:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_light_crossbow_2:GetAuraDuration() return FrameTime() end
function modifier_light_crossbow_2:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_light_crossbow_2:GetModifierAura() return "modifier_light_crossbow_2_aura" end
------------------------
--LIGHT CROSSBOW2 AURA--
------------------------
if modifier_light_crossbow_2_aura == nil then modifier_light_crossbow_2_aura = class({}) end
function modifier_light_crossbow_2_aura:IsHidden() return false end
function modifier_light_crossbow_2_aura:IsDebuff() return false end
function modifier_light_crossbow_2_aura:IsPurgable() return false end
function modifier_light_crossbow_2_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_light_crossbow_2_aura:DeclareFunctions()
	return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end
function modifier_light_crossbow_2_aura:GetModifierBaseDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_aura") end
end
function modifier_light_crossbow_2_aura:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_aura") end
end
function modifier_light_crossbow_2_aura:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ms_aura") end
end

-------------------
--LIGHT CROSSBOW3--
-------------------
LinkLuaModifier("modifier_light_crossbow_3", "items/light_crossbow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_light_crossbow_3_aura", "items/light_crossbow.lua", LUA_MODIFIER_MOTION_NONE)
if item_light_crossbow_3 == nil then item_light_crossbow_3 = class({}) end
function item_light_crossbow_3:GetIntrinsicModifierName() return "modifier_light_crossbow_3" end

if modifier_light_crossbow_3 == nil then modifier_light_crossbow_3 = class({}) end
function modifier_light_crossbow_3:IsHidden() return true end
function modifier_light_crossbow_3:IsPurgable() return false end
function modifier_light_crossbow_3:RemoveOnDeath() return false end
function modifier_light_crossbow_3:DeclareFunctions()
	return { MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,}
end
function modifier_light_crossbow_3:GetModifierProcAttack_Feedback(keys)
	if IsServer() then
        local parent = self:GetParent()
        local target = keys.target
        --if parent ~= keys.attacker then return end
        if not parent:IsRealHero() then return end 
        local ability = self:GetAbility()
        if not ability then return end
        local chance = ability:GetSpecialValueFor("static_chance")
        local randomSeed = math.random(1, 100)
        if randomSeed <= chance then
            local caster = self:GetCaster()
            if not target then return end
            if not target:IsAlive() then return end
            if not caster:IsAlive() then return end
			local static_radius = ability:GetSpecialValueFor("static_radius")
			local static_strikes = ability:GetSpecialValueFor("static_strikes")
            local damage_typ = DAMAGE_TYPE_PHYSICAL
            local damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
            local attack_dmg_mult = ability:GetSpecialValueFor("chain_damage") / 100        
            local caster_attack = caster:GetAverageTrueAttackDamage(target) * attack_dmg_mult
            local damage = caster_attack           
            local particleName = "particles/econ/events/fall_2022/maelstrom/maelstrom_fall2022.vpcf" --"particles/items_fx/chain_lightning.vpcf"
            -- Create the chain lightning particle effect
            local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
            ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
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
                    ParticleManager:ReleaseParticleIndex(particle)
                    enemies_hit = enemies_hit + 1
                end
            end
            local bonus_charge = 1
            local has_ss = caster:HasModifier("modifier_super_scepter")
            local marci_ult = caster:HasModifier("modifier_marci_unleash_flurry")
            local charges = ability:GetCurrentCharges()
            local limit = ability:GetSpecialValueFor("charge_awaken") 
            local evolve = (charges >= limit)
            if has_ss and marci_ult then
                bonus_charge = 2								
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
                    EmitSoundOn(zeus_ultimate_sound, caster)                    
                    caster:EmitSoundParams(zeus_ultimate_sound, 1, 3.0, 0)   
                    -- Remove the old item and add the evolved item
                    caster:RemoveItem(ability)
                    caster:AddItemByName("item_thunder_hammer")                                                      
                    self.evolve_check = true
                end  
            end        
        end   
	end
end
function modifier_light_crossbow_3:IsAura() return true end
function modifier_light_crossbow_3:IsAuraActiveOnDeath() return false end
function modifier_light_crossbow_3:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_light_crossbow_3:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_light_crossbow_3:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_light_crossbow_3:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_light_crossbow_3:GetAuraDuration() return FrameTime() end
function modifier_light_crossbow_3:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_light_crossbow_3:GetModifierAura() return "modifier_light_crossbow_3_aura" end


------------------------
--LIGHT CROSSBOW3 AURA--
------------------------
if modifier_light_crossbow_3_aura == nil then modifier_light_crossbow_3_aura = class({}) end
function modifier_light_crossbow_3_aura:IsHidden() return false end
function modifier_light_crossbow_3_aura:IsDebuff() return false end
function modifier_light_crossbow_3_aura:IsPurgable() return false end
function modifier_light_crossbow_3_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_light_crossbow_3_aura:DeclareFunctions()
	return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end
function modifier_light_crossbow_3_aura:GetModifierBaseDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_aura") end
end
function modifier_light_crossbow_3_aura:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_aura") end
end
function modifier_light_crossbow_3_aura:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ms_aura") end
end


-----------------
--HAMMER OF GOD--
-----------------
LinkLuaModifier("modifier_thunder_hammer", "items/light_crossbow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_thunder_hammer_aura", "items/light_crossbow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_thunder_hammer_static", "items/light_crossbow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_thunder_hammer_chain_lightning", "items/light_crossbow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_thunder_power", "items/light_crossbow.lua", LUA_MODIFIER_MOTION_NONE)
if item_thunder_hammer == nil then item_thunder_hammer = class({}) end
function item_thunder_hammer:GetIntrinsicModifierName() return "modifier_thunder_hammer" end
function item_thunder_hammer:GetCastRange(location, target)
	if IsClient() then return self.BaseClass.GetCastRange(self, location, target) end
end
function item_thunder_hammer:OnSpellStart()
	local target = self:GetCursorTarget()
	target:EmitSound("DOTA_Item.Mjollnir.Activate")
	target:EmitSound("DOTA_Item.Mjollnir.Loop")
	target:AddNewModifier(target, self, "modifier_thunder_hammer_static", {duration = self:GetSpecialValueFor("static_dur")})
end

if modifier_thunder_hammer == nil then modifier_thunder_hammer = class({}) end
function modifier_thunder_hammer:IsHidden() return true end
function modifier_thunder_hammer:IsPurgable() return false end
function modifier_thunder_hammer:RemoveOnDeath() return false end
function modifier_thunder_hammer:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_thunder_hammer:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
	if self:GetAbility() then
		self.bonus_damage = self:GetCaster():GetLevel() * self:GetAbility():GetSpecialValueFor("bonus_damage_lvl")
		self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
		self.chain_chance = self:GetAbility():GetSpecialValueFor("chain_chance")
		self.chain_cooldown = self:GetAbility():GetSpecialValueFor("chain_cooldown")
	else
		self.bonus_damage = 0 self.bonus_attack_speed = 0
		self.chain_chance = 0 self.chain_cooldown = 0
	end
	self.bChainCooldown = false
end
function modifier_thunder_hammer:OnIntervalThink()
	self.bChainCooldown = false
	self:StartIntervalThink(-1)
end
function modifier_thunder_hammer:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ORDER}
end
function modifier_thunder_hammer:GetModifierPreAttack_BonusDamage() return self.bonus_damage end
function modifier_thunder_hammer:GetModifierAttackSpeedBonus_Constant() return self.bonus_attack_speed end
function modifier_thunder_hammer:OnAttack(keys)
	if keys.attacker == self:GetParent() and self:GetParent():IsAlive() and not self.bChainCooldown and not self:GetParent():IsIllusion() and self:GetParent():GetTeamNumber() ~= keys.target:GetTeamNumber() then
	self.true_hit = true
	end
end
function modifier_thunder_hammer:OnAttackLanded(keys)
	if keys.attacker == self:GetParent() and self:GetParent():IsAlive() and not self.bChainCooldown and not self:GetParent():IsIllusion() and self:GetParent():GetTeamNumber() ~= keys.target:GetTeamNumber() and RollPseudoRandom(self.chain_chance, self:GetAbility()) and self.true_hit then
		self:GetParent():EmitSound("Item.Maelstrom.Chain_Lightning")
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_thunder_hammer_chain_lightning", {starting_unit_entindex = keys.target:entindex()})

		--UP: Lightning Shard
		if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
			local power_buff = self:GetAbility():GetSpecialValueFor("buff_dur")
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_thunder_power", {duration = power_buff})
		end
		---------------------

		self.bChainCooldown = true
		self:StartIntervalThink(self.chain_cooldown)
		self.true_hit = false
		------gain stacks for Evolution---
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local bonus_charge = 1
		local has_ss = caster:HasModifier("modifier_super_scepter")
		local marci_ult = caster:HasModifier("modifier_marci_unleash_flurry")
		local charges = ability:GetCurrentCharges()
		local limit = ability:GetSpecialValueFor("charge_awaken") 
		local evolve = (charges >= limit)		
		if has_ss and marci_ult then
			bonus_charge = 2								
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
				EmitSoundOn(zeus_ultimate_sound, caster)                    
				caster:EmitSoundParams(zeus_ultimate_sound, 1, 3.0, 0)   
				-- Remove the old item and add the evolved ite			
				caster:RemoveItem(ability)
				caster:AddItemByName("item_thunder_gods_might")								
				self.evolve_check = true
			end  
		end 
	end
end
function modifier_thunder_hammer:IsAura() return true end
function modifier_thunder_hammer:IsAuraActiveOnDeath() return false end
function modifier_thunder_hammer:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_thunder_hammer:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_thunder_hammer:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_thunder_hammer:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_thunder_hammer:GetAuraDuration() return FrameTime() end
function modifier_thunder_hammer:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_thunder_hammer:GetModifierAura() return "modifier_thunder_hammer_aura" end

-----------------
--THUNDER POWER--
-----------------
modifier_thunder_power = class({})
function modifier_thunder_power:IsHidden() return false end
function modifier_thunder_power:IsDebuff() return false end
function modifier_thunder_power:IsPurgable() return false end
function modifier_thunder_power:RemoveOnDeath() return false end
function modifier_thunder_power:OnCreated() if not IsServer() then return end self.stack_table = {} self:StartIntervalThink(1) self:SetStackCount(1) end
function modifier_thunder_power:OnStackCountChanged(prev_stacks)
	if not IsServer() then return end
	local stacks = self:GetStackCount()
	if stacks > prev_stacks then
		table.insert(self.stack_table, GameRules:GetGameTime())
	end
end
function modifier_thunder_power:OnIntervalThink()
	if self:GetAbility() then
		local repeat_needed = true
		local power_buff = self:GetAbility():GetSpecialValueFor("buff_dur")
		while repeat_needed do
			local item_time = self.stack_table[1]
			if GameRules:GetGameTime() - item_time >= power_buff then
				if self:GetStackCount() == 1 then
					if not self:IsNull() then
						self:Destroy()
					end	
					break
				else
					table.remove(self.stack_table, 1)
					self:DecrementStackCount()
				end
			else
				repeat_needed = false
			end
		end
	end
end
function modifier_thunder_power:OnRefresh() if not IsServer() then return end self:IncrementStackCount() end
function modifier_thunder_power:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_TOOLTIP} end
function modifier_thunder_power:GetModifierAttackSpeedBonus_Constant() if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("buff_as") end end
function modifier_thunder_power:OnTooltip() if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("buff_as") end end
----------------------------------
--THUNDER HAMMER CHAIN LIGHTNING--
----------------------------------
modifier_thunder_hammer_chain_lightning = modifier_thunder_hammer_chain_lightning or class({})
function modifier_thunder_hammer_chain_lightning:IsHidden() return true end
function modifier_thunder_hammer_chain_lightning:IsPurgable() return false end
function modifier_thunder_hammer_chain_lightning:RemoveOnDeath() return false end
function modifier_thunder_hammer_chain_lightning:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_thunder_hammer_chain_lightning:OnCreated(keys)
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
	if not IsServer() then return end
	if self:GetAbility() then
		if self:GetCaster() then
			local ability = self:GetAbility()
			local caster = self:GetCaster()
			local lvl_dmg = caster:GetLevel() * ability:GetSpecialValueFor("chain_damage")
			local attack_dmg_mult = ability:GetSpecialValueFor("static_damage") / 100
			local caster_attack = caster:GetAverageTrueAttackDamage(caster) * attack_dmg_mult
			local damage = caster_attack + lvl_dmg
			self.chain_damage = damage
		else
			self.chain_damage = self:GetAbility():GetSpecialValueFor("chain_damage")
		end	
		self.chain_strikes = self:GetAbility():GetSpecialValueFor("chain_strikes")
		self.chain_radius = self:GetAbility():GetSpecialValueFor("chain_radius")
		self.chain_delay = self:GetAbility():GetSpecialValueFor("chain_delay")
	else
		self.chain_damage = 0 self.chain_strikes = 0 self.chain_radius = 0 self.chain_delay = 0
	end
	self.starting_unit_entindex	= keys.starting_unit_entindex
	if self.starting_unit_entindex and EntIndexToHScript(self.starting_unit_entindex) then
		self.current_unit = EntIndexToHScript(self.starting_unit_entindex)
	else
		if self:IsNull() then return end
		self:Destroy()
		return
	end
	self.units_affected = {}
	self.unit_counter = 0
	self:OnIntervalThink()
	self:StartIntervalThink(self.chain_delay)
end
function modifier_thunder_hammer_chain_lightning:OnIntervalThink()
	self.zapped = false
	for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self.current_unit:GetAbsOrigin(), nil, self.chain_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)) do
		if not self.units_affected[enemy] then
			enemy:EmitSound("Item.Maelstrom.Chain_Lightning.Jump")
			self.zap_particle = ParticleManager:CreateParticle("particles/econ/events/spring_2021/maelstrom_spring_2021.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.current_unit)
			if self.unit_counter == 0 then
				ParticleManager:SetParticleControlEnt(self.zap_particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			else
				ParticleManager:SetParticleControlEnt(self.zap_particle, 0, self.current_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", self.current_unit:GetAbsOrigin(), true)
			end
			ParticleManager:SetParticleControlEnt(self.zap_particle, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(self.zap_particle, 2, Vector(1, 1, 1))
			ParticleManager:ReleaseParticleIndex(self.zap_particle)
			self.unit_counter = self.unit_counter + 1
			self.current_unit = enemy
			self.units_affected[self.current_unit] = true
			self.zapped = true
			ApplyDamage({ victim = enemy, damage = self.chain_damage, damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, attacker = self:GetCaster(), ability = self:GetAbility() })
			break
		end
	end
	if (self.unit_counter >= self.chain_strikes and self.chain_strikes > 0) or not self.zapped then
		self:StartIntervalThink(-1)
		if self:IsNull() then return end
		self:Destroy()
	end
end
function modifier_thunder_hammer_chain_lightning:CheckState()
	return {[MODIFIER_STATE_CANNOT_MISS] = true}
end

-------------------------
--THUNDER HAMMER STATIC--
-------------------------
modifier_thunder_hammer_static = modifier_thunder_hammer_static or class({})
function modifier_thunder_hammer_static:GetStatusEffectName() return "particles/econ/events/ti8/mjollnir_shield_ti8.vpcf" end
function modifier_thunder_hammer_static:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
	if not IsServer() then return end
	if self:GetAbility() then
		if self:GetCaster() then
			local ability = self:GetAbility()
			local caster = self:GetCaster()
			local lvl_dmg = caster:GetLevel() * ability:GetSpecialValueFor("chain_damage")
			local attack_dmg_mult = ability:GetSpecialValueFor("static_damage") / 100
			local caster_attack = caster:GetAverageTrueAttackDamage(caster) * attack_dmg_mult
			local damage = caster_attack + lvl_dmg
			self.static_damage = damage
		else
			self.static_damage = self:GetAbility():GetSpecialValueFor("static_damage")	
		end
		self.static_chance = self:GetAbility():GetSpecialValueFor("static_chance")
		self.static_strikes = self:GetAbility():GetSpecialValueFor("static_strikes")
		self.static_radius = self:GetAbility():GetSpecialValueFor("static_radius")
		self.static_cooldown = self:GetAbility():GetSpecialValueFor("static_cooldown")
	else
		self.static_chance = 0 self.static_strikes = 0 self.static_damage = 0 self.static_radius = 0 self.static_cooldown = 0
	end
	local name7 = "particles/econ/events/ti8/mjollnir_shield_ti8.vpcf" --green
	self.bStaticCooldown = false
	self.shield_particle = ParticleManager:CreateParticle(name7, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:AddParticle(self.shield_particle, false, false, -1, false, false)
end
function modifier_thunder_hammer_static:OnIntervalThink()
	self.bStaticCooldown = false
	self:StartIntervalThink(-1)
end
function modifier_thunder_hammer_static:OnDestroy()
	if not IsServer() then return end
	self:GetParent():StopSound("DOTA_Item.Mjollnir.Loop")
end
function modifier_thunder_hammer_static:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_TOOLTIP} end
function modifier_thunder_hammer_static:OnTakeDamage(keys)
	if self:GetAbility() and keys.unit == self:GetParent() and keys.attacker ~= self:GetParent() and not self.bStaticCooldown and RollPseudoRandom(self.static_chance, self:GetAbility()) then
		self:GetParent():EmitSound("Item.Maelstrom.Chain_Lightning.Jump")
		if (keys.attacker:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() <= self.static_radius and not keys.attacker:IsBuilding() and not keys.attacker:IsOther() and keys.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
			local static_particle = nil
			static_particle = ParticleManager:CreateParticle("particles/econ/events/ti8/maelstorm_ti8.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.attacker)
			ParticleManager:SetParticleControlEnt(static_particle, 0, keys.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.attacker:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(static_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(static_particle)
			ApplyDamage({ victim = keys.attacker, damage = self.static_damage, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE, attacker = self:GetCaster(), ability = self:GetAbility() })
		end
		local unit_count = 0
		for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.static_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)) do
			if enemy ~= keys.attacker then
				static_particle = ParticleManager:CreateParticle("particles/econ/events/ti8/maelstorm_ti8.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
				ParticleManager:SetParticleControlEnt(static_particle, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(static_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(static_particle)
				ApplyDamage({ victim = enemy, damage = self.static_damage, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE, attacker = self:GetCaster(), ability = self:GetAbility() })
				unit_count = unit_count + 1
				if (unit_count >= self.static_strikes and self.static_strikes > 0) then
					break
				end
			end
		end
		self.bStaticCooldown = true
		self:StartIntervalThink(self.static_cooldown)
	end
end
function modifier_thunder_hammer_static:OnTooltip() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("static_chance") end end

-----------------------
--THUNDER HAMMER AURA--
-----------------------
if modifier_thunder_hammer_aura == nil then modifier_thunder_hammer_aura = class({}) end
function modifier_thunder_hammer_aura:IsHidden() return false end
function modifier_thunder_hammer_aura:IsDebuff() return false end
function modifier_thunder_hammer_aura:IsPurgable() return false end
function modifier_thunder_hammer_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_thunder_hammer_aura:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end
function modifier_thunder_hammer_aura:GetModifierPreAttack_BonusDamage()
	local parent_lvl = self:GetParent():GetLevel()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_aura") * parent_lvl end
end
function modifier_thunder_hammer_aura:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_aura") end
end
function modifier_thunder_hammer_aura:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("ms_aura") end
end
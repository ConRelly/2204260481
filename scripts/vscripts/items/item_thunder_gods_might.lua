-- Register the item
LinkLuaModifier("modifier_thunder_gods_might", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_god_might_immune", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_god_might_speed", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_god_might_aura", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_god_might_aura_debuff", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_physical", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_magical", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_thunder_pure", "items/item_thunder_gods_might.lua", LUA_MODIFIER_MOTION_NONE)


item_thunder_gods_might = item_thunder_gods_might or class({})
local item = item_thunder_gods_might

function item:GetIntrinsicModifierName()
    return "modifier_thunder_gods_might"
end


function item:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local duration = 10
    local radius = 2000
    caster:AddNewModifier(caster, ability, "modifier_item_thunder_god_might_immune", {duration = duration})
    -- Apply the movespeed bonus and remove the movespeed limit
    caster:AddNewModifier(caster, ability, "modifier_item_thunder_god_might_speed", {duration = duration})

    -- Apply the modifier aura that affects enemys: every 0.3s deals damage_per_tick as physical damage that ignores base armor
    caster:AddNewModifier(caster, ability, "modifier_item_thunder_god_might_aura", {duration = duration})

    -- play a sound based on the selected damage type

    local sound_name = "DOTA_Item.Mjolnir.Activate"
    EmitSoundOn(sound_name, caster)    

end

modifier_thunder_gods_might = modifier_thunder_gods_might or class({})
local modifier_item = modifier_thunder_gods_might
function modifier_item:IsHidden() return true end
function modifier_item:IsPurgable() return false end
function modifier_item:RemoveOnDeath() return false end
function modifier_item:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PROCATTACK_FEEDBACK}
end
function modifier_item:OnCreated()
    if IsServer() then
        if self:GetAbility() and self:GetCaster() then
            self.cd = self:GetAbility():GetSpecialValueFor("feather_cd") * self:GetCaster():GetCooldownReduction()
        end    
    end    
end
-- bonus dmg and all stats bonus
function modifier_item:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage") end
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
        local randomSeed = math.random(1, 100)
        if randomSeed <= 10 then
            local ability = self:GetAbility()
            local caster = self:GetCaster()
            if not target:IsAlive() then return end
            if not ability then return end
            if not target then return end
            local damage_typ = DAMAGE_TYPE_PHYSICAL
            local damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
            local all_stats = caster:GetAgility() + caster:GetStrength() + caster:GetIntellect()
            local caster_attack = caster:GetAverageTrueAttackDamage(target)
            local has_modifier = caster:HasModifier("modifier_super_scepter")
            local damage = caster_attack + all_stats
            local particleName = "particles/items_fx/chain_lightning.vpcf"
            -- uses 20% of the spell amp
            if has_modifier then
                damage = damage * ((1 + caster:GetSpellAmplification(false)) /5)
                damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_IGNORES_BASE_PHYSICAL_ARMOR
            end 
            -- Create the chain lightning particle effect
            local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
            ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(particle)
            -- Get a list of all nearby enemies within a 900 range
            local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, 900, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
            local enemies_hit = 0
            caster:EmitSoundParams("Item.Maelstrom.Chain_Lightning.Jump", 1, 0.7, 0)
            -- For each enemy found, repeat the damage and particle effect on them
            for _, enemy in pairs(enemies) do
                -- Check if the number of enemies hit is less than 4
                if enemies_hit < 4 then
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

        end   
	end
end
--------Aura------
modifier_item_thunder_god_might_aura = modifier_item_thunder_god_might_aura or class({})

function modifier_item_thunder_god_might_aura:IsAura() return true end
function modifier_item_thunder_god_might_aura:IsAuraActiveOnDeath() return false end
function modifier_item_thunder_god_might_aura:IsHidden() return true end
function modifier_item_thunder_god_might_aura:GetAuraDuration() return 1 end
function modifier_item_thunder_god_might_aura:GetModifierAura() return "modifier_item_thunder_god_might_aura_debuff" end
function modifier_item_thunder_god_might_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_thunder_god_might_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_item_thunder_god_might_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_item_thunder_god_might_aura:GetAuraRadius() return 2000 end



modifier_item_thunder_god_might_aura_debuff = modifier_item_thunder_god_might_aura_debuff or class({})
local modifier_effect = modifier_item_thunder_god_might_aura_debuff

function modifier_effect:IsHidden() return false end
function modifier_effect:IsPurgable() return false end
function modifier_effect:IsDebuff() return true end

if IsServer() then
	function modifier_effect:OnCreated()
		--self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("interval")) 
        self:StartIntervalThink(0.3) 
	end

	function modifier_effect:OnIntervalThink()
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
        local all_stats = caster:GetAgility() + caster:GetStrength() + caster:GetIntellect()
        local caster_attack = caster:GetAverageTrueAttackDamage(caster)
        local damage = caster_attack + all_stats
        local damage_per_tick = ((parent:GetHealth() * 0.01) + damage)
        local has_ss_modif = caster:HasModifier("modifier_super_scepter")
         -- uses 20% of the spell amp with SS
        if has_ss_modif then
            damage_per_tick = damage_per_tick * ((1 + caster:GetSpellAmplification(false)) /5)
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
        local particleName = "particles/items_fx/chain_lightning.vpcf" --chain_lightning_b.vpcf
        local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)        
	end
end

---------modifier damage type imune ---

modifier_item_thunder_god_might_immune = modifier_item_thunder_god_might_immune or class({})

function modifier_item_thunder_god_might_immune:IsHidden() return false end
function modifier_item_thunder_god_might_immune:IsPurgable() return false end
function modifier_item_thunder_god_might_immune:IsBuff() return true end
function modifier_item_thunder_god_might_immune:RemoveOnDeath() return true end
function modifier_item_thunder_god_might_immune:GetStatusEffectName() return "particles/status_fx/status_effect_mjollnir_shield.vpcf" end   
function modifier_item_thunder_god_might_immune:DeclareFunctions()
    return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE}
end

function modifier_item_thunder_god_might_immune:OnCreated()   
    if IsServer() then           
        local sound_name = "DOTA_Item.Mjollnir.Activate"
        local caster = self:GetCaster()
        local random_index = RandomInt(1, 3)
        local duration = 10
        if not caster:IsAlive() then return end
        if random_index == 1 then
            caster:AddNewModifier(caster, nil, "modifier_item_thunder_physical", {})
            print("OnCreated type imune: physical ")
        elseif random_index == 2 then
            caster:AddNewModifier(caster, nil, "modifier_item_thunder_magical", {})
            print("OnCreated type imune: magical ")
        elseif random_index == 3 then
            caster:AddNewModifier(caster, nil, "modifier_item_thunder_pure", {}) 
            print("OnCreated type imune: pure")  
        end    

        self.shield_particle = ParticleManager:CreateParticle("particles/items2_fx/mjollnir_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        self:AddParticle(self.shield_particle, false, false, -1, false, false)

        caster:EmitSound(sound_name)
        caster:EmitSound("DOTA_Item.Mjollnir.Loop")      
    end
end

function modifier_item_thunder_god_might_immune:GetTexture()
    if self:GetParent():HasModifier("modifier_item_thunder_physical") then
        return "spirit_orb_red"
    elseif self:GetParent():HasModifier("modifier_item_thunder_magical") then
        return "spirit_orb_blue"
    elseif self:GetParent():HasModifier("modifier_item_thunder_pure") then
        return "spirit_orb"
    end
end 
function modifier_item_thunder_god_might_immune:OnRefresh()
    self:OnCreated()
end   


function modifier_item_thunder_god_might_immune:OnDestroy()
    if IsServer() then
        if self.particle then
            ParticleManager:DestroyParticle(self.particle, false)
            ParticleManager:ReleaseParticleIndex(self.particle)
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
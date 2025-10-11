--------------------------------------------------------------------------------
drow_ranger_multishot_lua = class({})
LinkLuaModifier("modifier_drow_ranger_multishot_lua", "lua_abilities/drow_ranger_multishot_lua/modifier_drow_ranger_multishot_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drow_ranger_multishot_lua_stacks", "lua_abilities/drow_ranger_multishot_lua/drow_ranger_multishot_lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Passive Modifier
function drow_ranger_multishot_lua:GetIntrinsicModifierName()
    return "modifier_drow_ranger_multishot_lua"
end

--------------------------------------------------------------------------------
-- Projectile
function drow_ranger_multishot_lua:OnProjectileHit_ExtraData(target, location, data)
    if not target then
        return
    end
    --check caster
    local caster = self:GetCaster()

    if caster and IsValidEntity(caster) and caster:IsAlive() then -- these can trigger on illusions and have travel time , so caster can be deleted by the time it executes
       -- get value
        local damage_modifier = self:GetSpecialValueFor("damage_modifier")
        local agi_multiplier = self:GetSpecialValueFor("agi_multiplier")
        -- Talent tree
        local special_multishot_agi_multiplier_lua = self:GetCaster():FindAbilityByName("special_multishot_agi_multiplier_lua")
        if (special_multishot_agi_multiplier_lua and special_multishot_agi_multiplier_lua:GetLevel() ~= 0) then
            agi_multiplier = agi_multiplier + special_multishot_agi_multiplier_lua:GetSpecialValueFor("value")
        end
        -- Talent tree
        local special_multishot_damage_modifier_lua = self:GetCaster():FindAbilityByName("special_multishot_damage_modifier_lua")
        if (special_multishot_damage_modifier_lua and special_multishot_damage_modifier_lua:GetLevel() ~= 0) then
            damage_modifier = damage_modifier + special_multishot_damage_modifier_lua:GetSpecialValueFor("value")
        end

        local damage = (damage_modifier / 100) * caster:GetAverageTrueAttackDamage(caster) + math.floor(caster:GetAgility() * agi_multiplier)
        local slow = self:GetSpecialValueFor("arrow_slow_duration")
        local chance = self:GetSpecialValueFor("stacks_chance")
        local ss_bonusdmg = (self:GetSpecialValueFor("bonus_ss") + talent_value(caster, "special_multishot_ss_bonus_dmg_lua")) / 10000 -- 100 stacks
        --print("ss_bonusdmg = "..ss_bonusdmg)
        local modif_multishot = "modifier_drow_ranger_multishot_lua_stacks"
    
        if caster:HasModifier("modifier_super_scepter") then
            if caster:HasModifier(modif_multishot) then
                local modifier = caster:FindModifierByName(modif_multishot)
                local stacks = modifier:GetStackCount()
                if RollPercentage(chance) then
                    modifier:SetStackCount(stacks + 1)
                end 
                damage = math.floor( damage * (stacks * ss_bonusdmg  + 1))
                --print("damage = "..damage)
            else
                if caster and IsValidEntity(caster) and caster:IsAlive() then
                    if not caster:HasModifier(modif_multishot) then
                        caster:AddNewModifier(caster, self, modif_multishot, {})
                        --Update stacks for illussions / OBS / etc.
                        if caster:HasModifier(modif_multishot) then
                            local mod1 = "modifier_drow_ranger_multishot_lua_stacks"
                            local owner = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())
                            if owner then	  
                                local modifier1 = caster:FindModifierByName(mod1)
                                if owner:HasModifier(mod1) then
                                    local modifier2 = owner:FindModifierByName(mod1)
                                    modifier1:SetStackCount(modifier2:GetStackCount())
                                end	
                            end		
                        end
                        if caster:HasModifier(modif_multishot) then
                            local time = GameRules:GetGameTime() / 60
                            if time > 1 then
                                local mbuff = caster:FindModifierByName(modif_multishot)
                                local stack = math.floor(time * 8)
                                --random 25% for a double stack
                                if RollPercentage(25) then
                                    stack = stack * 2
                                end
                                local orig_stacks = mbuff:GetStackCount()
                                if orig_stacks < stack then
                                    mbuff:SetStackCount(stack)
                                end    
                            end
                        end		
                    end
                end                
            end
        end   
           

        -- check frost arrow ability
        if not self:GetAutoCastState() then
            if data.frost == 1 then
                local ability = self:GetCaster():FindAbilityByName("drow_ranger_frost_arrows_lua")
                target:AddNewModifier(
                        self:GetCaster(), -- player source
                        ability, -- ability source
                        "modifier_drow_ranger_frost_arrows_lua", -- modifier name
                        { duration = slow } -- kv
                )
            end
        end   

        -- damage
        local damageTable = {
            victim = target,
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            ability = self, --Optional.
            -- damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
        }
        ApplyDamage(damageTable)

        -- play effects
        local sound_cast = "Hero_DrowRanger.ProjectileImpact"
        EmitSoundOn(sound_cast, target)

        return true
    end    
end

modifier_drow_ranger_multishot_lua_stacks = class({})

function modifier_drow_ranger_multishot_lua_stacks:IsHidden()
	return false
end

function modifier_drow_ranger_multishot_lua_stacks:IsPurgable()
	return false
end
function modifier_drow_ranger_multishot_lua_stacks:RemoveOnDeath()
	return false
end

function modifier_drow_ranger_multishot_lua_stacks:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
	}

	return funcs
end

function modifier_drow_ranger_multishot_lua_stacks:GetModifierManaBonus()
    if self:GetAbility() then
	    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_mana")
    end   
end
function modifier_drow_ranger_multishot_lua_stacks:GetModifierBonusStats_Agility()
    if self:GetAbility() then
	    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_agi")
    end   
end
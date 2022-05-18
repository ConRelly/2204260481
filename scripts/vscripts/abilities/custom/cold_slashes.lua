cold_slashes = class ( {})

LinkLuaModifier ("modifier_cold_slashes", "abilities/custom/cold_slashes.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_cold_slashes_target", "abilities/custom/cold_slashes.lua", LUA_MODIFIER_MOTION_NONE)

local aghbuf = "modifier_item_ultimate_scepter_consumed"

function cold_slashes:GetAbilityTextureName()
    
    return self.BaseClass.GetAbilityTextureName(self) 
end

 
function cold_slashes:GetAOERadius()
    if self:GetCaster ():HasScepter () then
        return 9000
    end
    return 9000
end

function cold_slashes:GetCooldown (nLevel)
    return self.BaseClass.GetCooldown (self, nLevel)
end

function cold_slashes:GetBehavior ()
    if 	self:GetCaster ():HasScepter () then
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function cold_slashes:OnSpellStart ()
    local hTarget = self:GetCursorTarget ()
    local caster = self:GetCaster() 
    if hTarget:HasModifier("modifier_cold_slashes_target") then
        self:EndCooldown()
        self:StartCooldown(5.0)
        return nil
    end   
    if hTarget ~= nil and not hTarget:HasModifier("modifier_cold_slashes_target") then
        hTarget:AddNewModifier (self:GetCaster (), self, "modifier_cold_slashes_target", nil)
        EmitSoundOn ("Hero_Juggernaut.OmniSlash", hTarget)
        
        local nFXIndex = ParticleManager:CreateParticle ("particles/deadpool_multislash_cast.vpcf", PATTACH_CUSTOMORIGIN, hTarget);
        ParticleManager:SetParticleControlEnt (nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin (), true);
        ParticleManager:SetParticleControl (nFXIndex, 1, hTarget:GetOrigin ());
        ParticleManager:ReleaseParticleIndex (nFXIndex);
    end  
end

modifier_cold_slashes = class ( {})

function modifier_cold_slashes:IsHidden ()
    return true
end

function modifier_cold_slashes:IsPurgable ()
    return false
end

--------------------------------------------------------------------------------

function modifier_cold_slashes:GetStatusEffectName ()
    return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_lvl2.vpcf"
end

--------------------------------------------------------------------------------

function modifier_cold_slashes:StatusEffectPriority ()
    return 1000
end

function modifier_cold_slashes:GetHeroEffectName ()
    return "particles/frostivus_herofx/juggernaut_fs_omnislash_slashers.vpcf"
end


function modifier_cold_slashes:HeroEffectPriority ()
    return 100
end

function modifier_cold_slashes:CheckState ()
    local state = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        --[MODIFIER_STATE_DISARMED] = true,
    }

    return state
end

modifier_cold_slashes_target = class ( {})

function modifier_cold_slashes_target:IsHidden ()
    return false
end

function modifier_cold_slashes_target:IsPurgable()
    return false
end
function modifier_cold_slashes_target:IsPurgeException()
    return true
end
--[[ function modifier_cold_slashes_target:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE  -- freezes the game after multiple uses with 2 or more Units having this skill
end ]]
function modifier_cold_slashes_target:OnCreated (kv)
    if IsServer () then
        local hTarget = self:GetParent ()

        local caster = self:GetAbility():GetCaster()
		local caster_missing_hp = caster:GetMaxHealth() - caster:GetHealth()
        local extra_dmg = (self:GetAbility():GetSpecialValueFor("missing_hp") * caster_missing_hp * 0.01) / 10
        self.damage = self:GetAbility ():GetSpecialValueFor ("damage") + math.ceil(extra_dmg) 
        --print(self.damage .. "cold slash damage")
        self.jumps_bonus = 0

        --if self:GetCaster():HasTalent("special_bonus_unique_kyloren_4") then self.jumps_bonus = self:GetCaster():FindTalentValue("special_bonus_unique_kyloren_4") end 

        self.bounce_tick = self:GetAbility ():GetSpecialValueFor ("bounce_tick")

        self.jumps = self:GetAbility ():GetSpecialValueFor ("jumps") + self.jumps_bonus

        self:StartIntervalThink (self.bounce_tick)

        hTarget:Stop ()

        self:GetCaster ():AddNewModifier (self:GetCaster (), self, "modifier_cold_slashes", nil)
    end
end


function modifier_cold_slashes_target:OnRefresh (kv)
    if IsServer () then
        local caster = self:GetAbility():GetCaster()
		local caster_missing_hp = caster:GetMaxHealth() - caster:GetHealth()
        local extra_dmg = (self:GetAbility():GetSpecialValueFor("missing_hp") * caster_missing_hp * 0.01) / 10
        self.damage = self:GetAbility ():GetSpecialValueFor ("damage") + math.ceil(extra_dmg)         
    end
end

function modifier_cold_slashes_target:OnIntervalThink ()
    if IsServer () then
        local target = self:GetParent ()
        local caster = self:GetAbility ():GetCaster ()
        --if target:IsCreep () then
        --    target:Kill (self:GetAbility (), caster)
        --end
        if  self.jumps <= 0 then
            if self:IsNull() then return end
            self:Destroy ()
        end
        --caster:SetAbsOrigin (target:GetAbsOrigin ())
        FindClearRandomPositionAroundUnit(caster, target, math.random(500))
        --FindClearSpaceForUnit (caster, target:GetAbsOrigin (), false)

        local nFXIndex = ParticleManager:CreateParticle ("particles/custom/deadpool_multislash_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, target);
        ParticleManager:SetParticleControlEnt (nFXIndex, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin () + Vector (0, 0, 96), true);
        ParticleManager:SetParticleControl (nFXIndex, 2, Vector (0, 0, 0));
        ParticleManager:SetParticleControl (nFXIndex, 3, Vector (0, 0, 0));
        ParticleManager:ReleaseParticleIndex (nFXIndex);
        local nFXIndexy = ParticleManager:CreateParticle ("particles/deadpool_multislash_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, target);
        ParticleManager:SetParticleControl (nFXIndexy, 0, target:GetAbsOrigin ());
        ParticleManager:SetParticleControl (nFXIndexy, 1, caster:GetAbsOrigin ());
        ParticleManager:ReleaseParticleIndex (nFXIndexy);        
        caster:StartGestureWithPlaybackRate (ACT_DOTA_ATTACK, 2)
        --EmitSoundOn ("Hero_Juggernaut.OmniSlash.Damage", target)
        caster:EmitSoundParams("Hero_Juggernaut.OmniSlash.Damage", 0, 0.5, 0)

        caster:PerformAttack (target, true, true, true, true, false, false, true)
        ApplyDamage ( { victim = target, attacker = caster, damage = self.damage, ability = self:GetAbility (), damage_type = DAMAGE_TYPE_PURE })

        --if self:GetCaster():HasTalent("special_bonus_unique_kyloren_5") then 
        caster:PerformAttack (target, true, true, true, true, false, false, true)
        --end 

        self.jumps = self.jumps - 1
    end
end
--------------------------------------------------------------------------------
function modifier_cold_slashes_target:OnDestroy (kv)
    if IsServer () then
        local target = self:GetParent ()
        local caster = self:GetAbility ():GetCaster ()
        target:Stop ()
        caster:Stop ()
        caster:RemoveGesture (ACT_DOTA_ATTACK)
        if caster:HasModifier("modifier_cold_slashes") and caster:IsAlive() then
            caster:RemoveModifierByName ("modifier_cold_slashes")
        end    
        local chance = math.random (100)

        if chance <= 82 then
            self:FindNearestTarget ()
        end
    end
end

function modifier_cold_slashes_target:FindNearestTarget ()
    if IsServer () then
        self.radius = self:GetAbility ():GetSpecialValueFor ("radius_scepter")
        local caster = self:GetAbility ():GetCaster ()
        local nearby_units = FindUnitsInRadius (caster:GetTeam (), caster:GetAbsOrigin (), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
        for i=1, #nearby_units do
            if  #nearby_units == 0 then
                return nil
            else
                local target = nearby_units[1]
                target:AddNewModifier (self:GetAbility ():GetCaster (), self:GetAbility (), "modifier_cold_slashes_target", nil)

                local nFXIndex = ParticleManager:CreateParticle ("particles/deadpool_multislash_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, target);
                ParticleManager:SetParticleControl (nFXIndex, 0, target:GetAbsOrigin ());
                ParticleManager:SetParticleControl (nFXIndex, 1, caster:GetAbsOrigin ());
                ParticleManager:ReleaseParticleIndex (nFXIndex);
            end
        end
    end
end


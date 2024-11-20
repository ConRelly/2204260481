LinkLuaModifier("modifier_mjz_lifestealer_poison_sting", "abilities/hero_lifestealer/mjz_lifestealer_poison_sting.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_lifestealer_poison_sting_slow", "abilities/hero_lifestealer/mjz_lifestealer_poison_sting.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_lifestealer_poison_sting_buff", "abilities/hero_lifestealer/mjz_lifestealer_poison_sting.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_lifestealer_poison_sting_gain_rate", "abilities/hero_lifestealer/mjz_lifestealer_poison_sting.lua", LUA_MODIFIER_MOTION_NONE)

mjz_lifestealer_poison_sting = class({})
local ability_class = mjz_lifestealer_poison_sting

function ability_class:GetIntrinsicModifierName()
    return "modifier_mjz_lifestealer_poison_sting"
end

---------------------------------------------------------------------------------------
-- Modifier: Main Ability Modifier
---------------------------------------------------------------------------------------

modifier_mjz_lifestealer_poison_sting = class({})
local modifier_class = modifier_mjz_lifestealer_poison_sting

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end
function modifier_class:RemoveOnDeath() return false end


function modifier_class:OnCreated()
    if IsServer() then
        local parent = self:GetParent()
        local ability = self:GetAbility()
        -- Initialize instance variables
        self.stacks_gained = 0
        self.last_stack_time = 0
        self.peak_stack_gain_rate = 10
        self.decay_time = 0
        self.first_stack_time = 0
        self.first_stack_out_of_x = 0
        
        self:InitializeModifiers(parent, ability)
    end       
end    

function modifier_class:OnDestroy()
end

function modifier_class:InitializeModifiers(parent, ability)
    local time = GameRules:GetGameTime() / 60
    local modif_buf = "modifier_mjz_lifestealer_poison_sting_buff"

        
    if not parent:HasModifier(modif_buf) then
        local buff_modifier = parent:AddNewModifier(parent, ability, modif_buf, {})
        buff_modifier:SetStackCount(time * 10)
    end 
    local modif_gain_rate = "modifier_mjz_lifestealer_poison_sting_gain_rate"  -- New modifier
    if not parent:HasModifier(modif_gain_rate) then
        parent:AddNewModifier(parent, ability, modif_gain_rate, {})
    end        
end

if IsServer() then
    function modifier_class:DeclareFunctions() 
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED, 
        } 
    end
    
    function modifier_class:OnAttackLanded(keys)
        if not IsServer() then return end
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local attacker = keys.attacker
        local target = keys.target

        if attacker ~= parent or attacker:PassivesDisabled() or attacker:IsIllusion() then return end

        local iDuration = GetTalentSpecialValueFor(ability, "duration") * (1 + attacker:GetStatusResistance())
        local claw_chance = GetTalentSpecialValueFor(ability, "claw_chance")
        local modifier_slow_name = "modifier_mjz_lifestealer_poison_sting_slow"
        
        if RollPercentage(claw_chance) then
            target:AddNewModifier(attacker, ability, modifier_slow_name, {Duration = iDuration})
        end    
    end
end

---------------------------------------------------------------------------------------
-- Modifier: Slow and Damage Modifier (Poison Sting)
---------------------------------------------------------------------------------------

modifier_mjz_lifestealer_poison_sting_slow = class({})
local modifier_class_slow = modifier_mjz_lifestealer_poison_sting_slow

function modifier_class_slow:IsHidden() return false end
function modifier_class_slow:IsPurgable() return false end
function modifier_class_slow:IsDebuff() return true end
function modifier_class_slow:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_class_slow:DeclareFunctions() 
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    } 
end
function modifier_class_slow:GetModifierMoveSpeedBonus_Percentage() 
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("move_slow_pct") end
end

if IsServer() then
    function modifier_class_slow:OnCreated()
        self:OnIntervalThink()
        local interval = 1.0
        if _G._challenge_bosss and _G._challenge_bosss > 0 then
            interval = 1 - (_G._challenge_bosss /20)
        end    
        self:StartIntervalThink(interval)      
    end
    
    function modifier_class_slow:OnIntervalThink()
        if not IsServer() then return end
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        local gain_stack = 1
        if ability:GetAutoCastState() then
            gain_stack = 0
            self:ApplyPoisonDamage(caster, ability, parent, gain_stack)
        else  -- RNG-based gain
            self:ApplyPoisonDamage(caster, ability, parent, gain_stack) 
        end
    end
  


    
    function modifier_class_slow:ApplyPoisonDamage(caster, hAbility, hParent, gain_stack)
        if not IsServer() then return end
        local fDamage = GetTalentSpecialValueFor(hAbility, "damage")
        local modif_buf = "modifier_mjz_lifestealer_poison_sting_buff"
        local chance = hAbility:GetSpecialValueFor("chance")
        local gain_rate_modifier = caster:FindModifierByName("modifier_mjz_lifestealer_poison_sting_gain_rate")
        local main_modifier = caster:FindModifierByName("modifier_mjz_lifestealer_poison_sting")
        -- Reset decay time
        if main_modifier then
            main_modifier.decay_time = GameRules:GetGameTime()
        end        
        if not caster:HasModifier(modif_buf) then
            caster:AddNewModifier(caster, hAbility, modif_buf, {})
        end
        local modifer = caster:FindModifierByName(modif_buf)   
        if gain_stack and gain_stack > 0 then
            if RollPercentage(chance) then
                modifer:SetStackCount(modifer:GetStackCount()+1)
                if gain_rate_modifier then
                    gain_rate_modifier:CalculateAndRecordStackGainRate()
                end
            end    
            if HasSuperScepter(caster) then
                if RollPercentage(chance) then
                    modifer:SetStackCount(modifer:GetStackCount()+1)
                    if gain_rate_modifier then
                        gain_rate_modifier:CalculateAndRecordStackGainRate()
                    end
                end
            end 
        end
        local stacks = modifer:GetStackCount() + 1
        local tdamage = fDamage * stacks  
        local iParticle = ParticleManager:CreateParticle("particles/msg_fx/msg_spell.vpcf", PATTACH_OVERHEAD_FOLLOW, hParent)
        ParticleManager:SetParticleControlEnt(iParticle, 0, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", hParent:GetOrigin(), true)
        ParticleManager:SetParticleControl(iParticle, 1, Vector(0, tdamage, 6))
        ParticleManager:SetParticleControl(iParticle, 2, Vector(1, math.floor(math.log10(tdamage))+2, 100))
        ParticleManager:SetParticleControl(iParticle, 3, Vector(85+80,26+40,139+40))        
        self:AddParticle(iParticle, false, false, -1, false, false)
        ApplyDamage({
            victim = hParent, 
            attacker = caster, 
            damage = tdamage, 
            damage_type = hAbility:GetAbilityDamageType(), 
            ability = hAbility
        })
    end
end

---------------------------------------------------------------------------------------
-- Modifier: Buff (Stacks and Stats)
---------------------------------------------------------------------------------------

modifier_mjz_lifestealer_poison_sting_buff = class({})
local modifier_class_bluff = modifier_mjz_lifestealer_poison_sting_buff
function modifier_class_bluff:IsHidden() return self:GetAbility() == nil end
function modifier_class_bluff:IsPurgable() return false end
function modifier_class_bluff:IsDebuff() return false end
function modifier_class_bluff:RemoveOnDeath() return false end
function modifier_class_bluff:AllowIllusionDuplicate() return true end

function modifier_class_bluff:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if parent:IsIllusion() or parent:HasModifier("modifier_arc_warden_tempest_double") then     
        local mod1 = "modifier_mjz_lifestealer_poison_sting_buff"
        -- print("ilusion")
        local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
        if owner then       
            if parent:HasModifier(mod1) then
                local modifier1 = parent:FindModifierByName(mod1)
                if owner:HasModifier(mod1) then
                    local modifier2 = owner:FindModifierByName(mod1)
                    modifier1:SetStackCount(modifier2:GetStackCount())
                end    
            end    
        end    
    end 
end       
function modifier_class_bluff:OnDestroy()
end

function modifier_class_bluff:DeclareFunctions() 
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
    } 
end
function modifier_class_bluff:GetModifierBonusStats_Strength() 
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("str_stack") * self:GetStackCount() end
end
function modifier_class_bluff:GetModifierHealthBonus()    
    if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_stack") * self:GetStackCount() end   
end


---------------------------------------------------------------------------------------
-- Modifier: Stack Gain Rate Display
---------------------------------------------------------------------------------------
modifier_mjz_lifestealer_poison_sting_gain_rate = class({})
local gain_rate_modifier_class = modifier_mjz_lifestealer_poison_sting_gain_rate

function gain_rate_modifier_class:IsHidden() return false end
function gain_rate_modifier_class:IsPurgable() return false end
function gain_rate_modifier_class:RemoveOnDeath() return false end

function gain_rate_modifier_class:OnCreated(kv)
    if IsServer() then
        self:StartIntervalThink(6)
    end
end


function gain_rate_modifier_class:CalculateAndRecordStackGainRate()
    if not IsServer() then return end
    local main_modifier = self:GetParent():FindModifierByName("modifier_mjz_lifestealer_poison_sting")
    if not main_modifier then return end

    -- Update last stack time and increment stacks gained
    main_modifier.last_stack_time = GameRules:GetGameTime()
    main_modifier.stacks_gained = main_modifier.stacks_gained + 1

    -- If this is the first stack out of 10, record the start time
    if main_modifier.stacks_gained == 1 then
        main_modifier.first_stack_out_of_x = GameRules:GetGameTime()
    end

    -- Calculate rate after 30 stacks
    if main_modifier.stacks_gained >= 30 then
        local time_elapsed = main_modifier.last_stack_time - main_modifier.first_stack_out_of_x
        if time_elapsed > 0 then
            -- Calculate stacks per minute
            local current_rate = math.ceil((30 * 30) / time_elapsed)
            -- Update peak rate if current rate is higher
            if current_rate > main_modifier.peak_stack_gain_rate then
                main_modifier.peak_stack_gain_rate = current_rate
                -- Update modifier stacks to show new peak rate
                self:SetStackCount(current_rate)
            end
        end

        -- Reset counter for next calculation
        main_modifier.stacks_gained = 0
        main_modifier.first_stack_out_of_x = 0
    end

    -- Reset decay timer
    main_modifier.decay_time = GameRules:GetGameTime()
end

function gain_rate_modifier_class:OnIntervalThink()
    local parent = self:GetParent()
    local main_modifier = parent:FindModifierByName("modifier_mjz_lifestealer_poison_sting")
    if not main_modifier then return end

    local current_time = GameRules:GetGameTime()
    local time_since_last_stack = current_time - main_modifier.decay_time

    -- Calculate decay (0.5% per second since last stack)
    if time_since_last_stack > 0 then
        local decay_factor = math.max(0, 1 - (time_since_last_stack * 0.005))
        local decayed_rate = main_modifier.peak_stack_gain_rate * decay_factor
        -- Update the displayed stacks
        if decayed_rate < 10 then
            decayed_rate = 10
        end
        self:SetStackCount(math.ceil(decayed_rate)) 
    end
    local buff_modifier = parent:FindModifierByName("modifier_mjz_lifestealer_poison_sting_buff")
    if buff_modifier and self:GetAbility():GetAutoCastState() then
        local gained = math.ceil(buff_modifier:GetStackCount() + (self:GetStackCount()/10))
        buff_modifier:SetStackCount(gained)
    end
end

---talents
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local bonusOperation
    local kv = ability:GetAbilityKeyValues()
    
    if kv.AbilityValues then
        local valueData = kv.AbilityValues[value]
        if type(valueData) == "table" then
            talentName = valueData.LinkedSpecialBonus
            bonusOperation = valueData.LinkedSpecialBonusOperation
        end
    end
    
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            local bonusValue = talent:GetSpecialValueFor("value")
            
            if bonusOperation then
                if bonusOperation == "SPECIAL_BONUS_ADD" or bonusOperation == "SPECIAL_BONUS_SUBTRACT" then
                    base = base + bonusValue -- For subtraction, bonusValue should already be negative
                elseif bonusOperation == "SPECIAL_BONUS_MULTIPLY" then
                    base = base * bonusValue
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_ADD" then
                    base = base * (1 + bonusValue / 100)
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_SUBTRACT" then
                    base = base * (1 - bonusValue / 100)
                end
            else
                -- Default behavior if no operation is specified
                base = base + bonusValue
            end
        end
    end
    
    return base
end


function HasSuperScepter(npc)
    local modifier_super_scepter = "modifier_item_imba_ultimate_scepter_synth_stats"
    if npc:HasModifier(modifier_super_scepter) and npc:FindModifierByName(modifier_super_scepter):GetStackCount() > 2 then
		return true 
	end	  
    return false
end

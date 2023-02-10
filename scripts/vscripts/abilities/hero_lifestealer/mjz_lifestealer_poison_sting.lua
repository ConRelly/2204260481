LinkLuaModifier("modifier_mjz_lifestealer_poison_sting", "abilities/hero_lifestealer/mjz_lifestealer_poison_sting.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_lifestealer_poison_sting_slow", "abilities/hero_lifestealer/mjz_lifestealer_poison_sting.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_lifestealer_poison_sting_buff", "abilities/hero_lifestealer/mjz_lifestealer_poison_sting.lua", LUA_MODIFIER_MOTION_NONE)

mjz_lifestealer_poison_sting = class({})
local ability_class = mjz_lifestealer_poison_sting

function ability_class:GetIntrinsicModifierName()
    return "modifier_mjz_lifestealer_poison_sting"
end
modifier_mjz_lifestealer_poison_sting_buff = class({})
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
        local time = GameRules:GetGameTime() / 60
        local modif_buf = "modifier_mjz_lifestealer_poison_sting_buff"
        if not parent:HasModifier(modif_buf) then
            parent:AddNewModifier(parent, ability, modif_buf, {})
            local modifer = parent:FindModifierByName(modif_buf) 
            local get_stacks = time * 4
            modifer:SetStackCount(get_stacks)
        end 
    end       
end    
function modifier_class:OnDestroy()

end

if IsServer() then
    function modifier_class:DeclareFunctions() 
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED, 
        } 
    end
    
    function modifier_class:OnAttackLanded(keys)
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
--function modifier_class_slow:GetEffectAttachType() 
--    return PATTACH_ABSORIGIN_FOLLOW 
--end
--function modifier_class_slow:GetEffectName() 
--    return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf" 
--end
--function modifier_class_slow:GetStatusEffectName() 
--    return "particles/status_fx/status_effect_poison_venomancer.vpcf" 
--end

if IsServer() then
    function modifier_class_slow:OnCreated()
        self:OnIntervalThink()
        self:StartIntervalThink(1.0)
    end
    function modifier_class_slow:OnIntervalThink()
        local caster = self:GetCaster()
        local hAbility = self:GetAbility()
        local hParent = self:GetParent()
        local fDamage = GetTalentSpecialValueFor(hAbility, "damage")
        local modif_buf = "modifier_mjz_lifestealer_poison_sting_buff"
        local chance = hAbility:GetSpecialValueFor("chance")
        if not caster:HasModifier(modif_buf) then
            caster:AddNewModifier(caster, ability, modif_buf, {})
        end
        local modifer = caster:FindModifierByName(modif_buf)   

        if RollPercentage(chance) then
            modifer:SetStackCount(modifer:GetStackCount()+1)
        end    
        if HasSuperScepter(caster) then
            if RollPercentage(chance) then
                modifer:SetStackCount(modifer:GetStackCount()+1)
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
    --self:SetStackCount(self:GetStackCount()+ 1)
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



-- 是否学习了指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
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
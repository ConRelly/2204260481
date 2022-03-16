
LinkLuaModifier("modifier_mjz_leshrac_pulse_nova", "abilities/hero_leshrac/mjz_leshrac_pulse_nova.lua", LUA_MODIFIER_MOTION_NONE)


mjz_leshrac_pulse_nova = class({})
local ability_class = mjz_leshrac_pulse_nova

function ability_class:GetAOERadius()
    return self:GetSpecialValueFor("radius") + self:GetCaster():GetCastRangeBonus()
end

function ability_class:OnToggle()
    if IsServer() then
        local ability = self
        local caster = self:GetCaster()
        local radius = ability:GetAOERadius()
        local pszScriptName = "modifier_mjz_leshrac_pulse_nova"

        if ability:GetToggleState() then
            EmitSoundOn("Hero_Leshrac.Pulse_Nova", caster)
            caster:AddNewModifier(caster, ability, pszScriptName, {})
        else
            caster:RemoveModifierByName(pszScriptName)
            StopSoundEvent("Hero_Leshrac.Pulse_Nova", caster)
        end
    end
end

--------------------------------------------------------------------------------

modifier_mjz_leshrac_pulse_nova = class({})
local modifier_class = modifier_mjz_leshrac_pulse_nova

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

if IsServer() then

    function modifier_class:OnCreated(table)
        local ability = self:GetAbility()
        local nova_tick = ability:GetSpecialValueFor('nova_tick')
        self.p_name = "particles/units/heroes/hero_leshrac/leshrac_pulse_nova.vpcf"

        self:OnIntervalThink()
        self:StartIntervalThink(nova_tick)
    end

    function modifier_class:OnIntervalThink()
        if not self:GetAbility() then if not self:IsNull() then self:Destroy() return end end
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        local radius = ability:GetAOERadius()

        if not caster:IsAlive() then
            ability:ToggleAbility()
            return 
        end
        if ability:GetToggleState() == false then
            return
        end

        EmitSoundOn("Hero_Leshrac.Pulse_Nova_Strike", caster)

        self:SpendMana()

        local enemy_list = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, 
                           ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false )

        for _, enemy in ipairs(enemy_list) do
            self:ApplyDamage(enemy)
            self:ApplyEffect(enemy)
        end

    end

    
    function modifier_class:SpendMana( )
        local ability = self:GetAbility()
        local caster = self:GetCaster()

        local mana_per_sec = ability:GetSpecialValueFor("mana_cost_per_second")
        -- caster:ReduceMana(mana_per_sec)
        caster:SpendMana(mana_per_sec, ability)
        
        if caster:GetMana() < mana_per_sec then
            ability:ToggleAbility()
        end
    end

    function modifier_class:ApplyDamage( target )
        local ability = self:GetAbility()
        local caster = self:GetCaster()
    
        local damage_normal = GetTalentSpecialValueFor(ability, "damage")
        local damage_scepter = GetTalentSpecialValueFor(ability, "damage_scepter")
        local damage_intelligence_per = GetTalentSpecialValueFor(ability, "damage_intelligence_per")
    
        local damage_amount = damage_normal
        if caster:HasScepter() then
            damage_amount = damage_scepter
        end
        
        local damage_intelligence = caster:GetIntellect() * (damage_intelligence_per / 100)
        damage_amount = damage_amount + damage_intelligence
    
        local dmg_table_target = {
            victim = target,
            attacker = caster,
            damage = damage_amount,
            damage_type = ability:GetAbilityDamageType(),
            -- damage_flags = ability:GetAbilityTargetFlags(), 
            ability = ability,
        }
        ApplyDamage(dmg_table_target)
    
    end
    
    function modifier_class:ApplyEffect( target )
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        
        local p_name = self.p_name or "particles/units/heroes/hero_leshrac/leshrac_pulse_nova.vpcf"
        local particle = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:ReleaseParticleIndex(particle)
    end

end


------------------------------------------------------------------------------

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


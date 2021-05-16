

modifier_mjz_spell_reflect = class({})
local modifier_class = modifier_mjz_spell_reflect

function modifier_class:IsHidden()
    return true
end
function modifier_class:IsPurgable()
    return false
end
function modifier_class:AllowIllusionDuplicate()
    return false
end

function modifier_class:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_REFLECT_SPELL,    --  Lotus Orb trigger.
        MODIFIER_PROPERTY_ABSORB_SPELL      --  Linken's Sphere trigger.
    }
end

function modifier_class:GetAbsorbSpell(keys)
    local parent = self:GetParent()
    local canAbsorbed = self:GetAbility():IsCooldownReady()
    if canAbsorbed then
        parent:EmitSound("Hero_Antimage.Counterspell.Absorb")
        self:_StartCooldown()
        return 1
    else
        return false
    end
end

if IsServer() then
    function modifier_class:OnCreated()
        local ability = self:GetAbility()
        -- self.cooldown = ability:GetSpecialValueFor("cooldown")
        self.cooldown = ability:GetCooldown(ability:GetLevel() - 1)
    end

    function modifier_class:GetReflectSpell(keys)
        local parent = self:GetParent()
        if self.stored ~= nil and not self.stored:IsNull() then
            self.stored:RemoveSelf() 
        end

        if parent:PassivesDisabled() or self:_IsCooldowning() then
            return
        end

        local usedAbility = keys.ability
        local usedAbilityName = usedAbility:GetName()
        local usedAbilityCaster = usedAbility:GetCaster()

        if usedAbilityCaster:GetTeamNumber() == parent:GetTeamNumber() or usedAbility.isReflection then
            return
        end

        local ability = parent:FindAbilityByName(usedAbilityName)

        if not ability then -- spell was never reflected
            ability = parent:AddAbility(usedAbilityName)
            ability:SetStolen(true)
            ability:SetHidden(true)

            ability:SetLevel(usedAbility:GetLevel())

            ability.isReflection = true
        end

        self.stored = ability
        parent:SetCursorCastTarget(usedAbilityCaster)
        ability:OnSpellStart()

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControlEnt(particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(particle)

        usedAbilityCaster:EmitSound("Hero_Antimage.Counterspell.Target")
       
    end


    function modifier_class:_IsCooldowning()
        local ability = self:GetAbility()
        local c2 = not ability:IsCooldownReady()
        return c2
    end

    function modifier_class:_StartCooldown()    
        local ability = self:GetAbility()
        local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
        ability:StartCooldown( cooldown )
    end
end

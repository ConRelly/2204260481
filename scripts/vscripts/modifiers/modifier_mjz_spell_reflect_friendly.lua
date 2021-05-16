

modifier_mjz_spell_reflect_friendly = class({})
local modifier_class = modifier_mjz_spell_reflect_friendly


function modifier_class:IsHidden()
    return false
end
function modifier_class:IsPurgable()
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
    local canAbsorbed = true
    if canAbsorbed then
        parent:EmitSound("Hero_Antimage.Counterspell.Absorb")
        return 1
    else
        return false
    end
end

if IsServer() then
    function modifier_class:OnCreated(keys)
        local parent = self:GetParent()
        local abaddon_aphotic_shield_cast = "Hero_Abaddon.AphoticShield.Cast"
        local abaddon_aphotic_shield_destroy = "Hero_Abaddon.AphoticShield.Destroy"
        local abaddon_aphotic_shield = "particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf"
        local antimage_counter = "particles/units/heroes/hero_antimage/antimage_counter.vpcf"
        local antimage_counter_cast = "Hero_Antimage.Counterspell.Cast"
        local antimage_counter_absorb = "Hero_Antimage.Counterspell.Absorb"
        
        parent:EmitSound(antimage_counter_cast)

        local shield_size = 110
        self.particle = ParticleManager:CreateParticle(antimage_counter, PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControl(self.particle, 1, Vector(shield_size, 0, shield_size))
        ParticleManager:SetParticleControl(self.particle, 2, Vector(shield_size, 0, shield_size))
        ParticleManager:SetParticleControl(self.particle, 4, Vector(shield_size, 0, shield_size))
        ParticleManager:SetParticleControl(self.particle, 5, Vector(shield_size, 0, 0))
        ParticleManager:SetParticleControlEnt(self.particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
    end

    function modifier_class:GetReflectSpell(keys)
        local parent = self:GetParent()

        if self.stored ~= nil then
            self.stored:RemoveSelf() 
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

        parent:SetCursorCastTarget(usedAbilityCaster)
        ability:OnSpellStart()
        self.stored = ability


        -- local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
        -- ParticleManager:SetParticleControlEnt(particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
        -- ParticleManager:ReleaseParticleIndex(particle)

        -- local reflect_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
		-- ParticleManager:SetParticleControlEnt(reflect_pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		-- ParticleManager:ReleaseParticleIndex(reflect_pfx)

        usedAbilityCaster:EmitSound("Hero_Antimage.Counterspell.Target")

        self:Destroy()
    end

    function modifier_class:OnDestroy()
        local parent = self:GetParent()
        local ability = self:GetAbility()

        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
end

LinkLuaModifier("modifier_mjz_monkey_king_cloud", "abilities/hero_monkey_king/mjz_monkey_king_cloud", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_monkey_king_arcana", "abilities/hero_monkey_king/mjz_monkey_king_cloud", LUA_MODIFIER_MOTION_NONE)

mjz_monkey_king_cloud = class({})
local ability_class = mjz_monkey_king_cloud

function ability_class:OnToggle()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = self
    
    if ability:GetToggleState() then
        caster:AddNewModifier(caster, ability, "modifier_mjz_monkey_king_cloud", {})
        caster:AddNewModifier(caster, ability, "modifier_mjz_monkey_king_arcana", {})
    else
        caster:RemoveModifierByName( "modifier_mjz_monkey_king_cloud")
        caster:RemoveModifierByName( "modifier_mjz_monkey_king_arcana")
    end
end

---------------------------------------------------------------------------------------

modifier_mjz_monkey_king_cloud = class({})
local modifier_class = modifier_mjz_monkey_king_cloud

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

function modifier_class:GetEffectName()
    return "particles/econ/items/monkey_king/arcana/monkey_arcana_cloud.vpcf"
end
function modifier_class:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_class:CheckState()
    local state = {
        -- [MODIFIER_STATE_FLYING] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
    return state
end

function modifier_class:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end
function modifier_class:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor('bonus_move_speed')
end

function modifier_class:GetActivityTranslationModifiers()
    -- return "arcana"
    return "cloudrun"
end


if IsServer() then
    function modifier_class:OnCreated()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        self.p_duration = 9  -- 效果持续时间是10秒
        self.p_name = "particles/econ/items/monkey_king/arcana/monkey_arcana_cloud.vpcf"
        
        self:_CreateParticle()
        self:StartIntervalThink(1.0)
    end
    function modifier_class:OnIntervalThink()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        local mana_pct = ability:GetSpecialValueFor("mana_pct")
        local mana = parent:GetMaxMana() * (mana_pct / 100)
        
        if ability:GetToggleState() then
            if parent:GetMana() > mana then
                parent:SpendMana(mana, ability)
            else
                ability:ToggleAbility()
            end

            self:_CreateParticle()
        end

    end

    function modifier_class:OnDestroy()
        self:_DestroyParticle()
    end

    function modifier_class:_DestroyParticle(  )
        if self.pfx then
            ParticleManager:DestroyParticle(self.pfx, false)
            ParticleManager:ReleaseParticleIndex(self.pfx)
        end
    end

    function modifier_class:_CreateParticle( )
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()

        local NOW = GameRules:GetGameTime()
        self.p_create_time = self.p_create_time or 0

        if (NOW - self.p_create_time) > self.p_duration then
            self.p_create_time = NOW
            self:_DestroyParticle()

            self.pfx = ParticleManager:CreateParticle( self.p_name, PATTACH_POINT_FOLLOW, parent )
            -- ParticleManager:SetParticleControl( self.pfx, 0, parent:GetAbsOrigin() )
            ParticleManager:SetParticleControlEnt( self.pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_cloud", parent:GetAbsOrigin(), true )
        end
    end
end

---------------------------------------------------------------------------------------

modifier_mjz_monkey_king_arcana = class({})
function modifier_mjz_monkey_king_arcana:IsHidden() return true end
function modifier_mjz_monkey_king_arcana:IsPurgable() return false end

function modifier_mjz_monkey_king_arcana:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
    }
end

function modifier_mjz_monkey_king_arcana:GetActivityTranslationModifiers()
    return "arcana"
end

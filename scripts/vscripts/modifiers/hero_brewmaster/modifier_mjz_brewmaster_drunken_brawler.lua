
modifier_mjz_brewmaster_drunken_brawler = class ({})
local modifier_class = modifier_mjz_brewmaster_drunken_brawler

function modifier_class:IsHidden()
    return true
end
function modifier_class:IsPurgable()	-- 能否被驱散
	return false
end

function modifier_class:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,	-- 暴击伤害
        MODIFIER_PROPERTY_EVASION_CONSTANT,			-- 闪避
        MODIFIER_EVENT_ON_ATTACK_START,			-- 当拥有modifier的单位开始攻击某个目标
        MODIFIER_EVENT_ON_ATTACK_LANDED,		-- 当拥有modifier的单位攻击到某个目标时
    }
    return funcs
end

function modifier_class:GetModifierEvasion_Constant(kv)
    local ability = self:GetAbility()
    self.evasion_constant = 0
    if ability then
        if ability._active then
            self.evasion_constant = ability:GetSpecialValueFor("dodge_chance_active")			
        else
            self.evasion_constant = ability:GetSpecialValueFor("dodge_chance")			
        end
    end
    return self.evasion_constant
end
function modifier_class:GetModifierPreAttack_CriticalStrike(kv)
    return self.crit_strike
end

function modifier_class:OnAttackStart( keys )
    local caster = self:GetParent()
    local unit = self:GetParent()
    local ability = self:GetAbility()

    self.crit = false
    self.crit_strike = 0

    self.crit_chance = 0
    if ability then
        if ability._active then
            self.crit_chance = ability:GetSpecialValueFor("crit_chance_active")
        else
            self.crit_chance = ability:GetSpecialValueFor("crit_chance")	
        end
    end

    if RandomInt(1, 100) <= self.crit_chance then
        self.crit = true
    end

    if ability and self.crit then
        unit:EmitSound("Hero_Brewmaster.Brawler.Crit")	-- EmitSoundOn("Hero_Brewmaster.Brawler.Crit", unit)	

        if ability._active then
            self.crit_strike = ability:GetSpecialValueFor("crit_multiplier_active")						
        else
            self.crit_strike = ability:GetSpecialValueFor("crit_multiplier")						
        end
    end
end
function modifier_class:OnAttackLanded(keys)
    local caster = self:GetParent()
    local ability = self:GetAbility()
    local attacker = keys.attacker

    if attacker == self:GetParent() then
        local target = keys.target

        if self.crit then
            local crit_effect_name = "particles/units/heroes/hero_brewmaster/brewmaster_drunken_brawler_crit.vpcf"
            local crit_effect = ParticleManager:CreateParticle(crit_effect_name, PATTACH_ABSORIGIN_FOLLOW, caster)
            ParticleManager:ReleaseParticleIndex(crit_effect)
        end
    end
end

function modifier_class:OnRefresh(kv)		-- 当执行 ForceRefresh() 时，触发此事件
    -- self:_Init(kv)
end

function modifier_class:OnCreated( kv )
    -- self:_Init()
end

function modifier_class:_Init( )
    local unit = self:GetParent()
    local ability = self:GetAbility()

    if ability then
        if ability._active then
            self.evasion_constant = ability:GetSpecialValueFor("dodge_chance_active")			
            self.crit_chance = ability:GetSpecialValueFor("crit_chance_active")
        else
            self.evasion_constant = ability:GetSpecialValueFor("dodge_chance")			
            self.crit_chance = ability:GetSpecialValueFor("crit_chance")	
        end
    else
        self.evasion_constant = 0
        self.crit_chance = 0
    end
end



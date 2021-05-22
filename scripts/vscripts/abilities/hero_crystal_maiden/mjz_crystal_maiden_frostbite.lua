local THIS_LUA = "abilities/hero_crystal_maiden/mjz_crystal_maiden_frostbite.lua"
LinkLuaModifier("modifier_mjz_crystal_maiden_frostbite", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_crystal_maiden_frostbite_bonus_int", THIS_LUA, LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------------------------------------


mjz_crystal_maiden_frostbite = class({})
local ability_class = mjz_crystal_maiden_frostbite

function ability_class:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function ability_class:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = self
    local point = self:GetCursorPosition()
    local radius = ability:GetTalentSpecialValueFor("radius")

    local units = caster:FindEnemyUnitsInRadius(point, radius, {ability = ability})
    for _,unit in pairs(units) do
        self:SpellTo(unit)
    end
end

function ability_class:SpellTo( target )
    local caster = self:GetCaster()
    local ability = self
    local mName = "modifier_mjz_crystal_maiden_frostbite"
    
    local hero_duration = ability:GetTalentSpecialValueFor( "duration")
    local creep_duration = ability:GetTalentSpecialValueFor( "creep_duration")
    local stun_duration = ability:GetTalentSpecialValueFor( "stun_duration")
    local duration = creep_duration
    if target:IsHero() then
        duration = hero_duration
    end

    ProjectileManager:CreateTrackingProjectile({
		Target = target,
		Source = caster,
		Ability = ability,	
		EffectName = "particles/units/heroes/hero_crystalmaiden/maiden_frostbite.vpcf",
		iMoveSpeed = 2000,
		vSourceLoc= caster:GetAbsOrigin(),           
		bDodgeable = false,                               
    })

    EmitSoundOn("hero_Crystal.frostbite", target)
    
    target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
    target:AddNewModifier(caster, ability, mName, {duration = duration})  
end

function ability_class:ApplyDamageToEnemy( target )
    local caster = self:GetCaster()
    local ability = self
    
    local targetTeam = ability:GetAbilityTargetTeam() -- DOTA_UNIT_TARGET_TEAM_ENEMY
    local targetType = ability:GetAbilityTargetType() -- DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
    local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    local damageType = ability:GetAbilityDamageType()
    local manareg = math.ceil(caster:GetManaRegen() * ability:GetTalentSpecialValueFor( "mana_reg_dmg"))
    --print(manareg .. " mana reg")
    local damage_interval = ability:GetSpecialValueFor("damage_interval")
    local hero_total_damage = ability:GetTalentSpecialValueFor( "total_damage")
    local creep_total_damage = ability:GetTalentSpecialValueFor( "creep_total_damage")
    local damage = 0
    if target:IsHero() then
        damage = (hero_total_damage + manareg) * damage_interval 
    else
        damage = (creep_total_damage + manareg) * damage_interval
    end

    local damageTable =
    {
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = damageType,
        ability = ability,
    }
    ApplyDamage( damageTable )
end

---------------------------------------------------------------------------------------

modifier_mjz_crystal_maiden_frostbite = class({})
local modifier_frostbite = modifier_mjz_crystal_maiden_frostbite

function modifier_frostbite:IsHidden() return false end
function modifier_frostbite:IsPurgable() return false end
function modifier_frostbite:IsDebuff() return true end
function modifier_frostbite:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_frostbite:CheckState()
    local state = {
        -- [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_FROZEN] = true,
        --[MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_INVISIBLE] = false,
    }
    return state
end

function modifier_frostbite:GetEffectName()
    return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end

function modifier_frostbite:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_frostbite:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost.vpcf"
end
function modifier_frostbite:HeroEffectPriority()
	return 10
end

if IsServer() then
    function modifier_frostbite:OnCreated()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        
        self.caster = caster
        self.ability = ability
        self.target = parent

        local damage_interval = ability:GetSpecialValueFor("damage_interval")
        self:OnIntervalThink()
        self:StartIntervalThink(damage_interval)
    end
    function modifier_frostbite:OnIntervalThink()
        if self.ability then
            self.ability:ApplyDamageToEnemy(self.target)
        end
    end
    function modifier_frostbite:OnDestroy()
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local bonus = ability:GetSpecialValueFor("bonus")
        if caster:HasScepter() and parent:IsAlive() and caster:IsAlive() then
            caster:PerformAttack(parent, true, true, true, true, true, false, true)
            if HasSuperScepter(caster) then
                caster:ModifyIntellect(bonus)
                caster:ModifyStrength(bonus)
                if caster:HasModifier("modifier_mjz_crystal_maiden_frostbite_bonus_int") then
                    local modifier = caster:FindModifierByName("modifier_mjz_crystal_maiden_frostbite_bonus_int")
                    modifier:SetStackCount(modifier:GetStackCount() + bonus)
                else
                    caster:AddNewModifier(caster, ability, "modifier_mjz_crystal_maiden_frostbite_bonus_int", {})
                    caster:FindModifierByName("modifier_mjz_crystal_maiden_frostbite_bonus_int"):SetStackCount(bonus)
                end
            end
        end
    end
end

if modifier_mjz_crystal_maiden_frostbite_bonus_int == nil then modifier_mjz_crystal_maiden_frostbite_bonus_int = class({}) end
local modifier_frostbine_int = modifier_mjz_crystal_maiden_frostbite_bonus_int

function modifier_frostbine_int:IsHidden() return false end
function modifier_frostbine_int:IsPurgable() return false end
function modifier_frostbine_int:IsDebuff() return false end
function modifier_frostbine_int:RemoveOnDeath() return false end
function modifier_frostbine_int:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_frostbine_int:OnTooltip()
	return self:GetStackCount()
end
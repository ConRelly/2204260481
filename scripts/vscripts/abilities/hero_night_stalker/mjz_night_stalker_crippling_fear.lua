LinkLuaModifier("modifier_mjz_night_stalker_crippling_fear_aura","abilities/hero_night_stalker/mjz_night_stalker_crippling_fear.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_night_stalker_crippling_fear_effect","abilities/hero_night_stalker/mjz_night_stalker_crippling_fear.lua", LUA_MODIFIER_MOTION_NONE)

mjz_night_stalker_crippling_fear = class({})
local ability_class = mjz_night_stalker_crippling_fear

function ability_class:GetAOERadius()
    return self:GetSpecialValueFor('radius')
end

if IsServer() then
    function ability_class:OnSpellStart()
        local ability = self
        local caster = self:GetCaster()
        local radius = ability:GetSpecialValueFor('radius')
        local duration = ability:GetSpecialValueFor('duration')
        local modifier_name = 'modifier_mjz_night_stalker_crippling_fear_aura'
        
        local modifier = caster:FindModifierByName(modifier_name)
		if modifier then
			modifier:SetDuration(duration, true)
			modifier:ForceRefresh()
		else
			caster:AddNewModifier(caster, ability, modifier_name, {duration = duration})
        end
        
        caster:EmitSound('Hero_Nightstalker.Trickling_Fear')
        caster:EmitSound('Hero_Nightstalker.Trickling_Fear_lp')
    end
end

---------------------------------------------------------------------------------------

modifier_mjz_night_stalker_crippling_fear_aura = class({})
local modifier_class = modifier_mjz_night_stalker_crippling_fear_aura

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end
function modifier_class:RemoveOnDeath() return false end

--[[
function modifier_class:GetEffectName()
    return "particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf"
end
function modifier_class:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
]]

if IsServer() then

    function modifier_class:OnCreated(table)
        local ability = self:GetAbility()
        local radius = ability:GetSpecialValueFor('radius')
--[[
        local p_effect = "particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf"

        local sFX = ParticleManager:CreateParticle( p_effect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControl(sFX, 2, Vector(radius, radius, radius) )
        self:AddParticle(sFX, false, false, -1, false, false)
		self.particle = sFX
]]
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		self:AddParticle(self.particle, false, false, -1, false, false)
		ParticleManager:SetParticleControl(self.particle, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.particle, 1, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.particle, 2, Vector(radius, radius, radius))
		ParticleManager:SetParticleControl(self.particle, 3, self:GetCaster():GetAbsOrigin())
		self:StartIntervalThink(FrameTime())
    end

    function modifier_class:OnIntervalThink()
		if self.particle then
			ParticleManager:SetParticleControl(self.particle, 0, self:GetCaster():GetAbsOrigin())
			ParticleManager:SetParticleControl(self.particle, 1, self:GetCaster():GetAbsOrigin())
			ParticleManager:SetParticleControl(self.particle, 3, self:GetCaster():GetAbsOrigin())
		end
	end

    function modifier_class:OnDestroy()
        local caster = self:GetParent()

        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)

        caster:StopSound('Hero_Nightstalker.Trickling_Fear_lp')
        caster:EmitSound('Hero_Nightstalker.Trickling_Fear_end')
    end
end

--------------------------------------------------------------

function modifier_class:IsAura() return true end
function modifier_class:IsAuraActiveOnDeath() return true end
function modifier_class:GetModifierAura() return "modifier_mjz_night_stalker_crippling_fear_effect" end
function modifier_class:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_class:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_class:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_class:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end


-------------------------------------------------------------------

modifier_mjz_night_stalker_crippling_fear_effect = class({})
local modifier_effect = modifier_mjz_night_stalker_crippling_fear_effect

function modifier_effect:IsHidden() return false end
function modifier_effect:IsPurgable() return true end
function modifier_effect:IsDebuff() return true end

function modifier_effect:GetEffectName()
    -- return "particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear.vpcf"
    return "particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_smoke.vpcf"
end
function modifier_effect:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_effect:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end
function modifier_effect:GetModifierAttackSpeedBonus_Constant()
    return -self:GetAbility():GetSpecialValueFor('slow_attack_speed')
end
function modifier_effect:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetAbility():GetSpecialValueFor('slow_movement_speed_pct')
end


-----------------------------------------------------------------------------------------

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
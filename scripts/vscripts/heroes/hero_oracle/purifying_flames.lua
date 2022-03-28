LinkLuaModifier("modifier_purifying_flames", "heroes/hero_oracle/purifying_flames", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_purifying_flames_buff", "heroes/hero_oracle/purifying_flames", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_oracle_immortal_head", "heroes/hero_oracle/purifying_flames", LUA_MODIFIER_MOTION_NONE)

----------------------
-- Purifying Flames --
----------------------
purifying_flames = class({})
function purifying_flames:GetIntrinsicModifierName()
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_oracle_immortal_head") and FindWearables(self:GetCaster(), "models/items/oracle/oracle_ti10_immortal_head/oracle_ti10_immortal_head.vmdl") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_oracle_immortal_head", {})
		end
    end
	return "modifier_purifying_flames"
end
function purifying_flames:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_oracle_immortal_head") then
        return "oracle/immortal_head_ti10/oracle_purifying_flames_immortal"
    end
    return "oracle_purifying_flames"
end
function purifying_flames:GetCooldown(lvl)
	return self.BaseClass.GetCooldown(self, lvl) - talent_value(self:GetCaster(), "special_bonus_purifying_flames_cooldown")
end

function purifying_flames:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local damage_flag = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
	
	if target:TriggerSpellAbsorb(self) then return end
	
	target:EmitSound("Hero_Oracle.PurifyingFlames.Damage")
	target:EmitSound("Hero_Oracle.PurifyingFlames")

	local pf = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_purifyingflames_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(pf, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pf)
	
	local pf_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_purifyingflames_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(pf_cast, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pf_cast)

	if target:GetTeamNumber() == caster:GetTeamNumber() then
		damage_flag = damage_flag + DOTA_DAMAGE_FLAG_NON_LETHAL
		target:AddNewModifier(caster, self, "modifier_purifying_flames_buff", {duration = self:GetSpecialValueFor("duration")})
	end
	
	ApplyDamage({
		attacker 		= caster,
		victim 			= target,
		ability 		= self,
		damage 			= self:GetSpecialValueFor("damage"),
		damage_type		= self:GetAbilityDamageType(),
		damage_flags	= damage_flag,
	})
end

---------------------------
-- Purifying Flames Buff --
---------------------------
modifier_purifying_flames_buff = class({})
function modifier_purifying_flames_buff:IgnoreTenacity() return true end
function modifier_purifying_flames_buff:IsDebuff() return false end
function modifier_purifying_flames_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_purifying_flames_buff:GetTexture() return "oracle_purifying_flames" end
function modifier_purifying_flames_buff:GetEffectName()
	return "particles/units/heroes/hero_oracle/oracle_purifyingflames.vpcf"
end

function modifier_purifying_flames_buff:OnCreated()
	local tick_rate = self:GetAbility():GetSpecialValueFor("tick_rate")
	self.heal_per_tick = self:GetAbility():GetSpecialValueFor("damage") * (1 + self:GetAbility():GetSpecialValueFor("heal_pct") / 100) * tick_rate / self:GetAbility():GetSpecialValueFor("duration")
	
	if not IsServer() then return end
	
	self:StartIntervalThink(tick_rate)
end

function modifier_purifying_flames_buff:OnIntervalThink()
	self:GetParent():Heal(self.heal_per_tick, self:GetCaster())
	
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self:GetParent(), self.heal_per_tick, nil)
end

-------------------------------
-- Purifying Flames Modifier --
-------------------------------
modifier_purifying_flames = class({})
function modifier_purifying_flames:IsHidden() return true end
function modifier_purifying_flames:OnCreated()
	self:StartIntervalThink(FrameTime())
end

function modifier_purifying_flames:OnIntervalThink()
    if IsServer() then
        local caster = self:GetCaster()

        if not self:GetAbility():GetAutoCastState() then return end
        if not self:GetAbility():IsCooldownReady() then return end
        if self:GetAbility():GetLevel() < 1 then return end
        if not self:GetAbility():IsFullyCastable() then return end
        if caster:IsIllusion() then return end
        if not caster:IsRealHero() then return end
        if caster:IsSilenced() then return end

        local radius = self:GetAbility():GetCastRange(caster:GetAbsOrigin(), caster) + caster:GetCastRangeBonus()
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_ANY_ORDER, false)

        if #enemies > 0 then
            if not IsValidEntity(enemies[1]) then return end
            if not IsValidEntity(self:GetAbility()) then return end 
            if not IsValidEntity(caster) then return end
            if not enemies[1]:IsAlive() then return end
            if not caster:IsAlive() then return end
            caster:CastAbilityOnTarget(enemies[1], self:GetAbility(), caster:GetPlayerOwnerID())
        end
    end
end


modifier_oracle_immortal_head = class({})
function modifier_oracle_immortal_head:IsHidden() return true end
function modifier_oracle_immortal_head:IsPurgable() return false end
function modifier_oracle_immortal_head:RemoveOnDeath() return false end

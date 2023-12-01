LinkLuaModifier("modifier_queenofpain_custom_shadow_strike_stacks", "abilities/heroes/queenofpain_custom_shadow_strike.lua", LUA_MODIFIER_MOTION_NONE)

queenofpain_custom_shadow_strike = class({})


if IsServer() then
    function queenofpain_custom_shadow_strike:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        caster:EmitSound("Hero_QueenOfPain.ShadowStrike")

        local projectile_speed = 900

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_shadow_strike_body.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 3, Vector(projectile_speed, 0, 0))
        ParticleManager:ReleaseParticleIndex(particle)

        ProjectileManager:CreateTrackingProjectile({
            Ability = self,
            Target = target,
            Source = caster,
            EffectName = "particles/units/heroes/hero_queenofpain/queen_shadow_strike.vpcf",
            iMoveSpeed = projectile_speed,
            bDodgeable = false,
            flExpireTime = GameRules:GetGameTime() + 10,
        })
    end


    function queenofpain_custom_shadow_strike:OnProjectileHit(target, location)
        local caster = self:GetCaster()

        target:EmitSound("Hero_QueenOfPain.ShadowStrike.Target")

        local damage = self:GetSpecialValueFor("strike_damage")

        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, target, damage, nil)

        ApplyDamage({
            ability = self,
            attacker = caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            victim = target
        })

        target:AddNewModifier(caster, self, "modifier_queenofpain_custom_shadow_strike", {
            duration = self:GetSpecialValueFor("duration")
        })
    end
end



LinkLuaModifier("modifier_queenofpain_custom_shadow_strike", "abilities/heroes/queenofpain_custom_shadow_strike.lua", LUA_MODIFIER_MOTION_NONE)

modifier_queenofpain_custom_shadow_strike = class({})
function modifier_queenofpain_custom_shadow_strike:IsDebuff() return true end
function modifier_queenofpain_custom_shadow_strike:IsPurgable() return false end
function modifier_queenofpain_custom_shadow_strike:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
if IsServer() then
	function modifier_queenofpain_custom_shadow_strike:OnCreated(keys)
		local interval = self:GetAbility():GetSpecialValueFor("tick_interval") + talent_value(self:GetCaster(), "special_bonus_qop_shadow_strike_tick_interval")
		self.tick_damage = self:GetCaster():GetIntellect() * self:GetAbility():GetSpecialValueFor("int_pct_tick") * 0.01

		self:StartIntervalThink(interval)
	end


    function modifier_queenofpain_custom_shadow_strike:OnIntervalThink()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        local stack = 1 + self:GetStackCount()
        local dmg = self.tick_damage * stack
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, parent, dmg, nil)

        ApplyDamage({
            ability = ability,
            attacker = caster,
            damage = dmg,
            damage_type = ability:GetAbilityDamageType(),
            victim = parent
        })
    end
end
function modifier_queenofpain_custom_shadow_strike:_OnScreamHit()
    if IsServer() then
        local caster = self:GetCaster()
        if caster:HasModifier("modifier_super_scepter") then
            self:IncrementStackCount()
            if caster:HasModifier("modifier_queenofpain_custom_shadow_strike_stacks") then
                local modif = caster:FindModifierByName("modifier_queenofpain_custom_shadow_strike_stacks")
                local Mstacks = modif:GetStackCount()
                local Stack = self:GetStackCount()
                modif:SetStackCount(Mstacks + Stack)
            else
                caster:AddNewModifier(caster, self:GetAbility(), "modifier_queenofpain_custom_shadow_strike_stacks", {})    
            end   
        end
    end    
end




function modifier_queenofpain_custom_shadow_strike:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end


function modifier_queenofpain_custom_shadow_strike:GetModifierMoveSpeedBonus_Percentage()
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("movement_slow")
    end    
end


modifier_queenofpain_custom_shadow_strike_stacks = class({})
function modifier_queenofpain_custom_shadow_strike_stacks:IsHidden() return false end
function modifier_queenofpain_custom_shadow_strike_stacks:IsDebuff() return false end
function modifier_queenofpain_custom_shadow_strike_stacks:IsPurgable() return false end
function modifier_queenofpain_custom_shadow_strike_stacks:RemoveOnDeath() return false end
function modifier_queenofpain_custom_shadow_strike_stacks:GetTexture()
	return "queenofpain_shadow_strike"
end
function modifier_queenofpain_custom_shadow_strike_stacks:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,

	}
end
function modifier_queenofpain_custom_shadow_strike_stacks:GetModifierTotal_ConstantBlock()
    local finalBlock = self:GetStackCount() / 2
	return finalBlock
end
function modifier_queenofpain_custom_shadow_strike_stacks:GetModifierBonusStats_Intellect()
    if self:GetAbility() then
        local bonus = self:GetAbility():GetSpecialValueFor("ss_int_bonus")
        local fstacks = self:GetStackCount() * bonus
	    return fstacks
    end
end
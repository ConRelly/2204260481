LinkLuaModifier("modifier_mjz_phantom_assassin_phantom_strike", "abilities/hero_phantom_assassin/mjz_phantom_assassin_phantom_strike.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_phantom_assassin_phantom_strike_buff", "abilities/hero_phantom_assassin/mjz_phantom_assassin_phantom_strike.lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------------

mjz_phantom_assassin_phantom_strike = mjz_phantom_assassin_phantom_strike or class({})

--[[
function mjz_phantom_assassin_phantom_strike:CastFilterResultTarget(target)
    if target == self:GetCaster() then
        return UF_FAIL_CUSTOM
    else
        return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
    end
end

function mjz_phantom_assassin_phantom_strike:GetCustomCastErrorTarget(target)
    if target == self:GetCaster() then
        return "#dota_hud_error_cant_cast_on_self"
    end
end
]]


function mjz_phantom_assassin_phantom_strike:GetIntrinsicModifierName()
	return "modifier_mjz_phantom_assassin_phantom_strike"
end

function mjz_phantom_assassin_phantom_strike:OnUpgrade()
	if not IsServer() then return end
	if self:GetLevel() == 1 then
		self:ToggleAutoCast()
	end
end

function mjz_phantom_assassin_phantom_strike:OnSpellStart( )
	if not IsServer() then return nil end
	local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb(ability) then return end

	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		self:BlinkTo(target)
		self:ApplyBuff()

		ExecuteOrderFromTable({
			UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex(),
			Queue = false,
		})
	else
		if target == caster then
			self:ApplyBuff()
		else
			self:BlinkTo(target)
			self:ApplyBuff()
		end
	end

end

function mjz_phantom_assassin_phantom_strike:BlinkTo( target )
	local caster = self:GetCaster()
	local ability = self

	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_PhantomAssassin.Strike.Start", caster)
	
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_start.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex(fx)

	local point = target:GetAbsOrigin() + (caster:GetAbsOrigin() - target:GetAbsOrigin()):Normalized() * 50
	FindClearSpaceForUnit(caster, point, false)
	
	EmitSoundOnLocationWithCaster(point, "Hero_PhantomAssassin.Strike.End", caster)

	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_end.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(fx, 0, point)
	ParticleManager:ReleaseParticleIndex(fx)
	
end

function mjz_phantom_assassin_phantom_strike:ApplyBuff( )
	local caster = self:GetCaster()
	local ability = self
	
	local duration = ability:GetTalentSpecialValueFor("duration")

	caster:AddNewModifier(caster, ability, "modifier_mjz_phantom_assassin_phantom_strike_buff", {duration = duration})
end

----------------------------------------------------------------------------------------------

modifier_mjz_phantom_assassin_phantom_strike_buff = class({})
local modifier_buff = modifier_mjz_phantom_assassin_phantom_strike_buff

function modifier_buff:IsHidden() return false end
function modifier_buff:IsPurgable() return true end
function modifier_buff:IsBuff() return true end


function modifier_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end
function modifier_buff:GetModifierAttackSpeedBonus_Constant( )
    return self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
end

----------------------------------------------------------------------------------------------

modifier_mjz_phantom_assassin_phantom_strike = class({})
local modifier_autocast = modifier_mjz_phantom_assassin_phantom_strike

function modifier_autocast:IsHidden() return true end
function modifier_autocast:IsPurgable() return false end

if IsServer() then
	function modifier_autocast:OnCreated()
		self:StartIntervalThink(1.25)
	end
	function modifier_autocast:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		
		if ability:GetAutoCastState() and ability:IsFullyCastable() then
			if caster:GetAttackTarget() then
				local flManaSpent = ability:GetManaCost(ability:GetLevel())
				caster:SpendMana(flManaSpent, ability)

				local flCooldown = ability:GetCooldown(ability:GetLevel())
				ability:StartCooldown(flCooldown)

				ability:ApplyBuff()
			end
		end
		
	end

end

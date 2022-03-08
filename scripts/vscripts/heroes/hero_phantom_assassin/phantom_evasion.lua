LinkLuaModifier("modifier_pa_phantom_evasion", "heroes/hero_phantom_assassin/phantom_evasion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pa_phantom_evasion_speed", "heroes/hero_phantom_assassin/phantom_evasion", LUA_MODIFIER_MOTION_NONE)

---------------------
-- Phantom Evasion --
---------------------
pa_phantom_evasion = class({})
function pa_phantom_evasion:GetCooldown(Level)
	return self:GetSpecialValueFor("cooldown") / self:GetCaster():GetCooldownReduction()
end
function pa_phantom_evasion:GetCastRange(location, target)
	return self:GetSpecialValueFor("max_distance")
end
function pa_phantom_evasion:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	local cooldown = self:GetSpecialValueFor("cooldown")
	self:GetCaster():EmitSound("Phantom_Evasion")
	self:GetCaster():Stop()

	if self:GetAutoCastState() then
		duration = duration * 2

		if self:GetCaster():HasAbility("pa_stifling_dagger") then
			local DaggerAbility = self:GetCaster():FindAbilityByName("pa_stifling_dagger")
			DaggerAbility.hitten_targets = {}
			local DaggersCount = 0
			if DaggerAbility:GetLevel() > 0 then
				local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("max_distance"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)

				local MaxDaggers = math.floor(DaggerAbility:GetLevel() / 2)
				for _, enemy in pairs(enemies) do
					if DaggersCount < MaxDaggers then
						DaggersCount = DaggersCount + 1
						DaggerAbility:LaunchDagger(enemy, false, false)
					end
				end
			end
		end
		self:EndCooldown()
		self:StartCooldown(cooldown)
	else
		self:GetCaster():Purge(false, true, false, false, false)
		self:EndCooldown()
		self:StartCooldown(cooldown / 2)
	end

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pa_phantom_evasion", {duration = duration})
end

------------------------------
-- Phantom Evasion Modifier --
------------------------------
modifier_pa_phantom_evasion = class({})
function modifier_pa_phantom_evasion:OnCreated()
	if not IsServer() then return end
	
	ProjectileManager:ProjectileDodge(self:GetParent())
	
	local blink_start_pfx = ParticleManager:CreateParticle("particles/custom/abilities/heroes/phantom_assassin_phantom_evasion/pa_phantom_evasion_start.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(blink_start_pfx, 0, self:GetParent():GetAbsOrigin())
	self:AddParticle(blink_start_pfx, false, false, -1, false, false)
--	ParticleManager:ReleaseParticleIndex(blink_start_pfx)
	
	self:GetParent():AddNoDraw()
end

function modifier_pa_phantom_evasion:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveNoDraw()

	if not self:GetAbility():GetAutoCastState() then
		local buff_duration = self:GetAbility():GetSpecialValueFor("buff_duration")
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pa_phantom_evasion_speed", {duration = buff_duration})
	end
end
function modifier_pa_phantom_evasion:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ORDER}
end
function modifier_pa_phantom_evasion:OnOrder(params)
	if not IsServer() then return end

	local hOrderedUnit = params.unit 
	local hTargetUnit = params.target
	local nOrderType = params.order_type

	if hOrderedUnit ~= self:GetParent() then return end
	if hTargetUnit and hTargetUnit:GetTeamNumber() == self:GetParent():GetTeamNumber() and (nOrderType == DOTA_UNIT_ORDER_MOVE_TO_TARGET or nOrderType == DOTA_UNIT_ORDER_ATTACK_TARGET or nOrderType == DOTA_UNIT_ORDER_ATTACK_MOVE) and not self:GetAbility():GetAutoCastState() then
		local max_distance = self:GetAbility():GetSpecialValueFor("max_distance")
		local distance = (hTargetUnit:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()
		local direction = (hTargetUnit:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized()
		local blink_point = self:GetParent():GetAbsOrigin() + direction * (distance - 150)
		if distance > max_distance then self:Destroy() return end
		self:GetParent():SetForwardVector(direction)
		FindClearSpaceForUnit(self:GetParent(), blink_point, false)
		
		local blink_end_pfx = ParticleManager:CreateParticle("particles/custom/abilities/heroes/phantom_assassin_phantom_evasion/pa_phantom_evasion_end.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(blink_end_pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(blink_end_pfx)
		
		self:GetParent():EmitSound("Phantom_Evasion")
	end
	
	self:GetParent():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
	if self:IsNull() then return end
	self:Destroy()
	return
end

function modifier_pa_phantom_evasion:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true
	}
end

------------------------
-- Phantom Evasion MS --
------------------------
modifier_pa_phantom_evasion_speed = class({})
function modifier_pa_phantom_evasion_speed:IsHidden() return false end
function modifier_pa_phantom_evasion_speed:IsPurgable() return true end
function modifier_pa_phantom_evasion_speed:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_pa_phantom_evasion_speed:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_pa_phantom_evasion_speed:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("buff_ms_pct") end
end
function modifier_pa_phantom_evasion_speed:CheckState() 
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end


--[[
	░░░░░▄▀▀▀▄░░░░░░░░░░░░░░░░░
	▄███▀░◐░░░▌░░░░░░░░░░░░░░░░
	░░░░▌░░░░░▐░░░░░░░░░░░░░░░░
	░░░░▐░░░░░▐░░░░░░░░░░░░░░░░
	░░░░▌░░░░░▐▄▄░░░░░░░░░░░░░░
	░░░░▌░░░░▄▀▒▒▀▀▀▀▄░░░░░░░░░
	░░░▐░░░░▐▒▒▒▒▒▒▒▒▀▀▄░░░░░░░
	░░░▐░░░░▐▄▒▒▒▒▒▒▒▒▒▒▀▄░░░░░
	░░░░▀▄░░░░▀▄▒▒▒▒▒▒▒▒▒▒▀▄░░░
	░░░░░░▀▄▄▄▄▄█▄▄▄▄▄▄▄▄▄▄▄▀▄░
	░░░░░░░░░░░▌▌░▌▌░░░░░░░░░░░
	░░░░░░░░░░░▌▌░▌▌░░░░░░░░░░░
	░░░░░░░░░▄▄▌▌▄▌▌░░░░░░░░░░░
]]

LinkLuaModifier("modifier_generic_knockback_lua", "lua_abilities/generic/modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_hw_sharpshooter", "heroes/hero_hoodwink/sharpshooter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hw_sharpshooter_debuff", "heroes/hero_hoodwink/sharpshooter", LUA_MODIFIER_MOTION_NONE)

------------------
-- Sharpshooter --
------------------
hw_sharpshooter = class({})
function hw_sharpshooter:Precache(context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_hoodwink.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_projectile.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_impact.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_target.vpcf", context)
	PrecacheResource("particle", "particles/items_fx/force_staff.vpcf", context)
end

function hw_sharpshooter:GetCastRange(location, target)
	if self:GetCaster():HasScepter() then
		return self:GetTalentSpecialValueFor("arrow_range") * self:GetSpecialValueFor("scepter_bonus")
	end
	return self:GetTalentSpecialValueFor("arrow_range")
end
function hw_sharpshooter:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor("misfire_time")

	self.delete_on_hit = true
	if self:GetCaster():HasScepter() then
		self.delete_on_hit = false
	end

	caster:AddNewModifier(caster, self, "modifier_hw_sharpshooter", {duration = duration, x = point.x, y = point.y, delete_on_hit = self.delete_on_hit})
end

function hw_sharpshooter:OnProjectileThink_ExtraData(location, ExtraData)
	local sound = EntIndexToHScript(ExtraData.sound)
	if not sound or sound:IsNull() then return end
	sound:SetOrigin(location)
end

function hw_sharpshooter:OnProjectileHit_ExtraData(target, location, ExtraData)
	local caster = self:GetCaster()
	local sound = EntIndexToHScript(ExtraData.sound)
	if self.delete_on_hit then
		if not sound or sound:IsNull() then return end
		StopSoundOn("Hero_Hoodwink.Sharpshooter.Projectile", sound)
		UTIL_Remove(sound)
	end

	if not target then return end

	if IsServer() then
		if caster:HasTalent("special_bonus_unique_hoodwink_sharpshooter_pure_damage") then
			damage_type = DAMAGE_TYPE_PURE
		else
			damage_type = self:GetAbilityDamageType()
		end
		if caster:HasModifier("modifier_super_scepter") then
			local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() / 2000
			damage = ExtraData.damage * (1 + distance)
		else
			damage = ExtraData.damage
		end
	end

	local damageTable = {victim = target, attacker = caster, damage = damage, damage_type = damage_type, ability = self, damage_flags = DOTA_DAMAGE_FLAG_NONE}
	ApplyDamage(damageTable)

	target:AddNewModifier(caster, self, "modifier_hw_sharpshooter_debuff", {duration = ExtraData.duration, x = ExtraData.x, y = ExtraData.y})

	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, ExtraData.damage, self:GetCaster():GetPlayerOwner())

	AddFOWViewer(self:GetCaster():GetTeamNumber(), target:GetOrigin(), 300, 4, false)

	local direction = Vector(ExtraData.x, ExtraData.y, 0):Normalized()
	self:PlayEffects(target, direction)

	return self.delete_on_hit
end

function hw_sharpshooter:PlayEffects(target, direction)
	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, target:GetOrigin())
	ParticleManager:SetParticleControlForward(effect_cast, 1, direction)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	EmitSoundOn("Hero_Hoodwink.Sharpshooter.Target", target)
end

--------------------------
-- Sharpshooter Release --
--------------------------
hw_sharpshooter_release = class({})
function hw_sharpshooter_release:OnSpellStart()
	local mod = self:GetCaster():FindModifierByName("modifier_hw_sharpshooter")
	if not mod then return end
	mod:Destroy()
end


---------------------------
-- Modifier Sharpshooter --
---------------------------
modifier_hw_sharpshooter = class({})
function modifier_hw_sharpshooter:IsHidden() return false end
function modifier_hw_sharpshooter:IsDebuff() return false end
function modifier_hw_sharpshooter:IsStunDebuff() return false end
function modifier_hw_sharpshooter:IsPurgable() return false end
function modifier_hw_sharpshooter:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ORDER, MODIFIER_PROPERTY_DISABLE_TURNING, MODIFIER_PROPERTY_MOVESPEED_LIMIT}
end
function modifier_hw_sharpshooter:OnCreated(kv)
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.team = self.parent:GetTeamNumber()
	self.charge = self:GetAbility():GetSpecialValueFor("max_charge_time") + talent_value(self.caster, "special_bonus_unique_hoodwink_sharpshooter_speed")
	self.damage = self:GetAbility():GetSpecialValueFor("max_damage")
	self.duration = self:GetAbility():GetSpecialValueFor("max_slow_debuff_duration")
	self.turn_rate = self:GetAbility():GetSpecialValueFor("turn_rate")
	self.recoil_distance = self:GetAbility():GetSpecialValueFor("recoil_distance")
	self.recoil_duration = self:GetAbility():GetSpecialValueFor("recoil_duration")
	self.recoil_height = self:GetAbility():GetSpecialValueFor("recoil_height")
	self.interval = 0.03 
	self:StartIntervalThink(self.interval)
	self.projectile_speed = self:GetAbility():GetSpecialValueFor("arrow_speed")
	self.projectile_range = self:GetAbility():GetSpecialValueFor("arrow_range")
	self.projectile_width = self:GetAbility():GetSpecialValueFor("arrow_width")
	local projectile_vision = self:GetAbility():GetSpecialValueFor("arrow_vision")
	if self.caster:HasShard() then
		local scepter_bonus = self:GetAbility():GetSpecialValueFor("scepter_bonus")
		self.projectile_speed = self.projectile_speed * scepter_bonus
		self.projectile_range = self.projectile_range * scepter_bonus
	end
	local vec = Vector(kv.x, kv.y, 0)

	self:SetDirection(vec)
	self.current_dir = self.target_dir
	self.face_target = true
	self.parent:SetForwardVector(self.current_dir)
	self.turn_speed = self.interval * self.turn_rate

	self.info = {
		Source = self.parent,
		Ability = self:GetAbility(),
		
	    bDeleteOnHit = kv.delete_on_hit,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,

	    EffectName = "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_projectile.vpcf",
	    fDistance = self.projectile_range,
	    fStartRadius = self.projectile_width,
	    fEndRadius = self.projectile_width,
	
		bHasFrontalCone = false,
		bReplaceExisting = false,
		
		bProvidesVision = true,
		iVisionRadius = projectile_vision,
		iVisionTeamNumber = self.caster:GetTeamNumber()
	}

	self.caster:SwapAbilities("hw_sharpshooter", "hw_sharpshooter_release", false, true)

	self:PlayEffects1()
	self:PlayEffects2()
	self:GetParent():StartGesture(ACT_DOTA_CHANNEL_ABILITY_6)
end
function modifier_hw_sharpshooter:OnRefresh(kv) end
function modifier_hw_sharpshooter:OnRemoved() end
function modifier_hw_sharpshooter:OnDestroy()
	if not IsServer() then return end
	local direction = self.current_dir
	local pct = math.min(self:GetElapsedTime(), self.charge) / self.charge
	self.info.vSpawnOrigin = self.parent:GetOrigin()
	self.info.vVelocity = direction * self.projectile_speed
	local sound = CreateModifierThinker(self.caster, self, "", {}, self.caster:GetOrigin(), self.team, false)
	EmitSoundOn("Hero_Hoodwink.Sharpshooter.Projectile", sound)

	self.info.ExtraData = {damage = self.damage * pct, duration = self.duration * pct, x = direction.x, y = direction.y, sound = sound:entindex()}
	ProjectileManager:CreateLinearProjectile(self.info)

	local mod = self.caster:AddNewModifier(self.caster, self, "modifier_generic_knockback_lua", {duration = self.recoil_duration, height = self.recoil_height, distance = self.recoil_distance, direction_x = -direction.x, direction_y = -direction.y})

	self.caster:SwapAbilities("hw_sharpshooter", "hw_sharpshooter_release", true, false)

	self:PlayEffects4(mod)
	self:GetParent():FadeGesture(ACT_DOTA_CHANNEL_ABILITY_6)
	self.caster:Stop()
end
function modifier_hw_sharpshooter:OnOrder(params)
	if params.unit ~= self:GetParent() then return end

	if params.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or params.order_type == DOTA_UNIT_ORDER_MOVE_TO_DIRECTION then
		self:SetDirection(params.new_pos)
	elseif params.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or params.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
		self:SetDirection(params.target:GetOrigin())
	end
end
function modifier_hw_sharpshooter:GetModifierMoveSpeed_Limit() return 0.1 end
function modifier_hw_sharpshooter:GetModifierTurnRate_Percentage() return -self.turn_rate end
function modifier_hw_sharpshooter:GetModifierDisableTurning() return 1 end
function modifier_hw_sharpshooter:CheckState()
	return {[MODIFIER_STATE_DISARMED] = true}
end
function modifier_hw_sharpshooter:OnIntervalThink()
	self:UpdateStack()
	self:TurnLogic()
	local startpos = self.parent:GetOrigin()
	local visions = self.projectile_range / self.projectile_width
	local delta = self.parent:GetForwardVector() * self.projectile_width
	for i = 1, visions do
		AddFOWViewer(self.team, startpos, self.projectile_width, 0.1, false)
		startpos = startpos + delta
	end

	if not self.charged and self:GetElapsedTime() > self.charge then
		self.charged = true
		EmitSoundOnClient("Hero_Hoodwink.Sharpshooter.MaxCharge", self.parent:GetPlayerOwner())
	end

	local remaining = self:GetRemainingTime()
	local seconds = math.ceil(remaining)
	local isHalf = (seconds-remaining) > 0.5
	if isHalf then seconds = seconds - 1 end

	if self.half ~= isHalf then
		self.half = isHalf
		self:PlayEffects3(seconds, isHalf)
	end
	self:UpdateEffect()
end

function modifier_hw_sharpshooter:SetDirection(vec)
	self.target_dir = ((vec - self.parent:GetOrigin()) * Vector(1, 1, 0)):Normalized()
	self.face_target = false
end

function modifier_hw_sharpshooter:TurnLogic()
	if self.face_target then return end

	local current_angle = VectorToAngles(self.current_dir).y
	local target_angle = VectorToAngles(self.target_dir).y
	local angle_diff = AngleDiff(current_angle, target_angle)

	local sign = -1
	if angle_diff < 0 then sign = 1 end

	if math.abs(angle_diff) < 1.1 * self.turn_speed then
		self.current_dir = self.target_dir
		self.face_target = true
	else
		self.current_dir = RotatePosition(Vector(0, 0, 0), QAngle(0, sign * self.turn_speed, 0), self.current_dir)
	end

	local a = self.parent:IsCurrentlyHorizontalMotionControlled()
	local b = self.parent:IsCurrentlyVerticalMotionControlled()
	if not (a or b) then
		self.parent:SetForwardVector(self.current_dir)
	end
end

function modifier_hw_sharpshooter:UpdateStack()
	local pct = math.min(self:GetElapsedTime(), self.charge) / self.charge
	pct = math.floor(pct * 100)
	self:SetStackCount(pct)
end

function modifier_hw_sharpshooter:OrderFilter(data)
	if #data.units > 1 then return true end

	local unit
	for _, id in pairs(data.units) do
		unit = EntIndexToHScript(id)
	end
	if unit ~= self.parent then return true end

	if data.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
		data.order_type = DOTA_UNIT_ORDER_MOVE_TO_DIRECTION
	elseif data.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET or data.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
		local pos = EntIndexToHScript(data.entindex_target):GetOrigin()

		data.order_type = DOTA_UNIT_ORDER_MOVE_TO_DIRECTION
		data.position_x = pos.x
		data.position_y = pos.y
		data.position_z = pos.z
	end

	return true
end

function modifier_hw_sharpshooter:PlayEffects1()
	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetOrigin(), true)

	self:AddParticle(effect_cast, false, false, -1, false, false)

	EmitSoundOn("Hero_Hoodwink.Sharpshooter.Channel", self.parent)
end
function modifier_hw_sharpshooter:PlayEffects2()
	local startpos = self.parent:GetAbsOrigin()
	local endpos = startpos + self.parent:GetForwardVector() * self.projectile_range

	local effect_cast = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_range_finder.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent, self.parent:GetPlayerOwner())
	ParticleManager:SetParticleControl(effect_cast, 0, startpos)
	ParticleManager:SetParticleControl(effect_cast, 1, endpos)

	self:AddParticle(effect_cast, false, false, -1, false, false)
	self.effect_cast = effect_cast
end
function modifier_hw_sharpshooter:PlayEffects3(seconds, half)
	local mid = 1
	if half then mid = 8 end
	local len = 2
	if seconds < 1 then
		len = 1
		if not half then return end
	end

	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_timer.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(1, seconds, mid))
	ParticleManager:SetParticleControl(effect_cast, 2, Vector(len, 0, 0))
end
function modifier_hw_sharpshooter:PlayEffects4(modifier)
	local effect_cast = ParticleManager:CreateParticle("particles/items_fx/force_staff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)

	modifier:AddParticle(effect_cast, false, false, -1, false, false)

	StopSoundOn("Hero_Hoodwink.Sharpshooter.Channel", self.caster)
	EmitSoundOn("Hero_Hoodwink.Sharpshooter.Cast", self.caster)
end

function modifier_hw_sharpshooter:UpdateEffect()
	local startpos = self.parent:GetAbsOrigin()
	local endpos = startpos + self.current_dir * self.projectile_range

	ParticleManager:SetParticleControl(self.effect_cast, 0, startpos)
	ParticleManager:SetParticleControl(self.effect_cast, 1, endpos)
end


----------------------------------
-- Modifier Sharpshooter Debuff --
----------------------------------
modifier_hw_sharpshooter_debuff = class({})
function modifier_hw_sharpshooter_debuff:IsHidden() return false end
function modifier_hw_sharpshooter_debuff:IsDebuff() return true end
function modifier_hw_sharpshooter_debuff:IsStunDebuff() return false end
function modifier_hw_sharpshooter_debuff:IsPurgable() return true end
function modifier_hw_sharpshooter_debuff:OnCreated(kv)
	self.parent = self:GetParent()
	self.slow = -self:GetAbility():GetSpecialValueFor("slow_move_pct")

	if not IsServer() then return end

	local direction = Vector(kv.x, kv.y, 0):Normalized()
	self:PlayEffects(direction)
end
function modifier_hw_sharpshooter_debuff:OnRefresh(kv) end
function modifier_hw_sharpshooter_debuff:OnRemoved() end
function modifier_hw_sharpshooter_debuff:OnDestroy() end
function modifier_hw_sharpshooter_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_hw_sharpshooter_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end
function modifier_hw_sharpshooter_debuff:CheckState()
	return {[MODIFIER_STATE_PASSIVES_DISABLED] = true}
end

function modifier_hw_sharpshooter_debuff:PlayEffects(direction)
	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_debuff.vpcf", PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetOrigin(), true)
	ParticleManager:SetParticleControlForward(effect_cast, 1, direction)

	self:AddParticle(effect_cast, false, false, -1, false, false)
end
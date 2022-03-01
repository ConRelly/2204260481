modifier_generic_knockback_lua = class({})

function modifier_generic_knockback_lua:IsHidden() return true end
function modifier_generic_knockback_lua:IsPurgable() return false end
function modifier_generic_knockback_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_generic_knockback_lua:GetEffectName()
	if not IsServer() then return end
	if self.stun then return "particles/generic_gameplay/generic_stunned.vpcf" end
end
function modifier_generic_knockback_lua:GetEffectAttachType()
	if not IsServer() then return end
	return PATTACH_OVERHEAD_FOLLOW
end
function modifier_generic_knockback_lua:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end
function modifier_generic_knockback_lua:CheckState()
	return {[MODIFIER_STATE_STUNNED] = self.stun}
end

function modifier_generic_knockback_lua:OnCreated(kv)
	if IsServer() then
		self.parent = self:GetParent()
		self.origin = self.parent:GetOrigin()
		self.distance = kv.distance or 0
		self.height = kv.height or kv.z or -1
		self.duration = kv.duration or 0

		if kv.direction_x and kv.direction_y then
			self.direction = Vector(kv.direction_x, kv.direction_y, 0):Normalized()
		else
			self.direction = -(self:GetParent():GetForwardVector())
		end
		self.tree = kv.tree_destroy_radius or self:GetParent():GetHullRadius()

		if kv.IsStun then self.stun = kv.IsStun else self.stun = false end
		if kv.IsFlail then self.flail = kv.IsFlail else self.flail = true end

		if self.duration == 0 then
			if self:IsNull() then return end
			self:Destroy()
			return
		end

		self.hVelocity = self.distance / self.duration

		local half_duration = self.duration / 2
		self.gravity = 2 * self.height / (half_duration * half_duration)
		self.vVelocity = self.gravity * half_duration

		if self.distance > 0 then
			if self:ApplyHorizontalMotionController() == false then 
				if self:IsNull() then return end
				self:Destroy()
				return
			end
		end
		if self.height >= 0 then
			if self:ApplyVerticalMotionController() == false then 
				if self:IsNull() then return end
				self:Destroy()
				return
			end
		end

		if self.flail then
			self:SetStackCount(1)
		elseif self.stun then
			self:SetStackCount(2)
		end
	else
		self.anim = self:GetStackCount()
		self:SetStackCount(0)
	end
end

function modifier_generic_knockback_lua:OnDestroy(kv)
	if not IsServer() then return end
	if not self.interrupted then
		if self.tree > 0 then
			GridNav:DestroyTreesAroundPoint(self:GetParent():GetOrigin(), self.tree, true)
		end
	end
	if self.EndCallback then self.EndCallback(self.interrupted) end
	self:GetParent():InterruptMotionControllers(true)
end

function modifier_generic_knockback_lua:SetEndCallback(func) self.EndCallback = func end

function modifier_generic_knockback_lua:GetOverrideAnimation(params)
	if self.anim == 1 then
		return ACT_DOTA_FLAIL
	elseif self.anim == 2 then
		return ACT_DOTA_DISABLED
	end
end

function modifier_generic_knockback_lua:UpdateHorizontalMotion(me, dt)
	local parent = self:GetParent()
	local target = self.direction * self.distance * (dt / self.duration)

	parent:SetOrigin(parent:GetOrigin() + target)
end

function modifier_generic_knockback_lua:OnHorizontalMotionInterrupted()
	if IsServer() then
		self.interrupted = true
		if self:IsNull() then return end
		self:Destroy()
	end
end

function modifier_generic_knockback_lua:UpdateVerticalMotion(me, dt)
	local time = dt / self.duration
	self.parent:SetOrigin(self.parent:GetOrigin() + Vector(0, 0, self.vVelocity * dt))
	self.vVelocity = self.vVelocity - self.gravity * dt
end

function modifier_generic_knockback_lua:OnVerticalMotionInterrupted()
	if IsServer() then
		self.interrupted = true
		if self:IsNull() then return end
		self:Destroy()
	end
end

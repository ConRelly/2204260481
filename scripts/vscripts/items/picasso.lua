---------------
-- Picasso T --
---------------
LinkLuaModifier("modifier_picasso_t", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_picasso_t_red", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_picasso_t_red_hit_cd", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_picasso_t_zeal_mode", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_picasso_pieces_thinker", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
if item_picasso_t == nil then item_picasso_t = class({}) end
function item_picasso_t:GetIntrinsicModifierName() return "modifier_picasso_t" end

if modifier_picasso_t == nil then modifier_picasso_t = class({}) end
function modifier_picasso_t:IsHidden() return true end
function modifier_picasso_t:IsPurgable() return false end
function modifier_picasso_t:RemoveOnDeath() return false end
function modifier_picasso_t:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_picasso_t:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end if not self:GetParent():IsIllusion() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_pieces_thinker", {})
		self:StartIntervalThink(FrameTime())
end end end
function modifier_picasso_t:OnIntervalThink()
	if IsServer() then if not self:GetCaster():HasModifier("modifier_picasso_2_pieces") then if not self:GetParent():IsIllusion() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_t_red", {})
end end end end
function modifier_picasso_t:OnDestroy()
	if IsServer() then if not self:GetCaster():HasModifier("modifier_picasso_paint_red") then
		self:GetCaster():RemoveModifierByName("modifier_picasso_t_red")
end end end
---------------
-- Red Paint --
---------------
if modifier_picasso_t_red == nil then modifier_picasso_t_red = class({}) end
function modifier_picasso_t_red:IsHidden() return false end
function modifier_picasso_t_red:IsPurgable() return false end
function modifier_picasso_t_red:RemoveOnDeath() return false end
function modifier_picasso_t_red:GetTexture() return "custom/picasso_paint_red" end
function modifier_picasso_t_red:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
		self:SetStackCount(0)
	end
end
function modifier_picasso_t_red:OnIntervalThink()
	if IsServer() then
		local zeal_mode_duration = self:GetAbility():GetSpecialValueFor("zeal_mode_duration")
		if self:GetStackCount() == 4 then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_t_zeal_mode", {duration = zeal_mode_duration})
			self:SetStackCount(0)
		end
	end
end
function modifier_picasso_t_red:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_picasso_t_red:OnAttackLanded(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local stacks = self:GetStackCount()
		local hit_cd = self:GetAbility():GetSpecialValueFor("hit_cd")
		if caster:HasModifier("modifier_picasso_3_pieces") then
			hit_cd = hit_cd - self:GetAbility():GetSpecialValueFor("hit_cd_3")
		end
		if not caster:HasModifier("modifier_picasso_t_red_hit_cd") then
			self:SetStackCount(stacks + 1)
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_t_red_hit_cd", {duration = hit_cd})
		end
	end
end
function modifier_picasso_t_red:OnDestroy() if IsServer() then self:Destroy() end end
if modifier_picasso_t_red_hit_cd == nil then modifier_picasso_t_red_hit_cd = class({}) end
function modifier_picasso_t_red_hit_cd:IsHidden() return true end
function modifier_picasso_t_red_hit_cd:IsDebuff() return true end
function modifier_picasso_t_red_hit_cd:IsPurgable() return false end
function modifier_picasso_t_red_hit_cd:RemoveOnDeath() return false end
function modifier_picasso_t_red_hit_cd:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
---------------
-- Zeal Mode --
---------------
if modifier_picasso_t_zeal_mode == nil then modifier_picasso_t_zeal_mode = class({}) end
function modifier_picasso_t_zeal_mode:IsHidden() return false end
function modifier_picasso_t_zeal_mode:GetTexture() return "custom/picasso_paint_red" end
function modifier_picasso_t_zeal_mode:IsPurgable() return false end
function modifier_picasso_t_zeal_mode:RemoveOnDeath() return false end
function modifier_picasso_t_zeal_mode:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	zeal_mode_pfx = "particles/custom/items/picasso/picasso_zeal_mode.vpcf"
	self.zm_fx = ParticleManager:CreateParticle(zeal_mode_pfx, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.zm_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	self:AddParticle(self.zm_fx, false, false, -1, false, false)
end
function modifier_picasso_t_zeal_mode:OnDestroy()
	ParticleManager:DestroyParticle(self.zm_fx, false)
	ParticleManager:ReleaseParticleIndex(self.zm_fx)
end
function modifier_picasso_t_zeal_mode:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE} end
function modifier_picasso_t_zeal_mode:GetModifierBaseDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("zeal_mode_dmg") end
end

---------------
-- Picasso M --
---------------
LinkLuaModifier("modifier_picasso_m", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_picasso_m_yellow", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_picasso_m_yellow_hit_cd", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_picasso_m_shelter_mode", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
if item_picasso_m == nil then item_picasso_m = class({}) end
function item_picasso_m:GetIntrinsicModifierName() return "modifier_picasso_m" end

if modifier_picasso_m == nil then modifier_picasso_m = class({}) end
function modifier_picasso_m:IsHidden() return true end
function modifier_picasso_m:IsPurgable() return false end
function modifier_picasso_m:RemoveOnDeath() return false end
function modifier_picasso_m:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_picasso_m:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end if not self:GetParent():IsIllusion() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_pieces_thinker", {})
		self:StartIntervalThink(FrameTime())
end end end
function modifier_picasso_m:OnIntervalThink()
	if IsServer() then if not self:GetCaster():HasModifier("modifier_picasso_2_pieces") then if not self:GetParent():IsIllusion() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_m_yellow", {})
end end end end
function modifier_picasso_m:OnDestroy()
	if IsServer() then if not self:GetCaster():HasModifier("modifier_picasso_paint_yellow") then if not self:GetParent():IsIllusion() then
		self:GetCaster():RemoveModifierByName("modifier_picasso_m_yellow")
end end end end
------------------
-- Yellow Paint --
------------------
if modifier_picasso_m_yellow == nil then modifier_picasso_m_yellow = class({}) end
function modifier_picasso_m_yellow:IsHidden() return false end
function modifier_picasso_m_yellow:IsPurgable() return false end
function modifier_picasso_m_yellow:RemoveOnDeath() return false end
function modifier_picasso_m_yellow:GetTexture() return "custom/picasso_paint_yellow" end
function modifier_picasso_m_yellow:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
		self:SetStackCount(0)
	end
end
function modifier_picasso_m_yellow:OnIntervalThink()
	if IsServer() then
		local shelter_mode_duration = self:GetAbility():GetSpecialValueFor("shelter_mode_duration")
		if self:GetStackCount() == 4 then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_m_shelter_mode", {duration = shelter_mode_duration})
			self:SetStackCount(0)
		end
	end
end
function modifier_picasso_m_yellow:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_picasso_m_yellow:OnAttackLanded(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local stacks = self:GetStackCount()
		local hit_cd = self:GetAbility():GetSpecialValueFor("hit_cd")
		if caster:HasModifier("modifier_picasso_3_pieces") then
			hit_cd = hit_cd - self:GetAbility():GetSpecialValueFor("hit_cd_3")
		end
		if not caster:HasModifier("modifier_picasso_m_yellow_hit_cd") then
			self:SetStackCount(stacks + 1)
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_m_yellow_hit_cd", {duration = hit_cd})
		end
	end
end
function modifier_picasso_m_yellow:OnDestroy() if IsServer() then self:Destroy() end end
if modifier_picasso_m_yellow_hit_cd == nil then modifier_picasso_m_yellow_hit_cd = class({}) end
function modifier_picasso_m_yellow_hit_cd:IsHidden() return true end
function modifier_picasso_m_yellow_hit_cd:IsDebuff() return true end
function modifier_picasso_m_yellow_hit_cd:IsPurgable() return false end
function modifier_picasso_m_yellow_hit_cd:RemoveOnDeath() return false end
function modifier_picasso_m_yellow_hit_cd:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
------------------
-- Shelter Mode --
------------------
if modifier_picasso_m_shelter_mode == nil then modifier_picasso_m_shelter_mode = class({}) end
function modifier_picasso_m_shelter_mode:IsHidden() return false end
function modifier_picasso_m_shelter_mode:IsPurgable() return false end
function modifier_picasso_m_shelter_mode:RemoveOnDeath() return false end
function modifier_picasso_m_shelter_mode:GetTexture() return "custom/picasso_paint_yellow" end
function modifier_picasso_m_shelter_mode:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	shelter_mode_pfx = "particles/custom/items/picasso/picasso_shelter_mode.vpcf"
	self.sm_fx = ParticleManager:CreateParticle(shelter_mode_pfx, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.sm_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	self:AddParticle(self.sm_fx, false, false, -1, false, false)
end
function modifier_picasso_m_shelter_mode:OnDestroy()
	ParticleManager:DestroyParticle(self.sm_fx, false)
	ParticleManager:ReleaseParticleIndex(self.sm_fx)
end
function modifier_picasso_m_shelter_mode:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE}
end
function modifier_picasso_m_shelter_mode:GetModifierIncomingPhysicalDamage_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("shelter_mode_phys_inc") * (-1) end
end
function modifier_picasso_m_shelter_mode:GetModifierStatusResistance()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("shelter_mode_resist") end
end

---------------
-- Picasso B --
---------------
LinkLuaModifier("modifier_picasso_b", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_picasso_b_blue", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_picasso_b_blue_hit_cd", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_picasso_b_impulse_mode", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
if item_picasso_b == nil then item_picasso_b = class({}) end
function item_picasso_b:GetIntrinsicModifierName() return "modifier_picasso_b" end

if modifier_picasso_b == nil then modifier_picasso_b = class({}) end
function modifier_picasso_b:IsHidden() return true end
function modifier_picasso_b:IsPurgable() return false end
function modifier_picasso_b:RemoveOnDeath() return false end
function modifier_picasso_b:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_picasso_b:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end if not self:GetParent():IsIllusion() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_pieces_thinker", {})
		self:StartIntervalThink(FrameTime())
end end end
function modifier_picasso_b:OnIntervalThink()
	if IsServer() then if not self:GetCaster():HasModifier("modifier_picasso_2_pieces") then if not self:GetParent():IsIllusion() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_b_blue", {})
end end end end
function modifier_picasso_b:OnDestroy()
	if IsServer() then if not self:GetCaster():HasModifier("modifier_picasso_paint_blue") then if not self:GetParent():IsIllusion() then
		self:GetCaster():RemoveModifierByName("modifier_picasso_b_blue")
end end end end
----------------
-- Blue Paint --
----------------
if modifier_picasso_b_blue == nil then modifier_picasso_b_blue = class({}) end
function modifier_picasso_b_blue:IsHidden() return false end
function modifier_picasso_b_blue:IsPurgable() return false end
function modifier_picasso_b_blue:RemoveOnDeath() return false end
function modifier_picasso_b_blue:GetTexture() return "custom/picasso_paint_blue" end
function modifier_picasso_b_blue:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
		self:SetStackCount(0)
	end
end
function modifier_picasso_b_blue:OnIntervalThink()
	if IsServer() then
		local impulse_mode_duration = self:GetAbility():GetSpecialValueFor("impulse_mode_duration")
		if self:GetStackCount() == 4 then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_b_impulse_mode", {duration = impulse_mode_duration})
			self:SetStackCount(0)
		end
	end
end
function modifier_picasso_b_blue:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_picasso_b_blue:OnAttackLanded(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local stacks = self:GetStackCount()
		local hit_cd = self:GetAbility():GetSpecialValueFor("hit_cd")
		if caster:HasModifier("modifier_picasso_3_pieces") then
			hit_cd = hit_cd - self:GetAbility():GetSpecialValueFor("hit_cd_3")
		end
		if not caster:HasModifier("modifier_picasso_b_blue_hit_cd") then
			self:SetStackCount(stacks + 1)
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_b_blue_hit_cd", {duration = hit_cd})
		end
	end
end
function modifier_picasso_b_blue:OnDestroy() if IsServer() then self:Destroy() end end
if modifier_picasso_b_blue_hit_cd == nil then modifier_picasso_b_blue_hit_cd = class({}) end
function modifier_picasso_b_blue_hit_cd:IsHidden() return true end
function modifier_picasso_b_blue_hit_cd:IsDebuff() return true end
function modifier_picasso_b_blue_hit_cd:IsPurgable() return false end
function modifier_picasso_b_blue_hit_cd:RemoveOnDeath() return false end
function modifier_picasso_b_blue_hit_cd:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
------------------
-- Impulse Mode --
------------------
if modifier_picasso_b_impulse_mode == nil then modifier_picasso_b_impulse_mode = class({}) end
function modifier_picasso_b_impulse_mode:IsHidden() return false end
function modifier_picasso_b_impulse_mode:GetTexture() return "custom/picasso_paint_blue" end
function modifier_picasso_b_impulse_mode:IsPurgable() return false end
function modifier_picasso_b_impulse_mode:RemoveOnDeath() return false end
function modifier_picasso_b_impulse_mode:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	impulse_mode_pfx = "particles/custom/items/picasso/picasso_impulse_mode.vpcf"
	self.im_fx = ParticleManager:CreateParticle(impulse_mode_pfx, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.im_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	self:AddParticle(self.im_fx, false, false, -1, false, false)
end
function modifier_picasso_b_impulse_mode:OnDestroy()
	ParticleManager:DestroyParticle(self.im_fx, false)
	ParticleManager:ReleaseParticleIndex(self.im_fx)
end
function modifier_picasso_b_impulse_mode:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE} end
function modifier_picasso_b_impulse_mode:GetModifierAttackSpeedPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("impulse_mode_as") end
end


if modifier_picasso_pieces_thinker == nil then modifier_picasso_pieces_thinker = class({}) end
function modifier_picasso_pieces_thinker:IsHidden() return true end
function modifier_picasso_pieces_thinker:IsPurgable() return false end
function modifier_picasso_pieces_thinker:RemoveOnDeath() return false end
function modifier_picasso_pieces_thinker:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end self:StartIntervalThink(FrameTime()) end
end
function modifier_picasso_pieces_thinker:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local paint_red = caster:HasModifier("modifier_picasso_t")
		local paint_yellow = caster:HasModifier("modifier_picasso_m")
		local paint_blue = caster:HasModifier("modifier_picasso_b")
		--2pieces
		if (paint_red and paint_yellow) or (paint_yellow and paint_blue) or (paint_blue and paint_red) or (paint_red and paint_yellow and paint_blue) then
			if not caster:HasModifier("modifier_picasso_paint_red") or not caster:HasModifier("modifier_picasso_paint_yellow") or not caster:HasModifier("modifier_picasso_paint_blue") then
				caster:AddNewModifier(caster, self:GetAbility(), "modifier_picasso_2_pieces", {})
			end
		else
			caster:RemoveModifierByName("modifier_picasso_2_pieces")
		end
		--3pieces
		if paint_red and paint_yellow and paint_blue then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_picasso_3_pieces", {})
		else
			caster:RemoveModifierByName("modifier_picasso_3_pieces")
		end
	end
end


-------------------------
-- Dye Impact 2 Pieces --
-------------------------
LinkLuaModifier("modifier_picasso_2_pieces", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_picasso_2_pieces == nil then modifier_picasso_2_pieces = class({}) end
function modifier_picasso_2_pieces:IsHidden() return true end
function modifier_picasso_2_pieces:IsPurgable() return false end
function modifier_picasso_2_pieces:RemoveOnDeath() return false end
function modifier_picasso_2_pieces:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
--		self:StartIntervalThink(FrameTime())
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local paint_red = caster:HasModifier("modifier_picasso_t")
		local paint_yellow = caster:HasModifier("modifier_picasso_m")
		local paint_blue = caster:HasModifier("modifier_picasso_b")
		local switch_interval = self:GetAbility():GetSpecialValueFor("switch_interval")

--		if (not caster:HasModifier("modifier_picasso_t")) or (not caster:HasModifier("modifier_picasso_m")) or (not caster:HasModifier("modifier_picasso_b")) then
			if paint_red and paint_yellow then
				if caster:HasModifier("modifier_picasso_t_red") then
					self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_t_red", {duration = switch_interval})
					self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_paint_red", {duration = switch_interval})
				elseif caster:HasModifier("modifier_picasso_m_yellow") then
					self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_m_yellow", {duration = switch_interval})
					self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_paint_yellow", {duration = switch_interval})
				end
			end
			if paint_yellow and paint_blue then
				if caster:HasModifier("modifier_picasso_m_yellow") then
					self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_m_yellow", {duration = switch_interval})
					self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_paint_yellow", {duration = switch_interval})
				elseif caster:HasModifier("modifier_picasso_b_blue") then
					self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_b_blue", {duration = switch_interval})
					self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_paint_blue", {duration = switch_interval})
				end
			end
			if paint_blue and paint_red then
				if caster:HasModifier("modifier_picasso_b_blue") then
					self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_b_blue", {duration = switch_interval})
					self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_paint_blue", {duration = switch_interval})
				elseif caster:HasModifier("modifier_picasso_t_red") then
					self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_t_red", {duration = switch_interval})
					self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_paint_red", {duration = switch_interval})
				end
			end
--		end
	end
end

-------------------
-- Red Paint Jar --
-------------------
LinkLuaModifier("modifier_picasso_paint_red", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_picasso_paint_red_blob", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_picasso_paint_red == nil then modifier_picasso_paint_red = class({}) end
function modifier_picasso_paint_red:IsHidden() return false end
function modifier_picasso_paint_red:IsPurgable() return false end
function modifier_picasso_paint_red:RemoveOnDeath() return false end
function modifier_picasso_paint_red:GetTexture() return "custom/picasso_t" end
function modifier_picasso_paint_red:OnCreated() if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:GetCaster():RemoveModifierByName("modifier_picasso_m_yellow")
		self:GetCaster():RemoveModifierByName("modifier_picasso_paint_yellow")
		self:GetCaster():RemoveModifierByName("modifier_picasso_b_blue")
		self:GetCaster():RemoveModifierByName("modifier_picasso_paint_blue")
	end	
end
function modifier_picasso_paint_red:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_picasso_paint_red:OnAttackLanded(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local stacks = self:GetStackCount()
		local blob_duration = self:GetAbility():GetSpecialValueFor("blob_duration")
		local blob_duration_3 = self:GetAbility():GetSpecialValueFor("blob_duration_3")
		if self:GetCaster():HasModifier("modifier_picasso_3_pieces") then blob_duration = blob_duration_3 end
		if not target:HasModifier("modifier_picasso_dry") then
			target:AddNewModifier(caster, self:GetAbility(), "modifier_picasso_paint_red_blob", {duration = blob_duration})
		end
	end
end
function modifier_picasso_paint_red:OnDestroy()
	if IsServer() then
		local switch_interval = self:GetAbility():GetSpecialValueFor("switch_interval")
		if self:GetCaster():HasModifier("modifier_picasso_2_pieces") then
			if self:GetCaster():HasModifier("modifier_picasso_m") then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_m_yellow", {duration = switch_interval})
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_paint_yellow", {duration = switch_interval})
			elseif self:GetCaster():HasModifier("modifier_picasso_b") then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_b_blue", {duration = switch_interval})
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_paint_blue", {duration = switch_interval})
			end
		end
	end
end
--red blop
if modifier_picasso_paint_red_blob == nil then modifier_picasso_paint_red_blob = class({}) end
function modifier_picasso_paint_red_blob:IsHidden() return false end
function modifier_picasso_paint_red_blob:IsDebuff() return true end
function modifier_picasso_paint_red_blob:IsPurgable() return false end
function modifier_picasso_paint_red_blob:RemoveOnDeath() return false end
function modifier_picasso_paint_red_blob:GetTexture() return "custom/picasso_t" end
function modifier_picasso_paint_red_blob:GetEffectName() return "particles/custom/items/picasso/picasso_red_blop.vpcf" end
function modifier_picasso_paint_red_blob:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_picasso_paint_red_blob:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end self:StartIntervalThink(FrameTime()) end
end
function modifier_picasso_paint_red_blob:OnIntervalThink()
	if IsServer() then
		local mix_duration = self:GetAbility():GetSpecialValueFor("mix_duration")
		if self:GetParent():HasModifier("modifier_picasso_paint_yellow_blob") then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_orange_mix", {duration = mix_duration * (1 - self:GetParent():GetStatusResistance())})
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_dry", {duration = mix_duration})
			self:GetParent():RemoveModifierByName("modifier_picasso_paint_red_blob")
			self:GetParent():RemoveModifierByName("modifier_picasso_paint_yellow_blob")
		end
	end
end

----------------------
-- Yellow Paint Jar --
----------------------
LinkLuaModifier("modifier_picasso_paint_yellow", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_picasso_paint_yellow_blob", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_picasso_paint_yellow == nil then modifier_picasso_paint_yellow = class({}) end
function modifier_picasso_paint_yellow:IsHidden() return false end
function modifier_picasso_paint_yellow:IsPurgable() return false end
function modifier_picasso_paint_yellow:RemoveOnDeath() return false end
function modifier_picasso_paint_yellow:GetTexture() return "custom/picasso_m" end
function modifier_picasso_paint_yellow:OnCreated() if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:GetCaster():RemoveModifierByName("modifier_picasso_b_blue")
		self:GetCaster():RemoveModifierByName("modifier_picasso_paint_blue")
		self:GetCaster():RemoveModifierByName("modifier_picasso_t_red")
		self:GetCaster():RemoveModifierByName("modifier_picasso_paint_red")
	end
end
function modifier_picasso_paint_yellow:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_picasso_paint_yellow:OnAttackLanded(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local stacks = self:GetStackCount()
		local blob_duration = self:GetAbility():GetSpecialValueFor("blob_duration")
		local blob_duration_3 = self:GetAbility():GetSpecialValueFor("blob_duration_3")
		if self:GetCaster():HasModifier("modifier_picasso_3_pieces") then blob_duration = blob_duration_3 end
		if not target:HasModifier("modifier_picasso_dry") then
			target:AddNewModifier(caster, self:GetAbility(), "modifier_picasso_paint_yellow_blob", {duration = blob_duration})
		end
	end
end
function modifier_picasso_paint_yellow:OnDestroy()
	if IsServer() then
		local switch_interval = self:GetAbility():GetSpecialValueFor("switch_interval")
		if self:GetCaster():HasModifier("modifier_picasso_2_pieces") then
			if self:GetCaster():HasModifier("modifier_picasso_b") then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_b_blue", {duration = switch_interval})
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_paint_blue", {duration = switch_interval})
			elseif self:GetCaster():HasModifier("modifier_picasso_t") then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_t_red", {duration = switch_interval})
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_paint_red", {duration = switch_interval})
			end
		end
	end
end
--yellow blop
if modifier_picasso_paint_yellow_blob == nil then modifier_picasso_paint_yellow_blob = class({}) end
function modifier_picasso_paint_yellow_blob:IsHidden() return false end
function modifier_picasso_paint_yellow_blob:IsDebuff() return true end
function modifier_picasso_paint_yellow_blob:IsPurgable() return false end
function modifier_picasso_paint_yellow_blob:RemoveOnDeath() return false end
function modifier_picasso_paint_yellow_blob:GetTexture() return "custom/picasso_m" end
function modifier_picasso_paint_yellow_blob:GetEffectName() return "particles/custom/items/picasso/picasso_yellow_blop.vpcf" end
function modifier_picasso_paint_yellow_blob:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_picasso_paint_yellow_blob:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end self:StartIntervalThink(FrameTime()) end
end
function modifier_picasso_paint_yellow_blob:OnIntervalThink()
	if IsServer() then
		local mix_duration = self:GetAbility():GetSpecialValueFor("mix_duration")
		if self:GetParent():HasModifier("modifier_picasso_paint_blue_blob") then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_purple_mix", {})
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_dry", {duration = mix_duration})
			self:GetParent():RemoveModifierByName("modifier_picasso_paint_yellow_blob")
			self:GetParent():RemoveModifierByName("modifier_picasso_paint_blue_blob")
		end
	end
end

--------------------
-- Blue Paint Jar --
--------------------
LinkLuaModifier("modifier_picasso_paint_blue", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_picasso_paint_blue_blob", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_picasso_paint_blue == nil then modifier_picasso_paint_blue = class({}) end
function modifier_picasso_paint_blue:IsHidden() return false end
function modifier_picasso_paint_blue:IsPurgable() return false end
function modifier_picasso_paint_blue:RemoveOnDeath() return false end
function modifier_picasso_paint_blue:GetTexture() return "custom/picasso_b" end
function modifier_picasso_paint_blue:OnCreated() if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:GetCaster():RemoveModifierByName("modifier_picasso_t_red")
		self:GetCaster():RemoveModifierByName("modifier_picasso_paint_red")
		self:GetCaster():RemoveModifierByName("modifier_picasso_m_yellow")
		self:GetCaster():RemoveModifierByName("modifier_picasso_paint_yellow")
	end
end
function modifier_picasso_paint_blue:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_picasso_paint_blue:OnAttackLanded(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local owner = self:GetParent()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local stacks = self:GetStackCount()
		local blob_duration = self:GetAbility():GetSpecialValueFor("blob_duration")
		local blob_duration_3 = self:GetAbility():GetSpecialValueFor("blob_duration_3")
		if self:GetCaster():HasModifier("modifier_picasso_3_pieces") then blob_duration = blob_duration_3 end
		if not target:HasModifier("modifier_picasso_dry") then
			target:AddNewModifier(caster, self:GetAbility(), "modifier_picasso_paint_blue_blob", {duration = blob_duration})
		end
	end
end
function modifier_picasso_paint_blue:OnDestroy()
	if IsServer() then
		local switch_interval = self:GetAbility():GetSpecialValueFor("switch_interval")
		if self:GetCaster():HasModifier("modifier_picasso_2_pieces") then
			if self:GetCaster():HasModifier("modifier_picasso_t") then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_t_red", {duration = switch_interval})
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_paint_red", {duration = switch_interval})
			elseif self:GetCaster():HasModifier("modifier_picasso_m") then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_m_yellow", {duration = switch_interval})
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_paint_yellow", {duration = switch_interval})
			end
		end
	end
end
--blue blop
if modifier_picasso_paint_blue_blob == nil then modifier_picasso_paint_blue_blob = class({}) end
function modifier_picasso_paint_blue_blob:IsHidden() return false end
function modifier_picasso_paint_blue_blob:IsDebuff() return true end
function modifier_picasso_paint_blue_blob:IsPurgable() return false end
function modifier_picasso_paint_blue_blob:RemoveOnDeath() return false end
function modifier_picasso_paint_blue_blob:GetTexture() return "custom/picasso_b" end
function modifier_picasso_paint_blue_blob:GetEffectName() return "particles/custom/items/picasso/picasso_blue_blop.vpcf" end
function modifier_picasso_paint_blue_blob:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_picasso_paint_blue_blob:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_picasso_paint_blue_blob:OnIntervalThink()
	if IsServer() then
		local mix_duration = self:GetAbility():GetSpecialValueFor("mix_duration")
		if self:GetParent():HasModifier("modifier_picasso_paint_red_blob") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_green_mix", {})
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_picasso_dry", {duration = mix_duration})
			self:GetParent():RemoveModifierByName("modifier_picasso_paint_blue_blob")
			self:GetParent():RemoveModifierByName("modifier_picasso_paint_red_blob")
		end
	end
end

------------------------
-- Paint Jar 3 Pieces --
------------------------
LinkLuaModifier("modifier_picasso_3_pieces", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_picasso_3_pieces == nil then modifier_picasso_3_pieces = class({}) end
function modifier_picasso_3_pieces:IsHidden() return true end
function modifier_picasso_3_pieces:IsPurgable() return false end
function modifier_picasso_3_pieces:RemoveOnDeath() return false end
function modifier_picasso_3_pieces:OnCreated() if IsServer() then if not self:GetAbility() then self:Destroy() end end end

---------
-- Dry --
---------
LinkLuaModifier("modifier_picasso_dry", "items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_picasso_dry == nil then modifier_picasso_dry = class({}) end
function modifier_picasso_dry:IsHidden() return false end
function modifier_picasso_dry:IsPurgable() return false end
function modifier_picasso_dry:RemoveOnDeath() return false end
function modifier_picasso_dry:GetTexture() return "river_painter2" end
function modifier_picasso_dry:OnCreated() if IsServer() then if not self:GetAbility() then self:Destroy() end end end

-----------	modifier_picasso_orange_mix
-- Mixes --	modifier_picasso_purple_mix
-----------	modifier_picasso_green_mix
LinkLuaModifier("modifier_picasso_orange_mix",	"items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_picasso_purple_mix",	"items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_picasso_green_mix",	"items/picasso.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_picasso_orange_mix == nil then modifier_picasso_orange_mix = class({}) end
function modifier_picasso_orange_mix:IsHidden() return false end
function modifier_picasso_orange_mix:IsPurgable() return true end
function modifier_picasso_orange_mix:RemoveOnDeath() return true end
function modifier_picasso_orange_mix:GetEffectName() return "particles/custom/items/picasso/picasso_orange_mix.vpcf" end
function modifier_picasso_orange_mix:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_picasso_orange_mix:OnCreated() if IsServer() then if not self:GetAbility() then self:Destroy() end end end
function modifier_picasso_orange_mix:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE} end
function modifier_picasso_orange_mix:GetModifierIncomingPhysicalDamage_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("orange_mix") end
end

if modifier_picasso_purple_mix == nil then modifier_picasso_purple_mix = class({}) end
function modifier_picasso_purple_mix:IsHidden() return false end
function modifier_picasso_purple_mix:IsPurgable() return true end
function modifier_picasso_purple_mix:RemoveOnDeath() return true end
function modifier_picasso_purple_mix:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local purple_dmg = self:GetAbility():GetSpecialValueFor("purple_dmg")
		local purple_radius = self:GetAbility():GetSpecialValueFor("purple_radius")
		local dmg = self:GetCaster():GetAttackDamage() * (purple_dmg / 100)
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, purple_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,enemy in pairs(enemies) do
			if enemy~=self:GetCaster() then
				ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = dmg, damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, ability = self:GetAbility()})
			end
		end
		local purple_mix_pfx = "particles/custom/items/picasso/picasso_purple_mix.vpcf"
		local purple_fx = ParticleManager:CreateParticle(purple_mix_pfx, PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(purple_fx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(purple_fx)
		self:GetParent():RemoveModifierByName("modifier_picasso_purple_mix")
	end
end
function modifier_picasso_purple_mix:DeclareFunctions() return {MODIFIER_PROPERTY_TOOLTIP} end
function modifier_picasso_purple_mix:OnTooltip()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("purple_dmg") end
end

if modifier_picasso_green_mix == nil then modifier_picasso_green_mix = class({}) end
function modifier_picasso_green_mix:IsHidden() return false end
function modifier_picasso_green_mix:IsPurgable() return false end
function modifier_picasso_green_mix:RemoveOnDeath() return false end
function modifier_picasso_green_mix:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local green_heal = self:GetAbility():GetSpecialValueFor("green_heal")
		local heal = self:GetCaster():GetMaxHealth() * (green_heal / 100)
		self:GetCaster():Heal(heal, self:GetCaster())
		local heal_particle = "particles/custom/items/picasso/picasso_green_mix.vpcf"
		local heal_fx = ParticleManager:CreateParticle(heal_particle, PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControl(heal_fx, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControl(heal_fx, 3, self:GetCaster():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(heal_fx)
		self:GetCaster():RemoveModifierByName("modifier_picasso_green_mix")
	end
end
function modifier_picasso_green_mix:DeclareFunctions() return {MODIFIER_PROPERTY_TOOLTIP} end
function modifier_picasso_green_mix:OnTooltip()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("green_heal") end
end

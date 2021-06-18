--------------------
-- Lier Scarlet T --
--------------------
LinkLuaModifier("modifier_lier_scarlet_t", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
if item_lier_scarlet_t == nil then item_lier_scarlet_t = class({}) end
function item_lier_scarlet_t:GetIntrinsicModifierName() return "modifier_lier_scarlet_t" end

if modifier_lier_scarlet_t == nil then modifier_lier_scarlet_t = class({}) end
function modifier_lier_scarlet_t:IsHidden() return true end
function modifier_lier_scarlet_t:IsPurgable() return false end
function modifier_lier_scarlet_t:RemoveOnDeath() return false end
function modifier_lier_scarlet_t:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_lier_scarlet_t:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end if not self:GetParent():IsIllusion() then
		self:StartIntervalThink(FrameTime())
end end end
function modifier_lier_scarlet_t:OnIntervalThink()
	if IsServer() then
		local lier_scarlet_t = self:GetCaster():HasModifier("modifier_lier_scarlet_t")
		local lier_scarlet_m = self:GetCaster():HasModifier("modifier_lier_scarlet_m")
		local lier_scarlet_b = self:GetCaster():HasModifier("modifier_lier_scarlet_b")
		--2piece
		if (lier_scarlet_t and lier_scarlet_m) or (lier_scarlet_m and lier_scarlet_b) or (lier_scarlet_b and lier_scarlet_t) then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_2_pieces", {})
		elseif self:GetCaster():HasModifier("modifier_lier_scarlet_2_pieces") then
			self:GetCaster():RemoveModifierByName("modifier_lier_scarlet_2_pieces")
		end
		--3piece
		if lier_scarlet_t and lier_scarlet_m and lier_scarlet_b and not self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff_cd") and not self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_3_pieces", {})
		elseif self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces") then
			self:GetCaster():RemoveModifierByName("modifier_lier_scarlet_3_pieces")
		end
		if self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff_cd") and self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff") then
			self:GetCaster():RemoveModifierByName("modifier_lier_scarlet_3_pieces")
		end
	end
end
function modifier_lier_scarlet_t:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_lier_scarlet_t:GetModifierExtraHealthPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("max_hp_pct") * (-1) end
end
function modifier_lier_scarlet_t:GetModifierTotalDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("total_dmg") end
end

--------------------
-- Lier Scarlet M --
--------------------
LinkLuaModifier("modifier_lier_scarlet_m", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lier_scarlet_m_thinker", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
if item_lier_scarlet_m == nil then item_lier_scarlet_m = class({}) end
function item_lier_scarlet_m:GetIntrinsicModifierName() return "modifier_lier_scarlet_m" end

if modifier_lier_scarlet_m == nil then modifier_lier_scarlet_m = class({}) end
function modifier_lier_scarlet_m:IsHidden() return true end
function modifier_lier_scarlet_m:IsPurgable() return false end
function modifier_lier_scarlet_m:RemoveOnDeath() return false end
function modifier_lier_scarlet_m:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_lier_scarlet_m:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end if not self:GetParent():IsIllusion() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_m_thinker", {})
		local aoe_interval = self:GetAbility():GetSpecialValueFor("aoe_interval")
		self:StartIntervalThink(aoe_interval)
end end end
function modifier_lier_scarlet_m:OnIntervalThink()
	if IsServer() then
		local heal_pct = self:GetAbility():GetSpecialValueFor("heal_pct")
		local aoe_dmg = self:GetAbility():GetSpecialValueFor("aoe_dmg")
		local aoe_radius = self:GetAbility():GetSpecialValueFor("aoe_radius")
		local dmg = self:GetCaster():GetAttackDamage() * aoe_dmg / 100
		local heal = (self:GetCaster():GetMaxHealth() * heal_pct / 100)
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, aoe_radius--[[FIND_UNITS_EVERYWHERE]], DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,enemy in pairs(enemies) do
			if enemy~=self:GetCaster() then
				local damageTable = {victim = enemy, attacker = self:GetCaster(), damage = dmg, damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, ability = self:GetAbility()}
				ApplyDamage(damageTable)
				local aoe_interval = self:GetAbility():GetSpecialValueFor("aoe_interval")
				Timers:CreateTimer({(aoe_interval / 3), function() ApplyDamage(damageTable) end})
				Timers:CreateTimer({(aoe_interval / 3 * 2), function() ApplyDamage(damageTable) end})
			end
		end
		self:GetCaster():Heal(heal,self:GetCaster())
	end
end
function modifier_lier_scarlet_m:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE}
end
function modifier_lier_scarlet_m:GetModifierExtraHealthPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("max_hp_pct") * (-1) end
end

if modifier_lier_scarlet_m_thinker == nil then modifier_lier_scarlet_m_thinker = class({}) end
function modifier_lier_scarlet_m_thinker:IsHidden() return true end
function modifier_lier_scarlet_m_thinker:IsPurgable() return false end
function modifier_lier_scarlet_m_thinker:RemoveOnDeath() return false end
function modifier_lier_scarlet_m_thinker:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_lier_scarlet_m_thinker:OnIntervalThink()
	if IsServer() then
		local lier_scarlet_t = self:GetCaster():HasModifier("modifier_lier_scarlet_t")
		local lier_scarlet_m = self:GetCaster():HasModifier("modifier_lier_scarlet_m")
		local lier_scarlet_b = self:GetCaster():HasModifier("modifier_lier_scarlet_b")
		--2piece
		if (lier_scarlet_t and lier_scarlet_m) or (lier_scarlet_m and lier_scarlet_b) or (lier_scarlet_b and lier_scarlet_t) then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_2_pieces", {})
		elseif self:GetCaster():HasModifier("modifier_lier_scarlet_2_pieces") then
			self:GetCaster():RemoveModifierByName("modifier_lier_scarlet_2_pieces")
		end
		--3piece
		if lier_scarlet_t and lier_scarlet_m and lier_scarlet_b and not self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff_cd") and not self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_3_pieces", {})
		elseif self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces") then
			self:GetCaster():RemoveModifierByName("modifier_lier_scarlet_3_pieces")
		end
		if self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff_cd") and self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff") then
			self:GetCaster():RemoveModifierByName("modifier_lier_scarlet_3_pieces")
		end
	end
end

--------------------
-- Lier Scarlet B --
--------------------
LinkLuaModifier("modifier_lier_scarlet_b", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
if item_lier_scarlet_b == nil then item_lier_scarlet_b = class({}) end
function item_lier_scarlet_b:GetIntrinsicModifierName() return "modifier_lier_scarlet_b" end

if modifier_lier_scarlet_b == nil then modifier_lier_scarlet_b = class({}) end
function modifier_lier_scarlet_b:IsHidden() return true end
function modifier_lier_scarlet_b:IsPurgable() return false end
function modifier_lier_scarlet_b:RemoveOnDeath() return false end
function modifier_lier_scarlet_b:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_lier_scarlet_b:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end if not self:GetParent():IsIllusion() then
		self:StartIntervalThink(FrameTime())
end end end
function modifier_lier_scarlet_b:OnIntervalThink()
	if IsServer() then
		--[[local display_as = self:GetCaster():GetDisplayAttackSpeed() * 0.7
		local bonus_as = self:GetAbility():GetSpecialValueFor("bonus_as_pct")
		self.bonus_as = display_as * (bonus_as / 100)
		self:SetStackCount(self.bonus_as)]]

		local lier_scarlet_t = self:GetCaster():HasModifier("modifier_lier_scarlet_t")
		local lier_scarlet_m = self:GetCaster():HasModifier("modifier_lier_scarlet_m")
		local lier_scarlet_b = self:GetCaster():HasModifier("modifier_lier_scarlet_b")
		--2piece
		if (lier_scarlet_t and lier_scarlet_m) or (lier_scarlet_m and lier_scarlet_b) or (lier_scarlet_b and lier_scarlet_t) then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_2_pieces", {})
		elseif self:GetCaster():HasModifier("modifier_lier_scarlet_2_pieces") then
			self:GetCaster():RemoveModifierByName("modifier_lier_scarlet_2_pieces")
		end
		--3piece
		if lier_scarlet_t and lier_scarlet_m and lier_scarlet_b and not self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff_cd") and not self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_3_pieces", {})
		elseif self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces") then
			self:GetCaster():RemoveModifierByName("modifier_lier_scarlet_3_pieces")
		end
		if self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff_cd") and self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff") then
			self:GetCaster():RemoveModifierByName("modifier_lier_scarlet_3_pieces")
		end
	end
end
function modifier_lier_scarlet_b:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE}
end
function modifier_lier_scarlet_b:GetModifierExtraHealthPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("max_hp_pct") * (-1) end
end
function modifier_lier_scarlet_b:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_ms_pct") end
end
function modifier_lier_scarlet_b:GetModifierAttackSpeedPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_as_pct") end
end


------------------------------
-- Shortened Reach 2 Pieces --
------------------------------
LinkLuaModifier("modifier_lier_scarlet_2_pieces", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_lier_scarlet_2_pieces == nil then modifier_lier_scarlet_2_pieces = class({}) end
function modifier_lier_scarlet_2_pieces:IsHidden() return false end
function modifier_lier_scarlet_2_pieces:GetTexture() return "custom/lier_scarlet_2_piece" end
function modifier_lier_scarlet_2_pieces:IsPurgable() return false end
function modifier_lier_scarlet_2_pieces:RemoveOnDeath() return false end
function modifier_lier_scarlet_2_pieces:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	self.phys_dmg_reduction = self:GetAbility():GetSpecialValueFor("phys_dmg_reduction")
	self.bonus_status_resist = self:GetAbility():GetSpecialValueFor("bonus_status_resist")
end
function modifier_lier_scarlet_2_pieces:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE}
end
function modifier_lier_scarlet_2_pieces:GetModifierIncomingPhysicalDamage_Percentage()
	if self:GetAbility() then return self.phys_dmg_reduction * (-1) end
end
function modifier_lier_scarlet_2_pieces:GetModifierStatusResistance()
	if self:GetAbility() then return self.bonus_status_resist end
end


-------------------------
-- Sword Soul 3 Pieces --
-------------------------
LinkLuaModifier("modifier_lier_scarlet_3_pieces", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lier_scarlet_3_pieces_buff", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lier_scarlet_3_pieces_buff_cd", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_lier_scarlet_3_pieces == nil then modifier_lier_scarlet_3_pieces = class({}) end
function modifier_lier_scarlet_3_pieces:IsHidden() return false end
function modifier_lier_scarlet_3_pieces:GetTexture() return "custom/lier_scarlet_3_piece" end
function modifier_lier_scarlet_3_pieces:IsPurgable() return false end
function modifier_lier_scarlet_3_pieces:RemoveOnDeath() return false end
function modifier_lier_scarlet_3_pieces:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_lier_scarlet_3_pieces:DeclareFunctions()
	return {MODIFIER_PROPERTY_MIN_HEALTH}
end
function modifier_lier_scarlet_3_pieces:GetMinHealth()
	if self:GetAbility() then
		if not self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff_cd") then
			return 1
		else
			return -1
		end
	end
end
function modifier_lier_scarlet_3_pieces:OnIntervalThink()
	if IsServer() then
	local max_health = self:GetCaster():GetMaxHealth()
	local health_threshold = self:GetAbility():GetSpecialValueFor("health_threshold")
	local buff_duration = self:GetAbility():GetSpecialValueFor("3_pieces_duration")
	local trigger = max_health * (health_threshold / 100)
		if not self:GetCaster():IsIllusion() and not self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff_cd") and not self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff") then
			if self:GetCaster():GetHealth() < trigger then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_3_pieces_buff", {duration = buff_duration})
			end
		end
	end
end

------------------------------
-- Sword Soul 3 Pieces Buff --
------------------------------
if modifier_lier_scarlet_3_pieces_buff == nil then modifier_lier_scarlet_3_pieces_buff = class({}) end
function modifier_lier_scarlet_3_pieces_buff:IsHidden() return false end
function modifier_lier_scarlet_3_pieces_buff:GetTexture() return "custom/lier_scarlet_3_piece_immune" end
function modifier_lier_scarlet_3_pieces_buff:GetEffectName() return "particles/custom/items/lier_scarlet/lier_scarlet_immune.vpcf" end
function modifier_lier_scarlet_3_pieces_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_lier_scarlet_3_pieces_buff:IsPurgable() return false end
function modifier_lier_scarlet_3_pieces_buff:RemoveOnDeath() return false end
function modifier_lier_scarlet_3_pieces_buff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_lier_scarlet_3_pieces_buff:OnDestroy()
	if IsServer() then
		local pieces_cd = self:GetAbility():GetSpecialValueFor("3_pieces_cd")
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_3_pieces_buff_cd", {duration = pieces_cd})
	end
end
function modifier_lier_scarlet_3_pieces_buff:DeclareFunctions()
	return {--MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_lier_scarlet_3_pieces_buff:GetModifierCritDMG()
	if IsServer() then
		local bonus_crit = self:GetAbility():GetSpecialValueFor("bonus_crit")
		if RollPseudoRandom(bonus_crit, self:GetAbility()) then
			return bonus_crit
		end
	end
	return 0
end
function modifier_lier_scarlet_3_pieces_buff:OnTooltip()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_crit") end
end
function modifier_lier_scarlet_3_pieces_buff:GetModifierIncomingDamage_Percentage()
	if self:GetAbility() then return -100 end
end
function modifier_lier_scarlet_3_pieces_buff:GetMinHealth()
	if self:GetAbility() then return 1 end
end
function modifier_lier_scarlet_3_pieces_buff:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

if modifier_lier_scarlet_3_pieces_buff_cd == nil then modifier_lier_scarlet_3_pieces_buff_cd = class({}) end
function modifier_lier_scarlet_3_pieces_buff_cd:IsHidden() return false end
function modifier_lier_scarlet_3_pieces_buff_cd:GetTexture() return "custom/lier_scarlet_3_piece_immune" end
function modifier_lier_scarlet_3_pieces_buff_cd:IsDebuff() return true end
function modifier_lier_scarlet_3_pieces_buff_cd:IsPurgable() return false end
function modifier_lier_scarlet_3_pieces_buff_cd:RemoveOnDeath() return false end
function modifier_lier_scarlet_3_pieces_buff_cd:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local duration = self:GetDuration()
--		self:SetStackCount(duration)
		self:StartIntervalThink(1)
	end
end
function modifier_lier_scarlet_3_pieces_buff_cd:OnIntervalThink()
	if IsServer() then
		local duration = self:GetStackCount() - 1 
--		self:SetStackCount(duration)
	end
end

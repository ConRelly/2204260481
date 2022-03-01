-----------------
--MYSTERY STONE--
-----------------
LinkLuaModifier("modifier_mystery_stone_1", "items/mystery_stone.lua", LUA_MODIFIER_MOTION_NONE)
if item_mystery_stone == nil then item_mystery_stone = class({}) end
function item_mystery_stone:GetIntrinsicModifierName() return "modifier_mystery_stone_1" end

if modifier_mystery_stone_1 == nil then modifier_mystery_stone_1 = class({}) end
function modifier_mystery_stone_1:IsHidden() return true end
function modifier_mystery_stone_1:IsPurgable() return false end
function modifier_mystery_stone_1:RemoveOnDeath() return false end
function modifier_mystery_stone_1:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_mystery_stone_1:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_mystery_stone_1:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING}
end
function modifier_mystery_stone_1:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end
function modifier_mystery_stone_1:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_mystery_stone_1:GetModifierCastRangeBonusStacking()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("cast_range") end
end

------------------
--MYSTERY STONE2--
------------------
LinkLuaModifier("modifier_mystery_stone_2", "items/mystery_stone.lua", LUA_MODIFIER_MOTION_NONE)
if item_mystery_stone_2 == nil then item_mystery_stone_2 = class({}) end
function item_mystery_stone_2:GetIntrinsicModifierName() return "modifier_mystery_stone_2" end

if modifier_mystery_stone_2 == nil then modifier_mystery_stone_2 = class({}) end
function modifier_mystery_stone_2:IsHidden() return true end
function modifier_mystery_stone_2:IsPurgable() return false end
function modifier_mystery_stone_2:RemoveOnDeath() return false end
function modifier_mystery_stone_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_mystery_stone_2:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_mystery_stone_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING}
end
function modifier_mystery_stone_2:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end
function modifier_mystery_stone_2:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_mystery_stone_2:GetModifierCastRangeBonusStacking()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("cast_range") end
end

------------------
--MYSTERY STONE3--
------------------
LinkLuaModifier("modifier_mystery_stone_3", "items/mystery_stone.lua", LUA_MODIFIER_MOTION_NONE)
if item_mystery_stone_3 == nil then item_mystery_stone_3 = class({}) end
function item_mystery_stone_3:GetIntrinsicModifierName() return "modifier_mystery_stone_3" end

if modifier_mystery_stone_3 == nil then modifier_mystery_stone_3 = class({}) end
function modifier_mystery_stone_3:IsHidden() return true end
function modifier_mystery_stone_3:IsPurgable() return false end
function modifier_mystery_stone_3:RemoveOnDeath() return false end
function modifier_mystery_stone_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_mystery_stone_3:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_mystery_stone_3:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING}
end
function modifier_mystery_stone_3:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end
function modifier_mystery_stone_3:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana") end
end
function modifier_mystery_stone_3:GetModifierCastRangeBonusStacking()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("cast_range") end
end


-------------------------------
--MYSTERY SCEPTER OF DIVINITY--
-------------------------------
item_mystery_cyclone = class({})
LinkLuaModifier("modifier_mystery_cyclone", "items/mystery_stone.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mystery_cyclone_active", "items/mystery_stone.lua", LUA_MODIFIER_MOTION_NONE)
function item_mystery_cyclone:GetIntrinsicModifierName() return "modifier_mystery_cyclone" end
function item_mystery_cyclone:CastFilterResultTarget(target)
	if not IsServer() then return end
	local caster = self:GetCaster()
	if caster:GetTeamNumber() == target:GetTeamNumber() and caster ~= target then
		return UF_FAIL_FRIENDLY
	end
	if caster ~= target and target:IsMagicImmune() then
		return UF_FAIL_MAGIC_IMMUNE_ENEMY
	end
end
function item_mystery_cyclone:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local friends = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
	for i=1,#friends do
		friends[i]:Purge(false, true, false, false, false)
		friends[i]:AddNewModifier(caster, self, "modifier_mystery_cyclone_active", {duration = self:GetSpecialValueFor("cyclone_duration")})
	end
end
function item_mystery_cyclone:GetAOERadius() return self:GetSpecialValueFor("radius") end

modifier_mystery_cyclone = class({})
function modifier_mystery_cyclone:IsHidden() return true end
function modifier_mystery_cyclone:IsPurgable() return false end
function modifier_mystery_cyclone:IsDebuff() return false end
function modifier_mystery_cyclone:RemoveOnDeath() return false end
function modifier_mystery_cyclone:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_mystery_cyclone:DeclareFunctions()
	return { MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING, MODIFIER_PROPERTY_MANA_BONUS }
end
function modifier_mystery_cyclone:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_mystery_cyclone:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_mystery_cyclone:GetModifierMoveSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_movement_speed") end
function modifier_mystery_cyclone:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_mystery_cyclone:GetModifierCastRangeBonusStacking() return self:GetAbility():GetSpecialValueFor("cast_range") end

-------------------
--MYSTERY CYCLONE--
-------------------
modifier_mystery_cyclone_active = class({})
function modifier_mystery_cyclone_active:IsDebuff() return false end
function modifier_mystery_cyclone_active:IsHidden() return false end
function modifier_mystery_cyclone_active:IsPurgable() return true end
function modifier_mystery_cyclone_active:IsStunDebuff() return true end
function modifier_mystery_cyclone_active:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 11111
end
function modifier_mystery_cyclone_active:IsMotionController() return true end
function modifier_mystery_cyclone_active:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end
function modifier_mystery_cyclone_active:OnCreated()
	self:StartIntervalThink(FrameTime())
	EmitSoundOn("DOTA_Item.Cyclone.Activate", self:GetParent())
	if IsServer() then
		self:GetParent():StartGesture(ACT_DOTA_FLAIL)
		self.angle = self:GetParent():GetAngles()
		self.abs = self:GetParent():GetAbsOrigin()
		self.cyc_pos = self:GetParent():GetAbsOrigin()

		local cyclone = {"particles/items_fx/cyclone.vpcf",
		"particles/econ/events/fall_major_2016/cyclone_fm06.vpcf",
		"particles/econ/events/winter_major_2017/cyclone_wm07.vpcf",
		"particles/econ/events/spring_2021/cyclone_spring2021.vpcf",
		"particles/econ/events/ti5/cyclone_ti5.vpcf",
		"particles/econ/events/ti6/cyclone_ti6.vpcf",
		"particles/econ/events/ti7/cyclone_ti7.vpcf",
		"particles/econ/events/ti8/cyclone_ti8.vpcf",
		"particles/econ/events/ti9/cyclone_ti9.vpcf",
		"particles/econ/events/ti10/cyclone_ti10.vpcf",
		"particles/econ/items/windrunner/windranger_arcana/windranger_arcana_item_cyclone.vpcf",
		"particles/econ/items/windrunner/windranger_arcana/windranger_arcana_item_cyclone_v2.vpcf"}
		for y=1, #cyclone do
			if y == 1 then
			y = RandomInt(1,#cyclone)
			self.fx = ParticleManager:CreateParticle(cyclone[y], PATTACH_CUSTOMORIGIN, self:GetParent())
			ParticleManager:SetParticleControl(self.fx, 0, self.abs)
			end
		end
	end
end
function modifier_mystery_cyclone_active:OnIntervalThink()
	if IsServer() then
		if not self:CheckMotionControllers() then
			if self:IsNull() then return end
			self:Destroy()
			return
		end
		self:HorizontalMotion(self:GetParent(), FrameTime())
	end
end
function modifier_mystery_cyclone_active:HorizontalMotion(unit, time)
	if not IsServer() then return end
	self.angle = unit:GetAngles()
	self.abs = unit:GetAbsOrigin()
	self.cyc_pos = unit:GetAbsOrigin()
	local new_angle = RotateOrientation(self.angle, QAngle(0,20,0))
	self:GetParent():SetAngles(new_angle[1], new_angle[2], new_angle[3])
	if self:GetElapsedTime() <= 0.3 then
		self.cyc_pos.z = self.cyc_pos.z + 50
		self:GetParent():SetAbsOrigin(self.cyc_pos)
	elseif self:GetDuration() - self:GetElapsedTime() < 0.3 then
		self.step = self.step or (self.cyc_pos.z - self.abs.z) / ((self:GetDuration() - self:GetElapsedTime()) / FrameTime())
		self.cyc_pos.z = self.cyc_pos.z - self.step
		self:GetParent():SetAbsOrigin(self.cyc_pos)
	else
		local pos = self:GetRandomPosition2D(self:GetParent():GetAbsOrigin(),10)
		while ((pos - self.abs):Length2D() > 30) do
			pos = self:GetRandomPosition2D(self:GetParent():GetAbsOrigin(),10)
		end
		self:GetParent():SetAbsOrigin(pos)
	end
end
function modifier_mystery_cyclone_active:GetRandomPosition2D(pos, radius)
	local posNew = pos + Vector(1,0,0) * math.random(0-radius, radius)
	return RotatePosition(pos, QAngle(0,math.random(-360,360),0), posNew)
end
function modifier_mystery_cyclone_active:OnDestroy()
	StopSoundOn("DOTA_Item.Cyclone.Activate", self:GetParent())
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.fx, false)
	ParticleManager:ReleaseParticleIndex(self.fx)
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	self:GetParent():SetAbsOrigin(self.abs)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
	self:GetParent():SetAngles(self.angle[1], self.angle[2], self.angle[3])
end
function modifier_mystery_cyclone_active:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_MAGIC_IMMUNE] = true, [MODIFIER_STATE_DISARMED] = true}
end
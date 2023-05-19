-------------------------
-- ABYSSAL WATER BLADE --
-------------------------
item_abyssal_water_blade = item_abyssal_water_blade or class({})
LinkLuaModifier("modifier_abyssal_water_blade", "items/water_abyssal_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssal_water_blade_aura", "items/water_abyssal_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssal_water_blade_internal_cd", "items/water_abyssal_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssal_water_blade_bash", "items/water_abyssal_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssal_water_blade_up", "items/water_abyssal_blade", LUA_MODIFIER_MOTION_NONE)
function item_abyssal_water_blade:GetIntrinsicModifierName() return "modifier_abyssal_water_blade" end
function item_abyssal_water_blade:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local active_stun_duration = self:GetSpecialValueFor("active_stun_duration")
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		if target:TriggerSpellAbsorb(self) then
			return nil
		end
	end
	if self:GetCaster():HasModifier("modifier_slark_pounce") then
		self:GetCaster():FindModifierByName("modifier_slark_pounce"):Destroy()
	end
	target:EmitSound("DOTA_Item.AbyssalBlade.Activate")
	target:EmitSoundParams("Hero_MonkeyKing.Spring.Water", 1, 0.5, 0)
	local blink_start_particle = ParticleManager:CreateParticle("particles/econ/events/ti7/blink_dagger_start_ti7_lvl2.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(blink_start_particle)
	FindClearSpaceForUnit(self:GetCaster(), target:GetAbsOrigin() - self:GetCaster():GetForwardVector() * 56, false)
	local blink_end_particle = ParticleManager:CreateParticle("particles/econ/events/ti7/blink_dagger_end_ti7_lvl2.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(blink_end_particle)

	local particle_abyssal_fx = ParticleManager:CreateParticle("particles/items_fx/abyssal_blade.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle_abyssal_fx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_abyssal_fx)

	caster:AddNewModifier(caster, self, "modifier_abyssal_water_blade_internal_cd", {duration = active_stun_duration * (1 - target:GetStatusResistance())})
	target:AddNewModifier(caster, self, "modifier_abyssal_water_blade_bash", {duration = active_stun_duration * (1 - target:GetStatusResistance())})
end

modifier_abyssal_water_blade = modifier_abyssal_water_blade or class({})
function modifier_abyssal_water_blade:IsHidden() return true end
function modifier_abyssal_water_blade:IsPurgable() return false end
function modifier_abyssal_water_blade:RemoveOnDeath() return false end
function modifier_abyssal_water_blade:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_abyssal_water_blade:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_abyssal_water_blade:OnIntervalThink()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local has_skadi_bow_edible = self:GetCaster():HasModifier("modifier_skadi_bow_edible")
		local has_skadi_bow = self:GetCaster():HasModifier("modifier_skadi_bow")
		local has_water_blade = self:GetCaster():HasModifier("modifier_abyssal_water_blade")
		local has_water_up = self:GetCaster():HasModifier("modifier_abyssal_water_blade_up")
		if has_water_blade and (has_skadi_bow or has_skadi_bow_edible)  then
			if not has_water_up then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_abyssal_water_blade_up", {})
			end	
		else
			if has_water_up then
				self:GetCaster():RemoveModifierByName("modifier_abyssal_water_blade_up")
			end	
		end
	end
end
function modifier_abyssal_water_blade:OnDestroy()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_abyssal_water_blade_up") then
			self:GetCaster():RemoveModifierByName("modifier_abyssal_water_blade_up")
		end
	end
end

function modifier_abyssal_water_blade:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL}
end
function modifier_abyssal_water_blade:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_damage") end
end
function modifier_abyssal_water_blade:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health") end
end
function modifier_abyssal_water_blade:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_hp_regen") end
end
function modifier_abyssal_water_blade:GetModifierPhysical_ConstantBlock()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("block_damage")
	end
end
function modifier_abyssal_water_blade:OnAttack(keys)
	if self:GetAbility() and
	keys.attacker == self:GetParent() and
	keys.attacker:FindAllModifiersByName(self:GetName())[1] == self and
	keys.target and
	not keys.target:IsBuilding() and
	not keys.target:IsOther() and
	not keys.attacker:IsIllusion() and
	not keys.attacker:HasModifier("modifier_abyssal_water_blade_internal_cd") and
	not keys.attacker:HasModifier("modifier_monkey_king_fur_army_soldier") and
	not keys.attacker:HasModifier("modifier_monkey_king_fur_army_soldier_hidden") then --and
	--not keys.attacker:HasAbility("faceless_void_time_lock") and
	--not keys.attacker:HasAbility("spirit_breaker_greater_bash") and
	--not keys.attacker:HasAbility("slardar_bash") then
		--if self:GetParent():IsRangedAttacker() then
--[[ 			if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("bash_chance_ranged"), self) then
				self.bash_proc = true
			end ]]
		--else
			if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("bash_chance_melee"), self) then
				self.bash_proc = true
			end
		--end
	end
end
function modifier_abyssal_water_blade:OnAttackLanded(keys)
	if self:GetAbility() and keys.attacker == self:GetParent() and self.bash_proc then
		if keys.target == nil then return end
		local target = keys.target
		local owner = self:GetCaster()
		local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
		local internal_bash_cd = self:GetAbility():GetSpecialValueFor("internal_bash_cd")
		self.bash_proc = false
		local bash_fx = ParticleManager:CreateParticle("particles/custom/items/abyssal_water_blade/abyssal_bash.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.attacker)
		ParticleManager:SetParticleControlEnt(bash_fx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(bash_fx, 1, keys.attacker, PATTACH_ABSORIGIN, "attach_hitloc", keys.attacker:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(bash_fx, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
		ParticleManager:ReleaseParticleIndex(bash_fx)
		target:EmitSound("DOTA_Item.SkullBasher")
		target:EmitSoundParams("Hero_MonkeyKing.Spring.Water", 1, 0.5, 0)
		local bash_incdmg = 0
		if owner:HasModifier("modifier_abyssal_water_blade_up") then
			local up_bash_cd = self:GetAbility():GetSpecialValueFor("up_bash_cd")
			local up_stun_duration = self:GetAbility():GetSpecialValueFor("up_stun_duration")
			internal_bash_cd = self:GetAbility():GetSpecialValueFor("internal_bash_cd") * ((100 - up_bash_cd) / 100)
			stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration") * ((100 + up_stun_duration) / 100)
		end
		self:GetParent():AddNewModifier(owner, self:GetAbility(), "modifier_abyssal_water_blade_internal_cd", {duration = internal_bash_cd})
		target:AddNewModifier(owner, self:GetAbility(), "modifier_abyssal_water_blade_bash", {duration = stun_duration})
	end
end
function modifier_abyssal_water_blade:GetModifierProcAttack_BonusDamage_Physical()
	if self:GetAbility() and self.bash_proc then return self:GetAbility():GetSpecialValueFor("bash_damage") end
end
function modifier_abyssal_water_blade:IsAura() return true end
function modifier_abyssal_water_blade:IsAuraActiveOnDeath() return false end
function modifier_abyssal_water_blade:GetAuraRadius()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aura_radius") end
end
function modifier_abyssal_water_blade:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_abyssal_water_blade:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_abyssal_water_blade:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_abyssal_water_blade:GetAuraDuration() return FrameTime() end
function modifier_abyssal_water_blade:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_abyssal_water_blade:GetModifierAura() return "modifier_abyssal_water_blade_aura" end
------------------------------
-- ABYSSAL WATER BLADE AURA --
------------------------------
if modifier_abyssal_water_blade_aura == nil then modifier_abyssal_water_blade_aura = class({}) end
function modifier_abyssal_water_blade_aura:IsHidden() return false end
function modifier_abyssal_water_blade_aura:IsDebuff() return false end
function modifier_abyssal_water_blade_aura:IsPurgable() return false end
function modifier_abyssal_water_blade_aura:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_abyssal_water_blade_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end
function modifier_abyssal_water_blade_aura:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_aura") end
end
function modifier_abyssal_water_blade_aura:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_aura") end
end
function modifier_abyssal_water_blade_aura:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all_aura") end
end
function modifier_abyssal_water_blade_aura:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("damage_aura") end
end

------------------------------
-- ABYSSAL WATER BLADE BASH --
------------------------------
modifier_abyssal_water_blade_bash = modifier_abyssal_water_blade_bash or class({})
function modifier_abyssal_water_blade_bash:IsHidden() return false end
function modifier_abyssal_water_blade_bash:IsPurgeException() return true end
function modifier_abyssal_water_blade_bash:IsStunDebuff() return true end
function modifier_abyssal_water_blade_bash:CheckState() if self:GetParent().bAbsoluteNoCC then return end return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_abyssal_water_blade_bash:GetEffectName() return "particles/generic_gameplay/generic_stunned.vpcf" end
function modifier_abyssal_water_blade_bash:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_abyssal_water_blade_bash:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_abyssal_water_blade_bash:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE} end
function modifier_abyssal_water_blade_bash:GetModifierIncomingPhysicalDamage_Percentage(keys)
	if self:GetAbility() then
		local attacker = keys.attacker
		local target = keys.target
		if attacker:HasModifier("modifier_abyssal_water_blade_up") and not target:HasModifier("modifier_phys") then
			return self:GetAbility():GetSpecialValueFor("up_bash_incdmg")
		elseif attacker:HasModifier("modifier_abyssal_water_blade_up") and target:HasModifier("modifier_phys") then
			return self:GetAbility():GetSpecialValueFor("up_bash_incdmg") / 10
		else
			return 0
		end
	end
end
function modifier_abyssal_water_blade_bash:GetOverrideAnimation() return ACT_DOTA_DISABLED end

---------------------------------
-- ABYSSAL WATER BLADE BASH CD --
---------------------------------
modifier_abyssal_water_blade_internal_cd = modifier_abyssal_water_blade_internal_cd or class({})
function modifier_abyssal_water_blade_internal_cd:IsHidden() return true end
function modifier_abyssal_water_blade_internal_cd:IgnoreTenacity() return true end
function modifier_abyssal_water_blade_internal_cd:IsPurgable() return false end
function modifier_abyssal_water_blade_internal_cd:IsDebuff() return true end
function modifier_abyssal_water_blade_internal_cd:RemoveOnDeath() return false end

----------------------------
-- ABYSSAL WATER BLADE UP --
----------------------------
if modifier_abyssal_water_blade_up == nil then modifier_abyssal_water_blade_up = class({}) end
function modifier_abyssal_water_blade_up:IsHidden() return false end
function modifier_abyssal_water_blade_up:IsPurgable() return false end
function modifier_abyssal_water_blade_up:RemoveOnDeath() return false end
function modifier_abyssal_water_blade_up:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end

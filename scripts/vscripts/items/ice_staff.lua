item_ice_staff = class({})
LinkLuaModifier("modifier_seal_act", "items/seal_act.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ice_staff", "items/ice_staff", LUA_MODIFIER_MOTION_NONE)

function item_ice_staff:OnSpellStart()
	 if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local ice_staff_pfx = ParticleManager:CreateParticle( "particles/econ/items/crystal_maiden/ti9_immortal_staff/cm_ti9_staff_lvlup_globe.vpcf", PATTACH_ABSORIGIN, caster )
		ParticleManager:SetParticleControlEnt(ice_staff_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin()+Vector(0,0,100), false)
		ParticleManager:SetParticleControl(ice_staff_pfx, 5, Vector(1,1,1))
 	end
end
function item_ice_staff:OnChannelThink(interval)
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		if target then
			local dagon_pfx = ParticleManager:CreateParticle("particles/econ/events/ti7/dagon_ti7.vpcf",  PATTACH_POINT_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(dagon_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), false)
			ParticleManager:SetParticleControlEnt(dagon_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
			ParticleManager:SetParticleControl(dagon_pfx, 2, Vector(400))
			ApplyDamage({
				victim = target,
				attacker = caster,
				damage = self:GetSpecialValueFor("damage_per_stack")/3,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self
			})
		end
	end
end
function item_ice_staff:OnChannelFinish()
	if IsServer() then
		self:SetCurrentCharges(0)
		for i=9,28 do
			ParticleManager:SetParticleControl(self.part, i, Vector(0, 0, 0))
		end
	end
end
function item_ice_staff:GetChannelTime() return self:GetCurrentCharges()*0.1 end
function item_ice_staff:GetIntrinsicModifierName() return "modifier_ice_staff" end

------------------------------------------------------------------------------------------------------------------------
modifier_ice_staff = class({})
function modifier_ice_staff:IsHidden() return true end
function modifier_ice_staff:IsPurgable() return false end
function modifier_ice_staff:RemoveOnDeath() return false end
function modifier_ice_staff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ice_staff:OnCreated(kv)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local charges = ability:GetCurrentCharges()
		self.damage = ability:GetSpecialValueFor("damage")
		self.agi = ability:GetSpecialValueFor("agi")
		self.str = ability:GetSpecialValueFor("str")
		self.int = ability:GetSpecialValueFor("int")
		self.mana_regen_p = ability:GetSpecialValueFor("mana_regen_p")
		self.spell_damage = ability:GetSpecialValueFor("spell_damage")
		self.spell_range = ability:GetSpecialValueFor("spell_range")
		self.hp = ability:GetSpecialValueFor("hp")
		self.mana = ability:GetSpecialValueFor("mana")
		self.mana_cost_red = ability:GetSpecialValueFor("mana_cost_red")
		self.cast_time = ability:GetSpecialValueFor("cast_time")
		self.mp_regen_amp = ability:GetSpecialValueFor("mp_regen_amp")
		self.spell_lifesteal_amp = ability:GetSpecialValueFor("spell_lifesteal_amp")
		Timers:CreateTimer(FrameTime(), function()
			caster:AddNewModifier(caster, ability, "modifier_seal_act", {})
		end)
		particle = ParticleManager:CreateParticle("particles/legendary_items/ice_staff.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 1, Vector(20, 0, 0))
		if charges > 0 then
			for i = 1, charges do
				ParticleManager:SetParticleControl(particle, i+8, Vector(1, 0, 0))
			end
		end
	end
end
function modifier_ice_staff:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING, MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING, MODIFIER_PROPERTY_CASTTIME_PERCENTAGE, MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
	MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end
function modifier_ice_staff:GetModifierHealthBonus() return self.hp end
function modifier_ice_staff:GetModifierManaBonus() return self.mana end
function modifier_ice_staff:GetModifierPreAttack_BonusDamage() return self.damage end
function modifier_ice_staff:GetModifierBonusStats_Agility() return self.agi end
function modifier_ice_staff:GetModifierBonusStats_Strength() return self.str end
function modifier_ice_staff:GetModifierBonusStats_Intellect() return self.int end
function modifier_ice_staff:GetModifierPercentageManacostStacking() return self.mana_cost_red end
function modifier_ice_staff:GetModifierPercentageManaRegen() return self.mana_regen_p end
function modifier_ice_staff:GetModifierSpellAmplify_Percentage() return self.spell_damage end
function modifier_ice_staff:GetModifierCastRangeBonusStacking() return self.spell_range end
function modifier_ice_staff:GetModifierPercentageCasttime() return self.cast_time end
function modifier_ice_staff:GetModifierMPRegenAmplify_Percentage() return self.mp_regen_amp end
function modifier_ice_staff:GetModifierSpellLifestealRegenAmplify_Percentage() return self.spell_lifesteal_amp end
function modifier_ice_staff:OnAbilityExecuted(params)
	if IsServer() then
		if not self:GetCaster():IsIllusion() then
			if params.unit == self:GetCaster() then
				if not params.ability:IsItem() and not params.ability:IsToggle() then
					local ability = self:GetAbility()
					if ability:GetCurrentCharges() < 20 then
						local charges = ability:GetCurrentCharges()
						ability:SetCurrentCharges(charges+1)
						ParticleManager:SetParticleControl(particle, charges+9, Vector(1, 0, 0))
					end
				end
			end
		end
	end
	return 0
end
function modifier_ice_staff:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		caster:RemoveModifierByName("modifier_seal_act")
		ParticleManager:DestroyParticle(particle, true)
	end
end

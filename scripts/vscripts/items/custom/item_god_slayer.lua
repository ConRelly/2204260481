item_god_slayer = class({})
LinkLuaModifier("modifier_dragonborn", "items/custom/item_god_slayer", LUA_MODIFIER_MOTION_NONE)

function item_god_slayer:GetIntrinsicModifierName() return "modifier_dragonborn" end
function item_god_slayer:GetAOERadius() return self:GetSpecialValueFor("radius") end
function item_god_slayer:GetCooldown(nLevel)
	return self.BaseClass.GetCooldown(self, nLevel)-- - (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_atomic_samurai_4") or 0)
end

function item_god_slayer:GetManaCost (hTarget) return self.BaseClass.GetManaCost (self, hTarget) end
function item_god_slayer:GetBehavior() return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IMMEDIATE end

function item_god_slayer:OnSpellStart ()
	if IsServer() then
		local vcaster = self:GetCaster():GetAbsOrigin()
		local vcenter = Vector(0,0,0)
		local distance = (vcenter - vcaster):Length2D()
		if distance and distance > 5500 then return end
			

		local thinker = CreateModifierThinker (self:GetCaster(), self, "modifier_atomic_samurai_focused_atomic_slash_thinker_2", {duration = self:GetSpecialValueFor("duration")}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)

		AddFOWViewer(self:GetCaster():GetTeam (), self:GetCursorPosition(), self:GetSpecialValueFor("radius") * 0.75, 4, false)
		GridNav:DestroyTreesAroundPoint(self:GetCursorPosition(), 500, false)

		EmitSoundOn("Hero_EmberSpirit.SearingChains.Cast", thinker)
		EmitSoundOn("Hero_EmberSpirit.SearingChains.Burn", self:GetCaster())
	end
end

modifier_dragonborn = class({})
function modifier_dragonborn:IsDebuff() return false end
function modifier_dragonborn:IsHidden() return false end
function modifier_dragonborn:IsPurgable() return false end
function modifier_dragonborn:IsPurgeException() return false end
function modifier_dragonborn:RemoveOnDeath() return false end
--function modifier_dragonborn:AllowIllusionDuplicate() return true end
function modifier_dragonborn:GetTexture() return "god_slayer" end
function modifier_dragonborn:GetEffectName() return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_debuff.vpcf" end
function modifier_dragonborn:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_dragonborn:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	--[[if self:GetParent() ~= nil and self:GetParent():IsRealHero() then
		local nWingsParticleIndex = ParticleManager:CreateParticle("particles/avalon/wings/tian_gang_zhan_yi/tian_gang_zhan_yi_lv04_p.vpcf", PATTACH_CENTER_FOLLOW, self:GetParent())
		--ParticleManager:SetParticleControl(nWingsParticleIndex, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(nWingsParticleIndex, 5, self:GetParent(), PATTACH_CENTER_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(nWingsParticleIndex, false, false, -1, false, false)
	end]]	--was just testing some wings (but not necesary for this item), Can't center them on the back, they seems to be created for a custom attach.
end
function modifier_dragonborn:DeclareFunctions()
	return  {
			MODIFIER_EVENT_ON_DEATH,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_HEALTH_BONUS,
			MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
		}
end

function modifier_dragonborn:OnDeath(params)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local stacks = self:GetStackCount()
		local target = params.target
		if target == nil then target = params.unit end
		local chance = ability:GetSpecialValueFor("stack_chance")
		local chance_underdog = ability:GetSpecialValueFor("stack_underdog_chance")
		if caster:HasModifier("modifier_underdog") then
			chance = chance_underdog
		end
		local kill_count = 0
		if ability:IsItem() then
			kill_count = ability:GetCurrentCharges()
		end
		
		if params.attacker and not params.attacker:IsNull() and params.attacker:GetTeamNumber() == caster:GetTeamNumber() and caster:GetTeamNumber() ~= target:GetTeamNumber() then --and target:IsBoss()
			if RandomInt(0,100) < chance then
				self:IncrementStackCount()
				if ability:IsItem() then
					local iCharges = kill_count + 1
					ability:SetCurrentCharges(iCharges)
				end
			end
		end
		if params.attacker and params.attacker:GetTeamNumber() == caster:GetTeamNumber() and target:IsBoss() then
			self:IncrementStackCount()
			if ability:IsItem() then
				local iCharges = kill_count + 1
				ability:SetCurrentCharges(iCharges)
			end
		end
		return true
	end
end

function modifier_dragonborn:GetModifierPhysicalArmorBonus()
	local ability = self:GetAbility()
	local item_charges = ability:GetCurrentCharges()
	local stacks = self:GetStackCount() + item_charges
	local armor = ability:GetSpecialValueFor("armor")
	local stack_armor = ability:GetSpecialValueFor("stack_armor")
	local realarmor = stacks * stack_armor + armor
	return realarmor
end
function modifier_dragonborn:GetModifierBonusStats_Strength()
	local ability = self:GetAbility()
	local item_charges = ability:GetCurrentCharges()
	local stacks = self:GetStackCount() + item_charges
	local stack_str = ability:GetSpecialValueFor("stack_str")
	local realstr = stacks * stack_str
	return realstr
end
function modifier_dragonborn:GetModifierBonusStats_Agility()
	local ability = self:GetAbility()
	local item_charges = ability:GetCurrentCharges()
	local stacks = self:GetStackCount() + item_charges
	local stack_agi = ability:GetSpecialValueFor("stack_agi")
	local realagi = stacks * stack_agi
	return realagi
end
function modifier_dragonborn:GetModifierSpellAmplify_Percentage()
	local ability = self:GetAbility()
	local item_charges = ability:GetCurrentCharges()
	local stacks = self:GetStackCount() + item_charges
	local stack_spellamp = ability:GetSpecialValueFor("stack_spellamp")
	local realamp = stacks * stack_spellamp
	return realamp
end
function modifier_dragonborn:GetModifierHealthBonus()
	local ability = self:GetAbility()
	local item_charges = ability:GetCurrentCharges()
	local stacks = self:GetStackCount() + item_charges
	local extra_hp = ability:GetSpecialValueFor("stack_health")
	local realhp = stacks * extra_hp
	return realhp
end
function modifier_dragonborn:GetModifierTotalDamageOutgoing_Percentage(params)
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local target = params.target
	if target == nil then target = params.unit end
	if target == nil then return end
	if params.attacker ~= caster then return end
	if IsServer() then
		local damage = ability:GetSpecialValueFor("stuff")
		local damage_underdog = ability:GetSpecialValueFor("stuff_underdog")
		if caster:HasModifier("modifier_underdog") and (caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker") then
			damage = damage_underdog
		end
		if target:GetLevel() >= 89 then
			return damage
		else
			return 0
		end
	end
end

LinkLuaModifier ("modifier_atomic_samurai_focused_atomic_slash_2", "items/custom/item_god_slayer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_atomic_samurai_focused_atomic_slash_thinker_2", "items/custom/item_god_slayer", LUA_MODIFIER_MOTION_NONE)

modifier_atomic_samurai_focused_atomic_slash_thinker_2 = class ({})
function modifier_atomic_samurai_focused_atomic_slash_thinker_2:Next()
	if IsServer() then
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetCaster(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
		
		if #units == 0 or units == nil then
			if self:IsNull() then return end
			self:Destroy()
			return nil
		end

		if #units > 0 then
			return units[1]
		end
	end
	return nil
end

function modifier_atomic_samurai_focused_atomic_slash_thinker_2:OnCreated(event)
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self.caster = self:GetAbility():GetCaster()
		local mana = self.caster:GetMaxMana()
		local per_mana = self:GetAbility():GetSpecialValueFor("mana_per")
		local per_mana_others = self:GetAbility():GetSpecialValueFor("mana_per_others")
		local per_mana_underdog = self:GetAbility():GetSpecialValueFor("mana_per_underdog")
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
		self.damage2 = mana * (per_mana / 100)
		if self.caster:HasModifier("modifier_underdog") and (self.caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker") then
			self.damage2 = mana * (per_mana_underdog / 100)
		end
		self.damage = mana * (per_mana_others / 100)
		self.mod = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_atomic_samurai_focused_atomic_slash_2", {})
		self.pos = self:GetParent():GetAbsOrigin()
		self.old_pos = self:GetCaster():GetAbsOrigin()

		local nFXIndex = ParticleManager:CreateParticle ("particles/econ/items/monkey_king/arcana/fire/mk_arcana_fire_spring_cast_ringouterpnts.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(nFXIndex, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(nFXIndex, 4, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(nFXIndex, 5, self:GetParent():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(nFXIndex)

		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("attack_interval"))
	end
end

function modifier_atomic_samurai_focused_atomic_slash_thinker_2:OnDestroy()
	if IsServer() then
		if self.mod and not self.mod:IsNull() then
			self.mod:Destroy()
		end
		self.caster:SetAbsOrigin(self.old_pos)
		FindClearSpaceForUnit(self.caster, self.old_pos, true)
	end
end

function modifier_atomic_samurai_focused_atomic_slash_thinker_2:OnIntervalThink()
	if IsServer() then
		if not self.caster:HasModifier("modifier_atomic_samurai_focused_atomic_slash_2") then self:Destroy() return end
		local target = self:Next()
		if target == nil or target:IsNull() then self:Destroy() return end
		local pos = target:GetAbsOrigin()
		local pos2 = self.caster:GetAbsOrigin()
		if target:GetLevel() >= 89 then
			self.damage = self.damage2
		end
		self:CreateTrail(pos2, pos)

		self.caster:SetAbsOrigin(target:GetAbsOrigin())
		FindClearSpaceForUnit(self.caster, target:GetAbsOrigin(), false)
		
		if self.caster:IsDisarmed() then return end

		--EmitSoundOn("Hero_Juggernaut.ArcanaTrigger", target)
		EmitSoundOn("Hero_Juggernaut.ArcanaTrigger.Loadout_1", self.caster)

		ApplyDamage({
			victim = target,
			attacker = self.caster,
			ability = self:GetAbility(),
			damage = self.damage,
			damage_type = self:GetAbility():GetAbilityDamageType()
		})
		self.caster:PerformAttack(target, true, true, true, false, false, false, false)
	end
end

function modifier_atomic_samurai_focused_atomic_slash_thinker_2:CreateTrail(pos1, pos2)
	if IsServer() then
		local nFXIndex = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, self:GetParent());
		ParticleManager:SetParticleControl(nFXIndex, 0, pos1 + Vector(0, 0, 92));
		ParticleManager:SetParticleControl(nFXIndex, 1, pos2 + Vector(0, 0, 92));
		ParticleManager:ReleaseParticleIndex(nFXIndex);
	end
end


if modifier_atomic_samurai_focused_atomic_slash_2 == nil then modifier_atomic_samurai_focused_atomic_slash_2 = class({}) end
function modifier_atomic_samurai_focused_atomic_slash_2:IsHidden() return true end
function modifier_atomic_samurai_focused_atomic_slash_2:IsPurgable() return false end
function modifier_atomic_samurai_focused_atomic_slash_2:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_atomic_samurai_focused_atomic_slash_2:CheckState () return { [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_OUT_OF_GAME] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true } end

function modifier_atomic_samurai_focused_atomic_slash_2:OnCreated()
	if IsServer() then
		self:GetCaster():AddNoDraw()
	end
end
function modifier_atomic_samurai_focused_atomic_slash_2:OnDestroy()
	if IsServer() then
		self:GetCaster():RemoveNoDraw()
	end
end
function modifier_atomic_samurai_focused_atomic_slash_2:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ORDER}
end
function modifier_atomic_samurai_focused_atomic_slash_2:OnOrder(params)
	if params.unit ~= self:GetParent() then return end
	if params.order_type ~= DOTA_UNIT_ORDER_HOLD_POSITION then
		return
	end
	self:Destroy()
	return 0
end

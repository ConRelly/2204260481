LinkLuaModifier("modifier_polymorpher", "items/sheepstick", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polymorpher_unique", "items/sheepstick", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_polymorpher_debuff", "items/sheepstick", LUA_MODIFIER_MOTION_NONE)

-----------------
-- Polymorpher --			WIP
-----------------
item_polymorpher = class({})
function item_polymorpher:GetIntrinsicModifierName() return "modifier_polymorpher" end
function item_polymorpher:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local hex_duration = self:GetSpecialValueFor("hex_duration")

--		if target:IsMagicImmune() then return end
		if target:GetTeamNumber() ~= caster:GetTeamNumber() then if target:TriggerSpellAbsorb(self) then return end end

		Polymorph(caster, self, target, hex_duration)
	end
end

modifier_polymorpher = class({})
function modifier_polymorpher:IsHidden() return true end
function modifier_polymorpher:IsPurgable() return false end
function modifier_polymorpher:RemoveOnDeath() return false end
function modifier_polymorpher:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_polymorpher:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_polymorpher:OnIntervalThink()
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_polymorpher_unique") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_polymorpher_unique", {})
		end
	end
end
function modifier_polymorpher:OnDestroy()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_polymorpher_unique") then
			self:GetCaster():RemoveModifierByName("modifier_polymorpher_unique")
		end
	end
end
function modifier_polymorpher:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
end
function modifier_polymorpher:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_polymorpher:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_polymorpher:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_polymorpher:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end

------------------------
-- Polymorpher unique --
------------------------
modifier_polymorpher_unique = class({})
function modifier_polymorpher_unique:IsHidden() return true end
function modifier_polymorpher_unique:IsPurgable() return false end
function modifier_polymorpher_unique:RemoveOnDeath() return false end
function modifier_polymorpher_unique:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_DEATH}
end
function modifier_polymorpher_unique:OnTakeDamage(keys)
	if not IsServer() then return end
	local parent = self:GetParent()
	local attacker = keys.attacker
	local unit = keys.unit
	local chance = self:GetAbility():GetSpecialValueFor("chance")
	local hex_duration = self:GetAbility():GetSpecialValueFor("hex_duration")

	if parent:IsIllusion() then return end
	if parent ~= unit then return end
	if parent == attacker then return end
	if parent:GetTeamNumber() == attacker:GetTeamNumber() then return end
--	if attacker:IsMagicImmune() then return end
	if not self:GetAbility():IsCooldownReady() or not self:GetAbility():IsOwnersManaEnough() then return end

	if RollPseudoRandomPercentage(chance, 0, parent) then
		Polymorph(parent, self:GetAbility(), attacker, hex_duration)
		self:GetAbility():UseResources(true, true, false, true)
	end
end
function modifier_polymorpher_unique:OnDeath(keys)
	if not IsServer() then return end
	local parent = self:GetParent()
	local attacker = keys.attacker
	local unit = keys.unit
	local hex_duration = self:GetAbility():GetSpecialValueFor("hex_duration")

	if unit:IsIllusion() then return end
	if not unit:IsHero() then return end
	if unit:GetTeamNumber() ~= parent:GetTeamNumber() then return end
--	if parent ~= unit then return end
--	if not self:GetAbility():IsCooldownReady() or not self:GetAbility():IsOwnersManaEnough() then return end

	if parent:HasAbility("nevermore_custom_requiem") then
		local radius = parent:CustomValue("nevermore_custom_requiem", "travel_distance")
		local targets = FindUnitsInRadius(parent:GetTeamNumber(), parent:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)

		for _, target in pairs(targets) do
			if target then
				Polymorph(parent, self:GetAbility(), target, hex_duration)
			end
		end
	else
		if parent == attacker then return end
--		if attacker:IsMagicImmune() then return end
		Polymorph(parent, self:GetAbility(), attacker, hex_duration)
	end
	--self:GetAbility():UseResources(true, false, true)
end

------------------------
-- Polymorpher debuff --
------------------------
modifier_polymorpher_debuff = class({})
function modifier_polymorpher_debuff:IsHidden() return false end
function modifier_polymorpher_debuff:IsDebuff() return true end
function modifier_polymorpher_debuff:IsPurgable() return true end
function modifier_polymorpher_debuff:OnCreated()
	if not IsServer() then return end
	self.sheep_pfx = ParticleManager:CreateParticle("particles/items_fx/item_sheepstick.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(self.sheep_pfx, 0, self:GetParent():GetAbsOrigin())
end
function modifier_polymorpher_debuff:OnRefresh()
	if not IsServer() then return end
	self:OnCreated()
end
function modifier_polymorpher_debuff:OnDestroy()
	if not IsServer() then return end
	if self.sheep_pfx then
		ParticleManager:DestroyParticle(self.sheep_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.sheep_pfx)
	end
end
function modifier_polymorpher_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
	}
end
function modifier_polymorpher_debuff:GetModifierMoveSpeedOverride() return self:GetAbility():GetSpecialValueFor("enemy_move_speed") end
function modifier_polymorpher_debuff:GetModifierModelChange() return "models/props_gameplay/pig.vmdl" end
function modifier_polymorpher_debuff:GetVisualZDelta() return 0 end
function modifier_polymorpher_debuff:CheckState()
	return {
		[MODIFIER_STATE_HEXED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}
end

function Polymorph(caster, ability, target, duration)
	target:EmitSoundParams("DOTA_Item.Sheepstick.Activate", 1, 1, 0)
	target:EmitSoundParams("Item.PigPole.Target", 1, 1.5, 0)

	if target:IsIllusion() then target:ForceKill(true) return end

	target:AddNewModifier(caster, ability, "modifier_polymorpher_debuff", {duration = duration})
	target:AddNewModifier(caster, ability, "modifier_nevermore_requiem_fear", {duration = duration})
end

LinkLuaModifier("modifier_lions_dagon_passive", "items/item_dagon.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lions_dagon_icon", "items/item_dagon.lua", LUA_MODIFIER_MOTION_NONE)

item_mjz_dagon_v2 = item_mjz_dagon_v2 or class({})
function item_mjz_dagon_v2:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end
function item_mjz_dagon_v2:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("splash_radius_scepter")
	end
	return 0
end
function item_mjz_dagon_v2:GetAbilityTextureName()
	if IsClient() then
		if self:GetCaster():HasModifier("modifier_lions_dagon_icon") then
			icon = "custom/lions_dagon_lion"
		else
			icon = "custom/lions_dagon"
		end
		return icon
	end
end
function item_mjz_dagon_v2:GetIntrinsicModifierName() return "modifier_lions_dagon_passive" end

function item_mjz_dagon_v2:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local units = {target}

	local base_damage = self:GetSpecialValueFor("damage")
	local damage_instances_count = 2
	local damage_delay = self:GetSpecialValueFor("damage_delay")
	local damage_per_use = self:GetSpecialValueFor("damage_per_use")
	local splash_radius_scepter = self:GetSpecialValueFor("splash_radius_scepter")

	local damage_stats = 0
	if caster:IsRealHero() then
		damage_stats = caster:GetIntellect(true) * 10
	end

	local use_count = 0
	if self:IsItem() then
		use_count = self:GetCurrentCharges()
	end

	local damage = base_damage + damage_per_use * use_count
	if caster:HasModifier("modifier_super_scepter") then
		damage = damage + damage_stats
	end

	if caster:HasScepter() then
		units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, splash_radius_scepter, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
	end

	caster:EmitSound("DOTA_Item.Dagon.Activate")

	if self:IsItem() then
		self:SetCurrentCharges(use_count + 1)
	end

	for _, unit in pairs(units) do
		if unit:IsIllusion() then unit:Kill(self, caster) end

		local dagon_pfx = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf", PATTACH_RENDERORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(dagon_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), false)
		ParticleManager:SetParticleControlEnt(dagon_pfx, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), false)
		ParticleManager:SetParticleControl(dagon_pfx, 2, Vector(800, 0, 0))
		ParticleManager:SetParticleControl(dagon_pfx, 3, Vector(0.3, 0, 0))
		ParticleManager:ReleaseParticleIndex(dagon_pfx)

		unit:EmitSoundParams("DOTA_Item.Dagon5.Target", 1, 1 / #units, 0)

		if not unit:IsMagicImmune() and not unit:TriggerSpellAbsorb(self) then
			if unit:IsAlive() then
				for i = 1, damage_instances_count do
					Timers:CreateTimer(damage_delay * damage_instances_count, function()
						ApplyDamage({
							attacker = caster,
							victim = unit,
							ability = self,
							damage = damage / damage_instances_count,
							damage_type = DAMAGE_TYPE_MAGICAL,
						})
					end)
				end
			end
		end
	end
	if caster:GetUnitName() == "npc_dota_hero_lion" then
		if caster:HasAbility("mjz_finger_of_death") and caster:FindAbilityByName("mjz_finger_of_death"):IsTrained() then
			Timers:CreateTimer(damage_delay * (damage_instances_count + 1), function()
				caster:SetCursorCastTarget(target)
				caster:FindAbilityByName("mjz_finger_of_death"):OnSpellStart_dagon()
			end)
		end
	end
end

modifier_lions_dagon_icon = class({})
function modifier_lions_dagon_icon:IsHidden() return true end
function modifier_lions_dagon_icon:IsDebuff() return false end
function modifier_lions_dagon_icon:IsPurgable() return false end
function modifier_lions_dagon_icon:RemoveOnDeath() return false end

modifier_lions_dagon_passive = class({})
function modifier_lions_dagon_passive:IsHidden() return true end
function modifier_lions_dagon_passive:IsDebuff() return false end
function modifier_lions_dagon_passive:IsPurgable() return false end
function modifier_lions_dagon_passive:RemoveOnDeath() return false end
function modifier_lions_dagon_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_lions_dagon_passive:OnCreated()
	if not IsServer() then return end
	if self:GetParent():GetUnitName() == "npc_dota_hero_lion" then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_lions_dagon_icon", {})
	end
end
function modifier_lions_dagon_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_lions_dagon_passive:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_lions_dagon_passive:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_lions_dagon_passive:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats") + self:GetAbility():GetSpecialValueFor("bonus_intellect")
end


LinkLuaModifier("modifier_lions_cursed_item_slot", "items/item_dagon.lua", LUA_MODIFIER_MOTION_NONE)
item_lions_cursed_item_slot = class({})
function item_lions_cursed_item_slot:GetIntrinsicModifierName() return "modifier_lions_cursed_item_slot" end

modifier_lions_cursed_item_slot = class({})
function modifier_lions_cursed_item_slot:IsHidden() return true end
function modifier_lions_cursed_item_slot:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_lions_cursed_item_slot:OnCreated()
	if not IsServer() then return end
	self:GetAbility():SetSellable(false)
	self:GetAbility():SetPurchaseTime(0)
end
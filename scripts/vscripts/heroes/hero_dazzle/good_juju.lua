LinkLuaModifier("modifier_dzzl_good_juju", "heroes/hero_dazzle/good_juju", LUA_MODIFIER_MOTION_NONE)

if dzzl_good_juju == nil then dzzl_good_juju = class({}) end

dzzl_good_juju.nonrefresh_items = {
	item_maiar_pendant = true,
	item_custom_fusion_rune = true,
	item_conduit = true,
	item_custom_refresher = true,
	item_plain_ring = true,
	item_helm_of_the_undying = true, 
	item_echo_wand = true,
	item_custom_ex_machina = true,
	item_minotaur_horn = true,
	item_bloodthorn = true,
	item_cursed_bloodthorn = true,
	item_resurection_pendant = true,
	item_random_get_ability_spell = true,
	item_random_get_ability = true,
	item_inf_aegis = true,
	item_video_file = true,
}

function dzzl_good_juju:GetIntrinsicModifierName() return "modifier_dzzl_good_juju" end

function dzzl_good_juju:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function dzzl_good_juju:GetCooldown(lvl)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_cooldown")
	end
    return 0
end
function dzzl_good_juju:GetManaCost(lvl)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_mana_cost")
	end
	return 0
end
function dzzl_good_juju:OnSpellStart()
	if IsServer() then
		local target = self:GetCursorTarget()
		for i = 0, 8 do
			local item = target:GetItemInSlot(i)
			if item then
				if not self.nonrefresh_items[item:GetAbilityName()] then
					if item:IsRefreshable() then
						local currentCD = item:GetCooldownTimeRemaining()
						if currentCD > 0 then
							if currentCD > 100 then
								item:EndCooldown()
								item:StartCooldown(currentCD / 2)
							else
								item:EndCooldown()
							end
						end
					end
				end
			end
		end

        target:EmitSound("DOTA_Item.Refresher.Activate")
        local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_lucky_charm.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControlEnt(fx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(fx)
	end
end

------------------------
-- Good Juju Modifier --
------------------------
modifier_dzzl_good_juju = modifier_dzzl_good_juju or class({})

function modifier_dzzl_good_juju:IsHidden() return true end
function modifier_dzzl_good_juju:IsDebuff() return false end
function modifier_dzzl_good_juju:IsPurgable() return false end
function modifier_dzzl_good_juju:IsPurgeException() return false end
function modifier_dzzl_good_juju:RemoveOnDeath() return false end

function modifier_dzzl_good_juju:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}
end

function modifier_dzzl_good_juju:GetModifierPercentageCooldown(params)
	if self:GetCaster():HasScepter() and params.ability and params.ability:IsItem() and self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("item_cooldown_reduction")
	end
end
function modifier_dzzl_good_juju:OnAbilityExecuted(params)
	if IsServer() then
		local caster = self:GetCaster()
		local used_ability = params.ability
		local cdr_per_cast = self:GetAbility():GetSpecialValueFor("cooldown_reduction") + talent_value(caster, "special_bonus_unique_dazzle_custom_juju")
		if cdr_per_cast == 0 then return end
		if caster:IsIllusion() then return end

		if params.unit == caster and not used_ability:IsItem() and not used_ability:IsToggle() and used_ability:GetCooldown(used_ability:GetLevel() - 1) > 0 then
			for i = 0, caster:GetAbilityCount() - 1 do
				local abil = caster:GetAbilityByIndex(i)
				if abil then
					local abil_cd = abil:GetCooldownTimeRemaining()
					if abil_cd > 0 then
						if abil_cd - cdr_per_cast > 0 then
							abil:EndCooldown()
							abil:StartCooldown(abil_cd - cdr_per_cast)
						else
							abil:EndCooldown()
						end
					end
				end
			end
		end
	end
end

-- require("lib/my")
local THIS_LUA = "items/item_mjz_great_holy_locket.lua"
LinkLuaModifier('modifier_item_mjz_great_holy_locket_passive', THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_item_mjz_great_holy_locket_heal_increase', THIS_LUA, LUA_MODIFIER_MOTION_NONE)


item_mjz_great_holy_locket = class({})

function item_mjz_great_holy_locket:GetIntrinsicModifierName()
	return "modifier_item_mjz_great_holy_locket_passive"
end

if IsServer() then 
	function item_mjz_great_holy_locket:OnCreated()
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_item_mjz_great_holy_locket_heal_increase", {duration = -1})
	end
	function item_mjz_great_holy_locket:OnRefresh()
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_item_mjz_great_holy_locket_heal_increase", {duration = -1})	
	end
	function item_mjz_great_holy_locket:OnDestroy()
		local caster = self:GetParent()
		caster:RemoveModifierByName("modifier_item_mjz_great_holy_locket_heal_increase")
	end
	function item_mjz_great_holy_locket:OnRemoved()
		local caster = self:GetParent()
		caster:RemoveModifierByName("modifier_item_mjz_great_holy_locket_heal_increase")
	end

end

function item_mjz_great_holy_locket:OnSpellStart()
	if IsServer() then
		local abiltiy = self
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local charges = self:GetCurrentCharges()
		local restore_per_charge = self:GetSpecialValueFor("restore_per_charge")

		local flheal = charges * restore_per_charge
		local flmana = flheal

		if target ~= caster then 
			flheal = flheal * 1.25

			--Green and blue effect numbers ingame for ally cast
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, target, flmana, caster:GetPlayerOwner())
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, flheal, caster:GetPlayerOwner())
		end 

		target:GiveMana(flmana)
		target:Heal(flheal, caster)

		self:SetCurrentCharges(0)

		--Sound and Graphics
		local sound_target = "DOTA_Item.MagicWand.Activate"
		EmitSoundOn( sound_target, target )	

		local particle_cast = "particles/econ/items/huskar/huskar_ti8/huskar_ti8_shoulder_heal.vpcf"
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
		local effect_delay = 0.16 + 0.04 * charges

		Timers:CreateTimer(effect_delay, function()
			ParticleManager:DestroyParticle(effect_cast, false)
			ParticleManager:ReleaseParticleIndex( effect_cast )
		end)
	end
end


------------------------------------------------------------
modifier_item_mjz_great_holy_locket_passive = modifier_item_mjz_great_holy_locket_passive or class({})

function modifier_item_mjz_great_holy_locket_passive:IsPurgable() return false end
function modifier_item_mjz_great_holy_locket_passive:IsHidden() return true end
function modifier_item_mjz_great_holy_locket_passive:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE	--MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_item_mjz_great_holy_locket_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		-- MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		-- MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,

	}
	return funcs
end

function modifier_item_mjz_great_holy_locket_passive:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_mjz_great_holy_locket_passive:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_mjz_great_holy_locket_passive:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

-- function modifier_item_mjz_great_holy_locket_passive:GetModifierStatusResistanceStacking()
-- 	return self.status_increase
-- end
-- function modifier_item_mjz_great_holy_locket_passive:GetModifierMagicalResistanceBonus()
-- 	return self.bonus_mr
-- end

function modifier_item_mjz_great_holy_locket_passive:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("health_regen")
end
function modifier_item_mjz_great_holy_locket_passive:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end
function modifier_item_mjz_great_holy_locket_passive:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

if IsServer() then
	function modifier_item_mjz_great_holy_locket_passive:OnCreated()
		local caster = self:GetCaster()
		self:StartIntervalThink(3.0)
	end

	function modifier_item_mjz_great_holy_locket_passive:OnIntervalThink()
		local abiltiy = self:GetAbility()
		local caster = self:GetCaster()
		local charges = abiltiy:GetCurrentCharges()
		local max_charges = abiltiy:GetSpecialValueFor("max_charges")

		if charges < max_charges then
			abiltiy:SetCurrentCharges(charges + 1)
		else
			--print("max_charges")
		end
	end
end

---------------------------------------------------------------------------------

modifier_item_mjz_great_holy_locket_heal_increase = class({})
local modifier_heal_increase = modifier_item_mjz_great_holy_locket_heal_increase
function modifier_heal_increase:IsPurgable() return false end
function modifier_heal_increase:IsHidden() return true end
-- function modifier_heal_increase:GetAttributes()
--     return MODIFIER_ATTRIBUTE_PERMANENT
-- end

function modifier_heal_increase:DeclareFunctions() 
	return {
		-- MODIFIER_PROPERTY_TOOLTIP,	-- OnTooltip
		-- MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE,
		-- MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		-- MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
	}
end

function modifier_heal_increase:OnTooltip()
    return self:GetStackCount()
end

function modifier_heal_increase:GetModifierLifestealRegenAmplify_Percentage()
	--return self.regenlifesteal_increase
	return 0
end

function modifier_heal_increase:GetModifierHPRegenAmplify_Percentage()
	return self.regenlifesteal_increase
end

function modifier_heal_increase:GetModifierHealAmplify_PercentageSource()
	--Amplifies heals your unit provides as a source
	return self.heal_increase
end

function modifier_heal_increase:GetModifierHealAmplify_PercentageTarget()
	-- Amplifies heals your unit receives as a target from healing spells
	--return self.heal_increase
	return 0
end

function modifier_heal_increase:OnCreated()
	-- self.regenlifesteal_increase = self:GetAbility():GetSpecialValueFor( "regen_and_lifesteal_increase" )
	self.heal_increase = self:GetAbility():GetSpecialValueFor( "heal_increase" ) 
end
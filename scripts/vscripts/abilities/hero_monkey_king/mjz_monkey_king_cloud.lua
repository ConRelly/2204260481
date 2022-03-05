LinkLuaModifier("modifier_mjz_monkey_king_cloud", "abilities/hero_monkey_king/mjz_monkey_king_cloud", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_monkey_king_arcana", "abilities/hero_monkey_king/mjz_monkey_king_cloud", LUA_MODIFIER_MOTION_NONE)

mjz_monkey_king_cloud = class({})
local ability_class = mjz_monkey_king_cloud

function mjz_monkey_king_cloud:Spawn()
	if IsServer() then
		self:SetLevel(1)
	end
end
function ability_class:OnToggle()
	if not IsServer() then return end
	local caster = self:GetCaster()
		
	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_mjz_monkey_king_cloud", {})
		caster:AddNewModifier(caster, self, "modifier_mjz_monkey_king_arcana", {})
	else
		caster:RemoveModifierByName( "modifier_mjz_monkey_king_cloud")
		caster:RemoveModifierByName( "modifier_mjz_monkey_king_arcana")
	end
end

---------------------------------------------------------------------------------------

modifier_mjz_monkey_king_cloud = class({})
local modifier_class = modifier_mjz_monkey_king_cloud
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end
function modifier_class:GetEffectName()
	return "particles/custom/abilities/heroes/mjz_monkey_king_cloud/monkey_arcana_cloud.vpcf"
end
function modifier_class:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_class:CheckState()
	local unslowable = nil
	if self:GetParent():HasModifier("item_aghanims_shard") then
		unslowable = true
	end
	return {
		[MODIFIER_STATE_UNSLOWABLE] = unslowable,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
end

function modifier_class:DeclareFunctions()
	if self:GetParent():HasModifier("item_aghanims_shard") then
		return {
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		}
	end
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_class:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor('bonus_move_speed') end
function modifier_class:GetActivityTranslationModifiers() return "cloudrun" end
function modifier_class:GetModifierIgnoreMovespeedLimit() return 1 end

if IsServer() then
	function modifier_class:OnCreated()
		self.interval = 0.1
		self:StartIntervalThink(self.interval)
	end

	function modifier_class:OnIntervalThink()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local mana_pct = ability:GetSpecialValueFor("mana_pct")
		local mana = parent:GetMaxMana() * mana_pct / 100 * self.interval
		
		if ability:GetToggleState() then
			if parent:GetMana() > mana then
				parent:SpendMana(mana, ability)
			else
				ability:ToggleAbility()
			end
		end
	end
end

---------------------------------------------------------------------------------------

modifier_mjz_monkey_king_arcana = class({})
function modifier_mjz_monkey_king_arcana:IsHidden() return true end
function modifier_mjz_monkey_king_arcana:IsPurgable() return false end
function modifier_mjz_monkey_king_arcana:DeclareFunctions() return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS} end
function modifier_mjz_monkey_king_arcana:GetActivityTranslationModifiers() return "arcana" end

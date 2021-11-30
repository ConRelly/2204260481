----------------------
-- Arcane Supremacy --
----------------------

LinkLuaModifier("modifier_arcane_supremacy", "heroes/hero_rubick/arcane_supremacy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arcane_supremacy_buff", "heroes/hero_rubick/arcane_supremacy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_super_scepter", "items/item_aghanim_synth", LUA_MODIFIER_MOTION_NONE)

arcane_supremacy = class({})
modifier_arcane_supremacy = class({})
function arcane_supremacy:GetIntrinsicModifierName() return "modifier_arcane_supremacy" end
function arcane_supremacy:CastFilterResultTarget(target)
	if self:GetCaster() == target or not target:IsRealHero() then
		return UF_FAIL_CUSTOM
	end
	local nResult = UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
	if nResult ~= UF_SUCCESS then
		return nResult
	end
	return UF_SUCCESS
end
function arcane_supremacy:GetCustomCastErrorTarget(target)
	if self:GetCaster() == target then return "#dota_hud_error_cant_cast_on_self" end
	if not target:IsRealHero() then return "#dota_hud_error_cant_cast_on_considered_hero" end
	return ""
end
function arcane_supremacy:GetBehavior()
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") or self:GetCaster():HasScepter() or self:GetCaster():HasModifier("modifier_super_scepter") then
		upgrade = true
	else
		upgrade = false
	end
	if upgrade then
		return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end
function arcane_supremacy:OnSpellStart()
	 if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_4)
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
		if caster == target then self:StartCooldown(10) return end
		if not target:IsRealHero() then self:StartCooldown(10) return end
		local duration = self:GetSpecialValueFor("buff_duration")
		local base_cd = self:GetSpecialValueFor("base_cd")
		local cd_shard = 0
		local cd_scepter = 0
		local cd_super = 0

		if caster:HasModifier("modifier_item_aghanims_shard") then
			cd_shard = self:GetSpecialValueFor("bonus_cd_shard")
		end
		if caster:HasScepter() then
			cd_scepter = self:GetSpecialValueFor("bonus_cd_scepter")
		end
		if caster:HasModifier("modifier_super_scepter") then
			cd_super = self:GetSpecialValueFor("bonus_cd_super")
			cd_scepter = 0
		end
		cd = base_cd + cd_shard + cd_scepter + cd_super
		self:StartCooldown(cd)
		target:AddNewModifier(caster, self, "modifier_arcane_supremacy_buff", {duration = duration})
 	end
end

-------------------------------
-- Arcane Supremacy Modifier --
-------------------------------
function modifier_arcane_supremacy:IsHidden() return true end
function modifier_arcane_supremacy:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_arcane_supremacy:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local modifier = "modifier_item_imba_ultimate_scepter_synth_stats"
		if caster:HasModifier(modifier) and caster:FindModifierByName(modifier):GetStackCount() >= 2 then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_super_scepter", {})
		else
			if caster:HasModifier("modifier_super_scepter") then
				caster:RemoveModifierByName("modifier_super_scepter")
			end
		end
	end
end
function modifier_arcane_supremacy:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_arcane_supremacy:GetModifierCastRangeBonusStacking()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_cast_range") end
end
function modifier_arcane_supremacy:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("spell_amp") end
end

---------------------------
-- Arcane Supremacy Buff --
---------------------------
modifier_arcane_supremacy_buff = modifier_arcane_supremacy_buff or class({})
function modifier_arcane_supremacy_buff:IsDebuff() return false end
function modifier_arcane_supremacy_buff:IsHidden() return false end
function modifier_arcane_supremacy_buff:IsPurgable() return false end
function modifier_arcane_supremacy_buff:RemoveOnDeath() return false end
--function modifier_arcane_supremacy_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_arcane_supremacy_buff:OnCreated()
	 if IsServer() then
		local caster = self:GetCaster()
		local paretn = self:GetParent()
		local duration = self:GetAbility():GetSpecialValueFor("buff_duration")
		if caster:HasModifier("modifier_item_aghanims_shard") then
			if paretn:HasModifier("modifier_item_aghanims_shard") then
				local ShardModifier = paretn:FindModifierByName("modifier_item_aghanims_shard")
				if ShardModifier:GetDuration() > 0 and ShardModifier:GetElapsedTime() < duration then
					paretn:AddNewModifier(caster, nil, "modifier_item_aghanims_shard", {duration = duration})
				end
			else
				paretn:AddNewModifier(caster, nil, "modifier_item_aghanims_shard", {duration = duration})
			end
		end
		if caster:HasScepter() then
			if paretn:HasScepter() then
				local ScepterModifier = paretn:FindModifierByName("modifier_item_ultimate_scepter_consumed")
				if ScepterModifier:GetDuration() > 0 and ScepterModifier:GetElapsedTime() < duration then
					paretn:AddNewModifier(caster, nil, "modifier_item_ultimate_scepter_consumed", {duration = duration})
				end
			else
				paretn:AddNewModifier(caster, nil, "modifier_item_ultimate_scepter_consumed", {duration = duration})
			end
		end
		if caster:HasModifier("modifier_super_scepter") then
			if paretn:HasModifier("modifier_super_scepter") then
				local SSModifier = paretn:FindModifierByName("modifier_super_scepter")
				if SSModifier:GetDuration() > 0 and SSModifier:GetElapsedTime() < duration then
					paretn:AddNewModifier(caster, nil, "modifier_super_scepter", {duration = duration})
				end
			else
				paretn:AddNewModifier(caster, nil, "modifier_super_scepter", {duration = duration})
			end
		end
	end
end
function modifier_arcane_supremacy_buff:OnRefresh()
	self:OnCreated()
end

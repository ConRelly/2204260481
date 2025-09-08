LinkLuaModifier("modifier_grow_strong", "heroes/hero_chaos_knight/grow_strong.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_grow_strong_bonus_str", "heroes/hero_chaos_knight/grow_strong.lua", LUA_MODIFIER_MOTION_NONE)

grow_strong = class({})
function grow_strong:Spawn()
	if not IsServer() then return end
	if self:GetCaster():GetUnitName() == "npc_dota_hero_chaos_knight" then
		self:SetLevel(1)
	end
end
function grow_strong:GetIntrinsicModifierName() return "modifier_grow_strong" end


modifier_grow_strong = class({})
function modifier_grow_strong:IsHidden() return false end
function modifier_grow_strong:IsPurgable() return false end
function modifier_grow_strong:RemoveOnDeath() return false end
function modifier_grow_strong:GetEffectName()
    return "particles/econ/courier/courier_greevil_naked/courier_greevil_naked_ambient_3.vpcf"
end
function modifier_grow_strong:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

-- helper to apply retro stacks once (no instant talent strength)
function modifier_grow_strong:TryApplyRetro()
	if self.retro_done then return end
	if not IsServer() then return end
	local ability = self:GetAbility()
	if not ability or ability:IsNull() then return end
	if not ability:IsTrained() then return end

	local caster = self:GetCaster()
	local retro_interval = 15
	local game_time = math.floor(GameRules:GetGameTime())
	local retro_stacks = math.floor(game_time / retro_interval)

	if retro_stacks > 0 then
		-- add the retro stacks to the modifier stack count only (no immediate talent strength)
		self:SetStackCount(self:GetStackCount() + retro_stacks)
	end

	-- mark retro as applied so it never runs again
	self.retro_done = true

	-- start regular interval thinking (continue normal growth)
	if ability and not ability:IsNull() then
		self:StartIntervalThink(ability:GetSpecialValueFor("grow_interval"))
	end
end

function modifier_grow_strong:OnCreated()
	if not IsServer() then return end
	-- try to apply retro stacks if ability is already trained; otherwise OnRefresh will handle it
	self:TryApplyRetro()
end

function modifier_grow_strong:OnRefresh()
	if not IsServer() then return end
	-- if ability was trained after modifier existed, TryApplyRetro will apply retro stacks once
	self:TryApplyRetro()
end

function modifier_grow_strong:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if ability and not ability:IsNull() and ability:IsTrained() then
		-- normal per-interval stack gain
		self:SetStackCount(self:GetStackCount() + 1)

		-- if the caster has the talent, apply the per-interval strength increment (same logic you had)
		if caster:HasTalent("special_bonus_unique_ck_grow_strong") then
			local modifynr = ability:GetSpecialValueFor("grow_str") * talent_value(caster, "special_bonus_unique_ck_grow_strong") * 0.5
			caster:ModifyStrength(modifynr)

			-- keep or create the bonus-strength modifier and increment its stack count
			if caster:HasModifier("modifier_grow_strong_bonus_str") then
				local modifier = caster:FindModifierByName("modifier_grow_strong_bonus_str")
				if modifier and not modifier:IsNull() then
					modifier:SetStackCount(modifier:GetStackCount() + modifynr)
				end
			else
				caster:AddNewModifier(caster, ability, "modifier_grow_strong_bonus_str", {})
				local modifier = caster:FindModifierByName("modifier_grow_strong_bonus_str")
				if modifier and not modifier:IsNull() then
					modifier:SetStackCount(modifynr)
				end
			end
		end

		-- continue normal interval thinking
		self:StartIntervalThink(ability:GetSpecialValueFor("grow_interval"))
	end
end

function modifier_grow_strong:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MODEL_SCALE, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end
function modifier_grow_strong:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("grow_str") end 
end
function modifier_grow_strong:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("grow_armor") + self:GetAbility():GetSpecialValueFor("grow_armor") * talent_value(self:GetCaster(), "special_bonus_unique_ck_grow_strong")) end	
end

function modifier_grow_strong:GetModifierModelScale()
	if self:GetAbility() then
		local scale = self:GetStackCount() * self:GetAbility():GetSpecialValueFor("grow_model")
		local max_scale = self:GetAbility():GetSpecialValueFor("max_scale")
		if scale > max_scale then scale = max_scale end
		return scale
	end	
end
function modifier_grow_strong:GetModifierPreAttack_CriticalStrike(keys)
	if IsServer() then
		if keys.attacker == self:GetCaster() then
			if self:GetAbility() then
				if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("crit_chance"), self:GetAbility()) then
					keys.target:AddNewModifier(keys.attacker, self:GetAbility(), "modifier_stunned", {Duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
					EmitSoundOn("DOTA_Item.MKB.Minibash", keys.target)
					EmitSoundOn("Hero_ChaosKnight.ChaosStrike", keys.target)
					return self:GetAbility():GetSpecialValueFor("crit_per_str") * self:GetStackCount() + 100
				end
			end
		end
	end
end


--base stats traker
if modifier_grow_strong_bonus_str == nil then modifier_grow_strong_bonus_str = class({}) end

function modifier_grow_strong_bonus_str:IsHidden() return true end
function modifier_grow_strong_bonus_str:IsPurgable() return false end
function modifier_grow_strong_bonus_str:IsDebuff() return false end
function modifier_grow_strong_bonus_str:RemoveOnDeath() return false end
function modifier_grow_strong_bonus_str:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_grow_strong_bonus_str:OnTooltip()
	return self:GetStackCount()
end

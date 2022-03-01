LinkLuaModifier("modifier_roshan_inherit_buff_datadriven_crit_buff", "abilities/custom/roshan_inherit_buff.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_roshan_inherit_buff_datadriven", "abilities/custom/roshan_inherit_buff.lua", LUA_MODIFIER_MOTION_NONE)


function StackCountIncrease(keys)
    local caster = keys.caster
    local ability = keys.ability
    local StackModifier = "modifier_roshan_inherit_buff_datadriven"
	local currentStacks = caster:GetModifierStackCount(StackModifier, ability)
	if not caster:HasAbility("roshan_inherit_buff_datadriven") then
		caster:RemoveModifierByName("modifier_roshan_inherit_buff_datadriven_collector")
		caster:RemoveModifierByName("modifier_roshan_inherit_buff_datadriven")
    end
	if currentStacks == 0 then
		caster:AddNewModifier(caster, ability, StackModifier, { Duration = -1 })
		caster:SetModifierStackCount(StackModifier, ability, (currentStacks + 1))
	else
		 caster:SetModifierStackCount(StackModifier, ability, (currentStacks + 1))
	end
end

--Adjusts the strength provided by the modifiers on ability upgrade
function GrowHeapAdjust(keys)
    local caster = keys.caster
    local ability = keys.ability
    local fleshHeapModifier = "modifier_roshan_inherit_buff_datadriven"
    local fleshHeapStackModifier = "modifier_roshan_inherit_buff_datadriven_collector"
    local currentStacks = caster:GetModifierStackCount(fleshHeapStackModifier, ability)

    -- Remove the old modifiers
    for i = 1, currentStacks do
        caster:RemoveModifierByName(fleshHeapModifier)
    end

    -- Add the same amount of new ones
    for i = 1, currentStacks do
        ability:ApplyDataDrivenModifier(caster, caster, fleshHeapModifier, {})
    end
end

--------------------------------------------------------------------------------
modifier_roshan_inherit_buff_datadriven = class({})
function modifier_roshan_inherit_buff_datadriven:IsPurgable() return false end
function modifier_roshan_inherit_buff_datadriven:RemoveOnDeath() return false end
function modifier_roshan_inherit_buff_datadriven:AllowIllusionDuplicate() return true end
function modifier_roshan_inherit_buff_datadriven:OnCreated(kv)
	if IsServer() then
--		self.crit_multiplier = self:GetAbility():GetSpecialValueFor("crit_per_str")*self:GetParent():GetStrength() + 100
--		self.strenght = self:GetAbility():GetSpecialValueFor("grow_str")
--		self.armor = self:GetAbility():GetSpecialValueFor("grow_armor")
		self.model_scale = self:GetAbility():GetSpecialValueFor("grow_model")
	end
end
function modifier_roshan_inherit_buff_datadriven:GetEffectName()
    return "particles/econ/courier/courier_greevil_naked/courier_greevil_naked_ambient_3.vpcf"
end
function modifier_roshan_inherit_buff_datadriven:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
function modifier_roshan_inherit_buff_datadriven:OnDestroy()
	if IsServer() then
		if self.nFXIndex ~= nil then ParticleManager:DestroyParticle(self.nFXIndex,true) end
	end
end
function modifier_roshan_inherit_buff_datadriven:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MODEL_SCALE, MODIFIER_EVENT_ON_ATTACK_START}
end
function modifier_roshan_inherit_buff_datadriven:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then
		local stacks = self:GetStackCount()
		if stacks > 10 then
			return stacks * self:GetAbility():GetSpecialValueFor("grow_armor")
		else
			local time = GameRules:GetGameTime() / 10
			return time * self:GetAbility():GetSpecialValueFor("grow_armor") 
		end
	end	
end
function modifier_roshan_inherit_buff_datadriven:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		local stacks = self:GetStackCount()
		if stacks > 10 then
			return stacks * self:GetAbility():GetSpecialValueFor("grow_str")
		else
			local time = GameRules:GetGameTime() / 10
			return time * self:GetAbility():GetSpecialValueFor("grow_str") 
		end
	end
end
function modifier_roshan_inherit_buff_datadriven:GetModifierModelScale()
	if self:GetAbility() then
		local scale = self:GetStackCount()*self.model_scale
		local max_scale = self:GetAbility():GetSpecialValueFor("max_scale")
		if scale > max_scale then scale = max_scale end
		return scale
	end	
end
function modifier_roshan_inherit_buff_datadriven:OnAttackStart(data)
	if IsServer() then
		if data.attacker == self:GetParent() then
			if self:GetAbility() then
				if RollPseudoRandom(self:GetAbility():GetSpecialValueFor("crit_chance"), self:GetAbility()) then
					data.attacker:AddNewModifier(data.attacker, self:GetAbility(), "modifier_roshan_inherit_buff_datadriven_crit_buff", {})
				end
			end	
		end
	end
end

--------------------------------------------------------------------------------
modifier_roshan_inherit_buff_datadriven_crit_buff = class({})
function modifier_roshan_inherit_buff_datadriven_crit_buff:IsHidden() return true end
function modifier_roshan_inherit_buff_datadriven_crit_buff:RemoveOnDeath() return true end
function modifier_roshan_inherit_buff_datadriven_crit_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_roshan_inherit_buff_datadriven_crit_buff:GetModifierPreAttack_CriticalStrike()
	return self:GetAbility():GetSpecialValueFor("crit_per_str")*self:GetParent():GetStrength() + 100
end
function modifier_roshan_inherit_buff_datadriven_crit_buff:OnAttackLanded(data)
	if IsServer() then
		if data.attacker == self:GetParent() then
			if not self:IsNull() then
				self:Destroy()
			end	
			data.target:AddNewModifier(data.attacker, self:GetAbility(), "modifier_stunned", {Duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
			EmitSoundOn("DOTA_Item.MKB.Minibash",data.target)
		end
	end
end

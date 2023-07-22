LinkLuaModifier("modifier_aghanims_blessing", "items/item_aghanim_synth.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghanims_scepter_synth", "items/item_aghanim_synth.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_super_scepter", "items/item_aghanim_synth.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tome_of_super_scepter", "items/item_aghanim_synth.lua", LUA_MODIFIER_MOTION_NONE)

function AghanimsSynthCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier_stats = keys.modifier_stats
	local PlayerID = caster:GetPlayerID()
	if not _G.super_courier[PlayerID] then
		if not caster:IsRealHero() then return nil end
	end
	if caster:HasModifier("modifier_arc_warden_tempest_double") then return nil end
	if not caster:HasModifier("modifier_aghanims_scepter_synth") then
		caster:AddNewModifier(caster, ability, "modifier_aghanims_scepter_synth", {})
	end
	if caster:HasModifier(modifier_stats) then
		local modifier = caster:FindModifierByName(modifier_stats)
		modifier:SetStackCount(modifier:GetStackCount() + 1)
	else
		ability:ApplyDataDrivenModifier(caster, caster, modifier_stats, {})
		local modifier = caster:FindModifierByName(modifier_stats)
		modifier:SetStackCount(1)
	end
	if caster:HasModifier(modifier_stats) and caster:FindModifierByName(modifier_stats):GetStackCount() > 2 then
		caster:AddNewModifier(caster, ability, "modifier_super_scepter", {})
	else
		if caster:HasModifier("modifier_super_scepter") then
			caster:RemoveModifierByName("modifier_super_scepter")
		end
	end
	caster:EmitSound("Hero_Alchemist.Scepter.Cast")
	ability:SpendCharge()
end


-- Aghanim"s Blessing --
item_ultimate_scepter_synth = class({})
function item_ultimate_scepter_synth:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()

	local str = self:GetSpecialValueFor("bonus_all_stats")
	local agi = self:GetSpecialValueFor("bonus_all_stats")
	local int = self:GetSpecialValueFor("bonus_all_stats")
	local health = self:GetSpecialValueFor("bonus_health")
	local mana = self:GetSpecialValueFor("bonus_mana")

	if caster:HasModifier("modifier_arc_warden_tempest_double") then return end
	if caster:HasModifier("modifier_aghanims_scepter_synth") then return end
	caster:AddNewModifier(caster, self, "modifier_aghanims_scepter_synth", {})
	caster:EmitSound("Hero_Alchemist.Scepter.Cast")
	caster:RemoveItem(self)
end
function item_ultimate_scepter_synth:GetIntrinsicModifierName() return "modifier_aghanims_blessing" end

modifier_aghanims_blessing = class({})
function modifier_aghanims_blessing:IsHidden() return true end
function modifier_aghanims_blessing:IsPurgable() return false end
function modifier_aghanims_blessing:OnCreated()
	if not IsServer() then return end
	if self:GetAbility() then
		self:GetAbility():OnSpellStart()
	end
--	if not IsServer() then return end
--	self:StartIntervalThink(FrameTime())
end
--[[
function modifier_aghanims_blessing:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_item_ultimate_scepter_consumed") then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_item_ultimate_scepter_consumed", {})
	end
end
function modifier_aghanims_blessing:OnDesrtoy()
	if self:GetParent():HasModifier("modifier_item_ultimate_scepter_consumed") then
		self:GetParent():RemoveModifierByName("modifier_item_ultimate_scepter_consumed")
	end
end
function modifier_aghanims_blessing:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,		
    }
end
function modifier_aghanims_blessing:GetModifierBonusStats_Strength() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end end
function modifier_aghanims_blessing:GetModifierBonusStats_Agility() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end end
function modifier_aghanims_blessing:GetModifierBonusStats_Intellect() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end end
function modifier_aghanims_blessing:GetModifierHealthBonus() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health") end end
function modifier_aghanims_blessing:GetModifierManaBonus() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_mana") end end
]]

-- Aghanim's Scepter --
modifier_aghanims_scepter_synth = class({})
function modifier_aghanims_scepter_synth:IsHidden() return true end
function modifier_aghanims_scepter_synth:IsPurgable() return false end
function modifier_aghanims_scepter_synth:RemoveOnDeath() return false end
function modifier_aghanims_scepter_synth:AllowIllusionDuplicate() return true end
function modifier_aghanims_scepter_synth:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.5)
end
function modifier_aghanims_scepter_synth:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_item_ultimate_scepter_consumed") then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_item_ultimate_scepter_consumed", {})
	end
end

-- Super Scepter --
modifier_super_scepter = modifier_super_scepter or class({})
function modifier_super_scepter:IsDebuff() return false end
function modifier_super_scepter:IsHidden() return true end
function modifier_super_scepter:IsPurgable() return false end
function modifier_super_scepter:RemoveOnDeath() return false end
function modifier_super_scepter:AllowIllusionDuplicate() return true end
function modifier_super_scepter:GetEffectName() return "particles/custom/items/super_scepter/super_scepter_amb.vpcf" end
function modifier_super_scepter:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_super_scepter:CheckState()
	local parent = self:GetParent()
	if parent and parent:GetUnitName() == "npc_dota_hero_muerta" then
		return {[MODIFIER_STATE_CANNOT_MISS] = true}
	end	
end
function modifier_super_scepter:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		
    }
end
function modifier_super_scepter:GetModifierBaseAttackTimeConstant()
	local parent = self:GetParent()
	if parent and parent:GetUnitName() == "npc_dota_hero_muerta" then
	    return 1.1
    end   
end	

function modifier_super_scepter:OnDestroy()
	if IsServer() then
		local modifier_stats = "modifier_item_imba_ultimate_scepter_synth_stats"
		if self:GetCaster():HasModifier(modifier_stats) and self:GetCaster():FindModifierByName(modifier_stats):GetStackCount() > 2 then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_super_scepter", {})
		else
			if self:GetCaster():HasModifier("modifier_super_scepter") then
				self:GetCaster():RemoveModifierByName("modifier_super_scepter")
			end
		end
	end
end


function SuperScepterTome(keys)
	if not keys.caster:HasModifier("modifier_super_scepter") then
		keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_super_scepter", {duration = keys.duration})
		keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_tome_of_super_scepter", {duration = keys.duration})
		keys.ability:SpendCharge()
	end
end

modifier_tome_of_super_scepter = class({})
function modifier_tome_of_super_scepter:IsHidden() return false end
function modifier_tome_of_super_scepter:IsPurgable() return false end
function modifier_tome_of_super_scepter:RemoveOnDeath() return false end
function modifier_tome_of_super_scepter:AllowIllusionDuplicate() return false end
function modifier_tome_of_super_scepter:GetTexture() return "imba_ultimate_scepter_synth" end

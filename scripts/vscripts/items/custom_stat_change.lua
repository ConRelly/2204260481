item_custom_stat_change = class({})

function item_custom_stat_change:OnSpellStart()
	if not IsServer() then return end
    local caster = self:GetCaster()
	local temp = 0
	local fx2 = nil
	if self:GetAbilityName() == "item_custom_stat_change_str" then
		fx2 = ParticleManager:CreateParticle("particles/econ/events/ti6/hero_levelup_ti6_flash_hit_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		temp = 0
	elseif self:GetAbilityName() == "item_custom_stat_change_agi" then
		fx2 = ParticleManager:CreateParticle("particles/econ/events/ti8/hero_levelup_ti8_flash_hit_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		temp = 1
	elseif self:GetAbilityName() == "item_custom_stat_change_int" then
		fx2 = ParticleManager:CreateParticle("particles/econ/events/ti7/hero_levelup_ti7_flash_hit_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		temp = 2
	end

	if fx2 ~= nil then
		ParticleManager:SetParticleControlEnt(fx2, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	end
	ParticleManager:ReleaseParticleIndex(fx2)
	local modifier = caster:AddNewModifier(caster, self, "modifier_item_stat_change", {})
	modifier:SetStackCount(temp)
	modifier:OnRefresh()
	
	self:SpendCharge()
end

item_custom_stat_change_str = class(item_custom_stat_change)
item_custom_stat_change_agi = class(item_custom_stat_change)
item_custom_stat_change_int = class(item_custom_stat_change)

LinkLuaModifier("modifier_item_stat_change", "items/custom_stat_change.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_stat_change = class({})
function modifier_item_stat_change:IsHidden() return true end
function modifier_item_stat_change:IsPurgable() return false end
function modifier_item_stat_change:RemoveOnDeath() return false end
function modifier_item_stat_change:OnCreated()
	if not IsServer() then return end
	self:SetStackCount(self:GetStackCount())
	self:GetParent():SetPrimaryAttribute(self:GetStackCount())
end
function modifier_item_stat_change:OnRefresh()
	self:OnCreated()
end

local THIS_LUA = "abilities/hero_io/mjz_io_overcharge.lua"

local MODIFIER_BUFF_NAME = 'modifier_mjz_io_overcharge_buff'
local ABILITY_TETHER_NAME = "wisp_tether"
local ABILITY_TETHER_BREAK_NAME = "wisp_tether_break"
local MODIFIER_TETHER_NAME = "modifier_wisp_tether"
local MODIFIER_TETHER_HASTE_NAME = "modifier_wisp_tether_haste"
local MODIFIER_CD = "modifier_mjz_io_overcharge_cd"
LinkLuaModifier('modifier_mjz_io_overcharge', THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_mjz_io_overcharge_caster', THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_mjz_io_overcharge_buff', THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_io_overcharge_cd", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
---------------------------------------------------------------------------------------

mjz_io_overcharge = class({})
local ability_class = mjz_io_overcharge

function ability_class:GetIntrinsicModifierName() return 'modifier_mjz_io_overcharge' end

function ability_class:OnToggle()
	if IsServer() then
		local caster = self:GetCaster()
		if self:GetToggleState() then
			caster:AddNewModifier(caster, self, 'modifier_mjz_io_overcharge_caster', {})
			caster:AddNewModifier(caster, self, MODIFIER_BUFF_NAME, {})
			EmitSoundOn("Hero_Wisp.Overcharge", caster)
		else
			caster:RemoveModifierByName('modifier_mjz_io_overcharge_caster')
			caster:RemoveModifierByName(MODIFIER_BUFF_NAME)
			StopSoundOn("Hero_Wisp.Overcharge", caster)
		end
	end
end
---------------------------------------------------------------------------------------

modifier_mjz_io_overcharge = class({})
local modifier_class = modifier_mjz_io_overcharge

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then

	function modifier_class:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		}
		return funcs
	end

	function modifier_class:OnAbilityFullyCast(params)
        if params.unit ~= self:GetParent() then return nil end
		if params.ability and params.ability:IsItem() then return nil end

        local ability = self:GetAbility()
		local ability_exe = params.ability
		local target_exe = params.target
		
		if ability_exe:GetName() == ABILITY_TETHER_NAME then
			self.target_exe = target_exe
		elseif ability_exe:GetName() == ABILITY_TETHER_BREAK_NAME then
		end
	end
	
	function modifier_class:OnCreated(table)
		self:StartIntervalThink(0.5)
	end

	function modifier_class:OnIntervalThink()
		local target_exe = self.target_exe
		
		if target_exe then
			if target_exe:HasModifier(MODIFIER_TETHER_HASTE_NAME) then
				if self:GetAbility():GetToggleState() then
					self:_AddBuff(target_exe)
				else
					self:_RemoveBuff(target_exe)
				end
			else
				self:_RemoveBuff(target_exe)
				self.target_exe = nil
			end
		end
	end

	function modifier_class:_AddBuff(target)
		local caster = self:GetCaster()
		if not target:HasModifier(MODIFIER_BUFF_NAME) then
			target:AddNewModifier(caster, self:GetAbility(), MODIFIER_BUFF_NAME, {})
		end
	end

	function modifier_class:_RemoveBuff(target)
		if target:HasModifier(MODIFIER_BUFF_NAME) then
			target:RemoveModifierByName(MODIFIER_BUFF_NAME)
		end
	end

end

---------------------------------------------------------------------------------------

modifier_mjz_io_overcharge_caster = class({})
local modifier_caster = modifier_mjz_io_overcharge_caster

function modifier_caster:IsHidden() return true end
function modifier_caster:IsPurgable() return false end


if IsServer() then
	function modifier_caster:OnCreated(table)
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("drain_interval"))
	end

	function modifier_caster:OnIntervalThink()
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local drain_interval = ability:GetSpecialValueFor('drain_interval')
		local drain_pct = ability:GetSpecialValueFor('drain_pct') / 100

		local deltaDrainPct	= drain_interval * drain_pct
		local health = parent:GetHealth()
		local damage = health * deltaDrainPct

		caster:ModifyHealth(health - damage, ability, true, 0)
--[[
		ApplyDamage( {
			victim = parent,
			attacker = caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS,
			ability = ability,
		} )
]]
		-- caster:SpendMana( caster:GetMana() * deltaDrainPct, ability )
	end
end

---------------------------------------------------------------------------------------

modifier_mjz_io_overcharge_buff = class({})
local modifier_buff = modifier_mjz_io_overcharge_buff

function modifier_buff:IsHidden() return false end
function modifier_buff:IsPurgable() return false end

function modifier_buff:GetEffectName()
	return "particles/units/heroes/hero_wisp/wisp_overcharge.vpcf"
end
function modifier_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_buff:GetPriority()
	return MODIFIER_PRIORITY_ULTRA + 10000
end
function modifier_buff:OnCreated()
	if not IsServer() then return end
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local buff_duration = self:GetAbility():GetSpecialValueFor("buff_duration")
	if parent ~= caster then
		if not parent:HasModifier(MODIFIER_CD) then
			cd_modifier = parent:AddNewModifier(caster, self:GetAbility(), MODIFIER_CD, {})
			cd_modifier:SetStackCount(buff_duration)
		end
		self:StartIntervalThink(1)
	end
end
function modifier_buff:OnIntervalThink()
	if not IsServer() then return end
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local buff_duration = self:GetAbility():GetSpecialValueFor("buff_duration")
	local cd_duration = self:GetAbility():GetSpecialValueFor("buff_cd")
	if parent ~= caster then
		local cd_modifier = parent:FindModifierByName(MODIFIER_CD)
		if cd_modifier:GetStackCount() > 0 then
			cd_modifier:SetStackCount(cd_modifier:GetStackCount() - 1)
		end
		if cd_modifier:GetStackCount() == 0 then
			cd_modifier = parent:AddNewModifier(caster, self:GetAbility(), MODIFIER_CD, {duration = cd_duration})
			self:StartIntervalThink(-1)
			Timers:CreateTimer(cd_duration + FrameTime(), function()
				if not parent:HasModifier(MODIFIER_CD) and parent:HasModifier("modifier_mjz_io_overcharge_buff") then
					cd_modifier = parent:AddNewModifier(caster, self:GetAbility(), MODIFIER_CD, {})
					cd_modifier:SetStackCount(buff_duration)
					self:StartIntervalThink(1)
				end
			end)
		end
	end
end
function modifier_buff:CheckState()
	local state = {[MODIFIER_STATE_DISARMED] = false, [MODIFIER_STATE_CANNOT_MISS] = true,[MODIFIER_STATE_STUNNED] = false}
	
	if self:GetParent():HasModifier(MODIFIER_CD) then
		if self:GetParent():FindModifierByName(MODIFIER_CD):GetStackCount() == 0 and self:GetParent() ~= self:GetCaster() then
			state = {[MODIFIER_STATE_DISARMED] = false}
		end
	end
	return state
end

function modifier_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
	}
end

function modifier_buff:GetModifierAttackSpeedBonus_Constant( )
	return self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
end

function modifier_buff:GetModifierIgnoreMovespeedLimit()
	if self:GetParent() == self:GetCaster() then return 1 else return 0 end
end

---------------------------------------------------------------------------------------

modifier_mjz_io_overcharge_cd = class({})
local modifier_buff_cd = modifier_mjz_io_overcharge_cd

function modifier_buff_cd:IsHidden() return (self:GetStackCount() > 0) end
function modifier_buff_cd:IsPurgable() return false end
function modifier_buff_cd:RemoveOnDeath() return false end
function modifier_buff_cd:IsDebuff() return true end
function modifier_buff_cd:GetTexture() return "mjz_io_overcharge" end

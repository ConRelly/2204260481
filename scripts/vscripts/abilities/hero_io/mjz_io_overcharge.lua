
local THIS_LUA = "abilities/hero_io/mjz_io_overcharge.lua"
local MODIFIER_BUFF_NAME = 'modifier_mjz_io_overcharge_buff'

local ABILITY_TETHER_NAME = "wisp_tether"
local ABILITY_TETHER_BREAK_NAME = "wisp_tether_break"
local MODIFIER_TETHER_NAME = "modifier_wisp_tether"
local MODIFIER_TETHER_HASTE_NAME = "modifier_wisp_tether_haste"
local MODIFIER_CD = "modifier_mjz_io_overcharge_cd"
LinkLuaModifier('modifier_mjz_io_overcharge', THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_mjz_io_overcharge_caster', THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_BUFF_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_CD, THIS_LUA, LUA_MODIFIER_MOTION_NONE)
---------------------------------------------------------------------------------------

mjz_io_overcharge = class({})
local ability_class = mjz_io_overcharge

function ability_class:GetIntrinsicModifierName()
	return 'modifier_mjz_io_overcharge'
end

function ability_class:OnToggle()
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()
		if ability:GetToggleState() then
			caster:AddNewModifier(caster, ability, 'modifier_mjz_io_overcharge_caster', {})
			caster:AddNewModifier(caster, ability, MODIFIER_BUFF_NAME, {})
			--caster:AddNewModifier(caster, ability, MODIFIER_CD, {duration = 9.5})
			EmitSoundOn("Hero_Wisp.Overcharge", caster)
		else
			caster:RemoveModifierByName('modifier_mjz_io_overcharge_caster')
			caster:RemoveModifierByName(MODIFIER_BUFF_NAME)
			StopSoundOn("Hero_Wisp.Overcharge", caster)
		end
	end
end
function ability_class:OnIntervalThink()
	if not IsServer() then return end
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	

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
		
        local caster = self:GetCaster()
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
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local target_exe = self.target_exe
		
		if target_exe then
			if target_exe:HasModifier(MODIFIER_TETHER_HASTE_NAME) then
				if ability:GetToggleState() then
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
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		if not target:HasModifier(MODIFIER_BUFF_NAME) then
			target:AddNewModifier(caster, ability, MODIFIER_BUFF_NAME, {})
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
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local drain_interval = ability:GetSpecialValueFor('drain_interval')
		local drain_pct = ability:GetSpecialValueFor('drain_pct')

		self:StartIntervalThink(drain_interval)
	end

	function modifier_caster:OnIntervalThink()
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local drain_interval = ability:GetSpecialValueFor('drain_interval')
		local drain_pct = ability:GetSpecialValueFor('drain_pct')

		local deltaDrainPct	= drain_interval * drain_pct
		local damage = parent:GetHealth() * deltaDrainPct

		ApplyDamage( {
			victim = parent,
			attacker = caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS,
			ability = ability,
		} )

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
function modifier_buff:GetPriority()
	return MODIFIER_PRIORITY_ULTRA + 10000
end

function modifier_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_buff:OnCreated()
	if not IsServer() then return end
	self.cd = 0
	self:StartIntervalThink(10)
end	
function modifier_buff:OnIntervalThink()
	if not IsServer() then return end
	local parent = self:GetParent()
	local caster = self:GetCaster()		
	if self.cd == 1 then 
		self.cd = 0
		print(self.cd .." cd")	
	else
		self.cd = 1
		if parent ~= caster then
			parent:AddNewModifier(caster, ability, MODIFIER_CD, {duration = 10})
		end	
		print(self.cd .." cd")		
	end	
end	

function modifier_buff:CheckState()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local state = {
		[MODIFIER_STATE_DISARMED] = false,
		[MODIFIER_STATE_CANNOT_MISS] = true,
		[MODIFIER_STATE_STUNNED] = false,

	}
	if self.cd == 1 and parent ~= caster then
		state = {
			[MODIFIER_STATE_DISARMED] = false,
			[MODIFIER_STATE_STUNNED] = true,
		}	
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

function modifier_buff:GetModifierIgnoreMovespeedLimit( )
	return 1
end

---------------------------------------------------------------------------------------

modifier_mjz_io_overcharge_cd = class({})
local modifier_buff_cd = modifier_mjz_io_overcharge_cd

function modifier_buff_cd:IsHidden() return false end
function modifier_buff_cd:IsPurgable() return false end
function modifier_buff_cd:IsDebuff() return true end

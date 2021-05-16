LinkLuaModifier( "modifier_mjz_slark_pounce_charges", "abilities/hero_slark/mjz_slark_pounce.lua" ,LUA_MODIFIER_MOTION_NONE )

mjz_slark_pounce = class({})
local ability_class = mjz_slark_pounce

-- function ability_class:GetIntrinsicModifierName()
--     if self:GetCaster():HasScepter() then
--         return "modifier_mjz_slark_pounce_charges"
--     end
-- end

-- function ability_class:GetAOERadius()
-- 	return self:GetSpecialValueFor("heap_range")
-- end

function ability_class:OnSpellStart()
    if not IsServer() then return end
    local ability = self
    local caster = self:GetCaster()
    local m_charges = "modifier_mjz_slark_pounce_charges"
    if caster:HasScepter()  then
        local abilityCharges = caster:FindModifierByName(m_charges)
        if abilityCharges == nil then
            abilityCharges = caster:AddNewModifier(caster, ability, m_charges, {})
        end
        if abilityCharges then
            abilityCharges:DecrementStackCount()
        end
    end
end

---------------------------------------------------------------------------

modifier_mjz_slark_pounce_charges = modifier_mjz_slark_pounce_charges or class({})

function modifier_mjz_slark_pounce_charges:IsDebuff() return false end
function modifier_mjz_slark_pounce_charges:IsHidden() return false end
function modifier_mjz_slark_pounce_charges:IsPurgable() return false end
function modifier_mjz_slark_pounce_charges:DestroyOnExpire() return false end
function modifier_mjz_slark_pounce_charges:RemoveOnDeath() return false end

function modifier_mjz_slark_pounce_charges:DeclareFunctions()
	local functions = {
	}
	return functions
end

function modifier_mjz_slark_pounce_charges:OnCreated(args)
	if IsServer() then
		local initialStacksCount = self:GetAbility():GetSpecialValueFor("max_charges")
		
		self:SetStackCount(initialStacksCount)
		self:StartIntervalThink(0.1)
	end
end

function modifier_mjz_slark_pounce_charges:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		local stacksNumber = self:GetStackCount()
		local chargesLimit = self:GetAbility():GetSpecialValueFor("max_charges")

		if stacksNumber >= chargesLimit then
			return nil
		end

		if self:GetRemainingTime() < 0 then
			self:IncrementStackCount()
		end
	end
end

function modifier_mjz_slark_pounce_charges:OnStackCountChanged(oldStackCount)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local chargeRestoreTime = self:GetAbility():GetSpecialValueFor("charge_restore_time")
		local chargesLimit = self:GetAbility():GetSpecialValueFor("max_charges")
        local stacksNumber = self:GetStackCount()
        
        chargeRestoreTime = chargeRestoreTime * parent:GetCooldownReduction()

		if oldStackCount > stacksNumber then
			if oldStackCount == chargesLimit then
				self:SetDuration(chargeRestoreTime, true)
			end
		else
			if stacksNumber < chargesLimit then
				self:SetDuration(chargeRestoreTime, true)
			else
				self:SetDuration(-1, true)
			end
		end

		if stacksNumber == 0 then
			ability:EndCooldown()
			ability:StartCooldown(self:GetRemainingTime())
		elseif stacksNumber > 0 then
			ability:EndCooldown()
		end
	end
end

modifier_mjz_void_spirit_astral_atlas_crit = class({})
local modifier_class = modifier_mjz_void_spirit_astral_atlas_crit

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end
function modifier_class:RemoveOnDeath() return true end


function modifier_class:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE }
	return funcs
end


function modifier_class:GetModifierPreAttack_CriticalStrike()
    local caster = self:GetCaster()
    local sp = caster:FindAbilityByName("special_bonus_unique_void_spirit_8")
    if sp then
        return sp:GetSpecialValueFor("value")
        -- local intnPct = 
        -- if RollPercentage(intnPct) then
        --     -- body
        -- end
    end
	return 0
end

	
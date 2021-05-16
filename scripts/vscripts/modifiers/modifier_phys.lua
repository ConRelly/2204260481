
modifier_phys = class({})

function modifier_phys:IsBuff()
    return true
end
function modifier_phys:IsHidden()
    return true
end

function modifier_phys:GetTexture()
    return "custom_avatar_debuff"
end

function modifier_phys:IsPurgable()
    return false
end

function modifier_phys:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,

	}
	return funcs
end

function modifier_phys:GetModifierIncomingPhysicalDamage_Percentage()
	local parent = self:GetParent()
	local armor = parent:GetPhysicalArmorValue(false)
	local base = 0
	if armor < 85 then 
		if armor < 1 then
			base = -87 
		else	
			base = (82 - armor) * (-1)
		end
	end    
	return base
end




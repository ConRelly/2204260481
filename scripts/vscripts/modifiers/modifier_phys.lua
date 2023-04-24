

LinkLuaModifier("modifier_phys", "modifiers/modifier_phys.lua", LUA_MODIFIER_MOTION_NONE)
modifier_phys = class({})

function modifier_phys:IsBuff()
    return true
end
function modifier_phys:IsHidden()
    return false
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
	if armor < 110 then 
		if armor < 5 then
			base = -88 
		else	
			base = math.floor((84 - (armor / 1.3))) * (-1)
		end
	end   
	return base
end





--LinkLuaModifier("modifier_hard_mode_boss", "modifiers/modifier_hard_mode_boss.lua", LUA_MODIFIER_MOTION_NONE)
modifier_hard_mode_boss = class({})

function modifier_hard_mode_boss:IsBuff()
    return true
end

function modifier_hard_mode_boss:IsHidden()
    return false
end

function modifier_hard_mode_boss:GetTexture()
    return "custom_avatar_debuff"
end

function modifier_hard_mode_boss:IsPurgable()
    return false
end

function modifier_hard_mode_boss:CheckState()
	local state =
	{
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY ] = true,

	}
	return state
end


function modifier_hard_mode_boss:DeclareFunctions()
	local funcs = {
        --MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		--MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

--function modifier_hard_mode_boss:GetModifierPercentageCooldown()
    --return 10
--end

--function modifier_hard_mode_boss:GetModifierTotalPercentageManaRegen()
	--return 0.5
--end

function modifier_hard_mode_boss:GetModifierPhysicalArmorBonus() 
	local parent = self:GetParent()
	local lvl = parent:GetLevel() or 10
	if lvl > 15 then 
		lvl = lvl + 50	
	end	
	return lvl
end
function modifier_hard_mode_boss:GetModifierIncomingDamage_Percentage()
	return -75
end

function modifier_hard_mode_boss:GetModifierMagicalResistanceBonus()
	return 65
end	

function modifier_hard_mode_boss:GetModifierExtraHealthPercentage()
    return 250
end  

function modifier_hard_mode_boss:GetModifierTotalDamageOutgoing_Percentage()
    return 150       -- 伤害增强20%
end


function modifier_hard_mode_boss:OnCreated() 
	--local parent = self:GetParent()
	--self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_rage_body.vpcf", PATTACH_POINT_FOLLOW, parent)
	--ParticleManager:SetParticleControlEnt(self.particle,2,self:GetParent(),PATTACH_CENTER_FOLLOW,"attach_hitloc",self:GetParent():GetAbsOrigin(), true)
	
end

function modifier_hard_mode_boss:OnDestroy() 
	--ParticleManager:DestroyParticle(self.particle, false)
	--ParticleManager:ReleaseParticleIndex(self.particle)
end
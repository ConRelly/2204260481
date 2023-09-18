
LinkLuaModifier("modifier_ward_like", "abilities/ability_ward_like.lua", LUA_MODIFIER_MOTION_NONE)
ability_ward_like = class({})

function ability_ward_like:GetIntrinsicModifierName()
	return "modifier_ward_like"
end

modifier_ward_like = class({})
-- Set the modifier as permanent
function modifier_ward_like:IsPermanent()
    return true
end

-- Set the modifier as hidden
function modifier_ward_like:IsHidden()
    return true
end

-- Set the modifier as debuff
function modifier_ward_like:IsDebuff()
    return false
end

-- Set the modifier as purgable
function modifier_ward_like:IsPurgable()
    return false
end
function modifier_ward_like:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_PROPERTY_HEALTHBAR_PIPS,
	}

	return funcs
end

function modifier_ward_like:CheckState() 
    return {
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY]  	= true,	
    } 
end


function modifier_ward_like:OnAttacked(kv)
	if IsServer() then
		if kv.target ~= self:GetParent() then
			return
		end
        local attacker = kv.attacker
        local damage = 20
        if kv.attacker:GetUnitName() == "npc_courier_replacement" or not kv.attacker:IsRealHero() then damage = 1 end
		local parent = self:GetParent()
        parent:ModifyHealth( parent:GetHealth() - damage, nil, true, 0 )

        EmitSoundOn( "Hero_Wisp.Spirits.Target", self:GetParent() )

	end
end

function modifier_ward_like:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_ward_like:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_ward_like:GetAbsoluteNoDamagePure()
	return 1
end
function modifier_ward_like:GetModifierHealthBarPips()
	return 5
end
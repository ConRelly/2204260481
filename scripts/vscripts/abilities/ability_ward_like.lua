
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
    if not IsServer() then return end
    if kv.target ~= self:GetParent() then return end

    local attacker = kv.attacker
    local damage = 20
    if attacker:GetUnitName() == "npc_courier_replacement" or not attacker:IsRealHero() then
        damage = 1
    end

    local parent = self:GetParent()
    local newHealth = math.max(parent:GetHealth() - damage, 0)
    parent:ModifyHealth(newHealth, nil, true, 0)

    EmitSoundOn("Hero_Wisp.Spirits.Target", parent)
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
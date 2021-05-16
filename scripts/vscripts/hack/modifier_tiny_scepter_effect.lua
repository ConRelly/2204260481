modifier_tiny_scepter_effect = class({})

local modifier = modifier_tiny_scepter_effect


function modifier:IsHidden()
    return true
end

function modifier:IsPurgable()
    return false
end

function modifier:GetTexture()
	return "item_ultimate_scepter"
end

function modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_START
    }
    return funcs
end

function modifier:OnAttackStart(keys)
    if IsServer() then
        if keys.attacker ~= self:GetParent() then
            return nil
        end

        local unit = self:GetParent()
        local tree_grab_modifier_name = 'modifier_tiny_craggy_exterior'
        
        local tree_grab_modifier = unit:FindModifierByName(tree_grab_modifier_name)
        if unit:HasScepter() and tree_grab_modifier then
            unit:SetModifierStackCount(tree_grab_modifier_name, unit, 99)  
        end
	end
end
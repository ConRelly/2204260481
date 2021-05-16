LinkLuaModifier("modifier_mjz_tiny_tree_grab_scepter_effect", "abilities/hero_tiny/mjz_tiny_tree_grab_scepter_effect.lua", LUA_MODIFIER_MOTION_NONE)

mjz_tiny_tree_grab_scepter_effect = class({})
local ability_class = mjz_tiny_tree_grab_scepter_effect

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_tiny_tree_grab_scepter_effect"
end


modifier_mjz_tiny_tree_grab_scepter_effect = class({})
local modifier_class = modifier_mjz_tiny_tree_grab_scepter_effect

function modifier_class:IsPassive()  return true end
function modifier_class:IsHidden()  return true end
function modifier_class:IsPurgable() return false end


if IsServer() then
	function modifier_class:OnCreated(table)
		self:_Work()
	end

	function modifier_class:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_ATTACK
		}
		return funcs
	end
	function modifier_class:OnAttack(keys)
		if keys.attacker ~= self:GetParent() then
			return nil
		end

		self:_Work()
	end

	function modifier_class:_Work( )
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local attack_count = ability:GetSpecialValueFor('attack_count') or 99
		local tree_grab_modifier_name = 'modifier_tiny_craggy_exterior'
		
		if parent:HasScepter() then
			local tree_grab_modifier = parent:FindModifierByName(tree_grab_modifier_name)
			if tree_grab_modifier then
				-- parent:SetModifierStackCount(tree_grab_modifier_name, parent, attack_count)  
				tree_grab_modifier:SetStackCount(attack_count)
			end
		end
	end
end

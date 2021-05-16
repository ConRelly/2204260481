-- require("lib/my")
local THIS_LUA = "items/item_mjz_mana_staff.lua"
LinkLuaModifier('modifier_item_mjz_mana_staff_consumed', THIS_LUA, LUA_MODIFIER_MOTION_NONE)


function on_attack(keys, mana_steal)
    local caster = keys.caster
    local ability = keys.ability
    local damage = keys.damage

    local mana_steal_pct = mana_steal or ability:GetSpecialValueFor("mana_steal")

    local mana_gain = damage * mana_steal_pct * 0.01

    local particle = ParticleManager:CreateParticle("particles/custom/manasteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(particle)

    caster:GiveMana(mana_gain)
end


function ManaStaffCast( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier_consumed = keys.modifier_consumed
	local modifier_stats = keys.modifier_stats
	local sound_cast = keys.sound_cast

	-- If the caster already has the synth buff, do nothing
	if caster:HasModifier(modifier_consumed) or caster:HasModifier("modifier_arc_warden_tempest_double") then
		return nil
	end

	-- Otherwise, apply the synth buff and the stats buff
    caster:AddNewModifier(caster, ability, modifier_consumed, {})
    if modifier_stats then
	    ability:ApplyDataDrivenModifier(caster, caster, modifier_stats, {})
    end

	-- Play sound
	caster:EmitSound(sound_cast)

	-- Spend the item's only charge
	ability:SetCurrentCharges( ability:GetCurrentCharges() - 1 )
	caster:RemoveItem(ability)

	-- Create a regular scepter for one game frame to prevent regular dota interactions from going bad
	-- local dummy_scepter = CreateItem("item_ultimate_scepter", caster, caster)
	-- caster:AddItem(dummy_scepter)
	-- Timers:CreateTimer(0.01, function()
	-- 	caster:RemoveItem(dummy_scepter)
	-- end)
end

------------------------------------------------------------
modifier_item_mjz_mana_staff_consumed = modifier_item_mjz_mana_staff_consumed or class({})

function modifier_item_mjz_mana_staff_consumed:IsPurgable() return false end
function modifier_item_mjz_mana_staff_consumed:IsHidden() return false end
function modifier_item_mjz_mana_staff_consumed:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_item_mjz_mana_staff_consumed:GetTexture()
    return "item_mjz_mana_staff"
end

function modifier_item_mjz_mana_staff_consumed:DeclareFunctions() 
    if IsServer() then
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,		-- 当拥有modifier的单位攻击到某个目标时
            MODIFIER_PROPERTY_TOOLTIP,	-- OnTooltip
        }
    else
        return {
            MODIFIER_PROPERTY_TOOLTIP,	-- OnTooltip
        }
    end
end

function modifier_item_mjz_mana_staff_consumed:OnTooltip()
	-- if self:GetAbility() then
	-- 	return self:GetAbility():GetSpecialValueFor("mana_steal")
	-- end
    -- return 0
    return self:GetStackCount()
end

if IsServer() then

    function  modifier_item_mjz_mana_staff_consumed:OnCreated(table)
		local ability = self:GetAbility()
        local mana_steal_pct = ability:GetSpecialValueFor("mana_steal")
        self:SetStackCount(mana_steal_pct)
    end
    
    function modifier_item_mjz_mana_staff_consumed:OnAttackLanded(keys)
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local attacker = keys.attacker
        local damage = keys.damage

		if attacker == self:GetParent() then
			local target = keys.target
			
			on_attack({
                caster = caster, ability = ability, damage = damage
            }, self:GetStackCount())
		end
	end

end

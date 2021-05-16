
local THIS_LUA = "items/item_kris_of_agony_one.lua"
LinkLuaModifier("modifier_item_kris_of_agony_one", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_kris_of_agony_one_lifesteal", THIS_LUA, LUA_MODIFIER_MOTION_NONE)


item_kris_of_agony_one = class({})

function item_kris_of_agony_one:GetIntrinsicModifierName()
    return "modifier_item_kris_of_agony_one"
end


-------------------------------------------------------------------------

modifier_item_kris_of_agony_one = class({})

function modifier_item_kris_of_agony_one:IsHidden() return true end
function modifier_item_kris_of_agony_one:IsPurgable() return false end

function modifier_item_kris_of_agony_one:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_kris_of_agony_one:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_item_kris_of_agony_one:GetModifierBonusStats_Strength( ... )
    return self:GetAbility():GetSpecialValueFor("bonus_strenght")
end

function modifier_item_kris_of_agony_one:GetModifierBonusStats_Agility( ... )
    return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_item_kris_of_agony_one:GetModifierHealthBonus( ... )
    return self:GetAbility():GetSpecialValueFor("bonus_hp")
end

function modifier_item_kris_of_agony_one:OnAttackLanded( keys )
    if IsServer() then
        if keys.attacker == self:GetParent() then
            if IsValidEntity(self.parent) then
                if not self.parent:HasModifier(self.mName) then
                    self.parent:AddNewModifier(self.parent, self.ability, self.mName, {})
                end
            end
        end
    end
end

if IsServer() then

    function modifier_item_kris_of_agony_one:OnCreated()
		self.ability = self:GetAbility()
        self.parent = self:GetParent()
        self.mName = "modifier_item_kris_of_agony_one_lifesteal"
        Timers:CreateTimer(
			0.25, 
            function()
                if IsValidEntity(self.parent) then
                    self.parent:RemoveModifierByName(self.mName)
				    self.parent:AddNewModifier(self.parent, self.ability, self.mName, {})
                end
			end
        )
    end

    function modifier_item_kris_of_agony_one:OnDestroy()
        if IsValidEntity(self:GetParent()) then
            self:GetParent():RemoveModifierByName(self.mName)
        end
    end
end

-------------------------------------------------------------------------

modifier_item_kris_of_agony_one_lifesteal = class({})

function modifier_item_kris_of_agony_one_lifesteal:IsHidden() return true end
function modifier_item_kris_of_agony_one_lifesteal:IsPurgable() return false end

function modifier_item_kris_of_agony_one_lifesteal:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_item_kris_of_agony_one_lifesteal:GetModifierEvasion_Constant( ... )
    return self:GetAbility():GetSpecialValueFor("evasion")
end

function modifier_item_kris_of_agony_one_lifesteal:OnAttackLanded( keys )
    if IsServer() then
        if keys.attacker == self:GetParent() then
            local parent = self:GetParent()
            local ability = self:GetAbility()
            local lifesteal = ability:GetSpecialValueFor("lifesteal")
            if parent:IsRangedAttacker() then
                lifesteal = ability:GetSpecialValueFor("lifesteal_ranged")
            end

            local heal = keys.damage * (lifesteal / 100)
            parent:Heal(heal, ability)

            if create_popup then
                create_popup({
                    target = parent,
                    value = heal,
                    color = Vector(0, 230, 0),
                    type = "heal"
                })
            end
            local p_name = "particles/generic_gameplay/generic_lifesteal.vpcf"
            local p_index = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, parent)
            ParticleManager:ReleaseParticleIndex(p_index)
        end

    end
end


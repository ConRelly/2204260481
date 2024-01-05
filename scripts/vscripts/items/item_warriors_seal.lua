


item_warriors_seal = class({})

function item_warriors_seal:GetIntrinsicModifierName()
    return "modifier_item_warriors_seal_buff"
end


item_warriors_seal_2 = class(item_warriors_seal)

------------------------------------------------------------------------------


LinkLuaModifier("modifier_item_warriors_seal_buff", "items/item_warriors_seal.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_warriors_seal_buff = class({})


if IsServer() then
    function modifier_item_warriors_seal_buff:OnCreated(keys)
        local parent = self:GetParent()

        if parent then
			if not parent:IsIllusion() then
				parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_warriors_seal", {})
				EmitSoundOn("Hero_Antimage.Counterspell.Absorb", parent)
			end
        end
    end
end


function modifier_item_warriors_seal_buff:IsHidden()
    return true
end
function modifier_item_warriors_seal_buff:IsPurgable()
	return false
end

-- function modifier_item_warriors_seal_buff:GetAttributes()
    -- return MODIFIER_ATTRIBUTE_MULTIPLE
-- end


function modifier_item_warriors_seal_buff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_item_warriors_seal_buff:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_warriors_seal_buff:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_warriors_seal_buff:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("magic_resist")
end

function modifier_item_warriors_seal_buff:GetModifierDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
end

LinkLuaModifier("modifier_item_warriors_seal", "items/item_warriors_seal.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_warriors_seal = class({})


function modifier_item_warriors_seal:GetTexture()
	return "warriors_seal"
end

function modifier_item_warriors_seal:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_AVOID_DAMAGE,
	}
end
function modifier_item_warriors_seal:IsPurgable()
	return false
end

function modifier_item_warriors_seal:RemoveOnDeath()
    return false
end

if IsServer() then
--[[ function modifier_item_warriors_seal:GetModifierAvoidDamage(keys)
	local attacker = keys.attacker
	local victim = keys.target
	if attacker ~= self.parent and self.parent == victim then
		local damageTaken = keys.damage
		local new_hp = self.parent:GetHealth() - (damageTaken * self.damage_reduction * self:GetStackCount() * 0.01) 
		if not self.parent:HasModifier("modifier_item_warriors_seal_buff") then
			if self:IsNull() then return end
			self:Destroy()
			return nil
		end
		if self:GetStackCount() > 0 then
			ParticleManager:CreateParticle("particles/econ/items/medusa/medusa_daughters/medusa_daughters_mana_shield_shell_impact_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
			if new_hp < 1 then
				self.parent:ForceKill(false)
			else
				self.parent:SetHealth(new_hp)
			end
			self:DecrementStackCount()
		end
	end
end ]]

function modifier_item_warriors_seal:GetModifierAvoidDamage(keys)
    local attacker = keys.attacker
    local victim = keys.target
	if self:GetAbility() then
		if attacker ~= self.parent and self.parent == victim and keys.inflictor ~= self:GetAbility() then
			local stack = self:GetStackCount()
			if stack < 1 then
				return 0
			end
			local damage_type = keys.damage_type
			local damage_flag = keys.damage_flags
			if not damage_flag then
				damage_flag = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
			else
				damage_flag = damage_flag + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION	
			end
			if not damage_type then
				damage_type = DAMAGE_TYPE_PHYSICAL
			end	
			local damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
			local damageTaken = math.floor(keys.original_damage) -- Use keys.original_damage for damage before reductions
			local damageReduction = damage_reduction * self:GetStackCount() * 0.01

			if not self.parent:HasModifier("modifier_item_warriors_seal_buff") then
				if self:IsNull() then return end
				self:Destroy()
				return 0
			end

			
			ParticleManager:CreateParticle("particles/econ/items/medusa/medusa_daughters/medusa_daughters_mana_shield_shell_impact_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)

			local postReductionDamage = damageTaken * (1 - damageReduction)			
			local damageTable = {
				victim = self.parent,
				attacker = attacker,
				damage = postReductionDamage,
				damage_type = damage_type,  -- Adjust the damage type as needed
				damage_flags = damage_flag,
				ability = self:GetAbility(),
		
			}

			ApplyDamage(damageTable)
			self:DecrementStackCount()
			return 1
		end
	end
end


function modifier_item_warriors_seal:OnCreated()
	local ability = self:GetAbility()
	self.parent = self:GetParent()
	self.damage_reduction = ability:GetSpecialValueFor("damage_reduction")
	self.interval = ability:GetSpecialValueFor("interval")
	self.max_stacks = ability:GetSpecialValueFor("max_stacks")
	ParticleManager:CreateParticle("particles/econ/items/medusa/medusa_daughters/medusa_daughters_mana_shield_end_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	self:SetStackCount(1)
	self:StartIntervalThink(self.interval)
end

function modifier_item_warriors_seal:OnIntervalThink()
	local parent = self:GetParent()
	if not parent:HasModifier("modifier_item_warriors_seal_buff") then
		if self:IsNull() then return end
		self:Destroy()
		return nil
	end
	if self:GetStackCount() < self.max_stacks then
		self:IncrementStackCount()
	end
end

end


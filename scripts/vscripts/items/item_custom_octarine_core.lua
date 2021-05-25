LinkLuaModifier("modifier_item_custom_octarine_core", "items/item_custom_octarine_core.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_custom_octarine_core_reduction", "items/item_custom_octarine_core.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_spell_lifesteal_unique", "modifiers/mjz/modifier_mjz_spell_lifesteal_unique.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_spell_lifesteal_octarine_core", "modifiers/mjz/modifier_mjz_spell_lifesteal_unique.lua", LUA_MODIFIER_MOTION_NONE)


item_custom_octarine_core = class({})

function item_custom_octarine_core:GetIntrinsicModifierName()
    return "modifier_item_custom_octarine_core"
end

item_custom_octarine_core_1 = class(item_custom_octarine_core)
item_custom_octarine_core_2 = class(item_custom_octarine_core)
item_bigan_octarine_core = class(item_custom_octarine_core)

------------------------------------------------------------------------------

modifier_item_custom_octarine_core = class({})

function modifier_item_custom_octarine_core:IsHidden()
    return true
end
function modifier_item_custom_octarine_core:IsPurgable()
	return false
end

function modifier_item_custom_octarine_core:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_custom_octarine_core:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end


function modifier_item_custom_octarine_core:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_custom_octarine_core:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_custom_octarine_core:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intelligence")
end


if IsServer() then
	function modifier_item_custom_octarine_core:OnCreated()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.itemName = self:GetAbility():GetName()
		--self.lifesteal = self.ability:GetSpecialValueFor("lifesteal") * 0.01
		self.lifesteal = self.ability:GetSpecialValueFor("lifesteal")
		self.particle_name = "particles/items3_fx/octarine_core_lifesteal.vpcf"
		self.mn_reduction = "modifier_item_custom_octarine_core_reduction"
		self.mn_lifesteal = "modifier_mjz_spell_lifesteal_unique"
		-- print(self.itemName)
		Timers:CreateTimer(
			0.25, 
			function()
				self.parent:RemoveModifierByName(self.mn_reduction)
				self.parent:AddNewModifier(self.parent, self.ability, self.mn_reduction, {})
				
				self.parent:RemoveModifierByName(self.mn_lifesteal)
				if not self.parent:IsIllusion() then
					local m = self.parent:AddNewModifier(self.parent, self.ability, self.mn_lifesteal, {})
					if m then
						m:SetStackCount(self.lifesteal)
					end
				end	
			end
		)
	end
	
	function modifier_item_custom_octarine_core:OnDestroy()
		if IsValidEntity(self.parent) then
			self.parent:RemoveModifierByName("modifier_item_custom_octarine_core_reduction")
			self.parent:RemoveModifierByName( "modifier_mjz_spell_lifesteal_unique")
		end
	end
	
	function modifier_item_custom_octarine_core:OnTakeDamage(keys)
		if keys.attacker:HasModifier("modifier_item_custom_octarine_core") then
			if self.parent == keys.attacker and keys.unit ~= self.parent then
				if self:_CanHeal(keys) then
					self.parent:Heal(keys.original_damage * self.lifesteal, self)
					ParticleManager:CreateParticle(self.particle_name, PATTACH_ABSORIGIN_FOLLOW, self.parent)
				end
			end
		end
	end

	function modifier_item_custom_octarine_core:_CanHeal( keys )
		local ability = keys.inflictor
		if keys.damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
			if keys.damage_type == DAMAGE_TYPE_PHYSICAL then
				if ability then
					-- return true
					local behavior = ability:GetBehavior()
					if self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET ) or 
						self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET ) or
						self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_POINT ) or
						self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_AOE )
					then
						return true
					end
				end
				return false
			end
			return true
		end
		return false
	end
	
	-- Helper: Flags
	function modifier_item_custom_octarine_core:FlagExist(a,b)--Bitwise Exist
		local p,c,d=1,0,b
		while a>0 and b>0 do
			local ra,rb=a%2,b%2
			if ra+rb>1 then c=c+p end
			a,b,p=(a-ra)/2,(b-rb)/2,p*2
		end
		return c==d
	end
end

modifier_item_custom_octarine_core_reduction = class({})

function modifier_item_custom_octarine_core_reduction:IsHidden()
    return true
end

function modifier_item_custom_octarine_core_reduction:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    }
end
function modifier_item_custom_octarine_core_reduction:IsPurgable()
	return false
end
function modifier_item_custom_octarine_core_reduction:RemoveOnDeath()
	return false
end

function modifier_item_custom_octarine_core_reduction:GetModifierPercentageCooldown()
	if IsValidEntity(self:GetAbility()) then
		return self:GetAbility():GetSpecialValueFor("bonus_cooldown")
	else
		self:Destroy()
	end
end
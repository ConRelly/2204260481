LinkLuaModifier("modifier_item_radiance_armor", "items/custom/item_radiance_armor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_radiance_armor_aura", "items/custom/item_radiance_armor", LUA_MODIFIER_MOTION_NONE)

item_radiance_armor = class({})

function item_radiance_armor:GetIntrinsicModifierName()
	return "modifier_item_radiance_armor"
end

function item_radiance_armor:GetCastRange()
	return self:GetSpecialValueFor("aura_radius")
end
--------------------------------------------------------
------------------------------------------------------------
modifier_item_radiance_armor = class({
	IsHidden 				= function(self) return false end,
	IsAura 					= function(self) return true end,
	GetAuraRadius 			= function(self) return self:GetAbility():GetSpecialValueFor("aura_radius") end,
	GetAuraSearchTeam 		= function(self) return DOTA_UNIT_TARGET_TEAM_ENEMY end,
	GetAuraSearchType 		= function(self) return DOTA_UNIT_TARGET_HERO end,
	GetModifierAura 		= function(self) return "modifier_item_radiance_armor_aura" end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_HEALTH_BONUS,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
		} end,
})

function modifier_item_radiance_armor:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local radiance_table = {
		--"modifier_item_radiance_armor",
		"modifier_item_radiance_armor_3",
		"modifier_item_radiance_armor_blue",
		"modifier_item_radiance_armor_green",
		"modifier_item_radiance_armor_3_edible",
		"modifier_item_radiance_armor_blue_edible",
		"modifier_item_radiance_armor_green_edible"
		}
		local parent = self:GetParent()
		for i = 1 , 6 do
			if parent:HasModifier(radiance_table[i]) then
				print(radiance_table[i])
				parent:RemoveModifierByName(radiance_table[i])
				if parent:IsIllusion() then
					parent:ForceKill(false)
				end
			end
		end
    end
end
function modifier_item_radiance_armor:OnDestroy()
end	
function modifier_item_radiance_armor:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_radiance_armor:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_attack")
end

function modifier_item_radiance_armor:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_radiance_armor:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_radiance_armor:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_radiance_armor:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_radiance_armor:GetModifierExtraHealthPercentage()
	return self:GetAbility():GetSpecialValueFor("bonus_health_pct")
end

function modifier_item_radiance_armor:GetEffectName()
	return "particles/econ/events/ti6/radiance_owner_ti6.vpcf"
end

modifier_item_radiance_armor_aura = class({
	IsHidden 		= function(self) return false end,
})

function modifier_item_radiance_armor_aura:OnCreated()
	if IsServer() then		
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("think_interval"))
		
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		self.base_damage = ability:GetSpecialValueFor("aura_dmg")
		self.aura_dmg_pct = ability:GetSpecialValueFor("aura_dmg_pct")
		self.aura_radius = ability:GetSpecialValueFor("aura_radius")
		self:StartIntervalThink(1)
		if not caster:IsRealHero() then
			self:StartIntervalThink(2)
		end				
	    --local pfx = ParticleManager:CreateParticle("particles/econ/events/ti6/radiance_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	   -- ParticleManager:SetParticleControl(pfx, 1, caster:GetAbsOrigin())
		--self:AddParticle(pfx, false, false, MODIFIER_PRIORITY_HIGH, false, false)
	end	

end


function modifier_item_radiance_armor_aura:IsPurgable()
	return false	
end
function modifier_item_radiance_armor_aura:GetTexture()
	return self:GetAbility():GetAbilityTextureName()
end
function modifier_item_radiance_armor_aura:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_radiance_armor_aura:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local aura_dmg = self.base_damage
		local aura_dmg_pct = ability:GetSpecialValueFor("aura_dmg_pct")/100
		local damage = math.ceil(aura_dmg + aura_dmg_pct*caster:GetMaxHealth())
		--print(damage)
		if not caster:IsRealHero() then
			damage = damage * 2
		end
		ApplyDamage({victim = parent, attacker = caster, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
	end
end

item_radiance_armor_1 = class(item_radiance_armor)
item_radiance_armor_2 = class(item_radiance_armor)


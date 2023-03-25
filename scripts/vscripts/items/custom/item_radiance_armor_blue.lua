require("lib/mys")
LinkLuaModifier("modifier_item_radiance_armor_blue", "items/custom/item_radiance_armor_blue", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_radiance_armor_aura_blue", "items/custom/item_radiance_armor_blue", LUA_MODIFIER_MOTION_NONE)
require("lib/notifications")
item_radiance_armor_blue = class({})

function item_radiance_armor_blue:GetIntrinsicModifierName()
	return "modifier_item_radiance_armor_blue"
end

function item_radiance_armor_blue:GetCastRange()
	return self:GetSpecialValueFor("aura_radius")
end
local radir = 0
--------------------------------------------------------
------------------------------------------------------------
modifier_item_radiance_armor_blue = class({
	IsHidden 				= function(self) return true end,
	IsAura 					= function(self) return true end,
	GetAuraRadius 			= function(self) return self:GetAbility():GetSpecialValueFor("aura_radius") end,
	GetAuraSearchTeam 		= function(self) return DOTA_UNIT_TARGET_TEAM_ENEMY end,
	GetAuraSearchType 		= function(self) return DOTA_UNIT_TARGET_HERO end,
	GetModifierAura 		= function(self) return "modifier_item_radiance_armor_aura_blue" end,
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
function modifier_item_radiance_armor_blue:OnCreated()
	if IsServer() then
		local radiance_table = {
			"modifier_item_radiance_armor",
			"modifier_item_radiance_armor_3",
			--"modifier_item_radiance_armor_blue",
			"modifier_item_radiance_armor_green",
			"modifier_item_radiance_armor_3_edible",
			"modifier_item_radiance_armor_blue_edible",
			"modifier_item_radiance_armor_green_edible"
		}
		local parent = self:GetParent()
		for i = 1 , 6 do
			if parent:HasModifier(radiance_table[i]) then
				--print(radiance_table[i])
				parent:RemoveModifierByName(radiance_table[i])
				if parent:IsIllusion() then
					parent:ForceKill(false)
				end
			end
		end
	end
end
function modifier_item_radiance_armor_blue:OnDestroy()
end

function modifier_item_radiance_armor_blue:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_radiance_armor_blue:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_attack")
end

function modifier_item_radiance_armor_blue:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_radiance_armor_blue:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_radiance_armor_blue:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_radiance_armor_blue:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_radiance_armor_blue:GetModifierExtraHealthPercentage()
	return self:GetAbility():GetSpecialValueFor("bonus_health_pct")
end

function modifier_item_radiance_armor_blue:GetEffectName()
	return "particles/econ/events/ti6/radiance_owner_ti6.vpcf"
end

modifier_item_radiance_armor_aura_blue = class({
	IsHidden 		= function(self) return false end,
})

function modifier_item_radiance_armor_aura_blue:OnCreated()
	if IsServer() then
		--self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("think_interval"))
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if caster == nil then return end
		self.base_damage = ability:GetSpecialValueFor("aura_dmg")
		self.aura_dmg_pct = ability:GetSpecialValueFor("aura_dmg_pct")
		self.aura_radius = ability:GetSpecialValueFor("aura_radius")
		self.int_damage = ability:GetSpecialValueFor("int_damage")
		self.mana_damage = ability:GetSpecialValueFor("mana_damage")
		self.int_threshold = ability:GetSpecialValueFor("int_threshold")
		self.threshold_multi = ability:GetSpecialValueFor("threshold_multi")
		self:StartIntervalThink(1)
		if not caster:IsRealHero() then	
			self:StartIntervalThink(2)
		end		
	   -- local pfx = ParticleManager:CreateParticle("particles/econ/events/ti6/radiance_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	    --ParticleManager:SetParticleControl(pfx, 1, caster:GetAbsOrigin())
		--self:AddParticle(pfx, false, false, MODIFIER_PRIORITY_HIGH, false, false)
	end	

end


function modifier_item_radiance_armor_aura_blue:IsPurgable()
	return false	
end
function modifier_item_radiance_armor_aura_blue:GetTexture()
	return self:GetAbility():GetAbilityTextureName()
end
function modifier_item_radiance_armor_aura_blue:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_radiance_armor_aura_blue:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		if caster == nil then return end
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local int = caster:GetIntellect()
		local int_mult = self.int_damage
		if int > self.int_threshold then 
			int_mult = self.threshold_multi
		end		
		local mana_bonus_dmg = caster:GetMaxMana() * (self.mana_damage / 100)
		local bonus_int_dmg = math.ceil(int * int_mult)
		local aura_dmg = self.base_damage
		local aura_dmg_pct = ability:GetSpecialValueFor("aura_dmg_pct")/100
		local damage = math.ceil(aura_dmg + aura_dmg_pct*caster:GetMaxHealth() + mana_bonus_dmg + bonus_int_dmg )
		--print(damage .. " radi dmg")
		if caster:IsRealHero() then	
			if HasSpeedsters(caster) and HasFalenSky(caster) and not GameRules:IsCheatMode() then
				damage = damage * 4
				if radir < 1 then
					Notifications:TopToAll({text="#stuf_2", style={color="blue"}, duration=5})
					radir = radir + 2
				end
				if _G._challenge_bosss > 0 then
					local heal_mult = _G._challenge_bosss / 50
					local heal_amount = damage * heal_mult
					caster:Heal(heal_amount, caster)
					local particle = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:DestroyParticle(particle, false)
					ParticleManager:ReleaseParticleIndex( particle )
				end							
			end
		end	
		if not caster:IsRealHero() then	
			damage = damage * 2
		end		
		ApplyDamage({victim = parent, attacker = caster, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
	end
end

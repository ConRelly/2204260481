require("lib/mys")
LinkLuaModifier("modifier_item_radiance_armor_green", "items/custom/item_radiance_armor_green", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_radiance_armor_aura_green", "items/custom/item_radiance_armor_green", LUA_MODIFIER_MOTION_NONE)
require("lib/notifications")
item_radiance_armor_green = class({})

function item_radiance_armor_green:GetIntrinsicModifierName()
	return "modifier_item_radiance_armor_green"
end

function item_radiance_armor_green:GetCastRange()
	return self:GetSpecialValueFor("aura_radius")
end
local radir = 0
--------------------------------------------------------
------------------------------------------------------------
modifier_item_radiance_armor_green = class({
	IsHidden 				= function(self) return true end,
	IsAura 					= function(self) return true end,
	GetAuraRadius 			= function(self) return self:GetAbility():GetSpecialValueFor("aura_radius") end,
	GetAuraSearchTeam 		= function(self) return DOTA_UNIT_TARGET_TEAM_ENEMY end,
	GetAuraSearchType 		= function(self) return DOTA_UNIT_TARGET_HERO end,
	GetModifierAura 		= function(self) return "modifier_item_radiance_armor_aura_green" end,
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

function modifier_item_radiance_armor_green:OnCreated()
	if IsServer() then
		local radiance_table = {
			"modifier_item_radiance_armor",
			"modifier_item_radiance_armor_3",
			"modifier_item_radiance_armor_blue",
			--"modifier_item_radiance_armor_green",
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
function modifier_item_radiance_armor_green:OnDestroy()
end
function modifier_item_radiance_armor_green:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_attack") end
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_radiance_armor_green:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_attack") end
end

function modifier_item_radiance_armor_green:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_stats") end
end

function modifier_item_radiance_armor_green:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_stats") end
end

function modifier_item_radiance_armor_green:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_stats") end
end

function modifier_item_radiance_armor_green:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_armor") end
end

function modifier_item_radiance_armor_green:GetModifierExtraHealthPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health_pct") end

end

function modifier_item_radiance_armor_green:GetEffectName()
	return "particles/econ/events/ti6/radiance_owner_ti6.vpcf"
end

modifier_item_radiance_armor_aura_green = class({
	IsHidden 		= function(self) return false end,
})

function modifier_item_radiance_armor_aura_green:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("think_interval"))
		
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		self.base_damage = ability:GetSpecialValueFor("aura_dmg")
		self.aura_dmg_pct = ability:GetSpecialValueFor("aura_dmg_pct")
		self.aura_radius = ability:GetSpecialValueFor("aura_radius")
		self.agi_damage = ability:GetSpecialValueFor("agi_damage")
		self.ms_damage = ability:GetSpecialValueFor("ms_damage")
		self.agi_threshold = ability:GetSpecialValueFor("agi_threshold")
		self.ms_threshold = ability:GetSpecialValueFor("ms_threshold")
		self.agi_threshold_multi = ability:GetSpecialValueFor("agi_threshold_multi")
		self.ms_threshold_multi = ability:GetSpecialValueFor("ms_threshold_multi")
		self:StartIntervalThink(1)
		if not caster:IsRealHero() then	
			self:StartIntervalThink(2)
		end			
	    --local pfx = ParticleManager:CreateParticle("particles/econ/events/ti6/radiance_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	    --ParticleManager:SetParticleControl(pfx, 1, caster:GetAbsOrigin())
		--self:AddParticle(pfx, false, false, MODIFIER_PRIORITY_HIGH, false, false)
	end	

end
function modifier_item_radiance_armor_aura_green:OnDestroy()

end	
--function modifier_item_radiance_armor_aura_green:GetEffectName()
--	return "particles/econ/events/ti6/radiance_ti6.vpcf"
--end
function modifier_item_radiance_armor_aura_green:IsPurgable()
	return false	
end
function modifier_item_radiance_armor_aura_green:GetTexture()
	return self:GetAbility():GetAbilityTextureName()
end
function modifier_item_radiance_armor_aura_green:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_radiance_armor_aura_green:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local agi = caster:GetAgility()
		local ms = caster:GetIdealSpeed()
		local ms_mult = self.ms_damage
		local agi_mult = self.agi_damage
		if agi > self.agi_threshold then 
			agi_mult = self.agi_threshold_multi
		end	
		if ms > self.ms_threshold then
			ms_mult = self.ms_threshold_multi
		end		
		local ms_bonus_dmg = ms * ms_mult
		local bonus_agi_dmg = math.ceil(agi * agi_mult)
		local aura_dmg = self.base_damage
		local aura_dmg_pct = ability:GetSpecialValueFor("aura_dmg_pct")/100
		local damage = math.ceil(aura_dmg + aura_dmg_pct*caster:GetMaxHealth() + ms_bonus_dmg + bonus_agi_dmg )
		--print(damage .. " radi dmg")
		if caster:IsRealHero() then	
			if HasSpeedsters(caster) and HasSwiftBlink(caster) and not GameRules:IsCheatMode() then
				damage = damage * 4
				if radir < 1 then
					Notifications:TopToAll({text="#stuf_3", style={color="green"}, duration=5})
					radir = radir + 2
				end			
			end
		end	
		if not caster:IsRealHero() then	
			damage = damage * 2
		end		
		ApplyDamage({victim = parent, attacker = caster, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
	end	
end

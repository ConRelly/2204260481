require("lib/mys")
LinkLuaModifier("modifier_item_radiance_armor_green_edible", "items/custom/item_radiance_armor_green_edible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_radiance_armor_aura_green_edible", "items/custom/item_radiance_armor_green_edible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_radiance_armor_green_unlocked", "items/custom/item_radiance_armor_green_edible", LUA_MODIFIER_MOTION_NONE)

require("lib/notifications")
item_radiance_armor_green_edible = class({})

function item_radiance_armor_green_edible:GetIntrinsicModifierName()
	return "modifier_item_radiance_armor_green_edible"
end

function item_radiance_armor_green_edible:GetCastRange()
	return 1500
end
local radir = 0
--------------------------------------------------------
------------------------------------------------------------
modifier_item_radiance_armor_green_edible = class({
	IsHidden 				= function(self) return false end,
	IsAura 					= function(self) return true end,
	IsPurgable              = function(self) return false end,
	RemoveOnDeath           = function(self) return false end,
	AllowIllusionDuplicate  = function(self) return true end,
	GetTexture              = function(self) return "radiance_armor_green" end,
	GetAuraRadius 			= function(self) return 2000 end,
	GetAuraSearchTeam 		= function(self) return DOTA_UNIT_TARGET_TEAM_ENEMY end,
	GetAuraSearchType 		= function(self) return DOTA_UNIT_TARGET_HERO end,
	GetModifierAura 		= function(self) return "modifier_item_radiance_armor_aura_green_edible" end,
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

function modifier_item_radiance_armor_green_edible:OnCreated()	
end
function modifier_item_radiance_armor_green_edible:OnDestroy()
end

function modifier_item_radiance_armor_green_edible:GetModifierHealthBonus()
	return 10000
end

function modifier_item_radiance_armor_green_edible:GetModifierPreAttack_BonusDamage()
	return 110000
end

function modifier_item_radiance_armor_green_edible:GetModifierBonusStats_Strength()
	return 600
end

function modifier_item_radiance_armor_green_edible:GetModifierBonusStats_Agility()
	return 1150
end

function modifier_item_radiance_armor_green_edible:GetModifierBonusStats_Intellect()
	return 600
end

function modifier_item_radiance_armor_green_edible:GetModifierPhysicalArmorBonus()
	return 99
end

function modifier_item_radiance_armor_green_edible:GetModifierExtraHealthPercentage()
	return 32
end

function modifier_item_radiance_armor_green_edible:GetEffectName()
	return "particles/econ/events/ti6/radiance_owner_ti6.vpcf"
end

modifier_item_radiance_armor_aura_green_edible = class({
	IsHidden 		= function(self) return false end,
})

function modifier_item_radiance_armor_aura_green_edible:OnCreated()
	if IsServer() then	
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		--self.base_damage = 15000
		--self.aura_dmg_pct = 50
		--self.aura_radius = 1500
		--self.str_damage = 5
		--self.armor_damage = 100
		if caster == nil then return end
		self:StartIntervalThink(1)
		if not caster:IsRealHero() then	
			self:StartIntervalThink(2)
		end		
	   -- local pfx = ParticleManager:CreateParticle("particles/econ/events/ti6/radiance_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	   -- ParticleManager:SetParticleControl(pfx, 1, caster:GetAbsOrigin())
		--self:AddParticle(pfx, false, false, MODIFIER_PRIORITY_HIGH, false, false)
	end	

end


function modifier_item_radiance_armor_aura_green_edible:IsPurgable()
	return false	
end
function modifier_item_radiance_armor_aura_green_edible:GetTexture()
	return "radiance_armor_green"
end
function modifier_item_radiance_armor_aura_green_edible:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_radiance_armor_aura_green_edible:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		if caster == nil then return end
		if not caster:IsHero() then return end
		local ability = self:GetAbility()
		local agi = caster:GetAgility()
		local ms = caster:GetIdealSpeed()
		local ms_mult = 8
		local agi_mult = 15
		if agi > 35000 then
			agi_mult = 18
		end	
		if ms > 40000 then
			ms_mult = 9.0
		end
		if caster:HasModifier("modifier_super_scepter") then
			if caster:HasModifier("modifier_marci_unleash_flurry") then
				ms_mult = 20
				agi_mult = 27
			end                                 
		end 				
		local ms_bonus_dmg = ms * ms_mult
		local bonus_agi_dmg = math.ceil(agi * agi_mult)
		local aura_dmg = 15000
		local aura_dmg_pct = 1.0
		local damage = math.ceil(aura_dmg + aura_dmg_pct*caster:GetMaxHealth() + ms_bonus_dmg + bonus_agi_dmg )
		--print(damage .. " radi dmg")
		if caster:IsRealHero() then	
			local unlocked = caster:HasModifier("modifier_radiance_armor_green_unlocked")
			if (HasSpeedsters(caster) and HasSwiftBlink(caster) and not GameRules:IsCheatMode()) or unlocked then
				damage = damage * 4
				if radir < 1 then
					Notifications:TopToAll({text="#stuf_3", style={color="green"}, duration=5})
					radir = radir + 2
				end	
				if not unlocked then
					caster:AddNewModifier(caster, ability, "modifier_radiance_armor_green_unlocked", {})
				end							
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
		if not caster:IsRealHero() then	
			damage = damage * 2
		end	
		ApplyDamage({victim = parent, attacker = caster, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
	end
end

modifier_radiance_armor_green_unlocked = modifier_radiance_armor_green_unlocked or class({})
function modifier_radiance_armor_green_unlocked:IsHidden() return false end
function modifier_radiance_armor_green_unlocked:IsPurgable() return false end
function modifier_radiance_armor_green_unlocked:RemoveOnDeath() return false end
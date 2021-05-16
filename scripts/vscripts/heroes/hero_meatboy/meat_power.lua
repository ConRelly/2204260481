LinkLuaModifier("modifier_meatboy_meat_power", "heroes/hero_meatboy/meat_power", LUA_MODIFIER_MOTION_NONE)

------------------------------------------------------------
------------------------------------------------------------

meatboy_meat_power = class({})

function meatboy_meat_power:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local duration = self:GetSpecialValueFor("duration")
	
	caster:AddNewModifier(caster, ability, "modifier_meatboy_meat_power",{duration = duration})
	
	for i=1,10 do
		local base_health = 1000
		local health_required = base_health * i
		local k = base_health/health_required
		local x = 0.9*(1-k)/(0.004 + 0.048*k)
		
		print("for base_health = "..base_health.." to health_required = "..health_required.."\n need "..x.." armor!")
	
	end
	
end

------------------------------------------------------------
------------------------------------------------------------
modifier_meatboy_meat_power = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
--	GetAttributes 			= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions		= function(self) return 
		{MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end,
})

function modifier_meatboy_meat_power:GetEffectName()
	return "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_eztzhok.vpcf"
end

function modifier_meatboy_meat_power:OnCreated()
	self:StartIntervalThink(0.25)
end

function modifier_meatboy_meat_power:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local hp_dmg = ability:GetSpecialValueFor("hp_dmg")*caster:GetHealth()/100--GetHealthPercent()
--	CustomNetTables:SetTableValue("meatboy", "meat_power", { value = hp_dmg})
	self:SetStackCount(hp_dmg)

	local effect = "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf"
	local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin()) -- Origin
	
end

function modifier_meatboy_meat_power:GetModifierPreAttack_BonusDamage()
--	local dmg_bonus = CustomNetTables:GetTableValue("meatboy", "meat_power").value
	return self:GetStackCount()
end
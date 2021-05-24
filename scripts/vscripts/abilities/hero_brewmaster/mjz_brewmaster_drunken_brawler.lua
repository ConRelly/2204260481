LinkLuaModifier("modifier_mjz_brewmaster_drunken_brawler", "abilities/hero_brewmaster/mjz_brewmaster_drunken_brawler.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_brewmaster_drunken_brawler_active", "abilities/hero_brewmaster/mjz_brewmaster_drunken_brawler.lua", LUA_MODIFIER_MOTION_NONE)


mjz_brewmaster_drunken_brawler = class({})
function mjz_brewmaster_drunken_brawler:GetIntrinsicModifierName() return "modifier_mjz_brewmaster_drunken_brawler" end
function mjz_brewmaster_drunken_brawler:OnSpellStart( )
	if not IsServer() then return nil end
	local caster = self:GetCaster()
	local duration = self:GetLevelSpecialValueFor("duration" , self:GetLevel() - 1)
	local dodge_chance = self:GetLevelSpecialValueFor("dodge_chance" , self:GetLevel() - 1)
	caster:AddNewModifier(caster, self, "modifier_mjz_brewmaster_drunken_brawler_active", {duration = duration})
end
function mjz_brewmaster_drunken_brawler:_Refresh()
	local modifier = self:GetCaster():FindModifierByName('modifier_mjz_brewmaster_drunken_brawler')
	if modifier then
		modifier:ForceRefresh()
	end
end


modifier_mjz_brewmaster_drunken_brawler = class ({})
function modifier_mjz_brewmaster_drunken_brawler:IsHidden() return true end
function modifier_mjz_brewmaster_drunken_brawler:IsPurgable() return false end
function modifier_mjz_brewmaster_drunken_brawler:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_mjz_brewmaster_drunken_brawler:GetModifierEvasion_Constant(kv)
	local ability = self:GetAbility()
	self.evasion_constant = 0
	if ability then
		if ability._active then
			self.evasion_constant = ability:GetSpecialValueFor("dodge_chance_active")			
		else
			self.evasion_constant = ability:GetSpecialValueFor("dodge_chance")			
		end
	end
	return self.evasion_constant
end
function modifier_mjz_brewmaster_drunken_brawler:GetModifierPreAttack_CriticalStrike(kv) return self.crit_strike end
function modifier_mjz_brewmaster_drunken_brawler:OnAttackStart(keys)
	local unit = self:GetCaster()
	local ability = self:GetAbility()

	self.crit = false
	self.crit_strike = 0

	self.crit_chance = 0
	if ability then
		if ability._active then
			self.crit_chance = ability:GetSpecialValueFor("crit_chance_active")
		else
			self.crit_chance = ability:GetSpecialValueFor("crit_chance")	
		end
	end

	if RollPseudoRandom(self.crit_chance, self:GetAbility()) then
		self.crit = true
	end

	if ability and self.crit then
		unit:EmitSound("Hero_Brewmaster.Brawler.Crit")

		if ability._active then
			self.crit_strike = ability:GetSpecialValueFor("crit_multiplier_active")						
		else
			self.crit_strike = ability:GetSpecialValueFor("crit_multiplier")						
		end
	end
end
function modifier_mjz_brewmaster_drunken_brawler:OnAttackLanded(keys)
	local ability = self:GetAbility()
	local attacker = keys.attacker
	if attacker == self:GetCaster() then
		local target = keys.target
		if self.crit then
			local crit_effect_name = "particles/units/heroes/hero_brewmaster/brewmaster_drunken_brawler_crit.vpcf"
			local crit_effect = ParticleManager:CreateParticle(crit_effect_name, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:ReleaseParticleIndex(crit_effect)
		end
	end
end

function modifier_mjz_brewmaster_drunken_brawler:OnRefresh(kv) end
function modifier_mjz_brewmaster_drunken_brawler:OnCreated(kv) end
function modifier_mjz_brewmaster_drunken_brawler:_Init()
	local ability = self:GetAbility()
	if ability then
		if ability._active then
			self.evasion_constant = ability:GetSpecialValueFor("dodge_chance_active")			
			self.crit_chance = ability:GetSpecialValueFor("crit_chance_active")
		else
			self.evasion_constant = ability:GetSpecialValueFor("dodge_chance")			
			self.crit_chance = ability:GetSpecialValueFor("crit_chance")	
		end
	else
		self.evasion_constant = 0
		self.crit_chance = 0
	end
end


modifier_mjz_brewmaster_drunken_brawler_active = class ({})
function modifier_mjz_brewmaster_drunken_brawler_active:IsHidden() return false end
function modifier_mjz_brewmaster_drunken_brawler_active:IsPurgable() return false end
function modifier_mjz_brewmaster_drunken_brawler_active:OnCreated(kv)
    local ability = self:GetAbility()

    ability._active = true

    local effect_evade_name = "particles/units/heroes/hero_brewmaster/brewmaster_drunkenbrawler_evade.vpcf"
    self.effect_evade = ParticleManager:CreateParticle(effect_evade_name, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    local effect_crit_name = "particles/units/heroes/hero_brewmaster/brewmaster_drunkenbrawler_crit.vpcf"
    self.effect_crit = ParticleManager:CreateParticle(effect_crit_name, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())	
end
function modifier_mjz_brewmaster_drunken_brawler_active:OnDestroy(kv)
    local ability = self:GetAbility()

    ability._active = false
    -- ability:_Refresh()

    ParticleManager:DestroyParticle(self.effect_evade, true)
    ParticleManager:DestroyParticle(self.effect_crit, true)
    ParticleManager:ReleaseParticleIndex(self.effect_evade)
    ParticleManager:ReleaseParticleIndex(self.effect_crit)
end

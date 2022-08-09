LinkLuaModifier("modifier_mjz_sandking_epicenter_slow","modifiers/hero_sand_king/modifier_mjz_sandking_epicenter.lua", LUA_MODIFIER_MOTION_NONE)


modifier_mjz_sandking_epicenter = class({})
local modifier_class = modifier_mjz_sandking_epicenter

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
	function modifier_class:OnCreated(table)
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		local epicenter_duration = self.ability:GetSpecialValueFor("epicenter_duration")
		-- local pulses_interval = ability:GetSpecialValueFor('epicenter_pulses_interval')
		
		if self.ability then
			self.radius_min = self.ability:GetSpecialValueFor("epicenter_radius_min")
			self.radius_max = self.ability:GetSpecialValueFor("epicenter_radius_max")
			self.radius_increase = self.ability:GetSpecialValueFor("epicenter_radius_increase")
			self.epicenter_pulses = GetTalentSpecialValueFor(self.ability, "epicenter_pulses")
			local epicenter_damage = self.ability:GetSpecialValueFor("epicenter_damage")
			local str_multiplier = self.ability:GetSpecialValueFor("str_multiplier") + talent_value(self.caster, "special_bonus_unique_mjz_sandking_epicenter_strength")
			self.slow_duration = self.ability:GetSpecialValueFor("epicenter_slow_duration")

			if self.caster:HasModifier("modifier_item_aghanims_shard") then
				epicenter_damage = epicenter_damage + self.ability:GetSpecialValueFor("epicenter_shard_dmg_inc")
				str_multiplier = str_multiplier + self.ability:GetSpecialValueFor("epicenter_shard_str_dmg_inc")
			end

			self.damage = epicenter_damage + self.caster:GetStrength() * str_multiplier
			if _G._challenge_bosss > 1 then
				for i = 1, _G._challenge_bosss do
					self.damage = math.floor(self.damage * 1.2)
				end	
			end
		end
		
		self.current_pulses = 0

		local flInterval = epicenter_duration / self.epicenter_pulses

		EmitSoundOn("Ability.SandKing_Epicenter", self.parent)

		self:StartIntervalThink(flInterval)
	end

	function modifier_class:OnRemoved()
		StopSoundOn("Ability.SandKing_Epicenter", self.parent)
	end
	
	function modifier_class:OnDestroy()
		StopSoundOn("Ability.SandKing_Epicenter", self.parent)
	end

	function modifier_class:OnIntervalThink()
		if self:IsNull() then self:Destroy() return end

		self.current_pulses = self.current_pulses + 1

		local radius = self.radius_min + (self.current_pulses * self.radius_increase)
		if radius > self.radius_max then radius = self.radius_max end
		
		local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		
		for _,enemy in pairs(enemies) do
			local damageTable = {
				victim = enemy,
				attacker = self.caster,
				damage = self.damage,
				damage_type = self.ability:GetAbilityDamageType(),
				ability = self.ability,
			}
			ApplyDamage(damageTable)
			
			enemy:AddNewModifier(self.caster, self.ability, 'modifier_mjz_sandking_epicenter_slow', {duration = self.slow_duration})
		end
		if RollPercentage(_G._effect_rate) then
			local p_name = "particles/units/heroes/hero_sandking/sandking_epicenter.vpcf"
			local particle = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN, self.parent)
			ParticleManager:SetParticleControlEnt(particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_origin", self.parent:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(particle, 1, Vector(radius, radius, radius))
			ParticleManager:ReleaseParticleIndex(particle)
		end	

		if self.current_pulses >= self.epicenter_pulses then
			self:StartIntervalThink(-1)
			if self:IsNull() then return end
			self:Destroy()
		end
	end
end


-----------------------------------------------------------------------------


modifier_mjz_sandking_epicenter_slow = class({})
function modifier_mjz_sandking_epicenter_slow:IsHidden() return false end
function modifier_mjz_sandking_epicenter_slow:IsPurgable() return true end

function modifier_mjz_sandking_epicenter_slow:OnCreated()
	if self:GetAbility() then
		self.ms_slow_pct = self:GetAbility():GetSpecialValueFor("epicenter_slow")
		self.as_slow = self:GetAbility():GetSpecialValueFor("epicenter_slow_as")
	end
end

function modifier_mjz_sandking_epicenter_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function modifier_mjz_sandking_epicenter_slow:GetModifierMoveSpeedBonus_Percentage() return self.ms_slow_pct end
function modifier_mjz_sandking_epicenter_slow:GetModifierAttackSpeedBonus_Constant() return self.as_slow end



-----------------------------------------------------------------------------------------

-- 是否学习了指定天赋技能
function HasTalent(unit, talentName)
	if unit:HasAbility(talentName) then
		if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end
	return false
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
	local base = ability:GetSpecialValueFor(value)
	local talentName
	local kv = ability:GetAbilityKeyValues()
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
				end
			end
		end
	end
	if talentName then 
		local talent = ability:GetCaster():FindAbilityByName(talentName)
		if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
	end
	return base
end

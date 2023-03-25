LinkLuaModifier("modifier_mjz_sandking_epicenter","modifiers/hero_sand_king/modifier_mjz_sandking_epicenter.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_sandking_epicenter_shard","abilities/hero_sand_king/mjz_sandking_epicenter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_sandking_epicenter_slow","modifiers/hero_sand_king/modifier_mjz_sandking_epicenter.lua", LUA_MODIFIER_MOTION_NONE)

mjz_sandking_epicenter = class({})
local ability_class = mjz_sandking_epicenter
function mjz_sandking_epicenter:GetIntrinsicModifierName()
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		return "modifier_mjz_sandking_epicenter_shard"
	end
	return
end
function ability_class:OnAbilityPhaseStart()
	if IsServer() then
		local caster = self:GetCaster()
		local p_name = "particles/units/heroes/hero_sandking/sandking_epicenter_tell.vpcf"
		self.nPreviewFX = ParticleManager:CreateParticle(p_name, PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(self.nPreviewFX, 0, caster, PATTACH_POINT_FOLLOW, "attach_tail", caster:GetOrigin(), true)
		EmitSoundOn("Ability.SandKing_Epicenter.spell", caster)
		self:OnUpgrade()
	end
	return true
end
function ability_class:OnAbilityPhaseInterrupted()
	if IsServer() then
		StopSoundOn("Ability.SandKing_Epicenter.spell", self:GetCaster())
		ParticleManager:DestroyParticle(self.nPreviewFX, false)
	end
end
function ability_class:GetChannelAnimation() return ACT_DOTA_CAST_ABILITY_4 end
function ability_class:GetPlaybackRateOverride() return 1 end
function ability_class:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		ParticleManager:DestroyParticle(self.nPreviewFX, false)
		caster:AddNewModifier(caster, self, "modifier_mjz_sandking_epicenter", {})
		EmitSoundOn("Ability.SandKing_Epicenter.spell", caster)
	end
end


---------------------
-- Epicenter Shard --
---------------------
modifier_mjz_sandking_epicenter_shard = class({})
function modifier_mjz_sandking_epicenter_shard:IsHidden() return true end
function modifier_mjz_sandking_epicenter_shard:IsPurgable() return false end
function modifier_mjz_sandking_epicenter_shard:OnCreated()
	if IsServer() then
		if self:GetAbility() then
			local tick_rate = self:GetAbility():GetSpecialValueFor("epicenter_shard_interval")
			if _G._challenge_bosss > 1 then
				tick_rate = tick_rate / _G._challenge_bosss
			end	
			self:StartIntervalThink(tick_rate)
		end
	end	
end
local challenge_update = true
function modifier_mjz_sandking_epicenter_shard:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		if not caster:IsAlive() then return end
		if caster:IsIllusion() then return end
		local radius = ability:GetSpecialValueFor("epicenter_radius_max")
		local epicenter_damage = ability:GetSpecialValueFor("epicenter_damage") + ability:GetSpecialValueFor("epicenter_shard_dmg_inc")
		local str_multiplier = ability:GetSpecialValueFor("str_multiplier") + ability:GetSpecialValueFor("epicenter_shard_str_dmg_inc") + talent_value(caster, "special_bonus_unique_mjz_sandking_epicenter_strength")
		local slow_duration = ability:GetSpecialValueFor("epicenter_slow_duration")

		local damage = epicenter_damage + caster:GetStrength() * str_multiplier
		if _G._challenge_bosss > 0 then
			for i = 1, _G._challenge_bosss do
				damage = math.floor(damage * 1.2)
			end	
		end
		local randomSeed = math.random(1, 100)
		if randomSeed <= _G._effect_rate then		
			local particle_epicenter_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_epicenter.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle_epicenter_fx, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle_epicenter_fx, 1, Vector(radius, radius, 1))
			ParticleManager:DestroyParticle(particle_epicenter_fx, false)
			ParticleManager:ReleaseParticleIndex(particle_epicenter_fx)
		end

		local enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

		for _, enemy in pairs(enemy_list) do
			local damageTable = {
				victim = enemy,
				attacker = caster,
				damage = damage,
				damage_type = ability:GetAbilityDamageType(),
				ability = ability,
			}
			ApplyDamage(damageTable)
			enemy:AddNewModifier(caster, ability, "modifier_mjz_sandking_epicenter_slow", {duration = slow_duration})
		end
		EmitSoundOn("Hero_Sandking.EpiPulse", self:GetParent())
		if _G._challenge_bosss > 0 and challenge_update then
			self:OnCreated()
			challenge_update = false
		end
	end	
end



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
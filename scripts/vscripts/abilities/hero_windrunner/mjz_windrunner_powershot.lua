
local THIS_LUA = "abilities/hero_windrunner/mjz_windrunner_powershot.lua"
local MODIFIER_DEBUFF_NAME = 'modifier_mjz_windrunner_powershot_debuff' 

LinkLuaModifier(MODIFIER_DEBUFF_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)


mjz_windrunner_powershot = class({})
local ability_class = mjz_windrunner_powershot

function ability_class:GetChannelAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end

function ability_class:GetChannelTime()
	return self:GetSpecialValueFor("channel_time")
end

function ability_class:OnChannelThink(flInterval)
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()
		local attack_damage = GetTalentSpecialValueFor(ability, "attack_damage")
		local total_damage = caster:GetAverageTrueAttackDamage(caster) * (attack_damage / 100)
		self.damage = self.damage + total_damage / self:GetChannelTime() * flInterval
	end
end

function ability_class:OnChannelFinish(bInterrupted)
	if IsServer() then
		local caster = self:GetCaster()

		ParticleManager:DestroyParticle(self.nfx, false)
		ParticleManager:ReleaseParticleIndex(self.nfx)

		StopSoundOn("Ability.PowershotPull", caster)
		EmitSoundOn("Ability.Powershot", caster)

		caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)

		local distance = self:GetSpecialValueFor("arrow_range") + caster:GetCastRangeBonus()
		local p_name = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf"
		self:FireLinearProjectile(p_name, 
			caster:GetForwardVector() * self:GetSpecialValueFor("arrow_speed"), distance, self:GetSpecialValueFor("arrow_width"), 
			{ExtraData={ damage = self.damage }}, false, true, self:GetSpecialValueFor("vision_radius"))
	end
end


if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local pos = self:GetCursorPosition()
		local direction = CalculateDirection(pos, caster:GetAbsOrigin())
		self.damage = 0

		EmitSoundOn("Ability.PowershotPull", caster)
		self.nfx = ParticleManager:CreateParticle("particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_channel_ti6.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(self.nfx, 0, caster, PATTACH_POINT_FOLLOW, "bow_mid1", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(self.nfx, 1, caster:GetAbsOrigin())
					ParticleManager:SetParticleControlForward(self.nfx, 1, direction)

	end
end

function ability_class:OnProjectileHit(hTarget, vLocation)
	if not IsServer() then return end
	local ability = self
	local caster = self:GetCaster()

	if hTarget then --and not hTarget:TriggerSpellAbsorb( self )
		EmitSoundOn("Ability.PowershotDamage", hTarget)

		local debuff_duration = ability:GetSpecialValueFor("debuff_duration")
		hTarget:AddNewModifier(caster, ability, "modifier_mjz_windrunner_powershot_debuff", {duration = debuff_duration})

		local damage = self.damage
		ApplyDamage({
			victim = hTarget, attacker = caster, 
			ability = ability, damage_type = ability:GetAbilityDamageType(), 
			damage = damage, damage_flags = DOTA_DAMAGE_FLAG_NONE
		})

		-- 伤害降低
		-- self.damage = self.damage * (100 - self:GetSpecialValueFor("damage_reduction")) / 100

		--OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, OVERHEAD_ALERT_DAMAGE, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, OVERHEAD_ALERT_MANA_LOSS
		SendOverheadEventMessage(caster:GetPlayerOwner(), OVERHEAD_ALERT_DAMAGE, hTarget, damage, caster:GetPlayerOwner())

	else
		AddFOWViewer(caster:GetTeam(), vLocation, ability:GetSpecialValueFor("vision_radius"), ability:GetSpecialValueFor("vision_duration"), true)
	end
end

function ability_class:OnProjectileThink(vLocation)
	if not IsServer() then return end
	GridNav:DestroyTreesAroundPoint(vLocation, self:GetSpecialValueFor("arrow_width"), true)
end


function ability_class:FireLinearProjectile(FX, velocity, distance, width, data, bDelete, bVision, vision)
	local internalData = data or {}
	local delete = false
	if bDelete then delete = bDelete end
	local provideVision = true
	if bVision then provideVision = bVision end
	local info = {
		EffectName = FX,
		Ability = self,
		vSpawnOrigin = internalData.origin or self:GetCaster():GetAbsOrigin(), 
		fStartRadius = width,
		fEndRadius = internalData.width_end or width,
		vVelocity = velocity,
		fDistance = distance or 1000,
		Source = internalData.source or self:GetCaster(),
		iUnitTargetTeam = internalData.team or self:GetAbilityTargetTeam(),
		iUnitTargetType = internalData.type or self:GetAbilityTargetType(),
		iUnitTargetFlags = internalData.type or self:GetAbilityTargetFlags(),
		iSourceAttachment = internalData.attach or DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		bDeleteOnHit = delete,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bProvidesVision = provideVision,
		iVisionRadius = vision or 100,
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		ExtraData = internalData.extraData
	}
	local projectile = ProjectileManager:CreateLinearProjectile( info )
	return projectile
end




---------------------------------------------------------------------------------------

modifier_mjz_windrunner_powershot_debuff = class({})
local modifier_debuff = modifier_mjz_windrunner_powershot_debuff

function modifier_debuff:IsHidden() return false end
function modifier_debuff:IsPurgable() return true end

function modifier_debuff:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	} 
end

function modifier_debuff:GetModifierIncomingDamage_Percentage(  )
	return self:GetAbility():GetSpecialValueFor("debuff_incoming_damage")
end


-----------------------------------------------------------------------------------------

function CalculateDirection(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local direction = (pos1 - pos2):Normalized()
	direction.z = 0
	return direction
end


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

local THIS_LUA = "abilities/hero_death_prophet/mjz_death_prophet_carrion_swarm.lua"

local MODIFIER_IMMORTAL_SHOULDERS_NAME = 'modifier_mjz_death_prophet_carrion_swarm_immortal_acherontia_dress'
local MODEL_IMMORTAL_SHOULDERS_NAME = 'models/items/death_prophet/acherontia/acherontia_dress.vmdl'

LinkLuaModifier(MODIFIER_IMMORTAL_SHOULDERS_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------------

mjz_death_prophet_carrion_swarm = class({})
local ability_class = mjz_death_prophet_carrion_swarm


function talent_value(caster, talent_name)
	local talent = caster:FindAbilityByName(talent_name)
	if talent and talent:GetLevel() > 0 then
		return talent:GetSpecialValueFor("value")
	end
	return 0
end

function ability_class:GetCooldown(level)
	local cd_talent = talent_value(self:GetCaster(), "special_bonus_unique_dp_carrion_swarm_cooldown")
	if cd_talent then
		return self.BaseClass.GetCooldown(self, level) - cd_talent
	else
		return self.BaseClass.GetCooldown(self, level)
	end
end
function ability_class:GetIntrinsicModifierName()
	if IsServer() then
        self:_CheckImmortal()
    end
	return nil
end

function ability_class:GetAbilityTextureName()
	
    if self:GetCaster():HasModifier(MODIFIER_IMMORTAL_SHOULDERS_NAME) then
        return "mjz_death_prophet_carrion_swarm_immortal"
    end
    return "mjz_death_prophet_carrion_swarm"
end

if IsServer() then
    function ability_class:_CheckImmortal()
        -- print('check immortal...')
        local ability = self
        local caster = self:GetCaster()
        if not caster:HasModifier(MODIFIER_IMMORTAL_SHOULDERS_NAME) then
            local has_immortal = FindWearables(caster, MODEL_IMMORTAL_SHOULDERS_NAME)
            if has_immortal then
                caster:AddNewModifier(caster, ability, MODIFIER_IMMORTAL_SHOULDERS_NAME, {})
            end
        end
	end
end

if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local position = self:GetCursorPosition()
		local direction = CalculateDirection( position, caster )
		local speed = GetTalentSpecialValueFor(ability, "speed")
		local distance = GetTalentSpecialValueFor(ability, "range")
		local width = GetTalentSpecialValueFor(ability, "start_radius")
		local endWidth = GetTalentSpecialValueFor(ability, "end_radius")

		caster:EmitSound("Hero_DeathProphet.CarrionSwarm")

		local p_name = "particles/units/heroes/hero_death_prophet/death_prophet_carrion_swarm.vpcf"
		FireLinearProjectile(ability, p_name, direction * speed, distance, width, {width_end = endWidth})

	end

	function ability_class:OnProjectileHit( target, position )
		if target then
			local ability = self
			local caster = self:GetCaster()
			local base_damage = GetTalentSpecialValueFor(ability, "base_damage")
			local int_damage_pct = GetTalentSpecialValueFor(ability, "int_damage_pct")

			local damage = base_damage + caster:GetIntellect(false) * (int_damage_pct / 100.0)
			DealDamage(ability, caster, target, damage )

			target:EmitSound("Hero_DeathProphet.CarrionSwarm.Damage")
		end
	end
end



---------------------------------------------------------------------------------------

modifier_mjz_death_prophet_carrion_swarm_immortal_acherontia_dress = class({})
function modifier_mjz_death_prophet_carrion_swarm_immortal_acherontia_dress:IsHidden() return true end
function modifier_mjz_death_prophet_carrion_swarm_immortal_acherontia_dress:IsPurgable() return false end

-----------------------------------------------------------------------------------------

function DealDamage(ability, attacker, victim, damage, data, spellText)
	--OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, OVERHEAD_ALERT_DAMAGE, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, OVERHEAD_ALERT_MANA_LOSS
	if ability:IsNull() or victim:IsNull() or attacker:IsNull() then return end
	local internalData = data or {}
	local damageType =  internalData.damage_type or ability:GetAbilityDamageType() or DAMAGE_TYPE_MAGICAL
	local damageFlags = internalData.damage_flags or DOTA_DAMAGE_FLAG_NONE
	local localdamage = damage or ability:GetAbilityDamage() or 0
	local spellText = spellText or 0
	local ability = ability or internalData.ability
	local returnDamage = ApplyDamage({victim = victim, attacker = attacker, ability = ability, damage_type = damageType, damage = localdamage, damage_flags = damageFlags})
	if spellText > 0 then
		SendOverheadEventMessage(attacker:GetPlayerOwner(),spellText,victim,returnDamage,attacker:GetPlayerOwner()) --Substract the starting health by the new health to get exact damage taken values.
	end
	return returnDamage
end

function CalculateDirection(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local direction = (pos1 - pos2):Normalized()
	direction.z = 0
	return direction
end

function FireLinearProjectile(ability, FX, velocity, distance, width, data, bDelete, bVision, vision)
	local internalData = data or {}
	local delete = false
	if bDelete then delete = bDelete end
	local provideVision = true
	if bVision then provideVision = bVision end
	local info = {
		EffectName = FX,
		Ability = ability,
		vSpawnOrigin = internalData.origin or ability:GetCaster():GetAbsOrigin(), 
		fStartRadius = width,
		fEndRadius = internalData.width_end or width,
		vVelocity = velocity,
		fDistance = distance or 1000,
		Source = internalData.source or ability:GetCaster(),
		iUnitTargetTeam = internalData.team or DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = internalData.type or DOTA_UNIT_TARGET_ALL,
		iUnitTargetFlags = internalData.type or DOTA_UNIT_TARGET_FLAG_NONE,
		bDeleteOnHit = delete,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bProvidesVision = provideVision,
		iVisionRadius = vision or 100,
		iVisionTeamNumber = ability:GetCaster():GetTeamNumber(),
		ExtraData = internalData.extraData
	}
	local projectile = ProjectileManager:CreateLinearProjectile( info )
	return projectile
end

function FindWearables( unit, wearable_model_name)
	local model = unit:FirstMoveChild()
	while model ~= nil do
		if model:GetClassname() == "dota_item_wearable" then
			local modelName = model:GetModelName()
			if modelName == wearable_model_name then
				return true
			end
		end
		model = model:NextMovePeer()
	end
	return false
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
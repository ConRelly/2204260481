
local THIS_LUA = "abilities/hero_rattletrap/mjz_rattletrap_rocket_flare.lua"
local MODIFIER_LUA = "modifiers/hero_rattletrap/modifier_mjz_rattletrap_rocket_flare.lua"
local MODIFER_INIT_NAME = 'modifier_mjz_rattletrap_rocket_flare'
local MODIFER_VISION_NAME = 'modifier_modifier_mjz_rattletrap_rocket_flare_vision'
local MODIFER_DUMMY_NAME = 'modifier_modifier_mjz_rattletrap_rocket_flare_dummy'

LinkLuaModifier(MODIFER_INIT_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFER_VISION_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFER_DUMMY_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)

local MODIFIER_IMMORTAL_SHOULDERS_NAME = 'modifier_mjz_rattletrap_immortal_paraflare_cannon'
local MODEL_IMMORTAL_SHOULDERS_NAME = 'models/items/rattletrap/paraflare_cannon/paraflare_cannon.vmdl'
LinkLuaModifier(MODIFIER_IMMORTAL_SHOULDERS_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)


local MODIFIER_DUMMY_THINKER = 'modifier_dummy_thinker_v1' 
LinkLuaModifier(MODIFIER_DUMMY_THINKER, 'modifiers/modifier_dummy_thinker_v1.lua', LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------------

mjz_rattletrap_rocket_flare = class({})
local ability_class = mjz_rattletrap_rocket_flare

function ability_class:GetAOERadius()
    return self:GetSpecialValueFor('radius')
end

function ability_class:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor('cast_range')
end

function ability_class:GetIntrinsicModifierName()
	if IsServer() then
        CheckImmortal(self:GetCaster(), self)
    end
	return MODIFER_INIT_NAME
end

function ability_class:GetAbilityTextureName()
	local has_modifier = self:GetCaster():HasModifier(MODIFIER_IMMORTAL_SHOULDERS_NAME)
    if has_modifier then
        return 'mjz_rattletrap_rocket_flare_immortal'        
    end
    return 'mjz_rattletrap_rocket_flare'
end

if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local target_point = self:GetCursorPosition()
		local particle_speed = ability:GetSpecialValueFor('speed')
		
		local rocket_origin = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_rocket"))

		local pos = target_point
		local direction = (pos - caster:GetAbsOrigin()):Normalized()
		direction.z = 0
		local target = CreateModifierThinker(caster, ability, MODIFIER_DUMMY_THINKER, {duration = 60}, pos, caster:GetTeamNumber(), false)
		local p_name = "particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare.vpcf"
		local pfx = ParticleManager:CreateParticle(p_name, PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, rocket_origin)
		ParticleManager:SetParticleControl(pfx, 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 2, Vector(particle_speed, 0, 0))
		ParticleManager:SetParticleControlEnt(pfx, 7, caster, PATTACH_INVALID, nil, caster:GetAbsOrigin(), true)

		local rocket = CreateModifierThinker(caster, ability, MODIFIER_DUMMY_THINKER, {duration = 60.0}, pos, caster:GetTeamNumber(), false)
		local info = 
		{
			Target = target,
			Source = caster,
			Ability = ability,	
			EffectName = nil,
			iMoveSpeed = particle_speed,
			vSourceLoc = rocket_origin,
			bDrawsOnMinimap = false,
			bDodgeable = false,
			bIsAttack = false,
			bVisibleToEnemies = true,
			bReplaceExisting = false,
			flExpireTime = GameRules:GetGameTime() + 60,
			bProvidesVision = false,
			ExtraData = {pfx = pfx, rocket = rocket:entindex()}
		}
		ProjectileManager:CreateTrackingProjectile(info)

		caster:EmitSound("Hero_Rattletrap.Rocket_Flare.Fire")
		rocket:EmitSound("Hero_Rattletrap.Rocket_Flare.Travel")
	end

	function ability_class:OnProjectileThink_ExtraData(pos, keys)
		local ability = self
		local caster = self:GetCaster()
		local radius = ability:GetSpecialValueFor("radius")
		local duration = ability:GetSpecialValueFor("duration")

		local rocket = EntIndexToHScript(keys.rocket)
		rocket:SetAbsOrigin(pos)

		AddFOWViewer(caster:GetTeamNumber(), pos, radius, FrameTime(), false)

		local enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, 
			ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER, false)

		for i=1, #enemy_list do
			enemy_list[i]:AddNewModifier(caster, ability, MODIFER_VISION_NAME, {duration = duration})
		end
	end
	
	function ability_class:OnProjectileHit_ExtraData(target, pos, keys)
		local ability = self
		local caster = self:GetCaster()
		local radius = ability:GetSpecialValueFor("radius")
		local duration = ability:GetSpecialValueFor("duration")
		local damage = GetTalentSpecialValueFor(ability, 'damage')
		local true_sight = HasTalentSpecialValueFor(ability, 'true_sight')
		local rocket = EntIndexToHScript(keys.rocket)

		ParticleManager:DestroyParticle(keys.pfx, false)
		ParticleManager:ReleaseParticleIndex(keys.pfx)
		
		rocket:StopSound("Hero_Rattletrap.Rocket_Flare.Travel")
		rocket:EmitSound("Hero_Rattletrap.Rocket_Flare.Explode")
		rocket:ForceKill(false)

		local pfx_name = "particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare_illumination.vpcf"
		-- pfx_name = "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_illumination.vpcf"

		local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, pos)
		ParticleManager:SetParticleControl(pfx, 1, Vector(duration, 0, 0))
		ParticleManager:DestroyParticle(pfx, false)
		ParticleManager:ReleaseParticleIndex(pfx)

		AddFOWViewer(caster:GetTeamNumber(), pos, radius, duration, false)

		if true_sight then
			local dummy_name = 'npc_dota_invisible_vision_source' 	-- "npc_dummy_unit"
			local truesight = CreateUnitByName(dummy_name, pos, false, caster, caster, caster:GetTeamNumber())
			truesight:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
			-- truesight:AddNewModifier(caster, ability, "modifier_true_sight_aura", {duration = duration})
			truesight:AddNewModifier(caster, ability, "modifier_item_gem_of_true_sight", {duration = duration})
			truesight:AddNewModifier(caster, ability, MODIFER_DUMMY_NAME, {})
		end

		local enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, 
			ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER, false)

		for i=1, #enemy_list do
			ApplyDamage({
				attacker = caster, 
				victim = enemy_list[i], 
				damage = damage, 
				ability = ability, 
				damage_type = self:GetAbilityDamageType()
			})
		end
	end

end


---------------------------------------------------------------------------------------

modifier_mjz_rattletrap_immortal_paraflare_cannon = class({})
function modifier_mjz_rattletrap_immortal_paraflare_cannon:IsHidden() return true end
function modifier_mjz_rattletrap_immortal_paraflare_cannon:IsPurgable() return false end
function modifier_mjz_rattletrap_immortal_paraflare_cannon:RemoveOnDeath() return false end

function CheckImmortal(caster, ability)
	-- print('check immortal...')
	if not caster:HasModifier(MODIFIER_IMMORTAL_SHOULDERS_NAME) then
		local has_immortal = FindWearables(caster, MODEL_IMMORTAL_SHOULDERS_NAME)
		-- has_immortal = true
		if has_immortal then
			caster:AddNewModifier(caster, ability, MODIFIER_IMMORTAL_SHOULDERS_NAME, {})
		end
	end
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
    local bonusOperation
    local kv = ability:GetAbilityKeyValues()
    
    if kv.AbilityValues then
        local valueData = kv.AbilityValues[value]
        if type(valueData) == "table" then
            talentName = valueData.LinkedSpecialBonus
            bonusOperation = valueData.LinkedSpecialBonusOperation
        end
    end
    
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            local bonusValue = talent:GetSpecialValueFor("value")
            
            if bonusOperation then
                if bonusOperation == "SPECIAL_BONUS_ADD" or bonusOperation == "SPECIAL_BONUS_SUBTRACT" then
                    base = base + bonusValue -- For subtraction, bonusValue should already be negative
                elseif bonusOperation == "SPECIAL_BONUS_MULTIPLY" then
                    base = base * bonusValue
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_ADD" then
                    base = base * (1 + bonusValue / 100)
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_SUBTRACT" then
                    base = base * (1 - bonusValue / 100)
                end
            else
                -- Default behavior if no operation is specified
                base = base + bonusValue
            end
        end
    end
    
    return base
end


-- 是否学习了天赋技能
function HasTalentSpecialValueFor(ability, value)
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
		return talent and talent:GetLevel() > 0 
    end
    return false
end
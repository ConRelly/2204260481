
local THIS_LUA = "abilities/hero_viper/mjz_viper_nethertoxin.lua"
local MODIFIER_LUA = "modifiers/hero_viper/modifier_mjz_viper_nethertoxin.lua"
local MODIFER_INIT_NAME = 'modifier_mjz_viper_nethertoxin'
local MODIFER_THINKER_NAME = 'modifier_mjz_viper_nethertoxin_thinker'


LinkLuaModifier(MODIFER_INIT_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFER_THINKER_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)

local MODIFIER_IMMORTAL_SHOULDERS_NAME = 'modifier_mjz_viper_ti8_immortal_tail'
local MODEL_IMMORTAL_SHOULDERS_NAME = 'models/items/viper/viper_immortal_tail_ti8/viper_immortal_tail_ti8.vmdl'
LinkLuaModifier(MODIFIER_IMMORTAL_SHOULDERS_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)


local MODIFIER_DUMMY_THINKER = 'modifier_dummy_thinker_v1' 
LinkLuaModifier(MODIFIER_DUMMY_THINKER, 'modifiers/modifier_dummy_thinker_v1.lua', LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------------

mjz_viper_nethertoxin = class({})
local ability_class = mjz_viper_nethertoxin

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
        return 'mjz_viper_nethertoxin_immortal'        
    end
    return 'mjz_viper_nethertoxin'
end

if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local target_point = self:GetCursorPosition()
		local duration = ability:GetSpecialValueFor("duration")
		local projectile_speed = ability:GetSpecialValueFor('projectile_speed')
		local projectile_origin = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_hitloc"))

		local pos = target_point
		local direction = (pos - caster:GetAbsOrigin()):Normalized()
		direction.z = 0
		local dummy = CreateModifierThinker(caster, ability, MODIFIER_DUMMY_THINKER, {duration = 60}, pos, caster:GetTeamNumber(), false)

		local p_name = "particles/units/heroes/hero_viper/viper_nethertoxin_cast.vpcf"
		-- local fx = ParticleManager:CreateParticle(p_name, PATTACH_POINT_FOLLOW, caster)
		-- ParticleManager:SetParticleControlEnt(fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		-- ParticleManager:SetParticleControl(fx, 1, pos)
		-- ParticleManager:ReleaseParticleIndex(fx)

		caster:EmitSound("Hero_Viper.Nethertoxin.Cast")


		local projectile_name = "particles/units/heroes/hero_viper/viper_nethertoxin_proj.vpcf"
		-- projectile_name = 'particles/units/heroes/hero_viper/viper_base_attack.vpcf'
		projectile_name = p_name

		local info = 
		{
			Target = dummy,
			Source = caster,
			Ability = ability,	
			EffectName = projectile_name,
			iMoveSpeed = projectile_speed,
			vSourceLoc = caster:GetAbsOrigin(),
			bDrawsOnMinimap = false,
			bDodgeable = false,
			bIsAttack = false,
			bVisibleToEnemies = true,
			bReplaceExisting = false,
			flExpireTime = GameRules:GetGameTime() + 60,
			bProvidesVision = false,
			ExtraData = {pfx = pfx, dummy = dummy:entindex()}
		}
		ProjectileManager:CreateTrackingProjectile(info)

	end

	function ability_class:OnProjectileThink_ExtraData(pos, keys)
		local ability = self
		local caster = self:GetCaster()
		local radius = ability:GetSpecialValueFor("radius")
		local duration = ability:GetSpecialValueFor("duration")

	end
	
	function ability_class:OnProjectileHit_ExtraData(target, pos, keys)
		local ability = self
		local caster = self:GetCaster()
		local radius = ability:GetSpecialValueFor("radius")
		local duration = ability:GetSpecialValueFor("duration")

		local pfx = keys.pfx
		if pfx then
			ParticleManager:DestroyParticle(pfx, false)
			ParticleManager:ReleaseParticleIndex(pfx)
		end

		local dummy = EntIndexToHScript(keys.dummy)
		dummy:EmitSound("Hero_Viper.NetherToxin")

		local p_name = 'particles/units/heroes/hero_viper/viper_nethertoxin_proj_endcap.vpcf'
		local fx = ParticleManager:CreateParticle(p_name, PATTACH_POINT_FOLLOW, dummy)
		ParticleManager:SetParticleControl(fx, 1, pos)
		ParticleManager:ReleaseParticleIndex(fx)

		dummy:ForceKill(false)

		CreateModifierThinker(caster, ability, MODIFER_THINKER_NAME, {duration = duration}, pos, caster:GetTeamNumber(), false)
	end

end


---------------------------------------------------------------------------------------

modifier_mjz_viper_ti8_immortal_tail = class({})
function modifier_mjz_viper_ti8_immortal_tail:IsHidden() return true end
function modifier_mjz_viper_ti8_immortal_tail:IsPurgable() return false end
function modifier_mjz_viper_ti8_immortal_tail:RemoveOnDeath() return false end

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
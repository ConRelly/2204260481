LinkLuaModifier("modifier_mjz_skeleton_king_ghost","abilities/hero_skeleton_king/mjz_skeleton_king_ghost.lua", LUA_MODIFIER_MOTION_NONE)

mjz_skeleton_king_ghost = class({})
local ability_class = mjz_skeleton_king_ghost

function ability_class:OnSpellStart()
    if IsServer() then
        local ability = self
        local caster = self:GetCaster()
        local duration = ability:GetSpecialValueFor("duration")
        local scepter_radius = ability:GetSpecialValueFor("scepter_radius")
        local heroList = {}

        if self:GetCaster():HasScepter() then
            heroList = FindUnitsInRadius(
                caster:GetTeamNumber(),	-- int, your team number
                caster:GetOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                scepter_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
                DOTA_UNIT_TARGET_HERO,	-- int, type filter
                0,	-- int, flag filter
                0,	-- int, order filter
                false	-- bool, can grow cache
            )
        else
            table.insert( heroList, caster)
        end

        for _,hero in pairs(heroList) do
            hero:AddNewModifier(caster, ability, "modifier_mjz_skeleton_king_ghost", {duration = duration})
        end
		EmitSoundOn("Hero_SkeletonKing.Reincarnate", caster)
	end
end


-----------------------------------------------------------------------------------------
modifier_mjz_skeleton_king_ghost = class({})
local modifier_class = modifier_mjz_skeleton_king_ghost

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end
function modifier_class:IsBuff() return true end

function modifier_class:DeclareFunctions()
	local funcs = {
		-- MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,			-- 冷却时间减少			
		-- MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,		-- 技能增强
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,          -- 魔法消耗和损失降低
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE,							-- 设定模型大小
        
	}
	return funcs
end

function modifier_class:GetModifierModelScale( )
	return self:GetAbility():GetSpecialValueFor('model_scale')
end
function modifier_class:GetModifierPercentageManacost()
	return self:GetAbility():GetSpecialValueFor('manacost_reduction')       -- 60 80 100
end

function modifier_class:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor('incoming_damage_per')       -- -40 -50 -60
end

function modifier_class:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end
-- function modifier_class:GetEffectName(params)   --GetHeroEffectName
--     return "particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf"
-- end

function modifier_class:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

-- function modifier_class:GetEffectName()
-- 	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
-- end



function modifier_class:OnCreated(table)
    local target = self:GetParent()
    local p = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    -- ParticleManager:ReleaseParticleIndex(p)
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
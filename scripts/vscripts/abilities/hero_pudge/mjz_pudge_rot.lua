
local THIS_LUA = "abilities/hero_pudge/mjz_pudge_rot.lua"
local MODIFIER_LUA = "modifiers/hero_pudge/modifier_mjz_pudge_rot.lua"

LinkLuaModifier( "modifier_mjz_pudge_rot", MODIFIER_LUA,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mjz_pudge_rot_effect", MODIFIER_LUA,LUA_MODIFIER_MOTION_NONE )

local MODIFIER_IMMORTAL_SHOULDERS_NAME = 'modifier_mjz_pudge_rot_immortal_ti7_arm'
local MODEL_IMMORTAL_SHOULDERS_NAME = 'models/items/pudge/immortal_arm/immortal_arm.vmdl'
LinkLuaModifier(MODIFIER_IMMORTAL_SHOULDERS_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------------

mjz_pudge_rot = class({})
local ability_class = mjz_pudge_rot

function ability_class:GetIntrinsicModifierName()
	if IsServer() then
        self:_CheckImmortal()
    end
	return nil
end

function ability_class:GetAbilityTextureName()
    if self:GetCaster():HasModifier(MODIFIER_IMMORTAL_SHOULDERS_NAME) then
        return "mjz_pudge_rot_immortal_ti7"
    end
    return "mjz_pudge_rot"
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

function ability_class:OnToggle()
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()

		if ability:GetToggleState() then
			caster:AddNewModifier( caster, ability, "modifier_mjz_pudge_rot", nil )
	
			if not caster:IsChanneling() then
				caster:StartGesture( ACT_DOTA_CAST_ABILITY_ROT )
				-- caster:StartGesture( ACT_DOTA_CAST_ABILITY_2 )
			end
		else
			caster:RemoveModifierByName("modifier_mjz_pudge_rot")
		end
	end
end

---------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------

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


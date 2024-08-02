LinkLuaModifier("modifier_mjz_obsidian_destroyer_essence_aura","abilities/hero_obsidian_destroyer/mjz_obsidian_destroyer_essence_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_essence_aura_effect","abilities/hero_obsidian_destroyer/mjz_obsidian_destroyer_essence_aura.lua", LUA_MODIFIER_MOTION_NONE)

mjz_obsidian_destroyer_essence_aura = class({})
local ability_class = mjz_obsidian_destroyer_essence_aura

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_obsidian_destroyer_essence_aura"
end

-----------------------------------------------------------------------------------------

modifier_mjz_obsidian_destroyer_essence_aura = class({})
local modifier_class = modifier_mjz_obsidian_destroyer_essence_aura

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_BONUS,
	}
	return funcs
end
function modifier_class:GetModifierManaBonus( )
	return self:GetAbility():GetSpecialValueFor('bonus_mana')
end

-----------------------------------------------------------------------------------------

function modifier_class:IsAura() return true end

function modifier_class:GetModifierAura()
	return "modifier_mjz_essence_aura_effect"
end

function modifier_class:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_class:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_class:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end

function modifier_class:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor( "radius" )
end

-----------------------------------------------------------------------------------------

modifier_mjz_essence_aura_effect = class({})
local modifier_effect = modifier_mjz_essence_aura_effect

function modifier_effect:IsHidden() return false end
function modifier_effect:IsPurgable() return false end

if IsServer() then
	function modifier_effect:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		}
	end
	function modifier_effect:OnAbilityExecuted(params)
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		if caster:PassivesDisabled() then return nil end

		if params.unit == self:GetParent() then
			local ability_used = params.ability
			if ability then
				if ability_used ~= nil and not ability_used:IsItem() then
					local restore_chance = ability:GetSpecialValueFor("restore_chance")
					local random_number = math.random( 1, 100 )
					if random_number <= restore_chance then
						RestoreMana(ability, parent)
					end
				end
			end	
		end
	end	

	function RestoreMana(ability, target )
		local restore_amount = ability:GetSpecialValueFor("restore_amount")
		local max_mana = target:GetMaxMana() * (restore_amount / 100.0) 
		local new_mana = target:GetMana() + max_mana

		--target:GiveMana(max_mana)
		if new_mana > target:GetMaxMana() then
			target:SetMana(target:GetMaxMana())
		else
			target:SetMana(new_mana)
		end

		local p_name = 'particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_essence_effect.vpcf'
		local p_index = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(p_index)
	
		EmitSoundOn("Hero_ObsidianDestroyer.EssenceAura", target)
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


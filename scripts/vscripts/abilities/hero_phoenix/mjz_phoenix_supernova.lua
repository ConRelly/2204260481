
LinkLuaModifier("modifier_mjz_phoenix_supernova_caster","modifiers/hero_phoenix/modifier_mjz_phoenix_supernova_caster.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_phoenix_supernova_egg","modifiers/hero_phoenix/modifier_mjz_phoenix_supernova_egg.lua", LUA_MODIFIER_MOTION_NONE)

local MODIFIER_CASTER_NAME = "modifier_mjz_phoenix_supernova_caster"

mjz_phoenix_supernova = class({})
local ability_class = mjz_phoenix_supernova

function ability_class:GetBehavior()
	if self:GetCaster():HasScepter() then
		-- return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
	return self.BaseClass.GetBehavior( self )
end


function ability_class:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("aoe_scepter")
	end
	return 0
end



function ability_class:OnSpellStart( )
	if not IsServer() then return false end
	local ability = self
	local caster = self:GetCaster()

	self:SpellTarget(caster)

	if caster:HasScepter() then
		-- local target = self:GetCursorTarget()
		-- if target ~= caster then
		-- 	self:SpellTarget(target)
		-- end

		local modifier_stats = "modifier_item_imba_ultimate_scepter_synth_stats"
		local count = 1

		local ms = caster:FindAllModifiersByName(modifier_stats)
		if #ms > 1 then
			count = #ms
		end

		local aoe_radius = ability:GetSpecialValueFor("aoe_scepter")
		local point = self:GetCursorPosition()
        local frinds = FindUnitsInRadius(caster:GetTeam(), point, nil, aoe_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
		
		for _,unit in pairs(frinds) do
			if count > 0 and unit:IsRealHero() then
				count = count - 1
				self:SpellTarget(unit)
			end
		end

	end

end

function ability_class:SpellTarget( target )
	local ability = self
	local caster = self:GetCaster()
	local duration = ability:GetDuration()
	local location = target:GetAbsOrigin()
	local max_attacks = GetTalentSpecialValueFor(ability, "max_attacks")
	local max_attacks_scepter = GetTalentSpecialValueFor(ability, "max_attacks_scepter")

	if caster:HasScepter() then
		max_attacks = max_attacks_scepter
	end
	if caster:HasModifier("modifier_super_scepter") then
		max_attacks = max_attacks * ability:GetSpecialValueFor("ss_attacks_mult")
		duration = duration * ability:GetSpecialValueFor("ss_duration_mult")
	end	

	target:EmitSound( "Hero_Phoenix.SuperNova.Cast" )
	target:AddNewModifier(caster, ability, MODIFIER_CASTER_NAME, {duration = duration})

	local egg = CreateUnitByName("npc_dota_phoenix_sun", location, false, target, target:GetOwner(), target:GetTeamNumber())
	egg:AddNewModifier(caster, ability, "modifier_kill", {duration = duration })
	-- egg:AddNewModifier(caster, ability, "modifier_invulnerable",{duration = duration + extend_duration })
	egg:AddNewModifier(caster, ability, "modifier_mjz_phoenix_supernova_egg", {duration = duration +0.1 })

	egg.max_attack = max_attacks
	egg.current_attack = 0
	
	local egg_playback_rate = 6 / (duration )
	egg:StartGestureWithPlaybackRate(ACT_DOTA_IDLE , egg_playback_rate)

	-- target._supernova_egg = egg
	egg._supernova_target = target
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
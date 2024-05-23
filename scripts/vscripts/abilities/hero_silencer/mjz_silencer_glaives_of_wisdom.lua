LinkLuaModifier("modifier_generic_orb_effect_lua", "modifiers/hero_silencer/modifier_generic_orb_effect_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_silencer_glaives_of_wisdom_heap", "modifiers/hero_silencer/modifier_mjz_silencer_glaives_of_wisdom_heap.lua", LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_mjz_silencer_ti8_immortal_weapon", "abilities/hero_silencer/mjz_silencer_glaives_of_wisdom.lua", LUA_MODIFIER_MOTION_NONE)

mjz_silencer_glaives_of_wisdom = class({})
local ability_class = mjz_silencer_glaives_of_wisdom

function ability_class:IsRefreshable() return true end
function ability_class:IsStealable() return false end	-- 是否可以被法术偷取。
function ability_class:AllowIllusionDuplicate() return true end
function ability_class:GetAbilityTextureName(brokenAPI)
	-- return self.BaseClass.GetAbilityTextureName(self)
	-- local ABILITY_TEXTURE_BASE = 'mjz_silencer_glaives_of_wisdom'
	local ABILITY_TEXTURE_IMMORTAl = 'mjz_silencer_glaives_of_wisdom_immortal'
	return ABILITY_TEXTURE_IMMORTAl
end


--------------------------------------------------------------------------------
-- Orb Effects

function ability_class:GetIntrinsicModifierName()
    return "modifier_generic_orb_effect_lua"
end

function ability_class:GetProjectileName()
	-- return "particles/units/heroes/hero_silencer/silencer_base_attack.vpcf"
	-- return "particles/econ/items/silencer/silencer_ti8/silencer_ti8_attack.vpcf"
	-- 如果有不朽武器饰品，系统会自动更换粒子效果
	local ORB_PROJECTILE_BASE  = 'particles/units/heroes/hero_silencer/silencer_glaives_of_wisdom.vpcf'
	-- local ORB_PROJECTILE_IMMORTAl = "particles/econ/items/silencer/silencer_ti8/silencer_ti8_glaive.vpcf"
	return ORB_PROJECTILE_BASE
end

function ability_class:OnOrbFire( params )
	local ability = self
	local caster = self:GetCaster()
	local target = params.target

	EmitSoundOn("Hero_Silencer.GlaivesOfWisdom", caster)
end

function ability_class:OnOrbImpact( params )
	if not IsServer() then return nil end
	local ability = self
	local caster = self:GetCaster()
	local target = params.target

	local int_caster = caster:GetIntellect(false)
	local int_damage_pct = GetTalentSpecialValueFor(ability, "intellect_damage_pct")

	local damage = int_caster * (int_damage_pct / 100.0)
	
	if caster:HasScepter() then
		local crit_chance = ability:GetSpecialValueFor('crit_chance_scepter')
		local crit_multiplier = ability:GetSpecialValueFor('crit_multiplier_scepter')
		
		if RollPercentage(crit_chance) then
			if HasSuperScepter(caster) then
				crit_multiplier = ability:GetSpecialValueFor('crit_multiplier_super_scepter')
			end
			damage = damage * (crit_multiplier / 100.0)

			create_popup({
				target = target,
				value = damage,
				color = Vector(216, 174, 83),	-- 纯粹
				type = "crit",
				pos = 4
			})
		end
	end
	
	local damage_table = {
		attacker = caster,
		ability = ability,
		victim = target,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
	}
	ApplyDamage(damage_table)


	EmitSoundOn("Hero_Silencer.GlaivesOfWisdom.Damage", target)
end

--------------------------------------------------------------------------------

function ability_class:OnAbilityPhaseStart()
	if IsServer() then
		local target = self:GetCursorTarget()
		if target then
			-- self.overrideAutocast = true
			-- self:GetCaster():MoveToTargetToAttack(target)
		end
	end
end

if IsServer() then
	function ability_class:OnUpgrade()
		local ability = self
		local caster = self:GetCaster()

		local modifier_heap_name = "modifier_mjz_silencer_glaives_of_wisdom_heap"
		if not caster:HasModifier(modifier_heap_name) then
			caster:AddNewModifier(caster, ability, modifier_heap_name, {})
		end
	end

end

-----------------------------------------------------------------------------------------

--[[
	modifier_mjz_silencer_ti8_immortal_weapon = class({})
	function modifier_mjz_silencer_ti8_immortal_weapon:IsHidden() return true end
	function modifier_mjz_silencer_ti8_immortal_weapon:IsPurgable() return false end
	function modifier_mjz_silencer_ti8_immortal_weapon:RemoveOnDeath() return false end
]]


-----------------------------------------------------------------------------------------

--[[
    A quick function to create popups.
    Example:
    create_popup({
        target = target,
        value = value,
        color = Vector(255, 20, 147),
        type = "spell_custom"
	}) 
	伤害类型的颜色：
		物理：Vector(174, 47, 40)
		魔法：Vector(91, 147, 209)
		纯粹：Vector(216, 174, 83)
]]
function create_popup(data)
    local target = data.target
    local value = math.floor(data.value)

    local type = data.type or "miss"
    local color = data.color or Vector(255, 255, 255)
    local duration = data.duration or 1.0

    local size = string.len(value)

    local pre = data.pre or nil
    if pre ~= nil then
        size = size + 1
    end

    local pos = data.pos or nil
    if pos ~= nil then
        size = size + 1
    end

    local particle_path = "particles/msg_fx/msg_" .. type .. ".vpcf"
    local particle = ParticleManager:CreateParticle(particle_path, PATTACH_OVERHEAD_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 1, Vector(pre, value, pos))
    ParticleManager:SetParticleControl(particle, 2, Vector(duration, size, 0))
    ParticleManager:SetParticleControl(particle, 3, color)
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


function HasSuperScepter(npc)
    local modifier_super_scepter = "modifier_item_imba_ultimate_scepter_synth_stats"
    if npc:HasModifier(modifier_super_scepter) and npc:FindModifierByName(modifier_super_scepter):GetStackCount() > 2 then
		return true 
	end	  
    return false
end
LinkLuaModifier("modifier_mjz_ember_spirit_flame_guard", "abilities/hero_ember_spirit/mjz_ember_spirit_flame_guard.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_ember_spirit_flame_guard_damage", "abilities/hero_ember_spirit/mjz_ember_spirit_flame_guard.lua", LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------------
mjz_ember_spirit_flame_guard = class({})
function mjz_ember_spirit_flame_guard:GetAOERadius() return self:GetSpecialValueFor("radius") end
if IsServer() then
	function mjz_ember_spirit_flame_guard:OnSpellStart()
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")

		if caster:HasModifier("modifier_mjz_ember_spirit_flame_guard") then
			caster:RemoveModifierByName("modifier_mjz_ember_spirit_flame_guard")
		end
		caster:AddNewModifier(caster, self, "modifier_mjz_ember_spirit_flame_guard", {duration = duration})

		caster:EmitSound("Hero_EmberSpirit.FlameGuard.Cast")
	end
end

-----------------------------------------------------------------------------------------
modifier_mjz_ember_spirit_flame_guard = class({})
function modifier_mjz_ember_spirit_flame_guard:IsHidden() return false end
function modifier_mjz_ember_spirit_flame_guard:IsPurgable() return true end
function modifier_mjz_ember_spirit_flame_guard:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf"
end
function modifier_mjz_ember_spirit_flame_guard:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_mjz_ember_spirit_flame_guard:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_mjz_ember_spirit_flame_guard:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("damage_reduction_pct")
end
if IsServer() then
	function modifier_mjz_ember_spirit_flame_guard:OnCreated(table)
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local tick_interval = ability:GetSpecialValueFor("tick_interval")
		local bonus_damage_pct = GetTalentSpecialValueFor(ability, "bonus_damage_pct")

		EmitSoundOn("Hero_EmberSpirit.FlameGuard.Loop", parent)

		parent:AddNewModifier(parent, ability, "modifier_mjz_ember_spirit_flame_guard_damage", {})
		parent:SetModifierStackCount("modifier_mjz_ember_spirit_flame_guard_damage", parent, bonus_damage_pct)

		self:StartIntervalThink(tick_interval)
	end

	function modifier_mjz_ember_spirit_flame_guard:OnIntervalThink()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local radius = ability:GetSpecialValueFor("radius")
		local tick_interval = ability:GetSpecialValueFor("tick_interval")
		local damage_per_second = GetTalentSpecialValueFor(ability, "damage_per_second")
		local bonus_dmg = talent_value(parent, "special_bonus_unique_mjz_ember_spirit_flame_guard_bonus_attack") * 0.01
		if bonus_dmg > 0 then
			--bonus dmg get multiplayed with parent tottal attack dmg
			bonus_dmg = bonus_dmg * parent:GetAverageTrueAttackDamage(parent)
			damage_per_second = damage_per_second + bonus_dmg
		end
		local damage = damage_per_second * tick_interval

		local enemy_list = FindUnitsInRadius(
			parent:GetTeam(),
			parent:GetAbsOrigin(),
			nil,
			radius,
			ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),
			ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER,
			false
		)

		for _,enemy in pairs(enemy_list) do
			ApplyDamage({
				attacker = parent,
				victim = enemy,
				damage = damage,
				damage_type = ability:GetAbilityDamageType(),
				ability = ability,
			})
		end
	end

	function modifier_mjz_ember_spirit_flame_guard:OnDestroy()
		local parent = self:GetParent()

		parent:RemoveModifierByName("modifier_mjz_ember_spirit_flame_guard_damage")
		StopSoundEvent("Hero_EmberSpirit.FlameGuard.Loop", parent)
	end
end

-----------------------------------------------------------------------------------------
modifier_mjz_ember_spirit_flame_guard_damage = class({})
function modifier_mjz_ember_spirit_flame_guard_damage:IsHidden() return true end
function modifier_mjz_ember_spirit_flame_guard_damage:IsPurgable() return false end
function modifier_mjz_ember_spirit_flame_guard_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end
function modifier_mjz_ember_spirit_flame_guard_damage:GetModifierDamageOutgoing_Percentage() return self:GetStackCount() end

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
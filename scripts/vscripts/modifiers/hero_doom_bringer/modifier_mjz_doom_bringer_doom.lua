LinkLuaModifier("modifier_mjz_doom_bringer_doom_mana","modifiers/hero_doom_bringer/modifier_mjz_doom_bringer_doom.lua", LUA_MODIFIER_MOTION_NONE)


-----------------------------------------------------------------------------------------

modifier_mjz_doom_bringer_doom_caster = class({})
local modifier_caster = modifier_mjz_doom_bringer_doom_caster

function modifier_caster:IsHidden() return false end
function modifier_caster:IsPurgable() return false end

function modifier_caster:GetEffectName()
	return  "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf"
end
function modifier_caster:GetEffectAttachType() 
	return PATTACH_ABSORIGIN_FOLLOW 
end

if IsServer() then

	function modifier_caster:OnCreated()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local tick_interval = ability:GetSpecialValueFor('tick_interval')

		EmitSoundOn("Hero_DoomBringer.Doom", caster)

		if caster:HasScepter() then
			caster:AddNewModifier(caster, ability, 'modifier_mjz_doom_bringer_doom_mana', {})
		end

		self:StartIntervalThink(tick_interval)
	end

	function modifier_caster:OnIntervalThink()
		if self and not self:GetAbility() then
			if not self:IsNull() then
				self:Destroy()
			end
			return	
		end			
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local tick_interval = ability:GetSpecialValueFor('tick_interval')
		local radius = parent:Script_GetAttackRange() + 150 --ability:GetSpecialValueFor('radius')

		local damage = GetTalentSpecialValueFor(ability, 'damage')
		damage = damage * tick_interval

		local enemy_list = FindUnitsInRadius(
			parent:GetTeam(), 
			parent:GetAbsOrigin(), 
			nil, radius, 
			ability:GetAbilityTargetTeam(), 
			ability:GetAbilityTargetType(), 
			ability:GetAbilityTargetFlags(), 
			FIND_ANY_ORDER, false
		)

		for _,enemy in pairs(enemy_list) do
			local postDmg = ApplyDamage({
				ability = ability,
				victim = enemy, 
				attacker = caster, 
				damage = damage, 
				damage_type = ability:GetAbilityDamageType()
			})

			-- self:_Popup(enemy, postDmg)
		end
	end

	function modifier_caster:OnDestroy()
		local caster = self:GetCaster()
		StopSoundEvent("Hero_DoomBringer.Doom", caster)

		if caster:HasModifier('modifier_mjz_doom_bringer_doom_mana') then
			caster:RemoveModifierByName('modifier_mjz_doom_bringer_doom_mana')
		end
	end

	function modifier_caster:_Popup(enemy, postDmg )
		local caster = self:GetCaster()
		-- SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, enemy, postDmg, caster)
		create_popup_by_damage_type({
			target = enemy,
			value = postDmg,
			color = Vector(0, 0, 0),
			type = "damage"
		}, ability)
	end
end

------------------------------------------------

function modifier_caster:IsAura() return true end
function modifier_caster:GetAuraRadius() if self:GetCaster() then return self:GetCaster():Script_GetAttackRange() + 250 end end
function modifier_caster:GetModifierAura() return "modifier_mjz_doom_bringer_doom_debuff" end
function modifier_caster:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_caster:GetAuraEntityReject(target) return self:GetParent():IsIllusion() end
function modifier_caster:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_caster:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE end
function modifier_caster:GetAuraDuration() return 0.5 end

---------------------------------------------------------------------------------------

modifier_mjz_doom_bringer_doom_mana = class({})
local modifier_mana = modifier_mjz_doom_bringer_doom_mana

function modifier_mana:IsHidden() return true end
function modifier_mana:IsPurgable() return false end

function modifier_mana:OnCreated()
	self.tick_interval = self:GetAbility():GetSpecialValueFor("tick_interval")
	self:StartIntervalThink(self.tick_interval)
end


function modifier_mana:OnIntervalThink()
	if IsServer() then
		if self and not self:GetAbility() then
			if not self:IsNull() then
				self:Destroy()
			end
			return	
		end	
        local ability = self:GetAbility()
        local parent = self:GetParent()

		-- local mana_cost = ability:GetManaCost(ability:GetLevel())
		local mana_cost = ability:GetSpecialValueFor("mana_second_scepter") * self.tick_interval
        if parent:GetMana() >= mana_cost then
            parent:SpendMana(mana_cost, ability)
        else
            ability:ToggleAbility()
        end
    end
end


-----------------------------------------------------------------------------------------

modifier_mjz_doom_bringer_doom_debuff = class({})
local modifier_debuff = modifier_mjz_doom_bringer_doom_debuff

function modifier_debuff:IsHidden() return false end
function modifier_debuff:IsPurgable() return true end
function modifier_debuff:IsDebuff() return true end

function modifier_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_doom.vpcf"
end
function modifier_debuff:StatusEffectPriority()
	return 10
end

function modifier_debuff:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf"
end
function modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_debuff:GetModifierMagicalResistanceBonus()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor('debuff_magical_resistance')
end
function modifier_debuff:GetModifierAttackSpeedBonus_Constant()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor('debuff_attack_speed')
end
function modifier_debuff:GetModifierMoveSpeedBonus_Percentage()
	if not self:GetAbility() then return end
	return self:GetAbility():GetSpecialValueFor('debuff_move_speed')
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
	spell_custom: 
		block | crit | damage | evade | gold | heal | mana_add | mana_loss | miss | poison | spell | xp
	Color:	
		red 	={255,0,0},
		orange	={255,127,0},
		yellow	={255,255,0},
		green 	={0,255,0},
		blue 	={0,0,255},
		indigo 	={0,255,255},
		purple 	={255,0,255},
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
	ParticleManager:ReleaseParticleIndex(particle)
end

function create_popup_by_damage_type(data, ability)
    local damage_type = ability:GetAbilityDamageType()
    if damage_type == DAMAGE_TYPE_PHYSICAL then
        data.color = Vector(174, 47, 40)
    elseif damage_type == DAMAGE_TYPE_MAGICAL then
        data.color = Vector(91, 147, 209)
    elseif damage_type == DAMAGE_TYPE_PURE then
        data.color = Vector(216, 174, 83)
    else
        data.color = Vector(255, 255, 255)
    end
    create_popup(data)
end

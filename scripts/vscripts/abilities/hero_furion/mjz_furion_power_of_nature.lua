
local THIS_LUA = "abilities/hero_furion/mjz_furion_power_of_nature.lua"

LinkLuaModifier("modifier_mjz_furion_power_of_nature", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_furion_power_of_nature_debuff", THIS_LUA, LUA_MODIFIER_MOTION_NONE)

mjz_furion_power_of_nature = class({})
local ability_class = mjz_furion_power_of_nature

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_furion_power_of_nature"
end

---------------------------------------------------------------------------------------

modifier_mjz_furion_power_of_nature = class({})
local modifier_class = modifier_mjz_furion_power_of_nature

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
	function modifier_class:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_ATTACK,
		}
		return funcs
	end

	function modifier_class:OnAttack(keys)
        if keys.attacker ~= self:GetParent() then return nil end
        if keys.attacker:PassivesDisabled() then return nil end

		local attacker = keys.attacker
		local target = keys.target
        local caster = self:GetCaster()
        local parent = self:GetParent()
		local ability = self:GetAbility()
		local duration = GetTalentSpecialValueFor(ability, 'duration')
		local modifier_debuff_name = 'modifier_mjz_furion_power_of_nature_debuff'
		
		if ability:IsCooldownReady() then
			if self:_IsEnemy(target) then
				if not target:HasModifier(modifier_debuff_name) then
					target:AddNewModifier(caster, ability, modifier_debuff_name, {duration = duration })

					-- ability:StartCooldown(ability:GetCooldownTimeRemaining())
					ability:UseResources(true, false, true)
				end
			end
		end
	end
	
	function modifier_class:_IsEnemy(target)
        local caster = self:GetCaster()
		local ability = self:GetAbility()
		local nTargetTeam = ability:GetAbilityTargetTeam()
		local nTargetType = ability:GetAbilityTargetType()
		local nTargetFlags = ability:GetAbilityTargetFlags()
		local nTeam = caster:GetTeamNumber()
		local ufResult = UnitFilter(target, nTargetTeam, nTargetType, nTargetFlags, nTeam)
		return ufResult == UF_SUCCESS
	end

end

---------------------------------------------------------------------------------------

modifier_mjz_furion_power_of_nature_debuff = class({})
local modifier_debuff = modifier_mjz_furion_power_of_nature_debuff

function modifier_debuff:IsHidden() return false end
function modifier_debuff:IsPurgable() return false end
function modifier_debuff:IsDebuff() return true end

function modifier_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP,
	}
	return funcs
end

function modifier_debuff:GetModifierMoveSpeedBonus_Percentage( params )
	return self:GetAbility():GetSpecialValueFor('movement_slow_pct')
end

function modifier_debuff:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("damage_pct")
end

function modifier_debuff:OnTakeDamage(keys)
	if keys.unit ~= self:GetParent() then return nil end

	if IsServer() then
		local damge = keys.damage
		local damage_type = keys.damage_type
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()

		self.damage = self.damage + damge
	end
end

if IsServer() then
	function modifier_debuff:OnCreated(table)
		self.damage = 0
	end

	function modifier_debuff:OnDestroy()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local damage_pct = GetTalentSpecialValueFor(ability, 'damage_pct')
		local damage = math.ceil((self.damage * (damage_pct / 100.0)) / 2)

		local damage_table = {
			victim = parent,
			attacker = caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			ability = ability,
		}
		local returnDamage = ApplyDamage( damage_table )
		if returnDamage > 0 then
			-- SendOverheadEventMessage(caster:GetPlayerOwner(), damage, parent, returnDamage, caster:GetPlayerOwner()) 
			create_popup_by_damage_type({
				target = parent,
				value = returnDamage,
				color = Vector(0, 0, 0),
				type = 'damage'
			}, ability)

			Timers:CreateTimer({
				endTime = 0.5, 
				callback = function()
					local returnDamage2 = ApplyDamage( damage_table )
					if returnDamage2 > 0 then
						create_popup_by_damage_type({
							target = parent,
							value = returnDamage2,
							color = Vector(0, 0, 0),
							type = 'damage'
						}, ability)
					end						
				end	
			})			
		end
		
	end

end


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
	ParticleManager:DestroyParticle(particle, false)
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
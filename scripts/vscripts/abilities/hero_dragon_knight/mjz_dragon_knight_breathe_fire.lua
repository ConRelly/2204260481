local TARGET_MODIFIER_LIST = {
	'modifier_dragon_knight_dragon_form',
	'modifier_dragon_knight_corrosive_breath',
	'modifier_dragon_knight_splash_attack',
	'modifier_dragon_knight_frost_breath',

}

LinkLuaModifier("modifier_mjz_dragon_knight_breathe_fire_reduction", "abilities/hero_dragon_knight/mjz_dragon_knight_breathe_fire.lua", LUA_MODIFIER_MOTION_NONE)

------------------------------------------------------------------------------------------

mjz_dragon_knight_breathe_fire = class({})
function mjz_dragon_knight_breathe_fire:GetIntrinsicModifierName()
    -- return MODIFIER_RELIEVE_NAME
end

if IsServer() then
	function mjz_dragon_knight_breathe_fire:OnSpellStart()
		EmitSoundOn("Hero_DragonKnight.BreathFire", self:GetCaster())
		self:PlayEffect()
		if HasModifierList(self:GetCaster(), {"modifier_dragon_knight_dragon_form"}) then end
	end

	function mjz_dragon_knight_breathe_fire:OnProjectileHit( hTarget, vLocation )
		local caster = self:GetCaster()
		local duration = GetTalentSpecialValueFor(self, "duration") 
		local base_damage = GetTalentSpecialValueFor(self, "damage") 
		local str_damage = GetTalentSpecialValueFor(self, "strength_damage") 
		local fire_damage = base_damage + caster:GetStrength() * str_damage / 100

		if hTarget ~= nil and (not hTarget:IsMagicImmune()) and (not hTarget:IsInvulnerable()) then
			local damage = {
				victim = hTarget,
				attacker = caster,
				damage = fire_damage,
				damage_type = self:GetAbilityDamageType(),
				ability = self,
			}
			ApplyDamage(damage)
			hTarget:AddNewModifier(caster, self, "modifier_mjz_dragon_knight_breathe_fire_reduction", {duration = duration})
		end
		return false
	end

	function mjz_dragon_knight_breathe_fire:PlayEffect()
		local caster = self:GetCaster()
		local start_radius = GetTalentSpecialValueFor(self, "start_radius")
		local end_radius = GetTalentSpecialValueFor(self, "end_radius")
		local range = GetTalentSpecialValueFor(self, "range")
		local speed = GetTalentSpecialValueFor(self, "speed")	

		local vPos = nil
		if self:GetCursorTarget() then
			vPos = self:GetCursorTarget():GetOrigin()
		else
			vPos = self:GetCursorPosition()
		end

		local vDirection = vPos - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()

		speed = speed * ((range) / (range - start_radius))

		local effect_name = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf"

		local info = {
			EffectName = effect_name,
			Ability = self,
			vSpawnOrigin = caster:GetOrigin(), 
			fStartRadius = start_radius,
			fEndRadius = end_radius,
			vVelocity = vDirection * speed,
			fDistance = range,
			Source = caster,
			fExpireTime = GameRules:GetGameTime() + 5,
			iUnitTargetTeam = self:GetAbilityTargetTeam(),
			iUnitTargetType = self:GetAbilityTargetType(),
		}
		ProjectileManager:CreateLinearProjectile(info)
	end
end

------------------------------------------------------------------------------------------
modifier_mjz_dragon_knight_breathe_fire_reduction = class({})
function modifier_mjz_dragon_knight_breathe_fire_reduction:IsHidden() return false end
function modifier_mjz_dragon_knight_breathe_fire_reduction:IsPurgable() return true end
function modifier_mjz_dragon_knight_breathe_fire_reduction:DeclareFunctions()
    return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_MAGICDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_mjz_dragon_knight_breathe_fire_reduction:GetModifierBaseDamageOutgoing_Percentage(params)
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("reduction") * (-1) end
end
function modifier_mjz_dragon_knight_breathe_fire_reduction:GetModifierMagicDamageOutgoing_Percentage()
	if self:GetAbility() then
		if self:GetCaster():HasModifier("modifier_super_scepter") then
			return self:GetAbility():GetSpecialValueFor("spell_dmg_reduction") * (-1)
		else
			return 0
		end
	end
end

------------------------------------------------------------------------------------------
function HasModifierList(unit, modifier_name_list)
	for _,modifier_name in pairs(modifier_name_list) do
		if not unit:HasModifier(modifier_name) then
			return false
		end
	end
	return true
end

function SetModifierListDuration(unit, modifier_name_list, duration)
	for _,modifier_name in pairs(modifier_name_list) do
		local modifier = unit:FindModifierByName(modifier_name)
		if modifier then
			modifier:SetDuration(duration, true)
		end
	end
end

function SetModifierDuration(unit, modifier_name, duration)
	local modifier = unit:FindModifierByName(modifier_name)
	if modifier then
		modifier:SetDuration(duration, true)
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


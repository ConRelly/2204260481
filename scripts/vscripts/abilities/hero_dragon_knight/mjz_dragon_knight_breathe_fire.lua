
local THIS_LUA = "abilities/hero_dragon_knight/mjz_dragon_knight_breathe_fire.lua"
local MODIFIER_REDUCTION_NAME = 'modifier_mjz_dragon_knight_breathe_fire_reduction'

local TARGET_MODIFIER_LIST = {
	'modifier_dragon_knight_dragon_form',
	'modifier_dragon_knight_corrosive_breath',
	'modifier_dragon_knight_splash_attack',
	'modifier_dragon_knight_frost_breath',

}

LinkLuaModifier(MODIFIER_REDUCTION_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)

------------------------------------------------------------------------------------------

mjz_dragon_knight_breathe_fire = class({})
local ability_class = mjz_dragon_knight_breathe_fire

function ability_class:GetIntrinsicModifierName()
    -- return MODIFIER_RELIEVE_NAME
end

if IsServer() then
	function ability_class:OnSpellStart(  )
		local caster = self:GetCaster()
		local ability = self
		local unit = caster
		
		EmitSoundOn( "Hero_DragonKnight.BreathFire", caster )

		self:PlayEffect()
		
		if HasModifierList(unit, {'modifier_dragon_knight_dragon_form'}) then
			
		end
	end

	function ability_class:OnProjectileHit( hTarget, vLocation )
		local caster = self:GetCaster()
		local ability = self
		local duration = GetTalentSpecialValueFor(ability, "duration" ) 
		local base_damage = GetTalentSpecialValueFor(ability, "damage" ) 
		local str_damage = GetTalentSpecialValueFor(ability, "strength_damage" ) 
		local fire_damage = base_damage + caster:GetStrength() * str_damage / 100

		if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
	
			local damage = {
				victim = hTarget,
				attacker = caster,
				damage = fire_damage,
				damage_type = ability:GetAbilityDamageType(),
				ability = ability,
			}
			ApplyDamage( damage )

			hTarget:AddNewModifier(caster, ability, MODIFIER_REDUCTION_NAME, {duration = duration})
		end
	
		return false
	end


	function ability_class:PlayEffect(  )
		local caster = self:GetCaster()
		local ability = self
		
		local start_radius = GetTalentSpecialValueFor(ability, "start_radius" )
		local end_radius = GetTalentSpecialValueFor(ability, "end_radius" )
		local range = GetTalentSpecialValueFor(ability, "range" )
		local speed = GetTalentSpecialValueFor(ability, "speed" )	

		local vPos = nil
		if self:GetCursorTarget() then
			vPos = self:GetCursorTarget():GetOrigin()
		else
			vPos = self:GetCursorPosition()
		end

		local vDirection = vPos - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()

		speed = speed * ( ( range ) / ( range - start_radius ) )

		local effect_name = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf"

		local info = {
			EffectName = effect_name,
			Ability = ability,
			vSpawnOrigin = caster:GetOrigin(), 
			fStartRadius = start_radius,
			fEndRadius = end_radius,
			vVelocity = vDirection * speed,
			fDistance = range,
			Source = caster,
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetType = ability:GetAbilityTargetType() ,
		}

		ProjectileManager:CreateLinearProjectile( info )
	end
end


------------------------------------------------------------------------------------------

modifier_mjz_dragon_knight_breathe_fire_reduction = class({})
local modifier_reduction = modifier_mjz_dragon_knight_breathe_fire_reduction

function modifier_reduction:IsHidden() return false end
function modifier_reduction:IsPurgable() return true end

function modifier_reduction:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE
    }
end
function modifier_reduction:GetModifierBaseDamageOutgoing_Percentage( params )
	return self:GetAbility():GetSpecialValueFor('reduction')
end




------------------------------------------------------------------------------------------

function HasModifierList( unit, modifier_name_list )
	for _,modifier_name in pairs(modifier_name_list) do
		if not unit:HasModifier(modifier_name) then
			return false
		end
	end
	return true
end

function SetModifierListDuration( unit, modifier_name_list, duration )
	for _,modifier_name in pairs(modifier_name_list) do
		local modifier = unit:FindModifierByName(modifier_name)
		if modifier then
			modifier:SetDuration(duration, true)
		end
	end
end

function SetModifierDuration( unit, modifier_name, duration )
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


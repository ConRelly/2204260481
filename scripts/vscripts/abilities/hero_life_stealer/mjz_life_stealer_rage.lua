LinkLuaModifier("modifier_mjz_life_stealer_rage", "abilities/hero_life_stealer/mjz_life_stealer_rage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_life_stealer_rage_buff", "abilities/hero_life_stealer/mjz_life_stealer_rage.lua", LUA_MODIFIER_MOTION_NONE)

local ABILITY_INFEST_NAME = "mjz_life_stealer_infest"

mjz_life_stealer_rage = class({})
local ability_class = mjz_life_stealer_rage

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_life_stealer_rage"
end

function ability_class:OnSpellStart()
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()

		self:Rage(caster)
	end
end

if IsServer() then

	function ability_class:Rage(target)
		local caster = self:GetCaster()
		local ability = self
		local duration = GetTalentSpecialValueFor(ability, "duration")

		EmitSoundOn( "Hero_LifeStealer.Rage", target )
		Basic_Dispel( target )
		target:AddNewModifier(caster, ability, "modifier_mjz_life_stealer_rage_buff", {Duration = duration})

    end
	
end

---------------------------------------------------------------------------------------

modifier_mjz_life_stealer_rage = class({})
local modifier_class = modifier_mjz_life_stealer_rage

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

function modifier_class:DeclareFunctions()
	local funcs = {
	}
	return funcs
end


if IsServer() then	

	function modifier_class:OnInventoryContentsChanged(  )
		local caster = self:GetCaster()

		--[[

		if caster:HasScepter() then
			if not caster:FindAbilityByName(ABILITY_INFEST_NAME) then
				local newAbility = caster:AddAbility(ABILITY_INFEST_NAME)
				newAbility:SetLevel(1)
				newAbility:SetAbilityIndex(4)
			end
		else
			if caster:FindAbilityByName(ABILITY_INFEST_NAME) then
				caster:RemoveAbility(ABILITY_INFEST_NAME)
			end
		end

		]]
	end

end


---------------------------------------------------------------------------------------

modifier_mjz_life_stealer_rage_buff = class({})
local modifier_class_buff = modifier_mjz_life_stealer_rage_buff

function modifier_class_buff:IsBuff() return true end
function modifier_class_buff:IsHidden() return false end
function modifier_class_buff:IsPurgable() return false end

function modifier_class_buff:CheckState()
    local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
    return state  
end

function modifier_class_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_class_buff:GetModifierPreAttack_BonusDamage(  )
	return self:GetStackCount()
end

function modifier_class_buff:GetModifierAttackSpeedBonus_Constant(  )
	return self:GetAbility():GetSpecialValueFor('attack_speed_bonus')
end

function modifier_class_buff:GetModifierMoveSpeedBonus_Percentage(  )
	return self:GetAbility():GetSpecialValueFor('movement_speed_bonus')
end

function modifier_class_buff:GetStatusEffectName()
    return "particles/status_fx/status_effect_life_stealer_rage.vpcf"
end

function modifier_class_buff:StatusEffectPriority()
    return 10
end

function modifier_class_buff:OnCreated( kv )
	if IsServer() then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_rage.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
					ParticleManager:SetParticleControlEnt(nfx, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloch", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(nfx, false, false, 0, false, false)
	end
end

function modifier_class_buff:OnDestroy()
	if IsServer() then
		-- ParticleManager:ReleaseParticleIndex(self.nfx)
	end
end

function modifier_class_buff:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_life_stealer/life_stealer_rage.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		self:GetParent():GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_attack2",
		self:GetParent():GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		2,
		self:GetParent(),
		PATTACH_CENTER_FOLLOW,
		"attach_hitloc",
		self:GetParent():GetOrigin(), -- unknown
		true -- unknown, true
	)
	assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_color"))(self,effect_cast)

	-- buff particle
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end

-----------------------------------------------------------------------------------------

-- 判定单位是否拥有阿哈利姆神杖
-- caster: 要判定的单位
-- 返回 true: 有神杖 false:没有神杖
--
function FindScepter(caster)
	for i = 0,5 do
		local item = caster:GetItemInSlot(i)
		if item then
			print(item:GetName())
			if item:GetName() == "item_ultimate_scepter" then
				return true
			end
		end
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

-- 弱驱散
function Basic_Dispel( target )
	-- Basic Dispel
	local RemovePositiveBuffs = false
	local RemoveDebuffs = true
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = false
	local RemoveExceptions = false
	target:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
end

-- 强驱散	
function Strong_Dispel( target )
	-- Strong Dispel
	local RemovePositiveBuffs = false
	local RemoveDebuffs = true
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = true
	local RemoveExceptions = false
	target:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
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


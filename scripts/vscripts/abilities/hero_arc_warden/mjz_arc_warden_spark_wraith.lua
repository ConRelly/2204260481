LinkLuaModifier("modifier_mjz_arc_warden_spark_wraith", "abilities/hero_arc_warden/mjz_arc_warden_spark_wraith.lua", LUA_MODIFIER_MOTION_NONE)

mjz_arc_warden_spark_wraith = class({})
local ability_class = mjz_arc_warden_spark_wraith

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_arc_warden_spark_wraith"
end

function ability_class:OnToggle()
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()

		if ability:GetToggleState() then
			--caster:AddNewModifier( caster, ability, "", nil )
		else
			--caster:RemoveModifierByName("")
		end
	end
end

if IsServer() then
	function ability_class:OnProjectileHit(target, location)
		local caster = self:GetCaster()
		local ability = self
		local spark_damage = GetTalentSpecialValueFor(ability, "spark_damage")
		if caster:IsRealHero() then
			local multipl = GetTalentSpecialValueFor(ability, "spark_bonus")
			local stats = caster:GetAgility() + caster:GetIntellect(false)
			local bonus_dmg = stats * multipl
			spark_damage = spark_damage + bonus_dmg
		end	
        if target and not caster:IsIllusion() then
            ApplyDamage({
					attacker = caster,
					victim = target,
					damage = spark_damage,
					damage_type = ability:GetAbilityDamageType(),
					ability = ability
			})
			
			create_popup_by_damage_type({
					target = target,
					value = spark_damage,
					color = nil,
					type = "damage"
			}, ability) 
			
			if ability:GetAutoCastState() or ability:GetToggleState() then
				EmitSoundOn("Hero_ArcWarden.SparkWraith.Damage", target)
			end
        end
    end
	
	function ability_class:OnProjectileHit_ExtraData(target, pos, keys)
	
	end
	
end

---------------------------------------------------------------------------------------

modifier_mjz_arc_warden_spark_wraith = class({})
local modifier_class = modifier_mjz_arc_warden_spark_wraith

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_START,			-- 当拥有modifier的单位开始攻击某个目标
		MODIFIER_EVENT_ON_ATTACK_LANDED,		-- 当拥有modifier的单位攻击到某个目标时
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
	if IsServer() then
		return funcs
	else
		return {
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		}
	end
end

function modifier_class:GetModifierPreAttack_BonusDamage(  )
	return self:GetStackCount()
end

if IsServer() then	

	function modifier_class:OnAttackStart( keys )
		self:_Update_BonusDamage()
	end

	function modifier_class:OnAttackLanded(keys)
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local attacker = keys.attacker
		local target = keys.target
	
		if attacker == self:GetParent() then
			local proc_chance = GetTalentSpecialValueFor(ability, "proc_chance")
			if not attacker:IsRealHero() then
				proc_chance = 5
			end	
			--local isTarget = UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, attacker:GetTeamNumber()) == UF_SUCCESS
			--if isTarget then
			if RollPercentage(proc_chance) then
				self:_LaunchSpark(target)
				self:_Update_BonusDamage()
			end
			--end
		end
	end
	
	function modifier_class:_LaunchSpark(target)
		local ability = self:GetAbility()
		local attacker = self:GetParent()
		local wraith_speed = GetTalentSpecialValueFor(ability, "wraith_speed")
		local distance = CalcDistanceBetweenEntityOBB(target, attacker)
		local iMoveSpeed = wraith_speed -- distance * 5
		
		--if ability:GetAutoCastState() or ability:GetToggleState() then
		--	EmitSoundOn("Hero_ArcWarden.SparkWraith.Appear", attacker)
		--end
		
        ProjectileManager:CreateTrackingProjectile({
            Ability = ability,
            Target = target,
            Source = attacker,
            EffectName = "particles/units/heroes/hero_arc_warden/arc_warden_wraith_prj.vpcf",
            iMoveSpeed = iMoveSpeed,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bDodgeable = false,
            flExpireTime = GameRules:GetGameTime() + 60,
        })
    end
	
	function modifier_class:_Update_BonusDamage( )
	
	end 
	
	function modifier_class:_Update_BonusDamage_OLD( )
		local parent = self:GetParent()
		local ability = self:GetAbility()

		local bonus_damage = 0
		if ability:IsCooldownReady() then
			bonus_damage = ability:GetSpecialValueFor('bonus_damage')
		end
		if self:GetStackCount() ~= bonus_damage then
			self:SetStackCount(bonus_damage)
		end
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




local MODIFIER_LUA = "modifiers/hero_legion_commander/modifier_mjz_legion_commander_duel.lua"
local MODIFIER_CASTER_DAMAGE_NAME = "modifier_mjz_legion_commander_duel_caster_damage"
LinkLuaModifier(MODIFIER_CASTER_DAMAGE_NAME, MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE)


modifier_mjz_legion_commander_duel_caster = class({})
local modifier_caster = modifier_mjz_legion_commander_duel_caster

function modifier_caster:IsHidden() return false end
function modifier_caster:IsPurgable() return false end

function modifier_caster:CheckState()
    
	local state = {
        --[MODIFIER_STATE_COMMAND_RESTRICTED] = true,     -- 不能控制
        [MODIFIER_STATE_MUTED] = true,                  -- 不能使用物品
        [MODIFIER_STATE_SILENCED] = true,               -- 沉默状态
        -- [MODIFIER_STATE_FLYING] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,      -- 不能位移
        [MODIFIER_STATE_DISARMED] = false,              -- 缴械状态
        [MODIFIER_STATE_ATTACK_IMMUNE] = false,         -- 攻击免疫

	}
	return state
end

function modifier_caster:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,					-- 增加护甲
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_caster:GetModifierAttackSpeedBonus_Constant( )
	return self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
end
function modifier_caster:GetModifierPhysicalArmorBonus( )
	return self:GetAbility():GetSpecialValueFor('bonus_armor')
end
function modifier_caster:GetModifierIncomingDamage_Percentage()
    if self:GetAbility() then
        if self:GetParent():GetName() == "npc_dota_hero_legion_commander" then
            return self:GetAbility():GetSpecialValueFor('reduce_damage')
        end 
        return 0   
    end    
end

if IsServer() then
    
    function modifier_caster:OnCreated(table)
        local ability = self:GetAbility()
        local parent = self:GetParent()
	    local damage_pct = GetTalentSpecialValueFor(ability, 'bonus_damage_pct')
        
        parent:EmitSound("Hero_LegionCommander.Duel")
        
        parent:AddNewModifier(parent, ability, MODIFIER_CASTER_DAMAGE_NAME, {})
        parent:SetModifierStackCount(MODIFIER_CASTER_DAMAGE_NAME, parent, damage_pct)
    end

    function modifier_caster:OnDestroy()
        local ability = self:GetAbility()
        local parent = self:GetParent()

        parent:StopSound("Hero_LegionCommander.Duel")
        
        --ParticleManager:DestroyParticle(ability._particle, true)
        --ParticleManager:ReleaseParticleIndex(ability._particle)
        if ability._particle ~= nil then
            ParticleManager:DestroyParticle(ability._particle, true)
            ParticleManager:ReleaseParticleIndex(ability._particle)
        end

        parent:RemoveModifierByName(MODIFIER_CASTER_DAMAGE_NAME)

        parent:SetForceAttackTarget(nil)
        parent:Stop()
    end
end

---------------------------------------------------------------------------------------

modifier_mjz_legion_commander_duel_enemy = class({})
local modifier_enemy = modifier_mjz_legion_commander_duel_enemy

function modifier_enemy:IsHidden() return false end
function modifier_enemy:IsPurgable() return false end

function modifier_enemy:CheckState()
    if self:GetParent().bAbsoluteNoCC then return end
	local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,     -- 不能控制
        [MODIFIER_STATE_MUTED] = true,                  -- 不能使用物品
        [MODIFIER_STATE_SILENCED] = true,               -- 沉默状态
        -- [MODIFIER_STATE_FLYING] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,      -- 不能位移
        [MODIFIER_STATE_DISARMED] = false,              -- 缴械状态
        [MODIFIER_STATE_ATTACK_IMMUNE] = false,         -- 攻击免疫

	}
	return state
end

if IsServer() then
    function modifier_enemy:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_DEATH,
        }
        return funcs
    end

    function modifier_enemy:OnCreated(table)
    end

    function modifier_enemy:OnDeath(event )
		if self:GetParent() ~= event.unit then return end

		local ability = self:GetAbility()
		local parent = self:GetParent()
        
        ability:OnTargetDeath(parent)        
    end
    
    function modifier_enemy:OnDestroy()
        local ability = self:GetAbility()
        local parent = self:GetParent()

        parent:SetForceAttackTarget(nil)
        parent:Stop()
        Timers:CreateTimer({
            endTime = 1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
            callback = function()
                if ability._particle ~= nil then
                    ParticleManager:DestroyParticle(ability._particle, true)
                    ParticleManager:ReleaseParticleIndex(ability._particle)
                end             
            end
        })        
    end
end

---------------------------------------------------------------------------------------

modifier_mjz_legion_commander_duel_caster_damage = class({})
local modifier_caster_damage = modifier_mjz_legion_commander_duel_caster_damage

function modifier_caster_damage:IsHidden() return true end
function modifier_caster_damage:IsPurgable() return false end

function modifier_caster_damage:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,			-- 按百分比修改攻击力，负数降低攻击，正数提高攻击
	}
	return funcs
end

function modifier_caster_damage:GetModifierDamageOutgoing_Percentage( )
	return self:GetStackCount()
end


---------------------------------------------------------------------------------------

modifier_mjz_legion_commander_duel_scepter = class({})
local modifier_scepter = modifier_mjz_legion_commander_duel_scepter

function modifier_scepter:IsHidden() return true end
function modifier_scepter:IsPurgable() return false end

function modifier_scepter:CheckState()
	local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
	return state
end

function modifier_scepter:DeclareFunctions()
    local funcs = {
		-- MODIFIER_PROPERTY_STATUS_RESISTANCE,				-- 状态抗性（不可叠加）	GetModifierStatusResistance
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,		-- 状态抗性（可以叠加）	GetModifierStatusResistanceStacking
    }
    return funcs
end

function modifier_scepter:GetModifierStatusResistanceStacking( params )
	return self:GetAbility():GetSpecialValueFor('status_resistance_scepter')
end

--------------------------------------------------------------------

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
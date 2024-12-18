LinkLuaModifier("modifier_mjz_troll_warlord_battle_trance","abilities/hero_troll_warlord/mjz_troll_warlord_battle_trance.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_troll_warlord_battle_trance_lifesteal","abilities/hero_troll_warlord/mjz_troll_warlord_battle_trance.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_troll_warlord_battle_trance_cd","abilities/hero_troll_warlord/mjz_troll_warlord_battle_trance.lua", LUA_MODIFIER_MOTION_NONE)

-------------------------------------------------------
mjz_troll_warlord_battle_trance = class({})
local ability_class = mjz_troll_warlord_battle_trance

function ability_class:GetCooldown(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_cooldown")
    end
    return self.BaseClass.GetCooldown(self, iLevel)
end

function ability_class:GetAOERadius()
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_radius")
    end
    return 0
end



function ability_class:OnSpellStart( ... )
	if not IsServer() then return end

	local ability = self
	local caster = self:GetCaster()

    if caster:HasScepter() then
        self:CastBattleTrance_Friendly()
    else
        self:CastBattleTrance(caster)
    end

	EmitSoundOn("Hero_TrollWarlord.BattleTrance.Cast", caster)
end

function ability_class:CastBattleTrance_Friendly( )
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("scepter_radius")
    local alliens = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

    if #alliens > 0 then
        for _, friend in pairs(alliens) do
			if friend ~= nil and friend:IsRealHero() then
				self:CastBattleTrance(friend)
            end
        end
    end
end

function ability_class:CastBattleTrance( target )
	local ability = self
	local caster = self:GetCaster()
	local pszScriptName = "modifier_mjz_troll_warlord_battle_trance"
	local m_lifesteal = "modifier_mjz_troll_warlord_battle_trance_lifesteal"
    local m_cd = "modifier_mjz_troll_warlord_battle_trance_cd"
	local duration = ability:GetSpecialValueFor("trance_duration")
    local cd_duration = duration * 1.7
    if not target:HasModifier(m_cd) then
        target:AddNewModifier(caster, ability, pszScriptName, {duration = duration})
        target:AddNewModifier(caster, ability, m_lifesteal, {duration = duration})
        target:AddNewModifier(caster, ability, m_cd, {duration = cd_duration})
    end   
end

---------------------------------------------------------------------------------------

modifier_mjz_troll_warlord_battle_trance = class({})
local modifier_class = modifier_mjz_troll_warlord_battle_trance

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

function modifier_class:GetEffectName(kv)
    return "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"
end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        -- MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,      --GetModifierMoveSpeedBonus_Constant
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_class:GetMinHealth(keys)
	return 100
end

function modifier_class:GetModifierAttackSpeedBonus_Constant(  )
	return self:GetAbility():GetSpecialValueFor('attack_speed')
end
function modifier_class:GetModifierMoveSpeedBonus_Percentage (  )
	return self:GetAbility():GetSpecialValueFor('movement_speed')
end

function modifier_class:OnTooltip(event)
	return self:GetAbility():GetSpecialValueFor('lifesteal')
end
function modifier_class:GetModifierIncomingDamage_Percentage()
	return -300
end


if IsServer() then
	function modifier_class:OnCreated(table)
		local parent = self:GetParent()
		
		local talent_ability = self:GetCaster():FindAbilityByName("special_bonus_unique_troll_warlord_4")
		local has_talent = (talent_ability and talent_ability:GetLevel() ~= 0)
		if has_talent then
			-- 强驱散
			Strong_Dispel(parent)
		else
			-- 弱驱散
			Basic_Dispel(parent)
		end
	end
end

-----------------------------CD Battle trance----------------------------------------------------------
modifier_mjz_troll_warlord_battle_trance_cd = class({})
function modifier_mjz_troll_warlord_battle_trance_cd:IsHidden() return false end
function modifier_mjz_troll_warlord_battle_trance_cd:IsPurgable() return false end
function modifier_mjz_troll_warlord_battle_trance_cd:RemoveOnDeath() return false end
function modifier_mjz_troll_warlord_battle_trance_cd:IsDebuff() return true end

-----------------------------------------------------------------------------------------

modifier_mjz_troll_warlord_battle_trance_lifesteal = class({})
local modifier_lifesteal = modifier_mjz_troll_warlord_battle_trance_lifesteal

function modifier_lifesteal:IsHidden() return true end
function modifier_lifesteal:IsPurgable() return false end

if IsServer() then
    function modifier_lifesteal:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end

    function modifier_lifesteal:OnAttackLanded(keys)
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local attacker = keys.attacker
        local target = keys.target
        local damage = keys.damage
    
        if parent == attacker and parent:GetTeamNumber() ~= target:GetTeamNumber() then
            if not target:IsHero() and not target:IsCreep() then
                return nil
            end
    
            if parent:IsIllusion() then return nil end
    
            local lifesteal_pct = self:GetAbility():GetSpecialValueFor('lifesteal')
            local lifesteal_amount = damage * (lifesteal_pct / 100.0)
            parent:Heal(lifesteal_amount, parent)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, lifesteal_amount, nil)
    
            -- Choose the particle to draw
            local lifesteal_particle = "particles/generic_gameplay/generic_lifesteal.vpcf"
    
            -- Heal and fire the particle
            local lifesteal_pfx = ParticleManager:CreateParticle(lifesteal_particle, PATTACH_ABSORIGIN_FOLLOW, attacker)
            ParticleManager:SetParticleControl(lifesteal_pfx, 0, attacker:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
            
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


------------------------------------------------------------------------------------

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

local THIS_LUA =  "abilities/hero_storm_spirit/mjz_storm_spirit_ball_lightning.lua"
LinkLuaModifier('modifier_mjz_storm_spirit_ball_lightning', THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_mjz_storm_spirit_ball_lightning_buff', THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_mjz_storm_spirit_ball_lightning_dummy', THIS_LUA, LUA_MODIFIER_MOTION_NONE)

----------------------------------------------------------------------------

mjz_storm_spirit_ball_lightning = class({})
local ability_class = mjz_storm_spirit_ball_lightning
--[[
function ability_class:GetIntrinsicModifierName()
	return 'modifier_mjz_storm_spirit_ball_lightning'
end

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('radius')
end
]]
function ability_class:OnToggle()
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()
		local buff_name = 'modifier_mjz_storm_spirit_ball_lightning_buff'
		if ability:GetToggleState() then
			EmitSoundOn("Hero_StormSpirit.BallLightning", caster)
			caster:AddNewModifier(caster, ability, buff_name, {})
		else
			caster:RemoveModifierByName(buff_name)
		end
	end
end

----------------------------------------------------------------------------
--[[
modifier_mjz_storm_spirit_ball_lightning = class({})

function modifier_mjz_storm_spirit_ball_lightning:IsPassive()
	return true
end
function modifier_mjz_storm_spirit_ball_lightning:IsPurgable()
	return false
end
function modifier_mjz_storm_spirit_ball_lightning:IsHidden()
	return true
end

if IsServer() then
	function modifier_mjz_storm_spirit_ball_lightning:OnCreated(table)
		self:StartIntervalThink(1.0)
	end

	function modifier_mjz_storm_spirit_ball_lightning:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local aura_enabled = GetTalentSpecialValueFor(ability, 'aura_enabled')
		local MODIFIER_AURA_NAME = 'modifier_mjz_storm_spirit_ball_lightning_aura'
		local MODIFIER_BUFF_NAME = 'modifier_mjz_storm_spirit_ball_lightning_buff'

		if aura_enabled > 0 then
			if not caster:HasModifier(MODIFIER_AURA_NAME) then
				caster:RemoveModifierByName(MODIFIER_BUFF_NAME)
				caster:AddNewModifier(caster, ability, MODIFIER_AURA_NAME, {})
			end
		else
			if not caster:HasModifier(MODIFIER_BUFF_NAME) then
				caster:AddNewModifier(caster, ability, MODIFIER_BUFF_NAME, {})
			end
		end
	end
end

-----------------------------------------------------------

modifier_mjz_storm_spirit_ball_lightning_dummy = class({})
local modifier_dummy = modifier_mjz_storm_spirit_ball_lightning_dummy

function modifier_dummy:IsHidden() return true end
function modifier_dummy:IsPurgable() return false end

function modifier_dummy:CheckState()
    local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_FLYING] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}
    return state  
end
]]
----------------------------------------------------------------------------


modifier_mjz_storm_spirit_ball_lightning_buff = class({})
local modifier_buff = modifier_mjz_storm_spirit_ball_lightning_buff

function modifier_buff:IsPurgable() return false end
function modifier_buff:IsHidden() return false end

function modifier_buff:CheckState()
	local Flying = nil
	if self:GetCaster():HasModifier("modifier_super_scepter") then Flying = true end
	local state = {
		--[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		--[MODIFIER_STATE_UNSELECTABLE] = true,
		-- [MODIFIER_STATE_OUT_OF_GAME] = true,
		--[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = Flying,
		--[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end

function modifier_buff:DeclareFunctions()
	return {
		-- MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
	}
end

function modifier_buff:GetModifierIgnoreMovespeedLimit()
	if self:GetCaster():HasModifier("modifier_super_scepter") then return 1 else return 0 end
end

-- function modifier_buff:GetOverrideAnimation(params)
--     return ACT_DOTA_OVERRIDE_ABILITY_4
-- end

function modifier_buff:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor('bonus_move_speed')
end

function modifier_buff:GetModifierIncomingDamage_Percentage()
	if self:GetAbility() then
		if self:GetParent():GetName() ~= "npc_dota_hero_rubick" then
			return self:GetAbility():GetSpecialValueFor("dmg_reduction") * (-1)
		end
		return 0	
	end	
end



if IsServer() then
	function modifier_buff:OnCreated( ... )
		local parent = self:GetParent()
		EmitSoundOn("Hero_StormSpirit.BallLightning.Loop", parent)

--[[ 		local p_name = "particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning.vpcf"
		local particle = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(particle, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self.particle = particle ]]  
		--particle above to bright
	
		local nFXIndex = ParticleManager:CreateParticle("particles/hero_flash/flash_custom_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(nFXIndex, false, false, -1, false, true)
 
		self.interval = 0.50
		self:StartIntervalThink(self.interval)
	end

	function modifier_buff:OnDestroy( ... )
		local parent = self:GetParent()
		StopSoundOn("Hero_StormSpirit.BallLightning.Loop", parent)
		StopSoundEvent("Hero_StormSpirit.BallLightning.Loop", parent)
		--ParticleManager:DestroyParticle(self.particle, true)
		--ParticleManager:ReleaseParticleIndex(self.particle)
	end


	function modifier_buff:OnIntervalThink()
		local parent = self:GetParent()
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local radius = GetTalentSpecialValueFor(ability, 'radius')
		if caster:HasModifier("modifier_super_scepter") then
			radius = radius * 2
		end
		local mana_percentage = self:GetSpecialValueFor("mana_percentage") - talent_value(self:GetCaster(), "special_bonus_unique_mjz_storm_spirit_ball_lightning_02")
		local mana_per = (parent:GetMaxMana() * mana_percentage / 100) * self.interval

		KillTreesInRadius(parent, parent:GetAbsOrigin(), radius)

		if parent:GetMana() > mana_per then
			parent:SpendMana(mana_per, ability)
		else
			if not self:IsNull() then
				self:Destroy()
			end	
			ability:ToggleAbility()
		end

		self:GiveDamage()
	end

	function modifier_buff:GiveDamage( ... )
		local parent = self:GetParent()
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local radius = GetTalentSpecialValueFor(ability, 'radius')
		local damage = GetTalentSpecialValueFor(ability, 'damage')
		if caster:HasModifier("modifier_super_scepter") then
			local mult = 1
			local armor_mult = (caster:GetPhysicalArmorValue(false) / 50) + 1
			local spell_amp = 1 + caster:GetSpellAmplification(false)
			if armor_mult > spell_amp then
				mult = armor_mult
			else
				mult = spell_amp
			end	
			if mult > 30 then
				mult = 27 + (mult / 10)
			end	
			damage = damage * mult
			radius = radius * 2
		end
		local damage_per = damage * self.interval
		local damageTable = {
			victim = nil,
			attacker = caster,
			damage = damage_per,
			damage_type = ability:GetAbilityDamageType(),
			ability = ability,
		}
		local unit_list = FindUnitsInRadius(
			caster:GetTeamNumber(), caster:GetAbsOrigin(),
			nil, radius,
			ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),
			ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER, false
        )
        for _,unit in pairs(unit_list) do
			if unit then
				damageTable.victim = unit
				ApplyDamage(damageTable)
            end
		end
	end

end


-----------------------------------------------------------------------------------------


function KillTreesInRadius(caster, center, radius)
    local particles = {
        "particles/newplayer_fx/npx_tree_break.vpcf",
        "particles/newplayer_fx/npx_tree_break_b.vpcf",
    }
    local particle = particles[math.random(1, #particles)]

    local trees = GridNav:GetAllTreesAroundPoint(center, radius, true)
    for _,tree in pairs(trees) do
        local particle_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_fx, 0, tree:GetAbsOrigin())
		ParticleManager:DestroyParticle(particle_fx, false)
        ParticleManager:ReleaseParticleIndex(particle_fx)
    end
    GridNav:DestroyTreesAroundPoint(center, radius, false)
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


-- 是否学习了天赋技能
function HasTalentSpecialValueFor(ability, value)
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
		return talent and talent:GetLevel() > 0 
    end
    return false
end

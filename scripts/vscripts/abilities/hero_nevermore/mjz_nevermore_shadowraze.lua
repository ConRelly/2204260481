local THIS_LUA = "abilities/hero_nevermore/mjz_nevermore_shadowraze.lua"
-- LinkLuaModifier("modifier_mjz_nevermore_shadowraze", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_nevermore_shadowraze_stack", THIS_LUA, LUA_MODIFIER_MOTION_NONE)

mjz_nevermore_shadowraze = mjz_nevermore_shadowraze or class({})

-- function mjz_nevermore_shadowraze:GetAOERadius()
--     return self:GetSpecialValueFor("radius")
-- end


function mjz_nevermore_shadowraze:OnSpellStart()
    if not IsServer() then return end
    local hCaster = self:GetCaster()
    local hAbility = self

    EmitSoundOn("Hero_Nevermore.Shadowraze", self:GetCaster())

    local hPosition = self:_FindSpellPosition()

    self:Spell_Shadowraze(hPosition)
end

function mjz_nevermore_shadowraze:_FindSpellPosition()
    local hCaster = self:GetCaster()
    local hAbility = self
    local startPos = hCaster:GetAbsOrigin()
    local direction = hCaster:GetForwardVector()
    local distance = hAbility:GetTalentSpecialValueFor("shadowraze_range")
    local radius = hAbility:GetTalentSpecialValueFor("shadowraze_radius")
    
    distance = distance + hCaster:GetCastRangeBonus()

    local position = startPos + direction * distance
    local endPos = position
    position = GetGroundPosition(position, hCaster)

    -- random
    local p_random = nil
    local width = radius
    local enemies = self:_FindEnemyUnitsInLine(startPos, endPos, width)
    if #enemies > 0 then
        local r_enemy = enemies[RandomInt(1, #enemies)]
        p_random = GetGroundPosition(r_enemy:GetAbsOrigin(), hCaster)
    end

    if p_random == nil then
        return position
    else
        return p_random
    end
end

function mjz_nevermore_shadowraze:Spell_Shadowraze(hPosition)
    if not IsServer() then return end
    local hCaster = self:GetCaster()
    local hAbility = self
    local radius = hAbility:GetSpecialValueFor("shadowraze_radius")

    AddFOWViewer(hCaster:GetTeam(), hPosition, radius, 1, false)
        
    local p_name = "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf"
    ParticleManager:FireParticle(p_name, PATTACH_POINT, hCaster, {[0] = hPosition})
    
    local enemies = hCaster:FindEnemyUnitsInRadius(hPosition, radius, {})
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( hAbility ) then
            local damage = self:_CalcDamage(enemy)
            
            self:_ApplyStack(enemy)

			ApplyDamage({ 
                victim = enemy, attacker = hCaster, ability = hAbility,
                damage = damage, damage_type = hAbility:GetAbilityDamageType() 
            })
            if HasTalent(hCaster, "special_bonus_unique_mjz_nevermore_shadowraze_agi_bonus") then
                hCaster:ModifyAgility(1)
            end  
            if HasTalent(hCaster, "special_bonus_unique_nevermore_raze_procsattacks") then
                if not enemy:IsNull() and enemy:IsAlive() and hCaster:IsAlive() then
                    hCaster:PerformAttack(enemy, true, true, true, true, true, false, true)
                end
            end
		end
	end
end


function mjz_nevermore_shadowraze:_CalcDamage( hEnemy )
    local hCaster = self:GetCaster()
    local hAbility = self
    local base_damage = hAbility:GetTalentSpecialValueFor("shadowraze_damage")
    --local damage_per_soul = hAbility:GetTalentSpecialValueFor("damage_per_soul")
    local stack_bonus_damage = hAbility:GetTalentSpecialValueFor("stack_bonus_damage_agi") * hCaster:GetAgility()
   -- local m_soul_name = "modifier_mjz_nevermore_necromastery"
    local m_stack_name = "modifier_mjz_nevermore_shadowraze_stack"
    --local m_soul = hCaster:FindModifierByName(m_soul_name)
    local m_stack = hEnemy:FindModifierByName(m_stack_name)

    local damage = base_damage
--[[     if m_soul ~= nil then
        damage = damage + m_soul:GetStackCount() * damage_per_soul
    end ]]
    if m_stack ~= nil then
        damage = damage + m_stack:GetStackCount() * stack_bonus_damage
    end
    return damage
end

function mjz_nevermore_shadowraze:_ApplyStack(hEnemy)
    if not IsServer() then return end
    local hCaster = self:GetCaster()
    local hAbility = self
    local duration = hAbility:GetSpecialValueFor("stack_bonus_duration")
    
    local m_stack_name = "modifier_mjz_nevermore_shadowraze_stack"
    local m_stack = hEnemy:FindModifierByName(m_stack_name)
    if m_stack then
        m_stack:IncrementStackCount()
        m_stack:SetDuration(duration, true)
    else
        m_stack = hEnemy:AddNewModifier(hCaster, hAbility, m_stack_name, {duration = duration})
        if m_stack then
            m_stack:IncrementStackCount()
        end
	end
end

function mjz_nevermore_shadowraze:_HealSelf(damage)
    local hCaster = self:GetCaster()
    local hAbility = self
    if hCaster:IsAlive() and hCaster:HasScepter() then
        local flAmount = damage
        hCaster:Heal(flAmount, hAbility)
    end
end

function mjz_nevermore_shadowraze:_FindEnemyUnitsInLine(startPos, endPos, width)
	local team = self:GetTeamNumber()
	local iTeam = self:GetAbilityTargetTeam()
	local iType = self:GetAbilityTargetType()
	local iFlag = self:GetAbilityTargetFlags()
	return FindUnitsInLine(team, startPos, endPos, nil, width, iTeam, iType, iFlag)
end

-----------------------------------------------------------------------------------------

modifier_mjz_nevermore_shadowraze_stack = modifier_mjz_nevermore_shadowraze_stack or class({})

function modifier_mjz_nevermore_shadowraze_stack:IsHidden() return false end
function modifier_mjz_nevermore_shadowraze_stack:IsPurgable() return false end
function modifier_mjz_nevermore_shadowraze_stack:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_mjz_nevermore_shadowraze_stack:OnTooltip()
	return self:GetStackCount() * 0.5 * self:GetCaster():GetAgility()
end
function modifier_mjz_nevermore_shadowraze_stack:GetEffectName()
	return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf"
end

--talents
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false  
end
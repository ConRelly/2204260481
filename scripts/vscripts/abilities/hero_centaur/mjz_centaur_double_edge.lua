
LinkLuaModifier('modifier_mjz_centaur_double_edge_radius', "abilities/hero_centaur/mjz_centaur_double_edge.lua", LUA_MODIFIER_MOTION_NONE)

----------------------------------------------------------------------------

mjz_centaur_double_edge = class({})
local ability_class = mjz_centaur_double_edge

function ability_class:GetAOERadius()
	local caster = self:GetCaster()
	local MODIFIER_NAME = 'modifier_mjz_centaur_double_edge_radius'
	local aoe = self:GetSpecialValueFor('radius')

	if IsServer() then
		local radius = GetTalentSpecialValueFor(self, "radius")
		if radius > aoe then
			if not caster:HasModifier(MODIFIER_NAME) then
				caster:AddNewModifier(caster, nil, MODIFIER_NAME, {})
			end
		end
	end

	if self:GetCaster():HasModifier(MODIFIER_NAME) then
		aoie = aoe + 400
	end
	return aoe
end

function ability_class:OnAbilityPhaseStart()
	self.iPreParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_double_edge_phase.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.iPreParticleID, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon", self:GetCaster():GetAbsOrigin(), true)
	return true
end

function ability_class:OnAbilityPhaseInterrupted()
	if self.iPreParticleID ~= nil then
		ParticleManager:DestroyParticle(self.iPreParticleID, true)
		self.iPreParticleID = nil
	end
end

function ability_class:OnSpellStart()
	if self.iPreParticleID ~= nil then
		ParticleManager:DestroyParticle(self.iPreParticleID, false)
		self.iPreParticleID = nil
	end

	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()
	local radius = ability:GetAOERadius()

	if not IsValidEntity(target) then return end

	EmitSoundOn("Hero_Centaur.DoubleEdge", caster)
	self:ApplySelfDamage()


	self:ApplyEffect(target, radius)
	
	local enemy_list = FindUnitsInRadius( caster:GetTeamNumber(), target:GetAbsOrigin(), caster, radius, 
	ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false )

	for _, enemy in ipairs(enemy_list) do
		self:ApplyDamage(enemy)
	end

end

function mjz_centaur_double_edge:ApplySelfDamage( )
	local caster = self:GetCaster()
	local ability = self
	local self_strength_damage = ability:GetSpecialValueFor( "self_strength_damage" )
	local damageType = ability:GetAbilityDamageType()
	local self_damage = caster:GetStrength() * (self_strength_damage / 100)

	ApplyDamage({ 
		victim = caster, 
		attacker = caster, 
		damage = self_damage,	
		damage_type = damageType, 
		damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL 
	})
end


function mjz_centaur_double_edge:ApplyDamage( target )
	local ability = self
	local caster = self:GetCaster()

	local edge_damage = GetTalentSpecialValueFor(ability, "edge_damage")
	local strength_damage = GetTalentSpecialValueFor(ability, "strength_damage")
	
	local damage_attr = caster:GetStrength() * (strength_damage / 100)
	local damage_amount = edge_damage + damage_attr

	local dmg_table_target = {
		victim = target,
		attacker = caster,
		damage = damage_amount,
		damage_type = ability:GetAbilityDamageType(),
		-- damage_flags = ability:GetAbilityTargetFlags(), 
		ability = ability,
	}
	ApplyDamage(dmg_table_target)

end

function mjz_centaur_double_edge:ApplyEffect( target, radius )
	local caster = self:GetCaster()
	local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_double_edge_body.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(iParticleID, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:DestroyParticle(iParticleID, false)
	ParticleManager:ReleaseParticleIndex(iParticleID)

	local p_name = "particles/units/heroes/hero_centaur/centaur_double_edge.vpcf"
	local p_name_ti9 = "particles/econ/items/centaur/centaur_ti9/centaur_double_edge_ti9.vpcf"

	local iParticleID = ParticleManager:CreateParticle(p_name_ti9, PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(iParticleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(iParticleID, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlForward(iParticleID, 2, caster:GetForwardVector())
	ParticleManager:SetParticleControlEnt(iParticleID, 3, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(iParticleID, 5, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(iParticleID, 6, Vector(radius, radius, radius))
	ParticleManager:DestroyParticle(iParticleID, false)
	ParticleManager:ReleaseParticleIndex(iParticleID)

end

function mjz_centaur_double_edge:ApplyEffect_Old( target )
	local caster = self:GetCaster()
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_double_edge.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin()) -- Origin
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin()) -- Destination
	ParticleManager:SetParticleControl(particle, 5, target:GetAbsOrigin()) -- Hit Glow
end

----------------------------------------------------------------------------

modifier_mjz_centaur_double_edge_radius = class({})

function modifier_mjz_centaur_double_edge_radius:IsPurgable()
	return false
end
function modifier_mjz_centaur_double_edge_radius:IsHidden()
	return true
end
-- 效果永久，死亡不消失
function modifier_mjz_centaur_double_edge_radius:GetAttributes() 
	return MODIFIER_ATTRIBUTE_PERMANENT 
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


LinkLuaModifier("modifier_mjz_phoenix_supernova_burn","modifiers/hero_phoenix/modifier_mjz_phoenix_supernova_egg.lua", LUA_MODIFIER_MOTION_NONE)


modifier_mjz_phoenix_supernova_egg = class({})
local modifier_egg = modifier_mjz_phoenix_supernova_egg

function modifier_egg:IsHidden() return true end
function modifier_egg:IsPurgable() return false end

function modifier_egg:CheckState() 

	local state = {
		[MODIFIER_STATE_ROOTED]     			= true,
		[MODIFIER_STATE_COMMAND_RESTRICTED]     = true,
		[MODIFIER_STATE_MAGIC_IMMUNE]     		= true,
	}
	return state
end

function modifier_egg:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_ATTACKED,
	}
end

function modifier_egg:GetDisableHealing()
	return 1
end
function modifier_egg:GetAbsoluteNoDamageMagical()
	return 1
end
function modifier_egg:GetAbsoluteNoDamagePure()
	return 1
end
function modifier_egg:GetAbsoluteNoDamagePhysical()
	return 1
end
function modifier_egg:GetModifierIncomingDamage_Percentage()
	return 0
end

function modifier_egg:GetOverrideAnimation()
	return ACT_DOTA_IDLE
end
-- function modifier_egg:GetOverrideAnimationRate()
-- 	return 0.7
-- end



---------------------------------------------------------------

function modifier_egg:IsAura() return true end
function modifier_egg:GetModifierAura()
	return "modifier_mjz_phoenix_supernova_burn"
end
function modifier_egg:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor( "aura_radius" )
end
function modifier_egg:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_egg:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_egg:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES --DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_egg:GetAuraDuration()
    return 1.0
end

---------------------------------------------------------------


if IsServer() then
	function modifier_egg:OnCreated(table)
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local egg = self:GetParent()
		
		egg:EmitSound("Hero_Phoenix.SuperNova.Begin")
		egg:EmitSound("Hero_Phoenix.SuperNova.Cast")

		local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_supernova_egg.vpcf", PATTACH_ABSORIGIN_FOLLOW, egg )
		ParticleManager:SetParticleControlEnt( pfx, 1, egg, PATTACH_POINT_FOLLOW, "attach_hitloc", egg:GetAbsOrigin(), true )
		ParticleManager:ReleaseParticleIndex( pfx )
		self:StartIntervalThink(0.25)
	end

end
function modifier_egg:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	if parent and caster then
		if caster:GetAbsOrigin() ~= parent:GetAbsOrigin() then
			parent:SetAbsOrigin(caster:GetAbsOrigin())
		end	
	end	
end	

function modifier_egg:OnDeath( keys )
	if not IsServer() then return end

	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local egg = self:GetParent()
	local egg_target = egg._supernova_target

	local killer = keys.attacker
	if egg ~= keys.unit then
		return
	end

	local stun_duration = GetTalentSpecialValueFor(ability, "stun_duration")

	egg_target:RemoveNoDraw()

	egg:AddNoDraw()

	StopSoundEvent("Hero_Phoenix.SuperNova.Begin", egg)
	StopSoundEvent( "Hero_Phoenix.SuperNova.Cast", egg)
	if egg == killer then
		-- Phoenix reborns
		StartSoundEvent( "Hero_Phoenix.SuperNova.Explode", egg)
		local pfxName = "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf"
		local pfx = ParticleManager:CreateParticle( pfxName, PATTACH_ABSORIGIN_FOLLOW, egg_target )
		ParticleManager:SetParticleControl( pfx, 0, egg:GetAbsOrigin() )
		ParticleManager:SetParticleControl( pfx, 1, Vector(1.5,1.5,1.5) )
		ParticleManager:SetParticleControl( pfx, 3, egg:GetAbsOrigin() )
		ParticleManager:ReleaseParticleIndex(pfx)

		self:ResetUnit(egg_target)
		egg_target:SetHealth( egg_target:GetMaxHealth() )
		egg_target:SetMana( egg_target:GetMaxMana() )

		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
									egg:GetAbsOrigin(),
									nil,
									ability:GetSpecialValueFor("aura_radius"),
									DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
									DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
									FIND_ANY_ORDER,
									false )
		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(egg_target, ability, "modifier_stunned", {duration = stun_duration })
    	end
	else
		-- Phoenix killed

		if egg_target:IsAlive() then egg_target:Kill(ability, killer) end

		StartSoundEventFromPosition( "Hero_Phoenix.SuperNova.Death", egg:GetAbsOrigin())

		local pfxName = "particles/units/heroes/hero_phoenix/phoenix_supernova_death.vpcf"
		local pfx = ParticleManager:CreateParticle( pfxName, PATTACH_WORLDORIGIN, nil )
		local attach_point = egg_target:ScriptLookupAttachment( "attach_hitloc" )
		ParticleManager:SetParticleControl( pfx, 0, egg_target:GetAttachmentOrigin(attach_point) )
		ParticleManager:SetParticleControl( pfx, 1, egg_target:GetAttachmentOrigin(attach_point) )
		ParticleManager:SetParticleControl( pfx, 3, egg_target:GetAttachmentOrigin(attach_point) )
		ParticleManager:ReleaseParticleIndex(pfx)
	end

	FindClearSpaceForUnit(egg_target, egg:GetAbsOrigin(), false)

	self.bIsFirstAttacked = nil
end

function modifier_egg:ResetUnit( unit )
	for i=0,10 do
		local abi = unit:GetAbilityByIndex(i)
		if abi then
			if abi:GetAbilityType() ~= 1 and not abi:IsItem() then
				abi:EndCooldown()
			end
		end
	end
	unit:Purge( true, true, true, true, true )
end

function modifier_egg:OnAttacked( keys )
	if not IsServer() then return end

	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local egg = self:GetParent()
	local attacker = keys.attacker

	if keys.target ~= egg then return end

	local max_attack = egg.max_attack
	local current_attack = egg.current_attack

	if attacker:IsRealHero() then
		egg.current_attack = egg.current_attack + 1
	else
		egg.current_attack = egg.current_attack + 1 --0.25
	end
	if egg.current_attack >= egg.max_attack then
		egg:Kill(ability, attacker)
	else
		egg:SetHealth( (egg:GetMaxHealth() * ((egg.max_attack-egg.current_attack)/egg.max_attack)) )
	end
	local pfxName = "particles/units/heroes/hero_phoenix/phoenix_supernova_hit.vpcf"
	local pfx = ParticleManager:CreateParticle( pfxName, PATTACH_POINT_FOLLOW, egg )
	local attach_point = egg:ScriptLookupAttachment( "attach_hitloc" )
	ParticleManager:SetParticleControlEnt( pfx, 0, egg, PATTACH_POINT_FOLLOW, "attach_hitloc", egg:GetAttachmentOrigin(attach_point), true )
	ParticleManager:SetParticleControlEnt( pfx, 1, egg, PATTACH_POINT_FOLLOW, "attach_hitloc", egg:GetAttachmentOrigin(attach_point), true )
	--ParticleManager:ReleaseParticleIndex(pfx)
end

----------------------------------------------------------------------------------------------


modifier_mjz_phoenix_supernova_burn = class({})

function modifier_mjz_phoenix_supernova_burn:IsHidden() return false end
function modifier_mjz_phoenix_supernova_burn:IsPurgable() return true end
function modifier_mjz_phoenix_supernova_burn:IsDebuff() return true end

function modifier_mjz_phoenix_supernova_burn:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_supernova_radiance.vpcf"
end

function modifier_mjz_phoenix_supernova_burn:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
	}
end

function modifier_mjz_phoenix_supernova_burn:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("damage_per_sec")
end

if IsServer() then
	function modifier_mjz_phoenix_supernova_burn:OnCreated(table)
		self:StartIntervalThink(FrameTime())
	end
	function modifier_mjz_phoenix_supernova_burn:OnIntervalThink()
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local damage_per_sec = ability:GetSpecialValueFor("damage_per_sec")
		local hp_damage_per_sec = ability:GetSpecialValueFor("hp_damage_per_sec")
		local str_dmg = caster:GetStrength() * 20
		local damage = damage_per_sec + caster:GetMaxHealth() * (hp_damage_per_sec / 100)
		if _G._challenge_bosss > 1 then
			damage = damage + str_dmg * _G._challenge_bosss 
			for i = 1, _G._challenge_bosss do
				damage = math.floor(damage * 1.2)
			end 
		end

		ApplyDamage({
			victim = parent,
			attacker = caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType()
		})

		self:StartIntervalThink(1.0)
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
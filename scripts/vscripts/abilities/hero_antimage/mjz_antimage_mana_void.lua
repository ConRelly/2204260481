local MODIFIER_MINISTUN_NAME = 'modifier_mjz_antimage_mana_void_stunned'
LinkLuaModifier(MODIFIER_MINISTUN_NAME, "abilities/hero_antimage/mjz_antimage_mana_void.lua", LUA_MODIFIER_MOTION_NONE)

------------------------------------------------------------------------------------

mjz_antimage_mana_void = class({})
local ability_class = mjz_antimage_mana_void

function ability_class:GetAOERadius(  )
	return self:GetSpecialValueFor("mana_void_aoe_radius")	 -- return self.BaseClass.GetAOERadius(self)
end
function ability_class:GetCastRange(  )
	return self:GetSpecialValueFor("cast_range")	 -- return self.BaseClass.GetAOERadius(self)
end

function ability_class:OnAbilityPhaseStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	end
	return true
end

function ability_class:OnAbilityPhaseInterrupted()
	if IsServer() then
		if self.nFXIndex then
			ParticleManager:DestroyParticle( self.nFXIndex, true )
		end
	end
end

if IsServer() then
	function ability_class:OnSpellStart(keys)
		local caster = self:GetCaster()
		local ability = self
		local target = self:GetCursorTarget()

		if target:TriggerSpellAbsorb(ability) then return nil end

		local mana_void_ministun = ability:GetSpecialValueFor('mana_void_ministun')
		target:AddNewModifier(caster, ability, MODIFIER_MINISTUN_NAME, {duration = mana_void_ministun})

		self:_ApplyDamage()

		self:_FireEffect()

	end

	function ability_class:_ApplyDamage()
		local caster = self:GetCaster()
		local ability = self
		local target = self:GetCursorTarget()

		local mana_void_damage_per_mana = GetTalentSpecialValueFor(ability, 'mana_void_damage_per_mana')
		local mana_void_aoe_radius = ability:GetSpecialValueFor('mana_void_aoe_radius')

		local damage = 0
		if target:GetMaxMana() > 0 then
			-- local missing_mana = target:GetMaxMana() - target:GetMana()
			-- damage = missing_mana * mana_void_damage_per_mana
			damage = target:GetMaxMana() * mana_void_damage_per_mana
		end
		
		local damageTable = {
			victim = target,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			attacker = caster,
			ability = ability
		}

		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),
			target:GetAbsOrigin(),
			nil,
			mana_void_aoe_radius,
			ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),
			ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER,
			false
		)

		for _,enemy in pairs(enemies) do
			if not enemy:IsMagicImmune() then
				damageTable.victim = enemy
				ApplyDamage(damageTable)
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, enemy, damage, nil)
			end
		end
	end

	function ability_class:_FireEffect()
		local caster = self:GetCaster()
		local ability = self
		local target = self:GetCursorTarget()
		local mana_void_aoe_radius = ability:GetSpecialValueFor('mana_void_aoe_radius')

		local void_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_manavoid.vpcf", PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(void_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
		ParticleManager:SetParticleControl(void_pfx, 1, Vector(mana_void_aoe_radius,0,0))
		ParticleManager:ReleaseParticleIndex(void_pfx)

		EmitSoundOn("Hero_Antimage.ManaVoid", target)
	end
end

------------------------------------------------------------------------------------

modifier_mjz_antimage_mana_void_stunned = class({})
local modifier_stunned = modifier_mjz_antimage_mana_void_stunned

function modifier_stunned:IsHidden() return true end
function modifier_stunned:IsPurgable() return false end
function modifier_stunned:IsPurgeException() return true end
function modifier_stunned:IsStunDebuff() return true end

function modifier_stunned:GetEffectName() return "particles/generic_gameplay/generic_stunned.vpcf" end
function modifier_stunned:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

function modifier_stunned:CheckState()
    local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
    return state  
end

function modifier_stunned:DeclareFunctions()
    local decFuncs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
    return decFuncs
end

function modifier_stunned:GetOverrideAnimation()
    return ACT_DOTA_DISABLED
end


------------------------------------------------------------------------------------

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
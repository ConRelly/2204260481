
LinkLuaModifier('modifier_mjz_nyx_assassin_spiked_carapace', "abilities/hero_nyx_assassin/mjz_nyx_assassin_spiked_carapace.lua", LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier('modifier_mjz_nyx_assassin_spiked_carapace_stun', "abilities/hero_nyx_assassin/mjz_nyx_assassin_spiked_carapace.lua", LUA_MODIFIER_MOTION_NONE)


mjz_nyx_assassin_spiked_carapace = class({})
local ability_class = mjz_nyx_assassin_spiked_carapace

-- function ability_class:GetIntrinsicModifierName()
-- 	return "modifier_mjz_nyx_assassin_spiked_carapace"
-- end

function ability_class:GetManaCost(iLevel)
	local mana_cost_per = self:GetLevelSpecialValueFor("mana_cost_per", iLevel) --self:GetSpecialValueFor("mana_cost_per")
	local max_mana = self:GetCaster():GetMaxMana()
	local spend_mana = max_mana * mana_cost_per / 100
	return spend_mana
end

function ability_class:OnToggle()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self
		if self:GetToggleState() then
			caster:AddNewModifier(caster, ability, "modifier_mjz_nyx_assassin_spiked_carapace", {})
		else
			caster:RemoveModifierByName( "modifier_mjz_nyx_assassin_spiked_carapace" )
		end
	end
end


----------------------------------------------------------------------------

modifier_mjz_nyx_assassin_spiked_carapace = class({})
local modifier_class = modifier_mjz_nyx_assassin_spiked_carapace

function modifier_class:IsPassive() return false end
function modifier_class:IsPurgable() return false end
function modifier_class:IsHidden() return true end

-- function modifier_class:GetAttributes()
-- 	return MODIFIER_ATTRIBUTE_MULTIPLE
-- end

function modifier_class:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_class:GetEffectName()
	return "particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace.vpcf" 
end


if IsServer() then
	function modifier_class:DeclareFunctions()
		local funcs = {
		  -- MODIFIER_EVENT_ON_HEALTH_GAINED,
		--   MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		--   MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		--   MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		--   MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		--   MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
		  MODIFIER_EVENT_ON_TAKEDAMAGE,
		--   MODIFIER_EVENT_ON_ATTACK_LANDED
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		}
		return funcs
	end

	function modifier_class:GetModifierIncomingDamage_Percentage()
		return self:GetAbility():GetSpecialValueFor('damage_reduction_pct')
	end	

	function modifier_class:OnTakeDamage( params )
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local spell = self:GetAbility()
		local Attacker = params.attacker
		local Target = params.unit
		local Ability = params.inflictor
		local flDamage = params.damage
		local attacker = params.attacker
		local target = params.attacker
		local damage = params.damage

		if params.unit ~= self:GetParent() or Target == nil then
			-- print("OnTakeDamage: params.unit ~= self:GetParent()")
			return 0
		end
		if params.attacker == params.unit then return end
		if params.attacker:IsMagicImmune() then return end
		if not self:_IsFullyCastable() then 
			-- print("OnTakeDamage: not spell:IsFullyCastable()")
			return 0
		end

		local damage_reflect_pct = GetTalentSpecialValueFor(self:GetAbility(), "damage_reflect_pct")
		local re_damage = math.ceil( (params.damage * damage_reflect_pct / 100) * (1 + caster:GetSpellAmplification(false) / 4 ) )


		local isTarget = UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, caster:GetTeamNumber()) == UF_SUCCESS
		if isTarget and IsValidEntity(target) and target:IsAlive() then

			self:_AddStun(target)

			-- print("OnTakeDamage: ApplyDamage -> " .. tostring(re_damage))
			ApplyDamage ( {
				victim = target,
				attacker = self:GetParent(),
				damage = re_damage,
				damage_type = params.damage_type,
				ability = self:GetAbility(),
				damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			})
		else
			print("OnTakeDamage: not isTarget")
		end
	end

	function modifier_class:OnCreated(table)
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		self:StartIntervalThink(1.0)
	end

	function modifier_class:OnIntervalThink()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local mana_cost_per = ability:GetSpecialValueFor("mana_cost_per")

		if ability:GetToggleState() then
			local current_mana = parent:GetMana()
			local max_mana = parent:GetMaxMana()
			local spend_mana = max_mana * mana_cost_per / 100
			if current_mana > spend_mana then
				-- ability:SpendMana(flManaSpent, hAbility)
				ability:PayManaCost()
			else
				-- ability:ToggleAbility()
			end
		end
	end

	function modifier_class:_IsFullyCastable( )
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local mana_cost_per = ability:GetSpecialValueFor("mana_cost_per")

		if ability:GetToggleState() then
			local current_mana = parent:GetMana()
			local max_mana = parent:GetMaxMana()
			local spend_mana = max_mana * mana_cost_per / 100
			if current_mana > spend_mana then
				return true
			end
		end
		return false
	end

	function modifier_class:_AddStun(target)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
		local stun_interval = self:GetAbility():GetSpecialValueFor("stun_interval")
		local prev_stun_time = target.mjz_nyx_assassin_spiked_carapace_stun_time or 0
		if (GameRules:GetGameTime() - prev_stun_time) > stun_interval then
			target.mjz_nyx_assassin_spiked_carapace_stun_time = GameRules:GetGameTime()

			EmitSoundOn("Hero_NyxAssassin.SpikedCarapace.Stun", caster)
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace_hit.vpcf", PATTACH_POINT_FOLLOW, caster)
						ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
						ParticleManager:SetParticleControlEnt(nfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
						ParticleManager:SetParticleControl(nfx, 2, Vector(1,0,0))
						ParticleManager:ReleaseParticleIndex(nfx)

			target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
		end
	end

end

-----------------------------------------------------------------------------------------
--[[

modifier_mjz_nyx_assassin_spiked_carapace_stun = class({})
local modifier_stun_class = modifier_mjz_nyx_assassin_spiked_carapace_stun

function modifier_stun_class:IsPurgable() return true end
function modifier_stun_class:IsHidden() return false end

-- function modifier_stun_class:GetAttributes()
-- 	return MODIFIER_ATTRIBUTE_MULTIPLE
-- end

function modifier_stun_class:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_stun_class:GetEffectName()
	return "particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace.vpcf" 
end
]]




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
LinkLuaModifier("modifier_mjz_nyx_assassin_mana_burn", "abilities/hero_nyx_assassin/mjz_nyx_assassin_mana_burn.lua", LUA_MODIFIER_MOTION_NONE)


mjz_nyx_assassin_mana_burn = class({})
function mjz_nyx_assassin_mana_burn:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
	return self.BaseClass.GetBehavior(self)
end
function mjz_nyx_assassin_mana_burn:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("radius_scepter")
	else
		return self:GetSpecialValueFor("cast_range")
	end
end
function mjz_nyx_assassin_mana_burn:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasModifier("modifier_nyx_assassin_burrow") then
		return self:GetSpecialValueFor("cast_range") + self:GetCaster():CustomValue("nyx_assassin_burrow", "mana_burn_bonus_cast_range")
	else
		return self:GetSpecialValueFor("cast_range")
	end
end

function mjz_nyx_assassin_mana_burn:OnSpellStart()
	if not IsServer() then return end
	EmitSoundOn("Hero_NyxAssassin.ManaBurn.Cast", self:GetCaster())

	if self:GetCursorTarget():GetTeam() ~= self:GetCaster():GetTeam() then if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end end

	local target_list = {}

	if self:GetCaster():HasScepter() then
		target_list = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),
			self:GetCursorTarget():GetAbsOrigin(),
			nil, self:GetSpecialValueFor("radius_scepter"),
			self:GetAbilityTargetTeam(),
			self:GetAbilityTargetType(),
			self:GetAbilityTargetFlags(),
			FIND_ANY_ORDER, false
		)
	else
		table.insert(target_list, self:GetCursorTarget())
	end

	for _,enemy in pairs(target_list) do
		if enemy then
			
			local mana_to_burn = math.min(enemy:GetMana(), self:GetCaster():GetIntellect() * GetTalentSpecialValueFor(self, "int_damage_pct"))

			enemy:Script_ReduceMana(mana_to_burn, self)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, enemy, mana_to_burn, nil)

			ApplyDamage({
				victim = enemy,
				attacker = self:GetCaster(),
				damage = mana_to_burn,
				damage_type = self:GetAbilityDamageType(),
				ability = self,
			})

			local particle_manaburn_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_CUSTOMORIGIN, enemy)
			ParticleManager:SetParticleControlEnt(particle_manaburn_fx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:DestroyParticle(particle_manaburn_fx, false)
			ParticleManager:ReleaseParticleIndex(particle_manaburn_fx)

		end
	end
	EmitSoundOn("Hero_NyxAssassin.ManaBurn.Target", self:GetCursorTarget())
end

-----------------------------------------------------------------------------------------

function GetTalentSpecialValueFor(ability, value)
	local base = ability:GetSpecialValueFor(value)
	local talentName
	local kv = ability:GetAbilityKeyValues()
	for k,v in pairs(kv) do
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
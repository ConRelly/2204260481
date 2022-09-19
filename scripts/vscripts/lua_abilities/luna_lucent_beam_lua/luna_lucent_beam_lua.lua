-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
luna_lucent_beam_lua = class({})
LinkLuaModifier("modifier_generic_stunned_lua", "lua_abilities/generic/modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lucent_beam_ss_mult", "lua_abilities/luna_lucent_beam_lua/luna_lucent_beam_lua.lua", LUA_MODIFIER_MOTION_NONE)

function luna_lucent_beam_lua:OnAbilityPhaseStart()
	if not IsServer() then return end

	local precast_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_eclipse_precast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(precast_pfx,	0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(precast_pfx)
	return true
end

function luna_lucent_beam_lua:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function luna_lucent_beam_lua:GetManaCost(level)
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		local cooldown = self.BaseClass.GetManaCost(self, level) - 50
		return cooldown
	end
	return self.BaseClass.GetManaCost(self, level)
end

function luna_lucent_beam_lua:GetBehavior()
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_OPTIONAL_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
end

function luna_lucent_beam_lua:OnProjectileHit_ExtraData(target, location, data)
	if not IsServer() then return end
	
	if target and IsValidEntity(target) then
		EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Luna.ProjectileImpact", self:GetCaster())
	
		self:GetCaster():PerformAttack(target, false, true, true, false, false, false, false)
	end
end

--------------------------------------------------------------------------------

if IsServer() then
	function luna_lucent_beam_lua:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local position = self:GetCursorPosition()
		local damage = self:GetTalentSpecialValueFor("beam_damage") + (caster:GetAgility() * self:GetTalentSpecialValueFor("agi_multiplier"))
		local lvl = caster:GetLevel()
		local dark_moon_modif = "modifier_lucent_beam_ss_mult"
		if caster:HasModifier("modifier_super_scepter") then
			if caster:HasModifier("modifier_mjz_luna_under_the_moonlight_buff") then
				local modif_stack_count = caster:FindModifierByName("modifier_mjz_luna_under_the_moonlight_buff"):GetStackCount()
				damage = damage + lvl * modif_stack_count
			end
		end	

		if not caster:HasShard() and target:TriggerSpellAbsorb(self) then return end

		if caster:HasShard() then
			point = position
			AddFOWViewer(self:GetCaster():GetTeamNumber(), position, self:GetSpecialValueFor("radius"), 1, false)
		else
			point = target:GetAbsOrigin()
		end

		local targets = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false)

		for _,enemy in pairs(targets) do
			if caster:HasModifier("modifier_super_scepter") then
				if enemy and enemy:HasModifier(dark_moon_modif) then
					local modif_moon = enemy:FindModifierByName(dark_moon_modif)	
					if modif_moon then 
						local stacks_moon = modif_moon:GetStackCount()
						damage = math.floor( damage * (1 + (stacks_moon / 100)))
					end
				end	
			end	
			ApplyDamage({
				victim = enemy,
				attacker = caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self,
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			})
			if enemy then
				enemy:AddNewModifier(caster, self, "modifier_generic_stunned_lua", {duration = self:GetSpecialValueFor("stun_duration")})
				if caster:HasModifier("modifier_super_scepter") then
					if not enemy:HasModifier(dark_moon_modif) then
						enemy:AddNewModifier(caster, self, dark_moon_modif, {})
					else
						local modif_moon = enemy:FindModifierByName(dark_moon_modif)	
						if modif_moon then 
							local stacks_moon = modif_moon:GetStackCount()
							modif_moon:SetStackCount(stacks_moon + 1)
						end
					end	
				end	

				if math.random(100) < self:GetSpecialValueFor("new_moon_chance") then
					local moonlight_buff = self:GetCaster():FindModifierByName("modifier_mjz_luna_under_the_moonlight_buff")
					moonlight_buff:SetStackCount(moonlight_buff:GetStackCount() + 1)
				end
			end	

			local beam_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_lucent_beam.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControl(beam_pfx, 1, enemy:GetAbsOrigin())
			ParticleManager:SetParticleControlEnt(beam_pfx,	5, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(beam_pfx,	6, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(beam_pfx)
		end
		EmitSoundOn("Hero_Luna.LucentBeam.Cast", caster)

		if caster:HasShard() then
			local enemy_count = 0
			local shard_targets = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
			for _,enemy in pairs(shard_targets) do
				enemy_count = enemy_count + 1

				EmitSoundOnLocationWithCaster(point, "Hero_Luna.Attack", self:GetCaster())

				ProjectileManager:CreateTrackingProjectile({
					Target 				= enemy,
					vSourceLoc			= point,
					Ability 			= self,
					EffectName 			= self:GetCaster():GetRangedProjectileName() or "particles/units/heroes/hero_luna/luna_base_attack.vpcf",
					iMoveSpeed			= self:GetCaster():GetProjectileSpeed() or 900,
					bDrawsOnMinimap 	= false,
					bDodgeable 			= true,
					bIsAttack 			= true,
					bVisibleToEnemies 	= true,
					bReplaceExisting 	= false,
					flExpireTime 		= GameRules:GetGameTime() + 10,
					bProvidesVision 	= false,
				})

				if enemy_count >= (#shard_targets / 2) then
					break
				end
			end
			EmitSoundOnLocationWithCaster(position, "Hero_Luna.LucentBeam.Target", caster)
		else
			EmitSoundOn("Hero_Luna.LucentBeam.Target", target)
		end

		if #targets < 1 then
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_lucent_beam.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
			ParticleManager:SetParticleControl(particle, 1, position)
			ParticleManager:SetParticleControl(particle, 5, Vector(0,0,0))
			ParticleManager:SetParticleControl(particle, 6, Vector(0,0,0))
			ParticleManager:ReleaseParticleIndex(particle)
		end
	end
end

---SS mult Modifier
modifier_lucent_beam_ss_mult = class({})
function modifier_lucent_beam_ss_mult:IsHidden() return false end
function modifier_lucent_beam_ss_mult:IsDebuff() return true end
function modifier_lucent_beam_ss_mult:IsPurgable() return false end
function modifier_lucent_beam_ss_mult:GetTexture() return "darkmoon" end
function modifier_lucent_beam_ss_mult:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_lucent_beam_ss_mult:OnTooltip() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("SS_bonus") * self:GetStackCount() end end





--talents
function HasTalent(unit, talentName)
	if unit:HasAbility(talentName) then
		if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end
	return false
end

function GetTalentSpecialValueFor(ability, value)
	local base = ability:GetSpecialValueFor(value)
	local talentName
	local valueName
	local kv = ability:GetAbilityKeyValues()
	for k,v in pairs(kv) do
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
					valueName = m["LinkedSpecialBonusField"]
				end
			end
		end
	end
	if talentName then 
		local talent = ability:GetCaster():FindAbilityByName(talentName)
		if talent and talent:GetLevel() > 0 then
			valueName = valueName or 'value'
			base = base + talent:GetSpecialValueFor(valueName) 
		end
	end
	return base
end
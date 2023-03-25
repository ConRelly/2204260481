--[[Author: Nightborn
	Date: August 27, 2016
]]
require("lib/my")
require("lib/popup")
item_echo_wand = class({})


function item_echo_wand:CastFilterResult()
	if not IsServer() then return end
	if self.echo == nil then return UF_FAIL_CUSTOM end
	return UF_SUCCESS
end

function item_echo_wand:GetCustomCastError()
	if not IsServer() then return end
	if self.echo == nil then return "#dota_hud_error_echo_wand_no_spell" end
end

function item_echo_wand:GetIntrinsicModifierName() return "modifier_item_echo_wand" end
function item_echo_wand:OnSpellStart()
	local caster = self:GetCaster()
	if not caster:HasModifier("modifier_item_echo_wand_lock") then
		caster:AddNewModifier(caster, self, "modifier_item_echo_wand_lock", {})
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_rubick/rubick_nullfield_defensive.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(fx)
		EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	else
		caster:RemoveModifierByName("modifier_item_echo_wand_lock")
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_rubick/rubick_nullfield_defensive_splash.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(fx)
	end
end

LinkLuaModifier("modifier_item_echo_wand_lock", "items/echo_wand.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_echo_wand_lock = class({})
function modifier_item_echo_wand_lock:IsHidden() return false end
function modifier_item_echo_wand_lock:IsDebuff() return true end
function modifier_item_echo_wand_lock:IsPurgable() return false end
function modifier_item_echo_wand_lock:RemoveOnDeath() return false end
function modifier_item_echo_wand_lock:GetTexture()
	return "echo_wand_disabled"
end

LinkLuaModifier("modifier_item_echo_wand", "items/echo_wand.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_echo_wand = class({})
if IsServer() then
	function modifier_item_echo_wand:OnCreated(keys)
		local parent = self:GetParent()
		if parent and parent:IsRealHero() then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_echo_wand_thinker", {})
		end
	end
	function modifier_item_echo_wand:OnDestroy()
		local parent = self:GetParent()
		parent:RemoveModifierByName("modifier_item_echo_wand_thinker")
		if parent:HasModifier("modifier_item_echo_wand_lock") then
			parent:RemoveModifierByName("modifier_item_echo_wand_lock")
		end
	end
end
function modifier_item_echo_wand:IsHidden() return true end
function modifier_item_echo_wand:IsPurgable() return false end
function modifier_item_echo_wand:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
	}
end
function modifier_item_echo_wand:CheckState()
	return {[MODIFIER_STATE_CANNOT_MISS] = true}
end
function modifier_item_echo_wand:GetModifierAttackRangeBonus()
	local parent = self:GetParent()
	local bonus_range = parent:GetCastRangeBonus()
	return self:GetAbility():GetSpecialValueFor("attack_range_bonus") + bonus_range
end
function modifier_item_echo_wand:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end
function modifier_item_echo_wand:GetModifierDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("negative_damage")
end
function modifier_item_echo_wand:GetModifierProjectileSpeedBonus()
	return self:GetAbility():GetSpecialValueFor("projectile_speed")
end
function modifier_item_echo_wand:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("spell_amp")
end
function modifier_item_echo_wand:GetModifierTotal_ConstantBlock()
	local block = self:GetAbility():GetSpecialValueFor("block")
	local parent = self:GetParent()
	local level = parent:GetLevel()
	local finalBlock = math.ceil(parent:GetMaxMana() / block)
	if level < 30 then
		finalBlock = finalBlock / 2
	end
	return finalBlock
end
function modifier_item_echo_wand:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("int_bonus")
end
function modifier_item_echo_wand:GetModifierHealthBonus()
	local hp = self:GetAbility():GetSpecialValueFor("hp_bonus")
	local parent = self:GetParent()
	local finalhp = math.ceil(parent:GetMaxMana() / hp)
	return finalhp
end
function modifier_item_echo_wand:GetModifierFixedAttackRate()
	if not IsServer() then return nil end
	local parent = self:GetParent()
	if not parent:HasModifier("modifier_item_echo_wand") then return end
	local level = parent:GetLevel()
	local wd_ult = "witch_doctor_custom_death_skull"
	local rate = self:GetAbility():GetSpecialValueFor("fixed_attack_rate")
	if level > 30 then
		rate = 0.4
		if parent:HasAbility(wd_ult) then
			rate = 0.2
		end		
	end
	if level > 55 then
		rate = 0.3
		if parent:HasAbility(wd_ult) then
			rate = 0.1
		end		
	end
	if parent:HasModifier("modifier_broken_wings") then
		local BrokenWings = parent:FindItemInInventory("item_broken_wings")
		rate = BrokenWings:GetSpecialValueFor("mimic_mace_attack_rate")
		if parent:HasAbility(wd_ult) then
			rate = 0.1
		end
	end
	return rate
end

LinkLuaModifier("modifier_item_echo_wand_thinker", "items/echo_wand.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_echo_wand_thinker = class({})
function modifier_item_echo_wand_thinker:IsHidden() return true end
function modifier_item_echo_wand_thinker:IsPurgable() return false end
function modifier_item_echo_wand_thinker:RemoveOnDeath() return false end
if IsServer() then
	function modifier_item_echo_wand_thinker:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		}
	end
	
	local exclude_table = {
		item_arcane_boots = true,
		item_custom_refresher = true,
		item_custom_ex_machina = true,
		item_guardian_greaves = true,
		item_conduit = true,
		item_custom_fusion_rune = true,
		item_black_king_bar = true,
		item_pocket_tower = true,
		item_pocket_barracks = true,
		item_pocket_rax = true,
		item_pocket_rax_ranged = true,
		item_echo_wand = true,
		item_imba_silver_edge = true,
		item_silver_edge = true,
		item_god_slayer = true,
		item_pipe_2 = true,
		item_minotaur_horn = true,
		item_random_get_ability = true,
		item_random_get_ability_onlvl = true,
		item_random_get_ability_spell = true,
		item_resurection_pendant = true,
		item_formidable_chest = true,
		item_mjz_attribute_mail = true,
		item_plain_perma = true,
		item_earth_rapier = true,
		item_high_tech_boots2 = true,
		item_manta = true,
		item_mjz_manta_2 = true,
		item_great_manta = true,
		item_illusionsts_cape = true,
		item_life_greaves = true,
		item_master_of_weapons_sword = true,
		item_master_of_weapons_sword2 = true,
		item_master_of_weapons_sword3 = true,
		item_master_of_weapons_sword4 = true,
		item_master_of_weapons_sword5 = true,
		item_mjz_bloodstone_ultimate_edible = true,
		item_thunder_gods_might = true,
		item_thunder_gods_might2 = true,
		--mjz_doom_bringer_devour = true,
		--mjz_clinkz_soul_pact = true,
		frostivus2018_clinkz_burning_army = true,
		rubick_spell_steal = true,
		dark_seer_custom_dark_clone_2 = true,
		disruptor_custom_ion_hammer = true,
		lone_druid_spirit_bear = true,
		mars_arena_of_blood_lua = true,
		monkey_king_wukongs_command = true,
		oracle_false_promise = true,
		shadow_shaman_mass_serpent_ward = true,
		skeleton_king_vampiric_aura = true,
		mjz_spectre_reality = true,
		mjz_spectre_haunt_single = true,
		treant_custom_ultimate_sacrifice = true,
		undying_custom_decay = true,
		undying_tombstone = true,
		warlock_rain_of_chaos = true,
		witch_doctor_maledict = true,
		mjz_faceless_the_world = true,
		juggernaut_omni_slash = true,
		item_dimensional_doorway = true,
		--mjz_elder_titan_earth_splitter = true,
		mjz_broodmother_spawn_spiderlings = true,
		mjz_troll_warlord_battle_trance = true,
		ember_spirit_fire_remnant = true,
		ember_spirit_activate_fire_remnant = true,
		chen_custom_holy_persuasion = true,
		shredder_chakram = true,
		shredder_chakram_2 = true,
		legion_commander_custom_duel = true,
		enigma_demonic_conversion = true,
		zuus_cloud = true,
		item_remove_ability = true,
		viper_nethertoxin = true,
		abaddon_borrowed_time = true,
		doom_devour_lua = true,
		mjz_axe_berserkers_call = true,
		mjz_skeleton_king_ghost = true,
		--centaur_stampede = true,   --does not have dmg reduction anymore
		mjz_templar_assassin_refraction = true,
		hoodwink_sharpshooter_release = true,
		brewmaster_primal_split = true,
		omniknight_guardian_angel = true,
		hoodwink_sharpshooter = true,
		mjz_ember_spirit_sleight_of_fist = true,
		furion_force_of_nature = true,
		dark_willow_terrorize_lua = true,
		life_stealer_infest = true,
		life_stealer_consume = true,
		shadow_demon_custom_hyperactivity = true,
		obsidian_destroyer_astral_imprisonment = true,
		clinkz_custom_wind_walk = true,
		mjz_tinker_quick_arm = true,
		obs_replay = true,
		item_video_file = true,
		guardian_angel = true,
		blood_madness = true,
		zanto_gari = true,
		arcane_supremacy = true,
		item_illusionsts_cape = true,
		item_custom_octarine_core2 = true,
		beastmaster_wild_axes = true,
		hw_sharpshooter = true,
		hw_sharpshooter_release = true,
		item_crit_edible = true,
		razor_eye_of_the_storm = true,
		item_pipe_of_dezun = true,
		item_auto_cast = true,
		item_auto_cast2 = true,
		item_hammer_of_the_divine = true,
		phantom_lancer_phantom_edge = true,
		treant_natures_form = true,
		dazzle_shallow_grave = true,
		aghanim_blink2 = true,
		item_imba_ultimate_scepter_synth2 = true,
		dazzle_good_juju = true,
		antimage_mana_overload = true,
		dzzl_good_juju = true,
		mjz_spectre_haunt = true,
		mjz_spectre_haunt_single = true,
		amalgamation = true,
		phantom_reflex = true,
		mjz_phoenix_supernova = true,
		enchantress_enchant = true,
		rubick_spell_steal = true,
		chaos_knight_phantasm = true,
		terrorblade_custom_reflection = true,
		dazzle_shadow_wave = true,
		reload_bullet = true,
		snapfire_lil_shredder = true,
		warlock_fatal_bonds = true,
		muerta_pierce_the_veil = true,
	}
	local include_table = {
		riki_blink_strike = true,
		phantom_assassin_phantom_strike = true,
		luna_eclipse_lua = true,
		--obsidian_destroyer_custom_sanity_eclipse = true,
	}
	function modifier_item_echo_wand_thinker:OnCreated()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.echo = nil
		self.targetType = nil
		self.cooldown_reduction = self.ability:GetSpecialValueFor("cooldown_reduction")
		self.minimum_cooldown = self.ability:GetSpecialValueFor("minimum_cooldown")
	end
	
	function modifier_item_echo_wand_thinker:OnAbilityExecuted(keys)
		if not IsServer() then return end
		--if not keys.ability:ProcsMagicStick() then return end   -- items and a lot of skills will be broken if this is enabled
		self.hit = true
		if keys.unit == self.parent and not self.parent:HasModifier("modifier_item_echo_wand_lock") and not ability_behavior_includes(keys.ability, DOTA_ABILITY_BEHAVIOR_CHANNELLED) and not keys.ability:IsToggle() then
			if not exclude_table[keys.ability:GetAbilityName()] then
				if (ability_behavior_includes(keys.ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and (keys.ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_ENEMY or keys.ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_BOTH)) or include_table[keys.ability:GetAbilityName()] then
					self.targetType = 0
					self.echo = keys.ability
				elseif ability_behavior_includes(keys.ability, DOTA_ABILITY_BEHAVIOR_POINT) then
					self.targetType = 1
					self.echo = keys.ability
				elseif ability_behavior_includes(keys.ability, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
					self.targetType = 2
					self.echo = keys.ability
				elseif (ability_behavior_includes(keys.ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and (keys.ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_FRIENDLY)) then	
					self.targetType = 3
					self.echo = keys.ability
				end
				item_echo_wand.echo = self.echo
			end
		end
		if keys.unit == self.parent and keys.ability:GetCooldown(keys.ability:GetLevel() - 1) > 1.5 and self.ability:GetCooldownTimeRemaining() > self.minimum_cooldown then
			local cooldown = self.ability:GetCooldownTimeRemaining() - (keys.ability:GetCooldown(keys.ability:GetLevel() - 1) / 3.5)
			if cooldown < self.minimum_cooldown then
				cooldown = self.minimum_cooldown
			end
			if keys.ability and keys.ability:GetName() == "item_tome_of_knowledge" then return end
			self.ability:EndCooldown()
			self.ability:StartCooldown(cooldown)
			if keys.ability and keys.ability:GetName() == "phantom_lancer_phantom_edge" then
				keys.ability:EndCooldown()
				keys.ability:StartCooldown(1.0)
			end
		end	
	end

	function modifier_item_echo_wand_thinker:OnAttackLanded(keys)
		if not IsServer() then return end
		local attacker = keys.attacker
		if attacker == self.parent and not keys.target:IsNull() and self.hit then 
			if self.echo and self.ability:IsCooldownReady() and not self.echo:IsNull() and IsValidEntity(self.echo) then
				--if self.echo:IsOwnersManaEnough() then
				if self.parent:HasModifier("modifier_atomic_samurai_focused_atomic_slash_2") then return end
				local cooldown = self.echo:GetCooldown(self.echo:GetLevel() - 1)
				if cooldown < self.minimum_cooldown then
					cooldown = self.minimum_cooldown
				end
				local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_rubick/rubick_nullfield_offensive.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
				ParticleManager:SetParticleControlEnt(fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(fx)
--				Timers:CreateTimer(0.05, function()
--					if not keys.target:IsNull() and IsValidEntity(keys.target) then
						if self.targetType == 0 then
							self.parent:SetCursorCastTarget(keys.target)
						elseif self.targetType == 1 then
							self.parent:SetCursorPosition(keys.target:GetAbsOrigin())
						elseif self.targetType == 2 then
							self.parent:SetCursorTargetingNothing(true)
						elseif self.targetType == 3 then
							self.parent:SetCursorCastTarget(self.parent)
						end
						if self.echo and not self.echo:IsNull() then
							self.ability:StartCooldown(cooldown * attacker:GetCooldownReduction())
							self.echo:OnSpellStart()
						end	
						if self.echo and not self.echo:IsNull() then
							if self.echo:GetName() == "vengefulspirit_wave_of_terror_lua" then
								if self.parent:HasModifier("modifier_atomic_samurai_focused_atomic_slash_2") then
									local lvl = attacker:GetLevel()
									local extra_time = (cooldown * 20)
									if lvl > 30 then
										extra_time = extra_time + lvl * 2
									end	
									self.ability:EndCooldown()
									self.ability:StartCooldown(extra_time * attacker:GetCooldownReduction())
								end	
							end	
						end	
						if attacker:HasModifier("modifier_ogre_magi_multicast_n") then
							local interval = attacker:CustomValue("ogre_magi_multicast_n", "interval")
							local multicast_1_chance = self.ability:GetSpecialValueFor("multicast_1")
							local multicast_2_chance = self.ability:GetSpecialValueFor("multicast_2")
							local multicast_3_chance = self.ability:GetSpecialValueFor("multicast_3")
							local multicast_4_chance = self.ability:GetSpecialValueFor("multicast_4")
							local chance = RandomInt(1,100)
							local casts = 0
							if HasSuperScepter(attacker) then
								chance = chance / 2
							end
							if chance <= multicast_4_chance then
								casts = 4
							elseif chance <= multicast_3_chance then
								casts = 3
							elseif chance <= multicast_2_chance then
								casts = 2
							elseif chance <= multicast_1_chance then
								casts = 1
							end
							if casts > 0 then 
								for count = 2, casts + 1 do
									Timers:CreateTimer(count * interval, function()
										if self.echo and not self.echo:IsNull() and IsValidEntity(self.echo) then
											if self.parent:IsNull() then return end
											if not self.parent:IsAlive() then return end
											if not self.parent:HasModifier("modifier_ogre_magi_multicast_n") then return end

											if self.targetType == 0 then
												if keys.target:IsNull() then return end
												if not keys.target:IsAlive() then return end
												self.parent:SetCursorCastTarget(keys.target)
											elseif self.targetType == 1 then
												if keys.target:IsNull() then return end
												if not keys.target:IsAlive() then return end												
												self.parent:SetCursorPosition(keys.target:GetAbsOrigin())
											elseif self.targetType == 2 then
												self.parent:SetCursorTargetingNothing(true)
											elseif self.targetType == 3 then
												self.parent:SetCursorCastTarget(self.parent)
											end
											if self.echo and not self.echo:IsNull() then
												self.echo:OnSpellStart()
											end

											if not attacker:HasModifier("modifier_ogre_magi_multicast_n_no_animation") then
												local counter_speed = 2

												if count == casts + 1 then
													counter_speed = 1
												end
												if count - 1 > 3 then sound = 3 else sound = count end

												local effect_cast = ParticleManager:CreateParticle("particles/custom/abilities/heroes/ogre_magi_multicast/ogre_magi_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, attacker)
												ParticleManager:SetParticleControl(effect_cast, 1, Vector(count, counter_speed, 0))
												ParticleManager:SetParticleControl(effect_cast, 2, Vector(0, counter_speed, 0))
												ParticleManager:ReleaseParticleIndex(effect_cast)
												local sound_line = math.min(sound -1, 3)
												local sound_cast = "Hero_OgreMagi.Fireblast.x" .. sound_line
												if sound_line > 0 then
													attacker:EmitSoundParams(sound_cast, 0, 0.3, 0)
												end
											end	
										end
									end)
								end
							end	
						end
						--self.echo:SetChanneling(true)
						--self.echo:EndChannel(true)
						--self.echo:UseResources(true, false, false)
--					end
--				end)
				self.hit = false
			end
		end
	end
end


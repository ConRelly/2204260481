--LinkLuaModifier("modifier_spectre_einherjar_lua", "lua_abilities/spectre_einherjar_lua/modifier_spectre_einherjar_lua.lua", LUA_MODIFIER_MOTION_NONE)
require("lib/illusion")
require("lib/my")
LinkLuaModifier("modifier_death", "abilities/custom/dark_seer_custom_dark_clone_2", LUA_MODIFIER_MOTION_NONE)
dark_seer_custom_dark_clone_2 = class({})

function dark_seer_custom_dark_clone_2:OnSpellStart()
	local caster = self:GetCaster()
	local target = caster:GetCursorCastTarget()
	local spawn_location = caster:GetAbsOrigin()
	local duration = self:GetTalentSpecialValueFor("duration")
	local illusion_damage_incoming = self:GetSpecialValueFor("illusion_damage_incoming")
	local illusion_damage_outgoing = self:GetSpecialValueFor("illusion_damage_outgoing")
	if not target ~= nil and not IsValidEntity(target) then return end
	if not target:IsRealHero() then return end

	-- Create unit
	local illusion = CreateUnitByName(target:GetUnitName(), spawn_location, true, caster, caster:GetPlayerOwner(), caster:GetTeamNumber())
	if not illusion then self:EndCooldown() return end
	illusion:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
	illusion:AddNewModifier(caster, self, "modifier_arc_warden_tempest_double", {})
	illusion:AddNewModifier(caster, self, "modifier_death", {duration = duration})
	illusion:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
	if caster:HasScepter() then
		if caster:HasModifier("modifier_item_aghanims_shard") then
			illusion:AddNewModifier(caster, self, "modifier_item_aghanims_shard", {})
		end
		illusion:AddNewModifier(caster, self, "modifier_item_ultimate_scepter_consumed", {})
		if caster:HasModifier("modifier_super_scepter") then
			illusion:AddNewModifier(caster, self, "modifier_super_scepter", {})
		end
	end

	--set health
	illusion:SetHealth(target:GetHealth())
	illusion:SetMana(target:GetMana())
	while illusion:GetLevel() < target:GetLevel() do
		illusion:HeroLevelUp(false)
	end
	illusion:SetAbilityPoints(-1)
	for slot = 0, 8 do
		local oldAbility = illusion:GetAbilityByIndex(slot)
		if oldAbility and oldAbility:GetAbilityName() ~= "dawnbreaker_luminosity" then
			illusion:RemoveAbilityByHandle(oldAbility)
		end
	end
	copy_items(target, illusion)
	disable_inventory(illusion)

	local IllusionNotLearn = {
		["chen_custom_holy_persuasion"] = true,
		["dark_seer_custom_dark_clone_2"] = true,
		["rubick_spell_steal"] = true,
		["arc_warden_tempest_double"] = true,
		["dawnbreaker_luminosity"] = true,
		["obs_replay"] = true,
		["mjz_troll_warlord_battle_trance"] = true,
		["mjz_troll_warlord_battle_trance_scepter"] = true,
		["skeleton_king_reincarnation"] = true,
		["mjz_skeleton_king_ghost"] = true,
	}

	local playerHero = target
	local maxAbilities = playerHero:GetAbilityCount() - 1
	local skip = FrameTime()
	--print("illusion created")
	for abilitySlot = 0, maxAbilities do
		skip = skip + FrameTime()
		Timers:CreateTimer(skip, function()
			local ability = playerHero:GetAbilityByIndex(abilitySlot)
			if ability ~= nil then 
				local abilityLevel = ability:GetLevel()
				local abilityName = ability:GetAbilityName()
				if illusion and IllusionNotLearn[abilityName] ~= true and not illusion:HasAbility(abilityName) and not ability:IsAttributeBonus() then
					if illusion and abilityLevel > 0 then
						local illusionAbility = illusion:AddAbility(abilityName)
						illusionAbility:SetLevel(abilityLevel)
					end
				end
			end
		end)
	end

	illusion:SetHealth(target:GetHealth())
	illusion:SetMana(target:GetMana())

	-- Play sound effects
	local sound_cast = "Hero_Dark_Seer.Wall_of_Replica_Start"
	EmitSoundOn(sound_cast, caster)
end


modifier_death = class({})
function modifier_death:IsHidden() return true end
function modifier_death:IsPurgable() return false end
function modifier_death:RemoveOnDeath() return true end
function modifier_death:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MIN_HEALTH}
end
function modifier_death:OnDestroy()
	if IsServer() then
		kill_illusion(self:GetParent())
	end	
end
function modifier_death:OnTakeDamage(keys)
	if not IsServer() then return end
	local unit = keys.unit
	if unit == self:GetParent() then
		if keys.damage > unit:GetHealth() then
			kill_illusion(unit)
		end
	end
end
function modifier_death:GetMinHealth(keys) return 1 end


-- 获得天赋技能的数据值
function FindTalentValue(unit, talentName)
	if unit:HasAbility(talentName) then
		return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
	end
	return nil
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

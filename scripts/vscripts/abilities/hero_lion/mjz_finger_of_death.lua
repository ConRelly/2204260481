require("lib/timers")

LinkLuaModifier("modifier_mjz_finger_of_death_locker", "abilities/hero_lion/mjz_finger_of_death.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_finger_of_death_bonus", "abilities/hero_lion/mjz_finger_of_death.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_finger_of_death_death", "abilities/hero_lion/mjz_finger_of_death.lua", LUA_MODIFIER_MOTION_NONE)

mjz_finger_of_death = class({})
function mjz_finger_of_death:GetIntrinsicModifierName() return "modifier_mjz_finger_of_death_locker" end
function mjz_finger_of_death:GetAbilityTextureName()
	if self:GetCaster():HasScepter() then
		return "mjz_lion_finger_of_death_immortal"
	end
	return "mjz_finger_of_death"
end
function mjz_finger_of_death:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end
function mjz_finger_of_death:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("splash_radius_scepter")
	end
	return self:GetSpecialValueFor("cast_range")
end
function mjz_finger_of_death:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("cast_range_scepter")
	end
	return self:GetSpecialValueFor("cast_range")
end
function mjz_finger_of_death:GetCooldown(iLevel)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("cooldown_scepter")
	end
	return self.BaseClass.GetCooldown(self, iLevel)
end
function mjz_finger_of_death:GetManaCost(iLevel)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("mana_cost_scepter")
	end
	return self.BaseClass.GetManaCost(self, iLevel)
end


function mjz_finger_of_death:OnSpellStart_dagon()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local targets = {target}

		local damage_instances = 2

		local damage_delay = self:GetSpecialValueFor("damage_delay")
		local kill_grace_duration = self:GetSpecialValueFor("kill_grace_duration")
		local splash_radius = self:GetSpecialValueFor("splash_radius_scepter")
	 
		local base_damage = self:GetSpecialValueFor(value_if_scepter(caster, "damage_scepter", "damage"))
		local extra_int = GetTalentSpecialValueFor(self, "damage_per_int") * caster:GetIntellect(false) or 0
		local kill_count = caster:GetModifierStackCount("modifier_mjz_finger_of_death_bonus", nil)
		local has_ss = caster:HasModifier("modifier_super_scepter")
		local damage_per_kill = self:GetSpecialValueFor("damage_per_kill") 
		-- Apply the level-based multiplier
		local lvl = caster:GetLevel()
		local bonus_percentage = math.min(lvl * 0.5, 50) -- 0.5% per level until level 100 (max 50%)
		if lvl > 100 then
			bonus_percentage = bonus_percentage + ((lvl - 100) * 5) -- +5% per level after 100
		end
		-- Calculate the final damage per kill
		damage_per_kill = math.ceil(damage_per_kill * (1 + bonus_percentage / 100))

		if has_ss then
			if caster:HasModifier("modifier_item_imba_ultimate_scepter_synth_stats") and extra_int > 0 then
				local modif_stack = caster:FindModifierByName("modifier_item_imba_ultimate_scepter_synth_stats"):GetStackCount()
				extra_int = extra_int + modif_stack * 15
			end
		end	
        local damage = math.ceil((base_damage + extra_int + damage_per_kill * kill_count) / damage_instances)

		caster:EmitSound("Hero_Lion.FingerOfDeath")

		if caster:HasScepter() then
			targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, splash_radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		end

		for _, target in pairs(targets) do
			_PlayEffect(caster, target)

			local sound_default = "Hero_Lion.FingerOfDeathImpact"
			local sound_immortal = "Hero_Lion.FingerOfDeathImpact.Immortal"
			local sound_name = value_if_scepter(caster, sound_immortal, sound_default)
			target:EmitSound(sound_name)

			if not target:TriggerSpellAbsorb(self) then
                local modifier = target:FindModifierByName("modifier_mjz_finger_of_death_death")
                if modifier then
                    modifier:IncrementStackCount()
					if not caster:HasTalent("special_bonus_finger_of_death_health_inf_kill_duration") then
                    	modifier:SetDuration(kill_grace_duration * (1 - target:GetStatusResistance()), true)
					end
                else
					if caster:HasTalent("special_bonus_finger_of_death_health_inf_kill_duration") then
						modifier = target:AddNewModifier(caster, self, "modifier_mjz_finger_of_death_death", {})
					else	
                    	modifier = target:AddNewModifier(caster, self, "modifier_mjz_finger_of_death_death", {duration = kill_grace_duration * (1 - target:GetStatusResistance())})
					end	
                    modifier:SetStackCount(1)
                end

				for i = 1, damage_instances do
					Timers:CreateTimer(damage_delay * FrameTime(), function()
						if target ~= nil and IsValidEntity(target) and target:IsAlive() and (not target:IsMagicImmune() or caster:HasScepter()) then
							ApplyDamage({
								attacker = caster,
								victim = target,
								damage = damage,
								damage_type = DAMAGE_TYPE_MAGICAL,
								ability = self,
							})
						end
					end)
				end
			end
		end
	end
end
function mjz_finger_of_death:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local targets = {target}

        local damage_instances = 2

        local damage_delay = self:GetSpecialValueFor("damage_delay")
        local kill_grace_duration = self:GetSpecialValueFor("kill_grace_duration")
        local splash_radius = self:GetSpecialValueFor("splash_radius_scepter")
        local base_damage = self:GetSpecialValueFor(value_if_scepter(caster, "damage_scepter", "damage"))
        local extra_int = GetTalentSpecialValueFor(self, "damage_per_int") * caster:GetIntellect(false) or 0
        local kill_count = caster:GetModifierStackCount("modifier_mjz_finger_of_death_bonus", nil)
		local has_ss = caster:HasModifier("modifier_super_scepter")
		local damage_per_kill = self:GetSpecialValueFor("damage_per_kill") 
		-- Apply the level-based multiplier
		local lvl = caster:GetLevel()
		local bonus_percentage = math.min(lvl * 0.5, 50) -- 0.5% per level until level 100 (max 50%)
		if lvl > 100 then
			bonus_percentage = bonus_percentage + ((lvl - 100) * 5) -- +5% per level after 100
		end
		-- Calculate the final damage per kill
		print("Adamage_per_kill: "..damage_per_kill)
		damage_per_kill = math.ceil(damage_per_kill * (1 + bonus_percentage / 100))
		print("Bdamage_per_kill: "..damage_per_kill)
		if has_ss then
			if caster:HasModifier("modifier_item_imba_ultimate_scepter_synth_stats") and extra_int > 0 then
				local modif_stack = caster:FindModifierByName("modifier_item_imba_ultimate_scepter_synth_stats"):GetStackCount()
				extra_int = extra_int + modif_stack * 15
			end
		end	
        local damage = math.ceil((base_damage + extra_int + damage_per_kill * kill_count) / damage_instances)

		if has_ss then
			if caster:HasItemInInventory("item_mjz_dagon_v2") then
				self.can_use_dagon = false
				local Dagon = caster:FindItemInInventory("item_mjz_dagon_v2")
				damage = damage + (Dagon:GetCurrentCharges() * base_damage / damage_instances)

				Dagon:SetCurrentCharges(Dagon:GetCurrentCharges() + 2)
			end
		end

        caster:EmitSound("Hero_Lion.FingerOfDeath")

        if caster:HasScepter() then
            targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, splash_radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
        end

        for _, target in pairs(targets) do
            _PlayEffect(caster, target)

            local sound_default = "Hero_Lion.FingerOfDeathImpact"
            local sound_immortal = "Hero_Lion.FingerOfDeathImpact.Immortal"
            local sound_name = value_if_scepter(caster, sound_immortal, sound_default)
            target:EmitSound(sound_name)

            if not target:TriggerSpellAbsorb(self) then
                local modifier = target:FindModifierByName("modifier_mjz_finger_of_death_death")
                if modifier then
                    modifier:IncrementStackCount()
					if not caster:HasTalent("special_bonus_finger_of_death_health_inf_kill_duration") then
                    	modifier:SetDuration(kill_grace_duration * (1 - target:GetStatusResistance()), true)
					end
                else
					if caster:HasTalent("special_bonus_finger_of_death_health_inf_kill_duration") then
						modifier = target:AddNewModifier(caster, self, "modifier_mjz_finger_of_death_death", {})
					else	
                    	modifier = target:AddNewModifier(caster, self, "modifier_mjz_finger_of_death_death", {duration = kill_grace_duration * (1 - target:GetStatusResistance())})
					end	
                    modifier:SetStackCount(1)
                end

                for i = 1, damage_instances do
                    Timers:CreateTimer(damage_delay * FrameTime(), function()
                        if target ~= nil and IsValidEntity(target) and target:IsAlive() and (not target:IsMagicImmune() or caster:HasScepter()) then
                            ApplyDamage({
                                attacker = caster,
                                victim = target,
                                damage = damage,
                                damage_type = DAMAGE_TYPE_MAGICAL,
                                ability = self,
                            })
                        end
                    end)
                end
            end
        end
    end
end

--test on spawn spell
function mjz_finger_of_death:OnOwnerSpawned()
    if IsServer() then
        local caster = self:GetCaster()
        local modif_tohel = caster:HasModifier("modifier_lion_to_hell_and_back")
        -- Check if the caster has scepter and the effect hasn't been triggered yet
        if caster:HasScepter() and not caster.finger_of_death_triggered and modif_tohel then
            caster.finger_of_death_triggered = true
            
            local splash_radius = 10000
            local damage_instances = 2
            local damage_delay = self:GetSpecialValueFor("damage_delay")
            local kill_grace_duration = self:GetSpecialValueFor("kill_grace_duration")
            
            local base_damage = self:GetSpecialValueFor("damage_scepter")
            local extra_int = GetTalentSpecialValueFor(self, "damage_per_int") * caster:GetIntellect(false) or 0
            local kill_count = caster:GetModifierStackCount("modifier_mjz_finger_of_death_bonus", nil)
			local has_ss = caster:HasModifier("modifier_super_scepter")
			local damage_per_kill = self:GetSpecialValueFor("damage_per_kill") 
			-- Apply the level-based multiplier
			local lvl = caster:GetLevel()
			if has_ss then
				if caster:HasModifier("modifier_item_imba_ultimate_scepter_synth_stats") and extra_int > 0 then
					local modif_stack = caster:FindModifierByName("modifier_item_imba_ultimate_scepter_synth_stats"):GetStackCount()
					extra_int = extra_int + modif_stack * 15
					local bonus_percentage = math.min(lvl * 0.5, 50) -- 0.5% per level until level 100 (max 50%)
					if lvl > 100 then
						bonus_percentage = bonus_percentage + ((lvl - 100) * 5) -- +5% per level after 100
					end
					-- Calculate the final damage per kill
					damage_per_kill = math.ceil(damage_per_kill * (1 + bonus_percentage / 100))			
				end
			end	
			local damage = math.ceil((base_damage + extra_int + damage_per_kill * kill_count) / damage_instances) * 10

            if caster:HasModifier("modifier_super_scepter") then
                if caster:HasItemInInventory("item_mjz_dagon_v2") then
                    self.can_use_dagon = false
                    local Dagon = caster:FindItemInInventory("item_mjz_dagon_v2")
                    damage = damage + (Dagon:GetCurrentCharges() * base_damage / damage_instances)

                    Dagon:SetCurrentCharges(Dagon:GetCurrentCharges() + 2)
                end
            end

            caster:EmitSound("Hero_Lion.FingerOfDeath")

            local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, splash_radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

            for _, target in pairs(targets) do
                _PlayEffect(caster, target)

                local sound_immortal = "Hero_Lion.FingerOfDeathImpact.Immortal"
                target:EmitSound(sound_immortal)

                if not target:TriggerSpellAbsorb(self) then
                    local modifier = target:FindModifierByName("modifier_mjz_finger_of_death_death")
                    if modifier then
                        modifier:SetStackCount(modifier:GetStackCount() + 3)
                        if not caster:HasTalent("special_bonus_finger_of_death_health_inf_kill_duration") then
                            modifier:SetDuration(kill_grace_duration * (1 - target:GetStatusResistance()), true)
                        end
                    else
                        if caster:HasTalent("special_bonus_finger_of_death_health_inf_kill_duration") then
                            modifier = target:AddNewModifier(caster, self, "modifier_mjz_finger_of_death_death", {})
                        else    
                            modifier = target:AddNewModifier(caster, self, "modifier_mjz_finger_of_death_death", {duration = kill_grace_duration * (1 - target:GetStatusResistance())})
                        end    
                        modifier:SetStackCount(3)
                    end

                    for i = 1, damage_instances do
                        Timers:CreateTimer(damage_delay * FrameTime(), function()
                            if target ~= nil and IsValidEntity(target) and target:IsAlive() and (not target:IsMagicImmune() or caster:HasScepter()) then
                                ApplyDamage({
                                    attacker = caster,
                                    victim = target,
                                    damage = damage,
                                    damage_type = DAMAGE_TYPE_MAGICAL,
                                    ability = self,
                                })
                            end
                        end)
                    end
                end
            end
        end
    end
end

-- Reset the trigger when the hero dies
function mjz_finger_of_death:OnOwnerDied()
    if IsServer() then
        local caster = self:GetCaster()
        caster.finger_of_death_triggered = false
    end
end



function _PlayEffect(caster, target)
	local particle_name_normal = "particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf"
	local particle_name_ti8 = "particles/econ/items/lion/lion_ti8/lion_spell_finger_of_death_charge_ti8.vpcf"
	particle_name_ti8 = particle_name_normal
	local particle_name = value_if_scepter(caster, particle_name_ti8, particle_name_normal)
	
	local particle_finger_fx = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(particle_finger_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle_finger_fx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(particle_finger_fx, 2, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_finger_fx, 3, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_finger_fx, 4, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_finger_fx, 5, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_finger_fx, 6, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_finger_fx, 7, target:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(particle_finger_fx, 10, caster, PATTACH_ABSORIGIN, "attach_attack2", caster:GetAbsOrigin(), true)
	ParticleManager:DestroyParticle(particle_finger_fx, false)
	ParticleManager:ReleaseParticleIndex(particle_finger_fx)
end

--------------------------------------------------------------------------------

modifier_mjz_finger_of_death_bonus = class({})
function modifier_mjz_finger_of_death_bonus:IsBuff() return true end
function modifier_mjz_finger_of_death_bonus:IsPermanent() return true end
function modifier_mjz_finger_of_death_bonus:IsPurgable() return false end
function modifier_mjz_finger_of_death_bonus:RemoveOnDeath() return false end
function modifier_mjz_finger_of_death_bonus:OnCreated() if not IsServer() then return end self:SetStackCount(1) end
function modifier_mjz_finger_of_death_bonus:OnRefresh() if not IsServer() then return end self:IncrementStackCount() end
function modifier_mjz_finger_of_death_bonus:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP, MODIFIER_PROPERTY_HEALTH_BONUS} 
end
function modifier_mjz_finger_of_death_bonus:OnStackCountChanged(old)
	if IsServer() then self:GetParent():CalculateStatBonus(true) end
end
function modifier_mjz_finger_of_death_bonus:GetModifierHealthBonus()
	return self:GetStackCount() * talent_value(self:GetParent(), "special_bonus_finger_of_death_health_per_kill")
end
function modifier_mjz_finger_of_death_bonus:OnTooltip()
	local ability = self:GetAbility()
	if ability == nil then return 0 end
	local damage_per_kill = ability:GetSpecialValueFor("damage_per_kill") * self:GetStackCount()
	local caster = self:GetCaster()
	local has_ss = caster:HasModifier("modifier_super_scepter")
	if has_ss then
		-- Apply the level-based multiplier
		local lvl = caster:GetLevel()
		local bonus_percentage = math.min(lvl * 0.5, 50) -- 0.5% per level until level 100 (max 50%)
		if lvl > 100 then
			bonus_percentage = bonus_percentage + ((lvl - 100) * 5) -- +5% per level after 100
		end
		-- Calculate the final damage per kill
		damage_per_kill = math.ceil(damage_per_kill * (1 + bonus_percentage / 100))
	end
	return damage_per_kill
end

---------------------------------------------------------------------------------

modifier_mjz_finger_of_death_locker = class({})
function modifier_mjz_finger_of_death_locker:IsHidden() return true end
function modifier_mjz_finger_of_death_locker:OnCreated()
	if not IsServer() then return end
	--self:StartIntervalThink(FrameTime())
end
--[[ function modifier_mjz_finger_of_death_locker:OnIntervalThink()
	if not IsServer() then return end
	if self:GetParent():GetUnitName() == "npc_dota_hero_lion" then
		if self:GetParent():HasItemInInventory("item_mjz_dagon_v2") then
			if self:GetParent():HasScepter() and not self:GetParent():HasModifier("modifier_super_scepter") and not self:GetParent():HasItemInInventory("item_lions_cursed_item_slot") then
				local hItem1 = self:GetParent():GetItemInSlot(16)
				if hItem1 ~= nil then self:GetParent():DropItem(hItem1, true, true) end
				local hero = PlayerResource:GetSelectedHeroEntity(self:GetParent():GetPlayerID())
				hero:AddItemByName("item_lions_cursed_item_slot")
			end
			if self:GetParent():HasModifier("modifier_super_scepter") and self:GetParent():HasModifier("modifier_item_imba_ultimate_scepter_synth_stats") and self:GetParent():HasItemInInventory("item_lions_cursed_item_slot") then
				if self:GetParent():FindModifierByName("modifier_item_imba_ultimate_scepter_synth_stats"):GetStackCount() >= 5 then
					self:GetParent():TakeItem(self:GetParent():FindItemInInventory("item_lions_cursed_item_slot"))
					--self:GetParent():RemoveItem(self:GetParent():FindItemInInventory("item_lions_cursed_item_slot"))
					caster:TakeItem(ability)
				end
			end
		end
	end
end ]]
function modifier_mjz_finger_of_death_locker:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end

function modifier_mjz_finger_of_death_locker:GetModifierOverrideAbilitySpecial(params)
	if self:GetParent() == nil or params.ability == nil then return 0 end

	if self:GetParent():GetUnitName() == "npc_dota_hero_lion" and params.ability:GetAbilityName() == "item_mjz_dagon_v2" and params.ability_special_value == "splash_radius_scepter" then return 1 end

	return 0
end

function modifier_mjz_finger_of_death_locker:GetModifierOverrideAbilitySpecialValue(params)
	if self:GetParent():GetUnitName() == "npc_dota_hero_lion" and params.ability:GetAbilityName() == "item_mjz_dagon_v2" and params.ability_special_value == "splash_radius_scepter" then
		local SpecialLevel = params.ability_special_level
		return self:GetAbility():GetSpecialValueFor("splash_radius_scepter")--params.ability:GetLevelSpecialValueNoOverride("splash_radius_scepter", SpecialLevel) + LionRange
	end

	return 0
end

---------------------------------------------------------------------------------


modifier_mjz_finger_of_death_death = class({})
function modifier_mjz_finger_of_death_death:IsHidden() return false end
function modifier_mjz_finger_of_death_death:IsPurgable() return false end
function modifier_mjz_finger_of_death_death:DeclareFunctions()
    return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_mjz_finger_of_death_death:OnTooltip()
	local ability = self:GetAbility()
	if ability == nil then return 0 end
	local damage_per_kill = ability:GetSpecialValueFor("damage_per_kill") * self:GetStackCount()
	local caster = self:GetCaster()
	local has_ss = caster:HasModifier("modifier_super_scepter")
	if has_ss then
		-- Apply the level-based multiplier
		local lvl = caster:GetLevel()
		local bonus_percentage = math.min(lvl * 0.5, 50) -- 0.5% per level until level 100 (max 50%)
		if lvl > 100 then
			bonus_percentage = bonus_percentage + ((lvl - 100) * 5) -- +5% per level after 100
		end
		-- Calculate the final damage per kill
		damage_per_kill = math.ceil(damage_per_kill * (1 + bonus_percentage / 100))
	end
	return damage_per_kill
end
function modifier_mjz_finger_of_death_death:OnRemoved()
    if not IsServer() then return end
    if not self:GetParent():IsAlive() then
        self:GetParent():EmitSoundParams("Hero_Lion.KillCounter", 1, 0.5, 0)
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local bonus_modifier = caster:FindModifierByName("modifier_mjz_finger_of_death_bonus")
        if bonus_modifier then
            bonus_modifier:SetStackCount(bonus_modifier:GetStackCount() + self:GetStackCount())
        else
            bonus_modifier = caster:AddNewModifier(caster, ability, "modifier_mjz_finger_of_death_bonus", {})
            bonus_modifier:SetStackCount(self:GetStackCount())
        end
    end
end
--------------------------------------------------------------------------------

function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
end

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

function GrantItemDropToHero(hPlayerHero, szItemName)
	local hItem = hPlayerHero:AddItemByName(szItemName)

	if hItem == nil then
		local newItem = CreateItem(szItemName, hPlayerHero, hPlayerHero)
		newItem:SetPurchaseTime(0)
		newItem:SetSellable(true)
		local drop = CreateItemOnPositionSync(hPlayerHero:GetAbsOrigin(), newItem)
		local dropTarget = hPlayerHero:GetAbsOrigin() + RandomVector(RandomFloat(50, 150))
		newItem:LaunchLoot(false, 150, 0.75, dropTarget, nil)

		return newItem
	end
	return hItem
end

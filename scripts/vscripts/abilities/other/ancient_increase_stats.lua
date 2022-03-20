LinkLuaModifier("modifier_ancient_increase_stats", "abilities/other/ancient_increase_stats.lua", LUA_MODIFIER_MOTION_NONE)

ancient_increase_stats = class({})
function ancient_increase_stats:GetIntrinsicModifierName() return "modifier_ancient_increase_stats" end


modifier_ancient_increase_stats = class({})
function modifier_ancient_increase_stats:IsHidden() return true end
function modifier_ancient_increase_stats:IsPurgable() return false end
function modifier_ancient_increase_stats:OnCreated()
	self.previous_round = 0
	self:StartIntervalThink(0.5)
end
function modifier_ancient_increase_stats:OnIntervalThink()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local health_base = ability:GetSpecialValueFor("health_base")
	local health_per_round = ability:GetSpecialValueFor("health_per_round")
	local armor_base = ability:GetSpecialValueFor("armor_base")
	local armor_per_round = ability:GetSpecialValueFor("armor_per_round")
	if IsServer() then
		if not _G._hardMode then
			local AncientImmunity = false
			local FindTowers = FindUnitsInRadius(parent:GetTeamNumber(), parent:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
			for _, tower in pairs(FindTowers) do
				if tower:HasModifier("modifier_tower_increase_stats") then
					AncientImmunity = true
					break
				end
			end
			if AncientImmunity == true then
				if not parent:HasModifier("modifier_invulnerable") then
					parent:AddNewModifier(parent, nil, "modifier_invulnerable", {})
				end
			elseif AncientImmunity == false then
				if parent:HasModifier("modifier_invulnerable") then
					parent:RemoveModifierByName("modifier_invulnerable")
				end
			end
		elseif AncientImmunity == true then
			if parent:HasModifier("modifier_invulnerable") then
				parent:RemoveModifierByName("modifier_invulnerable")
				AncientImmunity = false
			end
		end

		if parent and not parent:IsNull() and parent:IsAlive() then
			local round = _G.RoundNumber
			local part3 = GameRules.GLOBAL_endlessHard_started
			if round and self.previous_round < round then
				
				-- Health
				local maxHealth = health_base + (health_per_round * round)
				if part3 then
					maxHealth = 150000  --health_base + (health_per_round * round) * 10
				end
				local health = maxHealth
			
				if round == self.previous_round then
					health = maxHealth * parent:GetHealthPercent() * 0.01
				end
			
				parent:SetMaxHealth(maxHealth)
				parent:SetBaseMaxHealth(maxHealth)
				parent:SetHealth(health)

				-- Armor
				local armor = armor_base + (armor_per_round * round)
				if part3 then
					armor = 150 --armor_base + (armor_per_round * round) * 20
				end
				parent:SetPhysicalArmorBaseValue(armor)

				self.previous_round = round

				--[[ if Cheats:IsEnabled() then
					if not parent:HasModifier("modifier_invulnerable") then
						parent:AddNewModifier(parent, nil, "modifier_invulnerable", {})
					end
				end ]]					
			end
		end
	end
end


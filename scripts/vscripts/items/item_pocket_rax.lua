
LinkLuaModifier("modifier_rax_behavior", "abilities/other/rax_behavior.lua", LUA_MODIFIER_MOTION_NONE)


item_pocket_rax = class({})

if IsServer() then
	function item_pocket_rax:CastFilterResultLocation(target)
		local caster = self:GetCaster()
		local buldings_range = 200
		local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, target, nil, 200, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, 0, false)
		local buildings = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, target, nil, 200, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BUILDING, 0, 0, false)
		if #units>0 or #buildings>0 then
			return UF_FAIL_CUSTOM
		end
		local buildings2 = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, target, nil, 20000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BUILDING, 0, 0, false)
		if self:GetAbilityName() == "item_pocket_rax_ranged" then
			if #buildings2>0 then
				for _, building in pairs(buildings2) do
					if building and IsValidEntity(building) then
						local building_name = building:GetUnitName()
						if building_name and building_name == "npc_dota_goodguys_range_rax_mid" then
							return UF_FAIL_CUSTOM
						end	
					end	
				end	
			end
		else
			if #buildings2>0 then
				for _, building in pairs(buildings2) do
					if building and IsValidEntity(building) then
						local building_name = building:GetUnitName()
						if building_name and building_name == "npc_dota_goodguys_melee_rax_mid" then
							return UF_FAIL_CUSTOM
						end	
					end	
				end	
				
			end				
		end	
		return UF_SUCCESS
	end

    function item_pocket_rax:OnSpellStart()
        self.target_pos = self:GetCursorPosition()
		local unitName = "npc_dota_creep_goodguys_melee"
		local buildingName = "npc_dota_goodguys_melee_rax_mid"
		local caster = self:GetCaster()
		if self:GetAbilityName() == "item_pocket_rax_ranged" then
			unitName = "npc_dota_creep_goodguys_ranged"
			buildingName = "npc_dota_goodguys_range_rax_mid"
		end

		CreateUnitByNameAsync(
			buildingName,
			self.target_pos,
			true,
			caster,
			nil,
			caster:GetTeamNumber(),
			function(tower)
				tower:SetControllableByPlayer(caster:GetPlayerID(), true)
				tower:SetAbsOrigin(self.target_pos)
				tower:SetOwner(caster)
				tower:SetInvulnCount(0)
				tower:AddNewModifier(caster, self, "modifier_rax_behavior", {name = unitName})
				self:SpendCharge(0.01)
			end
		)
							
    end
end
item_pocket_rax_ranged = class(item_pocket_rax)
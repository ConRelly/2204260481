LinkLuaModifier("modifier_newking_buff", "abilities/bosses/custom_new_king_reincarnation.lua", LUA_MODIFIER_MOTION_NONE)

modifier_newking_buff = class({})

function modifier_newking_buff:IsHidden() return true end
function modifier_newking_buff:IsPurgable() return false end
function modifier_newking_buff:IsDebuff() return false end

function modifier_newking_buff:OnCreated(kv)
	if IsServer() then
		self.bonus_damage = kv.bonus_damage or 0
		self:SetHasCustomTransmitters(true)
	end
end

function modifier_newking_buff:AddCustomTransmitterData()
	return {
		bonus_damage = self.bonus_damage,
	}
end

function modifier_newking_buff:HandleCustomTransmitterData(data)
	self.bonus_damage = data.bonus_damage
end

function modifier_newking_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_newking_buff:GetModifierBaseDamageOutgoing_Percentage()
	return self.bonus_damage or 0
end

local REINCARNATION_SPAWNS = {
	["custom_new_king_reincarnation"] = {
		bonus_damage = 20,
		units = {
			{ name = "npc_boss_doom", count = 1 },
			{ name = "npc_dota_creature_snowball_tuskar_2", count = 2 },
			{ name = "npc_boss_skeleton_king_angry", count = 1 },
		}
	},
	["custom_new_king_reincarnation_3"] = {
		bonus_damage = 50,
		units = {
			{ name = "npc_boss_tidehunter_2", count = 1 },
			{ name = "npc_boss_skeleton_king_ultimate", count = 1 },
		}
	},
	["custom_new_king_reincarnation_4"] = {
		bonus_damage = 50,
		units = {
			{ name = "npc_boss_wisp_new", count = 1 },
			{ name = "npc_boss_juggernaut_2", count = 1 },
		}
	},
	["custom_new_king_reincarnation_5"] = {
		bonus_damage = 50,
		units = {
			{ name = "npc_dota_creature_siltbreaker_2", count = 1 },
			{ name = "npc_boss_storegga", count = 1 },
		}
	},
	["custom_new_king_reincarnation_6"] = {
		bonus_damage = 70,
		units = {
			{ name = "npc_dota_boss_aghanim", count = 1 },
		}
	},
}

function OnDeathSpawn(keys)
	if not IsServer() then return end
	local caster = keys.caster
	local ability = keys.ability
	if not caster or caster:IsNull() then return end

	if caster._reincarnation_spawned then return end
	caster._reincarnation_spawned = true

	local abilityName = ability and not ability:IsNull() and ability:GetAbilityName() or ""
	local config = REINCARNATION_SPAWNS[abilityName]
	if not config then return end

	local origin = caster:GetAbsOrigin()
	local team = caster:GetTeamNumber()
	if not team or team == 0 then
		team = DOTA_TEAM_BADGUYS
	end

	local bonus_damage = config.bonus_damage or 0
	if ability and not ability:IsNull() then
		local val = ability:GetSpecialValueFor("bonus_damage")
		if val and val > 0 then
			bonus_damage = val
		end
	end

	for _, unitData in ipairs(config.units) do
		local count = unitData.count or 1
		for i = 1, count do
			local spawnPos = origin + RandomVector(RandomFloat(150, 450))
			CreateUnitByNameAsync(unitData.name, spawnPos, true, nil, nil, team, function(unit)
				if unit and not unit:IsNull() then
					FindClearSpaceForUnit(unit, spawnPos, true)
					if bonus_damage > 0 then
						unit:AddNewModifier(unit, nil, "modifier_newking_buff", { bonus_damage = bonus_damage })
					end
				end
			end)
		end
	end
end

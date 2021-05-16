local MODIFIERS_DIR = "cdota/modifiers/"
local MODIFIERS_LIST = {
	"modifier_chill_generic", "modifier_frozen_generic", 
	"modifier_mjz_g_frozen",
}

for _,mn in pairs(MODIFIERS_LIST) do
	LinkLuaModifier(mn, MODIFIERS_DIR .. mn, LUA_MODIFIER_MOTION_NONE)
end
if IsServer() then 
	require("cdota/ParticleManager")
	require("cdota/CDOTA_BaseNPC")
	require("cdota/CDOTABaseAbility")
	require("cdota/CDOTA_Modifier_Lua")
end
---------------------------------------------------------------------------------------------------

function ActualRandomVector(maxLength, flMinLength)
	local minLength = flMinLength or 0
	return RandomVector(RandomInt(minLength, maxLength))
end

function CalculateDistance(ent1, ent2, b3D)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local vector = (pos1 - pos2)
	if b3D then
		return vector:Length()
	else
		return vector:Length2D()
	end
end

function CalculateDirection(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local direction = (pos1 - pos2):Normalized()
	direction.z = 0
	return direction
end


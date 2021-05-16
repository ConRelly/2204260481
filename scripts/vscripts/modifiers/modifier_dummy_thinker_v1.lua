
--[[
    https://github.com/MouJiaoZi/dota_balance_in_imbalance/blob/master/game/scripts/vscripts/modifier/modifier_dummy_thinker.lua
]]

modifier_dummy_thinker_v1 = class({})

function modifier_dummy_thinker_v1:IsDebuff()			return false end
function modifier_dummy_thinker_v1:IsHidden() 			return true end
function modifier_dummy_thinker_v1:IsPurgable() 		return false end
function modifier_dummy_thinker_v1:IsPurgeException() 	return false end
function modifier_dummy_thinker_v1:CheckState() 
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    } 
end

function modifier_dummy_thinker_v1:OnCreated(keys)
	if IsServer() and IsInToolsMode() and self:GetParent():GetName() == "npc_dota_thinker" then
		--self:StartIntervalThink(0.3)
		self:OnIntervalThink()
	end
	if IsServer() then
		self.kvtable = keys
	end
end

function modifier_dummy_thinker_v1:OnIntervalThink()
	DebugDrawCircle(self:GetParent():GetAbsOrigin(), Vector(255,0,0), 100, 50, true, 0.3)
	if self:GetAbility() then
		DebugDrawText(self:GetParent():GetAbsOrigin(), self:GetAbility():GetAbilityName(), false, 0.3)
	end
end

function modifier_dummy_thinker_v1:OnDestroy()
	if IsServer() then
		if self.kvtable.destroy_sound then
			self:GetParent():EmitSound(self.kvtable.destroy_sound)
		end
		self.kvtable = nil
	end
end

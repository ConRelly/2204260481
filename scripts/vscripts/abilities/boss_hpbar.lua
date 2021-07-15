-----------------
-- Boss HP Bar --
-----------------
boss_hpbar = boss_hpbar or class({})
LinkLuaModifier("modifier_boss_hpbar", "abilities/boss_hpbar.lua", LUA_MODIFIER_MOTION_NONE)
function boss_hpbar:GetIntrinsicModifierName() return "modifier_boss_hpbar" end
-- Boss HP Bar Modifier
modifier_boss_hpbar = modifier_boss_hpbar or class({})
function modifier_boss_hpbar:IsHidden() return true end
function modifier_boss_hpbar:IsDebuff() return false end
function modifier_boss_hpbar:IsPurgable() return false end
function modifier_boss_hpbar:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(FrameTime())
		Timers:CreateTimer(FrameTime(), function()
			local caster = self:GetCaster()
			if caster ~= nil then
				if not caster:IsIllusion() then
					local current_hp = self:GetCaster():GetHealth()
					local maxhp = self:GetCaster():GetMaxHealth()
					CustomGameEventManager:Send_ServerToAllClients("CreateHP", {name = "hp_bar",text = "#HPBar", current_hp = current_hp, maxhp = maxhp})
					CustomGameEventManager:Send_ServerToAllClients("RefreshHPData", {name = "hp_bar",text = "#HPBar", current_hp = current_hp, maxhp = maxhp})
				end
			end
		end)
	end
end
function modifier_boss_hpbar:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		if caster ~= nil then
			if not caster:IsIllusion() then
				CustomGameEventManager:Send_ServerToAllClients("RemoveHPUI", {name = "hp_bar"})
			end
		end
	end
end
function modifier_boss_hpbar:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		if caster ~= nil then
			if not caster:IsIllusion() then
				local current_hp = self:GetCaster():GetHealth()
				local maxhp = self:GetCaster():GetMaxHealth()
				CustomGameEventManager:Send_ServerToAllClients("RefreshHPData", {name = "hp_bar",text = "#HPBar", current_hp = current_hp, maxhp = maxhp})
			end
		end
		if not caster:IsAlive() then
			self:Destroy()
		end
	end
end
function modifier_boss_hpbar:CheckState() return {[MODIFIER_STATE_NO_HEALTH_BAR] = true} end
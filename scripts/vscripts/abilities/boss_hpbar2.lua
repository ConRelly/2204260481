-----------------
-- Boss HP Bar 2 --
-----------------
boss_hpbar2 = boss_hpbar2 or class({})
LinkLuaModifier("modifier_boss_hpbar2", "abilities/boss_hpbar2.lua", LUA_MODIFIER_MOTION_NONE)
function boss_hpbar2:GetIntrinsicModifierName() return "modifier_boss_hpbar2" end
-- Boss HP Bar Modifier
modifier_boss_hpbar2 = modifier_boss_hpbar2 or class({})
function modifier_boss_hpbar2:IsHidden() return true end
function modifier_boss_hpbar2:IsDebuff() return false end
function modifier_boss_hpbar2:IsPurgable() return false end
function modifier_boss_hpbar2:OnCreated()
	if IsServer() then
		self:StartIntervalThink(FrameTime())
		Timers:CreateTimer(FrameTime(), function()
			local caster = self:GetCaster()
			--local team = 2
			if caster ~= nil then
				if not caster:IsIllusion() then
					--CustomGameEventManager:Send_ServerToTeam(team, "show_boss_hp", {})
					CustomGameEventManager:Send_ServerToAllClients("show_boss_hp", {})
				end
			end
		end)
	end
end
local hide_hp = true
function modifier_boss_hpbar2:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		if caster ~= nil then
			if not caster:IsIllusion() then
				if hide_hp then
					Timers:CreateTimer(0.7, function()	
						CustomGameEventManager:Send_ServerToAllClients("hide_boss_hp", {})
						hide_hp = true
						--print("hide hp lua 37")
					end)				
				end
				hide_hp = false	
				CustomGameEventManager:Send_ServerToAllClients("hide_boss_hp", {})
			end	
		end
	end
end
local show_hp = true
function modifier_boss_hpbar2:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local team = 2
		if caster ~= nil then
			if not caster:IsIllusion() then
				UpdateBossBar(caster, team)
				if show_hp then 
					Timers:CreateTimer(0.5, function()
						CustomGameEventManager:Send_ServerToAllClients("show_boss_hp", {})
						show_hp = true
						--print("show hp lua 58")
					end)
				end	
				show_hp = false
			end
		end
		if not caster:IsAlive() then
			self:Destroy()
		end
	end
end
function modifier_boss_hpbar2:CheckState() return {[MODIFIER_STATE_NO_HEALTH_BAR] = true} end
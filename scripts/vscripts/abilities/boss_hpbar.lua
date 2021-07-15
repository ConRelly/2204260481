-----------------
-- Boss HP Bar --
-----------------
boss_hpbar = boss_hpbar or class({})
LinkLuaModifier("modifier_boss_hpbar", "abilities/boss_hpbar.lua", LUA_MODIFIER_MOTION_NONE)
function boss_hpbar:GetIntrinsicModifierName() return "modifier_boss_hpbar" end
-- Boss HP Bar Modifier
modifier_boss_hpbar = modifier_boss_hpbar or class({})
function modifier_boss_hpbar:IsHidden() return false end
function modifier_boss_hpbar:IsDebuff() return false end
function modifier_boss_hpbar:IsPurgable() return false end
function modifier_boss_hpbar:OnCreated()
    if IsServer() then --if not self:GetAbility() then self:Destroy() end
        self:StartIntervalThink(FrameTime())
        Timers:CreateTimer(FrameTime(), function()
            local caster = self:GetCaster()
            if caster ~= nil then
                local team = DOTA_TEAM_GOODGUYS
                CustomGameEventManager:Send_ServerToTeam(team, "show_boss_hp", {})
            --if not caster:IsIllusion() then
                local svalue = caster:GetHealth()
                local evalue = caster:GetMaxHealth()
                --CustomGameEventManager:Send_ServerToAllClients("createhp", {name = "hp_bar",text = "#HPBar", svalue = svalue, evalue = evalue})
                --CustomGameEventManager:Send_ServerToAllClients("refreshhpdata", {name = "hp_bar",text = "#HPBar", svalue = svalue, evalue = evalue})
                --end
            end
        end)
    end
end
function modifier_boss_hpbar:OnDestroy()
    if IsServer() then
        local caster = self:GetCaster()
        local team = DOTA_TEAM_GOODGUYS
        CustomGameEventManager:Send_ServerToTeam(team, "hide_boss_hp", {})        
        if caster ~= nil then            
            --if not caster:IsIllusion() then
               -- CustomGameEventManager:Send_ServerToAllClients("removehppui", {name = "hp_bar"})
            --end
        end
    end
end
function modifier_boss_hpbar:OnIntervalThink()
    if IsServer() then
        local caster = self:GetCaster()
        if caster ~= nil then
            local team = "Slayers"
            --if not caster:IsIllusion() then
                UpdateBossBar(caster, team)
                local svalue = caster:GetHealth()
                local evalue = caster:GetMaxHealth()
                --CustomGameEventManager:Send_ServerToAllClients("refreshhpdata", {name = "hp_bar",text = "#HPBar", svalue = svalue, evalue = evalue})
            --end
        end
        if not caster:IsAlive() then           
            self:Destroy()
        end
    end
end
function modifier_boss_hpbar:CheckState() return {[MODIFIER_STATE_NO_HEALTH_BAR] = true} end
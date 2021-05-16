LinkLuaModifier("modifier_ignis_fatuus_health_counter", "abilities/hero_keeper_of_the_light/ignis_fatuus_health_counter.lua", LUA_MODIFIER_MOTION_NONE)


ignis_fatuus_health_counter = class({})

function ignis_fatuus_health_counter:GetIntrinsicModifierName()
    return "modifier_ignis_fatuus_health_counter"
end


modifier_ignis_fatuus_health_counter = class({})

function modifier_ignis_fatuus_health_counter:IsHidden() return true end
function modifier_ignis_fatuus_health_counter:IsPurgable() return false end

function modifier_ignis_fatuus_health_counter:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACKED,
	}

	return funcs
end


function modifier_ignis_fatuus_health_counter:OnAttacked(event)
    if IsServer() then
        print("OnAttacked")
        PrintTable(event)
		if event.target ~= self:GetParent() then
			return
		end

        local target = event.target
        local attacker = event.attacker

        local MAX_COUNT = 8
        self.count = self.count or MAX_COUNT

        local parent = self:GetParent()
        local health = parent:GetHealth()
        local maxHealth = parent:GetMaxHealth()

        if self.count <= 1  then
            parent:ForceKill(false)
        else
            self.count = self.count - 1
            local newHealth = (self.count / MAX_COUNT) * maxHealth
            parent:SetHealth(newHealth)
        end
	end
end

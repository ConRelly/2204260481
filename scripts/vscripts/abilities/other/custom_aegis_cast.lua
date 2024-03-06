
LinkLuaModifier("modifier_custom_aegis_cast", "abilities/other/custom_aegis_cast.lua", LUA_MODIFIER_MOTION_NONE)
custom_aegis_cast = class({})
function custom_aegis_cast:GetIntrinsicModifierName()
    return "modifier_custom_aegis_cast"
end

function custom_aegis_cast:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        if not caster:IsAlive() then
            return
        end
        SearchInventorySkill(caster)
    end
end
modifier_custom_aegis_cast = class({})
function modifier_custom_aegis_cast:IsHidden() return true end
function modifier_custom_aegis_cast:IsPurgable() return false end
function modifier_custom_aegis_cast:RemoveOnDeath() return false end
function modifier_custom_aegis_cast:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH_PREVENTED}
end
function modifier_custom_aegis_cast:OnDeathPrevented(params)
	if IsServer() then
		local parent = self:GetParent()
		if parent == nil then return end
        if params.unit == nil then return end
        if not IsValidEntity(params.unit) then return end
        if not params.unit:IsRealHero() then return end
		local aegis_charges = parent:FindModifierByName("modifier_aegis")
		if aegis_charges and aegis_charges:GetStackCount() > 0 then return end
		if self:GetParent():IsReincarnating() then return end        
		if parent == params.unit and parent:IsAlive() then
            if not parent:HasModifier("modifier_ring_invincibility_cd") then return end
            if parent:FindModifierByName("modifier_ring_invincibility_cd"):GetStackCount() > 7 then            
                local ability = self:GetAbility()
                if ability == nil then return end
                if ability:GetAutoCastState() then   
                    SearchInventorySkill(parent) 
                end
            end    
        end
    end
end


-- search_inventory

function SearchInventorySkill(unit)
    if not IsServer() then
        return
    end
    local caster = unit
    local item_name = "item_aegis_lua"

    -- Search the caster's inventory
    for i = 0, 16 do
        local item = caster:GetItemInSlot(i)
        if item and item:GetName() == item_name then
            item:OnSpellStart_skill(caster)
            return
        end
    end

    -- Search the caster's owned couriers inventories

    local playerID = caster:GetPlayerOwnerID()
    if _G.COURIERS[playerID] then
        for _, courier in ipairs(_G.COURIERS[playerID]) do
            for i = 0, 16 do
                local item = courier:GetItemInSlot(i)
                if item and item:GetName() == item_name then
                    item:OnSpellStart_skill(caster)
                    return
                end
            end
        end
    end    
    
end
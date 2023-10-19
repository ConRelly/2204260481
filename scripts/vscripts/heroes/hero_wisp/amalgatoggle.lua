LinkLuaModifier("modifier_symbiosis_ready", "heroes/hero_wisp/amalgatoggle", LUA_MODIFIER_MOTION_NONE)



modifier_symbiosis_ready = class({})

function modifier_symbiosis_ready:IsHidden() return true end
function modifier_symbiosis_ready:IsPurgable() return false end

if amalgatoggle == nil then
    amalgatoggle = class({})
end

function amalgatoggle:GetAbilityTextureName()
	local has_modifier = self:GetCaster():HasModifier("amalgamation_modifier")
	local super_scept = self:GetCaster():HasModifier("modifier_super_scepter")
	local carnage = self:GetCaster():HasModifier("modifier_symbiosis_carnage")
	local venom = self:GetCaster():HasModifier("modifier_symbiosis_venom")
    if has_modifier and super_scept then
		if venom then
			return "venom_out"
		elseif carnage then		
			return "venom_toggle"
		end	
    end
	return "venom_out"
end
local drop_bonus = 2
function amalgatoggle:OnAbilityUpgrade(ability)
    if IsServer() then
        if self ~= ability then return end
        local caster = self:GetCaster()
        local playerID = caster:GetPlayerID()
        local lvl = self:GetLevel() 
        print("Level: "..lvl)
        if caster:HasModifier("modifier_super_scepter") then
            if drop_bonus == 2 and self:GetLevel() > 1 then
                DropItemOrInventory(playerID, "item_imba_ultimate_scepter_synth2")
                DropItemOrInventory(playerID, "item_edible_fragment")    
                DropItemOrInventory(playerID, "item_imba_ultimate_scepter_synth2")
                DropItemOrInventory(playerID, "item_edible_fragment")  
                drop_bonus = 0                           
            else    
                DropItemOrInventory(playerID, "item_imba_ultimate_scepter_synth2")
                DropItemOrInventory(playerID, "item_edible_fragment")
                drop_bonus = drop_bonus - 1
            end
        end
    end    
end
--[[ function amalgatoggle:OnToggle()
    local caster = self:GetCaster()
    if self:GetToggleState() then
        caster:AddNewModifier(caster, self, "modifier_symbiosis_ready", {})
    else
        if caster:HasModifier("modifier_symbiosis_ready") then
            caster:RemoveModifierByName("modifier_symbiosis_ready")
        end
    end
end
 ]]
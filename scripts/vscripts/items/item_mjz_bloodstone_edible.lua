LinkLuaModifier( "modifier_item_mjz_bloodstone_edible", "items/item_mjz_bloodstone_edible", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_bloodstone_buff_edible", "items/item_mjz_bloodstone_edible", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_mjz_bloodstone_charges", "items/item_mjz_bloodstone", LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------------




---------------------------------------------------------------------------------------

item_mjz_bloodstone_edible = class({})

-----------------------------------------------------------------------------------------------------------
--	Edible item
-----------------------------------------------------------------------------------------------------------
local edible_bloodstone = "modifier_item_mjz_bloodstone_edible"
local item_bloodstone = "modifier_item_mjz_bloodstone"

if modifier_item_mjz_bloodstone_edible == nil then modifier_item_mjz_bloodstone_edible = class({}) end

function item_mjz_bloodstone_edible:OnSpellStart()
	local caster = self:GetCaster()
	if not caster:IsRealHero() or caster:HasModifier("modifier_arc_warden_tempest_double") or caster:HasModifier(edible_bloodstone) or caster:HasModifier(item_bloodstone) then return end
	caster:AddNewModifier(caster, self, edible_bloodstone, {})
	caster:EmitSound("Hero_Alchemist.Scepter.Cast")
	--caster:RemoveItem(self)
	caster:TakeItem(self)
end


---------------------------------------------------------------------------------------


function modifier_item_mjz_bloodstone_edible:IsHidden() return true end
function modifier_item_mjz_bloodstone_edible:IsPurgable() return false end
--function modifier_item_mjz_bloodstone:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_mjz_bloodstone_edible:IsPermanent() return true end
function modifier_item_mjz_bloodstone_edible:RemoveOnDeath() return false end
function modifier_item_mjz_bloodstone_edible:AllowIllusionDuplicate() return true end
function modifier_item_mjz_bloodstone_edible:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
	}
end
function modifier_item_mjz_bloodstone_edible:GetModifierBonusStats_Intellect()
	return 420
end
function modifier_item_mjz_bloodstone_edible:GetModifierHealthBonus()
	return 9500
end
function modifier_item_mjz_bloodstone_edible:GetModifierManaBonus()
	return 5500
end

-------------------------------------------------------------------------------

modifier_item_mjz_bloodstone_buff_edible = class({})
function modifier_item_mjz_bloodstone_buff_edible:IsHidden() return false end
function modifier_item_mjz_bloodstone_buff_edible:IsPurgable() return false end
function modifier_item_mjz_bloodstone_buff_edible:IsBuff() return true end
function modifier_item_mjz_bloodstone_buff_edible:RemoveOnDeath() return false end
function modifier_item_mjz_bloodstone_buff_edible:GetTexture() return "item_mjz_bloodstone_edible" end
function modifier_item_mjz_bloodstone_buff_edible:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_item_mjz_bloodstone_buff_edible:GetModifierConstantManaRegen()
	return self:GetStackCount() * 2.5
end
function modifier_item_mjz_bloodstone_buff_edible:GetModifierMPRegenAmplify_Percentage()
	return 950
end
function modifier_item_mjz_bloodstone_buff_edible:GetModifierSpellAmplify_Percentage()
	local charges = self:GetStackCount()
	if charges > 330 then
		charges = 330
	end			
	return charges * 1.4
end
function modifier_item_mjz_bloodstone_buff_edible:GetModifierSpellLifestealRegenAmplify_Percentage()
	return 40
end
function modifier_item_mjz_bloodstone_buff_edible:GetModifierPercentageManacostStacking()
	return 35
end



-------------------------------------------------------------------------------




if IsServer() then
	function modifier_item_mjz_bloodstone_edible:OnCreated(table)
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_mjz_bloodstone_buff_edible") then
			if parent:IsAlive() then
				parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_mjz_bloodstone_buff_edible", {})
			end	
		end	

		if parent:HasModifier("modifier_mjz_bloodstone_charges") then
			local charges = parent:FindModifierByName("modifier_mjz_bloodstone_charges"):GetStackCount()
			if parent:HasModifier("modifier_item_mjz_bloodstone_buff_edible") then
				local modif_buff = "modifier_item_mjz_bloodstone_buff_edible"
				local mbuff = parent:FindModifierByName(modif_buff)	
				if mbuff ~= nil then
					mbuff:SetStackCount(charges)
				end				
			end	
		end
		if parent:IsIllusion() or parent:HasModifier("modifier_arc_warden_tempest_double") then
			local mod1 = "modifier_item_mjz_bloodstone_buff_edible"
			local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
			if owner then			 
				if parent:HasModifier(mod1) then
					local modifier1 = parent:FindModifierByName(mod1)
					if owner:HasModifier(mod1) then
						local modifier2 = owner:FindModifierByName(mod1)
						modifier1:SetStackCount(modifier2:GetStackCount())
					end	
				end
			end
		end		
	end
	
end


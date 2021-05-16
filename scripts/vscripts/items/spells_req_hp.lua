LinkLuaModifier( "immortal_spells_req_hp", "modifiers/immortal_all_in_one", LUA_MODIFIER_MOTION_NONE )
item_spells_req_hp = class({})
function item_spells_req_hp:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	caster:EmitSound("DOTA_Item.ClarityPotion.Activate")
	if caster:HasModifier("immortal_spells_req_hp") then
		caster:RemoveModifierByName("immortal_spells_req_hp")
	else
		caster:AddNewModifier( self:GetCaster(), self, "immortal_spells_req_hp", kv )
	end
	self:SetCurrentCharges( self:GetCurrentCharges() - 1 )
	caster:RemoveItem(self)
end
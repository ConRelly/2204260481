-----------------
-- Soul Ring 3 --
-----------------
if item_soul_ring_3 == nil then item_soul_ring_3 = class({}) end
LinkLuaModifier("modifier_soul_ring_3", "items/soul_ring.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_soul_ring_3_buff", "items/soul_ring.lua", LUA_MODIFIER_MOTION_NONE)
function item_soul_ring_3:OnSpellStart()
	self:GetParent():EmitSound("DOTA_Item.SoulRing.Activate")
	local health_sacrifice = self:GetSpecialValueFor("health_sacrifice")
	local mana_gain = self:GetSpecialValueFor("mana_gain")
	if (self:GetParent():GetHealth() - health_sacrifice) <= 0 then
		self:GetParent():SetHealth(1)
	else
		self:GetParent():SetHealth(self:GetParent():GetHealth() - health_sacrifice)
	end
	self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_soul_ring_3_buff", {duration = self:GetSpecialValueFor("duration")})
	soul_ring = ParticleManager:CreateParticle("particles/items2_fx/soul_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(soul_ring, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), true)
	ParticleManager:SetParticleControl(soul_ring, 1, Vector(self:GetSpecialValueFor("duration"), 0, 0))
	self:GetParent():GiveMana(mana_gain)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, self:GetParent(), mana_gain, nil)
	if self:GetParent():FindItemInInventory("item_trusty_shovel") then
		for itemSlot = 0, 5 do
			local item = self:GetParent():GetItemInSlot(itemSlot)
			if item and item:GetName() == "item_trusty_shovel" then
				self:GetParent():RemoveItem(self:GetParent():FindItemInInventory("item_trusty_shovel"))
				self:GetParent():EmitSound("Hero_PhantomAssassin.Arcana_Layer")
				self:GetParent():AddItemByName("item_ritual_shovel")
				break
			end
		end
	end
end
function item_soul_ring_3:GetIntrinsicModifierName() return "modifier_soul_ring_3" end

if modifier_soul_ring_3 == nil then modifier_soul_ring_3 = class({}) end
function modifier_soul_ring_3:IsHidden() return true end
function modifier_soul_ring_3:IsPurgable() return false end
function modifier_soul_ring_3:RemoveOnDeath() return false end
function modifier_soul_ring_3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_soul_ring_3:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_soul_ring_3:GetModifierBonusStats_Strength() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_strength") end end
function modifier_soul_ring_3:GetModifierPhysicalArmorBonus() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_armor") end end

----------------------
-- Soul Ring 3 Buff --
----------------------
if modifier_soul_ring_3_buff == nil then modifier_soul_ring_3_buff = class({}) end
function modifier_soul_ring_3_buff:IsHidden() return false end
function modifier_soul_ring_3_buff:IsPurgable() return false end
function modifier_soul_ring_3_buff:RemoveOnDeath() return false end
function modifier_soul_ring_3_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_soul_ring_3_buff:DeclareFunctions() return {MODIFIER_PROPERTY_EXTRA_MANA_BONUS} end
function modifier_soul_ring_3_buff:GetModifierExtraManaBonus() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_gain") end end
LinkLuaModifier( "modifier_item_mjz_heart", "items/item_mjz_heart", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_heart_buff", "items/item_mjz_heart", LUA_MODIFIER_MOTION_NONE )

---------------------------------------------------------------------------------------

item_mjz_heart_2 = class({})
item_mjz_heart_3 = class({})
item_mjz_heart_4 = class({})
item_mjz_heart_5 = class({})

function item_mjz_heart_2:GetIntrinsicModifierName() return "modifier_item_mjz_heart" end
function item_mjz_heart_3:GetIntrinsicModifierName() return "modifier_item_mjz_heart" end
function item_mjz_heart_4:GetIntrinsicModifierName() return "modifier_item_mjz_heart" end
function item_mjz_heart_5:GetIntrinsicModifierName() return "modifier_item_mjz_heart" end

---------------------------------------------------------------------------------------

if modifier_item_mjz_heart == nil then modifier_item_mjz_heart = class({}) end
function modifier_item_mjz_heart:IsHidden() return true end
function modifier_item_mjz_heart:IsPurgable() return false end
function modifier_item_mjz_heart:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_mjz_heart:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS}
end
function modifier_item_mjz_heart:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_strength") end
end
function modifier_item_mjz_heart:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health") end
end

if IsServer() then
	function modifier_item_mjz_heart:OnCreated(table)
		local parent = self:GetParent()
		if IsValidEntity(parent) and parent:IsRealHero() then
			self:StartIntervalThink(FrameTime())
		end
	end

	function modifier_item_mjz_heart:OnIntervalThink()
		local parent = self:GetParent()
		if IsValidEntity(parent) and parent:IsRealHero() then
			local mt = {"modifier_item_mjz_heart_buff",}
			for _,mname in pairs(mt) do
				if not parent:HasModifier(mname) then
					parent:AddNewModifier(self:GetCaster(), self:GetAbility(), mname, {})
				end
			end
		end
		self:StartIntervalThink(-1)
	end

	function modifier_item_mjz_heart:OnDestroy()
		local parent = self:GetParent()
		if IsValidEntity(parent) and parent:IsAlive() then
			local mt = {"modifier_item_mjz_heart_buff",}
			for _,mname in pairs(mt) do
				parent:RemoveModifierByName(mname)
			end
		end
	end
end

-------------------------------------------------------------------------------

modifier_item_mjz_heart_buff = class({})
function modifier_item_mjz_heart_buff:IsHidden() return true end
function modifier_item_mjz_heart_buff:IsPurgable() return false end
function modifier_item_mjz_heart_buff:IsBuff() return true end
function modifier_item_mjz_heart_buff:GetTexture() return "item_mjz_heart" end
function modifier_item_mjz_heart_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE}
end
function modifier_item_mjz_heart_buff:GetModifierHealthRegenPercentage()
	if IsValidEntity(self:GetAbility()) then
		return self:GetAbility():GetSpecialValueFor("health_regen_rate")
	end
end
function modifier_item_mjz_heart_buff:GetModifierHPRegenAmplify_Percentage()
	if IsValidEntity(self:GetAbility()) then
		return self:GetAbility():GetSpecialValueFor("hp_regen_amp")
	end
end

blood_madness = class({})
LinkLuaModifier("modifier_blood_madness", "heroes/hero_axe/blood_madness.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_blood_madness_checker", "heroes/hero_axe/blood_madness.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_blood_madness_timer", "heroes/hero_axe/blood_madness.lua", LUA_MODIFIER_MOTION_NONE)

function blood_madness:GetCastPoint() if self:GetCaster():HasScepter() then return 0 else return self.BaseClass.GetCastPoint(self) end end
function blood_madness:GetIntrinsicModifierName() return "modifier_blood_madness_checker" end
function blood_madness:OnSpellStart()
	local caster = self:GetCaster()
	local timer = self:GetSpecialValueFor("timer")
	if caster:HasScepter() then
		timer = self:GetSpecialValueFor("timer_scepter")
	end
	if caster:HasModifier("modifier_blood_madness") then
		caster:RemoveModifierByName("modifier_blood_madness")
	end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_blood_madness", {duration = self:GetSpecialValueFor("duration")})
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_blood_madness_timer", {duration = timer})
end

----------------------------------------------------------------------------------------
modifier_blood_madness = class({})
function modifier_blood_madness:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_blood_madness:IsPurgable() return false end
function modifier_blood_madness:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end
function modifier_blood_madness:GetModifierPhysicalArmorBonus(params)
	if self:GetAbility() then
		local bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor") * self:GetStackCount()
		if bonus_armor > 5000 then
			bonus_armor = 5000
		end	
		return bonus_armor
	end	
end
function modifier_blood_madness:GetModifierBonusStats_Strength(params) if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_str") * self:GetStackCount() end end

----------------------------------------------------------------------------------------
modifier_blood_madness_checker = class({})
function modifier_blood_madness_checker:IsHidden() return true end
function modifier_blood_madness_checker:IsPurgable() return false end
function modifier_blood_madness_checker:OnCreated()
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_blood_madness_checker:OnIntervalThink()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_item_helm_of_the_undying_active") or self:GetCaster():HasModifier("modifier_skeleton_king_reincarnation_scepter_active") then
			self:GetCaster():FindAbilityByName("blood_madness"):SetActivated(false)
		else
			self:GetCaster():FindAbilityByName("blood_madness"):SetActivated(true)
		end
	end
end

----------------------------------------------------------------------------------------
modifier_blood_madness_timer = class({})
function modifier_blood_madness_timer:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MIN_HEALTH}
end
function modifier_blood_madness_timer:IsHidden() return false end
function modifier_blood_madness_timer:IsPurgable() return false end
function modifier_blood_madness_timer:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 6000000
end
function modifier_blood_madness_timer:OnWaweChange(wawe) self:SetStackCount(wawe) end
function modifier_blood_madness_timer:OnTakeDamage(params)
	if IsServer() then
        if params.unit == self:GetParent() then
			local damage = params.damage
			local parent_hp = self:GetParent():GetHealth()
			local caster  = self:GetCaster()
			if damage > parent_hp then
				damage = parent_hp
			end
			if damage > 200000 then
				damage = 200000
			end	

            caster:SetModifierStackCount("modifier_blood_madness",caster,caster:GetModifierStackCount("modifier_blood_madness",caster) + damage)
        end
	end
	return 0
end
function modifier_blood_madness_timer:GetMinHealth() if self:GetCaster():HasScepter() then return 100 end end
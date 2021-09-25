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
function modifier_blood_madness:GetModifierPhysicalArmorBonus(params) return self:GetAbility():GetSpecialValueFor("bonus_armor") * self:GetStackCount() end
function modifier_blood_madness:GetModifierBonusStats_Strength(params) return self:GetAbility():GetSpecialValueFor("bonus_str") * self:GetStackCount() end

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
function modifier_blood_madness_timer:OnWaweChange(wawe) self:SetStackCount(wawe) end
function modifier_blood_madness_timer:OnTakeDamage(params)
	if IsServer() then
        if params.unit == self:GetParent() then
			local damage = params.damage
			if damage > self:GetParent():GetHealth() then
				damage = self:GetParent():GetHealth()
			end
			if damage > 300000 then
				damage = 300000
			end	

            self:GetCaster():SetModifierStackCount("modifier_blood_madness",self:GetCaster(),self:GetCaster():GetModifierStackCount("modifier_blood_madness",self:GetCaster()) + damage)
        end
	end
	return 0
end
function modifier_blood_madness_timer:GetMinHealth() if self:GetCaster():HasScepter() then return 5 end end
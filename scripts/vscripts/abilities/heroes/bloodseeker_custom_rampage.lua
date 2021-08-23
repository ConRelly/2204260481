LinkLuaModifier("modifier_bloodseeker_custom_rampage", "abilities/heroes/bloodseeker_custom_rampage.lua", LUA_MODIFIER_MOTION_NONE)


bloodseeker_custom_rampage = class({})
function bloodseeker_custom_rampage:OnSpellStart()
	if IsServer() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_bloodseeker_custom_rampage", {duration = self:GetSpecialValueFor("duration")})
	end
end


modifier_bloodseeker_custom_rampage = class({})
function modifier_bloodseeker_custom_rampage:IsBuff() return true end
function modifier_bloodseeker_custom_rampage:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE}
end
function modifier_bloodseeker_custom_rampage:GetModifierMoveSpeed_Absolute()
	return self:GetAbility():GetSpecialValueFor("ms_cap")
end
function modifier_bloodseeker_custom_rampage:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("increased_damage")
end
if IsServer() then
    function modifier_bloodseeker_custom_rampage:OnCreated(keys)
		self.parent = self:GetParent()
        local ability = self:GetAbility()
        self.max_hp = ability:GetSpecialValueFor("max_hp")
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(self.particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		
        self:StartIntervalThink(0.1)
    end
	function modifier_bloodseeker_custom_rampage:OnDestroy()
        ParticleManager:DestroyParticle(self.particle, false)
    end
    function modifier_bloodseeker_custom_rampage:OnIntervalThink()
        if self.parent and (self.parent:GetHealth() / self.parent:GetMaxHealth() * 100) > self.max_hp then
            self.parent:SetHealth(self.parent:GetMaxHealth() * self.max_hp * 0.01)
        end
    end
end

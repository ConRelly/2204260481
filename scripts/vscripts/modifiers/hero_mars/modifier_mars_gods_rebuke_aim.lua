modifier_mars_gods_rebuke_aim = class({})

function modifier_mars_gods_rebuke_aim:IsHidden() return true end
function modifier_mars_gods_rebuke_aim:IsPurgable() return false end
function modifier_mars_gods_rebuke_aim:RemoveOnDeath() return false end
function modifier_mars_gods_rebuke_aim:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_mars_gods_rebuke_aim:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_START, MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function modifier_mars_gods_rebuke_aim:OnAbilityStart(event)
	if not IsServer() or event.unit ~= self:GetParent() or event.ability ~= self:GetAbility() then return end
	local caster = event.unit
	-- The native cone still reads a position when issued as an instant no-target cast.
	caster:SetCursorTargetingNothing(false)
	caster:SetCursorPosition(caster:GetAbsOrigin() + caster:GetForwardVector() * 100)
end

modifier_mars_gods_rebuke_aim.OnAbilityExecuted = modifier_mars_gods_rebuke_aim.OnAbilityStart

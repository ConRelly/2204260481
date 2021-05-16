
-- Keeps track of the casters health
function BacktrackHealth( keys )
	if not IsServer() then return nil end

	local caster = keys.caster
	local ability = keys.ability
	if caster:IsIllusion() or caster:HasModifier("modifier_arc_warden_tempest_double") then return nil end
	ability.caster_hp_old = ability.caster_hp_old or caster:GetMaxHealth()
	ability.caster_hp = ability.caster_hp or caster:GetMaxHealth()

	ability.caster_hp_old = ability.caster_hp
	ability.caster_hp = caster:GetHealth()
end


-- Negates incoming damage
function BacktrackHeal( keys )
	if not IsServer() then return nil end

	local caster = keys.caster
	local ability = keys.ability
	if caster:IsIllusion() or caster:HasModifier("modifier_arc_warden_tempest_double") then return nil end
	caster:SetHealth(ability.caster_hp_old)
end


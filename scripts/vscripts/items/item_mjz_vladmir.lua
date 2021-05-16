
--[[ ============================================================================================================
	Author: Rook, with help from Noya
	Date: January 26, 2015
	Called when the melee unit affected by the lifesteal aura lands an attack on a target.  Applies a brief lifesteal 
	modifier if not attacking a structure or mechanical unit (Lifesteal blocks in KV files will normally allow the 
	unit to heal when attacking these).
================================================================================================================= ]]
function on_attack_landed(keys)
	if keys.target.GetInvulnCount == nil then
		--keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker,		"modifier_item_mjz_vladmir_aura_lifesteal", {duration = 0.03})
		--OnAttackLanded_lifesteal(keys)
		
	end
end

function OnAttackLanded_lifesteal(keys)
	local parent = keys.attacker
	local ability = keys.ability
	local attacker = keys.attacker
	local target = keys.target
	local damage = keys.damage
	
	PrintTable(keys)

	if parent == attacker and parent:GetTeamNumber() ~= target:GetTeamNumber() then
		if not target:IsHero() and not target:IsCreep() then
			return nil
		end

		if parent:IsIllusion() then return nil end

		local lifesteal_pct = ability:GetSpecialValueFor('lifesteal_aura')
		local lifesteal_amount = damage * (lifesteal_pct / 100.0)
		parent:Heal(lifesteal_amount, parent)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, lifesteal_amount, nil)

		-- Choose the particle to draw
		local lifesteal_particle = "particles/generic_gameplay/generic_lifesteal.vpcf"

		-- Heal and fire the particle
		local lifesteal_pfx = ParticleManager:CreateParticle(lifesteal_particle, PATTACH_ABSORIGIN_FOLLOW, attacker)
		ParticleManager:SetParticleControl(lifesteal_pfx, 0, attacker:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
		
	end
end    
--natures_form--
LinkLuaModifier("modifier_natures_form", "heroes/hero_treant/treant_natures_form.lua", LUA_MODIFIER_MOTION_NONE)
treant_natures_form = treant_natures_form or class({})
function treant_natures_form:Spawn()
	if IsServer() then
		self:SetLevel(1)
	end
end
function treant_natures_form:ProcsMagicStick() return false end
function treant_natures_form:IsInnateAbility() return true end
function treant_natures_form:OnInventoryContentsChanged()
	if IsServer() then
		if self:GetCaster():HasScepter() and not self:GetCaster():HasModifier("modifier_natures_form") then
			self:SetHidden(false)
		else
			self:SetHidden(true)
		end
	end
end
function treant_natures_form:OnHeroCalculateStatBonus()
	self:OnInventoryContentsChanged()
end
function treant_natures_form:OnOwnerDied()
	if IsServer() then
		if root == true then
			self:GetCaster():SwapAbilities("treant_natures_form_unroot", "treant_natures_form", false, true)
			self:GetCaster():RemoveModifierByName("modifier_natures_form")
			ParticleManager:DestroyParticle(root_fx, false)
			root = false
		end
	end
end
function treant_natures_form:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		EmitSoundOn("Hero_Treant.Overgrowth.Cast", self:GetCaster())
		caster:SwapAbilities("treant_natures_form", "treant_natures_form_unroot", false, true)
		root_fx = ParticleManager:CreateParticle("particles/custom/abilities/heroes/treant_natures_form/treant_natures_form_root.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(root_fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetOrigin(), true)
		root = true
		caster:AddNewModifier(caster, self, "modifier_natures_form", {})
	end
end

--unroot--
treant_natures_form_unroot = treant_natures_form_unroot or class({})
function treant_natures_form_unroot:Spawn()
	if IsServer() then
		self:SetLevel(1)
	end
end
function treant_natures_form_unroot:ProcsMagicStick() return false end
function treant_natures_form_unroot:IsInnateAbility() return true end
function treant_natures_form_unroot:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		EmitSoundOn("Hero_Treant.Death", self:GetCaster())
		caster:SwapAbilities("treant_natures_form_unroot", "treant_natures_form", false, true)
		caster:RemoveModifierByName("modifier_natures_form")
		ParticleManager:DestroyParticle(root_fx, false)
		root = false
	end
end

modifier_natures_form = modifier_natures_form or class({})
function modifier_natures_form:IsHidden() return false end
function modifier_natures_form:IsPurgable() return false end
function modifier_natures_form:IsDebuff() return false end
function modifier_natures_form:RemoveOnDeath() return true end
--function modifier_natures_form:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_natures_form:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_natures_form:GetModifierAttackRangeBonus() return self:GetAbility():GetSpecialValueFor("attack_range") end
function modifier_natures_form:GetModifierIncomingDamage_Percentage()
	if self:GetAbility()then
		if self:GetParent():GetName() == "npc_dota_hero_treant" then
			return self:GetAbility():GetSpecialValueFor("dmg_reduct") * (-1)
		end	
		return 0
	end	
end
function modifier_natures_form:GetModifierHPRegenAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("regen_amp") end
function modifier_natures_form:GetModifierAttackSpeedPercentage() return self:GetAbility():GetSpecialValueFor("as_reduct") * (-1) end
function modifier_natures_form:GetModifierBaseDamageOutgoing_Percentage() return self:GetAbility():GetSpecialValueFor("bonus_dmg") end
function modifier_natures_form:CheckState() return {[MODIFIER_STATE_ROOTED] = true} end
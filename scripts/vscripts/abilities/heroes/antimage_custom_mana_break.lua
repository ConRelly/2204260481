LinkLuaModifier("modifier_antimage_custom_mana_break", "abilities/heroes/antimage_custom_mana_break.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_antimage_custom_mana_break_buff", "abilities/heroes/antimage_custom_mana_break.lua", LUA_MODIFIER_MOTION_NONE)

antimage_custom_mana_break = class({})
function antimage_custom_mana_break:GetIntrinsicModifierName() return "modifier_antimage_custom_mana_break" end
modifier_antimage_custom_mana_break = class({})
modifier_antimage_custom_mana_break_buff = class(antimage_custom_mana_break)

local modifier_buff = "modifier_antimage_custom_mana_break_buff"
function modifier_antimage_custom_mana_break:IsHidden() return true end
function modifier_antimage_custom_mana_break:IsDebuff() return false end
function modifier_antimage_custom_mana_break:IsPurgable() return false end
function modifier_antimage_custom_mana_break:RemoveOnDeath() return false end
function modifier_antimage_custom_mana_break:OnCreated()
	if IsServer() then
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if not parent:HasModifier(modifier_buff) then
			parent:AddNewModifier(parent, ability, modifier_buff, {})
		end 
	end
	--self:SetStackCount(self:GetStackCount()+ 1)
end
function modifier_antimage_custom_mana_break:DeclareFunctions()
	if not IsServer() then return end
	return {
		--MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_antimage_custom_mana_break:OnAttackLanded(keys)
	if not IsServer() then return end
	local ability = self:GetAbility()
	local attacker = keys.attacker
	local chance_hit = ability:GetSpecialValueFor("chance_hit")
	if attacker == self:GetParent() and attacker:IsAlive() then
		local target = keys.target
		if RollPercentage(chance_hit) then
			if attacker:PassivesDisabled() or target:IsAttackImmune() or target:GetMaxMana() == 0 or not target:IsAlive() then return nil end

			--target:EmitSound("Hero_Antimage.ManaBreak")

			--[[local particle = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle)]]
			local damage_flag = DOTA_DAMAGE_FLAG_NONE
			local mana_per_hit = ability:GetSpecialValueFor("mana_per_hit")
			local target_mana = target:GetMana()
			local chance = ability:GetSpecialValueFor("stack_chance")
			local lvl = attacker:GetLevel()
			if HasTalent(attacker, "special_bonus_custom_mana_break_1") then
				damage_flag = DOTA_DAMAGE_FLAG_IGNORES_BASE_PHYSICAL_ARMOR
			end
			if attacker:HasModifier("modifier_super_scepter") then
				mana_per_hit = mana_per_hit + lvl
				chance = ability:GetSpecialValueFor("stack_chance_ss")
				if attacker:HasModifier("modifier_marci_unleash_flurry") then
					damage_flag = DOTA_DAMAGE_FLAG_IGNORES_BASE_PHYSICAL_ARMOR
				end                                 
			end				
			local damage = mana_per_hit * ability:GetSpecialValueFor("mana_burn_as_damage")			
			target:Script_ReduceMana(mana_per_hit, nil)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, mana_per_hit, nil)
			if RandomInt(0,100) < chance then
				self:OnRefresh()
			end
			ApplyDamage({
				ability = ability,
				attacker = attacker,
				damage = damage,
				damage_flags = damage_flag,
				damage_type = ability:GetAbilityDamageType(),
				victim = target
			})
		end
	end
end


function modifier_antimage_custom_mana_break_buff:IsHidden() return (self:GetAbility() == nil) or (self:GetStackCount() < 1) end
function modifier_antimage_custom_mana_break_buff:IsDebuff() return false end
function modifier_antimage_custom_mana_break_buff:IsPurgable() return false end
function modifier_antimage_custom_mana_break_buff:RemoveOnDeath() return false end
function modifier_antimage_custom_mana_break_buff:AllowIllusionDuplicate() return true end
function modifier_antimage_custom_mana_break_buff:DeclareFunctions()
	--if not IsServer() then return end
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS
	}
end
function modifier_antimage_custom_mana_break_buff:OnCreated()
	if not IsServer() then return end
	local parent = self:GetParent()
	local ability = self:GetAbility()
	--self.buff = self
	if not parent:HasModifier("modifier_antimage_custom_mana_break_buff") then
		parent:AddNewModifier(parent, ability, "modifier_antimage_custom_mana_break_buff", {})
	end
	if parent:IsIllusion() or parent:HasModifier("modifier_arc_warden_tempest_double") then
		local mod1 = "modifier_antimage_custom_mana_break_buff"
		local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
		if owner then
			if parent:HasModifier(mod1) then
				local modifier1 = parent:FindModifierByName(mod1)
				if owner:HasModifier(mod1) then
					local modifier2 = owner:FindModifierByName(mod1)
					modifier1:SetStackCount(modifier2:GetStackCount())
				end	
			end
		end
	end
end
function modifier_antimage_custom_mana_break_buff:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_stack") end
end
function modifier_antimage_custom_mana_break_buff:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_hp") end
end 
function modifier_antimage_custom_mana_break_buff:GetModifierManaBonus()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_mp") end
end
function modifier_antimage_custom_mana_break_buff:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_agi") end
end  
function modifier_antimage_custom_mana_break:OnRefresh()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local stack = ability:GetSpecialValueFor("mana_per_hit")
	local lvl = caster:GetLevel()
	if caster:HasModifier("modifier_super_scepter") then
		stack = stack + lvl
	end		
	local final_stack = stack / 40
	local mbuff = caster:FindModifierByName(modifier_buff)
	if mbuff ~= nil then
		mbuff:SetStackCount(mbuff:GetStackCount() + math.ceil(final_stack))
		caster:CalculateStatBonus(false)
	end
	--[[if RandomInt(0,100) < ability:GetSpecialValueFor("stack_chance") then
		self:SetStackCount(self:GetStackCount() + math.ceil(final_stack))
	end]]
end

function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end
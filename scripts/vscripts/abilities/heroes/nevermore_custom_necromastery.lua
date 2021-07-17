require("lib/my")



nevermore_custom_necromastery = class({})


function nevermore_custom_necromastery:GetIntrinsicModifierName()
    return "modifier_nevermore_custom_necromastery"
end

function nevermore_custom_necromastery:OnUpgrade()
    local caster = self:GetCaster()
	if caster:HasModifier("modifier_nevermore_custom_necromastery") then
		caster:FindModifierByName("modifier_nevermore_custom_necromastery"):ForceRefresh()
	end
end
function nevermore_custom_necromastery:OnInventoryContentsChanged()
    local caster = self:GetCaster()
	if caster:HasModifier("modifier_nevermore_custom_necromastery") then
		caster:FindModifierByName("modifier_nevermore_custom_necromastery"):ForceRefresh()
	end
end



LinkLuaModifier("modifier_nevermore_custom_necromastery", "abilities/heroes/nevermore_custom_necromastery.lua", LUA_MODIFIER_MOTION_NONE)

modifier_nevermore_custom_necromastery = class({})

function modifier_nevermore_custom_necromastery:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEATH,
	}
end



if IsServer() then

	function modifier_nevermore_custom_necromastery:OnCreated()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.hasTalent = false
		self.max_souls = 0
		self.release = self.ability:GetSpecialValueFor("necromastery_soul_release")
		self.talent_ratio = 0
		self.damage_per_soul = self.ability:GetSpecialValueFor("necromastery_damage_per_soul")
		--if self.parent:IsRealHero() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		self:SetStackCount(1)	
		if parent:IsIllusion() or parent:HasModifier("modifier_arc_warden_tempest_double") then
			local mod1 = "modifier_nevermore_custom_necromastery"
			print("ilusion SF")
			local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
			if owner then       
				if parent:HasModifier(mod1) then
					local modifier1 = parent:FindModifierByName(mod1)
					if owner:HasModifier(mod1) then
						local modifier2 = owner:FindModifierByName(mod1)
						modifier1:SetStackCount(modifier2:GetStackCount())
					end	
					--print("illusion nevermore1")
				end    
			end    
		end
		self.modifier = self.parent:AddNewModifier(caster, self.ability, "modifier_nevermore_custom_necromastery_buff", {})
		--else

		--end					
		if self.parent:HasScepter() then
			self.max_souls = self.ability:GetSpecialValueFor("necromastery_max_souls_scepter")
		else 
			self.max_souls = self.ability:GetSpecialValueFor("necromastery_max_souls")
		end
		local think_interval = 3
		self:StartIntervalThink(think_interval)
	end   
	function modifier_nevermore_custom_necromastery:OnDestroy()
		self.modifier:Destroy()
    end
	function modifier_nevermore_custom_necromastery:OnRefresh()
		if self.parent:HasScepter() then
			self.max_souls = self.ability:GetSpecialValueFor("necromastery_max_souls_scepter")
		else 
			self.max_souls = self.ability:GetSpecialValueFor("necromastery_max_souls")
		end
		self.damage_per_soul = self.ability:GetSpecialValueFor("necromastery_damage_per_soul")
		if self.hasTalent then
			self.damage_per_soul = self.ability:GetSpecialValueFor("necromastery_damage_per_soul") + self.talent_ratio
		end
    end
	
	function modifier_nevermore_custom_necromastery:OnIntervalThink()
		local talent = self.parent:FindAbilityByName("special_bonus_unique_nevermore_1")
		
		if talent and talent:GetLevel() > 0 then
			self.hasTalent = true
			self.talent_ratio = talent:GetSpecialValueFor("value")
			self:ForceRefresh()
			self:StartIntervalThink(-1)
		end
    end
	
	function modifier_nevermore_custom_necromastery:OnAttackLanded(keys)
		local attacker = keys.attacker
		local target = keys.target
		if attacker == self.parent and not target:IsNull() then 
			local stacks = self:GetStackCount()
			if stacks < self.max_souls then
				self:IncrementStackCount()
				self.modifier:SetStackCount(self:GetStackCount() * self.damage_per_soul)
				if stacks % 3 == 0 then
					ProjectileManager:CreateTrackingProjectile({
						Target = self.parent,
						Source = target,
						Ability = self.ability,
						EffectName = "particles/units/heroes/hero_nevermore/nevermore_necro_souls.vpcf",
						bDodgeable = false,
						bProvidesVision = false,
						iMoveSpeed = 1500,
						iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
					})
				end
			end
		end
	end
	function modifier_nevermore_custom_necromastery:OnDeath(keys)
		if keys.unit == self.parent then
			local release = self:GetAbility():GetSpecialValueFor("necromastery_soul_release")
			local new_stack_count = math.ceil(self:GetStackCount() * release)
			self:SetStackCount(new_stack_count)
			if self.parent:HasAbility("nevermore_custom_requiem") then
				local requiem = self.parent:FindAbilityByName("nevermore_custom_requiem")
				if requiem and requiem:GetLevel() >= 1 then
					requiem:OnSpellStart()
				end
			end
		end
	end
end

function modifier_nevermore_custom_necromastery:IsHidden()
    return false
end

function modifier_nevermore_custom_necromastery:IsPurgable()
	return false
end
LinkLuaModifier("modifier_nevermore_custom_necromastery_buff", "abilities/heroes/nevermore_custom_necromastery.lua", LUA_MODIFIER_MOTION_NONE)

modifier_nevermore_custom_necromastery_buff = class({})

function modifier_nevermore_custom_necromastery_buff:IsHidden()
    return true
end
function modifier_nevermore_custom_necromastery_buff:IsPurgable()
	return false
end

function modifier_nevermore_custom_necromastery_buff:RemoveOnDeath()
	return false
end

function modifier_nevermore_custom_necromastery_buff:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if parent:IsIllusion() or parent:HasModifier("modifier_arc_warden_tempest_double") then
			
			local mod1 = "modifier_nevermore_custom_necromastery_buff"
		-- print("ilusion")
			local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
			if owner then       
				if parent:HasModifier(mod1) then
					local modifier1 = parent:FindModifierByName(mod1)
					if owner:HasModifier(mod1) then
						local modifier2 = owner:FindModifierByName(mod1)
						modifier1:SetStackCount(modifier2:GetStackCount())
					end	
					--print("illusion nevermore2")
				end    
			end    
		end
		
	end	
end	

function modifier_nevermore_custom_necromastery_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end

function modifier_nevermore_custom_necromastery_buff:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end
function modifier_nevermore_custom_necromastery_buff:GetModifierSpellAmplify_Percentage()
	local ability = self:GetAbility()
	--local caster = self:GetCaster()
	local mult = ability:GetSpecialValueFor("spell_amp_per_soul")
	local spell_amp = self:GetStackCount() * mult
	return spell_amp
end



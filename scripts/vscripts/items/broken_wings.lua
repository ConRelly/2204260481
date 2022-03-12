LinkLuaModifier("modifier_broken_wings", "items/broken_wings", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broken_wings_feather_stacks", "items/broken_wings", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broken_wings_divinity", "items/broken_wings", LUA_MODIFIER_MOTION_NONE)

------------------
-- Broken Wings --
------------------
item_broken_wings = class({})
function item_broken_wings:GetIntrinsicModifierName() return "modifier_broken_wings" end

function item_broken_wings:OnProjectileHit(target, location)
	if not self:GetCaster():HasItemInInventory("item_broken_wings") then return end
	if not self:GetCaster():HasModifier("modifier_broken_wings") then return end
	local caster = self:GetCaster()
	if caster:IsIllusion() then return end
	local max_stacks = self:GetSpecialValueFor("feather_max_stacks")
	if not target then return false end
	if caster:HasModifier("modifier_broken_wings_divinity") then return end

	if not caster:HasModifier("modifier_broken_wings_feather_stacks") then
		local feather_stacks = caster:AddNewModifier(caster, self, "modifier_broken_wings_feather_stacks", {})
		feather_stacks:SetStackCount(1)
	else
		local feather_stacks = caster:FindModifierByName("modifier_broken_wings_feather_stacks")
		feather_stacks:SetStackCount(feather_stacks:GetStackCount() + 1)
		if feather_stacks:GetStackCount() >= max_stacks then
			feather_stacks:SetStackCount(max_stacks)
			local DivinityDuration = self:GetSpecialValueFor("divinity_duration")
			caster:AddNewModifier(caster, self, "modifier_broken_wings_divinity", {duration = DivinityDuration})
		end
	end
	if caster:HasItemInInventory("item_wind_rapier") then
		local WindChance = self:GetSpecialValueFor("wind_rapier_chance")
		if RollPercentage(WindChance) then
			local WindRapier = caster:FindItemInInventory("item_wind_rapier")
			if caster:HasModifier("modifier_wind_rapier_agility_buff") then
				local WindRapierStack = caster:FindModifierByName("modifier_wind_rapier_agility_buff")
				WindRapierStack:SetStackCount(WindRapierStack:GetStackCount() + 1)
			else
				local duration = WindRapier:GetSpecialValueFor("stack_duration")
				local agility_gain = WindRapier:GetSpecialValueFor("proc_bonus") * 0.01 * caster:GetAgility()
				RapierStacks = caster:AddNewModifier(caster, WindRapier, "modifier_wind_rapier_agility_buff", {agility_gain = agility_gain, duration = duration})
				RapierStacks:SetStackCount(1)
			end
		end
	end

	return true
end


modifier_broken_wings = class({})
function modifier_broken_wings:IsHidden() return true end
function modifier_broken_wings:IsPurgable() return false end
--function modifier_broken_wings:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_broken_wings:DestroyOnExpire() return false end
function modifier_broken_wings:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_broken_wings:OnDestroy()
	if not IsServer() then return end
	if self:GetParent():HasModifier("modifier_broken_wings_feather_stacks") then
		self:GetParent():RemoveModifierByName("modifier_broken_wings_feather_stacks")
	end
end
function modifier_broken_wings:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_broken_wings:GetModifierAttackRangeBonus()
	if self:GetParent():IsRangedAttacker() then if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_attack_range") end end
end
function modifier_broken_wings:GetModifierCastRangeBonusStacking()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_cast_range") end
end
function modifier_broken_wings:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.target
		if not owner:IsRealHero() then return end
--		local max_stacks = self:GetAbility():GetSpecialValueFor("feather_max_stacks")
		if owner ~= keys.attacker then return end
		if owner:HasModifier("modifier_broken_wings_divinity") then return end
		if self:GetRemainingTime() > 0 then return end
		local AttackCD = self:GetAbility():GetSpecialValueFor("attack_cd")
		if owner:HasItemInInventory("item_ultimate_ethereal_blade") then
			AttackCD = AttackCD / 3
		end
		target:EmitSound("Item_Desolator.Target")
--[[
		if not owner:HasModifier("modifier_broken_wings_feather_stacks") then
			feather_stacks = owner:AddNewModifier(owner, self:GetAbility(), "modifier_broken_wings_feather_stacks", {})
			feather_stacks:SetStackCount(1)
		else
			feather_stacks:SetStackCount(feather_stacks:GetStackCount() + 1)
			if feather_stacks:GetStackCount() >= max_stacks then
				feather_stacks:SetStackCount(max_stacks)
				local DivinityDuration = self:GetAbility():GetSpecialValueFor("divinity_duration")
				owner:AddNewModifier(owner, self:GetAbility(), "modifier_broken_wings_divinity", {duration = DivinityDuration})
			end
		end
		if owner:HasItemInInventory("item_wind_rapier") then
			local WindChance = self:GetAbility():GetSpecialValueFor("wind_rapier_chance")
			if RollPercentage(WindChance) then
				local WindRapier = self:GetParent():FindItemInInventory("item_wind_rapier")
				if self:GetParent():HasModifier("modifier_wind_rapier_agility_buff") then
					local WindRapierStack = self:GetParent():FindModifierByName("modifier_wind_rapier_agility_buff")
					WindRapierStack:SetStackCount(WindRapierStack:GetStackCount() + 1)
				else
					local duration = WindRapier:GetSpecialValueFor("stack_duration")
					local agility_gain = WindRapier:GetSpecialValueFor("proc_bonus") * 0.01 * self:GetParent():GetAgility()
					RapierStacks = self:GetParent():AddNewModifier(self:GetParent(), WindRapier, "modifier_wind_rapier_agility_buff", {agility_gain = agility_gain, duration = duration})
					RapierStacks:SetStackCount(1)
				end
			end
		end
]]
		ProjectileManager:CreateTrackingProjectile({
			Target = self:GetCaster(),
			Source = target,
			Ability = self:GetAbility(),
			EffectName = "particles/custom/items/broken_wings/broken_wings_feather.vpcf",
			vSourceLoc = target:GetAbsOrigin(),
			iMoveSpeed = 750,
			bDodgeable = false,
			bVisibleToEnemies = true,
			bReplaceExisting = false,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
			flExpireTime = GameRules:GetGameTime() + 60,
		})
		self:SetDuration(AttackCD, false)
	end
end

--------------------
-- Feather Stacks --
--------------------
modifier_broken_wings_feather_stacks = class({})
function modifier_broken_wings_feather_stacks:IsHidden() return self:GetStackCount() < 1 end
function modifier_broken_wings_feather_stacks:IsPurgable() return false end
function modifier_broken_wings_feather_stacks:DestroyOnExpire() return false end
function modifier_broken_wings_feather_stacks:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	self.hit = true
end
function modifier_broken_wings_feather_stacks:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_broken_wings_feather_stacks:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("feather_spell_amp") * self:GetStackCount() end
end
function modifier_broken_wings_feather_stacks:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("feather_agi") * self:GetStackCount() end
end
function modifier_broken_wings_feather_stacks:GetModifierDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("feather_dmg_red") * self:GetStackCount() * (-1) end
end
function modifier_broken_wings_feather_stacks:OnTakeDamage(keys)
	if not IsServer() then return end
	local caster = self:GetParent()
	local target = keys.unit
	local attacker = keys.attacker
	local DamageType = keys.damage_type
	if not caster:IsRealHero() then return end
	if attacker ~= caster then return end
	if target == attacker then return end
	if self:GetStackCount() < 1 then return end
	if self.hit == true then
		if DamageType == DAMAGE_TYPE_MAGICAL or DamageType == DAMAGE_TYPE_PURE then
			self.hit = false
			local feather_add_dmg = self:GetAbility():GetSpecialValueFor("feather_add_dmg")
			local max_used_stacks = 50
			if caster:HasModifier("modifier_super_scepter") then
				if caster:HasModifier("modifier_marci_unleash_flurry") then
					feather_add_dmg = self:GetAbility():GetSpecialValueFor("feather_add_dmg_marci")
					max_used_stacks = 3
				end                                 
			end
			local orig_dmg = keys.original_damage
			local lvl = caster:GetLevel()
			local spell_amp = caster:GetSpellAmplification(false)
			local limit_magic = math.floor( lvl * 100000 / spell_amp)
			local limit_pure = math.floor( lvl * 10000 / spell_amp)
			local limit = 0
			local used_stacks = 1
			if DamageType == DAMAGE_TYPE_MAGICAL then 
				limit = limit_magic
			elseif DamageType == DAMAGE_TYPE_PURE then
				limit = limit_pure	
			end		
			if orig_dmg > limit then
				if caster:HasModifier("modifier_broken_wings_divinity") then 
					orig_dmg = limit
				end
				used_stacks = math.ceil(orig_dmg / limit + 1)
				if used_stacks > 50 then
					used_stacks = max_used_stacks
				end
			end
			local damage = math.floor(orig_dmg * ((feather_add_dmg - 100) / 100))
			local damage_popup = math.floor(orig_dmg * (feather_add_dmg / 100))				
			ApplyDamage({
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = DamageType,
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
				ability = self:GetAbility(),
			})
			create_popup({
				target = target,
				value = damage_popup,
				color = Vector(160, 202, 224),
				type = "null_ultimate",
				pos = 9
			})
			if caster:HasModifier("modifier_broken_wings_divinity") then self.hit = true return end
			local cd = self:GetAbility():GetSpecialValueFor("feather_cd") * self:GetCaster():GetCooldownReduction()
			Timers:CreateTimer(cd, function() self.hit = true end)
			self:SetStackCount(self:GetStackCount() - used_stacks)
		end
	end
end

--------------
-- Divinity --
--------------
modifier_broken_wings_divinity = class({})
function modifier_broken_wings_divinity:IsHidden() return false end
function modifier_broken_wings_divinity:IsPurgable() return false end
function modifier_broken_wings_divinity:RemoveOnDeath() return false end
function modifier_broken_wings_divinity:GetEffectName()
	return "particles/custom/items/broken_wings/broken_wings_divinity.vpcf"
end
function modifier_broken_wings_divinity:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_broken_wings_divinity:OnCreated()
	if IsServer() then
		local player = PlayerResource:GetPlayer(self:GetParent():GetPlayerID())
		screen_pfx = ParticleManager:CreateParticleForPlayer("particles/custom/items/broken_wings/broken_wings_divinity_screen.vpcf", PATTACH_ABSORIGIN, self:GetParent(), player)
		ParticleManager:SetParticleControl(screen_pfx, 1, Vector(1, 0, 0))
	end
end
function modifier_broken_wings_divinity:OnDestroy()
	if not IsServer() then return end
	self:GetParent():FindModifierByName("modifier_broken_wings_feather_stacks"):SetStackCount(0)
	if screen_pfx then
		ParticleManager:DestroyParticle(screen_pfx, false)
		ParticleManager:ReleaseParticleIndex(screen_pfx)
	end
end
function modifier_broken_wings_divinity:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING}
end
function modifier_broken_wings_divinity:GetModifierPercentageManacostStacking() return 100 end

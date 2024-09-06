----------------------------
-- Divine Obsidian Rapier --
----------------------------
LinkLuaModifier("modifier_item_obsidian_rapier", "items/obsidian_rapier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_obsidian_rapier", "items/obsidian_rapier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_obsidian_rapier_active", "items/obsidian_rapier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_obsidian_rapier_stun", "items/obsidian_rapier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_obsidian_rapier_shard_debuff", "items/obsidian_rapier", LUA_MODIFIER_MOTION_NONE)

item_obsidian_rapier = item_obsidian_rapier or class({})
function item_obsidian_rapier:IsRefreshable() return false end
function item_obsidian_rapier:GetIntrinsicModifierName() return "modifier_item_obsidian_rapier" end
function item_obsidian_rapier:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("active_duration")
-- Earth's True Power
	caster:AddNewModifier(caster, self, "modifier_obsidian_rapier_active", {duration = duration})
end

modifier_item_obsidian_rapier = class({})
function modifier_item_obsidian_rapier:IsHidden() return true end
function modifier_item_obsidian_rapier:IsPurgable() return false end
function modifier_item_obsidian_rapier:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end
function modifier_item_obsidian_rapier:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if not caster:HasAbility("obsidian_rapier") then
		self.obsidianAbility = caster:AddAbility("obsidian_rapier")
		self.obsidianAbility:SetLevel(1)
		self:StartIntervalThink(-1)
	end
end
function modifier_item_obsidian_rapier:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if self.obsidianAbility then
		caster:RemoveAbilityByHandle(self.obsidianAbility)
	end
end



obsidian_rapier = obsidian_rapier or class({})
function obsidian_rapier:Precache(context)
	PrecacheResource("particle", "particles/custom/items/obsidian_rapier/obsidian_boulder.vpcf", context)
	PrecacheResource("particle", "particles/generic_gameplay/generic_stunned.vpcf", context)
end
function obsidian_rapier:GetIntrinsicModifierName() return "modifier_obsidian_rapier" end
function obsidian_rapier:OnProjectileHit_ExtraData(target, loc, ExtraData)
	if not IsServer() then return end
	local caster = self:GetCaster()
	
	if target then
	--	target:EmitSound("n_mud_golem.Boulder.Target")
	-- Divine Shard --
		if RollPseudoRandomPercentage(math.min(ExtraData.stun_chance, 100), self:entindex(), target) then
			target:AddNewModifier(caster, self, "modifier_obsidian_rapier_stun", {duration = ExtraData.stun_duration, stun_dmg_amp = ExtraData.stun_dmg_amp})
		end
		if ExtraData.shard == 1 then
			local shard_armor = self:GetSpecialValueFor("obsidian_shard_armor")
			local shard_duration = self:GetSpecialValueFor("obsidian_shard_duration")
			target:AddNewModifier(caster, self, "modifier_obsidian_rapier_shard_debuff", {duration = shard_duration, shard_armor = shard_armor})
		end
		local damageFlags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
		if ExtraData.sphere == 1 then
			damageFlags = damageFlags + DOTA_DAMAGE_FLAG_IGNORES_BASE_PHYSICAL_ARMOR
		end
		
		local damageTable = {
			victim = target,
			attacker = caster,
			ability = self,
			damage = ExtraData.damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage_flags = damageFlags,
		}
		local dmgDealt = ApplyDamage(damageTable)
		
		local chance_threshold = self:GetSpecialValueFor("obsidian_chance_threshold")
		local max_threshold = self:GetSpecialValueFor("obsidian_max_threshold")
		local dmg_threshold = self:GetSpecialValueFor("obsidian_dmg_threshold") * 1000000
		if caster.obsidianDamageStacks then
			if not caster.limit_reach then
				caster.obsidianDamageStacks = caster.obsidianDamageStacks + dmgDealt
				--print("total obsidian dmg dealt: "..caster.obsidianDamageStacks)
				if caster.obsidianDamageStacks >= dmg_threshold then
					caster.obsidianDamageStacks = caster.obsidianDamageStacks - dmg_threshold
					caster.obsidianStacks = math.min(caster.obsidianStacks + chance_threshold, max_threshold)
					caster:SetModifierStackCount(self:GetIntrinsicModifierName(), caster, caster.obsidianStacks)
					print("obs stacks chance: ".. caster.obsidianStacks)
					-- Increase item charges to symbolize the extra chance (caster.obsidianStacks)
					local item = caster:FindItemInInventory("item_obsidian_rapier")
					if item then
						item:SetCurrentCharges(caster.obsidianStacks)
					end	
					if caster.obsidianStacks > 22 then
						caster.limit_reach = true
					end
				end
			end
		end
		if target:IsAlive() and ExtraData.stone == 1 then
			local modif_rapier = caster:HasModifier("modifier_obsidian_rapier_active")
			local modif_hammer = caster:HasModifier("modifier_hotd_pure_divinity")
			if modif_rapier or modif_hammer then
				ExtraData.stone = nil
				local sphere_chance = self:GetSpecialValueFor("obsidian_sphere_chance")
				local shard_chance = self:GetSpecialValueFor("obsidian_shard_chance")
				if RollPseudoRandomPercentage(math.min(sphere_chance, 100), self:entindex()+1, target) then
					self:ThrowObsidianSphere(target, ExtraData)
				elseif RollPseudoRandomPercentage(math.min(shard_chance, 100), self:entindex()+2, target) then
					self:ThrowObsidianShard(target, ExtraData)
				end
			end
		end
		return true
	end
end
function obsidian_rapier:ThrowObsidianStone(target, data)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local data = data or {}
	local base_damage = data.base_damage or self:GetSpecialValueFor("obsidian_base_damage")
-- Divine Growth
	local base_str_damage = data.base_str_damage or self:GetSpecialValueFor("obsidian_base_str_damage")
	local total_str_damage = data.total_str_damage or self:GetSpecialValueFor("obsidian_total_str_damage")
	if caster:HasModifier("modifier_rolling_stone_buff") then
		base_str_damage = base_str_damage * (1 + (self:GetSpecialValueFor("up_rolling_stone_divine") / 100))
		total_str_damage = total_str_damage * (1 + (self:GetSpecialValueFor("up_rolling_stone_divine") / 100))
	end
	local spell_amp_dmg = data.spell_amp_dmg or self:GetSpecialValueFor("obsidian_spell_amp_dmg")
	
	local damage = base_damage
	if caster.GetBaseStrength and caster:GetBaseStrength() then
		damage = damage + (caster:GetBaseStrength() * base_str_damage )
	end
	if caster.GetStrength and caster:GetStrength() then
		damage = damage + (caster:GetStrength() * total_str_damage )
	end
	if caster.GetSpellAmplification and caster:GetSpellAmplification(false) then
		damage = damage + (caster:GetSpellAmplification(false) * (spell_amp_dmg / 100))
	end
	damage = damage * (data.total_damage or 1)
	
	local stun_chance = data.stun_chance or self:GetSpecialValueFor("obsidian_stun_chance")
	local stun_duration = data.stun_duration or self:GetSpecialValueFor("obsidian_stun_duration")
	local stun_dmg_amp = data.stun_dmg_amp or self:GetSpecialValueFor("obsidian_stun_dmg_amp")
	
-- Obsidian Strike
--	caster:EmitSound("n_mud_golem.Boulder.Cast")
	local proj = {
		Source = caster,
		Target = target,
		Ability = self,
		EffectName = "particles/custom/items/obsidian_rapier/obsidian_boulder.vpcf",
		iMoveSpeed = data.speed or 1500,
		bDodgeable = true,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		ExtraData = {
			damage = damage,
			stun_chance = stun_chance,
			stun_duration = stun_duration,
			stun_dmg_amp = stun_dmg_amp,
			stone = 1,
		}
	}
	ProjectileManager:CreateTrackingProjectile(proj)
end
function obsidian_rapier:ThrowObsidianSphere(target, data)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local data = data or {}
	local base_damage = data.base_damage or self:GetSpecialValueFor("obsidian_base_damage")
-- Divine Growth
	local base_str_damage = data.base_str_damage or self:GetSpecialValueFor("obsidian_base_str_damage")
	local total_str_damage = data.total_str_damage or self:GetSpecialValueFor("obsidian_total_str_damage")
	local spell_amp_dmg = data.spell_amp_dmg or self:GetSpecialValueFor("obsidian_spell_amp_dmg")
	if caster:HasModifier("modifier_rolling_stone_buff") then
		base_str_damage = base_str_damage * (1 + (self:GetSpecialValueFor("up_rolling_stone_divine") / 100))
		total_str_damage = total_str_damage * (1 + (self:GetSpecialValueFor("up_rolling_stone_divine") / 100))
	end
-- Earth's Core
	local sphere_dmg = data.sphere_dmg or self:GetSpecialValueFor("obsidian_sphere_dmg")
	
	local damage = base_damage
	if caster.GetBaseStrength and caster:GetBaseStrength() then
		damage = damage + (caster:GetBaseStrength() * base_str_damage )
	end
	if caster.GetStrength and caster:GetStrength() then
		damage = damage + (caster:GetStrength() * total_str_damage )
	end
	if caster.GetSpellAmplification and caster:GetSpellAmplification(false) then
		damage = damage + (caster:GetSpellAmplification(false) * (spell_amp_dmg / 100))
	end
	damage = damage * (data.total_damage or 1) * (sphere_dmg / 100)
	
	local stun_chance = data.stun_chance or self:GetSpecialValueFor("obsidian_stun_chance")
	local stun_duration = data.stun_duration or self:GetSpecialValueFor("obsidian_stun_duration")
	local stun_dmg_amp = data.stun_dmg_amp or self:GetSpecialValueFor("obsidian_stun_dmg_amp")
	
-- Obsidian Strike
--	caster:EmitSound("n_mud_golem.Boulder.Cast")
	local proj = {
		Source = caster,
		Target = target,
		Ability = self,
		EffectName = "particles/custom/items/obsidian_rapier/obsidian_boulder.vpcf",
		iMoveSpeed = data.speed or 900,
		bDodgeable = true,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		ExtraData = {
			damage = damage,
			stun_chance = 0,
			stun_duration = stun_duration,
			stun_dmg_amp = stun_dmg_amp,
			sphere = 1,
		}
	}
	ProjectileManager:CreateTrackingProjectile(proj)
end
function obsidian_rapier:ThrowObsidianShard(target, data)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local data = data or {}
	local base_damage = data.base_damage or self:GetSpecialValueFor("obsidian_base_damage")
-- Divine Growth
	local base_str_damage = data.base_str_damage or self:GetSpecialValueFor("obsidian_base_str_damage")
	local total_str_damage = data.total_str_damage or self:GetSpecialValueFor("obsidian_total_str_damage")
	local spell_amp_dmg = data.spell_amp_dmg or self:GetSpecialValueFor("obsidian_spell_amp_dmg")
	if caster:HasModifier("modifier_rolling_stone_buff") then
		base_str_damage = base_str_damage * (1 + (self:GetSpecialValueFor("up_rolling_stone_divine") / 100))
		total_str_damage = total_str_damage * (1 + (self:GetSpecialValueFor("up_rolling_stone_divine") / 100))
	end
-- Earth's Core
	local shard_dmg = data.shard_dmg or self:GetSpecialValueFor("obsidian_shard_dmg")
	
	local damage = base_damage
	if caster.GetBaseStrength and caster:GetBaseStrength() then
		damage = damage + (caster:GetBaseStrength() * base_str_damage )
	end
	if caster.GetStrength and caster:GetStrength() then
		damage = damage + (caster:GetStrength() * total_str_damage )
	end
	if caster.GetSpellAmplification and caster:GetSpellAmplification(false) then
		damage = damage + (caster:GetSpellAmplification(false) * (spell_amp_dmg / 100))
	end
	damage = damage * (data.total_damage or 1) * (shard_dmg / 100)
	
	local stun_chance = data.stun_chance or self:GetSpecialValueFor("obsidian_stun_chance")
	local stun_duration = data.stun_duration or self:GetSpecialValueFor("obsidian_stun_duration")
	local stun_dmg_amp = data.stun_dmg_amp or self:GetSpecialValueFor("obsidian_stun_dmg_amp")
	
-- Obsidian Strike
--	caster:EmitSound("n_mud_golem.Boulder.Cast")
	local proj = {
		Source = caster,
		Target = target,
		Ability = self,
		EffectName = "particles/custom/items/obsidian_rapier/obsidian_boulder.vpcf",
		iMoveSpeed = data.speed or 900,
		bDodgeable = true,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		ExtraData = {
			damage = damage,
			stun_chance = 0,
			stun_duration = stun_duration,
			stun_dmg_amp = stun_dmg_amp,
			shard = 1,
		}
	}
	ProjectileManager:CreateTrackingProjectile(proj)
end


modifier_obsidian_rapier = class({})
function modifier_obsidian_rapier:IsHidden() return true end
function modifier_obsidian_rapier:IsPurgable() return false end
function modifier_obsidian_rapier:RemoveOnDeath() return false end
function modifier_obsidian_rapier:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	caster.obsidianDamageStacks = caster.obsidianDamageStacks or 0
	caster.obsidianStacks = caster.obsidianStacks or 0
	caster.limit_reach = caster.limit_reach or false
	if self:GetAbility() then
		local interval = self:GetAbility():GetSpecialValueFor("up_giants_interval")
		self:StartIntervalThink(interval)
	end

end
function modifier_obsidian_rapier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_obsidian_rapier:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_strength") end
end
function modifier_obsidian_rapier:GetModifierStatusResistanceStacking()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_status_resist") end
end
function modifier_obsidian_rapier:GetModifierManaBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_mana") end
end
function modifier_obsidian_rapier:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_spell_amp") end
end
function modifier_obsidian_rapier:GetModifierTotalDamageOutgoing_Percentage(keys)
	if keys.damage_type ~= 1 then return end
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_phys_dmg") end
end
function modifier_obsidian_rapier:OnAttackLanded(keys)
	if not IsServer() then return end
	if not self:GetAbility() then return end
	local owner = self:GetParent()
	local target = keys.target
	if owner ~= keys.attacker then return end
	if not owner:IsRealHero() then return end
	if owner:IsIllusion() then return end
	if target == nil then return end
	if target.GetUnitName == nil then return end

	local chance = self:GetAbility():GetSpecialValueFor("obsidian_base_chance")
	if owner:HasModifier("modifier_obsidian_rapier_active") then
		chance = chance + self:GetAbility():GetSpecialValueFor("active_bonus_chance")
	end
	if owner.obsidianStacks then
		chance = chance + owner.obsidianStacks
	end
	if RollPseudoRandomPercentage(math.min(chance, 100), self:GetAbility():entindex(), keys.attacker) then
		self:GetAbility():ThrowObsidianStone(target)
	end
end
function modifier_obsidian_rapier:OnIntervalThink()
    if not IsServer() then return end

    local caster = self:GetCaster()
	if self:GetAbility() then
		-- Check if the caster has the "modifier_item_giants_ring" modifier
		if caster:HasModifier("modifier_item_giants_ring") then
			local ring_aoe = self:GetAbility():GetSpecialValueFor("up_giants_aoe")
			-- Find all enemy units within a 1000 range
			local enemies = FindUnitsInRadius(
				caster:GetTeamNumber(),
				caster:GetAbsOrigin(),
				nil,
				ring_aoe,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_ANY_ORDER,
				false
			)

			-- Throw obsidian at each enemy
			for i = 1, #enemies do
				self:GetAbility():ThrowObsidianStone(enemies[i])
			end
		end
	end
end
-- Divine Obsidian Rapier Active
modifier_obsidian_rapier_active = class({})
function modifier_obsidian_rapier_active:IsHidden() return false end
function modifier_obsidian_rapier_active:IsPurgable() return false end


-- Divine Obsidian Rapier Stun
modifier_obsidian_rapier_stun = class({})
function modifier_obsidian_rapier_stun:IsHidden() return false end
function modifier_obsidian_rapier_stun:IsPurgeException() return true end
function modifier_obsidian_rapier_stun:IsStunDebuff() return true end
function modifier_obsidian_rapier_stun:GetEffectName() return "particles/generic_gameplay/generic_stunned.vpcf" end
function modifier_obsidian_rapier_stun:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_obsidian_rapier_stun:OnCreated(keys)
	if not IsServer() then return end
	self.stun_dmg_amp = keys.stun_dmg_amp
	self:SetHasCustomTransmitterData(true)
end
function modifier_obsidian_rapier_stun:OnRefresh(keys)
	if not IsServer() then return end
	self.stun_dmg_amp = keys.stun_dmg_amp
	self:SendBuffRefreshToClients()
end
function modifier_obsidian_rapier_stun:AddCustomTransmitterData()
	return {
		stun_dmg_amp = self.stun_dmg_amp
	}
end
function modifier_obsidian_rapier_stun:HandleCustomTransmitterData(data)
	self.stun_dmg_amp = data.stun_dmg_amp
end
function modifier_obsidian_rapier_stun:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE} end
function modifier_obsidian_rapier_stun:GetModifierIncomingPhysicalDamage_Percentage(keys)
	if keys.inflictor and self:GetAbility() and keys.inflictor:GetAbilityName() == self:GetAbility():GetAbilityName() then
		return self.stun_dmg_amp
	end
end
function modifier_obsidian_rapier_stun:GetOverrideAnimation()
	if self:GetParent().bAbsoluteNoCC then return end
	return ACT_DOTA_DISABLED
end
function modifier_obsidian_rapier_stun:CheckState()
	if self:GetParent().bAbsoluteNoCC then return end
	return {[MODIFIER_STATE_STUNNED] = true}
end


-- Divine Obsidian Rapier Shard debuff
modifier_obsidian_rapier_shard_debuff = class({})
function modifier_obsidian_rapier_shard_debuff:IsHidden() return false end
function modifier_obsidian_rapier_shard_debuff:IsPurgable() return true end
function modifier_obsidian_rapier_shard_debuff:OnCreated(keys)
	if not IsServer() then return end
	self.shard_armor = 0
	self:GetParent():CalculateGenericBonuses()
	
	self.shard_armor = self:GetParent():GetPhysicalArmorValue(false) * (keys.shard_armor / 100)
	self:SetHasCustomTransmitterData(true)
end
function modifier_obsidian_rapier_shard_debuff:OnRefresh(keys)
	if not IsServer() then return end
	self.shard_armor = 0
	self:GetParent():CalculateGenericBonuses()
	
	self.shard_armor = self:GetParent():GetPhysicalArmorValue(false) * (keys.shard_armor / 100)
	self:SendBuffRefreshToClients()
end
function modifier_obsidian_rapier_shard_debuff:AddCustomTransmitterData()
	return {
		shard_armor = self.shard_armor
	}
end
function modifier_obsidian_rapier_shard_debuff:HandleCustomTransmitterData(data)
	self.shard_armor = data.shard_armor
end
function modifier_obsidian_rapier_shard_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_obsidian_rapier_shard_debuff:GetModifierPhysicalArmorBonus()
	return self.shard_armor * (-1)
end

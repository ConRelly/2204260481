LinkLuaModifier("modifier_broken_wings", "items/broken_wings", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broken_wings_feather_stacks", "items/broken_wings", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broken_wings_permanent_feathers", "items/broken_wings", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broken_wings_divinity", "items/broken_wings", LUA_MODIFIER_MOTION_NONE)

local featherModifier = "modifier_broken_wings_feather_stacks"
-- Keep the modifier ID so existing feather stacks survive a script reload.
local divinityFeatherModifier = "modifier_broken_wings_permanent_feathers"

local function GetFeatherStacks(hero, item)
	return hero:FindModifierByName(featherModifier) or hero:AddNewModifier(hero, item, featherModifier, {})
end

------------------
-- Broken Wings --
------------------
item_broken_wings = class({})
function item_broken_wings:GetIntrinsicModifierName() return "modifier_broken_wings" end

function item_broken_wings:OnProjectileHit(target, location)
	if not target then return false end
	local caster = self:GetCaster()
	if not caster or not caster:IsRealHero() or caster:IsIllusion() then return end
	if not caster:HasItemInInventory("item_broken_wings") or not caster:HasModifier("modifier_broken_wings") then return end
	if caster:HasModifier("modifier_broken_wings_divinity") then return end
	if not self.windbuff then
		self.windbuff = true
		self.hadwindbuff = false 
	end	
	local featherStacks = GetFeatherStacks(caster, self)
	if not featherStacks then return end
	local maxStacks = self:GetSpecialValueFor("feather_max_stacks")
	if RollPercentage(self:GetSpecialValueFor("permanent_feather_chance")) then
		local divinityStacks = caster:FindModifierByName(divinityFeatherModifier)
			or caster:AddNewModifier(caster, nil, divinityFeatherModifier, {})
		if not divinityStacks then return end
		divinityStacks:IncrementStackCount()
		featherStacks:ForceRefresh()
	else
		featherStacks:SetStackCount(math.min(maxStacks, featherStacks:GetStackCount() + 1))
	end
	if featherStacks:GetTotalFeathers() >= maxStacks then
		caster:AddNewModifier(caster, self, "modifier_broken_wings_divinity", {duration = self:GetSpecialValueFor("divinity_duration")})
	end
	if caster:HasItemInInventory("item_wind_rapier") then
		local WindChance = self:GetSpecialValueFor("wind_rapier_chance")
		if RollPercentage(WindChance) then
			local WindRapier = caster:FindItemInInventory("item_wind_rapier")
			local haswindModif = caster:HasModifier("modifier_wind_rapier_agility_buff")
			if haswindModif then
				self.hadwindbuff = true
				local WindRapierStack = caster:FindModifierByName("modifier_wind_rapier_agility_buff")
				WindRapierStack:SetStackCount(WindRapierStack:GetStackCount() + 1)
			elseif self.hadwindbuff then -- fix the bug if you buy wind rapier and never take out of backpack(item is not complete in creation). and keep the backpack Trick.
				local duration = WindRapier:GetSpecialValueFor("stack_duration")
				local agility_gain = WindRapier:GetSpecialValueFor("proc_bonus") * 0.01 * caster:GetAgility()

				RapierStacks = caster:AddNewModifier(caster, WindRapier, "modifier_wind_rapier_agility_buff", {agility_gain = agility_gain, duration = duration})
				if haswindModif then
					RapierStacks:SetStackCount(1)
				end	
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
	if not IsServer() then return end
	if not self:GetAbility() then
		self:Destroy()
		return
	end
	self:RestoreDivinityFeatherBonuses()
end
function modifier_broken_wings:RestoreDivinityFeatherBonuses()
	local hero = self:GetParent()
	local item = self:GetAbility()
	if item and hero:HasModifier(divinityFeatherModifier) then GetFeatherStacks(hero, item) end
end
function modifier_broken_wings:OnRespawn(keys)
	if IsServer() and keys.unit == self:GetParent() then self:RestoreDivinityFeatherBonuses() end
end
function modifier_broken_wings:OnDestroy()
	if not IsServer() then return end
	if self:GetParent():HasModifier("modifier_broken_wings_feather_stacks") then
		self:GetParent():RemoveModifierByName("modifier_broken_wings_feather_stacks")
	end
end
function modifier_broken_wings:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_RESPAWN}
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
		if owner:IsIllusion() then return end
		if target == nil then return end
		if owner:HasModifier("modifier_broken_wings_divinity") then return end
		if self:GetRemainingTime() > 0 then return end
		local AttackCD = self:GetAbility():GetSpecialValueFor("attack_cd")
		if owner:HasItemInInventory("item_ultimate_ethereal_blade") then
			AttackCD = AttackCD / 3
		end
		self:SetDuration(AttackCD, false)
		--target:EmitSound("Item_Desolator.Target")
		ProjectileManager:CreateTrackingProjectile({
			Target = owner,
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
end
function modifier_broken_wings_feather_stacks:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_broken_wings_feather_stacks:GetModifierSpellAmplify_Percentage()
	return self:GetFeatherBonus("feather_spell_amp")
end
function modifier_broken_wings_feather_stacks:GetModifierBonusStats_Agility()
	return self:GetFeatherBonus("feather_agi")
end
function modifier_broken_wings_feather_stacks:GetModifierDamageOutgoing_Percentage()
	return -self:GetFeatherBonus("feather_dmg_red")
end
function modifier_broken_wings_feather_stacks:GetTotalFeathers()
	local hero = self:GetParent()
	return self:GetStackCount() + hero:GetModifierStackCount(divinityFeatherModifier, hero)
end
function modifier_broken_wings_feather_stacks:GetFeatherBonus(name)
	local item = self:GetAbility()
	if not item then return 0 end
	local count = math.min(self:GetTotalFeathers(), item:GetSpecialValueFor("feather_max_stacks"))
	return item:GetSpecialValueFor(name) * count
end

modifier_broken_wings_permanent_feathers = class({})
function modifier_broken_wings_permanent_feathers:IsHidden() return false end
function modifier_broken_wings_permanent_feathers:IsPurgable() return false end
function modifier_broken_wings_permanent_feathers:RemoveOnDeath() return false end
function modifier_broken_wings_permanent_feathers:GetTexture() return "custom/broken_wings" end


local function GetInventorySlot(hero)
	for slot = 0, 5 do
		local item = hero:GetItemInSlot(slot)
		if item and not item:IsNull() and item:GetName() == "item_broken_wings" then return slot end
	end
	return 0
end

local function GetDamageLimit(hero, item, damageType, divinity)
	local spellAmp = hero:GetSpellAmplification(false)
	if spellAmp <= 0 then return math.huge end
	local level = hero:GetLevel()
	if level > 100 then level = 100 + (level - 100) * 10 end
	local coefficient = item:GetSpecialValueFor(damageType == DAMAGE_TYPE_MAGICAL and "damage_limit_magic" or "damage_limit_pure")
	local limit = level * item:GetSpecialValueFor("damage_limit_multiplier") * coefficient / spellAmp
	if divinity then limit = limit * item:GetSpecialValueFor("divinity_limit_multiplier") end
	return math.max(1, math.floor(limit))
end

function modifier_broken_wings_feather_stacks:OnTakeDamage(keys)
	if not IsServer() or self.applyingFeatherDamage then return end
	local caster = self:GetParent()
	local damageType = keys.damage_type
	local originalDamage = keys.original_damage
	if keys.attacker ~= caster or keys.unit == caster or not caster:IsRealHero()
		or (damageType ~= DAMAGE_TYPE_MAGICAL and damageType ~= DAMAGE_TYPE_PURE)
		or not originalDamage or originalDamage < 2 then return end
	local item = self:GetAbility()
	if not item or self:GetTotalFeathers() < 1 then return end

	local divinity = caster:HasModifier("modifier_broken_wings_divinity")
	local now = GameRules:GetGameTime()
	if now < (self.nextFeatherProc or 0) then return end
	local slot = GetInventorySlot(caster)
	local limit = GetDamageLimit(caster, item, damageType, divinity)
	if not divinity and slot > 0 and originalDamage < limit / slot then return end

	local usedStacks = slot == 0 and 1 or 0
	if originalDamage > limit then
		if divinity then
			if originalDamage > limit * 4 then
				originalDamage = limit / 6
			elseif originalDamage > limit * 3 then
				originalDamage = limit / 4
			elseif originalDamage > limit * 2 then
				originalDamage = limit / 3
			else
				originalDamage = limit / 2
			end
		else
			usedStacks = math.min(49, math.max(1, math.ceil(originalDamage / (limit + 1))))
		end
	end

	local damageMultiplier = item:GetSpecialValueFor("feather_add_dmg")
	if caster:HasModifier("modifier_super_scepter") and caster:HasModifier("modifier_marci_unleash_flurry") then
		damageMultiplier = item:GetSpecialValueFor("feather_add_dmg_marci")
		usedStacks = math.min(usedStacks, 3)
	end
	if not divinity then
		if usedStacks > self:GetStackCount() then return end
		self.nextFeatherProc = now + item:GetSpecialValueFor("feather_cd") * caster:GetCooldownReduction()
	end

	self.applyingFeatherDamage = true
	ApplyDamage({
		victim = keys.unit,
		attacker = caster,
		damage = math.floor(originalDamage * (damageMultiplier - 100) / 100),
		damage_type = damageType,
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		ability = item,
	})
	self.applyingFeatherDamage = false
	if not divinity and usedStacks > 0 and not self:IsNull() then
		self:SetStackCount(math.max(0, self:GetStackCount() - usedStacks))
	end
	create_popup({
		target = keys.unit,
		value = math.floor(originalDamage * damageMultiplier / 100),
		color = Vector(160, 202, 224),
		type = "null_ultimate",
		pos = 9,
	})
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
	if not IsServer() then return end
	local player = PlayerResource:GetPlayer(self:GetParent():GetPlayerID())
	if not player then return end
	self.screenParticle = ParticleManager:CreateParticleForPlayer("particles/custom/items/broken_wings/broken_wings_divinity_screen.vpcf", PATTACH_ABSORIGIN, self:GetParent(), player)
	ParticleManager:SetParticleControl(self.screenParticle, 1, Vector(1, 0, 0))
end
function modifier_broken_wings_divinity:OnDestroy()
	if not IsServer() then return end
	local hero = self:GetParent()
	if hero and not hero:IsNull() then
		hero:RemoveModifierByName(divinityFeatherModifier)
		local featherStacks = hero:FindModifierByName(featherModifier)
		if featherStacks then
			featherStacks:SetStackCount(0)
			featherStacks:ForceRefresh()
		end
	end
	if self.screenParticle then
		ParticleManager:DestroyParticle(self.screenParticle, false)
		ParticleManager:ReleaseParticleIndex(self.screenParticle)
	end
end
function modifier_broken_wings_divinity:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING}
end
function modifier_broken_wings_divinity:GetModifierPercentageManacostStacking() return 100 end

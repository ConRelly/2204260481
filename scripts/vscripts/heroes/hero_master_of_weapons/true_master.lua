LinkLuaModifier("modifier_true_master", "heroes/hero_master_of_weapons/true_master", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_true_master_sword", "heroes/hero_master_of_weapons/true_master", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_true_master_dagger", "heroes/hero_master_of_weapons/true_master", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_true_master_dagger_bleed", "heroes/hero_master_of_weapons/true_master", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_true_master_dagger_stacks", "heroes/hero_master_of_weapons/true_master", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_true_master_gun", "heroes/hero_master_of_weapons/true_master", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_true_master_gun_reload", "heroes/hero_master_of_weapons/true_master", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_true_master_dagger_bleed_initial", "heroes/hero_master_of_weapons/true_master", LUA_MODIFIER_MOTION_NONE)


true_master = class({})
function true_master:GetIntrinsicModifierName() return "modifier_true_master" end
function true_master:GetCooldown(lvl)
    return self:GetSpecialValueFor("fixed_cooldown") / self:GetCaster():GetCooldownReduction()
end
function true_master:OnSpellStart()
	if not IsServer() then return end
	if self:GetCaster():HasModifier("modifier_true_master_gun") then
		self:GetCaster():RemoveModifierByName("modifier_true_master_gun")
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_true_master_sword", {})
	elseif self:GetCaster():HasModifier("modifier_true_master_sword") then
		self:GetCaster():RemoveModifierByName("modifier_true_master_sword")
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_true_master_dagger", {})
	elseif self:GetCaster():HasModifier("modifier_true_master_dagger") then
		self:GetCaster():RemoveModifierByName("modifier_true_master_dagger")
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_true_master_gun", {})
	end
end
function true_master:GetAbilityTextureName()
	local sword = self:GetCaster():HasModifier("modifier_true_master_sword")
	local dagger = self:GetCaster():HasModifier("modifier_true_master_dagger")
	local gun = self:GetCaster():HasModifier("modifier_true_master_gun")
    if sword then
		return "msword"
	elseif dagger then		
		return "mdagger"
	elseif gun then	
		return "mgun"
	end	
	return "msword"
end

modifier_true_master = class({})
function modifier_true_master:IsHidden() return true end
function modifier_true_master:IsPurgable() return false end
function modifier_true_master:RemoveOnDeath() return false end
function modifier_true_master:OnCreated()
	if not IsServer() then return end
	local RandomWeapon = RandomInt(1, 3)
	if RandomWeapon == 1 then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_true_master_sword", {})
	elseif RandomWeapon == 2 then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_true_master_dagger", {})
	elseif RandomWeapon == 3 then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_true_master_gun", {})
	end
end


--[[ function modifier_true_master:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING, MODIFIER_PROPERTY_MODEL_SCALE}
end

function modifier_true_master:GetModifierPercentageCooldownStacking()
	if self:GetParent():GetLevel() >= 35 then
		return 30
	end
	return 0
end
function modifier_true_master:GetModifierModelScale()
	return -50
end ]]

-----------
-- Sword --
-----------
modifier_true_master_sword = class({})
function modifier_true_master_sword:IsHidden() return false end
function modifier_true_master_sword:IsPurgable() return false end
function modifier_true_master_sword:RemoveOnDeath() return false end
function modifier_true_master_sword:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end
function modifier_true_master_sword:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor("sword_bonus_attack_range")
end
function modifier_true_master_sword:GetModifierPreAttack_CriticalStrike(params)
	if IsServer() then
		if self:GetAbility() and RollPercentage(self:GetAbility():GetSpecialValueFor("sword_crit_chance")) then
			return self:GetAbility():GetLevelSpecialValueFor("sword_crit_damage", RandomInt(1, self:GetAbility():GetLevel()))
		end
		return 0
	end
end

------------
-- Dagger --
------------

modifier_true_master_dagger = class({})
function modifier_true_master_dagger:IsAura() return true end
function modifier_true_master_dagger:IsHidden() return false end
function modifier_true_master_dagger:IsPurgable() return false end
function modifier_true_master_dagger:RemoveOnDeath() return false end
function modifier_true_master_dagger:GetAuraRadius() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("dagger_aura_range") end end
function modifier_true_master_dagger:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_true_master_dagger:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_true_master_dagger:GetModifierAura() return "modifier_true_master_dagger_bleed_initial" end
function modifier_true_master_dagger:GetAuraDuration() return -1 end
function modifier_true_master_dagger:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAX_ATTACK_RANGE, MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT, MODIFIER_PROPERTY_AVOID_DAMAGE,}
end
function modifier_true_master_dagger:GetModifierMaxAttackRange()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("dagger_max_attack_range")
	end	
end
function modifier_true_master_dagger:GetModifierIgnoreMovespeedLimit() return 1 end
function modifier_true_master_dagger:GetModifierAvoidDamage(keys)
	if keys.damage > 0 then
		if self:GetAbility() and RollPercentage(self:GetAbility():GetSpecialValueFor("dagger_dodge_chance")) then
			return 1
		end
	end
	return 0
end

-- Dagger Stacking buff
modifier_true_master_dagger_stacks = class({})
function modifier_true_master_dagger_stacks:IsHidden() return false end
function modifier_true_master_dagger_stacks:IsPurgable() return false end
function modifier_true_master_dagger_stacks:RemoveOnDeath() return false end
function modifier_true_master_dagger_stacks:IsPermanent() return true end
function modifier_true_master_dagger_stacks:GetTexture() return "blood_stacks" end
function modifier_true_master_dagger_stacks:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
end
function modifier_true_master_dagger_stacks:GetModifierBonusStats_Agility()
	if not self:GetAbility() then return end
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("dagger_stack_agi")
end
function modifier_true_master_dagger_stacks:GetModifierBonusStats_Strength()
	if not self:GetAbility() then return end
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("dagger_stack_str")
end
function modifier_true_master_dagger_stacks:GetModifierPreAttack_BonusDamage()
	if not self:GetAbility() then return end
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("dagger_stack_dmg")
end
function modifier_true_master_dagger_stacks:GetModifierMoveSpeedBonus_Constant()
	if not self:GetAbility() then return end
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("dagger_stack_ms")
end
function modifier_true_master_dagger_stacks:GetModifierHealthBonus()
	if not self:GetAbility() then return end
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("dagger_stack_hp")
end



-- Dagger Bleeding initial 
modifier_true_master_dagger_bleed_initial = class({})
function modifier_true_master_dagger_bleed_initial:IsHidden() return true end
function modifier_true_master_dagger_bleed_initial:IsPurgable() return false end
function modifier_true_master_dagger_bleed_initial:GetTexture() return "custom/abilities/mows_bleed" end
function modifier_true_master_dagger_bleed_initial:OnCreated(kv)
	if not IsServer() then return end
	if not self:GetAbility() then return end
	if not self:GetCaster() then return end
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local duration = self:GetAbility():GetSpecialValueFor("dagger_bleed_duration") * (1 + caster:GetStatusResistance())
	if parent and not parent:HasModifier("modifier_true_master_dagger_bleed") then
		parent:AddNewModifier(caster, self:GetAbility(), "modifier_true_master_dagger_bleed", {duration = duration})
	end
end


-- Dagger Bleeding
modifier_true_master_dagger_bleed = class({})
function modifier_true_master_dagger_bleed:IsHidden() return false end
function modifier_true_master_dagger_bleed:IsPurgable() return false end
function modifier_true_master_dagger_bleed:GetTexture() return "custom/abilities/mows_bleed" end
function modifier_true_master_dagger_bleed:OnCreated(kv)
	if not IsServer() then return end
	if not self:GetAbility() then return end
	if not self:GetCaster() then return end
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local stacks = self:GetStackCount()
	print("on created dagger bleed")
	self.stack_expire_times = {}
	self.heal_reduction = 0
	if stacks > 0 then 
		self:StartIntervalThink(1)
	else
		self:StartIntervalThink(-1)	
	end	
end

function modifier_true_master_dagger_bleed:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetAbility() then self:Destroy() return end
	local stacks = self:GetStackCount() or 0
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if caster and parent and parent:IsAlive() and stacks > 1 then
		self.heal_reduction = self:GetAbility():GetSpecialValueFor("dagger_bleed_heal_reduction") 
		local bleed_damage = (caster:GetAttackDamage() * ability:GetSpecialValueFor("dagger_bleed_damage") / 100) * stacks
		bleed_damage = math.floor(bleed_damage + (parent:GetHealth() * 0.01))
		ApplyDamage({
			victim = parent,
			attacker = caster,
			ability = ability,
			damage = bleed_damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR,
		})
		if caster:HasModifier("modifier_super_scepter") then
			local distance = (parent:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
			local dager_ss_range = ability:GetSpecialValueFor("dagger_ss_range")
			if _G._challenge_bosss > 0 then
				dager_ss_range = dager_ss_range * (_G._challenge_bosss + 1)
			end	
			if distance <= dager_ss_range then 
				if caster:HasModifier("modifier_true_master_dagger_stacks") then
					local modifier = caster:FindModifierByName("modifier_true_master_dagger_stacks")
					modifier:SetStackCount(modifier:GetStackCount() + stacks)
				else
					local new_modif = caster:AddNewModifier(caster, ability, "modifier_true_master_dagger_stacks", {})
					new_modif:SetStackCount(stacks)
				end	
			end	
		end	
		self:UpdateStacks()	
	end
end

function modifier_true_master_dagger_bleed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_EVENT_ON_UNIT_MOVED,
	}
end

function modifier_true_master_dagger_bleed:GetModifierHealAmplify_PercentageTarget()
	return -self.heal_reduction * self:GetStackCount()
end

function modifier_true_master_dagger_bleed:OnUnitMoved(keys)
    if not IsServer() then return end
    local parent = self:GetParent()
    if keys.unit == parent and self:GetAbility() and not parent:IsMagicImmune() and not parent:IsInvulnerable() then
        local caster = self:GetCaster()
        if caster and caster:HasModifier("modifier_true_master_dagger") then
            if parent.previoustick then
                local distance = (parent:GetAbsOrigin() - parent.previoustick):Length2D()
                parent.distance_accumulated = (parent.distance_accumulated or 0) + distance
                if parent.distance_accumulated >= 700 and self:GetStackCount() < self:GetAbility():GetSpecialValueFor("dagger_bleed_max_stacks") then
                    self:IncrementStackCount()
                    self:ForceRefresh()
					self:StartIntervalThink(1)
                    parent.distance_accumulated = parent.distance_accumulated - 700
                end
                parent.previoustick = parent:GetAbsOrigin()
            else
                parent.previoustick = parent:GetAbsOrigin()
            end
        end
    end
end



function modifier_true_master_dagger_bleed:OnRefresh(kv)
	if IsServer() then
		local duration = self:GetDuration()
		local current_game_time = GameRules:GetGameTime()
		table.insert(self.stack_expire_times, current_game_time + duration)
	end
end
function modifier_true_master_dagger_bleed:OnDestroy(kv)
	if not IsServer() then return end
	local parent = self:GetParent()
	parent.previoustick = nil
end	

function modifier_true_master_dagger_bleed:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end

function modifier_true_master_dagger_bleed:UpdateStacks()
    if IsServer() then
        local current_game_time = GameRules:GetGameTime()
        for i = #self.stack_expire_times, 1, -1 do
            if self.stack_expire_times[i] <= current_game_time then
                table.remove(self.stack_expire_times, i)
            end
        end
        self:SetStackCount(#self.stack_expire_times)
    end
end


----dagger end ---


---------
-- Gun --
---------
modifier_true_master_gun = class({})
function modifier_true_master_gun:IsHidden() return false end
function modifier_true_master_gun:IsPurgable() return false end
function modifier_true_master_gun:RemoveOnDeath() return false end
function modifier_true_master_gun:OnCreated()
	if not IsServer() then return end
	self.ProjectileSpeed = self:GetParent():GetProjectileSpeed()
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_true_master_gun_reload", {})
	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
	AttachWearable(self:GetParent(), "models/items/pangolier/pangolier_immortal_musket/pangolier_immortal_musket.vmdl", nil)
end
function modifier_true_master_gun:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveModifierByName("modifier_true_master_gun_reload")
	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	RemoveWearables(self:GetParent())
end
function modifier_true_master_gun:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS, MODIFIER_PROPERTY_PROJECTILE_NAME, MODIFIER_PROPERTY_ATTACK_POINT_CONSTANT, MODIFIER_PROPERTY_FIXED_ATTACK_RATE, MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS}
end
function modifier_true_master_gun:GetModifierAttackPointConstant()
	return -0.3
end
function modifier_true_master_gun:GetModifierAttackRangeBonus()
	return 8000
end
function modifier_true_master_gun:GetModifierFixedAttackRate() return self:GetAbility():GetSpecialValueFor("gun_bat") end
function modifier_true_master_gun:GetModifierProjectileSpeedBonus()
	if self:GetParent():IsRangedAttacker() then
		return self.ProjectileSpeed * 2
	end
	return 0
end
function modifier_true_master_gun:OnAttackStart(keys)
	if not IsServer() then return end
	if self:GetParent() == keys.attacker then
		if keys.target == nil then return end
		self:GetParent():EmitSound("Hero_Pangolier.Swashbuckle.Musket")
		self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_1_END)

		self.pierce_proc = false
		if RollPercentage(self:GetAbility():GetSpecialValueFor("dagger_true_strike")) then
			self.pierce_proc = true
		end
	end
end
function modifier_true_master_gun:OnAttackLanded(keys)
	if not IsServer() then return end
	if self:GetParent() == keys.attacker then
		if keys.target == nil then return end
		local instance = 4
		for i = 1, (instance - 1) do
			ApplyDamage({
				victim = keys.target,
				attacker = self:GetCaster(),
				ability = self:GetAbility(),
				damage = keys.original_damage * 2,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			})
		end
	end
end
function modifier_true_master_gun:GetModifierProjectileName()
	return "particles/econ/items/shadow_fiend/sf_desolation/sf_base_attack_desolation_desolator.vpcf"
end
function modifier_true_master_gun:GetActivityTranslationModifiers() return "musket" end
function modifier_true_master_gun:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = false}
	if self.pierce_proc then
		state = {[MODIFIER_STATE_STUNNED] = false, [MODIFIER_STATE_CANNOT_MISS] = true}
	end
	return state
end

-- Gun Reload
modifier_true_master_gun_reload = class({})
function modifier_true_master_gun_reload:IsHidden() return self:GetStackCount() > 0 end
function modifier_true_master_gun_reload:IsDebuff() return true end
function modifier_true_master_gun_reload:IsPurgable() return false end
function modifier_true_master_gun_reload:RemoveOnDeath() return false end
function modifier_true_master_gun_reload:DestroyOnExpire() return false end
function modifier_true_master_gun_reload:OnCreated()
	self:SetStackCount(3)
end
function modifier_true_master_gun_reload:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK}
end
function modifier_true_master_gun_reload:OnAttack(keys)
	if not IsServer() then return end
	if self:GetParent() == keys.attacker then
		if self:GetStackCount() > 0 then
			self:SetStackCount(self:GetStackCount() - 1)
		end
		if self:GetStackCount() == 0 then
			Timers:CreateTimer(1, function()
				if self:GetAbility() then
					self:SetStackCount(3)
				end
			end)
		end
	end
end
function modifier_true_master_gun_reload:CheckState()
	local state = {}
	if self:GetStackCount() == 0 then
		state = {[MODIFIER_STATE_DISARMED] = true}
	else
		state = {[MODIFIER_STATE_DISARMED] = false}
	end
	return state
end



function AttachWearable(unit, modelPath, part)
	local wearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model = modelPath, DefaultAnim = animation, targetname = DoUniqueString("prop_dynamic")})

	wearable:FollowEntity(unit, true)
	
	if part ~= nil then
		local mask1_particle = ParticleManager:CreateParticle(part, PATTACH_ABSORIGIN_FOLLOW, wearable)
		ParticleManager:SetParticleControlEnt(mask1_particle, 0, wearable, PATTACH_POINT_FOLLOW, "attach_part", unit:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(mask1_particle, 1, wearable, PATTACH_POINT_FOLLOW, "attach_part", unit:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(mask1_particle, 2, wearable, PATTACH_POINT_FOLLOW, "attach_part", unit:GetOrigin(), true)
	end
	
	unit.wearables = unit.wearables or {}
	table.insert(unit.wearables, wearable)
	return wearable
end

function RemoveWearables(unit)
	if not unit.wearables or #unit.wearables == 0 then return end
	for _, part in pairs(unit.wearables) do
		part:RemoveSelf()
	end
	unit.wearables = {}
end
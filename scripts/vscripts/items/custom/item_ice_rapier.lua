
-----------------------------------------------------------------------------------------------------------
--	Skadi definition
-----------------------------------------------------------------------------------------------------------

if item_ice_rapier == nil then item_ice_rapier = class({}) end
LinkLuaModifier( "modifier_item_imba_skadi", "items/custom/item_ice_rapier.lua", LUA_MODIFIER_MOTION_NONE )			-- Owner's bonus attributes, stackable
LinkLuaModifier( "modifier_item_imba_skadi_unique", "items/custom/item_ice_rapier.lua", LUA_MODIFIER_MOTION_NONE )	-- On-damage slow applier
LinkLuaModifier( "modifier_item_imba_skadi_slow", "items/custom/item_ice_rapier.lua", LUA_MODIFIER_MOTION_NONE )	-- Slow debuff
LinkLuaModifier( "modifier_item_imba_skadi_freeze", "items/custom/item_ice_rapier.lua", LUA_MODIFIER_MOTION_NONE )	-- Root debuff

function item_ice_rapier:GetIntrinsicModifierName() return "modifier_item_imba_skadi" end
function item_ice_rapier:GetCastRange()
	if IsServer() then
		return
	end
	local caster = self:GetCaster()
	if caster and caster:HasModifier("modifier_item_imba_skadi") then
		return caster:GetModifierStackCount("modifier_item_imba_skadi", caster)
	else
		return 0
	end
end
function item_ice_rapier:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local caster_loc = caster:GetAbsOrigin()
		local radius = self:GetSpecialValueFor("base_radius")
		local duration = self:GetSpecialValueFor("base_duration")
		local damage = self:GetSpecialValueFor("base_damage")
		local hp_damage = self:GetSpecialValueFor("hp_damage") / 100
		local level = caster:GetLevel()

		-- Calculate cast parameters
		if caster:IsHero() then
			radius = radius + caster:GetStrength() * self:GetSpecialValueFor("radius_per_str")
			if radius > 2000 then radius = 2000 end
			duration = duration + caster:GetAgility() * self:GetSpecialValueFor("duration_per_agi")
			if duration > 10 then duration = 10 end
			damage = damage + caster:GetIntellect() * level
		end

		-- Play sound
		--[[if USE_MEME_SOUNDS and RollPercentage(5) then
			caster:EmitSound("Imba.SkadiDeadWinter")
		else
			caster:EmitSound("Imba.SkadiCast")
		end]]

		-- Play particle
		local blast_pfx = ParticleManager:CreateParticle("particles/item/skadi/skadi_ground.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleAlwaysSimulate(blast_pfx)
		ParticleManager:SetParticleControl(blast_pfx, 0, caster_loc)
		ParticleManager:SetParticleControl(blast_pfx, 2, Vector(radius * 1.15, 1, 1))
		ParticleManager:ReleaseParticleIndex(blast_pfx)

		-- Grant flying vision in the target area
		self:CreateVisibilityNode(caster_loc, radius, duration + self:GetSpecialValueFor("vision_extra_duration"))

		-- Find targets in range
		local nearby_enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

		-- Play target sound if at least one enemy was hit
		--if #nearby_enemies > 0 then caster:EmitSound("Imba.SkadiHit") end

		-- Damage and freeze enemies
		for _,enemy in pairs(nearby_enemies) do
			local target_hp = enemy:GetHealth() * hp_damage
			-- Apply damage
			ApplyDamage({attacker = caster, victim = enemy, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
			ApplyDamage({attacker = caster, victim = enemy, ability = self, damage = target_hp, damage_type = DAMAGE_TYPE_MAGICAL})
			-- Apply freeze modifier
			enemy:AddNewModifier(caster, self, "modifier_item_imba_skadi_freeze", {duration = duration})

			-- Apply ministun
			enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = 0.01})
		end
	end
end

-----------------------------------------------------------------------------------------------------------
--	Skadi owner bonus attributes (stackable)
-----------------------------------------------------------------------------------------------------------

if modifier_item_imba_skadi == nil then modifier_item_imba_skadi = class({}) end
function modifier_item_imba_skadi:IsHidden() return true end
function modifier_item_imba_skadi:IsDebuff() return false end
function modifier_item_imba_skadi:IsPurgable() return false end
function modifier_item_imba_skadi:IsPermanent() return true end
--function modifier_item_imba_skadi:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- Adds the unique modifier to the caster when created
function modifier_item_imba_skadi:OnCreated(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local item = self:GetAbility()
		local vLocation = caster:GetAbsOrigin()
	
		-- Ability properties
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()

		-- Ability specials
		self.radius = self:GetAbility():GetSpecialValueFor("base_radius")

		if not self.parent:HasModifier("modifier_item_imba_skadi_unique") then
			self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_imba_skadi_unique", {})
		end

		-- Set stack count
		self:UpdateCastRange()

		-- Cast range update thinker
		self:StartIntervalThink(0.5)
	end
end


function modifier_item_imba_skadi:OnDestroy(keys)
	if IsServer() then
		self.parent = self:GetParent()
		if self.parent:HasModifier("modifier_item_imba_skadi_unique") then
			self.parent:RemoveModifierByName("modifier_item_imba_skadi_unique")
		end
	end
end 
-- Cast range update thinker
function modifier_item_imba_skadi:OnIntervalThink()	
	local item = self:GetAbility()
	local caster = self:GetCaster()
	local vLocation = caster:GetAbsOrigin()
	if not caster:HasModifier("modifier_arc_warden_tempest_double")and caster:IsRealHero() then	
		if 	caster:HasModifier("modifier_fire_rapier_passive_bonus") or
			caster:HasModifier("modifier_wind_rapier_passive_bonus") or
			caster:HasModifier("modifier_earth_rapier_passive_bonus") then

			GameRules:SendCustomMessage("#Game_notification_ice_rapier_request_message1",0,0)			
			Timers:CreateTimer(0.001, function() caster:DropItemAtPositionImmediate(item, vLocation) end)		
		end
	
	end

	self:UpdateCastRange()
	
end

function modifier_item_imba_skadi:UpdateCastRange()
	if IsServer() then
		if self.parent:IsHero() then
			local iradius = self.radius + self.parent:GetStrength() * self.ability:GetSpecialValueFor("radius_per_str")
			
			--local iradius = self.radius + self.parent:GetStrength() * self.ability:GetSpecialValueFor("radius_per_str")
			if iradius > 2000 then iradius = 2000 end
			self:SetStackCount(( iradius))
		end
	end
end

-- Declare modifier events/properties
--[[function modifier_item_imba_skadi:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end]]

--[[function modifier_item_imba_skadi:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("rapier_str") end

function modifier_item_imba_skadi:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("rapier_agi") end

function modifier_item_imba_skadi:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("rapier_int") end
	
function modifier_item_imba_skadi:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("magic_amp")
end]]

function modifier_item_imba_skadi:GetEffectName()
	return "particles/econ/courier/courier_roshan_frost/courier_roshan_frost_ambient.vpcf"
end

function modifier_item_imba_skadi:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
-----------------------------------------------------------------------------------------------------------
--	Skadi slow applier
-----------------------------------------------------------------------------------------------------------

if modifier_item_imba_skadi_unique == nil then modifier_item_imba_skadi_unique = class({}) end
function modifier_item_imba_skadi_unique:IsHidden() return true end
function modifier_item_imba_skadi_unique:IsDebuff() return false end
function modifier_item_imba_skadi_unique:IsPurgable() return false end
function modifier_item_imba_skadi_unique:IsPermanent() return true end
function modifier_item_imba_skadi_unique:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- Changes the caster's attack projectile, if applicable
function modifier_item_imba_skadi_unique:OnCreated(keys)
	if IsServer() then
		--ChangeAttackProjectileImba(self:GetParent())

		-- Store ability KVs for later usage
		--[[local ability = self:GetAbility()
		self.max_duration = ability:GetSpecialValueFor("max_duration")
		self.min_duration = ability:GetSpecialValueFor("min_duration")
		self.slow_range_cap = ability:GetSpecialValueFor("slow_range_cap")
		self.max_distance = ability:GetSpecialValueFor("max_distance")]]
	end
end

-- Changes the caster's attack projectile, if applicable
function modifier_item_imba_skadi_unique:OnDestroy()
	if IsServer() then
		--ChangeAttackProjectileImba(self:GetParent())
	end
end

-- Declare modifier events/properties
function modifier_item_imba_skadi_unique:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		--MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function modifier_item_imba_skadi_unique:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("rapier_str")
	end
	return 0	 
end

function modifier_item_imba_skadi_unique:GetModifierBonusStats_Agility()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("rapier_agi") 
	end
	return 0
end

function modifier_item_imba_skadi_unique:GetModifierBonusStats_Intellect()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("rapier_int")
	end
	return 0		 
end
	
function modifier_item_imba_skadi_unique:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("magic_amp")
	end
	return 0		
end

-- On-damage slow effect
--[[function modifier_item_imba_skadi_unique:OnTakeDamage(keys)
	if IsServer() then
		local attacker = self:GetParent()
		local target = keys.unit
		local target_distance = (target:GetAbsOrigin() - attacker:GetAbsOrigin()):Length2D()
		if attacker ~= keys.attacker then return end
		if attacker:IsIllusion() then return end
		if (not IsHeroOrCreep(target)) or attacker:GetTeam() == target:GetTeam() then
			return
		end
		if target_distance >= self.max_distance then return nil end

		local slow_duration = self.min_duration + (self.max_duration - self.min_duration) * math.max( self.slow_range_cap - target_distance, 0) / self.slow_range_cap

		-- Apply the slow
		target:AddNewModifier(attacker, self:GetAbility(), "modifier_item_imba_skadi_slow", {duration = slow_duration})
	end
end]]

-----------------------------------------------------------------------------------------------------------
--	Skadi slow
-----------------------------------------------------------------------------------------------------------

--[[if modifier_item_imba_skadi_slow == nil then modifier_item_imba_skadi_slow = class({}) end
function modifier_item_imba_skadi_slow:IsHidden() return false end
function modifier_item_imba_skadi_slow:IsDebuff() return true end
function modifier_item_imba_skadi_slow:IsPurgable() return true end

-- Modifier status effect
function modifier_item_imba_skadi_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost_lich.vpcf" end

function modifier_item_imba_skadi_slow:StatusEffectPriority()
	return 10 end

-- Ability KV storage
function modifier_item_imba_skadi_slow:OnCreated(keys)
	self.slow_as = self:GetAbility():GetSpecialValueFor("slow_as")
	self.slow_ms = self:GetAbility():GetSpecialValueFor("slow_ms")
end

-- Declare modifier events/properties
function modifier_item_imba_skadi_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_item_imba_skadi_slow:GetModifierAttackSpeedBonus_Constant()
	return self.slow_as end

function modifier_item_imba_skadi_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow_ms end]]

-----------------------------------------------------------------------------------------------------------
--	Skadi freeze
-----------------------------------------------------------------------------------------------------------

if modifier_item_imba_skadi_freeze == nil then modifier_item_imba_skadi_freeze = class({}) end
function modifier_item_imba_skadi_freeze:IsHidden() return true end
function modifier_item_imba_skadi_freeze:IsDebuff() return true end
function modifier_item_imba_skadi_freeze:IsPurgable() return true end

-- Modifier particle
function modifier_item_imba_skadi_freeze:GetEffectName()
	return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end

function modifier_item_imba_skadi_freeze:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

-- Modifier status effect
function modifier_item_imba_skadi_freeze:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost.vpcf" end

function modifier_item_imba_skadi_freeze:StatusEffectPriority()
	return 11 end

-- Declare modifier states
function modifier_item_imba_skadi_freeze:CheckState()
	local states = {
		[MODIFIER_STATE_ROOTED] = true,
	}
	return states
end

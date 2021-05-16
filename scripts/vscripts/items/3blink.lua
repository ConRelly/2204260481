if item_3blink == nil then item_3blink = class({}) end
LinkLuaModifier( "modifier_item_3blink", "items/3blink.lua", LUA_MODIFIER_MOTION_NONE )
function item_3blink:GetCastRange(location, target)
	if IsClient() then
		local max_blink_range = self:GetSpecialValueFor("max_blink_range")

		--UP: Aghanim's Shard
		if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then max_blink_range = (max_blink_range + 800) end
		---------------------

		return max_blink_range - self:GetCaster():GetCastRangeBonus()
	end
end
function item_3blink:GetAOERadius() return 800 end
function item_3blink:OnSpellStart()
	if self:GetCursorTarget() or self:GetCursorTarget() == self:GetCaster() then self:EndCooldown() return end
	movement_slow = self:GetSpecialValueFor("movement_slow")
	attack_slow = self:GetSpecialValueFor("attack_slow")
	dmg = self:GetSpecialValueFor("dmg")
	radius = self:GetSpecialValueFor("radius")
	base_cooldown = self:GetSpecialValueFor("base_cooldown")
	cast_pct_improvement = self:GetSpecialValueFor("cast_pct_improvement")
	bonus_attack_damage = self:GetSpecialValueFor("bonus_attack_damage")
	bonus_attack_speed = self:GetSpecialValueFor("bonus_attack_speed")
	bonus_movement = self:GetSpecialValueFor("bonus_movement")
	self.duration = self:GetSpecialValueFor("duration")
	self.blast_multiplier = self:GetSpecialValueFor("blast_multiplier")
	targetflag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	caster = self:GetCaster()
	origin_point = caster:GetAbsOrigin()
	target_point = self:GetCursorPosition()
	distance = (target_point - origin_point):Length2D()
	max_blink_range = self:GetSpecialValueFor("max_blink_range")
	EmitSoundOnLocationWithCaster(target_point, "DOTA_Item.BlinkDagger.Activate", caster)
	self:GetCaster():EmitSound("Blink_Layer.Arcane")
	self:GetCaster():EmitSound("Blink_Layer.Swift")
	EmitSoundOnLocationWithCaster(target_point, "Blink_Layer.Overwhelming", caster)

	--UP: Aghanim's Shard
	if caster:HasModifier("modifier_item_aghanims_shard") then max_blink_range = (max_blink_range + 800) end
	---------------------

	if distance > max_blink_range then
		local max_extra_distance = self:GetSpecialValueFor("max_extra_distance")

		--UP: Aghanim's Shard + Aghanim's Scepter
		if caster:HasModifier("modifier_item_aghanims_shard") and caster:HasScepter() then max_extra_distance = (max_extra_distance + 800) end
		-----------------------------------------

		if distance > max_extra_distance then target_point = origin_point + (target_point - origin_point):Normalized() * max_extra_distance end
	end
	ProjectileManager:ProjectileDodge(caster)
	ParticleManager:CreateParticle("particles/custom/items/3blink/3blink_start.vpcf", PATTACH_ABSORIGIN, caster)
	caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
    caster:SetAbsOrigin(target_point)
    FindClearSpaceForUnit(caster, target_point, false)
	
    local end_3blink = ParticleManager:CreateParticle("particles/custom/items/3blink/3blink_end.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(end_3blink, 0, self:GetCaster():GetOrigin())
	ParticleManager:ReleaseParticleIndex(end_3blink)
	
    local burst = ParticleManager:CreateParticle("particles/items3_fx/blink_overwhelming_burst.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(burst, 0, self:GetParent():GetOrigin())
	ParticleManager:SetParticleControl(burst, 1, Vector(radius, 500, 500 ))
	ParticleManager:ReleaseParticleIndex(burst)

	caster:AddNewModifier(caster, self, "modifier_item_arcane_blink_buff", {duration = self.duration})
	caster:AddNewModifier(caster, self, "modifier_item_swift_blink_buff", {duration = self.duration})

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target_point, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, FIND_ANY_ORDER, false)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_item_overwhelming_blink_debuff", {duration = self.duration * (1 - enemy:GetStatusResistance())})
		ApplyDamage({
			victim 			= enemy,
			damage 			= caster:GetPrimaryStatValue() * self.blast_multiplier + dmg,
			damage_type		= DAMAGE_TYPE_MAGICAL,
			damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			attacker 		= caster,
			ability 		= self
		})
	end
end
function item_3blink:GetIntrinsicModifierName() return "modifier_item_3blink" end

if modifier_item_3blink == nil then modifier_item_3blink = class({}) end
function modifier_item_3blink:IsHidden() return true end
function modifier_item_3blink:IsPurgable() return false end
function modifier_item_3blink:RemoveOnDeath() return false end
function modifier_item_3blink:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_3blink:DeclareFunctions() return { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, } end
function modifier_item_3blink:GetModifierBonusStats_Strength() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end end
function modifier_item_3blink:GetModifierBonusStats_Agility() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end end
function modifier_item_3blink:GetModifierBonusStats_Intellect() if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("all") end end

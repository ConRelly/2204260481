--LinkLuaModifier("modifier_mjz_windrunner_powershot_debuff", "abilities/hero_windrunner/mjz_windrunner_powershot.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_powershot_passive", "abilities/hero_windrunner/mjz_windrunner_powershot", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_powershot_max_charge", "abilities/hero_windrunner/mjz_windrunner_powershot", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_powershot_shard", "abilities/hero_windrunner/mjz_windrunner_powershot", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_wr_shackleshot_immortal_falcon_bow", "abilities/hero_windrunner/mjz_windrunner_powershot", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_traxexs_necklace_frozen", "items/traxexs_necklace", LUA_MODIFIER_MOTION_NONE)


mjz_windrunner_powershot = class({})
function mjz_windrunner_powershot:GetIntrinsicModifierName()
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_wr_shackleshot_immortal_falcon_bow") and FindWearables(self:GetCaster(), "models/items/windrunner/ti6_falcon_bow/ti6_falcon_bow_model.vmdl") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_wr_shackleshot_immortal_falcon_bow", {})
		end
    end
	return "modifier_powershot_passive"
end
function mjz_windrunner_powershot:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_wr_shackleshot_immortal_falcon_bow") then
        return "windrunner/peregrine_flight/windrunner_powershot"
    else
		return "windrunner_powershot"
	end
end

function mjz_windrunner_powershot:GetChannelAnimation() return ACT_DOTA_CAST_ABILITY_2 end
function mjz_windrunner_powershot:GetChannelTime()
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		return self:GetSpecialValueFor("channel_time") / 2
	else
		return self:GetSpecialValueFor("channel_time")
	end
end

function mjz_windrunner_powershot:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local pos = self:GetCursorPosition()
		local direction = CalculateDirection(pos, caster:GetAbsOrigin())
		caster:FindModifierByName("modifier_powershot_passive"):SetStackCount(0)
		self.damage = 0

		EmitSoundOn("Ability.PowershotPull", caster)
		self.nfx = ParticleManager:CreateParticle("particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_channel_ti6.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControlEnt(self.nfx, 0, caster, PATTACH_POINT_FOLLOW, "bow_mid1", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.nfx, 1, caster:GetAbsOrigin())
		ParticleManager:SetParticleControlForward(self.nfx, 1, direction)
	end
end

function mjz_windrunner_powershot:OnChannelFinish(bInterrupted)
	if IsServer() then
		local caster = self:GetCaster()

		local attack_damage = caster:GetAverageTrueAttackDamage(caster) * (self:GetSpecialValueFor("attack_damage") + talent_value(caster, "special_bonus_unique_mjz_windrunner_powershot_damage")) / 100
		local channel_pct = (GameRules:GetGameTime() - self:GetChannelStartTime()) / self:GetChannelTime()
		self.damage = attack_damage * channel_pct

		ParticleManager:DestroyParticle(self.nfx, false)
		ParticleManager:ReleaseParticleIndex(self.nfx)

		StopSoundOn("Ability.PowershotPull", caster)
		EmitSoundOn("Ability.Powershot", caster)

		caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)

		local distance = self:GetSpecialValueFor("arrow_range") + caster:GetCastRangeBonus()
		self:FirePowerShot(caster, self, "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf", caster:GetForwardVector() * self:GetSpecialValueFor("arrow_speed"), distance, self:GetSpecialValueFor("arrow_width"), {}, false, true, self:GetSpecialValueFor("vision_radius"), self.damage)
		if not bInterrupted and caster:HasModifier("modifier_super_scepter") then
			if caster:HasModifier("modifier_powershot_max_charge") then
				caster:RemoveModifierByName("modifier_powershot_max_charge")
			end
			caster:AddNewModifier(caster, self, "modifier_powershot_max_charge", {duration = self:GetSpecialValueFor("debuff_duration")})
		end

		if caster:GetUnitName() == "npc_dota_hero_windrunner" and caster:HasModifier("modifier_traxexs_necklace") then
			local info = {
				Ability = self,
				EffectName = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_spell_powershot.vpcf",
				vSpawnOrigin = caster:GetAbsOrigin(),
				fStartRadius = self:GetSpecialValueFor("arrow_width") / 2,
				fEndRadius = self:GetSpecialValueFor("arrow_width") / 2,
				vVelocity = caster:GetForwardVector() * self:GetSpecialValueFor("arrow_speed") * 2,
				fDistance = distance,
				Source = caster,
				iUnitTargetTeam = self:GetAbilityTargetTeam(),
				iUnitTargetType = self:GetAbilityTargetType(),
				iUnitTargetFlags = self:GetAbilityTargetFlags(),
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				bDeleteOnHit = false,
				fExpireTime = GameRules:GetGameTime() + 10.0,
				bProvidesVision = true,
				iVisionRadius = self:GetSpecialValueFor("vision_radius"),
				iVisionTeamNumber = caster:GetTeamNumber(),
				ExtraData = {damage = 0, caster = caster, shatter = true}
			}
			Timers:CreateTimer(0.5, function()
				ProjectileManager:CreateLinearProjectile(info)
			end)
		end
	end
end

function mjz_windrunner_powershot:FirePowerShot(caster, ability, FX, velocity, distance, width, data, bDelete, bVision, vision, damage)
	local internalData = {}
	if data then internalData = data end
	local delete = false
	if bDelete then delete = bDelete end
	local provideVision = true
	if bVision then provideVision = bVision end
	local info = {
		EffectName = FX,
		Ability = ability,
		vSpawnOrigin = internalData.origin or caster:GetAbsOrigin(), 
		fStartRadius = width,
		fEndRadius = internalData.width_end or width,
		vVelocity = velocity,
		fDistance = distance or 1000,
		Source = internalData.source or caster,
		iUnitTargetTeam = internalData.team or ability:GetAbilityTargetTeam(),
		iUnitTargetType = internalData.type or ability:GetAbilityTargetType(),
		iUnitTargetFlags = internalData.type or ability:GetAbilityTargetFlags(),
		iSourceAttachment = internalData.attach or DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		bDeleteOnHit = delete,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bProvidesVision = provideVision,
		iVisionRadius = vision or 100,
		iVisionTeamNumber = caster:GetTeamNumber(),
		ExtraData = {damage = damage, caster = caster}
	}
	local projectile = ProjectileManager:CreateLinearProjectile(info)
	return projectile
end

function mjz_windrunner_powershot:OnProjectileThink_ExtraData(loc, ExtraData)
	if not IsServer() then return end
	GridNav:DestroyTreesAroundPoint(loc, self:GetSpecialValueFor("tree_width"), true)
end

function mjz_windrunner_powershot:OnProjectileHit_ExtraData(target, loc, ExtraData)
	if not IsServer() then return end
	local caster = ExtraData.caster or self:GetCaster()

	if target then
		local hits_counter = caster:FindModifierByName("modifier_powershot_passive")
		local hits = hits_counter:GetStackCount()
		EmitSoundOn("Ability.PowershotDamage", target)

		if caster:HasModifier("modifier_item_aghanims_shard") then
			target:AddNewModifier(caster, self, "modifier_powershot_shard", {duration = self:GetSpecialValueFor("debuff_duration")})
		end
--[[ 		if not target:HasModifier("modifier_mjz_faceless_the_world_aura_effect_enemy") then
			target:AddNewModifier(caster, self, "modifier_mjz_windrunner_powershot_debuff", {duration = self:GetSpecialValueFor("debuff_inco_duration")})
		end ]]

		local damage = (ExtraData.damage or self.damage) + hits * self:GetSpecialValueFor("damage_increase") / 100
		ApplyDamage({victim = target, attacker = caster, ability = self, damage_type = self:GetAbilityDamageType(), damage = damage, damage_flags = DOTA_DAMAGE_FLAG_NONE})

		SendOverheadEventMessage(caster:GetPlayerOwner(), OVERHEAD_ALERT_DAMAGE, target, damage, caster:GetPlayerOwner())

		hits_counter:SetStackCount(hits + 1)

		if caster:GetUnitName() == "npc_dota_hero_windrunner" and caster:HasModifier("modifier_traxexs_necklace") then
			if target:HasModifier("modifier_traxexs_necklace_frozen") and ExtraData.shatter then
				local frozen = target:FindModifierByName("modifier_traxexs_necklace_frozen")
				frozen:SetStackCount(1)
				frozen:Destroy()
			end
		end
	else
		AddFOWViewer(caster:GetTeam(), loc, self:GetSpecialValueFor("vision_radius"), self:GetSpecialValueFor("vision_duration"), true)
	end
end

-------------removed , incoming dmg amp brackes last wave balance and future implementations--------------------------

--[[ modifier_mjz_windrunner_powershot_debuff = class({})
function modifier_mjz_windrunner_powershot_debuff:IsHidden() return false end
function modifier_mjz_windrunner_powershot_debuff:IsPurgable() return false end
function modifier_mjz_windrunner_powershot_debuff:DeclareFunctions() 
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} 
end
function modifier_mjz_windrunner_powershot_debuff:GetModifierIncomingDamage_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("debuff_incoming_damage") end
end
 ]]
---------------------------------------------------------------------------------------

modifier_powershot_shard = class({})
function modifier_powershot_shard:IsHidden() return false end
function modifier_powershot_shard:IsPurgable() return false end
function modifier_powershot_shard:OnCreated()
	if not IsServer() then return end
	local stack_duration = self:GetAbility():GetSpecialValueFor("debuff_duration")
	self:SetStackCount(self:GetStackCount() + 1)
	self:SetDuration(stack_duration, true)
	Timers:CreateTimer(stack_duration, function()
		if self ~= nil and not self:IsNull() and not self:GetAbility():IsNull() and not self:GetParent():IsNull() and not self:GetCaster():IsNull() and self:GetStackCount() > 0 then
			self:SetStackCount(self:GetStackCount() - 1)
		end
	end)
end
function modifier_powershot_shard:OnRefresh()
	self:OnCreated()
end
function modifier_powershot_shard:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function modifier_powershot_shard:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("shard_armor") * self:GetStackCount() * (-1) end
end

---------------------------------------------------------------------------------------

modifier_powershot_max_charge = class({})
function modifier_powershot_max_charge:IsHidden() return false end
function modifier_powershot_max_charge:IsPurgable() return false end
function modifier_powershot_max_charge:GetEffectName() return "particles/custom/abilities/heroes/mjz_windrunner_powershot/powershot_full_charged.vpcf" end
function modifier_powershot_max_charge:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_powershot_max_charge:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_powershot_max_charge:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end

function modifier_powershot_max_charge:GetModifierOverrideAbilitySpecial(params)
	if self:GetParent() == nil or params.ability == nil then return 0 end

	if params.ability:GetAbilityName() == "mjz_windrunner_powershot" and params.ability_special_value == "shot_chance" then return 1 end
	if params.ability:GetAbilityName() == "mjz_windrunner_powershot" and params.ability_special_value == "attack_damage" then return 1 end

	return 0
end

function modifier_powershot_max_charge:GetModifierOverrideAbilitySpecialValue(params)
	if params.ability:GetAbilityName() == "mjz_windrunner_powershot" and params.ability_special_value == "shot_chance" then
		local SpecialLevel = params.ability_special_level
		return self:GetParent():FindAbilityByName("mjz_windrunner_powershot"):GetLevelSpecialValueNoOverride("shot_chance", SpecialLevel) * 5
	end
	if params.ability:GetAbilityName() == "mjz_windrunner_powershot" and params.ability_special_value == "attack_damage" then
		local SpecialLevel = params.ability_special_level
		return self:GetParent():FindAbilityByName("mjz_windrunner_powershot"):GetLevelSpecialValueNoOverride("attack_damage", SpecialLevel) + 1000
	end

	return 0
end

modifier_powershot_max_charge_attack = class({})
function modifier_powershot_max_charge_attack:IsHidden() return false end
function modifier_powershot_max_charge_attack:IsPurgable() return false end

modifier_powershot_max_charge_chance = class({})
function modifier_powershot_max_charge_chance:IsHidden() return false end
function modifier_powershot_max_charge_chance:IsPurgable() return false end

-----------------------------------------------------------------------------------------

modifier_powershot_passive = class({})
function modifier_powershot_passive:IsHidden() return true end
function modifier_powershot_passive:IsPurgable() return false end
function modifier_powershot_passive:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_powershot_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_powershot_passive:OnAttackLanded(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local target = keys.target
		local shot_chance = self:GetAbility():GetSpecialValueFor("shot_chance")

		if caster ~= keys.attacker then return end
		if caster:IsIllusion() then return end
		if RollPercentage(shot_chance) then
			self:SetStackCount(0)
			EmitSoundOn("Ability.Powershot", caster)
			local distance = self:GetAbility():GetSpecialValueFor("arrow_range") + caster:GetCastRangeBonus()
			if caster:HasModifier("modifier_super_scepter") then
				mjz_windrunner_powershot.damage = caster:GetAverageTrueAttackDamage(caster) * (self:GetAbility():GetSpecialValueFor("attack_damage") + talent_value(caster, "special_bonus_unique_mjz_windrunner_powershot_damage")) / 100
			else
				mjz_windrunner_powershot.damage = caster:GetAverageTrueAttackDamage(caster) * (self:GetAbility():GetSpecialValueFor("attack_damage") + talent_value(caster, "special_bonus_unique_mjz_windrunner_powershot_damage")) / 100 * (RandomInt(1, 100) / 100)
			end

			mjz_windrunner_powershot:FirePowerShot(caster, self:GetAbility(), "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf", (keys.target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * self:GetSpecialValueFor("arrow_speed") * Vector(1, 1, 0), distance, self:GetAbility():GetSpecialValueFor("arrow_width"), {}, false, true, self:GetAbility():GetSpecialValueFor("vision_radius"), mjz_windrunner_powershot.damage)
		end
	end
end


modifier_wr_shackleshot_immortal_falcon_bow = class({})
function modifier_wr_shackleshot_immortal_falcon_bow:IsHidden() return true end
function modifier_wr_shackleshot_immortal_falcon_bow:IsPurgable() return false end
function modifier_wr_shackleshot_immortal_falcon_bow:RemoveOnDeath() return false end

-----------------------------------------------------------------------------------------

function CalculateDirection(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local direction = (pos1 - pos2):Normalized()
	direction.z = 0
	return direction
end


function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
    end
    return base
end
LinkLuaModifier("modifier_wr_shackleshot_stun", "heroes/hero_windranger/shackleshot", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_wr_shackleshot_immortal_vedette", "heroes/hero_windranger/shackleshot", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_traxexs_necklace_frozen", "items/traxexs_necklace", LUA_MODIFIER_MOTION_NONE)

-----------------
-- Shackleshot --
-----------------
wr_shackleshot = class({})

function wr_shackleshot:GetIntrinsicModifierName()
	if IsServer() then
		if not self:GetCaster():HasModifier("modifier_wr_shackleshot_immortal_vedette") and FindWearables(self:GetCaster(), "models/items/windrunner/windranger_ti8_immortal_shoulders/windranger_ti8_immortal_shoulders.vmdl") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_wr_shackleshot_immortal_vedette", {})
		end
    end
	return
end

function wr_shackleshot:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_wr_shackleshot_immortal_vedette") then
        return "windrunner_shackleshot_ti8immortal"
    end
    return "windrunner_shackleshot"
end

function wr_shackleshot:OnSpellStart()
	local target = self:GetCursorTarget()

	self:GetCaster().basic_stun_modifier = "modifier_wr_shackleshot_stun"
	if self:GetCaster():GetUnitName() == "npc_dota_hero_windrunner" and self:GetCaster():HasModifier("modifier_traxexs_necklace") then
		self:GetCaster().basic_stun_modifier = "modifier_traxexs_necklace_frozen"
	end
	self:GetCaster():EmitSound("Hero_Windrunner.ShackleshotCast")

	ProjectileManager:CreateTrackingProjectile({
		Target		= target,
		Source		= self:GetCaster(),
		Ability		= self,	
		
		EffectName	= "particles/units/heroes/hero_windrunner/windrunner_shackleshot.vpcf",
		iMoveSpeed	= self:GetSpecialValueFor("shackle_speed"),
		bDodgeable	= true,

		ExtraData	= {
			location_x = self:GetCaster():GetAbsOrigin().x,
			location_y = self:GetCaster():GetAbsOrigin().y,
			location_z = self:GetCaster():GetAbsOrigin().z,
		}
	})
end

function wr_shackleshot:SearchForShackleTarget(target, target_angle, ignore_list, target_count)
	local stun_duration = self:GetTalentSpecialValueFor("stun_duration")
	local shackleTarget = nil

	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("shackle_distance"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
	
	for _, enemy in pairs(enemies) do
		if enemy ~= target and not ignore_list[enemy] and math.abs(AngleDiff(target_angle, VectorToAngles(enemy:GetAbsOrigin() - target:GetAbsOrigin()).y)) <= self:GetSpecialValueFor("shackle_angle") then
			shackleTarget = enemy
			
			target:EmitSound("Hero_Windrunner.ShackleshotBind")
			enemy:EmitSound("Hero_Windrunner.ShackleshotBind")
			
			local shackleshot_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_shackleshot_pair.vpcf", PATTACH_POINT_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(shackleshot_particle, 1, enemy, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(shackleshot_particle, 2, Vector(stun_duration, 0, 0))
			
			if target.AddNewModifier then
				local target_modifier = target:AddNewModifier(self:GetCaster(), self, self:GetCaster().basic_stun_modifier, {duration = stun_duration * (1 - target:GetStatusResistance())})
				
				if target_modifier then
					target_modifier:AddParticle(shackleshot_particle, false, false, -1, false, false)
				end
			end
			
			if enemy.AddNewModifier then
				enemy:AddNewModifier(self:GetCaster(), self, self:GetCaster().basic_stun_modifier, {duration = stun_duration * (1 - enemy:GetStatusResistance())})
			end
			
			break
		end
	end

	if not shackleTarget then
		local trees = GridNav:GetAllTreesAroundPoint(target:GetAbsOrigin(), self:GetSpecialValueFor("shackle_distance"), false)
		
		for _, tree in pairs(trees) do
			if not ignore_list[enemy] and math.abs(AngleDiff(target_angle, VectorToAngles(tree:GetAbsOrigin() - target:GetAbsOrigin()).y)) <= self:GetSpecialValueFor("shackle_angle") then
				shackleTarget = tree
				
				if target.AddNewModifier then
					local shackleshot_tree_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_shackleshot_pair.vpcf", PATTACH_POINT_FOLLOW, target)
					ParticleManager:SetParticleControl(shackleshot_tree_particle, 1, (tree:GetAbsOrigin() + Vector(0, 0, 150)))
					ParticleManager:SetParticleControl(shackleshot_tree_particle, 2, Vector(stun_duration, 0, 0))

					local target_modifier = target:AddNewModifier(self:GetCaster(), self, self:GetCaster().basic_stun_modifier, {tree = tree, duration = stun_duration * (1 - target:GetStatusResistance())})

					Timers:CreateTimer(stun_duration, function()
						if tree ~= nil then
							GridNav:DestroyTreesAroundPoint(tree:GetAbsOrigin(), 10, false)
						end
					end)
					
					if target_modifier then
						target_modifier:AddParticle(shackleshot_tree_particle, false, false, -1, false, false)
					end
				end
				break
			end
		end
	end
	
	if not shackleTarget then
		local shackleshot_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_shackleshot_single.vpcf", PATTACH_ABSORIGIN, target)
		ParticleManager:ReleaseParticleIndex(shackleshot_particle)
	end
	
	return shackleTarget
end

function wr_shackleshot:OnProjectileHit_ExtraData(target, location, ExtraData)
	if not target or (target.IsMagicImmune and target:IsMagicImmune()) or (target.TriggerSpellAbsorb and target:TriggerSpellAbsorb(self)) then return end

	local shackled_targets	= {}
	
	target:EmitSound("Hero_Windrunner.ShackleshotStun")

	local next_target = target

	for i = 1, self:GetSpecialValueFor("shackle_count") do
		if next_target then
			next_target = self:SearchForShackleTarget(next_target, VectorToAngles(next_target:GetAbsOrigin() - Vector(ExtraData.location_x, ExtraData.location_y, ExtraData.location_z)).y, shackled_targets, i)
			
			if next_target then
				shackled_targets[next_target] = true
			elseif i == 1 then
				local stun_modifier = target:AddNewModifier(self:GetCaster(), self, self:GetCaster().basic_stun_modifier, {duration = self:GetSpecialValueFor("fail_stun_duration") * (1 - target:GetStatusResistance())})
				
				if stun_modifier then
					local shackleshot_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_shackleshot_single.vpcf", PATTACH_ABSORIGIN, target)
					ParticleManager:SetParticleControlForward(shackleshot_particle, 2, Vector(ExtraData.location_x, ExtraData.location_y, ExtraData.location_z):Normalized())
					stun_modifier:AddParticle(shackleshot_particle, false, false, -1, false, false)
				end
			end
		else
			break
		end
	end
end

-------------------------------
-- Shackleshot Stun Modifier --
-------------------------------
modifier_wr_shackleshot_stun = class({})
function modifier_wr_shackleshot_stun:IsDebuff() return true end
function modifier_wr_shackleshot_stun:IsPurgeException() return true end
function modifier_wr_shackleshot_stun:IsStunDebuff() return true end
function modifier_wr_shackleshot_stun:GetEffectName() return "particles/generic_gameplay/generic_stunned.vpcf" end
function modifier_wr_shackleshot_stun:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_wr_shackleshot_stun:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

function modifier_wr_shackleshot_stun:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_wr_shackleshot_stun:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end


modifier_wr_shackleshot_immortal_vedette = class({})
function modifier_wr_shackleshot_immortal_vedette:IsHidden() return true end
function modifier_wr_shackleshot_immortal_vedette:IsPurgable() return false end
function modifier_wr_shackleshot_immortal_vedette:RemoveOnDeath() return false end

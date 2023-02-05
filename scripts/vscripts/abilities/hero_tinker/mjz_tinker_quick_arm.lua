LinkLuaModifier( "modifier_quick_arm_scepter", "abilities/hero_tinker/mjz_tinker_quick_arm", LUA_MODIFIER_MOTION_NONE )

mjz_tinker_quick_arm = mjz_tinker_quick_arm or class({})
--function mjz_tinker_quick_arm:IsRefreshable() return false end
function mjz_tinker_quick_arm:GetChannelTime()
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		return 0
	else
		return self:GetSpecialValueFor("channel_time") - talent_value(self:GetCaster(), "special_bonus_unique_mjz_tinker_quick_arm_channel_time")
	end
end
function mjz_tinker_quick_arm:GetBehavior()
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_CHANNELLED
end
function mjz_tinker_quick_arm:IsStealable() return false end
function mjz_tinker_quick_arm:OnUpgrade()
	if self:GetCaster():HasAbility("tinker_keen_teleport") then
		self:GetCaster():FindAbilityByName("tinker_keen_teleport"):SetLevel(self:GetLevel())
	end
end
function mjz_tinker_quick_arm:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		self.cdr = self:GetSpecialValueFor("cooldown_reduction") - talent_value(self:GetCaster(), "special_bonus_unique_mjz_tinker_quick_arm_cdr")
		caster:EmitSound("Hero_Tinker.Rearm")

		if not caster:HasModifier("modifier_super_scepter") then
			self.fx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_rearm.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(self.fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack3", caster:GetOrigin(), true)
		else
			caster:AddNewModifier(caster, self, "modifier_quick_arm_scepter", {duration = self:GetSpecialValueFor("channel_time") - talent_value(self:GetCaster(), "special_bonus_unique_mjz_tinker_quick_arm_channel_time")})
		end
	end
end

function mjz_tinker_quick_arm:GetChannelAnimation()
	if self:GetLevel() == 1 then
		return ACT_DOTA_TINKER_REARM1
	elseif self:GetLevel() == 2 then
		return ACT_DOTA_TINKER_REARM2
	elseif self:GetLevel() == 3 then
		return ACT_DOTA_TINKER_REARM3
	end
end

function mjz_tinker_quick_arm:OnChannelFinish(interrupted)
	if IsServer() then
		local caster = self:GetCaster()

		if self.fx then
			ParticleManager:DestroyParticle(self.fx, false)
			ParticleManager:ReleaseParticleIndex(self.fx)
		end

		if not interrupted then
			self:HalveCooldowns(caster)
		end
	end
end


function mjz_tinker_quick_arm:HalveCooldowns(caster)

	local exclude_abilities = {
	}
		
	local exclude_items = {
		item_god_slayer = true,
		item_custom_refresher = true,
		item_custom_ex_machina = true,
		item_echo_wand = true,
		item_pipe_of_dezun = true,
		item_resurection_pendant = true,
		item_inf_aegis = true,
	}
	if not caster or caster:IsNull() then
		return
	end

    for i = 0, caster:GetAbilityCount() -1 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and IsValidEntity(ability) then
			self:halve_ability_cooldown(ability, exclude_abilities)
		end
    end

	for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
        local item = caster:GetItemInSlot(i)
        self:halve_ability_cooldown(item, exclude_items)
    end
	local tp_slot = caster:GetItemInSlot(15)
	local tp_slot_cd = tp_slot:GetCooldownTimeRemaining()
	tp_slot:EndCooldown()
	tp_slot:StartCooldown(tp_slot_cd * self.cdr / 100)
end

function mjz_tinker_quick_arm:halve_ability_cooldown(ability, exclude_table)
    if ability then
        if not exclude_table[ability:GetAbilityName()] then
			if ability:GetCooldownTimeRemaining() > 0 then
				local flCooldown = ability:GetCooldownTimeRemaining() * self.cdr / 100
				
				ability:EndCooldown()
				
				if flCooldown > 1.0 then
					ability:StartCooldown(flCooldown)
				end
            end
        end
    end
end


modifier_quick_arm_scepter = class({})
function modifier_quick_arm_scepter:IsHidden() return false end
--function modifier_quick_arm_scepter:IsDebuff() return true end
function modifier_quick_arm_scepter:IsPurgable() return true end
function modifier_quick_arm_scepter:RemoveOnDeath() return false end
function modifier_quick_arm_scepter:OnDestroy()
	if IsServer() then
		if self:GetAbility() then
			self:GetAbility():HalveCooldowns(self:GetCaster())
		end
	end	
end

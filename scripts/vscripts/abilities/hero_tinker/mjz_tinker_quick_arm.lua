
mjz_tinker_quick_arm = mjz_tinker_quick_arm or class({})


mjz_tinker_quick_arm._exclude_abilities = {

}

mjz_tinker_quick_arm._exclude_items = {

}

function mjz_tinker_quick_arm:IsStealable()
	return false
end

function mjz_tinker_quick_arm:OnSpellStart( )
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self
		local particle = "particles/units/heroes/hero_tinker/tinker_rearm.vpcf"
		local sound = "Hero_Tinker.Rearm"

		caster:EmitSound(sound)
		self.fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(self.fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack3", caster:GetOrigin(), true)

	end
end

function mjz_tinker_quick_arm:GetChannelAnimation()
    return ACT_DOTA_TINKER_REARM1
end


function mjz_tinker_quick_arm:OnChannelFinish(interrupted)
	if IsServer() then
		local caster = self:GetCaster()

		ParticleManager:DestroyParticle(self.fx, false)
		ParticleManager:ReleaseParticleIndex(self.fx)
		self.fx = nil

		caster:StopSound(sound)

		if not interrupted then
			self:HalveCooldowns()
		end
	end
end


function mjz_tinker_quick_arm:HalveCooldowns()
    local caster = self:GetCaster()

    self:halve_abilities(caster, self._exclude_abilities)
    self:halve_items(caster, self._exclude_items)
end

function mjz_tinker_quick_arm:halve_abilities(caster, exclude_abilities)
    for i = 0, caster:GetAbilityCount() -1 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and IsValidEntity(ability) then
			self:halve_ability_cooldown(ability, exclude_abilities)
		end
    end
end

function mjz_tinker_quick_arm:halve_items(caster, exclude_items)
	for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
        local item = caster:GetItemInSlot(i)
        self:halve_ability_cooldown(item, exclude_items)
    end
end

function mjz_tinker_quick_arm:halve_ability_cooldown(ability, exclude_table)
    if ability then
        if not exclude_table[ability:GetAbilityName()] then
			if ability:GetCooldownTimeRemaining() > 0 then
				local flCooldown = ability:GetCooldownTimeRemaining() / 2
				
				ability:EndCooldown()
				
				if flCooldown > 1.0 then
					ability:StartCooldown(flCooldown)
				end
            end
        end
    end
end


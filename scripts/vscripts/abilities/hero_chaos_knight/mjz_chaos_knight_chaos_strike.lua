mjz_chaos_knight_chaos_strike = class({})
LinkLuaModifier("modifier_mjz_chaos_knight_chaos_strike", "abilities/hero_chaos_knight/mjz_chaos_knight_chaos_strike", LUA_MODIFIER_MOTION_NONE)

function mjz_chaos_knight_chaos_strike:GetIntrinsicModifierName() return "modifier_mjz_chaos_knight_chaos_strike" end

modifier_mjz_chaos_knight_chaos_strike = class({})
function modifier_mjz_chaos_knight_chaos_strike:IsHidden() return true end
function modifier_mjz_chaos_knight_chaos_strike:IsPurgable() return false end
function modifier_mjz_chaos_knight_chaos_strike:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self.IsCrit = false
		self.shard_crit = false
	end
end
function modifier_mjz_chaos_knight_chaos_strike:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function modifier_mjz_chaos_knight_chaos_strike:GetModifierPreAttack_CriticalStrike(params)
	if IsServer() and (not self:GetParent():PassivesDisabled()) then
		local chance = self:GetAbility():GetSpecialValueFor("crit_chance")
		chance = chance + self:GetParent():FindTalentValue("special_bonus_unique_mjz_chaos_strike")
		if RollPseudoRandom(chance, self:GetAbility()) then
			self.IsCrit = true
			if self:GetCaster():HasShard() then self.shard_crit = true end
			return self:GetAbility():GetSpecialValueFor("crit_damage")
		end
	end
end
function modifier_mjz_chaos_knight_chaos_strike:OnAttackLanded(params)
	if IsServer() then
		local lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal")
		if self:GetCaster() == params.attacker then
			if params.target ~= nil and self.IsCrit then
				local heal = params.damage * lifesteal / 100
				self:GetParent():Heal(heal, self:GetAbility())
				local effect_cast = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:ReleaseParticleIndex(effect_cast)
				EmitSoundOn("Hero_ChaosKnight.ChaosStrike", self:GetParent())
				self.IsCrit = false
			end
		end

		local chaos_bolt = self:GetCaster():FindAbilityByName("mjz_chaos_knight_chaos_bolt")
		if chaos_bolt then
			if self:GetCaster() == params.attacker and not self:GetCaster():IsIllusion() then
				if params.target ~= nil and self.shard_crit then
					local cd_rem = chaos_bolt:GetCooldownTimeRemaining()
					local cdr = self:GetAbility():GetSpecialValueFor("shard_cdr")
					if cd_rem > 0 then
						if cd_rem - cdr > 0 then
							chaos_bolt:EndCooldown()
							chaos_bolt:StartCooldown(cd_rem - cdr)
						else
							chaos_bolt:EndCooldown()
						end
					end
					self.shard_crit = false
				end
			end
		end
	end
end



function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

function FindTalentValue(unit, talentName)
    if unit:HasAbility(talentName) then
        return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return nil
end

function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do
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
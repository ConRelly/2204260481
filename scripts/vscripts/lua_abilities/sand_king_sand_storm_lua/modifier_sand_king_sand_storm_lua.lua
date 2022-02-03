modifier_sand_king_sand_storm_lua = class({})

--------------------------------------------------------------------------------
function modifier_sand_king_sand_storm_lua:IsHidden() return false end
function modifier_sand_king_sand_storm_lua:IsDebuff() return false end
function modifier_sand_king_sand_storm_lua:IsPurgable() return false end
function modifier_sand_king_sand_storm_lua:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

--------------------------------------------------------------------------------
function modifier_sand_king_sand_storm_lua:OnCreated(kv)
	self.radius = self:GetAbility():GetSpecialValueFor("sand_storm_radius")
	local interval = self:GetAbility():GetSpecialValueFor("sand_storm_interval")

	if IsServer() then
		local damage = self:GetAbility():GetTalentSpecialValueFor("sand_storm_damage") + (self:GetCaster():GetStrength() * self:GetAbility():GetTalentSpecialValueFor("str_multiplier"))
		self.damageTable = {
			-- victim = target,
			attacker = self:GetParent(),
			damage = damage * interval,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(),
		}

		self:StartIntervalThink(interval)
		self:SandStorm_Effect(self:GetParent(), self.radius)

		EmitSoundOn("Ability.SandKing_SandStorm.loop", self:GetParent())
	end
end
function modifier_sand_king_sand_storm_lua:OnDestroy(kv)
	if IsServer() then
		if self.effect_cast then
			ParticleManager:DestroyParticle(self.effect_cast, false)
			ParticleManager:ReleaseParticleIndex(self.effect_cast)
		end

		StopSoundOn("Ability.SandKing_SandStorm.loop", self:GetParent())
	end
end

function modifier_sand_king_sand_storm_lua:DeclareFunctions()
	return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
end
function modifier_sand_king_sand_storm_lua:GetModifierInvisibilityLevel() return 1 end
function modifier_sand_king_sand_storm_lua:CheckState()
	return {[MODIFIER_STATE_ATTACK_IMMUNE] = true}
end

function modifier_sand_king_sand_storm_lua:OnIntervalThink()
	local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), 0, 0, false)

	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage(self.damageTable)
	end

	if self.effect_cast then
		self:SandStorm_Effect(self:GetParent(), self.radius)
	end
end

--------------------------------------------------------------------------------

function modifier_sand_king_sand_storm_lua:SandStorm_Effect(parent, radius)
	if self.effect_cast then
		ParticleManager:DestroyParticle(self.effect_cast, false)
		ParticleManager:ReleaseParticleIndex(self.effect_cast)
	end
	self.effect_cast = ParticleManager:CreateParticle("particles/custom/sandking_sandstorm_lua.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(radius, radius, radius))
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
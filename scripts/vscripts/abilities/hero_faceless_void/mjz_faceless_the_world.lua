LinkLuaModifier("modifier_mjz_faceless_the_world_dummy", "abilities/hero_faceless_void/mjz_faceless_the_world", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_faceless_the_world_aura_friendly", "abilities/hero_faceless_void/mjz_faceless_the_world", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_faceless_the_world_aura_effect_friendly", "abilities/hero_faceless_void/mjz_faceless_the_world", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_faceless_the_world_aura_enemy", "abilities/hero_faceless_void/mjz_faceless_the_world", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_faceless_the_world_aura_effect_enemy", "abilities/hero_faceless_void/mjz_faceless_the_world", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

mjz_faceless_the_world = class({})
function mjz_faceless_the_world:GetAOERadius()
	local radius = self:GetSpecialValueFor("radius") + talent_value(self:GetCaster(), "special_bonus_unique_mjz_faceless_the_world_radius")
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		radius = radius + self:GetSpecialValueFor("radius_super_scepter")
	end
	return radius
end
function mjz_faceless_the_world:GetAbilityTextureName()
	if IsClient() then
		if self:GetCaster():HasModifier("modifier_super_scepter") then
			icon = "mjz_faceless_the_world_immortal"
		else
			icon = "mjz_faceless_the_world"
		end
		return icon
	end
end

function mjz_faceless_the_world:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target_point = caster:GetAbsOrigin()
	
		local radius = self:GetSpecialValueFor("radius") + talent_value(caster, "special_bonus_unique_mjz_faceless_the_world_radius")
		local duration_normal = self:GetSpecialValueFor("duration")
		local duration_scepter = self:GetSpecialValueFor("duration_scepter")
		local duration = value_if_scepter(caster, duration_scepter, duration_normal)
		if caster:HasModifier("modifier_super_scepter") then
			duration = duration + self:GetSpecialValueFor("duration_super_scepter")
			radius = radius + self:GetSpecialValueFor("radius_super_scepter")
		end

		local dummy = CreateUnitByName("npc_dota_invisible_vision_source", target_point, false, caster, caster, caster:GetTeam())
		dummy:AddNewModifier(caster, nil, "modifier_phased", {})
		dummy:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
		dummy:AddNewModifier(caster, self, "modifier_item_gem_of_true_sight", {duration = duration})
		dummy:AddNewModifier(caster, self, "modifier_mjz_faceless_the_world_aura_friendly", {duration = duration})
		dummy:AddNewModifier(caster, self, "modifier_mjz_faceless_the_world_aura_enemy", {duration = duration})

		AddFOWViewer(caster:GetTeamNumber(), target_point, radius + 50, duration, false)

		EmitSoundOn("Hero_FacelessVoid.Chronosphere", caster)
	end
end

----------------------------------------------------------------------

modifier_mjz_faceless_the_world_aura_friendly = class({})
function modifier_mjz_faceless_the_world_aura_friendly:IsHidden() return false end
function modifier_mjz_faceless_the_world_aura_friendly:IsPurgable() return false end
function modifier_mjz_faceless_the_world_aura_friendly:OnCreated()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local radius = self:GetAbility():GetSpecialValueFor("radius") + talent_value(caster, "special_bonus_unique_mjz_faceless_the_world_radius")
	if caster:HasModifier("modifier_super_scepter") then
		radius = radius + self:GetAbility():GetSpecialValueFor("radius_super_scepter")
	end
	local p_name = "particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf"
	local p_name_ball = "particles/econ/items/faceless_void/faceless_void_mace_of_aeons/fv_chronosphere_aeons.vpcf"

	if (IsMakerHero and IsMakerHero(caster)) or caster:HasModifier("modifier_super_scepter") then
		self.particle_index = ParticleManager:CreateParticle(p_name_ball, PATTACH_ABSORIGIN, caster)
	else
		self.particle_index = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN, caster)
	end
	ParticleManager:SetParticleControl(self.particle_index, 0, parent:GetOrigin())
	ParticleManager:SetParticleControl(self.particle_index, 1, Vector(radius, radius, radius))
	ParticleManager:SetParticleControl(self.particle_index, 4, parent:GetOrigin())
	ParticleManager:SetParticleControl(self.particle_index, 6, parent:GetOrigin())
	ParticleManager:SetParticleControl(self.particle_index, 10, parent:GetOrigin())
end
function modifier_mjz_faceless_the_world_aura_friendly:OnDestroy()
	if not IsServer() then return end
	if self.particle_index then
		ParticleManager:DestroyParticle(self.particle_index, false)
		ParticleManager:ReleaseParticleIndex(self.particle_index)
	end
end
function modifier_mjz_faceless_the_world_aura_friendly:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}
end
function modifier_mjz_faceless_the_world_aura_friendly:IsAura() return true end
function modifier_mjz_faceless_the_world_aura_friendly:GetAuraRadius() return self:GetAbility():GetAOERadius() end
function modifier_mjz_faceless_the_world_aura_friendly:GetModifierAura() return "modifier_mjz_faceless_the_world_aura_effect_friendly" end
function modifier_mjz_faceless_the_world_aura_friendly:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_mjz_faceless_the_world_aura_friendly:GetAuraSearchType() return DOTA_UNIT_TARGET_ALL end
function modifier_mjz_faceless_the_world_aura_friendly:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_mjz_faceless_the_world_aura_friendly:GetAuraDuration() return 0.1 end
function modifier_mjz_faceless_the_world_aura_friendly:GetAuraEntityReject(target)
	if target:GetTeam() == self:GetCaster():GetTeam() and self:GetCaster():HasScepter() then
		return false
	elseif target == self:GetCaster() or target:GetMainControllingPlayer() == self:GetCaster():GetPlayerOwnerID() then
		return false
	end
	return true
end

----------------------------------------------------------------------

modifier_mjz_faceless_the_world_aura_effect_friendly = class({})
function modifier_mjz_faceless_the_world_aura_effect_friendly:IsHidden() return true end
function modifier_mjz_faceless_the_world_aura_effect_friendly:IsPurgable() return false end
function modifier_mjz_faceless_the_world_aura_effect_friendly:IsStunDebuff() return false end
function modifier_mjz_faceless_the_world_aura_effect_friendly:IsDebuff() return false end
function modifier_mjz_faceless_the_world_aura_effect_friendly:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.2)
end
function modifier_mjz_faceless_the_world_aura_effect_friendly:OnIntervalThink()
	self:SetStackCount(self:GetStackCount() + 1)
end
function modifier_mjz_faceless_the_world_aura_effect_friendly:GetEffectName() return "particles/units/heroes/hero_faceless_void/faceless_void_chrono_speed.vpcf" end
function modifier_mjz_faceless_the_world_aura_effect_friendly:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_mjz_faceless_the_world_aura_effect_friendly:CheckState()
	return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_STUNNED] = false,
		[MODIFIER_STATE_FROZEN] = false,
		[MODIFIER_STATE_ROOTED] = false,
		[MODIFIER_STATE_SILENCED] = false,
		[MODIFIER_STATE_INVISIBLE] = false,
	}
end
function modifier_mjz_faceless_the_world_aura_effect_friendly:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_mjz_faceless_the_world_aura_effect_friendly:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount() * talent_value(self:GetCaster(), "special_bonus_unique_mjz_faceless_the_world_attack_speed") * 0.2
end
function modifier_mjz_faceless_the_world_aura_effect_friendly:GetModifierMoveSpeed_AbsoluteMin()
	return self:GetAbility():GetSpecialValueFor("speed")
end

----------------------------------------------------------------------

modifier_mjz_faceless_the_world_aura_enemy = class({})
function modifier_mjz_faceless_the_world_aura_enemy:IsHidden() return true end
function modifier_mjz_faceless_the_world_aura_enemy:IsPurgable() return false end
function modifier_mjz_faceless_the_world_aura_enemy:IsAura() return true end
function modifier_mjz_faceless_the_world_aura_enemy:GetAuraRadius() return self:GetAbility():GetAOERadius() end
function modifier_mjz_faceless_the_world_aura_enemy:GetModifierAura() return "modifier_mjz_faceless_the_world_aura_effect_enemy" end
function modifier_mjz_faceless_the_world_aura_enemy:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_BOTH end
function modifier_mjz_faceless_the_world_aura_enemy:GetAuraSearchType() return DOTA_UNIT_TARGET_ALL end
function modifier_mjz_faceless_the_world_aura_enemy:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_mjz_faceless_the_world_aura_enemy:GetAuraDuration() return 0.1 end
function modifier_mjz_faceless_the_world_aura_enemy:GetAuraEntityReject(target)
	if target:GetTeam() == self:GetCaster():GetTeam() and self:GetCaster():HasScepter() then
		return true
	elseif target == self:GetCaster() or target:GetMainControllingPlayer() ~= self:GetCaster():GetPlayerOwnerID() then
		return true
	end
	return false
end

----------------------------------------------------------------------

modifier_mjz_faceless_the_world_aura_effect_enemy = class({})
function modifier_mjz_faceless_the_world_aura_effect_enemy:IsHidden() return false end
function modifier_mjz_faceless_the_world_aura_effect_enemy:IsPurgable() return false end
function modifier_mjz_faceless_the_world_aura_effect_enemy:IsStunDebuff() return true end
function modifier_mjz_faceless_the_world_aura_effect_enemy:IsDebuff() return true end
function modifier_mjz_faceless_the_world_aura_effect_enemy:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end
function modifier_mjz_faceless_the_world_aura_effect_enemy:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_stuf")
end
function modifier_mjz_faceless_the_world_aura_effect_enemy:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}
end

----------------------------------------------------------------------

function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
end

function HasTalentBy(ability, value)
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
        return talent and talent:GetLevel() > 0 
    end
    return false
end


-- 是否学习了指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local valueName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                    valueName = m["LinkedSpecialBonusField"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            valueName = valueName or "value"
            base = base + talent:GetSpecialValueFor(valueName) 
        end
    end
    return base
end

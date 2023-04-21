LinkLuaModifier("modifier_mjz_doom_bringer_infernal_blade_burn","modifiers/hero_doom_bringer/modifier_mjz_doom_bringer_infernal_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_doom_bringer_infernal_blade_stun","modifiers/hero_doom_bringer/modifier_mjz_doom_bringer_infernal_blade.lua", LUA_MODIFIER_MOTION_NONE)


modifier_mjz_doom_bringer_infernal_blade = class({})
local modifier_class = modifier_mjz_doom_bringer_infernal_blade

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
	
	function modifier_class:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_ORDER,
			MODIFIER_EVENT_ON_ATTACK_START,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
		}
		return funcs
	end

	function modifier_class:OnAttackStart( event )
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local attacker = event.attacker
		local target = event.target
		
		if not self:_CheckAttack(event) then return false end

		if ability:GetAutoCastState() or ability.overrideAutocast then
			EmitSoundOn("Hero_DoomBringer.InfernalBlade.PreAttack", attacker)
		end
	end

	function modifier_class:OnAttackLanded( event )
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local attacker = event.attacker
		local target = event.target
		
		if not self:_CheckAttack(event) then return false end

		if ability:GetAutoCastState() or ability.overrideAutocast then
			 self:AddEffectModifier(target)

			-- ability:PayManaCost()
			-- ability:StartCooldown(ability:GetCooldownTimeRemaining())
			-- void UseResources(bool bMana, bool bGold, bool bCooldown)
			ability:UseResources(true, true, false, true)

			--[[
				local caster = attacker
				local p_name = "particles/units/heroes/hero_doom_bringer/doom_infernal_blade.vpcf"
				local p_index = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, caster) 
				ParticleManager:SetParticleControlEnt(p_index, 1, caster, PATTACH_POINT_FOLLOW, "attach_weapon_blur", caster:GetAbsOrigin(), true)
				-- ParticleManager:ReleaseParticleIndex(p_index)
				self.p = p_index
			]]
        end
	end

	function modifier_class:OnOrder(keys)
		if keys.unit ~= self:GetParent() then return end
		self:GetAbility().overrideAutocast = false
		if self.p then
			ParticleManager:DestroyParticle(self.p, false)
			ParticleManager:ReleaseParticleIndex(self.p)
			self.p = nil
		end
	end

	function modifier_class:_CheckAttack(event)
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local attacker = event.attacker
		local target = event.target

		if attacker ~= parent then return false end
		--if attacker:IsIllusion() then return false end
		if target:IsTower() or target:IsBarracks() then return false end
		if target:IsBuilding() or target:IsOther() then return false end

		if (not ability:IsCooldownReady()) or (not ability:IsFullyCastable()) then return false end
		if attacker:IsSilenced() then return false end
		-- if attacker:GetMana() < ability:GetManaCost(ability:GetLevel()) then return false end

		return true
	end

	function modifier_class:AddEffectModifier(target)
		local parent = self:GetParent()
		local caster = self:GetParent()
        local ability = self:GetAbility()
		local burn_duration = ability:GetSpecialValueFor('burn_duration')
		local stun_duration = ability:GetSpecialValueFor('stun_duration')


		local modifier_burn_name = 'modifier_mjz_doom_bringer_infernal_blade_burn'
		local modifier_stun_name = 'modifier_mjz_doom_bringer_infernal_blade_stun'
		target:AddNewModifier(caster, ability, modifier_burn_name, {duration = burn_duration})
		target:AddNewModifier(caster, ability, modifier_stun_name, {duration = stun_duration})
	end

end

-----------------------------------------------------------------------------------------

modifier_mjz_doom_bringer_infernal_blade_burn = class({})
local modifier_burn = modifier_mjz_doom_bringer_infernal_blade_burn

function modifier_burn:IsHidden() return false end
function modifier_burn:IsPurgable() return false end
function modifier_burn:IsDebuff() return true end
function modifier_burn:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE		-- 效果能够存在多个
end

function modifier_burn:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf"
end
function modifier_burn:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

if IsServer() then

	function modifier_burn:OnCreated(table)
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local p_name = "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_impact.vpcf"
		local pIndex =  ParticleManager:CreateParticle( p_name, PATTACH_ABSORIGIN_FOLLOW, parent )
		ParticleManager:ReleaseParticleIndex(pIndex)
		EmitSoundOn("Hero_DoomBringer.InfernalBlade.Target", parent)

		self:OnIntervalThink()
		self:StartIntervalThink(1.0)
	end

	function modifier_burn:OnIntervalThink()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local burn_base_damage = GetTalentSpecialValueFor(ability, 'burn_base_damage')
		local burn_strength_damage_pct = GetTalentSpecialValueFor(ability, 'burn_strength_damage_pct')
		local caster_strength = caster:GetStrength()

		local damage = burn_base_damage + caster_strength * (burn_strength_damage_pct / 100.0)
		local postDmg = ApplyDamage({
			ability = ability,
			victim = parent, 
			attacker = caster, 
			damage = damage, 
			damage_type = ability:GetAbilityDamageType()
		})
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), postDmg, self:GetCaster())
	end

end

-----------------------------------------------------------------------------------------

modifier_mjz_doom_bringer_infernal_blade_stun = class({})
local modifier_stun = modifier_mjz_doom_bringer_infernal_blade_stun

function modifier_stun:IsHidden() return true end
function modifier_stun:IsPurgable() return true end
function modifier_stun:IsDebuff() return true end
function modifier_stun:IsStunDebuff() return true end

function modifier_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end
function modifier_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_stun:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end
function modifier_stun:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_stun:CheckState()
	return { [MODIFIER_STATE_STUNNED] = true}
end
-----------------------------------------------------------------------------------------

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
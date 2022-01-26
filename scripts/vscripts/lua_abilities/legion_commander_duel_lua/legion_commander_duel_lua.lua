LinkLuaModifier("modifier_legion_commander_duel_lua", "lua_abilities/legion_commander_duel_lua/legion_commander_duel_lua", LUA_MODIFIER_MOTION_NONE)


legion_commander_duel_lua = class({})
function legion_commander_duel_lua:GetIntrinsicModifierName() return "modifier_legion_commander_duel_lua" end

--------------------------------------------------------------------------------

modifier_legion_commander_duel_lua = class({})
function modifier_legion_commander_duel_lua:IsHidden() return self:GetStackCount() < 1 end
function modifier_legion_commander_duel_lua:IsPurgable() return false end
function modifier_legion_commander_duel_lua:AllowIllusionDuplicate() return false end
function modifier_legion_commander_duel_lua:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end
function modifier_legion_commander_duel_lua:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local modifier = self
		if parent:HasModifier(modifier) then
			local time = GameRules:GetGameTime() / 60
			if time > 1 then
				local mbuff = parent:FindModifierByName(modifier)	
				local stack = math.floor(time / 2)
				mbuff:SetStackCount(stack)
			end 
		end
	end	

end	

function modifier_legion_commander_duel_lua:OnDeath(event)
	if IsServer() then
		local caster = self:GetCaster()
		local target = event.target
		if caster:IsIllusion() then return end
		if caster:PassivesDisabled() then return end
		if not caster:IsAlive() then return end
		if event.unit == nil or event.attacker == nil or event.unit:IsNull() or event.attacker:IsNull() then return end
		if target == nil then target = event.unit end	
		if event.attacker:GetTeamNumber() == caster:GetTeamNumber() and caster:GetTeamNumber() ~= target:GetTeamNumber() then
			local chance = GetTalentSpecialValueFor(self:GetAbility(), "stack_chance")
			if RollPercentage(chance) then
				self:SetStackCount(self:GetStackCount() + 1)

				local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
				ParticleManager:ReleaseParticleIndex(nFXIndex)
			end	
		end
	end   
end
function modifier_legion_commander_duel_lua:GetModifierPreAttack_BonusDamage(params)
	if self:GetParent():PassivesDisabled() then return end
	if self:GetParent():IsIllusion() then return end

	local BonusDamage = self:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage_bonus")
	local DamagePerStr = self:GetStackCount() * self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("str_multiplier")
	return BonusDamage + DamagePerStr
end

--------------------------------------------------------------------------------

-- talents
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
LinkLuaModifier("modifier_mjz_nyx_assassin_spiked_carapace", "abilities/hero_nyx_assassin/mjz_nyx_assassin_spiked_carapace.lua", LUA_MODIFIER_MOTION_NONE)


mjz_nyx_assassin_spiked_carapace = class({})
function mjz_nyx_assassin_spiked_carapace:GetManaCost(iLevel)
	return self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("mana_cost_per") / 100
end
function mjz_nyx_assassin_spiked_carapace:OnToggle()
	if IsServer() then
		if self:GetToggleState() then
			EmitSoundOn("Hero_NyxAssassin.SpikedCarapace", self:GetCaster())
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_mjz_nyx_assassin_spiked_carapace", {})
			if self:GetCaster():HasModifier("modifier_nyx_assassin_burrow") then
				local stun_duration = self:GetSpecialValueFor("stun_duration")

				local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetCaster():CustomValue("nyx_assassin_burrow", "carapace_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

				for _, target in pairs(targets) do
					if target then
						local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace_hit.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
						ParticleManager:SetParticleControl(nfx, 0, target:GetAbsOrigin())
						ParticleManager:SetParticleControlEnt(nfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
						ParticleManager:SetParticleControl(nfx, 2, Vector(1,0,0))
						
						ParticleManager:ReleaseParticleIndex(nfx)
						
						target:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = stun_duration})
						EmitSoundOn("Hero_NyxAssassin.SpikedCarapace.Stun", target)
					end
				end
			end
		else
			self:GetCaster():RemoveModifierByName("modifier_mjz_nyx_assassin_spiked_carapace")
		end
	end
end

----------------------------------------------------------------------------

modifier_mjz_nyx_assassin_spiked_carapace = class({})
local modifier_class = modifier_mjz_nyx_assassin_spiked_carapace

function modifier_class:IsPassive() return false end
function modifier_class:IsPurgable() return false end
function modifier_class:IsHidden() return true end
function modifier_class:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_class:GetEffectName() return "particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace.vpcf" end
function modifier_class:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
function modifier_class:GetModifierIncomingDamage_Percentage() return self:GetAbility():GetSpecialValueFor("damage_reduction_pct") end

if IsServer() then
	function modifier_class:OnCreated()
		self.interval = 0.25
		self:StartIntervalThink(self.interval)
	end

	function modifier_class:OnIntervalThink()
		local mana_per_interval = (self:GetParent():GetMaxMana() * self:GetAbility():GetSpecialValueFor("mana_cost_per") / 100) * self.interval
		self:GetParent():SpendMana(mana_per_interval, self:GetAbility())
	end

	function modifier_class:OnTakeDamage(params)
		local target = params.attacker
		local unit = self:GetParent()
		if params.unit ~= self:GetParent() or params.unit == nil then return end
		if target == unit then return end
		if target:IsMagicImmune() then return end

		if not self:GetAbility():IsOwnersManaEnough() then return end
		
		local re_damage = math.ceil((params.damage * GetTalentSpecialValueFor(self:GetAbility(), "damage_reflect_pct") / 100) * (1 + self:GetCaster():GetSpellAmplification(false) / 4))
		
		local isTarget = UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber()) == UF_SUCCESS
		if isTarget and IsValidEntity(target) and target:IsAlive() then
			
			local prev_stun_time = target.mjz_nyx_assassin_spiked_carapace_stun_time or 0
			if (GameRules:GetGameTime() - prev_stun_time) > self:GetAbility():GetSpecialValueFor("stun_interval") then
				target.mjz_nyx_assassin_spiked_carapace_stun_time = GameRules:GetGameTime()
				
				EmitSoundOn("Hero_NyxAssassin.SpikedCarapace.Stun", target)
				
				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace_hit.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
				ParticleManager:SetParticleControl(nfx, 0, target:GetAbsOrigin())
				ParticleManager:SetParticleControlEnt(nfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 2, Vector(1,0,0))
				
				ParticleManager:ReleaseParticleIndex(nfx)
				
				target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
			end

			ApplyDamage ({
				victim = target,
				attacker = unit,
				damage = re_damage,
				damage_type = params.damage_type,
				ability = self:GetAbility(),
				damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			})
		end
	end
end

-----------------------------------------------------------------------------------------

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
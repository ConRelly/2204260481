LinkLuaModifier("modifier_mjz_luna_under_the_moonlight_buff", "abilities/hero_luna/mjz_luna_under_the_moonlight.lua", LUA_MODIFIER_MOTION_NONE)

mjz_luna_under_the_moonlight = mjz_luna_under_the_moonlight or class({})
modifier_mjz_luna_under_the_moonlight_buff = class(mjz_luna_under_the_moonlight)

function mjz_luna_under_the_moonlight:Spawn()
	if IsServer() then
		self:SetLevel(1)
	end
end

function mjz_luna_under_the_moonlight:GetIntrinsicModifierName() return "modifier_mjz_luna_under_the_moonlight_buff" end
function mjz_luna_under_the_moonlight:LucentBeam(target, stun)
	if IsServer() then
		local caster = self:GetCaster()
		local position = target:GetAbsOrigin()
		local sDur = stun or 0
		local mbuf = caster:FindModifierByName("modifier_mjz_luna_under_the_moonlight_buff")
		local stack_count = mbuf:GetStackCount() + 1
		local bonus_stack = 0
		if _G._challenge_bosss > 0 then
			bonus_stack = _G._challenge_bosss
		end	
		local level = caster:GetLevel() * (3 + bonus_stack)
		if level < 30 then
			level = 30
		end
		local damage = level * stack_count		
		if caster:HasModifier("modifier_super_scepter") then
			if target and target:HasModifier("modifier_lucent_beam_ss_mult") then
				local modif_moon = target:FindModifierByName("modifier_lucent_beam_ss_mult")	
				if modif_moon then 
					local stacks_moon = modif_moon:GetStackCount()
					damage = math.floor( damage * (1 + (stacks_moon / 100)))
				end
			end	
		end			
		if not target:TriggerSpellAbsorb(self) then
			self:DealDamage(caster, target, damage)
			if sDur > 0 then
				self:Stun(target, sDur)
			end
		end

		local beam_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_lucent_beam.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControl(beam_pfx, 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(beam_pfx,	5, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(beam_pfx,	6, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:DestroyParticle(beam_pfx, false)
		ParticleManager:ReleaseParticleIndex(beam_pfx)

		if stun then target:EmitSound("Hero_Luna.LucentBeam.Target") end
	end	
end

function mjz_luna_under_the_moonlight:DealDamage(attacker, target, damage, data, spellText)
	if self:IsNull() or target:IsNull() or attacker:IsNull() then return end
	local internalData = data or {}
	local damageType =  internalData.damage_type or self:GetAbilityDamageType() or DAMAGE_TYPE_MAGICAL
	local damageFlags = internalData.damage_flags or DOTA_DAMAGE_FLAG_NONE
	local localdamage = damage or self:GetAbilityDamage() or 0
	local spellText = spellText or 0
	local ability = self or internalData.ability
	local oldHealth = target:GetHealth()
	ApplyDamage({victim = target, attacker = attacker, ability = ability, damage_type = damageType, damage = localdamage, damage_flags = damageFlags})
	if target:IsNull() then return oldHealth end
	local newHealth = target:GetHealth()
	local returnDamage = oldHealth - newHealth
	if spellText > 0 then
		SendOverheadEventMessage(attacker:GetPlayerOwner(),spellText,target,returnDamage,attacker:GetPlayerOwner())
	end
	return returnDamage
end
function mjz_luna_under_the_moonlight:Stun(target, duration, bDelay)
	if not target or target:IsNull() then return end
	local delay = false
	if bDelay then delay = Bdelay end
	return target:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = duration, delay = delay})
end

---------------------------------------------------

function modifier_mjz_luna_under_the_moonlight_buff:IsHidden() return false end
function modifier_mjz_luna_under_the_moonlight_buff:IsDebuff() return false end
function modifier_mjz_luna_under_the_moonlight_buff:IsPurgable() return false end
function modifier_mjz_luna_under_the_moonlight_buff:RemoveOnDeath() return false end
function modifier_mjz_luna_under_the_moonlight_buff:AllowIllusionDuplicate() return true end	
function modifier_mjz_luna_under_the_moonlight_buff:GetTexture() return "mjz_luna_under_the_moonlight" end
function modifier_mjz_luna_under_the_moonlight_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_EVENT_ON_ATTACK,
	}	 
end
function modifier_mjz_luna_under_the_moonlight_buff:OnCreated()
	if not IsServer() then return end
	local parent = self:GetParent()
	if parent:IsIllusion() or parent:HasModifier("modifier_arc_warden_tempest_double") then
		local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
		if owner then
			if parent:HasModifier("modifier_mjz_luna_under_the_moonlight_buff") then
				local modifier1 = parent:FindModifierByName("modifier_mjz_luna_under_the_moonlight_buff")
				if owner:HasModifier("modifier_mjz_luna_under_the_moonlight_buff") then
					local modifier2 = owner:FindModifierByName("modifier_mjz_luna_under_the_moonlight_buff")
					modifier1:SetStackCount(modifier2:GetStackCount())
				end
			end
		end
	end
	--self:SetStackCount(0)
end
function modifier_mjz_luna_under_the_moonlight_buff:OnRefresh()
	if IsServer() then
		local stack_up = 1
		if _G._challenge_bosss > 0 then
			stack_up = _G._challenge_bosss
		end			
		self:SetStackCount(self:GetStackCount() + stack_up)
	end	
end
function modifier_mjz_luna_under_the_moonlight_buff:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("spell_amp") end
end
function modifier_mjz_luna_under_the_moonlight_buff:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_hp") end
end
function modifier_mjz_luna_under_the_moonlight_buff:GetModifierManaBonus()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_mp") end
end
function modifier_mjz_luna_under_the_moonlight_buff:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_agi") end
end

function modifier_mjz_luna_under_the_moonlight_buff:OnAttack(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetParent() then return end
	if keys.target:IsBuilding() then return end
	if not IsInToolsMode() and keys.target:GetTeamNumber() == self:GetParent():GetTeamNumber() then return end
	if not self:GetAbility() then return end

	local attacker = keys.attacker
	local target = keys.target
	local chance = self:GetAbility():GetSpecialValueFor("proc_chance")
	if RollPercentage(chance) then --self:GetAbility():GetSpecialValueFor("proc_chance")
		if self:GetCaster():IsAlive() then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_mjz_luna_under_the_moonlight_buff", {})
			if keys.target:IsMagicImmune() then return end
			self:GetAbility():LucentBeam(target)
		end	
	end
end

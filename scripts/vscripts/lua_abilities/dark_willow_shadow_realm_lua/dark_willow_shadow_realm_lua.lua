-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]

LinkLuaModifier("modifier_dark_willow_shadow_realm_lua", "lua_abilities/dark_willow_shadow_realm_lua/dark_willow_shadow_realm_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dark_willow_shadow_realm_lua_buff", "lua_abilities/dark_willow_shadow_realm_lua/dark_willow_shadow_realm_lua", LUA_MODIFIER_MOTION_NONE)


--------------------------------------------------------------------------------
-- Shadow Realm
--------------------------------------------------------------------------------

dark_willow_shadow_realm_lua = class({})
function dark_willow_shadow_realm_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_dark_willow_shadow_realm_lua", {duration = self:GetSpecialValueFor("duration")})
end


--------------------------------------------------------------------------------
-- Shadow Realm Modifier
--------------------------------------------------------------------------------

modifier_dark_willow_shadow_realm_lua = class({})
function modifier_dark_willow_shadow_realm_lua:IsHidden() return false end
function modifier_dark_willow_shadow_realm_lua:IsDebuff() return false end
function modifier_dark_willow_shadow_realm_lua:IsPurgable() return false end
function modifier_dark_willow_shadow_realm_lua:GetStatusEffectName()
	return "particles/status_fx/status_effect_dark_willow_shadow_realm.vpcf"
end
function modifier_dark_willow_shadow_realm_lua:OnCreated()
	if not IsServer() then return end

	self.bonus_range = self:GetAbility():GetSpecialValueFor("attack_range_bonus")
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("damage") + (self:GetParent():GetIntellect(true) * self:GetAbility():GetTalentSpecialValueFor("int_multiplier"))
	self.bonus_max = self:GetAbility():GetSpecialValueFor("max_damage_duration")

	self.scepter = self:GetParent():HasScepter()
	self.create_time = GameRules:GetGameTime()

	ProjectileManager:ProjectileDodge(self:GetParent())

	if self:GetParent():GetAggroTarget() and not self.scepter then
		ExecuteOrderFromTable({UnitIndex = self:GetParent():entindex(), OrderType = DOTA_UNIT_ORDER_STOP})
	end
	self:GetParent():Purge(false, true, false, true, true)
	self:PlayEffects()
end
function modifier_dark_willow_shadow_realm_lua:OnRefresh()
	if not IsServer() then return end

	self.bonus_range = self:GetAbility():GetSpecialValueFor("attack_range_bonus")
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("damage") + (self:GetParent():GetIntellect(true) * self:GetAbility():GetTalentSpecialValueFor("int_multiplier"))
	self.bonus_max = self:GetAbility():GetSpecialValueFor("max_damage_duration")
end
function modifier_dark_willow_shadow_realm_lua:OnDestroy()
	StopSoundOn("Hero_DarkWillow.Shadow_Realm", self:GetParent())
end

function modifier_dark_willow_shadow_realm_lua:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_EVENT_ON_ATTACK}
end

function modifier_dark_willow_shadow_realm_lua:GetModifierAttackRangeBonus()
	if self:GetAbility() then return self.bonus_range end
end

function modifier_dark_willow_shadow_realm_lua:OnAttack(params)
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end

	local time = GameRules:GetGameTime() - self.create_time
	time = math.min(time / self.bonus_max, 1)

	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_dark_willow_shadow_realm_lua_buff", {record = params.record, damage = self.bonus_damage, time = time, target = params.target:entindex()})

--	EmitSoundOn("Hero_DarkWillow.Shadow_Realm.Attack", self:GetParent())

	if not self.scepter then if self:IsNull() then return end
		self:Destroy()
	end
end

function modifier_dark_willow_shadow_realm_lua:CheckState()
	local state = {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
--		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
	}

	return state
end

function modifier_dark_willow_shadow_realm_lua:PlayEffects()
	local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_shadow_realm.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)

	self:AddParticle(effect_cast, false, false, -1, false, false)
	EmitSoundOn("Hero_DarkWillow.Shadow_Realm", self:GetParent())
end


--------------------------------------------------------------------------------
-- Shadow Realm Attack Buff Modifier
--------------------------------------------------------------------------------

modifier_dark_willow_shadow_realm_lua_buff = class({})
function modifier_dark_willow_shadow_realm_lua_buff:IsHidden() return true end
function modifier_dark_willow_shadow_realm_lua_buff:IsDebuff() return false end
function modifier_dark_willow_shadow_realm_lua_buff:IsPurgable() return false end
function modifier_dark_willow_shadow_realm_lua_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_dark_willow_shadow_realm_lua_buff:OnCreated(kv)
	if not IsServer() then return end

	self.damage = kv.damage
	self.record = kv.record
	self.time = kv.time
	self.target = EntIndexToHScript(kv.target)

--	self:PlayEffects()
end

function modifier_dark_willow_shadow_realm_lua_buff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY, MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL}
end

function modifier_dark_willow_shadow_realm_lua_buff:OnAttackRecordDestroy(params)
	if not IsServer() then return end
	if params.record~=self.record then return end

--	self:StopEffects(false)
	if self:IsNull() then return end
	self:Destroy()
end
function modifier_dark_willow_shadow_realm_lua_buff:GetModifierProcAttack_BonusDamage_Magical(params)
	if params.record~=self.record then return end
	if not self:GetAbility() then return end
	local parent = self:GetParent()
	local damage = self.damage * self.time * (1 + parent:GetSpellAmplification(false))
	local ability = self:GetAbility()
	local chance = ability:GetSpecialValueFor("ss_chance")
	local crit_power = ability:GetSpecialValueFor("crit_power") * 0.01
	local crit_status = parent:GetStatusResistance() * crit_power -- status can go negative but is fine 
	if parent:HasModifier("modifier_super_scepter") and RollPercentage(chance) then    --is not affected by arcane or wings and arcane has a x 1.8 for every hit (that's 4x with 20%)
		--here other crit sources can be added , like (crit_power + crit_status + crit_etc )
		local dmg = damage * (crit_power + crit_status )

		damage = dmg
		create_popup({
			target = params.target,
			value = damage,
			color = Vector(5, 129, 232),
			type = "crit",
			pos = 4
		})
	else	
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, params.target, damage, parent:GetPlayerOwner())
	end	

--	EmitSoundOn("Hero_DarkWillow.Shadow_Realm.Damage", self:GetParent())

	return damage
end
--[[
function modifier_dark_willow_shadow_realm_lua_buff:PlayEffects()
	if not IsServer() then return end
	local speed = self:GetParent():GetProjectileSpeed()

	self.effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_shadow_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(self.effect_cast, 2, Vector(self:GetParent():GetProjectileSpeed(), 0, 0))
	ParticleManager:SetParticleControl(self.effect_cast, 5, Vector(self.time, 0, 0))
end

function modifier_dark_willow_shadow_realm_lua_buff:StopEffects(dodge)
	ParticleManager:DestroyParticle(self.effect_cast, dodge)
	ParticleManager:ReleaseParticleIndex(self.effect_cast)
end
]]


--------------------------------------------------------------------------------

function HasTalent(unit, talentName)
	if unit:HasAbility(talentName) then
		if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end
	return false
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
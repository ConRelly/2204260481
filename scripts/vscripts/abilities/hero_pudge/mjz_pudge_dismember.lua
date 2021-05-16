LinkLuaModifier("modifier_mjz_pudge_dismember_duration", "abilities/hero_pudge/mjz_pudge_dismember.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_pudge_dismember", "abilities/hero_pudge/mjz_pudge_dismember.lua", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------------
mjz_pudge_dismember = class({})
function mjz_pudge_dismember:GetConceptRecipientType() return DOTA_SPEECH_USER_ALL end
function mjz_pudge_dismember:SpeakTrigger() return DOTA_ABILITY_SPEAK_CAST end
function mjz_pudge_dismember:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
	return self.BaseClass.GetBehavior(self)
end
--[[
function mjz_pudge_dismember:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_aoe")
	end
	return self.BaseClass.GetCastRange(vLocation, hTarget)
end
]]
function mjz_pudge_dismember:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_aoe")
	end
	return 0
end

function mjz_pudge_dismember:GetCooldown(iLvl)
	local cooldown = self.BaseClass.GetCooldown(self, iLvl)
	if self:GetCaster():HasScepter() then
		cooldown = self:GetSpecialValueFor("scepter_cooldown")
	end
	return cooldown
end

function mjz_pudge_dismember:GetChannelAnimation()
	return ACT_DOTA_CHANNEL_ABILITY_4
end

function mjz_pudge_dismember:GetChannelTime()
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")
		local mName = "modifier_mjz_pudge_dismember_duration"
		if caster:HasModifier(mName) then
			duration = duration + 2.0
		else
			local sb = caster:FindAbilityByName("special_bonus_unique_mjz_pudge_dismember_duration")
			if sb and sb:GetLevel() > 0 then
				if not caster:HasModifier(mName) then
					caster:AddNewModifier(caster, self, mName, {})
				end
			end
		end
	end
	return duration
end

function mjz_pudge_dismember:OnAbilityPhaseStart()
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()
		self.hVictims = {}
		if self:GetCaster():HasScepter() then
			-- local point = caster:GetAbsOrigin()
			local point = self:GetCursorPosition()
			local radius = ability:GetSpecialValueFor("scepter_aoe") + caster:GetCastRangeBonus()
			self.hVictims = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
		else
			self.hVictims[1] = self:GetCursorTarget()
		end
	end
	return true
end

function mjz_pudge_dismember:OnChannelFinish(bInterrupted)
	if not IsServer() then
		return 
	end
	if self.hVictims ~= nil then
		for _,victim in pairs(self.hVictims) do
			victim:RemoveModifierByName("modifier_mjz_pudge_dismember")
		end
	end
end


function mjz_pudge_dismember:OnSpellStart()
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()
		self.parent = self:GetCaster()

		PM_FireParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack1"})
		PM_FireParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack2"})
		
		self.counter = 0
		--local cooldown = self.BaseClass.GetCooldown(self, iLvl)
		if self:GetCaster():HasScepter() then
			cooldown = self:GetSpecialValueFor("scepter_cooldown")
		else
			cooldown = self:GetSpecialValueFor("cooldown")
		end	
		--local cooldown = self:GetSpecialValueFor("scepter_cooldown")
		self:EndCooldown()
		self:StartCooldown(cooldown * self.parent:GetCooldownReduction())
		
		if self.hVictims and #self.hVictims > 0 then
			for _,victim in pairs(self.hVictims) do
				if victim:TriggerSpellAbsorb(self) then
					if #self.hVictims == 1 then
						caster:Interrupt()
					end
				else
					victim:AddNewModifier(caster, ability, "modifier_mjz_pudge_dismember", { duration = self:GetChannelTime() })
					victim:Interrupt()
				end
			end
		else
			caster:Interrupt()
		end
	end
end

function mjz_pudge_dismember:OnChannelThink(flInterval)
	local caster = self:GetCaster()
--[[
	local endPoint = caster:GetAbsOrigin() + caster:GetForwardVector() * self:GetTrueCastRange()
	local speed = 1.5 * flInterval
	self.counter = self.counter + flInterval
	local enemies = self.hVictims
	for _,enemy in pairs(enemies) do
		if CalculateDistance(enemy, caster) > caster:GetAttackRange() then
			enemy:SetAbsOrigin(enemy:GetAbsOrigin() - CalculateDirection(enemy, caster) * speed)
		end
	end
]]
	if self.counter > 0.25 then
		EmitSoundOn("Hero_Pudge.Dismember", caster)
		EmitSoundOn("Hero_Pudge.DismemberSwings", caster)
		PM_FireParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack1"})
		PM_FireParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack2"})
		
		self.counter = 0
	end
end

---------------------------------------------------------------------------------------
modifier_mjz_pudge_dismember_duration = class({})
function modifier_mjz_pudge_dismember_duration:IsHidden() return true end
function modifier_mjz_pudge_dismember_duration:IsPurgable() return false end
function modifier_mjz_pudge_dismember_duration:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

---------------------------------------------------------------------------------------
modifier_mjz_pudge_dismember = class({})
function modifier_mjz_pudge_dismember:IsHidden() return false end
function modifier_mjz_pudge_dismember:IsPurgable() return false end
function modifier_mjz_pudge_dismember:IsDebuff() return true end
function modifier_mjz_pudge_dismember:IsStunDebuff() return true end
function modifier_mjz_pudge_dismember:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_INVISIBLE] = false}
end
function modifier_mjz_pudge_dismember:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end
function modifier_mjz_pudge_dismember:GetOverrideAnimation(params) return ACT_DOTA_DISABLED end
--[[
function modifier_mjz_pudge_dismember:GetEffectName()
	return "particles/units/heroes/hero_pudge/pudge_dismember.vpcf"
end
]]
if IsServer() then
	function modifier_mjz_pudge_dismember:OnCreated(kv)
		local ability = self:GetAbility()
		self.dismember_damage = GetTalentSpecialValueFor(ability, "dismember_damage")
		self.strength_damage = GetTalentSpecialValueFor(ability, "strength_damage")
		self.tick_rate = 1.0
		
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleAlwaysSimulate(self.nfx)
		ParticleManager:SetParticleControlEnt(self.nfx, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)


		self:GetParent():InterruptChannel()
		self:OnIntervalThink()
		self:StartIntervalThink(self.tick_rate)
	end

	function modifier_mjz_pudge_dismember:OnDestroy()
		--self:GetCaster():InterruptChannel()
		ParticleManager:ReleaseParticleIndex(self.nfx)
	end

	function modifier_mjz_pudge_dismember:OnIntervalThink()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local damage = self.dismember_damage + caster:GetStrength() * self.strength_damage

		if parent:IsAlive() then
			local damageTable = {
				victim = parent,
				attacker = caster,
				damage = damage,
				damage_type = ability:GetAbilityDamageType(),
				ability = ability,
			}
			ApplyDamage(damageTable)
			caster:Heal(damage, caster)
		end
		-- EmitSoundOn("Hero_Pudge.Dismember", self:GetParent())
	end
end

------------------------------------------------------------------------------------------

function PM_FireParticle(effect, attach, owner, cps)
	local FX = ParticleManager:CreateParticle(effect, attach, owner)
	if cps then
		for cp, value in pairs(cps) do
			if type(value) == "userdata" then
				ParticleManager:SetParticleControl(FX, tonumber(cp), value)
			elseif type(value) == "table" then
				ParticleManager:SetParticleControlEnt(FX, cp, value.owner or owner, value.attach or attach, value.point or "attach_hitloc", (value.owner or owner):GetAbsOrigin(), true)
			else
				ParticleManager:SetParticleControlEnt(FX, cp, owner, attach, value, owner:GetAbsOrigin(), true)
			end
		end
	end
	ParticleManager:ReleaseParticleIndex(FX)
end


function FindWearables(unit, wearable_model_name)
	local model = unit:FirstMoveChild()
	while model ~= nil do
		if model:GetClassname() == "dota_item_wearable" then
			local modelName = model:GetModelName()
			if modelName == wearable_model_name then
				return true
			end
		end
		model = model:NextMovePeer()
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

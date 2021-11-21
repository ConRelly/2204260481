LinkLuaModifier("modifier_item_blast_staff3", "items/item_blast_staff_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_blast_staff_debuff", "items/item_blast_staff_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_blast_staff3_proc", "items/item_blast_staff_3.lua", LUA_MODIFIER_MOTION_NONE)
local debuff_bonus = 0
item_blast_staff_3 = class({})
function item_blast_staff_3:GetIntrinsicModifierName() return "modifier_item_blast_staff3" end
function item_blast_staff_3:OnSpellStart()
	local parent = self:GetParent()
	local target = self:GetCursorPosition()
	local strikes = self:GetSpecialValueFor("strikes")
	for count = 1, strikes do
		local tempTarget = target + Vector(RandomInt(-150, 150),RandomInt(-150, 150), 0)
		local direction = (tempTarget - parent:GetAbsOrigin()):Normalized()
		local direction = (direction * Vector(1, 1, 0)):Normalized()
		ProjectileManager:CreateLinearProjectile({
			EffectName = "particles/custom/items/blast_staff/blast_staff_active.vpcf",
			Ability = self,
			vSpawnOrigin = parent:GetAbsOrigin() + Vector(0,0,100),
			vVelocity = direction * 4100,
			fDistance = 1200 + parent:GetCastRangeBonus(),
			fStartRadius = 120,
			fEndRadius = 120,
			Source = parent,
			fExpireTime = GameRules:GetGameTime() + 5,
			bDeleteOnHit = false,
			bHasFrontalCone = false,
			bReplaceExisiting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAGS_NONE,
			iUnitTargetType = self:GetAbilityTargetType(),
		})
	end
	parent:EmitSound("Hero_Alchemist.UnstableConcoction.Stun")
	parent:EmitSound("Hero_Alchemist.UnstableConcoction.Stun")
end

if IsServer() then
	function item_blast_staff_3:OnProjectileHit(target, location)
		if target and target:IsAlive() and not target:IsMagicImmune() then
			local parent = self:GetParent()
			local particleIndex = ParticleManager:CreateParticle("particles/custom/items/blast_staff/blast_staff_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			local bonus_marci_int_mult = 0
			ParticleManager:SetParticleControl(particleIndex, 3, target:GetAbsOrigin())
			local duration = self:GetSpecialValueFor("debuff_duration")
			if parent:HasModifier("modifier_super_scepter") then
				if parent:HasModifier("modifier_marci_unleash_flurry") then
					duration = duration + 1
					debuff_bonus = -10
					bonus_marci_int_mult = 5
				end                                 
			end 			
			local damage = (self:GetSpecialValueFor("int_multiplier") + bonus_marci_int_mult) * parent:GetIntellect()
			if not target:HasModifier("modifier_item_blast_staff_debuff") and parent:HasScepter() then				
				target:AddNewModifier(parent, self, "modifier_item_blast_staff_debuff", {duration = duration})
			end
			ApplyDamage({
				ability = self,
				attacker = parent,
				damage = damage,
				damage_type = self:GetAbilityDamageType(),
				victim = target
			})
		end
	end
end


modifier_item_blast_staff3 = class({})
function modifier_item_blast_staff3:IsHidden() return true end
function modifier_item_blast_staff3:IsPurgable() return false end
function modifier_item_blast_staff3:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
if IsServer() then
	function modifier_item_blast_staff3:OnCreated(keys)
		local parent = self:GetParent()
		if parent then
			parent:RemoveModifierByName("modifier_item_blast_staff3_proc")
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_blast_staff3_proc", {})
		end
	end
end
function modifier_item_blast_staff3:OnDestroy()
	if IsServer() then
		self:GetCaster():RemoveModifierByName("modifier_item_blast_staff3_proc")
	end
end
function modifier_item_blast_staff3:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
	}
end

function modifier_item_blast_staff3:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_agility") end
end
function modifier_item_blast_staff3:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
end
function modifier_item_blast_staff3:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_strength") end
end
function modifier_item_blast_staff3:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("spell_amp") end
end
function modifier_item_blast_staff3:GetModifierStatusResistance()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("status_resist") end
end	


modifier_item_blast_staff_debuff = class({})
function modifier_item_blast_staff_debuff:IsHidden() return false end
function modifier_item_blast_staff_debuff:IsDebuff() return true end
function modifier_item_blast_staff_debuff:IsPurgable() return false end
function modifier_item_blast_staff_debuff:GetTexture() return "blast_staff_3" end
function modifier_item_blast_staff_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end
function modifier_item_blast_staff_debuff:OnCreated()
	local caster = self:GetCaster()
	self.debuff_bonus = 0
	if caster:HasModifier("modifier_super_scepter") then
		if caster:HasModifier("modifier_marci_unleash_flurry") then
			self.debuff_bonus = -10
		end                                 
	end 
end	

function modifier_item_blast_staff_debuff:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("resist_reduc") + self.debuff_bonus end
end


modifier_item_blast_staff3_proc = class({})
function modifier_item_blast_staff3_proc:IsHidden() return true end
function modifier_item_blast_staff3_proc:IsPurgable() return false end
function modifier_item_blast_staff3_proc:RemoveOnDeath() return false end
function modifier_item_blast_staff3_proc:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

if IsServer() then
	function modifier_item_blast_staff3_proc:OnCreated()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
	end
	function modifier_item_blast_staff3_proc:OnAbilityFullyCast(keys)
		local used_ability = keys.ability
		local unit = keys.unit
		if used_ability:GetCooldownTime() <= 0 then return end
		if not used_ability:IsItem() and not used_ability:IsToggle() and unit == self.parent and used_ability ~= self:GetAbility() then
			local target = used_ability:GetCursorPosition()
			local direction = (target - self.parent:GetAbsOrigin()):Normalized()
			if target == Vector(0, 0, 0) or direction == Vector(0, 0, 0) then
				direction = self.parent:GetForwardVector()
			end
			local direction = (direction * Vector(1, 1, 0)):Normalized()
			local projTable = 
			{
				EffectName = "particles/custom/items/blast_staff/blast_staff_pssv.vpcf",
				Ability = self.ability,
				vSpawnOrigin = self.parent:GetAbsOrigin() + Vector(0, 0, 100),
				vVelocity = direction * 2100,
				fDistance = 1200 + self.parent:GetCastRangeBonus(),
				fStartRadius = 400,
				fEndRadius = 400,
				fExpireTime = GameRules:GetGameTime() + 5,
				Source = self.parent,
				bHasFrontalCone = false,
				bReplaceExisiting = false,
				bDeleteOnHit = true,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAGS_NONE,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO
			}
			local projID = ProjectileManager:CreateLinearProjectile(projTable)
			local ability_cd = math.ceil(used_ability:GetCooldown(used_ability:GetLevel()))
			--print(ability_cd .. " cd")
			if ability_cd > 3 then
				local extra_hits = math.ceil(ability_cd / 5)
				--print(extra_hits .. " extra hits")
				for hits = 1 , extra_hits do
					Timers:CreateTimer(math.random(2, 40) / 100, function()
						local projID = ProjectileManager:CreateLinearProjectile(projTable)
					end)
				end
			end
		end
	end
end

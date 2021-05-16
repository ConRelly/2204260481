
LinkLuaModifier("modifier_item_mjz_demon_talon", "items/item_mjz_demon_talon.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mjz_demon_talon_passive", "items/item_mjz_demon_talon.lua", LUA_MODIFIER_MOTION_NONE)


item_mjz_demon_talon = class({})

function item_mjz_demon_talon:GetIntrinsicModifierName()
    return "modifier_item_mjz_demon_talon"
end
function item_mjz_demon_talon:OnSpellStart()
	local caster = self:GetCaster()
	if self:GetAbilityName() == "item_mjz_greater_demon_talon" then
		local item = find_item(caster, "item_mjz_greater_demon_talon")
		local purchase_time = item:GetPurchaseTime()
		caster:RemoveItem(item)
		local item2 = caster:AddItemByName("item_mjz_magi_demon_talon")
		item2:SetPurchaseTime(purchase_time)
	elseif self:GetAbilityName() == "item_mjz_magi_demon_talon" then
		local item = find_item(caster, "item_mjz_magi_demon_talon")
		local purchase_time = item:GetPurchaseTime()
		caster:RemoveItem(item)
		local item2 = caster:AddItemByName("item_mjz_greater_demon_talon")
		item2:SetPurchaseTime(purchase_time)
	end

end

function item_mjz_demon_talon:OnUpgrade()
	local caster = self:GetCaster()
	if self:GetAbilityName() == "item_mjz_greater_demon_talon" then
		local item = find_item(caster, "item_mjz_greater_demon_talon")
		local purchase_time = item:GetPurchaseTime()
		caster:RemoveItem(item)
		local item2 = caster:AddItemByName("item_mjz_magi_demon_talon")
		item2:SetPurchaseTime(purchase_time)
	elseif self:GetAbilityName() == "item_mjz_magi_demon_talon" then
		local item = find_item(caster, "item_mjz_magi_demon_talon")
		local purchase_time = item:GetPurchaseTime()
		caster:RemoveItem(item)
		local item2 = caster:AddItemByName("item_mjz_greater_demon_talon")
		item2:SetPurchaseTime(purchase_time)
	end
	
end

---------------------------------------------------------------------

item_mjz_greater_demon_talon = class(item_mjz_demon_talon)
item_mjz_magi_demon_talon = class(item_mjz_demon_talon)

---------------------------------------------------------------------

modifier_item_mjz_demon_talon = class({})

function modifier_item_mjz_demon_talon:IsHidden() return true end
function modifier_item_mjz_demon_talon:IsPurgable() return false end

function modifier_item_mjz_demon_talon:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_mjz_demon_talon:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_item_mjz_demon_talon:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_regen")
end

function modifier_item_mjz_demon_talon:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end


function modifier_item_mjz_demon_talon:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

if IsServer() then
	function modifier_item_mjz_demon_talon:OnCreated()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.caster = self:GetCaster()
		self.pszScriptName = "modifier_item_mjz_demon_talon_passive"

		self:OnIntervalThink()
		self:StartIntervalThink(3)
	end
	function modifier_item_mjz_demon_talon:OnIntervalThink()
		if self.parent and IsValidEntity(self.parent) and self.parent:IsAlive() then
			if not self.parent:HasModifier(self.pszScriptName) then
				self.parent:AddNewModifier(self.caster, self.ability, self.pszScriptName, {})
			end
		end
	end
	function modifier_item_mjz_demon_talon:OnDestroy()
		if self.parent and IsValidEntity(self.parent) and self.parent:IsAlive() then
			self.parent:RemoveModifierByName(self.pszScriptName)
		end
	end
	
end

---------------------------------------------------------------------

modifier_item_mjz_demon_talon_passive = class({})

function modifier_item_mjz_demon_talon_passive:IsHidden() return true end
function modifier_item_mjz_demon_talon_passive:IsPurgable() return false end

if IsServer() then
	function modifier_item_mjz_demon_talon_passive:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_ATTACK,
		}
		return funcs
	end
	
	function modifier_item_mjz_demon_talon_passive:OnAttack(keys)
		if keys.attacker ~= self:GetParent() then return nil end
		if keys.target.IsBuilding == nil or keys.target:IsBuilding() then return false end
		-- if not self:GetParent():HasScepter() then return nil end
		-- if not self:GetParent():IsRangedAttacker() then return nil end
		-- if self:GetParent():PassivesDisabled() then return nil end
		-- if TargetIsFriendly(self:GetParent(), keys.target) then return nil end
		--if keys.target:IsMagicImmune() then return nil end
		-- if keys.target:IsPhantom() then return nil end
		if keys.target:GetTeamNumber() == self:GetParent():GetTeamNumber() then return nil end
		if not self:GetAbility() then return nil end

		local attacker = keys.attacker
		local target = keys.target
		local victim = target
		local ability = self:GetAbility()
		local proc_chance = ability:GetSpecialValueFor("proc_chance")
		local proc_damage = ability:GetSpecialValueFor("proc_damage")
		
		local bool = false 
		local physStack = ability:GetAbilityDamageType() == DAMAGE_TYPE_PHYSICAL
		local magStack = ability:GetAbilityDamageType() == DAMAGE_TYPE_MAGICAL

		
		if RollPercentage( proc_chance ) then
			bool = true
		end

		if bool then
			local damage = proc_damage
			if not attacker:IsRealHero() or attacker:IsInvulnerable() then
				damage = proc_damage / 2
			end
			-- PrintTable(keys)
			-- print("demon_talon: " .. tostring(damage))
			if physStack then
				ApplyDamage({
					ability = ability,
					attacker = attacker,
					damage = damage,
					damage_type = DAMAGE_TYPE_PHYSICAL,
					-- damage_flags = 16,	DOTA_DAMAGE_FLAG_REFLECTION
					victim = victim
				})
				local particle = ParticleManager:CreateParticle("particles/custom/demon_talon_custom.vpcf", PATTACH_ABSORIGIN_FOLLOW, victim)
				ParticleManager:ReleaseParticleIndex(particle)
			end
			if magStack then
				ApplyDamage({
					ability = ability,
					attacker = attacker,
					damage = damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					-- damage_flags = 16,	DOTA_DAMAGE_FLAG_REFLECTION
					victim = victim
				})
				local particle = ParticleManager:CreateParticle("particles/custom/magi_demon_talon_custom.vpcf",PATTACH_ABSORIGIN_FOLLOW, victim)
				ParticleManager:ReleaseParticleIndex(particle)
			end
		end

	end	

end

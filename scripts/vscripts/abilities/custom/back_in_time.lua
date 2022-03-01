LinkLuaModifier("modifier_back_in_time", "abilities/custom/back_in_time.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_back_in_time_buff", "abilities/custom/back_in_time.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_back_in_time_aura", "abilities/custom/back_in_time.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_back_in_time_aura_effect", "abilities/custom/back_in_time.lua", LUA_MODIFIER_MOTION_NONE)

back_in_time = class({})
function back_in_time:GetIntrinsicModifierName() return "modifier_back_in_time" end
function back_in_time:OnHeroCalculateStatBonus(params)
	if self:GetLevel() ~= 0 then return end
	local ability = self:GetCaster():FindAbilityByName("weaver_time_lapse")
	if not ability then return end
	if ability:GetLevel() ~= 0 then
		self:SetLevel(1)
	end
end

modifier_back_in_time = class({})
function modifier_back_in_time:IsHidden() return true end
function modifier_back_in_time:IsPurgable() return false end
function modifier_back_in_time:RemoveOnDeath() return false end
--function modifier_back_in_time:AllowIllusionDuplicate() return true end
function modifier_back_in_time:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end

function modifier_back_in_time:OnCreated()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_back_in_time_buff") then self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_back_in_time_buff", {}) end
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local modifier = "modifier_back_in_time_buff"
	local modifier2 = "modifier_back_in_time_aura"
	if parent:HasModifier(modifier) then
--		parent:AddNewModifier(parent, ability, modifier, {})
		local time = GameRules:GetGameTime() / 60
		if time > 1 then
			local mbuff = parent:FindModifierByName(modifier)	
			local stack = math.floor(time / 1.2)
			mbuff:SetStackCount(stack)
		end 
	end
	
	if parent:IsIllusion() or parent:HasModifier("modifier_arc_warden_tempest_double") then
		local mod1 = "modifier_back_in_time_buff"
		-- print("ilusion")
		local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
		if owner then			 
			if parent:HasModifier(mod1) then
				local modifier1 = parent:FindModifierByName(mod1)
				if owner:HasModifier(mod1) then
					local modifier2 = owner:FindModifierByName(mod1)
					modifier1:SetStackCount(modifier2:GetStackCount())
				end	
				--print("")
			end
		end
	end

	if not parent:HasModifier(modifier2) then
		parent:AddNewModifier(parent, ability, modifier2, {})
		--print("modif2 added")
	end
	if not parent:HasAbility("weaver_time_lapse") then
		parent:AddAbility("weaver_time_lapse")
	end		
	local lapse = parent:FindAbilityByName("weaver_time_lapse")
	if lapse and lapse:GetLevel() ~= 0 then return end
	lapse:SetLevel(1)
end

function modifier_back_in_time:OnDestroy()
	if IsServer() then
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local modifier = "modifier_back_in_time_aura"
		local modifier2 = "modifier_back_in_time_buff"
		--if parent:HasModifier("modifier_back_in_time_buff") then
		--	parent:RemoveModifierByName("modifier_back_in_time_buff")
		--end
		if parent:HasModifier(modifier) then
			local has_modifier = parent:FindModifierByName(modifier)
			if has_modifier then
				parent:RemoveModifierByName(modifier)
			end
		end
		if parent:HasModifier(modifier2) then
			local has_modifier2 = parent:FindModifierByName(modifier2)
			if has_modifier2 then
				parent:RemoveModifierByName(modifier2)
			end
		end		
	end
end

function modifier_back_in_time:DeclareFunctions()
	if not IsServer() then return nil end
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_back_in_time:OnTakeDamage(keys)
	if not IsServer() then return nil end
	local attacker = keys.attacker
	local unit = keys.unit
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if parent == unit and attacker ~= unit and ability:IsCooldownReady() and parent:GetHealth() < 500 then
		local lapse = parent:FindAbilityByName("weaver_time_lapse")
		if lapse and lapse:GetLevel() >= 1 then
			parent:SetCursorCastTarget(parent)
			lapse:OnSpellStart()
		else
			return nil
		end
		parent:SetHealth(600)
		local cooldown = ability:GetCooldown(ability:GetLevel()) * parent:GetCooldownReduction()
		if cooldown < 20 then
			cooldown = 20
		end
		ability:StartCooldown(cooldown)
		parent:SetHealth(parent:GetMaxHealth())
		local chance = GetTalentSpecialValueFor(ability, "stack_chance")
		local more_stacks = 1
		if parent:HasModifier("modifier_super_scepter") then
			if parent:HasModifier("modifier_marci_unleash_flurry") then
				more_stacks = 2
			end                                 
		end 		
		if RollPercentage(chance) then
			local modif_buff = "modifier_back_in_time_buff"
			local mbuff = parent:FindModifierByName(modif_buff)	
			if mbuff ~= nil then
				local stack_increase = ability:GetSpecialValueFor("stack_increase") / 100
				local nr_stacks = mbuff:GetStackCount()
				local increase_stak = math.ceil(nr_stacks +(nr_stacks * stack_increase) + more_stacks)
				--print(increase_stak .. " extra stacks")
				mbuff:SetStackCount(increase_stak)
			end 
		end				
	end
end


modifier_back_in_time_buff = class({})
function modifier_back_in_time_buff:IsHidden() return self:GetAbility() == nil end
function modifier_back_in_time_buff:IsPurgable() return false end
function modifier_back_in_time_buff:RemoveOnDeath() return false end
function modifier_back_in_time_buff:GetTexture() return "back_in_time" end
function modifier_back_in_time_buff:AllowIllusionDuplicate() return true end
function modifier_back_in_time_buff:OnCreated() if not IsServer() then return end end
function modifier_back_in_time_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end

function modifier_back_in_time_buff:GetModifierPreAttack_CriticalStrike()
	if not IsServer() then return nil end
	local crit_chance = self:GetAbility():GetSpecialValueFor("crit_chance")
	local crit_bonus = 100 + self:GetStackCount() * self:GetAbility():GetSpecialValueFor("crit_stack")
	if RollPercentage(crit_chance) then
		return crit_bonus
	end
end
function modifier_back_in_time_buff:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("str_stack") end
end

function modifier_back_in_time_buff:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("agi_stack") end
end	

function modifier_back_in_time_buff:GetModifierEvasion_Constant()
	local evasion = math.ceil(self:GetStackCount() * self:GetAbility():GetSpecialValueFor("evasion_stack"))
	if evasion < 20 then
		evasion = 20
	elseif evasion > 80 then
		evasion = 80
	end
	if self:GetAbility() then return evasion end
end	

function modifier_back_in_time_buff:GetModifierHealthBonus()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("hp_stack") end
end 

function modifier_back_in_time_buff:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("ms_stack") end
end


modifier_back_in_time_aura = class({})
local modifier_class = modifier_back_in_time_aura
function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end
function modifier_class:RemoveOnDeath() return false end
function modifier_class:OnCreated()
	if IsServer() then if not self:GetAbility() then if not self:IsNull() then self:Destroy() end end end
end
function modifier_class:IsAura() return true end
function modifier_class:GetModifierAura() return "modifier_back_in_time_aura_effect" end
function modifier_class:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_class:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_class:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end
function modifier_class:GetAuraRadius()
	-- return self:GetAbility():GetSpecialValueFor("radius") + self:GetParent():GetCastRangeBonus()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("aoe") end
end


modifier_back_in_time_aura_effect = class({})
local modifier_effect2 = modifier_back_in_time_aura_effect

function modifier_effect2:IsHidden() return false end
function modifier_effect2:IsPurgable() return false end
function modifier_effect2:IsDebuff() return true end
function modifier_effect2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_effect2:OnCreated(table)
	if IsServer() then
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local interval = ability:GetSpecialValueFor("interval")
		self:StartIntervalThink(interval)
	end 
end

function modifier_effect2:OnIntervalThink()
	if IsServer() then
		--if not self:_Enabled() then return nil end

		--local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local target = self:GetParent()
		local lvl = caster:GetLevel()
		if ability and IsValidEntity(ability) then
			local interval = ability:GetSpecialValueFor("interval")
			local base_damage = ability:GetSpecialValueFor("base_damage") * lvl
			if lvl < 29 then
				base_damage = base_damage / 4
			end	
			local modif_buff = "modifier_back_in_time_buff"
			local mbuff = caster:FindModifierByName(modif_buff)	
			local nr_stacks = mbuff:GetStackCount()
			local damage = base_damage * nr_stacks
			if damage == 0 then return nil end
			damage = damage * interval

			ApplyDamage({
				attacker = caster,
				victim = target,
				ability = ability,
				damage_type = ability:GetAbilityDamageType(),
				damage = damage
			})
		end	
	end
end	


-- talent
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

LinkLuaModifier("modifier_mjz_necrolyte_reapers_scythe","abilities/hero_necrolyte/mjz_necrolyte_reapers_scythe.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_necrolyte_reapers_scythe_stun","abilities/hero_necrolyte/mjz_necrolyte_reapers_scythe.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_necrolyte_reapers_scythe_self","abilities/hero_necrolyte/mjz_necrolyte_reapers_scythe.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_necrolyte_reapers_scythe_ss_stacks","abilities/hero_necrolyte/mjz_necrolyte_reapers_scythe.lua", LUA_MODIFIER_MOTION_NONE)
--hr aura
LinkLuaModifier("modifier_mjz_necrolyte_heartstopper_aura_counter","abilities/hero_necrolyte/mjz_necrolyte_heartstopper_aura.lua", LUA_MODIFIER_MOTION_NONE)


mjz_necrolyte_reapers_scythe = class({})
local ability_class = mjz_necrolyte_reapers_scythe


function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('radius')
end
function ability_class:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor('radius')
end
function ability_class:GetBehavior()
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	else
		return self.BaseClass.GetBehavior(self)
	end
end

function ability_class:GetCooldown(iLevel)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor('cooldown_scepter')
	end
	return self:GetSpecialValueFor('cooldown')
end
--create an innate modifier for ability_class
function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_necrolyte_reapers_scythe_self"
end
modifier_mjz_necrolyte_reapers_scythe_self = class({})	
function modifier_mjz_necrolyte_reapers_scythe_self:IsHidden() return true end
function modifier_mjz_necrolyte_reapers_scythe_self:IsPurgable() return false end

function modifier_mjz_necrolyte_reapers_scythe_self:OnCreated()
	if IsServer() then
		self:StartIntervalThink(6)  
	end
end


function modifier_mjz_necrolyte_reapers_scythe_self:OnIntervalThink()
	if IsServer() then
		if self:GetAbility() == nil then return end
		local ability = self:GetAbility()
		local autocast = self:GetAbility():GetAutoCastState()
		if autocast then
			local caster = self:GetCaster()
			if not caster:IsAlive() then return end
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor('radius') + caster:GetCastRangeBonus(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			--add limit of max 3 enemies for autocast
			local count = 0
			for _, enemy in pairs(enemies) do
				if not enemy:HasModifier('modifier_mjz_necrolyte_reapers_scythe') then
					if count < 3 then	
						ability:OnSpellStart_Super_Scepter(enemy)
						count = count + 1
					else
						break
					end
				end
			end
			local timer = ability:GetSpecialValueFor('cooldown_Super_scepter') * self:GetCaster():GetCooldownReduction()
			if not caster:HasModifier("modifier_super_scepter") then timer = 12 end
			self:StartIntervalThink(timer) 
		end	
	end
end



if IsServer() then
	function ability_class:OnSpellStart()
		local caster = self:GetCaster()
		local ability = self
		local target = self:GetCursorTarget()
		local stun_duration = ability:GetSpecialValueFor("stun_duration")

		target:AddNewModifier(caster, ability, 'modifier_mjz_necrolyte_reapers_scythe', {})
		target:AddNewModifier(caster, ability, 'modifier_mjz_necrolyte_reapers_scythe_stun', {duration = stun_duration})

		local hr_stoper_aura = caster:HasAbility("mjz_necrolyte_heartstopper_aura")
		local shard = caster:HasModifier("modifier_item_aghanims_shard")
		if hr_stoper_aura and shard then
			local hr_ability = caster:FindAbilityByName("mjz_necrolyte_heartstopper_aura")
			caster:AddNewModifier(caster, hr_ability, "modifier_mjz_necrolyte_heartstopper_aura_counter", {})
		end
		local has_ss = caster:HasModifier("modifier_super_scepter")
		if has_ss then
			if caster:HasModifier("modifier_mjz_necrolyte_reapers_scythe_ss_stacks") then
				caster:FindModifierByName("modifier_mjz_necrolyte_reapers_scythe_ss_stacks"):IncrementStackCount()
			else
				caster:AddNewModifier(caster, ability, "modifier_mjz_necrolyte_reapers_scythe_ss_stacks", {})
			end
		end			
		EmitSoundOn("Hero_Necrolyte.ReapersScythe.Cast", caster)
		EmitSoundOn("Hero_Necrolyte.ReapersScythe.Target", target)

	end
	function ability_class:OnSpellStart_Super_Scepter(enemy)
		local caster = self:GetCaster()
		local ability = self
		local target = enemy
		local stun_duration = ability:GetSpecialValueFor("stun_duration") / 2

		target:AddNewModifier(caster, ability, 'modifier_mjz_necrolyte_reapers_scythe', {})
		target:AddNewModifier(caster, ability, 'modifier_mjz_necrolyte_reapers_scythe_stun', {duration = stun_duration})
		--if caster has ability mjz_necrolyte_heartstopper_aura 
		local hr_stoper_aura = caster:HasAbility("mjz_necrolyte_heartstopper_aura")
		local shard = caster:HasModifier("modifier_item_aghanims_shard")
		if hr_stoper_aura and shard then
			local hr_ability = caster:FindAbilityByName("mjz_necrolyte_heartstopper_aura")
			caster:AddNewModifier(caster, hr_ability, "modifier_mjz_necrolyte_heartstopper_aura_counter", {})
		end
		caster:EmitSoundParams("Hero_Necrolyte.ReapersScythe.Cast", 0, 0.2, 0)
		target:EmitSoundParams("Hero_Necrolyte.ReapersScythe.Target", 0, 0.2, 0)
		local has_ss = caster:HasModifier("modifier_super_scepter")
		--if has_ss then -- makes so that temp ss works even after expiring
		if caster:HasModifier("modifier_mjz_necrolyte_reapers_scythe_ss_stacks") then
			caster:FindModifierByName("modifier_mjz_necrolyte_reapers_scythe_ss_stacks"):IncrementStackCount()
		else
			caster:AddNewModifier(caster, ability, "modifier_mjz_necrolyte_reapers_scythe_ss_stacks", {})
		end
		--end	
	end	
end

-----------------------------------------------------------------------------------------
--stacks modifier
modifier_mjz_necrolyte_reapers_scythe_ss_stacks = class({})


function modifier_mjz_necrolyte_reapers_scythe_ss_stacks:IsHidden() return false end
function modifier_mjz_necrolyte_reapers_scythe_ss_stacks:IsPurgable() return false end
function modifier_mjz_necrolyte_reapers_scythe_ss_stacks:RemoveOnDeath() return false end
function modifier_mjz_necrolyte_reapers_scythe_ss_stacks:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_TOOLTIP, MODIFIER_PROPERTY_TOOLTIP2}
end
function modifier_mjz_necrolyte_reapers_scythe_ss_stacks:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetStackCount() * 10 end
end
function modifier_mjz_necrolyte_reapers_scythe_ss_stacks:OnTooltip()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("ss_bonus_damage") * self:GetParent():GetLevel() end
end
function modifier_mjz_necrolyte_reapers_scythe_ss_stacks:OnTooltip2()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("ss_bonus_damage_lvl_mult") * self:GetParent():GetLevel() end
end		
------------
modifier_mjz_necrolyte_reapers_scythe = class({})
local modifier_class = modifier_mjz_necrolyte_reapers_scythe

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end
function modifier_class:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end


function modifier_class:GetEffectName()
	-- return "particles/units/heroes/hero_necrolyte/necrolyte_scythe.vpcf"
	return "particles/econ/items/necrolyte/necro_sullen_harvest/necro_ti7_immortal_scythe.vpcf"	
end
function modifier_class:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_class:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end
function modifier_class:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

if IsServer() then
	function modifier_class:OnCreated(table)
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local stun_duration = ability:GetSpecialValueFor("stun_duration")

		self:_FireEffect_Start()
		self:_FireEffect_Orig()

		self:StartIntervalThink(stun_duration)
	end

	function modifier_class:OnIntervalThink()
		self:StartIntervalThink(-1)
		self:_ApplyDamage()
		if self:IsNull() then return end
		self:Destroy()
	end

	function modifier_class:_FireEffect_Start( )
		local caster = self:GetCaster()
		local target = self:GetParent()

		local p_name_start = "particles/units/heroes/hero_necrolyte/necrolyte_scythe_start.vpcf"
		local p_name_start_sullen_harvest = "particles/econ/items/necrolyte/necro_sullen_harvest/necro_ti7_immortal_scythe_start.vpcf"
		local scythe_fx = ParticleManager:CreateParticle(p_name_start_sullen_harvest, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(scythe_fx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(scythe_fx, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:DestroyParticle(scythe_fx, false)
		ParticleManager:ReleaseParticleIndex(scythe_fx)
	end

	function modifier_class:_FireEffect_Orig( )
		local caster = self:GetCaster()
		local p_name = "particles/units/heroes/hero_necrolyte/necrolyte_scythe_orig.vpcf"
		local orig_fx = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, caster)
		self:AddParticle(orig_fx, false, false, -1, false, false)
	end

	function modifier_class:_ApplyDamage( )
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility()
		local health_divide = ability:GetSpecialValueFor("health_divide_dmg")
		local extra_dmg = ((-1 * (target:GetHealthPercent() - 100)) / health_divide) + 1
		--print(extra_dmg .. " dmg mult")
		local base_damage = ability:GetSpecialValueFor("base_damage")
		if caster:HasModifier("modifier_mjz_necrolyte_reapers_scythe_ss_stacks") then
			local caster = parent:FindModifierByName("modifier_mjz_necrolyte_reapers_scythe_ss_stacks")
			if modif then
				local ss_bonus_damage =  modif:GetStackCount() * modif:GetAbility():GetSpecialValueFor("ss_bonus_damage_lvl_mult") * caster:GetLevel()
				base_damage = base_damage + ss_bonus_damage
				print(ss_bonus_damage .. " Reaper ss_bonus_damage")
			end
		end	
		local int_damage_multiplier = ability:GetSpecialValueFor("int_damage_multiplier")
		local damage = (base_damage + caster:GetIntellect(true) * int_damage_multiplier) * extra_dmg
		local fdamage = damage / 2
		Timers:CreateTimer({
			endTime = 0.05, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
			callback = function()
				if not target or target:IsNull() then return end
				ApplyDamage({
					attacker = caster,
					victim = target,
					ability = ability,
					damage = fdamage,
					damage_type = ability:GetAbilityDamageType(),
				})				
			end
		})		
		ApplyDamage({
			attacker = caster,
			victim = target,
			ability = ability,
			damage = fdamage,
			damage_type = ability:GetAbilityDamageType(),
		})
	end
end

-----------------------------------------------------------------------------------------

modifier_mjz_necrolyte_reapers_scythe_stun = class({})
local modifier_stun = modifier_mjz_necrolyte_reapers_scythe_stun

function modifier_stun:IsHidden() return true end
function modifier_stun:IsPurgable() return false end
function modifier_stun:IsDebuff() return false end

function modifier_stun:CheckState()
	if self:GetParent().bAbsoluteNoCC then return end
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end

function modifier_stun:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end
function modifier_stun:GetOverrideAnimation( )
	return ACT_DOTA_DISABLED
end

function modifier_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end
function modifier_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
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


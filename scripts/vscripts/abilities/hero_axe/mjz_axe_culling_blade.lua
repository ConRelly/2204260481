LinkLuaModifier("modifier_mjz_axe_culling_blade_checker","abilities/hero_axe/mjz_axe_culling_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_axe_culling_blade_boost","abilities/hero_axe/mjz_axe_culling_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_culling_blade_stacks","abilities/hero_axe/mjz_axe_culling_blade", LUA_MODIFIER_MOTION_NONE)


mjz_axe_culling_blade = class({})
function mjz_axe_culling_blade:GetIntrinsicModifierName() return "modifier_culling_blade_stacks" end
function mjz_axe_culling_blade:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end
function mjz_axe_culling_blade:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor('splash_radius_scepter')
	end
	return self:GetSpecialValueFor('cast_range')
end
function mjz_axe_culling_blade:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor('cast_range') end
if IsServer() then
	function mjz_axe_culling_blade:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local base_damage = self:GetSpecialValueFor("base_damage")
		local str_damage_multiplier = self:GetSpecialValueFor("str_damage_multiplier")
		local splash_radius_scepter = self:GetSpecialValueFor("splash_radius_scepter")
		local damage = base_damage + caster:GetStrength() * str_damage_multiplier

		if target:TriggerSpellAbsorb(self) then return end

		local success_effect = false

		if caster:HasScepter() then
			enemies = FindTargetEnemy(caster, target:GetAbsOrigin(), splash_radius_scepter)
		else
			enemies = {target}
		end

		for _,enemy in pairs(enemies) do
			local checker = enemy:AddNewModifier(caster, self, 'modifier_mjz_axe_culling_blade_checker', {})

			ApplyDamage({
				attacker = caster,
				victim = enemy,
				ability = self,
				damage = damage,
				damage_type = self:GetAbilityDamageType(),
			})
			self:PlayEffect(enemy)

			if checker.success and not success_effect then
				local culling_kill_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(culling_kill_particle, 4, target:GetAbsOrigin())
				ParticleManager:DestroyParticle(culling_kill_particle, false)
				ParticleManager:ReleaseParticleIndex(culling_kill_particle)
				success_effect = true
			end

			enemy:RemoveModifierByName('modifier_mjz_axe_culling_blade_checker')
		end
	end

	function mjz_axe_culling_blade:OnCullingBladeSuccess(target)
		local caster = self:GetCaster()
		local speed_radius = self:GetSpecialValueFor("speed_radius")
		local speed_duration = self:GetSpecialValueFor("speed_duration")

		EmitSoundOn("Hero_Axe.Culling_Blade_Success", caster)

		local unit_list = FindTargetFriendly(caster, target:GetAbsOrigin(), speed_radius)
		for _,unit in pairs(unit_list) do
			unit:AddNewModifier(caster, self, "modifier_mjz_axe_culling_blade_boost", {duration = speed_duration})
		end

		caster:AddNewModifier(caster, self, "modifier_culling_blade_stacks", {})
		if caster:HasModifier("modifier_super_scepter") then
			self:EndCooldown()
		end
	end

	function mjz_axe_culling_blade:OnCullingBladeFail(target)
		EmitSoundOn("Hero_Axe.Culling_Blade_Fail", self:GetCaster())
	end

	function mjz_axe_culling_blade:PlayEffect(target)
		local caster = self:GetCaster()

		local p_name = "particles/units/heroes/hero_axe/axe_culling_blade.vpcf"
		local nFXIndex = ParticleManager:CreateParticle( p_name, PATTACH_CUSTOMORIGIN, target );
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true );
		ParticleManager:DestroyParticle(nFXIndex, false)
		ParticleManager:ReleaseParticleIndex( nFXIndex );
	end
end

-----------------------------------------------------------------------------------------

modifier_mjz_axe_culling_blade_checker = class({})
function modifier_mjz_axe_culling_blade_checker:IsHidden() return true end
function modifier_mjz_axe_culling_blade_checker:IsPurgable() return false end
function modifier_mjz_axe_culling_blade_checker:IsDebuff() return false end
function modifier_mjz_axe_culling_blade_checker:IsBuff() return false end
if IsServer() then
	function modifier_mjz_axe_culling_blade_checker:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end
	function modifier_mjz_axe_culling_blade_checker:OnDeath()
		self.success = true
		self:GetAbility():OnCullingBladeSuccess(self:GetParent())
		if self:IsNull() then return end
		self:Destroy()
	end
	function modifier_mjz_axe_culling_blade_checker:OnCreated(table) self.success = false end
	function modifier_mjz_axe_culling_blade_checker:OnDestroy()
		if self.success == false then
			self:GetAbility():OnCullingBladeFail(self:GetParent())
		end
	end
end

-----------------------------------------------------------------------------------------

modifier_mjz_axe_culling_blade_boost = class({})
function modifier_mjz_axe_culling_blade_boost:IsHidden() return false end
function modifier_mjz_axe_culling_blade_boost:IsPurgable() return true end
function modifier_mjz_axe_culling_blade_boost:IsBuff() return true end

function modifier_mjz_axe_culling_blade_boost:GetEffectName() return "particles/units/heroes/hero_axe/axe_cullingblade_sprint.vpcf" end
function modifier_mjz_axe_culling_blade_boost:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_mjz_axe_culling_blade_boost:DeclareFunctions()
	return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_mjz_axe_culling_blade_boost:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor('attack_speed_bonus')
end

function modifier_mjz_axe_culling_blade_boost:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor('move_speed_bonus')
end
if IsServer() then
	function modifier_mjz_axe_culling_blade_boost:OnCreated(table)
		local parent = self:GetParent()
		local p_name = "particles/units/heroes/hero_axe/axe_culling_blade_boost.vpcf"
		local p_boost = ParticleManager:CreateParticle(p_name, PATTACH_CUSTOMORIGIN, parent)
		ParticleManager:DestroyParticle(p_boost, false)
		ParticleManager:ReleaseParticleIndex(p_boost)
	end
end

-----------------------------------------------------------------------------------------

modifier_culling_blade_stacks = class({})
function modifier_culling_blade_stacks:IsHidden() return (self:GetStackCount() < 1) end
function modifier_culling_blade_stacks:IsPurgable() return false end
function modifier_culling_blade_stacks:RemoveOnDeath() return false end
function modifier_culling_blade_stacks:OnCreated()
	self.armor_per_kill = self:GetAbility():GetSpecialValueFor("armor_per_kill")
--	self:SetStackCount(1)
end
function modifier_culling_blade_stacks:OnRefresh()
	self:SetStackCount(self:GetStackCount() + 1)
end
function modifier_culling_blade_stacks:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_culling_blade_stacks:GetModifierPhysicalArmorBonus()
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		return self:GetStackCount() * self.armor_per_kill
	end
end

-----------------------------------------------------------------------------------------


-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(caster, point, radius)
	local iTeamNumber = caster:GetTeamNumber()
	local vPosition = point 				-- 搜索中心点
	local hCacheUnit = nil                  -- 通常值
	local flRadius = radius                 -- 搜索范围
	local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
	-- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
	local iFlagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES     -- 无视魔法免疫
	local iOrder = FIND_CLOSEST                         -- 寻找最近的
	local bCanGrowCache = false             -- 通常值
	return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
		flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
end

-- 搜索目标位置所有的友方单位
function FindTargetFriendly(caster, point, radius)
	local iTeamNumber = caster:GetTeamNumber()
	local vPosition = point 				-- 搜索中心点
	local hCacheUnit = nil                  -- 通常值
	local flRadius = radius                 -- 搜索范围
	local iTeamFilter = DOTA_UNIT_TARGET_TEAM_FRIENDLY  -- 目标是友方单位
	-- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
	local iFlagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES     -- 无视魔法免疫
	local iOrder = FIND_CLOSEST                         -- 寻找最近的
	local bCanGrowCache = false             -- 通常值
	return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
		flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
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


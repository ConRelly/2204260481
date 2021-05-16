
local THIS_LUA = "abilities/hero_medusa/mjz_medusa_mana_snake.lua"

LinkLuaModifier("modifier_mjz_medusa_mana_snake", THIS_LUA, LUA_MODIFIER_MOTION_NONE)


mjz_medusa_mana_snake = class({})
local ability_class = mjz_medusa_mana_snake

function ability_class:GetIntrinsicModifierName()
	return 'modifier_mjz_medusa_mana_snake'
end

---------------------------------------------------------------------------------------

modifier_mjz_medusa_mana_snake = class({})
local modifier_class = modifier_mjz_medusa_mana_snake

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end


if IsServer() then

	function modifier_class:DeclareFunctions()
		local funcs = {
			-- MODIFIER_EVENT_ON_ATTACK,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
		}
		return funcs
	end

	function modifier_class:OnAttack(keys)
		
	end

    function modifier_class:OnAttackLanded(keys)
		self:_ManaSteal(keys.attacker, keys.target, keys.damage)
	end

	function modifier_class:_ManaSteal( attacker, target, damage)
		if attacker ~= self:GetParent() then return nil end
		if attacker:PassivesDisabled() then return nil end

		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local mana_steal = ability:GetSpecialValueFor('mana_steal')

		if ability:IsCooldownReady() then
			if self:_IsEnemy(target) then
				local p_name = "particles/custom/mjz_manasteal.vpcf"
				local particle = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, parent)
				ParticleManager:ReleaseParticleIndex(particle)

				local mana_gain = damage * (mana_steal / 100.0)
				parent:GiveMana(mana_gain)
			end
		end
	end

	function modifier_class:_IsEnemy(target)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local nTargetTeam = ability:GetAbilityTargetTeam()
		local nTargetType = ability:GetAbilityTargetType()
		local nTargetFlags = ability:GetAbilityTargetFlags()
		local nTeam = caster:GetTeamNumber()
		local ufResult = UnitFilter(target, nTargetTeam, nTargetType, nTargetFlags, nTeam)
		return ufResult == UF_SUCCESS
	end

end



---------------------------------------------------------------------------------------------------------------

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

-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(unit, point, radius)
    local iTeamNumber = unit:GetTeamNumber()
    local vPosition = point   				-- 搜索中心点
    local hCacheUnit = nil                  -- 通常值
    local flRadius = radius                 -- 搜索范围
    local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
    -- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP           
	-- 仅针对可见的单位、忽视建筑物、支持魔法免疫
    local iFlagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE   
    local iOrder = FIND_CLOSEST                         -- 寻找最近的
    local bCanGrowCache = false             -- 通常值
    return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
        flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
end

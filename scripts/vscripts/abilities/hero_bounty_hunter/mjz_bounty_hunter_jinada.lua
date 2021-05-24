LinkLuaModifier("modifier_mjz_bounty_hunter_jinada", "abilities/hero_bounty_hunter/mjz_bounty_hunter_jinada.lua", LUA_MODIFIER_MOTION_NONE)

mjz_bounty_hunter_jinada = class({})
local ability_class = mjz_bounty_hunter_jinada

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_bounty_hunter_jinada"
end

function ability_class:GetCooldown(iLevel)
    return self:GetSpecialValueFor("cooldown")
    -- return self.BaseClass.GetCooldown(self, iLevel)
end

---------------------------------------------------------------------------------------

modifier_mjz_bounty_hunter_jinada = class({})
local modifier_class = modifier_mjz_bounty_hunter_jinada

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_START,			-- 当拥有modifier的单位开始攻击某个目标
		MODIFIER_EVENT_ON_ATTACK_LANDED,		-- 当拥有modifier的单位攻击到某个目标时
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
	if IsServer() then
		return funcs
	else
		return {
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		}
	end
end

function modifier_class:GetModifierPreAttack_BonusDamage(  )
	return self:GetStackCount()
end

if IsServer() then	

	function modifier_class:OnAttackStart( keys )
		self:_Update_BonusDamage()
	end

	function modifier_class:OnAttackLanded(keys)
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local attacker = keys.attacker
	
		if attacker == self:GetParent() then
			local target = keys.target
			
			if ability:IsCooldownReady() then
				local gold_steal = GetTalentSpecialValueFor(ability, 'gold_steal')
				local cooldown = GetTalentSpecialValueFor(ability, 'cooldown')
				
				if self:_Can_Gold_Steal(attacker, target) then
					local iGoldChange = gold_steal
					local bReliable = false
					local iReason = DOTA_ModifyGold_Unspecified
					attacker:ModifyGold(iGoldChange, bReliable, iReason)
				end

				ability:StartCooldown(cooldown)
				attacker:EmitSound('Hero_BountyHunter.Jinada')

				self:_Update_BonusDamage()
			end
		end
	end

	function modifier_class:_Update_BonusDamage( )
		local parent = self:GetParent()
		local ability = self:GetAbility()

		local bonus_damage = 0
		if ability:IsCooldownReady() then
			bonus_damage = ability:GetSpecialValueFor('bonus_damage')
		end
		if self:GetStackCount() ~= bonus_damage then
			self:SetStackCount(bonus_damage)
		end
	end

	function modifier_class:_Can_Gold_Steal(attacker, target)
		if not attacker:IsIllusion() and 
		   not target:IsBuilding() and 
		   not target:IsTower() and 
		   (attacker:GetTeam() ~= target:GetTeam())
		then
			if target:IsHero() or target:IsCreature() then
				return true
			end
		end
		return false
	end

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
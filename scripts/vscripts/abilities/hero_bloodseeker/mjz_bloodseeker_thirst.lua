
local THIS_LUA = "abilities/hero_bloodseeker/mjz_bloodseeker_thirst.lua"
LinkLuaModifier("modifier_mjz_bloodseeker_thirst", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_bloodseeker_thirst_buff", THIS_LUA, LUA_MODIFIER_MOTION_NONE)


mjz_bloodseeker_thirst = class({})
local ability_class = mjz_bloodseeker_thirst


function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_bloodseeker_thirst"
end

------------------------------------------------------------------------------------

modifier_mjz_bloodseeker_thirst = class({})
local modifier_class = modifier_mjz_bloodseeker_thirst

function modifier_class:IsHidden() return true end
function modifier_class:IsPassive() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
    function modifier_class:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end

    function modifier_class:OnCreated(table)
        local ability = self:GetAbility()
        self.attack_count = 0
        self.attack_stack_per = 10
        self.prev_attack_time = 0
        local duration = ability:GetSpecialValueFor('duration')
        local max_stacks = GetTalentSpecialValueFor(ability, 'max_stacks')
        self.max_attack_count = max_stacks * self.attack_stack_per

        self:UpdateStackCount()
        self:StartIntervalThink(duration)
    end

    function modifier_class:OnIntervalThink()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local duration = ability:GetSpecialValueFor('duration')        
        local now_time = GameRules:GetGameTime()
        if now_time > (self.prev_attack_time + duration) then
            self.attack_count = self.attack_count - self.attack_stack_per
        end

        self:UpdateStackCount()
    end

    function modifier_class:OnAttackLanded(keys)
        if keys.attacker ~= self:GetParent() then return nil end

        local caster = self:GetCaster()
        local parent = self:GetParent()
		local ability = self:GetAbility()
        local attacker = keys.attacker
        local target = keys.target
		
		if parent:PassivesDisabled() then return nil end

        self.prev_attack_time = GameRules:GetGameTime()
        self.attack_count = self.attack_count + 1

        self:UpdateStackCount()
    end

    function modifier_class:UpdateStackCount( )
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local modifier_buff_name = 'modifier_mjz_bloodseeker_thirst_buff'   
        local duration = ability:GetSpecialValueFor('duration')        
        local max_stacks = GetTalentSpecialValueFor(ability, 'max_stacks')
        self.max_attack_count = max_stacks * self.attack_stack_per

        if self.attack_count < 0 then
            self.attack_count = 0
        end
        if self.attack_count > self.max_attack_count then
            self.attack_count = self.max_attack_count
        end

        local stacks = self.attack_count / self.attack_stack_per

        if not parent:HasModifier(modifier_buff_name) then
            parent:AddNewModifier(caster, ability, modifier_buff_name, {})
        end

        local modifier = parent:FindModifierByName(modifier_buff_name)
        if modifier:GetStackCount() ~= math.ceil( stacks ) then
            modifier:SetStackCount(stacks)
        end
    end

end


------------------------------------------------------------------------------------

modifier_mjz_bloodseeker_thirst_buff = class({})
local modifier_buff = modifier_mjz_bloodseeker_thirst_buff

function modifier_buff:IsHidden() return false end
function modifier_buff:IsPurgable() return false end


function modifier_buff:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_thirst_owner.vpcf"
end


function modifier_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_buff:GetModifierMoveSpeedBonus_Percentage( )
    local base = self:GetAbility():GetSpecialValueFor('bonus_movement_speed')
    return base * self:GetStackCount()
end

function modifier_buff:GetModifierAttackSpeedBonus_Constant( )
    local base = self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
    return base * self:GetStackCount()
end

function modifier_buff:GetModifierPreAttack_BonusDamage( )
    local base = self:GetAbility():GetSpecialValueFor('bonus_damage')
    return base * self:GetStackCount()
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
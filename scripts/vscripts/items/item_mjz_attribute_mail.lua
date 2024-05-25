LinkLuaModifier("modifier_item_mjz_attribute_mail", "items/item_mjz_attribute_mail.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mjz_attribute_mail_passive", "items/item_mjz_attribute_mail.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mjz_attribute_mail_buff", "items/item_mjz_attribute_mail.lua", LUA_MODIFIER_MOTION_NONE)


item_mjz_attribute_mail = class({})

function item_mjz_attribute_mail:GetIntrinsicModifierName()
    if IsServer() then
        if not self:GetCaster():HasModifier("modifier_item_mjz_attribute_mail_passive") then
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_mjz_attribute_mail_passive", {})
        end
    end
    return "modifier_item_mjz_attribute_mail"
end

function item_mjz_attribute_mail:OnSpellStart()
    local caster = self:GetCaster()

    caster:EmitSound("Item.CrimsonGuard.Cast")
    local modif = "modifier_item_formidable_chest_buff"
    local units = FindUnitsInRadius(
        caster:GetTeam(), 
        caster:GetAbsOrigin(), 
        nil, 
        self:GetSpecialValueFor("radius"), 
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
        0, 
        0, 
        false
    )
    local duration = self:GetSpecialValueFor("duration")
    for _, unit in ipairs(units) do
        if self:CanAddBuff(unit) then
            if not unit:HasModifier(modif) then
                unit:AddNewModifier(caster, self, "modifier_item_mjz_attribute_mail_buff", {
                    duration = duration
                })
            end    
        end
    end

end

function item_mjz_attribute_mail:CanAddBuff( unit )
    if unit and IsValidEntity(unit) and unit:IsAlive() then
        if not unit:HasModifier("modifier_item_formidable_chest_buff") and not unit:HasModifier("modifier_sumon_bonus") and not unit:HasModifier("modifier_bear_bonus") then
            return true
        end
    end
    return false
end

------------------------------------------------------------------------------------------

modifier_item_mjz_attribute_mail = class({})

function modifier_item_mjz_attribute_mail:IsHidden() return true end
function modifier_item_mjz_attribute_mail:IsPurgable() return false end

function modifier_item_mjz_attribute_mail:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_mjz_attribute_mail:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,

    }
end

function modifier_item_mjz_attribute_mail:GetModifierPhysicalArmorBonus()
    if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_armor") end
end
function modifier_item_mjz_attribute_mail:GetModifierExtraHealthPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health") end
end
function modifier_item_mjz_attribute_mail:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_strength") end
end
function modifier_item_mjz_attribute_mail:GetModifierHealthRegenPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("hp_regen_pct") end
end

------------------------------------------------------------------------------------------

modifier_item_mjz_attribute_mail_buff = class({})

function modifier_item_mjz_attribute_mail_buff:GetTexture()
    return "item_mjz_attribute_mail"
end

function modifier_item_mjz_attribute_mail_buff:GetEffectName()
    return "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf"
end

function modifier_item_mjz_attribute_mail_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end

function modifier_item_mjz_attribute_mail_buff:GetModifierIncomingDamage_Percentage()
    local ability = self:GetAbility()
    if ability then
        return ability:GetSpecialValueFor("damage_reduction")
    end
end

------------------------------------------------------------------------------------------


modifier_item_mjz_attribute_mail_passive = class({})

function modifier_item_mjz_attribute_mail_passive:IsHidden() return true end
function modifier_item_mjz_attribute_mail_passive:IsPurgable() return false end

if IsServer() then
	function modifier_item_mjz_attribute_mail_passive:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_ATTACKED,
		}
	end

	function modifier_item_mjz_attribute_mail_passive:OnAttacked(event)
		local target = event.target
		local attacker = event.attacker
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local caster = self:GetCaster()
        
		if target ~= parent then return nil end
		if attacker:GetTeamNumber() == parent:GetTeamNumber() then return nil end
		if parent:IsIllusion() then return nil end
		if caster:IsIllusion() then return nil end
		if caster:PassivesDisabled() then return nil end
        if attacker:IsMagicImmune() then return nil end

        local inSlot = false
        for i=0,5 do
            if ability ~= nil and parent:GetItemInSlot(i) == ability then
                inSlot = true
            end
        end

        if not inSlot then 
            if self:IsNull() then return end
            self:Destroy()
            return nil 
        end


		local p_name = "particles/units/heroes/hero_centaur/centaur_return.vpcf"
		local particle = ParticleManager:CreateParticle(p_name, PATTACH_CUSTOMORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle)

		self:ReturnDamage(caster, ability, attacker)
	end

    function modifier_item_mjz_attribute_mail_passive:ReturnDamage(caster, ability, attacker )
		local caster_attr = self:GetPrimaryStatValue()
		local attr_return = GetTalentSpecialValueFor(ability, "attr_return")
	
		local return_damage = caster_attr * (attr_return / 100)
		ApplyDamage({ 
			victim = attacker, attacker = caster, ability = ability,
			damage = return_damage, damage_type = ability:GetAbilityDamageType() 
		})
    end
    
    function modifier_item_mjz_attribute_mail_passive:GetPrimaryStatValue()
        local STRENGTH = 0
        local AGILITY = 1
        local INTELLIGENCE = 2
        local unit = self:GetParent()
        local pa = unit:GetPrimaryAttribute()
        local PrimaryStatValue = 0
        if pa == STRENGTH  then
            PrimaryStatValue = unit:GetStrength()
        elseif pa == AGILITY  then
            PrimaryStatValue = unit:GetAgility()
        elseif pa == INTELLIGENCE  then
            PrimaryStatValue = unit:GetIntellect(true)
        else
            PrimaryStatValue = math.floor((unit:GetIntellect(true) + unit:GetAgility() + unit:GetStrength()) / 2)
        end
        return PrimaryStatValue
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


-- 是否学习了天赋技能
function HasTalentSpecialValueFor(ability, value)
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
		return talent and talent:GetLevel() > 0 
    end
    return false
end


local MODIFIER_DAMAGE_NAME = 'modifier_mjz_templar_assassin_refraction_damage'
LinkLuaModifier(MODIFIER_DAMAGE_NAME, "modifiers/hero_templar_assassin/modifier_mjz_templar_assassin_refraction_buff.lua", LUA_MODIFIER_MOTION_NONE)


modifier_mjz_templar_assassin_refraction_buff = class ({})
local modifier_class = modifier_mjz_templar_assassin_refraction_buff

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end	-- 能否被驱散 
function modifier_class:IsBuff() return true end

function modifier_class:GetTexture()
	return "modifiers/mjz_templar_assassin_refraction_buff"
end

if IsServer() then
	function modifier_class:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			--MODIFIER_PROPERTY_MIN_HEALTH,
		}
		return funcs
	end

	--[[function modifier_class:GetMinHealth(keys)
        local parent = self:GetParent()
        if not parent:IsIllusion() then
            return 1
        end
    end]]
	
	function modifier_class:OnCreated( kv )
		local ability = self:GetAbility()
		local caster = self:GetCaster()

		caster:AddNewModifier(caster, ability, MODIFIER_DAMAGE_NAME, {})

		local p_name = "particles/units/heroes/hero_templar_assassin/templar_assassin_refraction.vpcf"
		local particle = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle, 3, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
		self.particle = particle
	end

	function modifier_class:OnRefresh(table)
		local caster = self:GetCaster()
		local modifier = caster:FindModifierByName(MODIFIER_DAMAGE_NAME)
		if modifier then
			modifier:ForceRefresh()
		end
	end

	function modifier_class:OnDestroy()
		local caster = self:GetCaster()
		if caster:HasModifier(MODIFIER_DAMAGE_NAME) then
			caster:RemoveModifierByName(MODIFIER_DAMAGE_NAME)
		end
		if self.particle then
			ParticleManager:DestroyParticle(self.particle, false)
		end
	end

	function modifier_class:OnTakeDamage( keys )
		if keys.unit ~= self:GetParent() then return nil end
		if keys.inflictor == self:GetAbility() then return nil end
		if self:GetParent():IsIllusion() then return nil end
		

		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local damage_threshold = ability:GetSpecialValueFor('damage_threshold')
		--local attacker = keys.attacker
		local damage = keys.damage

		-- Ensures the damage surpasses the threshold
		if damage >= damage_threshold then
			-- Replaces the health the caster lost when taking damage
			--caster:SetHealth(caster:GetHealth() + damage)
				
			EmitSoundOn("Hero_TemplarAssassin.Refraction.Absorb", caster)
		end
	end

end

----------------------------------------------------------------------------

modifier_mjz_templar_assassin_refraction_damage = class ({})
local modifier_damage = modifier_mjz_templar_assassin_refraction_damage

function modifier_damage:IsHidden() return true end
function modifier_damage:IsPurgable() return false end	-- 能否被驱散 
function modifier_damage:IsBuff() return true end

function modifier_damage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_damage:GetModifierPreAttack_BonusDamage( )
	return self:GetStackCount()
end

function modifier_damage:GetModifierIncomingDamage_Percentage()
	return -100
end

if IsServer() then
	function modifier_damage:OnCreated()
		self:_Init()
	end

	function modifier_damage:OnRefresh(table)
		self:_Init()
	end

	function modifier_damage:_Init()
		local ability = self:GetAbility()
		local bonus_damage = GetTalentSpecialValueFor(ability, 'bonus_damage')
		self:SetStackCount(bonus_damage)
	end
end


-------------------------------------------------------------------------------------

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
    local bonusOperation
    local kv = ability:GetAbilityKeyValues()
    
    if kv.AbilityValues then
        local valueData = kv.AbilityValues[value]
        if type(valueData) == "table" then
            talentName = valueData.LinkedSpecialBonus
            bonusOperation = valueData.LinkedSpecialBonusOperation
        end
    end
    
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            local bonusValue = talent:GetSpecialValueFor("value")
            
            if bonusOperation then
                if bonusOperation == "SPECIAL_BONUS_ADD" or bonusOperation == "SPECIAL_BONUS_SUBTRACT" then
                    base = base + bonusValue -- For subtraction, bonusValue should already be negative
                elseif bonusOperation == "SPECIAL_BONUS_MULTIPLY" then
                    base = base * bonusValue
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_ADD" then
                    base = base * (1 + bonusValue / 100)
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_SUBTRACT" then
                    base = base * (1 - bonusValue / 100)
                end
            else
                -- Default behavior if no operation is specified
                base = base + bonusValue
            end
        end
    end
    
    return base
end
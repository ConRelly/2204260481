

modifier_mjz_drow_ranger_marksmanship_thinker = class({})
local modifier_class = modifier_mjz_drow_ranger_marksmanship_thinker

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end


function modifier_class:DeclareFunctions()
	local func = {
		MODIFIER_EVENT_ON_ATTACK,
        -- MODIFIER_EVENT_ON_ATTACK_START,
		-- MODIFIER_EVENT_ON_ATTACK_FAIL,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_ORDER,
		-- MODIFIER_PROPERTY_PROJECTILE_NAME,
    }
	return func
end

function modifier_class:OnCreated()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
end

function modifier_class:OnAttack(keys)
	if IsServer() then
		-- print('OnAttack')				
		if keys.attacker ~= self:GetParent() then return nil end
		if keys.target:IsBuilding() then return nil end		
		if self:GetParent():PassivesDisabled()  then return nil end
		if TargetIsFriendly(self:GetParent(), keys.target) then return nil end
		
        -- if keys.attacker:IsIllusion() then return nil end

		local attacker = keys.attacker
		local target = keys.target
        local ability = self:GetAbility()
		
		local marksmanship_attack = ability:_FirtAbilityEffect(attacker, target)		
		-- self:SetStackCount(marksmanship_attack)
	end
end


function modifier_class:OnAttackStart(keys)
	if IsServer() then
		-- print('OnAttackStart')		
        if keys.attacker ~= self:GetParent() then return nil end
        -- if keys.attacker:IsIllusion() then return nil end
        if self:GetParent():PassivesDisabled()  then return nil end
		if TargetIsFriendly(self:GetParent(), keys.target) then return nil end

        local attacker = keys.attacker
		local target = keys.target
        local ability = self:GetAbility()

	end
end

function modifier_class:OnAttackLanded(keys)
	if IsServer() then
		-- print('OnAttackLanded')
        if keys.attacker ~= self:GetParent() then return nil end
		if keys.attacker:IsIllusion() then return nil end
		if keys.target:IsBuilding() then return nil end
		if TargetIsFriendly(self:GetParent(), keys.target) then return nil end
		
		local attacker = keys.attacker
		local target = keys.target
        local ability = self:GetAbility()	
	end
end

function modifier_class:OnAttackFail(keys)
    if IsServer() then
        if keys.attacker ~= self:GetParent() then return nil end
		if keys.attacker:IsIllusion() then return nil end
		if keys.target:IsBuilding() then return nil end
		if TargetIsFriendly(self:GetParent(), keys.target) then return nil end
		
		local attacker = keys.attacker
        local target = keys.target
    end
end

function modifier_class:OnOrder(keys)
	if keys.unit == self.caster then
		local order_type = keys.order_type
		if order_type ~= DOTA_UNIT_ORDER_ATTACK_TARGET then
			-- print('OnOrder')	
		end
	end
end

function modifier_class:GetModifierProjectileName()
	if self:GetStackCount() > 0 then
		return "particles/units/heroes/hero_drow/drow_marksmanship_attack.vpcf"
	end
end

-------------------------------------------------------------------------------------

function SetArrowAttackProjectile(caster, frost_attack, marksmanship_attack)
	if marksmanship_attack then
		local marksmanship_arrow = "particles/units/heroes/hero_drow/drow_marksmanship_attack.vpcf"

		if frost_attack then
			marksmanship_arrow = "particles/units/heroes/hero_drow/drow_marksmanship_frost_arrow.vpcf"
		end

		caster:SetRangedProjectileName(marksmanship_arrow)

		return
	end

	-- modifiers
	local skadi_modifier = "modifier_item_skadi"
	local deso_modifier = "modifier_item_desolator"
	local deso_2_modifier = "modifier_item_desolator_2"
	local morbid_modifier = "modifier_morbid_mask"
	local mom_modifier = "modifier_mask_of_madness"
	local satanic_modifier = "modifier_satanic"
	local vladimir_modifier = "modifier_item_vladmir"
	local vladimir_2_modifier = "modifier_item_vladmir_blood"

	-- normal projectiles
	local skadi_projectile = "particles/items2_fx/skadi_projectile.vpcf"
	local deso_projectile = "particles/items_fx/desolator_projectile.vpcf"
	local deso_skadi_projectile = "particles/item/desolator/desolator_skadi_projectile_2.vpcf"
	local lifesteal_projectile = "particles/item/lifesteal_mask/lifesteal_particle.vpcf"

	-- Frost arrow projectiles
	local basic_arrow = "particles/units/heroes/hero_drow/drow_base_attack.vpcf"
	local frost_arrow = "particles/units/heroes/hero_drow/drow_frost_arrow.vpcf"

	local frost_lifesteal_projectile = "particles/hero/drow/lifesteal_arrows/drow_lifedrain_frost_arrow.vpcf"
	local frost_skadi_projectile = "particles/hero/drow/skadi_arrows/drow_skadi_frost_arrow.vpcf"
	local frost_deso_projectile = "particles/hero/drow/deso_arrows/drow_deso_frost_arrow.vpcf"
	local frost_deso_skadi_projectile = "particles/hero/drow/deso_skadi_arrows/drow_deso_skadi_frost_arrow.vpcf"
	local frost_lifesteal_skadi_projectile = "particles/hero/drow/lifesteal_skadi_arrows/drow_lifesteal_skadi_frost_arrow.vpcf"
	local frost_lifesteal_deso_projectile = "particles/hero/drow/lifesteal_deso_arrows/drow_lifedrain_deso_frost_arrow.vpcf"
	local frost_lifesteal_deso_skadi_projectile = "particles/hero/drow/lifesteal_deso_skadi_arrows/drow_lifesteal_deso_skadi_frost_arrow.vpcf"

	-- Set variables
	local has_lifesteal
	local has_skadi
	local has_desolator

	-- Assign variables
	-- Lifesteal
	if caster:HasModifier(morbid_modifier) or caster:HasModifier(mom_modifier) or caster:HasModifier(satanic_modifier) or caster:HasModifier(vladimir_modifier) or caster:HasModifier(vladimir_2_modifier) then
		has_lifesteal = true
	end

	-- Skadi
	if caster:HasModifier(skadi_modifier) then
		has_skadi = true
	end

	-- Desolator
	if caster:HasModifier(deso_modifier) or caster:HasModifier(deso_2_modifier) then
		has_desolator = true
	end

	-- ASSIGN PARTICLES
	-- Frost attack
	if frost_attack then
		-- Desolator + lifesteal + frost + skadi (doesn't exists yet)
		if has_desolator and has_skadi and has_lifesteal then
			caster:SetRangedProjectileName(frost_lifesteal_deso_skadi_projectile)
			-- Desolator + lifesteal + frost
		elseif has_desolator and has_lifesteal then
			caster:SetRangedProjectileName(frost_lifesteal_deso_projectile)
			-- Desolator + skadi + frost
		elseif has_skadi and has_desolator then
			caster:SetRangedProjectileName(frost_deso_skadi_projectile)
			-- Lifesteal + skadi + frost
		elseif has_lifesteal and has_skadi then
			caster:SetRangedProjectileName(frost_lifesteal_skadi_projectile)
			-- skadi + frost
		elseif has_skadi then
			caster:SetRangedProjectileName(frost_skadi_projectile)
			-- lifesteal + frost
		elseif has_lifesteal then
			caster:SetRangedProjectileName(frost_lifesteal_projectile)
			-- Desolator + frost
		elseif has_desolator then
			caster:SetRangedProjectileName(frost_deso_projectile)
			return
			-- Frost
		else
			caster:SetRangedProjectileName(frost_arrow)
			return
		end
	-- Non frost attack
	else
		-- Skadi + desolator
		if has_skadi and has_desolator then
			caster:SetRangedProjectileName(deso_skadi_projectile)
			return
		-- Skadi
		elseif has_skadi then
			caster:SetRangedProjectileName(skadi_projectile)
		-- Desolator
		elseif has_desolator then
			caster:SetRangedProjectileName(deso_projectile)
			return
		-- Lifesteal
		elseif has_lifesteal then
			caster:SetRangedProjectileName(lifesteal_projectile)
		-- Basic arrow
		else
			caster:SetRangedProjectileName(basic_arrow)
			return
		end
	end
end



--[[
    A quick function to create popups.
    Example:
    create_popup({
        target = target,
        value = value,
        color = Vector(255, 20, 147),
        type = "spell_custom"
	}) 
	伤害类型的颜色：
		物理：Vector(174, 47, 40)
		魔法：Vector(91, 147, 209)
		纯粹：Vector(216, 174, 83)
	spell_custom: 
		block | crit | damage | evade | gold | heal | mana_add | mana_loss | miss | poison | spell | xp
	Color:	
		red 	={255,0,0},
		orange	={255,127,0},
		yellow	={255,255,0},
		green 	={0,255,0},
		blue 	={0,0,255},
		indigo 	={0,255,255},
		purple 	={255,0,255},
]]
function create_popup(data)
    local target = data.target
    local value = math.floor(data.value)

    local type = data.type or "miss"
    local color = data.color or Vector(255, 255, 255)
    local duration = data.duration or 1.0

    local size = string.len(value)

    local pre = data.pre or nil
    if pre ~= nil then
        size = size + 1
    end

    local pos = data.pos or nil
    if pos ~= nil then
        size = size + 1
    end

    local particle_path = "particles/msg_fx/msg_" .. type .. ".vpcf"
    local particle = ParticleManager:CreateParticle(particle_path, PATTACH_OVERHEAD_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 1, Vector(pre, value, pos))
    ParticleManager:SetParticleControl(particle, 2, Vector(duration, size, 0))
    ParticleManager:SetParticleControl(particle, 3, color)
	ParticleManager:ReleaseParticleIndex(particle)
end

function create_popup_by_damage_type(data, ability)
    local damage_type = ability:GetAbilityDamageType()
    if damage_type == DAMAGE_TYPE_PHYSICAL then
        data.color = Vector(174, 47, 40)
    elseif damage_type == DAMAGE_TYPE_MAGICAL then
        data.color = Vector(91, 147, 209)
    elseif damage_type == DAMAGE_TYPE_PURE then
        data.color = Vector(216, 174, 83)
    else
        data.color = Vector(255, 255, 255)
    end
    create_popup(data)
end

function TargetIsFriendly(caster, target )
	local nTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY 	-- ability:GetAbilityTargetTeam()
	local nTargetType = DOTA_UNIT_TARGET_ALL 			-- ability:GetAbilityTargetType()
	local nTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE		-- ability:GetAbilityTargetFlags()
	local nTeam = caster:GetTeamNumber()
	local ufResult = UnitFilter(target, nTargetTeam, nTargetType, nTargetFlags, nTeam)
	return ufResult == UF_SUCCESS
end
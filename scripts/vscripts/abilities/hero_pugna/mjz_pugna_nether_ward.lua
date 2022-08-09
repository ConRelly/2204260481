LinkLuaModifier("modifier_mjz_pugna_nether_ward", "abilities/hero_pugna/mjz_pugna_nether_ward.lua", LUA_MODIFIER_MOTION_NONE)


mjz_pugna_nether_ward = class({})
local ability_class = mjz_pugna_nether_ward

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('radius')
end
function ability_class:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor('cast_range')
end

if IsServer() then
	function ability_class:OnSpellStart()
		local ability = self
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		local duration = ability:GetSpecialValueFor('duration')

		EmitSoundOn("Hero_Pugna.NetherWard", caster)

		local position = point
		local unit_name = 'npc_dota_mjz_pugna_nether_ward'
		local unit = CreateUnitByName(unit_name, position, false, caster, caster, caster:GetTeamNumber())
		if unit and IsValidEntity(unit) then
			FindClearSpaceForUnit(unit, position, false)
			unit:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
			unit:AddNewModifier(caster, ability, "modifier_mjz_pugna_nether_ward", {duration = duration})
		end
	end
end

-----------------------------------------------------------------------------------------

modifier_mjz_pugna_nether_ward = class({})
local modifier_effect = modifier_mjz_pugna_nether_ward

function modifier_effect:IsHidden() return true end
function modifier_effect:IsPurgable() return false end

function modifier_effect:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_ward_ambient.vpcf"
end
function modifier_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		-- MODIFIER_EVENT_ON_ATTACKED,
	}
end

function modifier_effect:GetModifierAttackRangeBonus( )
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor('radius')
	end	
end
function modifier_effect:GetBonusDayVision( )
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor('radius')
	end	
end
function modifier_effect:GetBonusNightVision( )
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor('radius')
	end	
end



function modifier_effect:OnTakeDamage( event )
	if not IsServer() then return nil end
	if event.unit ~= self:GetParent() then return nil end
	if event.attacker:IsIllusion() then return nil end

	local target = event.unit
	local attacker = event.attacker

	self:_OnAttacked(attacker)
end

function modifier_effect:OnAttacked( event )
	if not IsServer() then return nil end
	if event.target ~= self:GetParent() then return nil end
	if event.attacker:IsIllusion() then return nil end

	local target = event.target
	local attacker = event.attacker

end

if IsServer() then
	function modifier_effect:OnCreated(table)
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local radius = ability:GetSpecialValueFor('radius')
		local interval = ability:GetSpecialValueFor('interval')
		local attacks_to_destroy = GetTalentSpecialValueFor(ability, 'attacks_to_destroy')
		parent.attack_counter = attacks_to_destroy

		local health = attacks_to_destroy
		parent:SetBaseMaxHealth(health)
		parent:SetMaxHealth(health)
		parent:SetHealth(health)
		parent:ModifyHealth(health, ability, false, 0)

		self:OnIntervalThink()
		self:StartIntervalThink(interval)
	end

	function modifier_effect:OnDestroy()
		local parent = self:GetParent()
		self:StartIntervalThink(-1)
		parent:ForceKill(false)
	end

	function modifier_effect:OnIntervalThink()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		
		local max_count = 8
		local radius = ability:GetSpecialValueFor('radius')
		local base_damage = ability:GetSpecialValueFor("base_damage")
		local intelligence_damage = GetTalentSpecialValueFor(ability, "intelligence_damage")
		local damage = base_damage + caster:GetIntellect() * (intelligence_damage / 100.0)

		local enemy_list = FindUnitsInRadius(
			caster:GetTeamNumber(),
			parent:GetAbsOrigin(),
			nil,
			radius,
			ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),
			ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER,
			false
		)
		
		local count = 0
		for _,enemy in pairs(enemy_list) do
			if count < max_count then
				count = count + 1
				self:_FireEffect(enemy)
				self:_ApplyDamage(enemy)
			end
		end
	end

	function modifier_effect:_OnAttacked(attacker)
		local parent = self:GetParent()
		local ability = self:GetAbility()
	
		if parent.attack_counter > 1 then
			parent.attack_counter = parent.attack_counter - 1
			parent:SetHealth(parent.attack_counter)
			parent:ModifyHealth(parent.attack_counter, ability, false, 0)
		end
	end

	function modifier_effect:_FireEffect(target)
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local ward = parent
		-- There are some light/medium/heavy unused versions
		local p_list = {
			"particles/units/heroes/hero_pugna/pugna_ward_attack.vpcf",
			"particles/units/heroes/hero_pugna/pugna_ward_attack_light.vpcf",
			"particles/units/heroes/hero_pugna/pugna_ward_attack_medium.vpcf",
			"particles/units/heroes/hero_pugna/pugna_ward_attack_heavy.vpcf",
		}
		local p_id = RandomInt(1, #p_list)
		local p_name = p_list[p_id]
		local p_attack = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, ward)
		ParticleManager:SetParticleControl(p_attack, 1, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(p_attack)

		--target:EmitSound("Hero_Pugna.NetherWard.Target")
		-- caster:EmitSound("Hero_Pugna.NetherWard.Attack")
		ward:EmitSound("Hero_Pugna.NetherWard.Attack")
	end

	function modifier_effect:_ApplyDamage(target)
		if IsServer() then
			local parent = self:GetParent()
			local caster = self:GetCaster()
			local ability = self:GetAbility()

			local base_damage = ability:GetSpecialValueFor("base_damage")
			local intelligence_damage = GetTalentSpecialValueFor(ability, "intelligence_damage")
			local damage = base_damage + caster:GetIntellect() * (intelligence_damage / 100.0)
			print("normal dmg: "..damage)
			if _G._challenge_bosss > 0 then
				for i = 1, _G._challenge_bosss do
					damage = math.floor(damage * 1.3)
					print("tier "..i.. " dmg: "..damage)
				end 
			end

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


-----------------------------------------------------------------------------------------


function FindWearables( unit, wearable_model_name)
    local model = unit:FirstMoveChild()
	while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
			local modelName = model:GetModelName()
			-- print('model name: ', model:GetModelName())			
            if modelName == wearable_model_name then
                return true
            end
        end
        model = model:NextMovePeer()
    end
    return false
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


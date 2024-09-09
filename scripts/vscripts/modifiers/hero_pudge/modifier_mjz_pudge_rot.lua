

modifier_mjz_pudge_rot_immortal_ti7_arm = class({})
function modifier_mjz_pudge_rot_immortal_ti7_arm:IsHidden() return true end
function modifier_mjz_pudge_rot_immortal_ti7_arm:IsPurgable() return false end

----------------------------------------------------------------------------

modifier_mjz_pudge_rot = class({})
local modifier_class = modifier_mjz_pudge_rot

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

------------------------------------------------

function modifier_class:IsAura() return true end
function modifier_class:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,

	}
end
function modifier_class:GetModifierIncomingDamage_Percentage()
	if self:GetAbility() then
		if self:GetParent():GetName() ~= "npc_dota_hero_rubick" then
			return self:GetAbility():GetSpecialValueFor("dmg_reduction") * (-1)
		end
		return 0	
	end	
end
function modifier_class:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("rot_radius")
    -- return self:GetAbility():GetAOERadius()
end

function modifier_class:GetModifierAura()
    return 'modifier_mjz_pudge_rot_effect'
end

function modifier_class:GetAuraSearchTeam()
	-- return DOTA_UNIT_TARGET_TEAM_ENEMY -- DOTA_UNIT_TARGET_TEAM_FRIENDLY
	return self:GetAbility():GetAbilityTargetTeam()
end

function modifier_class:GetAuraEntityReject(target)
    return self:GetParent():IsIllusion()
end

function modifier_class:GetAuraSearchType()
	-- return DOTA_UNIT_TARGET_ALL -- DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	return self:GetAbility():GetAbilityTargetType()
end

function modifier_class:GetAuraSearchFlags()
	-- return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES  -- DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE -- DOTA_UNIT_TARGET_FLAG_NONE
	return self:GetAbility():GetAbilityTargetFlags()
end

function modifier_class:GetAuraDuration()
    return 0.5
end

------------------------------------------------

-- function modifier_class:GetEffectName()
--     return "particles/units/heroes/hero_pudge/pudge_rot_recipient.vpcf"
-- end

if IsServer() then
	function modifier_class:OnCreated( kv )
		local ability = self:GetAbility()
		self.rot_radius = GetTalentSpecialValueFor(ability, "rot_radius" ) 
		self.rot_tick = GetTalentSpecialValueFor(ability, "rot_tick" )
		
		EmitSoundOn( "Hero_Pudge.Rot", self:GetCaster() )

		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_rot.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 150, 1, 150 ) )
		self:AddParticle( nFXIndex, false, false, -1, false, false )

		self:StartIntervalThink( self.rot_tick / 2 )
	end

	function modifier_class:OnDestroy()
		StopSoundOn( "Hero_Pudge.Rot", self:GetCaster() )
	end

	function modifier_class:OnIntervalThink()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local base_damage = GetTalentSpecialValueFor(ability, "base_damage" )
		local health_damage_pct = GetTalentSpecialValueFor(ability, "health_damage_pct" )
		local rot_damage = base_damage + caster:GetMaxHealth() * (health_damage_pct / 100.0)

		local flDamagePerTick = math.ceil((self.rot_tick * rot_damage) / 60)

		if caster:IsAlive() then
			local damage = {
				victim = parent,
				attacker = caster,
				damage = flDamagePerTick,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
				ability = ability,
			}
			ApplyDamage( damage )
		end
	end
end

----------------------------------------------------------------------------

modifier_mjz_pudge_rot_effect = class({})
local modifier_effect = modifier_mjz_pudge_rot_effect

function modifier_effect:IsHidden( ) return false end
function modifier_effect:IsPurgable() return true end

function modifier_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_effect:GetModifierMoveSpeedBonus_Percentage( params )
	return self:GetAbility():GetSpecialValueFor('rot_slow')
end

function modifier_effect:GetEffectName()
    return "particles/units/heroes/hero_pudge/pudge_rot_recipient.vpcf"
end

if IsServer() then

	function modifier_effect:OnCreated()
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		self.rot_tick = GetTalentSpecialValueFor(ability, "rot_tick" )

		-- local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_rot_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		-- self:AddParticle( nFXIndex, false, false, -1, false, false )

		self:StartIntervalThink( self.rot_tick )
	end

	function modifier_effect:OnIntervalThink()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local base_damage = GetTalentSpecialValueFor(ability, "base_damage" )
		local health_damage_pct = GetTalentSpecialValueFor(ability, "health_damage_pct" )
		local rot_damage = base_damage + caster:GetHealth() * (health_damage_pct / 100.0)
		if _G._challenge_bosss > 1 then
			for i = 1, _G._challenge_bosss do
				rot_damage = math.floor(rot_damage * 1.5)
			end 
		end
		--local flDamagePerTick = math.ceil(self.rot_tick * rot_damage) -- not used for a buff reason and reduce in process

		if caster:IsAlive() then
			local damage = {
				victim = parent,
				attacker = caster,
				damage = rot_damage,
				damage_type = ability:GetAbilityDamageType(),
				ability = ability,
			}
			ApplyDamage( damage )
		end
	end
end

------------------------------------------------------------------------------------------

function FindWearables( unit, wearable_model_name)
	local model = unit:FirstMoveChild()
	while model ~= nil do
		if model:GetClassname() == "dota_item_wearable" then
			local modelName = model:GetModelName()
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


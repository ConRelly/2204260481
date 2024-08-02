

modifier_mjz_pudge_dismember = class({})
local modifier_class = modifier_mjz_pudge_dismember

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end
function modifier_class:IsDebuff()
	return true
end
function modifier_class:IsStunDebuff()
	return true
end

function modifier_class:CheckState()
	if self:GetParent().bAbsoluteNoCC then return end
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}
	return state
end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

function modifier_class:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

-- function modifier_class:GetEffectName()
-- 	return "particles/units/heroes/hero_pudge/pudge_dismember.vpcf"
-- end

if IsServer() then
	function modifier_class:OnCreated( kv )
		local ability = self:GetAbility()
		self.dismember_damage = GetTalentSpecialValueFor(ability, "dismember_damage" )
		self.strength_damage = GetTalentSpecialValueFor(ability, "strength_damage" )
		self.tick_rate = 1.0
		
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleAlwaysSimulate(self.nfx)
		ParticleManager:SetParticleControlEnt(self.nfx, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)


		self:GetParent():InterruptChannel()
		self:OnIntervalThink()
		self:StartIntervalThink( self.tick_rate )
	end

	function modifier_class:OnDestroy()
		--self:GetCaster():InterruptChannel()
		ParticleManager:ReleaseParticleIndex(self.nfx)
	end

	function modifier_class:OnIntervalThink()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local damage = self.dismember_damage + caster:GetStrength() * self.strength_damage

		if parent:IsAlive() then
			local damageTable = {
				victim = parent,
				attacker = caster,
				damage = damage,
				damage_type = ability:GetAbilityDamageType(),
				ability = ability,
			}
			ApplyDamage( damageTable )

			caster:Heal(damage, caster)
		end

		-- EmitSoundOn( "Hero_Pudge.Dismember", self:GetParent() )
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


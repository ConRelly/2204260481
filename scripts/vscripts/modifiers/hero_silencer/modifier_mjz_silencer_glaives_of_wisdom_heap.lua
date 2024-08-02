
local MODIFIER_HEAP_NAME = 'modifier_mjz_silencer_glaives_of_wisdom_heap'
local MODIFIER_HEAP_AURA_NAME = 'modifier_mjz_silencer_glaives_of_wisdom_heap_aura'

LinkLuaModifier(MODIFIER_HEAP_AURA_NAME, "modifiers/hero_silencer/modifier_mjz_silencer_glaives_of_wisdom_heap.lua", LUA_MODIFIER_MOTION_NONE)
-------------------------------------------------------------------

modifier_mjz_silencer_glaives_of_wisdom_heap = class ({})
local modifier_class = modifier_mjz_silencer_glaives_of_wisdom_heap

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end
function modifier_class:RemoveOnDeath() return false end
function modifier_class:AllowIllusionDuplicate() return false end

function modifier_class:GetTexture()
	return self:GetAbility():GetAbilityTextureName()
end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
	if IsServer() then
		table.insert( funcs, MODIFIER_EVENT_ON_HERO_KILLED)
		table.insert( funcs, MODIFIER_EVENT_ON_RESPAWN)
	end
	return funcs
end

function modifier_class:GetModifierBonusStats_Strength( params )
    if self.heap_type == 1 then
        return self:GetStackCount()
    end
    return 0
end
function modifier_class:GetModifierBonusStats_Agility( params )
    if self.heap_type == 2 then
        return self:GetStackCount()
    end
    return 0
end
function modifier_class:GetModifierBonusStats_Intellect( params )
    if self.heap_type == 3 then
		return self:GetStackCount()
	end
    return 0
end

function modifier_class:OnCreated( kv )
	self.heap_amount = self:GetAbility():GetSpecialValueFor( "heap_amount" )
    self.heap_type = self:GetAbility():GetSpecialValueFor( "heap_type" )
    self.heap_type = self.heap_type or 1
	if IsServer() then
		self:CalculateStatBonus(false)
		self:RemoveModifierIntSteal()
	end
end

function modifier_class:OnRefresh( kv )
	self.heap_amount = self:GetAbility():GetSpecialValueFor( "heap_amount" )
	if IsServer() then
		self:CalculateStatBonus(false)
	end
end

if IsServer() then
	function modifier_class:OnRespawn( )
		self:CalculateStatBonus(false)
		self:RemoveModifierIntSteal()
	end

	function modifier_class:OnHeroKilled(keys)
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local target = keys.target
		local attacker = keys.attacker
		local hKiller = keys.attacker
		local hVictim = keys.target

		if hVictim == nil or hKiller == nil then return nil end
		if target:IsIllusion() then return nil end
		if not target:IsRealHero() then return nil end
		if target:GetTeam() == caster:GetTeam() then return nil end

		local heap_amount_hero = GetTalentSpecialValueFor(ability, "heap_amount_hero" )
		if (keys.reincarnate == false or keys.reincarnate == nil) then
			--[[
				print(keys.target:GetNumAttackers())
				for i = 0, target:GetNumAttackers() - 1 do
					if caster:GetPlayerID() == target:GetAttacker(i) then
						break
					end
				end
			]]
			
			if caster:IsAlive() then
				if hKiller == caster or self:InNearby(hVictim) then
					self:IncrementHeapAmount(heap_amount_hero)
		
					self:PlayEffect( hVictim, hKiller, event, heap_amount_hero)
				end
			end
        end
	end

	function modifier_class:OnEnemyDiedNearby( hVictim, hKiller, event )
		local ability = self:GetAbility()
		local caster = self:GetCaster()

		if hVictim == nil or hKiller == nil then return nil end
		if hVictim:IsIllusion() then return nil end
		if hVictim:IsRealHero() then return nil end
		if hVictim:GetTeam() == caster:GetTeam() then return nil end
		local heap_amount = GetTalentSpecialValueFor(ability, "heap_amount" )
		if caster:IsAlive() then
			if hKiller == caster or self:InNearby(hVictim) then
				self:IncrementHeapAmount(heap_amount)
	
				if HasSuperScepter(caster) then
					local chance = ability:GetSpecialValueFor("second_stack")
					if RollPercentage(chance) then
						self:IncrementHeapAmount(heap_amount)
						self:PlayEffect( hVictim, hKiller, event, heap_amount * 2)
						--print(chance_nr .. "luky nr")
					else
						self:PlayEffect( hVictim, hKiller, event, heap_amount)	
					end
				else
					self:PlayEffect( hVictim, hKiller, event, heap_amount)		
				end	
			end
		end
	end

	function modifier_class:InNearby( target )
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local heap_range = GetTalentSpecialValueFor(ability, "heap_range" )
		if caster:IsAlive() then 
			local vToCaster = caster:GetOrigin() - target:GetOrigin()
			local flDistance = vToCaster:Length2D()
			if heap_range >= flDistance then
				return true
			end		
		end
		return false
	end
	
	function modifier_class:GetHeapAmount()
		if self.heap_amount == nil then
			self.heap_amount = 0
		end
		return self.heap_amount
	end

	function modifier_class:IncrementHeapAmount(amount)
		local value = amount or 0
		if self.heap_amount == nil then
			self.heap_amount = 0
		end
		self.heap_amount = self.heap_amount + value
		self:CalculateStatBonus()
		return self.heap_amount
	end

	function modifier_class:CalculateStatBonus()
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local heap_amount = self:GetHeapAmount()
		self:SetStackCount( heap_amount)
		caster:CalculateStatBonus(false)
	end

	function modifier_class:PlayEffect(hVictim, hKiller, event, intellectDifference )
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()

		--[[
			local p_name = "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf"
			local nFXIndex = ParticleManager:CreateParticle( p_name, PATTACH_OVERHEAD_FOLLOW, caster )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		]]

		-- local intellectDifference = 2		

		local plusIntParticleName = "particles/units/heroes/hero_silencer/silencer_last_word_steal_count.vpcf"
		local plusIntParticle = ParticleManager:CreateParticle(plusIntParticleName, PATTACH_OVERHEAD_FOLLOW, parent)
		ParticleManager:SetParticleControl(plusIntParticle, 1, Vector(10 + intellectDifference, 0, 0))
		ParticleManager:ReleaseParticleIndex(plusIntParticle)

		--[[
			local minusIntParticleName = "particles/units/heroes/hero_silencer/silencer_last_word_victim_count.vpcf"
			local minusIntParticle = ParticleManager:CreateParticle(minusIntParticleName, PATTACH_OVERHEAD_FOLLOW, keys.unit)
			ParticleManager:SetParticleControl(minusIntParticle, 1, Vector(10 + intellectDifference, 0, 0))
			ParticleManager:ReleaseParticleIndex(minusIntParticle)
		]]
	end

	-- 删除默认的 Modifier 
	function modifier_class:RemoveModifierIntSteal(  )
		local caster = self:GetCaster()
		local modifier = caster:FindModifierByName('modifier_silencer_int_steal')
		if modifier then
			if modifier:IsNull() then return end
			modifier:Destroy()
		end
	end
end

--------------------------------------------------------------

function modifier_class:IsAura() return true end

function modifier_class:GetModifierAura()
	return MODIFIER_HEAP_AURA_NAME
end

function modifier_class:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_class:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_class:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_class:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor( "heap_range" )
end


-------------------------------------------------------------------

modifier_mjz_silencer_glaives_of_wisdom_heap_aura = class({})
local modifier_heap_aura = modifier_mjz_silencer_glaives_of_wisdom_heap_aura

function modifier_heap_aura:IsHidden() return true end
function modifier_heap_aura:IsPurgable() return false end
if IsServer() then
    function modifier_heap_aura:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_DEATH
        }
	end
	
    function modifier_heap_aura:OnDeath(event)
        if self:GetParent() ~= event.unit then return end

		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local hVictim = event.unit
		local hKiller = event.attacker

		local modifier_heap = caster:FindModifierByName(MODIFIER_HEAP_NAME)
		modifier_heap:OnEnemyDiedNearby(hVictim, hKiller, event)
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

function HasSuperScepter(npc)
    local modifier_super_scepter = "modifier_item_imba_ultimate_scepter_synth_stats"
    if npc:HasModifier(modifier_super_scepter) and npc:FindModifierByName(modifier_super_scepter):GetStackCount() > 2 then
		return true 
	end	  
    return false
end
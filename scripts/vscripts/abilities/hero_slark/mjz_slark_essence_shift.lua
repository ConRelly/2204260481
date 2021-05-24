LinkLuaModifier( "modifier_mjz_slark_essence_shift_heap", "modifiers/hero_slark/modifier_mjz_slark_essence_shift_heap.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mjz_slark_essence_shift_heap_aura", "modifiers/hero_slark/modifier_mjz_slark_essence_shift_heap.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mjz_slark_essence_shift_fast_attack", "modifiers/hero_slark/modifier_mjz_slark_essence_shift_heap.lua" ,LUA_MODIFIER_MOTION_NONE )

mjz_slark_essence_shift = class({})
local ability_class = mjz_slark_essence_shift
local modifier_stack_name = "modifier_mjz_slark_essence_shift_heap"

function ability_class:GetIntrinsicModifierName()
	return modifier_stack_name
end

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor("heap_range")
end


function ability_class:OnSpellStart()
	if not IsServer() then return end

	local ability = self
	local caster = self:GetCaster()
	local pszScriptName = "modifier_mjz_slark_essence_shift_fast_attack"

	if caster:HasModifier(pszScriptName) then
		return false
	end
	ability:SetActivated(false)
	caster:AddNewModifier(caster, ability, pszScriptName, {})
end

function ability_class:FastAttack(target)
	local ability = self
	local caster = self:GetCaster()
	local attack_count = self:GetTalentSpecialValueFor(ability, 'attack_count')

	caster:EmitSound("Hero_Slark.Pounce.Impact")
	for i = 1, attack_count do
		if IsValidEntity(target) then
			caster:PerformAttack(target, true, true, true, true, true, false, false)
		end
	end

	ability:SetActivated(true)
end

function ability_class:OnEnemyDiedNearby( hVictim, hKiller, kv )
	if hVictim == nil or hKiller == nil or hVictim:IsIllusion()  then
		return
	end

	local caster = self:GetCaster()
	local heap_range = self:GetSpecialValueFor( "heap_range" )

	if hVictim:GetTeamNumber() ~= caster:GetTeamNumber() and caster:IsAlive() then
		local vToCaster = caster:GetOrigin() - hVictim:GetOrigin()
		local flDistance = vToCaster:Length2D()

		if hKiller == caster or heap_range >= flDistance then
			if self.nKills == nil then
				self.nKills = 0
			end

			self.nKills = self.nKills + 1

			local hBuff = caster:FindModifierByName(modifier_stack_name)
			if hBuff ~= nil then
				hBuff:SetStackCount( self.nKills )
				caster:CalculateStatBonus()
			end

			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, caster )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end
	end
end

function ability_class:GetHeapKills()
	if self.nKills == nil then
		self.nKills = 0
	end
	return self.nKills
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function ability_class:GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local valueName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                    valueName = m["LinkedSpecialBonusField"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            valueName = valueName or 'value'
            base = base + talent:GetSpecialValueFor(valueName) 
        end
    end
    return base
end

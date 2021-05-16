LinkLuaModifier("modifier_mjz_luna_under_the_moonlight", "abilities/hero_luna/mjz_luna_under_the_moonlight.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_luna_under_the_moonlight_buff", "abilities/hero_luna/mjz_luna_under_the_moonlight.lua", LUA_MODIFIER_MOTION_NONE)

mjz_luna_under_the_moonlight = mjz_luna_under_the_moonlight or class({})
modifier_mjz_luna_under_the_moonlight_buff = class(mjz_luna_under_the_moonlight)

function mjz_luna_under_the_moonlight:GetIntrinsicModifierName()
    return "modifier_mjz_luna_under_the_moonlight"
end

local modifier_buffa = "modifier_mjz_luna_under_the_moonlight_buff"

function mjz_luna_under_the_moonlight:LucentBeam(target, stun)
	local caster = self:GetCaster()
    local ability = self
    local position = target:GetAbsOrigin()
    local sDur = stun or 0
	local modifier_buffa = "modifier_mjz_luna_under_the_moonlight_buff"
	local mbuf = caster:FindModifierByName(modifier_buffa)    
    local stack_count = mbuf:GetStackCount() + 1
    local level = caster:GetLevel()
    if level < 30 then
        level = 30
    end    
    local damage = level * stack_count
	--local damage = GetTalentSpecialValueFor(ability, "beam_damage") * stack_count
    if not target:TriggerSpellAbsorb( ability ) then
        ability:DealDamage( caster, target, damage )
        if sDur > 0 then
            ability:Stun( target, sDur )
        end
    end
	
    ability:FireParticle("particles/units/heroes/hero_luna/luna_lucent_beam.vpcf", PATTACH_ABSORIGIN, target, 
                { [1] = position, 
                [2] = {attach = PATTACH_POINT_FOLLOW, point = "attach_hitloc"}, 
                [5] = {attach = PATTACH_POINT_FOLLOW, point = "attach_hitloc"}, 
                [6] = {attach = PATTACH_POINT_FOLLOW, point = "attach_hitloc"}})
	if stun then target:EmitSound("Hero_Luna.LucentBeam.Target") end
end

function mjz_luna_under_the_moonlight:DealDamage(attacker, target, damage, data, spellText)
	--OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, OVERHEAD_ALERT_DAMAGE, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, OVERHEAD_ALERT_MANA_LOSS
	if self:IsNull() or target:IsNull() or attacker:IsNull() then return end
	local internalData = data or {}
	local damageType =  internalData.damage_type or self:GetAbilityDamageType() or DAMAGE_TYPE_MAGICAL
	local damageFlags = internalData.damage_flags or DOTA_DAMAGE_FLAG_NONE
	local localdamage = damage or self:GetAbilityDamage() or 0
	local spellText = spellText or 0
	local ability = self or internalData.ability
	local oldHealth = target:GetHealth()
	ApplyDamage({victim = target, attacker = attacker, ability = ability, damage_type = damageType, damage = localdamage, damage_flags = damageFlags})
	if target:IsNull() then return oldHealth end
	local newHealth = target:GetHealth()
	local returnDamage = oldHealth - newHealth
	if spellText > 0 then
		SendOverheadEventMessage(attacker:GetPlayerOwner(),spellText,target,returnDamage,attacker:GetPlayerOwner()) --Substract the starting health by the new health to get exact damage taken values.
	end
	return returnDamage
end
function mjz_luna_under_the_moonlight:Stun(target, duration, bDelay)
	if not target or target:IsNull() then return end
	local delay = false
	if bDelay then delay = Bdelay end
	return target:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = duration, delay = delay})
end
function mjz_luna_under_the_moonlight:FireParticle(effect, attach, owner, cps)
	local FX = ParticleManager:CreateParticle(effect, attach, owner)
	if cps then
		for cp, value in pairs(cps) do
			if type(value) == "userdata" then
				ParticleManager:SetParticleControl(FX, tonumber(cp), value)
			elseif type(value) == "table" then
				ParticleManager:SetParticleControlEnt(FX, cp, value.owner or owner, value.attach or attach, value.point or "attach_hitloc", (value.owner or owner):GetAbsOrigin(), true)
			else
				ParticleManager:SetParticleControlEnt(FX, cp, owner, attach, value, owner:GetAbsOrigin(), true)
			end
		end
	end
	ParticleManager:ReleaseParticleIndex(FX)
end
-----------------------------------------------------------------------


modifier_mjz_luna_under_the_moonlight = class ({})
local modifier_class = modifier_mjz_luna_under_the_moonlight

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable()	-- 能否被驱散
	return false
end
function modifier_class:AllowIllusionDuplicate()
    return true
end    	
function modifier_class:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        if not parent:HasModifier(modifier_buffa) then
            parent:AddNewModifier(caster, ability, modifier_buffa, {})
            local mbuf = parent:FindModifierByName(modifier_buffa)
            local mbuf_c = caster:FindModifierByName(modifier_buffa)
            mbuf:SetStackCount( mbuf_c:GetStackCount() + 1 )
        end   
    end               
    --self:SetStackCount(self:GetStackCount()+ 1)
end

if IsServer() then
	function modifier_class:DeclareFunctions()
		local funcs = {
            MODIFIER_EVENT_ON_ATTACK,
            -- MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		}
		return funcs
	end
	
	function modifier_class:OnAttack(keys)
		if keys.attacker ~= self:GetParent() then return nil end
		if keys.target:IsBuilding() then return nil end
		-- if not self:GetParent():HasScepter() then return nil end
		-- if not self:GetParent():IsRangedAttacker() then return nil end
		-- if self:GetParent():PassivesDisabled() then return nil end
		-- if TargetIsFriendly(self:GetParent(), keys.target) then return nil end
		if keys.target:IsMagicImmune() then return nil end
		-- if keys.target:IsPhantom() then return nil end
		if not IsInToolsMode() and keys.target:GetTeamNumber() == self:GetParent():GetTeamNumber() then return nil end
		if not self:GetAbility() then return nil end

		local attacker = keys.attacker
		local target = keys.target
		local victim = target
		local ability = self:GetAbility()
		local proc_chance = ability:GetSpecialValueFor("proc_chance")
		--local LUNA_LUCENT_BEAM = "luna_lucent_beam"
		

        if RollPercentage( proc_chance ) then
            --local isInNight = not GameRules:IsDaytime()
            --local beam = attacker:FindAbilityByName(LUNA_LUCENT_BEAM)
            --if beam and beam:GetLevel() > 0 or isInNight then
                -- attacker:CastAbilityOnTarget(target, beam, -1)
                -- attacker:SetCursorCastTarget(target)
                -- beam:OnSpellStart()
                ability:LucentBeam(target)
                local modifier_buffa = "modifier_mjz_luna_under_the_moonlight_buff"
                local mbuf = attacker:FindModifierByName(modifier_buffa)
                if mbuf ~= nil then
                    mbuf:SetStackCount( mbuf:GetStackCount() + 1 )
                end                
            --end
		end

	end	

    -- function modifier_class:GetModifierPreAttack_BonusDamage( )
    --     return -1000
    -- end
end
---------------------------------------------------
---------------------------------------------------
function modifier_mjz_luna_under_the_moonlight_buff:IsHidden()
    return false
end
function modifier_mjz_luna_under_the_moonlight_buff:IsDebuff()
    return false
end
function modifier_mjz_luna_under_the_moonlight_buff:IsPurgable()
    return false
end
function modifier_mjz_luna_under_the_moonlight_buff:RemoveOnDeath()
    return false
end
function modifier_mjz_luna_under_the_moonlight_buff:AllowIllusionDuplicate()
    return true
end    
function modifier_mjz_luna_under_the_moonlight_buff:DeclareFunctions()
    --if not IsServer() then return end
    return {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS
    }     
end
function modifier_mjz_luna_under_the_moonlight_buff:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if parent:IsIllusion() then
        
        local mod1 = "modifier_mjz_luna_under_the_moonlight_buff"
       -- print("ilusion")
        local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
        if owner then       
            if parent:HasModifier(mod1) then
                local modifier1 = parent:FindModifierByName(mod1)
                local modifier2 = owner:FindModifierByName(mod1)
                modifier1:SetStackCount(modifier2:GetStackCount())
               -- print("lunastuf")
            end    
        end    
    end

    --self.buff = self
    --if not parent:HasModifier("modifier_mjz_luna_under_the_moonlight_buff") then
    --    parent:AddNewModifier(parent, ability, "modifier_mjz_luna_under_the_moonlight_buff", {})
   -- end
        
    --self:SetStackCount(self:GetStackCount()+ 1)
end
function modifier_mjz_luna_under_the_moonlight_buff:GetModifierSpellAmplify_Percentage()
    local ability = self:GetAbility()
    return self:GetStackCount() * ability:GetSpecialValueFor("spell_amp")
end
function modifier_mjz_luna_under_the_moonlight_buff:GetModifierHealthBonus()
    local ability = self:GetAbility()
    return self:GetStackCount() * ability:GetSpecialValueFor("bonus_hp")
end 
function modifier_mjz_luna_under_the_moonlight_buff:GetModifierManaBonus()
    local ability = self:GetAbility()
    return self:GetStackCount() * ability:GetSpecialValueFor("bonus_mp")
end
function modifier_mjz_luna_under_the_moonlight_buff:GetModifierBonusStats_Agility()
    local ability = self:GetAbility()
    return self:GetStackCount() * ability:GetSpecialValueFor("bonus_agi")
end  

--[[function modifier_mjz_luna_under_the_moonlight:OnRefresh()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local stack = ability:GetSpecialValueFor("mana_per_hit")
    local final_stack = stack / 4
    local mbuff = caster:FindModifierByName(modifier_buffa)
    if mbuff ~= nil then
        mbuff:SetStackCount( mbuff:GetStackCount() + math.ceil( final_stack ) )
        caster:CalculateStatBonus()
    end    
    --[[if RandomInt( 0,100 ) < ability:GetSpecialValueFor("stack_chance") then
        self:SetStackCount(self:GetStackCount() + math.ceil( final_stack ))
    end]]   
--end


---------------------------------------------------------------------------------------

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

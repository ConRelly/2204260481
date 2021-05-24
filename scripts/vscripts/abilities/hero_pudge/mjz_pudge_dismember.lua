
local THIS_LUA = "abilities/hero_pudge/mjz_pudge_dismember.lua"
local MODIFIER_LUA = "modifiers/hero_pudge/modifier_mjz_pudge_dismember.lua"

LinkLuaModifier( "modifier_mjz_pudge_dismember_duration", THIS_LUA, LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mjz_pudge_dismember", MODIFIER_LUA, LUA_MODIFIER_MOTION_NONE )


-----------------------------------------------------------------

mjz_pudge_dismember = class({})
local ability_class = mjz_pudge_dismember

function ability_class:GetConceptRecipientType()
	return DOTA_SPEECH_USER_ALL
end

function ability_class:SpeakTrigger()
	return DOTA_ABILITY_SPEAK_CAST
end

function ability_class:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
	return self.BaseClass.GetBehavior( self )
end

-- function ability_class:GetCastRange(vLocation, hTarget)
--     if self:GetCaster():HasScepter() then
--         return self:GetSpecialValueFor("scepter_aoe")
--     end
-- 	return self.BaseClass.GetCastRange( vLocation, hTarget )
-- end

function ability_class:GetAOERadius()
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_aoe")
    end
	return 0
end

function ability_class:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasScepter() then
        cooldown = self:GetSpecialValueFor("scepter_cooldown")
    end
    return cooldown
end

function ability_class:GetChannelAnimation()
	return ACT_DOTA_CHANNEL_ABILITY_4
end

function ability_class:GetChannelTime()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor( "duration" )
    local mName = "modifier_mjz_pudge_dismember_duration"
    if caster:HasModifier(mName) then
        duration = duration + 1.0
    else
        if IsServer() then
            local sb = caster:FindAbilityByName("special_bonus_unique_mjz_pudge_dismember_duration")
            if sb and sb:GetLevel() > 0 then
                if not caster:HasModifier(mName) then
                    caster:AddNewModifier(caster, self, mName, {})
                end
            end
        end
    end
    return duration
end

function ability_class:OnAbilityPhaseStart()
    if IsServer() then
        local ability = self
        local caster = self:GetCaster()
        self.hVictims = {}
        if self:GetCaster():HasScepter() then
            -- local point = caster:GetAbsOrigin()
            local point = self:GetCursorPosition()
            local radius = ability:GetSpecialValueFor("scepter_aoe") + caster:GetCastRangeBonus()
            self.hVictims = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
        else
            self.hVictims[1] = self:GetCursorTarget()
        end
	end

	return true
end

function ability_class:OnChannelFinish( bInterrupted )
    if not IsServer() then
       return 
    end
    if self.hVictims ~= nil then
        for _,victim in pairs(self.hVictims) do
            victim:RemoveModifierByName( "modifier_mjz_pudge_dismember" )
        end
	end
end


function ability_class:OnSpellStart()
	if IsServer() then
		local ability = self
        local caster = self:GetCaster()

        PM_FireParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack1"})
        PM_FireParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack2"})
        
        self.counter = 0

        local cooldown = self:GetSpecialValueFor("scepter_cooldown")
        self:EndCooldown()
        self:StartCooldown(cooldown)
        
        if self.hVictims and #self.hVictims > 0 then
            for _,victim in pairs(self.hVictims) do
                if victim:TriggerSpellAbsorb( self ) then
                    if #self.hVictims == 1 then
                        caster:Interrupt()
                    end
                else
                    victim:AddNewModifier( caster, ability, "modifier_mjz_pudge_dismember", { duration = self:GetChannelTime() } )
                    victim:Interrupt()
                end
            end
        else
            caster:Interrupt()
        end
	end
end

function ability_class:OnChannelThink(flInterval)
	local caster = self:GetCaster()
	-- local endPoint = caster:GetAbsOrigin() + caster:GetForwardVector() * self:GetTrueCastRange()
	-- local speed = 1.5 * flInterval
	-- self.counter = self.counter + flInterval
	-- local enemies = self.hVictims
	-- for _,enemy in pairs(enemies) do
	-- 	if CalculateDistance(enemy, caster) > caster:GetAttackRange() then
	-- 		enemy:SetAbsOrigin(enemy:GetAbsOrigin() - CalculateDirection(enemy, caster) * speed)
	-- 	end
	-- end

	if self.counter > 0.25 then
		EmitSoundOn("Hero_Pudge.Dismember", caster)
		EmitSoundOn("Hero_Pudge.DismemberSwings", caster)
		PM_FireParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack1"})
        PM_FireParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack2"})
        
		self.counter = 0
	end
end

---------------------------------------------------------------------------------------

modifier_mjz_pudge_dismember_duration = class({})
function modifier_mjz_pudge_dismember_duration:IsHidden()
    return true
end
function modifier_mjz_pudge_dismember_duration:IsPurgable()
    return false
end
-- 效果永久，死亡不消失
function modifier_mjz_pudge_dismember_duration:GetAttributes() 
	return MODIFIER_ATTRIBUTE_PERMANENT 
end



------------------------------------------------------------------------------------------

function PM_FireParticle(effect, attach, owner, cps)
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


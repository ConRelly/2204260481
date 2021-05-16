LinkLuaModifier("modifier_mjz_sandking_epicenter","modifiers/hero_sand_king/modifier_mjz_sandking_epicenter.lua", LUA_MODIFIER_MOTION_NONE)

mjz_sandking_epicenter = class({})
local ability_class = mjz_sandking_epicenter

function ability_class:OnAbilityPhaseStart()
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()
		local p_name = "particles/units/heroes/hero_sandking/sandking_epicenter_tell.vpcf"
		self.nPreviewFX = ParticleManager:CreateParticle( p_name, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControlEnt( self.nPreviewFX, 0, caster, PATTACH_POINT_FOLLOW, "attach_tail", caster:GetOrigin(), true )
	end
	return true
end

function ability_class:OnAbilityPhaseInterrupted()
	if IsServer() then
		StopSoundOn("Ability.SandKing_Epicenter.spell", self:GetCaster())
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
	end
end

function ability_class:GetChannelAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end

function ability_class:GetPlaybackRateOverride()
	return 1
end


function ability_class:OnSpellStart()
	if IsServer() then
		EmitSoundOn("Ability.SandKing_Epicenter.spell", caster)
	end
end

function ability_class:OnChannelFinish( bInterrupted )
	if IsServer() then
		local ability = self
		local caster = self:GetCaster()
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
		caster:AddNewModifier( caster, ability, "modifier_mjz_sandking_epicenter", {} )
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
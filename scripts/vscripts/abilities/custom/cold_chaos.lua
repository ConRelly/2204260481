if cold_chaos == nil then cold_chaos = class({}) end

LinkLuaModifier( "modifier_cold_chaos", "abilities/custom/cold_chaos.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_cold_chaos_deny", "abilities/custom/cold_chaos.lua", LUA_MODIFIER_MOTION_NONE )

function cold_chaos:IsRefreshable() return true end
function cold_chaos:IsStealable() return false end
 
local CONST_COOLDOWN_NOT_REDUC = 100

function cold_chaos:GetCooldown( nLevel )
    return self.BaseClass.GetCooldown( self, nLevel )
end

function cold_chaos:OnSpellStart()
    local duration = self:GetSpecialValueFor(  "duration" )
    

	local hTarget = self:GetCursorTarget()

    if hTarget then 
        hTarget:AddNewModifier( self:GetCaster(), self, "modifier_cold_chaos_deny", { duration = duration } )

        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), 9999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, 0, false )
        if #units > 0 then
            for _,unit in pairs(units) do
                if unit ~= hTarget then
                    unit:AddNewModifier( self:GetCaster(), self, "modifier_cold_chaos", { duration = duration, target = hTarget:entindex() } )
                end
            end
        end

        EmitSoundOn("Hero_Grimstroke.InkCreature.Returned", self:GetCaster())
        EmitSoundOn("Hero_Grimstroke.InkCreature.Death", self:GetCaster())
	end
end

if modifier_cold_chaos == nil then modifier_cold_chaos = class({}) end

modifier_cold_chaos.m_hTarget = nil

function modifier_cold_chaos:IsPurgable() return false end
function modifier_cold_chaos:IsHidden() return false end
function modifier_cold_chaos:RemoveOnDeath() return true end
function modifier_cold_chaos:GetStatusEffectName() return "particles/status_fx/status_effect_ancestral_spirit.vpcf" end
function modifier_cold_chaos:StatusEffectPriority() return 1000 end
function modifier_cold_chaos:GetHeroEffectName() return "particles/units/heroes/hero_sven/sven_gods_strength_hero_effect.vpcf" end
function modifier_cold_chaos:HeroEffectPriority() return 100 end
function modifier_cold_chaos:GetEffectName() return "particles/units/heroes/hero_dazzle/dazzle_armor_friend_ring.vpcf" end
function modifier_cold_chaos:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_cold_chaos:OnCreated(params)
    if IsServer() then
        self.m_hTarget = EntIndexToHScript(params.target)

        self:StartIntervalThink(1)
        self:OnIntervalThink()
  	end
end

function modifier_cold_chaos:OnIntervalThink()
    if IsServer() then
        if not self.m_hTarget or self.m_hTarget:IsNull() or not self.m_hTarget:IsAlive() then
            self:Destroy() return
        end 

        local order_caster =
        {
            UnitIndex = self:GetParent():entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = self.m_hTarget:entindex()
        }

        ExecuteOrderFromTable(order_caster)

        self:GetParent():SetForceAttackTarget(self.m_hTarget)
  	end
end


function modifier_cold_chaos:OnDestroy()
    if IsServer() then
        self:GetParent():Stop()
        self:GetParent():Interrupt()
        
        self:GetParent():SetForceAttackTarget(nil)

    	EmitSoundOn("Hero_Grimstroke.InkSwell.Cast", self:GetParent())
  	end
end

function modifier_cold_chaos:CheckState()
	local state = {
        [MODIFIER_STATE_SPECIALLY_DENIABLE] = true,
        [MODIFIER_STATE_PROVIDES_VISION] = true
	}

	return state
end

modifier_cold_chaos_deny = class({})

function modifier_cold_chaos_deny:IsPurgable() return false end
function modifier_cold_chaos_deny:IsHidden() return true end
function modifier_cold_chaos_deny:RemoveOnDeath() return false end


function modifier_cold_chaos_deny:CheckState()
	local state = {
        [MODIFIER_STATE_SPECIALLY_DENIABLE] = true,
        [MODIFIER_STATE_PROVIDES_VISION] = true
	}

	return state
end

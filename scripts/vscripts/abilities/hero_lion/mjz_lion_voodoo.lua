
local THIS_LUA = "abilities/hero_lion/mjz_lion_voodoo.lua"
LinkLuaModifier( "modifier_mjz_lion_voodoo", THIS_LUA, LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mjz_lion_voodoo_magical", THIS_LUA, LUA_MODIFIER_MOTION_NONE )

mjz_lion_voodoo = mjz_lion_voodoo or class({})

--------------------------------------------------------------------------------

function mjz_lion_voodoo:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return self.BaseClass.GetBehavior( self )
end

function mjz_lion_voodoo:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("aoe_radius")
	end
end

function mjz_lion_voodoo:GetAbilityTextureName()
    if self:GetCaster():HasScepter() then
		return "mjz_lion_voodoo_fish"
	end	 
	return "mjz_lion_voodoo"
end

function mjz_lion_voodoo:OnSpellStart()
    if not IsServer() then return end

	local hCaster 		= 	self:GetCaster()
	local hAbility		= 	self
	local hTarget  		= 	self:GetCursorTarget()
	local hPoint   		= 	self:GetCursorPosition()
	local radius   		= 	hAbility:GetTalentSpecialValueFor("aoe_radius")
	local soundName	   	= 	"Hero_Lion.Voodoo"

    if hCaster:HasScepter() then
		local enemies = hCaster:FindEnemyUnitsInRadius(hPoint, radius, {ability = hAbility})
		if #enemies > 0 then 
			EmitSoundOnLocationWithCaster(hPoint, soundName, hCaster)
			for i,enemy in ipairs(enemies) do
				self:SpellTarget(enemy)
			end
		end
	else
		EmitSoundOn( sound, hTarget )
		self:SpellTarget(hTarget)
    end

end

function mjz_lion_voodoo:SpellTarget( hTarget )
    local hCaster = self:GetCaster()
	local hAbility = self
	
	if hTarget:IsIllusion() then
		hTarget:Kill(hAbility, hCaster)
		return 
	end

	local duration = hAbility:GetTalentSpecialValueFor("duration")
	local reduce_magical_resistance = hAbility:GetTalentSpecialValueFor("reduce_magical_resistance")

	hTarget:AddNewModifier(hCaster, hAbility, "modifier_mjz_lion_voodoo", { duration = duration } )

	if reduce_magical_resistance > 0 then
		local mm = hTarget:AddNewModifier(hCaster, hAbility, "modifier_mjz_lion_voodoo_magical", { duration = duration })
		mm:SetStackCount(reduce_magical_resistance)
	end
end

--------------------------------------------------------------------------------

modifier_mjz_lion_voodoo = modifier_mjz_lion_voodoo or class({})

function modifier_mjz_lion_voodoo:IsHidden() return false end
function modifier_mjz_lion_voodoo:IsDebuff() return true end
function modifier_mjz_lion_voodoo:IsPurgable() return false end
function modifier_mjz_lion_voodoo:IsPurgeException() return false end

function modifier_mjz_lion_voodoo:CheckState()
	return {
		[ MODIFIER_STATE_HEXED ] = false,
		[ MODIFIER_STATE_MUTED ] = true,
		[ MODIFIER_STATE_DISARMED ] = true,
		[ MODIFIER_STATE_SILENCED ] = true,
		[ MODIFIER_STATE_BLOCK_DISABLED ] = true,
		[ MODIFIER_STATE_EVADE_DISABLED ] = true,
		[ MODIFIER_STATE_PASSIVES_DISABLED ] = false
	}
end

function modifier_mjz_lion_voodoo:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
        MODIFIER_PROPERTY_MODEL_CHANGE,
	}
	return funcs
end

function modifier_mjz_lion_voodoo:GetModifierMoveSpeedOverride() 
	return self.movespeed 
end
function modifier_mjz_lion_voodoo:GetModifierModelChange() 
	return self.model
end

function modifier_mjz_lion_voodoo:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed")
	self.model = "models/props_gameplay/frog.vmdl" 
	if self:GetCaster():HasScepter() then
		self.model = "models/items/hex/fish_hex/fish_hex.vmdl"
	end

	local partname = "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"
	local part = ParticleManager:CreateParticle(partname, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:ReleaseParticleIndex(part)
end


--------------------------------------------------------------------------------

modifier_mjz_lion_voodoo_magical = modifier_mjz_lion_voodoo_magical or class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self)
        return {
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        }
    end,
    CheckState              = function(self)
        return {
            -- [ MODIFIER_STATE_HEXED ] = true,
        }
    end,
})

function modifier_mjz_lion_voodoo_magical:GetModifierMagicalResistanceBonus( )
	return 0 - self:GetStackCount()
end


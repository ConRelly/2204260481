

modifier_mjz_rattletrap_rocket_flare = class({})
local modifier_class = modifier_mjz_rattletrap_rocket_flare

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
	function modifier_class:OnCreated(table)
		self:StartIntervalThink(1.0)
	end

	function modifier_class:OnIntervalThink()
        local ability = self:GetAbility()
        local caster = self:GetCaster()
        local parent = self:GetParent()

        if not ability:GetAutoCastState() then return nil end
        if not ability:IsFullyCastable() then return nil end
		if not ability:IsCooldownReady() then return nil end
		if parent:IsIllusion() then return nil end
		if not parent:IsRealHero() then return nil end
		if IsChanneling(parent) then return nil end		-- 施法中
		if parent:IsSilenced() then return nil end		-- 沉默中

		local radius_auto = ability:GetSpecialValueFor("radius_auto")
		local pos = parent:GetAbsOrigin()
		
		local enemy_list = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius_auto, 
			ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER, false)

        if #enemy_list > 0 then
			local first_enemy = enemy_list[1]
			
			--[[
				parent:SetCursorCastTarget(first_enemy)
				ability:OnSpellStart()
				ability:StartCooldown(ability:GetCooldownTimeRemaining())
			]]
			
			--[[
				local order = {
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					UnitIndex = parent:entindex(),
					Position = first_enemy:GetAbsOrigin(),
					AbilityIndex = ability:entindex()
				}
				ExecuteOrderFromTable(order)
			]]
			
			parent:CastAbilityOnPosition(first_enemy:GetAbsOrigin(), ability, parent:GetPlayerOwnerID())
        end
	end
end

-----------------------------------------------------------------------------------------

modifier_modifier_mjz_rattletrap_rocket_flare_vision = class({})
local modifier_vision = modifier_modifier_mjz_rattletrap_rocket_flare_vision

function modifier_vision:IsDebuff()			return true end
function modifier_vision:IsHidden() 			return false end
function modifier_vision:IsPurgable() 		return true end
function modifier_vision:IsPurgeException() 	return true end
function modifier_vision:CheckState() 
	return {
		[MODIFIER_STATE_PROVIDES_VISION] = true,
	} 
end

function modifier_vision:OnCreated()
	if IsServer() then
		local parent = self:GetParent()
		local p_name = "particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare_sparks.vpcf"
		local pfx = ParticleManager:CreateParticle(p_name, PATTACH_CUSTOMORIGIN, parent)
		ParticleManager:SetParticleControlEnt(pfx, 3, parent, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

-----------------------------------------------------------------------------------------

modifier_modifier_mjz_rattletrap_rocket_flare_dummy = class({})
local modifier_dummy = modifier_modifier_mjz_rattletrap_rocket_flare_dummy

function modifier_dummy:IsHidden() return true end
function modifier_dummy:IsPurgable() return false end

function modifier_dummy:CheckState() 
	local state = {
		[MODIFIER_STATE_PROVIDES_VISION] 	    = true,
		[MODIFIER_STATE_INVULNERABLE] 			= true,
		[MODIFIER_STATE_NO_HEALTH_BAR] 			= true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]		= true,
		[MODIFIER_STATE_NOT_ON_MINIMAP]		    = true,
		[MODIFIER_STATE_UNSELECTABLE]		    = true,
	}
	return state
end


-----------------------------------------------------------------------------------------

function IsChanneling(unit)
	local ability_count = unit:GetAbilityCount()
	for i=0,(ability_count-1) do
		local ability = unit:GetAbilityByIndex(i)
		if ability ~= nil then
			if ability:IsChanneling() then
				return true
			end
		end
	end
	for itemSlot = 0, 5, 1 do
		local Item = unit:GetItemInSlot( itemSlot )
		if Item ~= nil then
			if Item:IsChanneling() then
				return true
			end
		end
	end
	return false
end


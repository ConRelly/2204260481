LinkLuaModifier("modifier_mjz_ursa_earthshock_movement","abilities/hero_ursa/mjz_ursa_earthshock.lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_mjz_ursa_earthshock","abilities/hero_ursa/mjz_ursa_earthshock.lua", LUA_MODIFIER_MOTION_NONE)

mjz_ursa_earthshock = class({})
local ability_class = mjz_ursa_earthshock


function ability_class:GetAOERadius()
	local caster = self:GetCaster()
	local base_radius = self:GetSpecialValueFor("shock_radius") + talent_value(caster, "special_bonus_unique_mjz_ursa_earthshock_radius") + talent_value(caster, "special_bonus_unique_ursa_5")

	return base_radius
end


function ability_class:OnSpellStart()
	if not IsServer() then return end
	if not self:GetCaster():HasModifier("modifier_mjz_ursa_earthshock_movement") then
		self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_1)
		
		local direction_vector = self:GetCaster():GetForwardVector() * self:GetSpecialValueFor("hop_distance")

		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_mjz_ursa_earthshock_movement", {
			duration		= self:GetSpecialValueFor("hop_duration"),
			distance		= self:GetSpecialValueFor("hop_distance"),
			direction_x		= direction_vector.x,
			direction_y 	= direction_vector.y,
			diretion_z 		= direction_vector.z,
			height			= self:GetSpecialValueFor("hop_height")
		})
	end
end

function ability_class:ApplyEarthShock()
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor('duration')
		local radius = self:GetSpecialValueFor("shock_radius") + talent_value(caster, "special_bonus_unique_mjz_ursa_earthshock_radius") + talent_value(caster, "special_bonus_unique_ursa_5")
		local str_damage_pct = self:GetSpecialValueFor("str_damage_pct")

		local base_damage = self:GetSpecialValueFor("damage") + caster:GetStrength() * str_damage_pct / 100

		local enemy_list = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)

		for _,enemy in pairs(enemy_list) do
			local damage = base_damage
			if caster:HasModifier("modifier_item_aghanims_shard") then
				local fs = caster:FindAbilityByName("ursa_fury_swipes")
				if fs then
					local fury_swipes = enemy:AddNewModifier(caster, fs, "modifier_ursa_fury_swipes_damage_increase", {duration = fs:GetSpecialValueFor("bonus_reset_time")})
					fury_swipes:SetStackCount(fury_swipes:GetStackCount() + 5)
					damage = base_damage + (fury_swipes:GetStackCount() * fs:GetSpecialValueFor("damage_per_stack"))
				end
			end
			ApplyDamage({
				victim = enemy,
				attacker = caster,
				damage = damage,
				damage_type = self:GetAbilityDamageType()
			})

			enemy:AddNewModifier(caster, self, "modifier_mjz_ursa_earthshock", {duration = duration})
		end

		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_ursa/ursa_earthshock.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, caster:GetOrigin() )
		ParticleManager:SetParticleControlForward( nFXIndex, 0, caster:GetForwardVector() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector(radius / 2, radius / 2, radius / 2) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		EmitSoundOn("Hero_Ursa.Earthshock", caster)
	end
end

---------------------------------------------------------------------------------------

modifier_mjz_ursa_earthshock = class({})
local modifier_class = modifier_mjz_ursa_earthshock

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return true end
function modifier_class:IsDebuff() return true end

function modifier_class:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_class:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor('movement_slow')
end

-----------------------------------------------------------------------------------------
-- https://github.com/EarthSalamander42/dota_imba/blob/master/game/dota_addons/dota_imba_reborn/scripts/vscripts/components/abilities/heroes/hero_ursa.lua
modifier_mjz_ursa_earthshock_movement = modifier_mjz_ursa_earthshock_movement or class({})

-- Gonna copy-paste my generic motion controller code here cause there's too many changes that need to be made (and I can't copy the class itself for some reason)

function modifier_mjz_ursa_earthshock_movement:IsHidden()		return true end
function modifier_mjz_ursa_earthshock_movement:IsPurgable()		return false end
-- function modifier_mjz_ursa_earthshock_movement:GetAttributes()
-- 	return MODIFIER_ATTRIBUTE_MULTIPLE
-- end

function modifier_mjz_ursa_earthshock_movement:OnCreated(params)
	if not IsServer() then return end
	
	self.distance			= params.distance
	self.direction			= Vector(params.direction_x, params.direction_y, params.direction_z):Normalized()
	self.duration			= params.duration
	self.height				= params.height

	self.velocity		= self.direction * self.distance / self.duration
	
	self.vertical_velocity		= 4 * self.height / self.duration
	self.vertical_acceleration	= -(8 * self.height) / (self.duration * self.duration)
	
	-- Do NOT continue with motion controllers if rooted; trying to be finnicky with this will cause crashes
	if self:GetParent():IsRooted() then return end
	
	if self.distance > 0 then
		if self:ApplyHorizontalMotionController() == false then 
			self:Destroy()
			return
		end
	end
	if self.height >= 0 then
		if self:ApplyVerticalMotionController() == false then 
			self:Destroy()
			return
		end
	end
end

function modifier_mjz_ursa_earthshock_movement:OnDestroy()
	if not IsServer() then return end
	
	self:GetParent():RemoveHorizontalMotionController(self)
	self:GetParent():RemoveVerticalMotionController(self)
	
	if self:GetAbility() then
		self:GetAbility():ApplyEarthShock()
	end

	if self.EndCallback then
		self.EndCallback()
	end
	self:GetParent():InterruptMotionControllers( true )
end

function modifier_mjz_ursa_earthshock_movement:UpdateHorizontalMotion(me, dt)
	if not IsServer() then return end
	
	me:SetAbsOrigin(me:GetAbsOrigin() + self.velocity * dt)
end

-- This typically gets called if the caster uses a position breaking tool (ex. Blink Dagger) while in mid-motion
function modifier_mjz_ursa_earthshock_movement:OnHorizontalMotionInterrupted()
	self:Destroy()
end

function modifier_mjz_ursa_earthshock_movement:UpdateVerticalMotion(me, dt)
	if not IsServer() then return end
	
	me:SetAbsOrigin(me:GetAbsOrigin() + Vector(0, 0, self.vertical_velocity) * dt)

	self.vertical_velocity = self.vertical_velocity + (self.vertical_acceleration * dt)
end

-- -- This typically gets called if the caster uses a position breaking tool (ex. Earth Spike) while in mid-motion
function modifier_mjz_ursa_earthshock_movement:OnVerticalMotionInterrupted()
	self:Destroy()
end

-- Setter
function modifier_mjz_ursa_earthshock_movement:SetEndCallback( func ) 
	self.EndCallback = func
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
function GetTalentSpecialValueFor(ability, value, keyName)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m[keyName or "LinkedSpecialBonus"]
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
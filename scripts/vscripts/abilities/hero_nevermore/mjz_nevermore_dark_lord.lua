local THIS_LUA = "abilities/hero_nevermore/mjz_nevermore_dark_lord.lua"
LinkLuaModifier("modifier_mjz_nevermore_dark_lord", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_nevermore_dark_lord_aura", THIS_LUA, LUA_MODIFIER_MOTION_NONE)

mjz_nevermore_dark_lord = mjz_nevermore_dark_lord or class({})

function mjz_nevermore_dark_lord:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function mjz_nevermore_dark_lord:GetIntrinsicModifierName()
	return "modifier_mjz_nevermore_dark_lord"
end

function mjz_nevermore_dark_lord:OnOwnerDied()
    if not IsServer() then return end
    self:ReleaseSouls()
end

function mjz_nevermore_dark_lord:ReleaseSouls(bDeath)
	local caster = self:GetCaster()

	local startPos = caster:GetAbsOrigin()
	local direction = caster:GetForwardVector()

	local distance = self:GetTalentSpecialValueFor("radius")
	local speed = self:GetTalentSpecialValueFor("requiem_speed")
	local width_start = self:GetTalentSpecialValueFor("requiem_width_start")
	local width_end = self:GetTalentSpecialValueFor("requiem_width_end")

	self.damage = self:_CalcDamage()
	local projectiles = 18
	if bDeath then projectiles = math.floor(projectiles) / 2 end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_a.vpcf", PATTACH_ABSORIGIN, caster, {[1]=Vector(projectiles, 0, 0),[2]=caster:GetAbsOrigin()})
	ParticleManager:FireParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf", PATTACH_ABSORIGIN, caster, {[1]=Vector(projectiles, 0, 0)})

	local angle = 360 / projectiles

    EmitSoundOn("Hero_Nevermore.RequiemOfSouls", caster)
    
    local _ToRadians = angle * math.pi / 180
    for i=0, projectiles do
		direction = self:_RotateVector2D(direction, _ToRadians )
		
		local particle_lines_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle_lines_fx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_lines_fx, 1, direction*speed)
		ParticleManager:SetParticleControl(particle_lines_fx, 2, Vector(0, distance/speed, 0))
		ParticleManager:ReleaseParticleIndex(particle_lines_fx)

        self:FireLinearProjectile("", direction*speed, distance, width_start, 
        { width_end = width_end, extraData={secondProj=false} }, false, true, width_end)
	end
end

function mjz_nevermore_dark_lord:OnProjectileHit_ExtraData(hTarget, vLocation, extraData)
	local caster = self:GetCaster()
	local secondProj = extraData.secondProj

	if secondProj == 0 then
		secondProj = false
	else
		secondProj = true
	end

	if hTarget and not hTarget:TriggerSpellAbsorb( self ) then
		EmitSoundOn("Hero_Nevermore.RequiemOfSouls.Damage", hTarget)

		-- hTarget:AddNewModifier(caster, self, "modifier_shadow_fiend_requiem", {Duration = self:GetTalentSpecialValueFor("reduction_duration")})
		self:DealDamage(caster, hTarget, self.damage, {}, 0)
	end
end


function mjz_nevermore_dark_lord:_CalcDamage( hEnemy )
    local hCaster = self:GetCaster()
    local hAbility = self
    local damage_per_soul = hAbility:GetTalentSpecialValueFor("damage_per_soul")
    local m_soul_name = "modifier_mjz_nevermore_necromastery"
    local m_soul = hCaster:FindModifierByName(m_soul_name)

    local damage = 0
    if m_soul ~= nil then
        damage = m_soul:GetStackCount() * damage_per_soul
    end

    return damage
end


function mjz_nevermore_dark_lord:_HealSelf(damage)
    local hCaster = self:GetCaster()
    local hAbility = self
    if hCaster:IsAlive() and hCaster:HasScepter() then
        local flAmount = damage
        hCaster:Heal(flAmount, hAbility)
    end
end

function mjz_nevermore_dark_lord:_RotateVector2D(vector, theta)
    local xp = vector.x*math.cos(theta)-vector.y*math.sin(theta)
    local yp = vector.x*math.sin(theta)+vector.y*math.cos(theta)
    return Vector(xp,yp,vector.z):Normalized()
end

---------------------------------------------------------------------------------------------

modifier_mjz_nevermore_dark_lord = modifier_mjz_nevermore_dark_lord or class({})

function modifier_mjz_nevermore_dark_lord:IsHidden() return true end
function modifier_mjz_nevermore_dark_lord:IsPurgable() return false end

--------------------------------------------------------------

function modifier_mjz_nevermore_dark_lord:IsAura()
	return true
end

function modifier_mjz_nevermore_dark_lord:GetModifierAura()
	return "modifier_mjz_nevermore_dark_lord_aura"
end

function modifier_mjz_nevermore_dark_lord:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_mjz_nevermore_dark_lord:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_mjz_nevermore_dark_lord:GetAuraSearchFlags()
    -- return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
    return self:GetAbility():GetAbilityTargetFlags()
end

function modifier_mjz_nevermore_dark_lord:GetAuraRadius()
    -- local base_range = self:GetAbility():GetSpecialValueFor( "range" ) 
    -- local bonus_range = self:GetParent():GetCastRangeBonus()
    -- return base_range + bonus_range
    return self:GetAbility():GetAOERadius()
end


---------------------------------------------------------------------------------------------------


modifier_mjz_nevermore_dark_lord_aura = modifier_mjz_nevermore_dark_lord_aura or class({})

function modifier_mjz_nevermore_dark_lord_aura:IsHidden() return false end
function modifier_mjz_nevermore_dark_lord_aura:IsPurgable() return true end
function modifier_mjz_nevermore_dark_lord_aura:IsDebuff() return true end

function modifier_mjz_nevermore_dark_lord_aura:DeclareFunctions()
    funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
    return funcs
end

function modifier_mjz_nevermore_dark_lord_aura:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("presence_armor_reduction")
end
function modifier_mjz_nevermore_dark_lord_aura:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("presence_resist_reduction")
end

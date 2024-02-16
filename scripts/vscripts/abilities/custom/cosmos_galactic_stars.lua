cosmos_galactic_stars = class({})
LinkLuaModifier( "modifier_cosmos_galactic_stars", "abilities/custom/cosmos_galactic_stars.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_cosmos_galactic_stars_thinker", "abilities/custom/cosmos_galactic_stars.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_cosmos_galactic_stars_damage", "abilities/custom/cosmos_galactic_stars.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_cosmos_galactic_stars_enhance", "abilities/custom/cosmos_galactic_stars.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_cosmos_galactic_stars_enhance_speed", "abilities/custom/cosmos_galactic_stars.lua", LUA_MODIFIER_MOTION_NONE )

function cosmos_galactic_stars:GetManaCost( level )
	if self:GetCaster():HasModifier("modifier_cosmos_galactic_stars_enhance") then
		return 0
	else
		return self.BaseClass.GetManaCost(self, level)
	end
end

local enchant_modif = 0
function cosmos_galactic_stars:OnSpellStart()
--[[ 	local caster = self:GetCaster()
	if caster:HasModifier("modifier_cosmos_galactic_stars_enhance") then
		caster:RemoveModifierByName("modifier_cosmos_galactic_stars_enhance")
	else
		caster:AddNewModifier(caster, self, "modifier_cosmos_galactic_stars_enhance", {duration = self:GetSpecialValueFor("duration")})
		self:UseResources( false,false, false, true )
		enchant_modif = 1		
	end ]]
end
modifier_cosmos_galactic_stars_enhance_speed = class({})
function modifier_cosmos_galactic_stars_enhance_speed:IsDebuff() return false end
function modifier_cosmos_galactic_stars_enhance_speed:IsHidden() return true end
function modifier_cosmos_galactic_stars_enhance_speed:IsPurgable() return false end
function modifier_cosmos_galactic_stars_enhance_speed:GetTexture() return "" end
function modifier_cosmos_galactic_stars_enhance_speed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
	}
	return funcs
end
function modifier_cosmos_galactic_stars_enhance_speed:CheckState()
	return {[MODIFIER_STATE_UNSLOWABLE] = true}
end
function modifier_cosmos_galactic_stars_enhance_speed:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movespeed")
end
function modifier_cosmos_galactic_stars_enhance_speed:GetModifierIgnoreMovespeedLimit() return 1 end
modifier_cosmos_galactic_stars_enhance = class({})
function modifier_cosmos_galactic_stars_enhance:IsDebuff() return false end
function modifier_cosmos_galactic_stars_enhance:IsHidden() return true end
function modifier_cosmos_galactic_stars_enhance:IsPurgable() return false end
function modifier_cosmos_galactic_stars_enhance:IsPurgeException() return false end
function modifier_cosmos_galactic_stars_enhance:GetTexture() return "" end



function cosmos_galactic_stars:GetIntrinsicModifierName()
	return "modifier_cosmos_galactic_stars"
end



modifier_cosmos_galactic_stars_damage = class({})
function modifier_cosmos_galactic_stars_damage:IsDebuff() return true end
function modifier_cosmos_galactic_stars_damage:IsHidden() return true end
function modifier_cosmos_galactic_stars_damage:IsPurgable() return false end
function modifier_cosmos_galactic_stars_damage:IsPurgeException() return false end

modifier_cosmos_galactic_stars_thinker = class({})
function modifier_cosmos_galactic_stars_thinker:OnCreated( kv )
	if IsServer() then
		local thinker = self:GetParent()
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		self.direction = (ability:GetCursorPosition() - caster:GetAbsOrigin()):Normalized()
		self.radius = ability:GetSpecialValueFor("radius")
		self.speed =  4
		self.hitbox = 60
		self.angle = kv.startangle
		self.ID = kv.starID
		self.maxstars = ability:GetSpecialValueFor("scepter_stars") + ability:GetSpecialValueFor("stars")
		self.minstars = ability:GetSpecialValueFor("stars")
		self.sceptercheck = false
		self.hide = 0
		thinker:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
		local particle_cast = "particles/econ/items/wisp/wisp_guardian_ti7.vpcf"
		
		self.particle = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl( self.particle, 0, thinker:GetAbsOrigin() )

		self:AddParticle(
			self.particle,
			false, -- bDestroyImmediately
			false, -- bStatusEffect
			-1, -- iPriority
			false, -- bHeroEffect
			false -- bOverheadEffect
		)
		
		self:StartIntervalThink(0.06)
	end
end
function modifier_cosmos_galactic_stars_thinker:OnIntervalThink()
	local thinker = self:GetParent()
	local ability = self:GetAbility()
	if not self:GetCaster():IsAlive() then
		self:Destroy()
		return
	end	
	if not ability then return end

	--local ability2 = self:GetCaster():GetAbilityByIndex(1)
	local ability2 = self:GetAbility()
	local thinker_pos = thinker:GetAbsOrigin()
	local caster = self:GetCaster()
	local casterpoint = caster:GetAbsOrigin()
	local rotation_time = ability:GetSpecialValueFor("time")
	local cooldown = ability:GetSpecialValueFor("cooldown")
	local damage = ability:GetSpecialValueFor("damage")
	local mana_damage = caster:GetMana() * ability:GetSpecialValueFor("mana_damage_pct")/100
	local minradius = ability:GetSpecialValueFor("radius")
	local plusdamage = ability2:GetSpecialValueFor("bonus_damage")
	local outer_limit = ability2:GetSpecialValueFor("outer_limit")
	local damage_pct = ability2:GetSpecialValueFor("damage_pct")
	local plusspeed = ability2:GetSpecialValueFor("speed_multiplier")
	local buffduration = ability2:GetSpecialValueFor("duration")
	local total_damage = 0
	local modifier = caster:FindModifierByName("modifier_cosmos_galactic_stars_enhance")
	local hp_ptc = caster:GetHealthPercent()
	if not caster:IsAlive() or caster:IsStunned() or (hp_ptc > 50 and self.ID >= self.maxstars - 1) then
		self.hide = -5000
	else
		self.hide = 0
	end
	
	self.speed = 4.0
	
	if caster:HasModifier("modifier_cosmos_galactic_stars_enhance") then
		total_damage = (damage + mana_damage) * (((damage_pct) / 100) + 1)
		self.speed = (plusspeed * (modifier:GetRemainingTime() / buffduration) * 3 ) + 1
		if self.radius < outer_limit then
			self.radius = self.radius + 8
		else
			self.radius = outer_limit
		end
		self.hitbox = 200
	else
		total_damage = (damage + mana_damage)
		if self.radius > minradius then
			self.radius = self.radius - 8
		else
			self.radius = minradius
		end
		self.hitbox = 100
	end
	
	if not caster:HasModifier("modifier_cosmos_galactic_stars_enhance") and enchant_modif == 1 and caster:IsAlive() then
		caster:AddNewModifier(caster, ability, "modifier_cosmos_galactic_stars_enhance_speed", {duration = ability:GetSpecialValueFor("movespeed_duration")})
		enchant_modif = 0
	end
	
	ParticleManager:SetParticleControl( self.particle, 0, self:GetParent():GetOrigin() )
	
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), thinker:GetAbsOrigin(), nil, self.hitbox, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	for _,enemy in pairs(enemies) do
		if self.hide == 0 then
			local modifier = enemy:FindModifierByName("modifier_cosmos_galactic_stars_damage")
			if not enemy:HasModifier("modifier_cosmos_galactic_stars_damage") or modifier:GetCaster():GetEntityIndex() ~= thinker:GetEntityIndex() then
				local damageTable = {
					victim = enemy,
					attacker = caster,
					damage = total_damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = ability, --Optional.
				}
				ApplyDamage( damageTable )
				if caster:HasModifier("modifier_cosmos_galactic_stars_enhance") then
					local big_particle = ParticleManager:CreateParticle( "particles/econ/items/wisp/wisp_guardian_explosion_ti7.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
					ParticleManager:SetParticleControl( big_particle, 0, enemy:GetOrigin() + Vector(0, 0, 100) )
					ParticleManager:ReleaseParticleIndex( big_particle )
					
					EmitSoundOn( "Hero_Wisp.Spirits.Target", enemy )
				else
					local small_particle = ParticleManager:CreateParticle( "particles/econ/items/wisp/wisp_guardian_explosion_small_ti7.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
					ParticleManager:SetParticleControl( small_particle, 0, enemy:GetOrigin() + Vector(0, 0, 100) )
					ParticleManager:ReleaseParticleIndex( small_particle )
					
					EmitSoundOn( "Hero_Wisp.Spirits.TargetCreep", enemy )
				end
				enemy:AddNewModifier(thinker, ability, "modifier_cosmos_galactic_stars_damage", {duration = cooldown})
			end
		end
	end
	
	--get healt percent
	local hp_ptc = caster:GetHealthPercent()
		
	if hp_ptc < 50 and self.sceptercheck == false then
		self.sceptercheck = true
		self.angle = self.angle - ((360/self.minstars) * (self.ID/self.maxstars))
	end
	
	if hp_ptc > 50 and self.sceptercheck == true then
		self.sceptercheck = false
		self.angle = self.angle + ((360/self.minstars) * (self.ID/self.maxstars))
	end
	
	self.angle = self.angle + ((360 / rotation_time * 0.01) * self.speed)
	if self.angle >= 360 then
		self.angle = self.angle - 360
	end
	
	local angle = (self.angle * (math.pi / 180))
	
	local position = Vector(math.sin(angle) * self.radius, math.cos(angle) * self.radius, GetGroundHeight(thinker:GetOrigin(), nil) - casterpoint.z + 100 + self.hide)
	thinker:SetAbsOrigin(casterpoint + position)
end

modifier_cosmos_galactic_stars = class({})
function modifier_cosmos_galactic_stars:IsDebuff() return false end
function modifier_cosmos_galactic_stars:IsHidden() return true end
function modifier_cosmos_galactic_stars:IsPurgable() return false end
function modifier_cosmos_galactic_stars:IsPurgeException() return false end
function modifier_cosmos_galactic_stars:RemoveOnDeath() return false end
function modifier_cosmos_galactic_stars:AllowIllusionDuplicate() return false end
function modifier_cosmos_galactic_stars:OnCreated()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local angle = 0
	local stars = ability:GetSpecialValueFor("stars")
	local scepterstars = ability:GetSpecialValueFor("scepter_stars")
	
	if IsServer() then
		if ability and caster then
			local starID = 0
			for i = 1, stars + scepterstars, 1 do
				angle = angle + (360 / stars)
				CreateModifierThinker(caster, ability, "modifier_cosmos_galactic_stars_thinker", {startangle = angle, starID = starID}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
				starID = starID + 1
			end
			self:StartIntervalThink(30)
		end
	end
end

function modifier_cosmos_galactic_stars:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if caster and ability then
			caster:AddNewModifier(caster, ability, "modifier_cosmos_galactic_stars_enhance", {duration = ability:GetSpecialValueFor("duration")})
			enchant_modif = 1
		end
	end	
end
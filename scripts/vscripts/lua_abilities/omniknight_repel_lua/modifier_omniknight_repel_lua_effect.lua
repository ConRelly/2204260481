modifier_omniknight_repel_lua_effect = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_omniknight_repel_lua_effect:IsHidden()
	return false
end

function modifier_omniknight_repel_lua_effect:IsDebuff()
	return false
end

function modifier_omniknight_repel_lua_effect:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_omniknight_repel_lua_effect:OnCreated( kv )
	-- references
	self.repel_chance = self:GetAbility():GetSpecialValueFor( "repel_chance" )
	self.repel_cooldown = self:GetAbility():GetSpecialValueFor( "repel_cooldown" )
	self.heal_str_multiplier = self:GetAbility():GetSpecialValueFor( "heal_str_multiplier" )
	self.cooldown_modifier_name = "modifier_omniknight_repel_lua_cooldown"
end

function modifier_omniknight_repel_lua_effect:OnRefresh( kv )
	-- references
	self.repel_chance = self:GetAbility():GetSpecialValueFor( "repel_chance" )
	self.repel_cooldown = self:GetAbility():GetSpecialValueFor( "repel_cooldown" )
	self.heal_str_multiplier = self:GetAbility():GetSpecialValueFor( "heal_str_multiplier" )
end

function modifier_omniknight_repel_lua_effect:OnRemoved()
end

function modifier_omniknight_repel_lua_effect:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_omniknight_repel_lua_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

if IsServer() then
	function modifier_omniknight_repel_lua_effect:OnAttackLanded( params )
		local caster = self:GetCaster()
		local target = params.target

		if caster:PassivesDisabled() then return end

		if self:GetParent() == target and self:GetParent():GetTeamNumber() ~= params.attacker:GetTeamNumber() and not target:HasModifier( self.cooldown_modifier_name ) then
			if not target:IsRealHero() then return end
			-- roll chance for repel
			if self:RollChance( self.repel_chance ) then
				-- heal
				local heal = params.damage + (caster:GetStrength() * self:GetAbility():GetSpecialValueFor( "heal_str_multiplier" ))
				local status_resist = target:GetStatusResistance()
				target:Heal( heal, self:GetAbility() )
				-- dispel target (good dispel)
				target:Purge( false, true, false, true, true )
				-- apply buff
				target:AddNewModifier(
					caster,
					self:GetAbility(), 
					self.cooldown_modifier_name, 
					{
						duration = self.repel_cooldown * (1 - status_resist)
					}
				)
				self:PlayEffects( target )
			end
		end
	end
end


--------------------------------------------------------------------------------
-- Helper
function modifier_omniknight_repel_lua_effect:RollChance( chance )
	local rand = math.random()
	if rand<chance/100 then
		return true
	end
	return false
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_omniknight_repel_lua_effect:PlayEffects( target )
	-- get resource
	local sound_cast = "Hero_Omniknight.Repel"
	local particle_cast = "particles/items2_fx/urn_of_shadows_heal_d.vpcf"

	-- play effects
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOn( sound_cast, target )
end
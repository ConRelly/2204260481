modifier_earthshaker_aftershock_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_earthshaker_aftershock_lua:IsHidden()
	return true
end

function modifier_earthshaker_aftershock_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_earthshaker_aftershock_lua:OnCreated( kv )
	if self:GetAbility() then
		-- references
		self.radius = self:GetAbility():GetSpecialValueFor( "aftershock_range" ) -- special value

		if IsServer() then
			local damage = self:GetAbility():GetAbilityDamage() + (self:GetCaster():GetStrength() * self:GetAbility():GetSpecialValueFor("str_multiplier")) -- special value
			self.duration = self:GetAbility():GetDuration() -- special value

			-- precache damage
			self.damageTable = {
				-- victim = target,
				attacker = self:GetCaster(),
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self:GetAbility(), --Optional.
			}

		end
	end	
end

function modifier_earthshaker_aftershock_lua:OnRefresh( kv )
	-- references
	self.radius = self:GetAbility():GetSpecialValueFor( "aftershock_range" ) -- special value
	if IsServer() then
		local damage = self:GetAbility():GetAbilityDamage() + (self:GetCaster():GetStrength() * self:GetAbility():GetSpecialValueFor("str_multiplier")) -- special value
		self.duration = self:GetAbility():GetDuration() -- special value
        
		self.damageTable.damage = damage
	
	end
end



function modifier_earthshaker_aftershock_lua:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_earthshaker_aftershock_lua:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_earthshaker_aftershock_lua:OnAbilityFullyCast( params )
	if IsServer() then
		local abilityName = params.ability:GetAbilityName()
		if self.banned[abilityName] then return end
		if params.unit~=self:GetParent() or params.ability:IsItem() then return end
		local damage = self:GetAbility():GetAbilityDamage() + (self:GetCaster():GetStrength() * self:GetAbility():GetTalentSpecialValueFor("str_multiplier")) -- special value
		self.duration = self:GetAbility():GetDuration() -- special value
        
		self.damageTable.damage = damage
		-- Find enemies in radius
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

		-- apply stun and damage
		for _,enemy in pairs(enemies) do
			enemy:AddNewModifier(
				self:GetParent(), -- player source
				self:GetAbility(), -- ability source
				"modifier_generic_stunned_lua", -- modifier name
				{ duration = self.duration } -- kv
			)

			self.damageTable.victim = enemy
			ApplyDamage(self.damageTable)
		end

		-- Effects
		self:PlayEffects()
	end
end

function modifier_earthshaker_aftershock_lua:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_earthshaker/earthshaker_aftershock.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, self.radius, self.radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end



modifier_earthshaker_aftershock_lua.banned = {
	["invoker_invoke"] = true,
	["elder_titan_return_spirit"] = true,
	["mjz_dragon_knight_elder_dragon_relieve"] = true,
	["mjz_lycan_shapeshift_relieve"] = true,
	["mjz_terrorblade_metamorphosis_relieve"] = true,
}



-- 获得天赋技能的数据值
function FindTalentValue(unit, talentName)
    if unit:HasAbility(talentName) then
        return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return nil
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
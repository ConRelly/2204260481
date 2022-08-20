local THIS_LUA = "abilities/hero_crystal_maiden/mjz_crystal_maiden_freezing_field.lua"
LinkLuaModifier("modifier_mjz_crystal_maiden_freezing_field_caster", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_crystal_maiden_freezing_field_dummy", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_crystal_maiden_freezing_field_debuff", THIS_LUA, LUA_MODIFIER_MOTION_NONE)

local MODIFIER_DUMMY_THINKER = 'modifier_dummy_thinker_v1' 
LinkLuaModifier(MODIFIER_DUMMY_THINKER, 'modifiers/modifier_dummy_thinker_v1.lua', LUA_MODIFIER_MOTION_NONE)


mjz_crystal_maiden_freezing_field = class({})
local ability_class = mjz_crystal_maiden_freezing_field

function ability_class:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function ability_class:OnSpellStart()
    if not IsServer() then return end
    local hCaster = self:GetCaster()
    local hAbility = self
    local duration = self:GetChannelTime()

    hCaster:AddNewModifier(hCaster, hAbility, "modifier_mjz_crystal_maiden_freezing_field_caster", {duration = duration})
    
    self.channeldummy = self:_CreateDummy(self:GetCursorPosition())
    self.channeldummy:AddNewModifier(hCaster, self, "modifier_mjz_crystal_maiden_freezing_field_dummy", {})
   
    EmitSoundOn("hero_Crystal.freezingField.wind", self.channeldummy)
end

function ability_class:OnChannelFinish(bInterrupted)
    if not IsServer() then return end
    self:_OnSpellFinesh(bInterrupted)
end

function ability_class:_OnSpellFinesh( bInterrupted )
    if IsValidEntity(self.channeldummy) then 
        StopSoundOn("hero_Crystal.freezingField.wind", self.channeldummy)
        self.channeldummy:ForceKill(true)
        UTIL_Remove(self.channeldummy)
    end
    self.channeldummy = nil
    self:GetCaster():RemoveModifierByName("modifier_mjz_crystal_maiden_freezing_field_caster")
end

function ability_class:_CreateDummy( point, duration)
    local caster = self:GetCaster()
    local ability = self
    local dummy_name = "npc_dota_invisible_vision_source" -- npc_dummy_unit
    local dummy = CreateUnitByName(dummy_name, point, false, caster, caster, caster:GetTeam())
    dummy:AddNewModifier(caster, nil, "modifier_phased", {})
    dummy:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
    -- dummy:AddNewModifier(caster, ability, "modifier_item_gem_of_true_sight", {duration = duration})
    dummy:AddNewModifier(caster, ability, MODIFIER_DUMMY_THINKER, {})
    return dummy
end

function ability_class:CalcDamage( caster, enemy)
    local ability = self
    local base_damage = GetTalentSpecialValueFor(ability, "damage" )
    local str_int = GetTalentSpecialValueFor(ability, "str_int" )
    if IsValidEntity(caster) and caster:IsHero() then
        return base_damage + (caster:GetIntellect() + caster:GetStrength()) * (str_int / 100)
    else
        return base_damage
    end
end

function ability_class:FrozenTarget( unit )
    local caster = self:GetCaster()
    local ability = self
    local frozen_duration = ability:GetSpecialValueFor("scepter_frozen_duration")
    local frozen_interval = ability:GetSpecialValueFor("scepter_frozen_interval")
    if caster:HasScepter() then 
        if IsValidEntity(unit) and unit:IsAlive() then
            local now = GameRules:GetGameTime()
            unit._mjz_crystal_maiden_freezing_field_frozen = unit._mjz_crystal_maiden_freezing_field_frozen or now
            if (now - unit._mjz_crystal_maiden_freezing_field_frozen) > frozen_interval then
                unit._mjz_crystal_maiden_freezing_field_frozen = now

                
                local fa = caster:FindAbilityByName("mjz_crystal_maiden_frostbite")
                if fa and fa:GetLevel() > 0 then
                    fa:SpellTo(unit)
                else
                    print("add modifier_mjz_g_frozen")
                    unit:AddNewModifier(caster, ability, "modifier_mjz_g_frozen", {duration = frozen_duration})
                end
            end
        end
    end
end


---------------------------------------------------------------------------------------

modifier_mjz_crystal_maiden_freezing_field_caster = class({})
local modifier_caster = modifier_mjz_crystal_maiden_freezing_field_caster

function modifier_caster:IsHidden() return false end
function modifier_caster:IsPurgable() return false end
function modifier_caster:CheckState()
	local state =
	{
		[MODIFIER_STATE_HEXED] = false,
		[MODIFIER_STATE_ROOTED] = false,
		--[MODIFIER_STATE_SILENCED] = false,
		[MODIFIER_STATE_STUNNED] = false,
		[MODIFIER_STATE_FROZEN] = false,
		[MODIFIER_STATE_FEARED] = false,
		[MODIFIER_STATE_DISARMED] = false,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = false,
		--[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
		[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
	}
	return state
end

function modifier_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_caster:GetModifierIncomingDamage_Percentage()
    return self.redu
end

function modifier_caster:OnCreated()
	self.redu = self:GetAbility():GetSpecialValueFor("reduction")
end
function modifier_caster:OnRefresh()
	self:OnCreated()
end

---------------------------------------------------------------------------------------

modifier_mjz_crystal_maiden_freezing_field_dummy = class({})
local modifier_dummy = modifier_mjz_crystal_maiden_freezing_field_dummy

function modifier_dummy:IsHidden() return true end
function modifier_dummy:IsPurgable() return false end

if IsServer() then
    function modifier_dummy:OnCreated( kv )
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        self.caster = caster
        self.ability = ability
		self.aura_radius = ability:GetSpecialValueFor( "radius" )
		self.minDistance = ability:GetSpecialValueFor( "explosion_min_dist" )
		self.maxDistance = ability:GetSpecialValueFor( "explosion_max_dist" )
		self.radius = ability:GetSpecialValueFor( "explosion_radius" )
		-- self.tick = ability:GetSpecialValueFor("explosion_interval")
        self.tick = ability:GetSpecialValueFor("damage_interval")
        self.challenge = 1
        self.challenge_boss = 0
        if _G._challenge_bosss > 0 then
            self.challenge_boss = _G._challenge_bosss / 10
        end
		-- self.chillInit = self:GetTalentSpecialValueFor("chill_init")
		-- self.chillHit = self:GetTalentSpecialValueFor("chill_hit")

		self.damage = ability:CalcDamage(caster, nil)

		self.FXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.FXIndex, 1, Vector( self.aura_radius, self.aura_radius, self.aura_radius) )
        
		self:StartIntervalThink( self.tick )
	end

	function modifier_dummy:OnDestroy( kv )
		self:GetParent():ForceKill(false)
		ParticleManager:ClearParticle(self.FXIndex, false)
    end

    function modifier_dummy:OnIntervalThink( kv )
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local dummy = self:GetParent()
		local casterLocation = dummy:GetAbsOrigin()

		ParticleManager:SetParticleControl( self.FXIndex, 0, casterLocation )
        self.challenge = self.challenge + self.challenge_boss
		local fxIndex = ParticleManager:FireParticle( "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster, {[0] = attackPoint} )
        -- Timers:CreateTimer(0.25, function()
        --  self:_ApplyDamage_old()
        -- end)
        --ParticleManager:ReleaseParticleIndex(fxIndex)
        self:_ApplyDamage()
    end

    function modifier_dummy:_ApplyDamage( )
        local ability = self:GetAbility()
        local caster = self:GetCaster()
		local dummy = self:GetParent()
		local casterLocation = dummy:GetAbsOrigin()

        local targetTeam = ability:GetAbilityTargetTeam()
		local targetType = ability:GetAbilityTargetType()
        local targetFlag = ability:GetAbilityTargetFlags()

		local attackPoint = casterLocation
        local damage = math.ceil((ability:CalcDamage(caster, nil) * self.tick)* self.challenge)
        local units = caster:FindEnemyUnitsInRadius(attackPoint, self.aura_radius, {type = targetType, flag = targetFlag} )
        for _, unit in pairs(units) do
            -- print("Damage: ".. damage)
            ability:DealDamage(caster, unit, damage)
            ability:FrozenTarget(unit)
        end
        EmitSoundOnLocationWithCaster( attackPoint, "hero_Crystal.freezingField.explosion", caster )
    end



    function modifier_dummy:_ApplyDamage_old( )
        local ability = self:GetAbility()
        local caster = self:GetCaster()
		local dummy = self:GetParent()
		local casterLocation = dummy:GetAbsOrigin()

        local targetTeam = ability:GetAbilityTargetTeam()
		local targetType = ability:GetAbilityTargetType()
        local targetFlag = ability:GetAbilityTargetFlags()

		local attackPoint = casterLocation + RandomVector(RandomInt(self.maxDistance, self.minDistance))

        local units = caster:FindEnemyUnitsInRadius(attackPoint, self.radius, {type = targetType, flag = targetFlag} )
        for _, unit in pairs(units) do
            print("Damage: ".. self.damage)

            ability:DealDamage(caster, unit, self.damage)
            -- if unit:IsChilled() then
            --     unit:AddChill(ability, caster, ability:GetChannelTimeRemaining(), self.chillHit)
            -- else
            --     unit:AddChill(ability, caster, ability:GetChannelTimeRemaining(), self.chillInit)
            -- end
        end
        EmitSoundOnLocationWithCaster( attackPoint, "hero_Crystal.freezingField.explosion", caster )
    end
end


function modifier_dummy:IsAura()
	return true
end
function modifier_dummy:GetModifierAura()
	return "modifier_mjz_crystal_maiden_freezing_field_debuff"
end
function modifier_dummy:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_dummy:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_dummy:GetAuraRadius()
	return self.aura_radius
end


---------------------------------------------------------------------------------------

modifier_mjz_crystal_maiden_freezing_field_debuff = class({})
local modifier_debuff = modifier_mjz_crystal_maiden_freezing_field_debuff

function modifier_debuff:IsHidden() return false end
function modifier_debuff:IsPurgable() return true end

function modifier_debuff:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_debuff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_slow")
end
function modifier_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_slow")
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
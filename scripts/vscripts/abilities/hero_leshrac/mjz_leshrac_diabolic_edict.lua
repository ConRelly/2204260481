
LinkLuaModifier("modifier_mjz_leshrac_diabolic_edict", "abilities/hero_leshrac/mjz_leshrac_diabolic_edict.lua", LUA_MODIFIER_MOTION_NONE)

mjz_leshrac_diabolic_edict = class({})
local ability_class = mjz_leshrac_diabolic_edict

function ability_class:GetAOERadius()
    return self:GetSpecialValueFor("radius") + self:GetCaster():GetCastRangeBonus()
end

function ability_class:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = self
    local radius = ability:GetAOERadius()
    local duration = GetTalentSpecialValueFor(ability, "duration")

    -- EmitSoundOn("Hero_Leshrac.Diabolic_Edict_lp", caster)

    caster:AddNewModifier(caster, ability, "modifier_mjz_leshrac_diabolic_edict", {duration = duration})

end

function ability_class:CalcDamage()
    local target = self:GetCursorTarget()
    local caster = self:GetCaster()
    local ability = self
    local radius = ability:GetAOERadius()

    local base_damage = GetTalentSpecialValueFor(ability, "damage")
    local damage_stats = GetTalentSpecialValueFor(ability, "damage_stats")
    local damage = base_damage
    if caster:IsRealHero() then
        damage = base_damage + ((caster:GetIntellect() + caster:GetStrength() + caster:GetAgility()) * (damage_stats / 100))
    end
    return damage
end

--------------------------------------------------------------------------------

modifier_mjz_leshrac_diabolic_edict = class({})
local modifier_class = modifier_mjz_leshrac_diabolic_edict

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end
function modifier_class:RemoveOnDeath() return false end
function modifier_class:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


if IsServer() then

    function modifier_class:OnCreated(table)
        local ability = self:GetAbility()
        local explosion_delay = ability:GetSpecialValueFor('explosion_delay')
        self.num_explosions = GetTalentSpecialValueFor(ability, 'num_explosions') or 0
        self.tower_bonus = ability:GetSpecialValueFor("tower_bonus")
        self.radius = ability:GetAOERadius()
        self.damage = ability:CalcDamage()

        self:StartIntervalThink(explosion_delay)

        self:GetCaster():StopSound("Hero_Leshrac.Diabolic_Edict_lp")
		self:GetCaster():EmitSound("Hero_Leshrac.Diabolic_Edict_lp")
    end

    function modifier_class:OnIntervalThink()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        
        if self.num_explosions <= 0 then
            if self:IsNull() then return end
            self:Destroy()
            return 
        end

        local radius = ability:GetAOERadius()

        -- FIND_ANY_ORDER FIND_CLOSEST
        local enemy_list = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, 
                           ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 
                           FIND_ANY_ORDER, false )

        local enemy_count = #enemy_list

        if enemy_count == 0 then
            PM_FireParticle(p_name_ti9, PATTACH_WORLDORIGIN, nil, {[1] = parent:GetAbsOrigin() + ActualRandomVector( radius, 100 ) })
        
        elseif enemy_count == 1 then
            local enemy = enemy_list[1]
            self:ApplyEffect(enemy)
            for i=1,2 do
                if self.num_explosions > 0 then
                    self.num_explosions = self.num_explosions - 1
                    self:ApplyDamage(enemy)
                end
            end
        
        else
            for _, enemy in ipairs(enemy_list) do
                if self.num_explosions > 0 then
                    self.num_explosions = self.num_explosions - 1
    
                    self:ApplyDamage(enemy)
                    self:ApplyEffect(enemy)
                end
            end
        end

    end

    function modifier_class:ApplyDamage(enemy)
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        local damage = self.damage

        if enemy == nil or not IsValidEntity(enemy) then
            return false
        end

        if enemy:IsBuilding() then
            damage = damage + damage * (self.tower_bonus / 100)
        end

        local damageTable = {
            attacker = parent,
            victim = enemy,
            damage = damage,
            damage_type = ability:GetAbilityDamageType(),
            damage_flags = DOTA_DAMAGE_FLAG_IGNORES_BASE_PHYSICAL_ARMOR,
            ability = ability
        }
        ApplyDamage(damageTable)
    end

    function modifier_class:ApplyEffect( enemy )
        local p_name = "particles/units/heroes/hero_leshrac/leshrac_diabolic_edict.vpcf"
        local p_name_ti9 = "particles/econ/items/leshrac/leshrac_ti9_immortal_head/leshrac_ti9_immortal_edict.vpcf"

        if enemy == nil or not IsValidEntity(enemy) then
            return false
        end
       
        PM_FireParticle(p_name_ti9, PATTACH_ABSORIGIN_FOLLOW, enemy, {[1] = "attach_hitloc"})
        enemy:EmitSound("Hero_Leshrac.Diabolic_Edict")
    end

    function modifier_class:OnRemoved()
		self:GetCaster():StopSound("Hero_Leshrac.Diabolic_Edict_lp")
	end
end


------------------------------------------------------------------------------

function ActualRandomVector(maxLength, flMinLength)
	local minLength = flMinLength or 0
	return RandomVector(RandomInt(minLength, maxLength))
end

function PM_FireParticle(effect, attach, owner, cps)
	local FX = ParticleManager:CreateParticle(effect, attach, owner)
	if cps then
		for cp, value in pairs(cps) do
			if type(value) == "userdata" then
				ParticleManager:SetParticleControl(FX, tonumber(cp), value)
			elseif type(value) == "table" then
				ParticleManager:SetParticleControlEnt(FX, cp, value.owner or owner, value.attach or attach, value.point or "attach_hitloc", (value.owner or owner):GetAbsOrigin(), true)
			else
				ParticleManager:SetParticleControlEnt(FX, cp, owner, attach, value, owner:GetAbsOrigin(), true)
			end
		end
	end
    ParticleManager:DestroyParticle(FX, false)
	ParticleManager:ReleaseParticleIndex(FX)
end


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


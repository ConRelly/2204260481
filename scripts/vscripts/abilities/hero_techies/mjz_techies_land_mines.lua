local THIS_LUA = "abilities/hero_techies/mjz_techies_land_mines.lua"
LinkLuaModifier("modifier_mjz_techies_land_mine", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_techies_land_mine_trigger", THIS_LUA, LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------

mjz_techies_land_mines = mjz_techies_land_mines or class({})

function mjz_techies_land_mines:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function mjz_techies_land_mines:GetIntrinsicModifierName()
	return "modifier_mjz_techies_land_mine"
end


function mjz_techies_land_mines:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local soundName = "Hero_Techies.LandMine.Plant"

		local mine = CreateUnitByName("npc_dota_techies_land_mine", self:GetCursorPosition(), true, caster, caster, caster:GetTeamNumber())
		mine:SetControllableByPlayer(caster:GetPlayerID(), true)
		mine:SetOwner(caster)
		mine:AddNewModifier(caster, self, "modifier_techies_land_mine", nil)
		mine:AddNewModifier(caster, self, "modifier_mjz_techies_land_mine_trigger", nil)
		-- mine:AddRadiusIndicator(caster, self, self:GetAOERadius(), 150, 22, 22, false, false)

		caster:EmitSound(soundName)
	end
end

function mjz_techies_land_mines:CalcDamage( enemy )
	local caster = self:GetCaster()
	local ability = self
	local base_damage = GetTalentSpecialValueFor(ability, "base_damage")
	local int_damage = GetTalentSpecialValueFor(ability, "int_damage")
	local building_damage_pct = ability:GetSpecialValueFor("building_damage_pct")
	local damage = base_damage + caster:GetIntellect() * (int_damage / 100)

	if enemy and IsValidEntity(enemy) and enemy:IsBuilding() then
		damage = damage * (building_damage_pct / 100)
	end

	--local bBaseOnly = false
	--local spellAmp = caster:GetSpellAmplification(bBaseOnly)
	-- print("spellAmp: ".. tostring(spellAmp))
	--damage = damage + damage * spellAmp

	return damage
end

function mjz_techies_land_mines:Parents()
	local caster = self:GetCaster()
	local ability = self
	return caster
end	
------------------------------------------------------------------------------------------

modifier_mjz_techies_land_mine = modifier_mjz_techies_land_mine or class({})

function modifier_mjz_techies_land_mine:IsHidden() return true end
function modifier_mjz_techies_land_mine:IsPurgable() return false end

if IsServer() then
	function modifier_mjz_techies_land_mine:OnCreated()
		self:StartIntervalThink(1.25)
	end
	function modifier_mjz_techies_land_mine:OnIntervalThink()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		if caster:IsChanneling() then return end
		if caster:IsSilenced() then return end

		if ability:GetAutoCastState() and ability:IsFullyCastable() then
			caster:CastAbilityOnPosition(caster:GetAbsOrigin(), ability, caster:GetTeam())
		end
	end
end

------------------------------------------------------------------------------------------

modifier_mjz_techies_land_mine_trigger = modifier_mjz_techies_land_mine_trigger or class({})

function modifier_mjz_techies_land_mine_trigger:IsDebuff() return false end
function modifier_mjz_techies_land_mine_trigger:IsHidden() return true end
function modifier_mjz_techies_land_mine_trigger:IsPurgable() return false end

function modifier_mjz_techies_land_mine_trigger:IsPassive() return true end

function modifier_mjz_techies_land_mine_trigger:DeclareFunctions()
	local functions = {
		MODIFIER_STATE_INVISIBLE,
		MODIFIER_STATE_NO_UNIT_COLLISION
	}
end

function modifier_mjz_techies_land_mine_trigger:OnCreated(args)
	if IsServer() then
		local activationDelay = self:GetAbility():GetSpecialValueFor("activation_delay")
		local soundName = "Hero_Techies.LandMine.Priming"

		self.active = false
		Timers:CreateTimer(activationDelay, function()
			if not self:IsNull() then
				self.active = true
				self:StartIntervalThink(FrameTime())

				self:GetParent():EmitSound(soundName)
			end
		end)
	end
end

function modifier_mjz_techies_land_mine_trigger:OnIntervalThink()
	if IsServer() then
		local owner = self:GetParent()
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local damageType = ability:GetAbilityDamageType()
		local triggerRadius = ability:GetAOERadius()
		
		local enemies = FindUnitsInRadius(
			owner:GetTeamNumber(),
			owner:GetAbsOrigin(),
			nil,
			triggerRadius,
			ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),
			ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER,
			false
		)
		if #enemies > 0 then
			local explosionParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_WORLDORIGIN, owner)
			
			ParticleManager:SetParticleControl(explosionParticle, 0, owner:GetAbsOrigin())
			ParticleManager:SetParticleControl(explosionParticle, 1, owner:GetAbsOrigin())
			ParticleManager:SetParticleControl(explosionParticle, 2, Vector(triggerRadius, 1, 1))
			ParticleManager:ReleaseParticleIndex(explosionParticle)
			for _, enemy in pairs(enemies) do
				local true_damage = ability:CalcDamage(enemy)
                print(true_damage .. "bomb dmg")
				ApplyDamage({
					victim = enemy,
					attacker = caster,
					damage = true_damage,
					damage_type = damageType,
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
					ability = ability
				})
			end
			owner:ForceKill(false)

			EmitSoundOn("Hero_Techies.LandMine.Detonate", owner)
		end
	end
end

function modifier_mjz_techies_land_mine_trigger:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = self.active, 
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end



-----------------------------------------------------------------------------------------


function KillTreesInRadius(caster, center, radius)
    local particles = {
        "particles/newplayer_fx/npx_tree_break.vpcf",
        "particles/newplayer_fx/npx_tree_break_b.vpcf",
    }
    local particle = particles[math.random(1, #particles)]

    local trees = GridNav:GetAllTreesAroundPoint(center, radius, true)
    for _,tree in pairs(trees) do
        local particle_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_fx, 0, tree:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_fx)
    end
    GridNav:DestroyTreesAroundPoint(center, radius, false)
end

-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(unit, point, radius)
    local iTeamNumber = unit:GetTeamNumber()
    local vPosition = point   				-- 搜索中心点
    local hCacheUnit = nil                  -- 通常值
    local flRadius = radius                 -- 搜索范围
    local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
    -- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP           
	-- 支持魔法免疫
    local iFlagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE   
    local iOrder = FIND_CLOSEST                         -- 寻找最近的
    local bCanGrowCache = false             -- 通常值
    return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
        flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
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


-- 是否学习了天赋技能
function HasTalentSpecialValueFor(ability, value)
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
		return talent and talent:GetLevel() > 0 
    end
    return false
end

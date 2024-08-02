LinkLuaModifier("modifier_mjz_techies_land_mine", "abilities/hero_techies/mjz_techies_land_mines.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_techies_land_mine_trigger", "abilities/hero_techies/mjz_techies_land_mines.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_techies_land_mine_burn_custom", "abilities/hero_techies/mjz_techies_land_mines.lua", LUA_MODIFIER_MOTION_NONE)
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

		local mine = CreateUnitByName("npc_dota_techies_land_mine", self:GetCursorPosition(), true, caster, caster, caster:GetTeamNumber())
		mine:SetControllableByPlayer(caster:GetPlayerID(), true)
		mine:SetOwner(caster)
		--mine:AddNewModifier(caster, self, "modifier_techies_land_mine", nil)
		mine:AddNewModifier(caster, self, "modifier_mjz_techies_land_mine_trigger", nil)
		-- mine:AddRadiusIndicator(caster, self, self:GetAOERadius(), 150, 22, 22, false, false)

		EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Hero_Techies.RemoteMine.Plant", caster)
	end
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
		local caster = self:GetCaster()
		if caster:IsChanneling() then return end
		if caster:IsSilenced() then return end

		if self:GetAbility():GetAutoCastState() and self:GetAbility():IsFullyCastable() then
			caster:CastAbilityOnPosition(caster:GetAbsOrigin(), self:GetAbility(), caster:GetTeam())
		end
	end
end

------------------------------------------------------------------------------------------

modifier_mjz_techies_land_mine_trigger = modifier_mjz_techies_land_mine_trigger or class({})
function modifier_mjz_techies_land_mine_trigger:IsDebuff() return false end
function modifier_mjz_techies_land_mine_trigger:IsHidden() return true end
function modifier_mjz_techies_land_mine_trigger:IsPurgable() return false end
function modifier_mjz_techies_land_mine_trigger:IsPassive() return true end

function modifier_mjz_techies_land_mine_trigger:OnCreated(args)
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
			activation_delay = FrameTime()
		else
			activation_delay = self:GetAbility():GetSpecialValueFor("activation_delay")
		end
		Timers:CreateTimer(activation_delay, function()
			if not self:IsNull() then
				self:GetParent():EmitSound("Hero_Techies.LandMine.Priming")
				self:StartIntervalThink(FrameTime())
			end
		end)
	end
end

function modifier_mjz_techies_land_mine_trigger:OnIntervalThink()
	if IsServer() then
		local mine = self:GetParent()
		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),
			mine:GetAbsOrigin(),
			nil,
			self:GetAbility():GetAOERadius(),
			self:GetAbility():GetAbilityTargetTeam(),
			self:GetAbility():GetAbilityTargetType(),
			self:GetAbility():GetAbilityTargetFlags(),
			FIND_ANY_ORDER,
			false
		)
		local burn_duration = self:GetAbility():GetSpecialValueFor("burn_duration")

		if #enemies > 0 then
			local true_damage = self:GetAbility():GetSpecialValueFor("base_damage") + self:GetCaster():GetIntellect(false) * (self:GetAbility():GetSpecialValueFor("int_damage") + talent_value(self:GetCaster(), "special_bonus_unique_mjz_techies_land_mines_int_damage"))
 			if RollPercentage(_G._effect_rate) then
				local explosionParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
					ParticleManager:SetParticleControl(explosionParticle, 0, mine:GetAbsOrigin())
					ParticleManager:SetParticleControl(explosionParticle, 1, mine:GetAbsOrigin())
					ParticleManager:SetParticleControl(explosionParticle, 2, Vector(self:GetAbility():GetAOERadius(), 1, 1))
					self:AddParticle(explosionParticle, false, false, 0, false, false)
					--ParticleManager:ReleaseParticleIndex(explosionParticle)
			end		
			for _, enemy in pairs(enemies) do
				--print(true_damage .. "bomb dmgg")
				ApplyDamage({
					victim = enemy,
					attacker = self:GetCaster(),
					ability = self:GetAbility(),
					damage = true_damage,
					damage_type = self:GetAbility():GetAbilityDamageType(),
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
				})
				enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_techies_land_mine_burn_custom", {duration = burn_duration})
			end
			mine:EmitSoundParams( "Hero_Techies.RemoteMine.Detonate", 0, 0.7, 0)
			--mine:EmitSound("Hero_Techies.LandMine.Detonate")
			Timers:CreateTimer(0.1, function()
				if mine ~= nil then
					mine:ForceKill(false)
				end	
			end)
			self:StartIntervalThink(-1)
		end
	end
end

function modifier_mjz_techies_land_mine_trigger:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

---techi debuff
modifier_techies_land_mine_burn_custom = class ( {})

function modifier_techies_land_mine_burn_custom:IsDebuff()
    return true
end
function modifier_techies_land_mine_burn_custom:IsPurgable()
    return false
end
function modifier_techies_land_mine_burn_custom:IsHidden()
    return false
end


function modifier_techies_land_mine_burn_custom:DeclareFunctions()
    return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_techies_land_mine_burn_custom:GetModifierMagicalResistanceBonus( params )
    if self:GetAbility() then
        return self:GetAbility():GetSpecialValueFor("mres_reduction") * (-1)
    end    
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
    local bonusOperation
    local kv = ability:GetAbilityKeyValues()
    
    if kv.AbilityValues then
        local valueData = kv.AbilityValues[value]
        if type(valueData) == "table" then
            talentName = valueData.LinkedSpecialBonus
            bonusOperation = valueData.LinkedSpecialBonusOperation
        end
    end
    
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then
            local bonusValue = talent:GetSpecialValueFor("value")
            
            if bonusOperation then
                if bonusOperation == "SPECIAL_BONUS_ADD" or bonusOperation == "SPECIAL_BONUS_SUBTRACT" then
                    base = base + bonusValue -- For subtraction, bonusValue should already be negative
                elseif bonusOperation == "SPECIAL_BONUS_MULTIPLY" then
                    base = base * bonusValue
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_ADD" then
                    base = base * (1 + bonusValue / 100)
                elseif bonusOperation == "SPECIAL_BONUS_PERCENTAGE_SUBTRACT" then
                    base = base * (1 - bonusValue / 100)
                end
            else
                -- Default behavior if no operation is specified
                base = base + bonusValue
            end
        end
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

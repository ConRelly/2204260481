item_water_scepter = class({})
LinkLuaModifier("modifier_seal_act", "items/seal_act.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_water_scepter", "items/water_scepter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spirit", "items/water_scepter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spirit_attack_speed", "items/water_scepter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_water_scepter_maim", "items/water_scepter", LUA_MODIFIER_MOTION_NONE)

function item_water_scepter:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
        local ability = self
		local spirit_as_duration = self:GetSpecialValueFor("hp")
        local water_scepter_pfx = ParticleManager:CreateParticle("particles/ea_items/op_staff/op_staff_act_dragon.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:ReleaseParticleIndex(water_scepter_pfx)
         if caster.spirit1 ~= nil then
            if not caster.spirit1:IsNull() then
                caster.spirit1:AddNewModifier(caster, ability, "modifier_spirit_attack_speed", {duration = spirit_as_duration})
                Timers:CreateTimer(0.1, function()
                    ability.speed = 4
                end)
                Timers:CreateTimer(0.2, function()
                    ability.speed = 6
                end)
                Timers:CreateTimer(0.3, function()
                    ability.speed = 8
                end)
                Timers:CreateTimer(0.4, function()
                    ability.speed = 10
                end)
                Timers:CreateTimer(5, function()
                    ability.speed = 8
                end)
                Timers:CreateTimer(5.1, function()
                    ability.speed = 6
                end)
                Timers:CreateTimer(5.2, function()
                    ability.speed = 4
                end)
                Timers:CreateTimer(5.3, function()
                    ability.speed = 2
                end)
            end
        end
        if caster.spirit2 ~= nil then
            if not caster.spirit2:IsNull() then
                caster.spirit2:AddNewModifier(caster, ability, "modifier_spirit_attack_speed", {duration = spirit_as_duration})
            end
        end
        if caster.spirit3 ~= nil then
            if not caster.spirit3:IsNull() then
                caster.spirit3:AddNewModifier(caster, ability, "modifier_spirit_attack_speed", {duration = spirit_as_duration})
            end
        end
	end
end
function item_water_scepter:GetIntrinsicModifierName() return "modifier_water_scepter" end

------------------------------------------------------------------------------------------------------------------------
modifier_water_scepter = class({})
function modifier_water_scepter:IsHidden() return true end
function modifier_water_scepter:IsPurgable() return false end
function modifier_water_scepter:RemoveOnDeath() return false end
function modifier_water_scepter:DeclareFunctions()
	return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
		}
end
function modifier_water_scepter:GetModifierHealthBonus() return self.hp end
function modifier_water_scepter:GetModifierPreAttack_BonusDamage() return self.damage end

function modifier_water_scepter:GetModifierBonusStats_Strength()
	if self:GetAbility() then if self:GetParent():GetPrimaryAttribute() == 0 then
	return self.primary_attribute + self.str else return self.secondary_stats + self.str end end
end
function modifier_water_scepter:GetModifierBonusStats_Agility()
	if self:GetAbility() then if self:GetParent():GetPrimaryAttribute() == 1 then
	return self.primary_attribute + self.agi else return self.secondary_stats + self.agi end end
end
function modifier_water_scepter:GetModifierBonusStats_Intellect()
	if self:GetAbility() then if self:GetParent():GetPrimaryAttribute() == 2 then
	return self.primary_attribute else return self.secondary_stats end end
end

function modifier_water_scepter:GetModifierAttackSpeedBonus_Constant() return self.attack_speed end
function modifier_water_scepter:GetModifierMoveSpeedBonus_Percentage() return self.ms end
function modifier_water_scepter:GetModifierStatusResistanceStacking() return self.status_resist end
function modifier_water_scepter:GetModifierConstantManaRegen() return self.mana_regen end
function modifier_water_scepter:GetModifierAttackRangeBonus() return self.attack_range end
function modifier_water_scepter:GetModifierHPRegenAmplify_Percentage() return self.hp_regen_amp end
function modifier_water_scepter:OnAttackLanded(kv)
    if IsServer() then
        local caster = self:GetCaster()
        local attacker = kv.attacker
        if attacker == caster then
            if RandomInt(1,100) <= 40 then
                local ability = self:GetAbility()
                local target = kv.target
                target:AddNewModifier(caster, ability, "modifier_water_scepter_maim", {duration = self.maim_duration * (1 - target:GetStatusResistance())})
				ApplyDamage({victim = target, attacker = caster, damage = self.bonus_chance_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
            end
        end
    end
end
function modifier_water_scepter:OnCreated(kv)
	local caster = self:GetCaster()
    local ability = self:GetAbility()
    self.hp = ability:GetSpecialValueFor("hp")
	self.damage = ability:GetSpecialValueFor("damage")
	self.agi = ability:GetSpecialValueFor("agi")
	self.str = ability:GetSpecialValueFor("str")
	self.primary_attribute = ability:GetSpecialValueFor("primary_attribute")
	self.secondary_stats = ability:GetSpecialValueFor("secondary_stats")
	self.attack_speed = ability:GetSpecialValueFor("attack_speed")
	self.ms = ability:GetSpecialValueFor("ms")
	self.status_resist = ability:GetSpecialValueFor("status_resist")
    self.mana_regen = ability:GetSpecialValueFor("mana_regen")
    self.attack_range = ability:GetSpecialValueFor("attack_range")
    self.hp_regen_amp = ability:GetSpecialValueFor("hp_regen_amp")
	if IsServer() then
        Timers:CreateTimer(FrameTime(), function()
            caster:AddNewModifier(caster, ability, "modifier_seal_act", {})
        end)
        self.maim_duration = ability:GetSpecialValueFor("maim_duration")
        self.bonus_chance_damage = ability:GetSpecialValueFor("bonus_chance_damage")
        ability.rot = 0
        ability.speed = 2
        ability.spirits_startTime = GameRules:GetGameTime()
        if (caster:IsRangedAttacker() and caster:IsAlive()) then
        --if caster:IsRealHero() then
            if caster.spirit1 ~= nil then
                if not caster.spirit1:IsNull() then
                    caster.spirit1:ForceKill(true)
                    caster.spirit1 = nil
                end
            end
            if caster.spirit2 ~= nil then
                if not caster.spirit2:IsNull() then
                    caster.spirit2:ForceKill(true)
                    caster.spirit2 = nil
                end
            end
            if caster.spirit3 ~= nil then
                if not caster.spirit3:IsNull() then
                    caster.spirit3:ForceKill(true)
                    caster.spirit3 = nil
                end
            end
            local casterOrigin = caster:GetAbsOrigin()
        -- Spawn a new spirit1
            local newSpirit = CreateUnitByName("npc_dota_spirit", casterOrigin, false, caster, nil, caster:GetTeam())
            -- Create particle FX
            newSpirit:SetRangedProjectileName("particles/my_new/my_wisp_base_attack.vpcf")
            pfx1 = ParticleManager:CreateParticle("particles/my2_wisp_guardian_.vpcf", PATTACH_ABSORIGIN_FOLLOW, newSpirit)
            newSpirit.pfx = pfx1
            caster.spirit1 = newSpirit
            -- Apply the spirit modifier
            newSpirit:AddNewModifier(caster, ability, "modifier_spirit", {})
        -- Spawn a new spirit2
            newSpirit = CreateUnitByName("npc_dota_spirit", casterOrigin, false, caster, nil, caster:GetTeam())
            -- Create particle FX
            newSpirit:SetRangedProjectileName("particles/my_new/my_wisp_base_attack.vpcf")
            pfx2 = ParticleManager:CreateParticle("particles/my2_wisp_guardian_.vpcf", PATTACH_ABSORIGIN_FOLLOW, newSpirit)
            newSpirit.pfx = pfx2
            caster.spirit2 = newSpirit
            -- Apply the spirit modifier
            newSpirit:AddNewModifier(caster, ability, "modifier_spirit", {})
        -- Spawn a new spirit3
            newSpirit = CreateUnitByName("npc_dota_spirit", casterOrigin, false, caster, nil, caster:GetTeam())
            -- Create particle FX
            newSpirit:SetRangedProjectileName("particles/my_new/my_wisp_base_attack.vpcf")
            pfx3 = ParticleManager:CreateParticle("particles/my2_wisp_guardian_.vpcf", PATTACH_ABSORIGIN_FOLLOW, newSpirit)
            newSpirit.pfx = pfx3
            caster.spirit3 = newSpirit
            -- Apply the spirit modifier
            newSpirit:AddNewModifier(caster, ability, "modifier_spirit", {})
        --end
            self:StartIntervalThink(FrameTime())
        else
            local spiritModifier = "modifier_spirit"
            
            if caster.spirit1 ~= nil then
                if not caster.spirit1:IsNull() then
                    caster.spirit1:RemoveModifierByName(spiritModifier)
                end
            end
            if caster.spirit2 ~= nil then
                if not caster.spirit2:IsNull() then
                    caster.spirit2:RemoveModifierByName(spiritModifier)
                end
            end
            if caster.spirit3 ~= nil then
                if not caster.spirit3:IsNull() then
                    caster.spirit3:RemoveModifierByName(spiritModifier)
                end
            end
        end
    end
end
function modifier_water_scepter:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
        local ability = self:GetAbility()
        local spiritModifier = "modifier_spirit"
        local casterOrigin = caster:GetAbsOrigin()
        if (caster:IsRangedAttacker() and caster:IsAlive()) then
            --if caster:IsRealHero() then
                local currentRadius = 100
                if caster.spirit1 ~= nil then
                    local elapsedTime = GameRules:GetGameTime() - ability.spirits_startTime
                    local rotationAngle = ability.rot - 60
                    local relPos = Vector(0, currentRadius, 0)
                    relPos = RotatePosition(Vector(0,0,0), QAngle(0, -rotationAngle, 0), relPos)
                    local absPos = GetGroundPosition(relPos + casterOrigin, caster.spirit1)
                    caster.spirit1:SetAbsOrigin(absPos)
                    caster.spirit1:SetBaseDamageMin(caster:GetAttackDamage())
                    caster.spirit1:SetBaseDamageMax(caster:GetAttackDamage())
                    -- Update particle
                    ParticleManager:SetParticleControl(caster.spirit1.pfx, 1, Vector(currentRadius, 0, 0))
                else
                -- Spawn a new spirit1
                    local newSpirit = CreateUnitByName("npc_dota_spirit", casterOrigin, false, caster, nil, caster:GetTeam())
                    -- Create particle FX
                    newSpirit:SetRangedProjectileName("particles/my_new/my_wisp_base_attack.vpcf")
                    pfx1 = ParticleManager:CreateParticle("particles/my2_wisp_guardian_.vpcf", PATTACH_ABSORIGIN_FOLLOW, newSpirit)
                    newSpirit.pfx = pfx1
                    caster.spirit1 = newSpirit
                    -- Apply the spirit modifier
                    newSpirit:AddNewModifier(caster, ability, "modifier_spirit", {})
                end
                if caster.spirit2 ~= nil then
                    local elapsedTime = GameRules:GetGameTime() - ability.spirits_startTime
                    local rotationAngle = ability.rot - 180
                    local relPos = Vector(0, currentRadius, 0)
                    relPos = RotatePosition(Vector(0,0,0), QAngle(0, -rotationAngle, 0), relPos)
                    local absPos = GetGroundPosition(relPos + casterOrigin, caster.spirit2)
                    caster.spirit2:SetAbsOrigin(absPos)
                    caster.spirit2:SetBaseDamageMin(caster:GetAttackDamage())
                    caster.spirit2:SetBaseDamageMax(caster:GetAttackDamage())
                    -- Update particle
                    ParticleManager:SetParticleControl(caster.spirit2.pfx, 1, Vector(currentRadius, 0, 0))
                else
                -- Spawn a new spirit2
                    newSpirit = CreateUnitByName("npc_dota_spirit", casterOrigin, false, caster, nil, caster:GetTeam())
                    -- Create particle FX
                    newSpirit:SetRangedProjectileName("particles/my_new/my_wisp_base_attack.vpcf")
                    pfx2 = ParticleManager:CreateParticle("particles/my2_wisp_guardian_.vpcf", PATTACH_ABSORIGIN_FOLLOW, newSpirit)
                    newSpirit.pfx = pfx2
                    caster.spirit2 = newSpirit
                    -- Apply the spirit modifier
                    newSpirit:AddNewModifier(caster, ability, "modifier_spirit", {})
                end
                if caster.spirit3 ~= nil then
                    local elapsedTime = GameRules:GetGameTime() - ability.spirits_startTime
                    local rotationAngle = ability.rot - 300
                    local relPos = Vector(0, currentRadius, 0)
                    relPos = RotatePosition(Vector(0,0,0), QAngle(0, -rotationAngle, 0), relPos)
                    local absPos = GetGroundPosition(relPos + casterOrigin, caster.spirit2)
                    caster.spirit3:SetAbsOrigin(absPos)
                    caster.spirit3:SetBaseDamageMin(caster:GetAttackDamage())
                    caster.spirit3:SetBaseDamageMax(caster:GetAttackDamage())
                    -- Update particle
                    ParticleManager:SetParticleControl(caster.spirit3.pfx, 1, Vector(currentRadius, 0, 0))
                else
                -- Spawn a new spirit3
                    newSpirit = CreateUnitByName("npc_dota_spirit", casterOrigin, false, caster, nil, caster:GetTeam())
                    -- Create particle FX
                    newSpirit:SetRangedProjectileName("particles/my_new/my_wisp_base_attack.vpcf")
                    pfx3 = ParticleManager:CreateParticle("particles/my2_wisp_guardian_.vpcf", PATTACH_ABSORIGIN_FOLLOW, newSpirit)
                    newSpirit.pfx = pfx3
                    caster.spirit3 = newSpirit
                    -- Apply the spirit modifier
                    newSpirit:AddNewModifier(caster, ability, "modifier_spirit", {})
                end
                ability.rot = ability.rot + ability.speed
            --end
        else
            if caster.spirit1 ~= nil then
                if not caster.spirit1:IsNull() then
                    caster.spirit1:RemoveModifierByName(spiritModifier)
                end
            end
            if caster.spirit2 ~= nil then
                if not caster.spirit2:IsNull() then
                    caster.spirit2:RemoveModifierByName(spiritModifier)
                end
            end
            if caster.spirit3 ~= nil then
                if not caster.spirit3:IsNull() then
                    caster.spirit3:RemoveModifierByName(spiritModifier)
                end
            end
        end
	end
end
function modifier_water_scepter:OnDestroy()
	if IsServer() then
        local caster = self:GetCaster()
        caster:RemoveModifierByName("modifier_seal_act")
        local ability = self:GetAbility()
        local spiritModifier = "modifier_spirit"
        if caster.spirit1 ~= nil then
            if not caster.spirit1:IsNull() then
                caster.spirit1:RemoveModifierByName(spiritModifier)
            end
        end
        if caster.spirit2 ~= nil then
            if not caster.spirit2:IsNull() then
                caster.spirit2:RemoveModifierByName(spiritModifier)
            end
        end
        if caster.spirit3 ~= nil then
            if not caster.spirit3:IsNull() then
                caster.spirit3:RemoveModifierByName(spiritModifier)
            end
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
modifier_spirit = class({})
function modifier_spirit:OnCreated(keys)
	if IsServer() then
		self.spirit_attack_damage = self:GetCaster():GetAttackDamage()
		self.spirit_attack_range = self:GetCaster():Script_GetAttackRange()
		self:StartIntervalThink(FrameTime())
    end
end
function modifier_spirit:OnIntervalThink()
	if IsServer() then
		self.spirit_attack_damage = self:GetCaster():GetAttackDamage()
		self.spirit_attack_range = self:GetCaster():Script_GetAttackRange()
	end
end
function modifier_spirit:OnDestroy()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		-- Kill
		if caster.spirit1 ~= nil then
		ParticleManager:DestroyParticle(caster.spirit1.pfx, false)
			if not caster.spirit1:IsNull() then
				caster.spirit1:ForceKill(true)
				caster.spirit1 = nil
			end
		end
		if caster.spirit2 ~= nil then
		ParticleManager:DestroyParticle(caster.spirit2.pfx, false)
			if not caster.spirit2:IsNull() then
				caster.spirit2:ForceKill(true)
				caster.spirit2 = nil
			end
		end
		if caster.spirit3 ~= nil then
		ParticleManager:DestroyParticle(caster.spirit3.pfx, false)
			if not caster.spirit3:IsNull() then
				caster.spirit3:ForceKill(true)
				caster.spirit3 = nil
			end
		end
	end
end
function modifier_spirit:CheckState()
	return {[MODIFIER_STATE_FLYING] = true, [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true, [MODIFIER_STATE_MAGIC_IMMUNE] = true, [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_NOT_ON_MINIMAP] = true, [MODIFIER_STATE_UNSELECTABLE] = true}
end
function modifier_spirit:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE} end
function modifier_spirit:GetModifierAttackRangeBonus() return self.spirit_attack_range end
function modifier_spirit:GetModifierBaseAttack_BonusDamage() return self.spirit_attack_damage end

------------------------------------------------------------------------------------------------------------------------
modifier_spirit_attack_speed = class({})
function modifier_spirit_attack_speed:OnCreated(kv)
	if IsServer() then
		self.spirit_attack_speed = self:GetAbility():GetSpecialValueFor("spirit_attack_speed")
    end
end
function modifier_spirit_attack_speed:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function modifier_spirit_attack_speed:GetModifierAttackSpeedBonus_Constant() return self.spirit_attack_speed end

------------------------------------------------------------------------------------------------------------------------
modifier_water_scepter_maim = class({})

function modifier_water_scepter_maim:IsDebuff() return true end
function modifier_water_scepter_maim:OnCreated(kv)
	if IsServer() then
		self.maim_slow_attack = self:GetAbility():GetSpecialValueFor("maim_slow_attack")
		self.maim_slow_movement = self:GetAbility():GetSpecialValueFor("maim_slow_movement")
    end
end
function modifier_water_scepter_maim:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_water_scepter_maim:GetModifierAttackSpeedBonus_Constant() return self.maim_slow_attack end
function modifier_water_scepter_maim:GetModifierMoveSpeedBonus_Percentage() return self.maim_slow_movement end

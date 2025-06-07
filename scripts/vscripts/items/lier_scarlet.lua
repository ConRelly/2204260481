--------------------
-- Lier Scarlet T --
--------------------
LinkLuaModifier("modifier_lier_scarlet_t", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
if item_lier_scarlet_t == nil then item_lier_scarlet_t = class({}) end
function item_lier_scarlet_t:GetIntrinsicModifierName() return "modifier_lier_scarlet_t" end
function item_lier_scarlet_t:Spawn()
    if IsServer() then
        local parent = self:GetParent()
        if self.SetCurrentCharges and self:GetCurrentCharges() == 0 then
            local min, max = 1, 6
            if parent and parent:HasModifier("modifier_super_scepter") then
                min = 3
            end
            self:SetCurrentCharges(RandomInt(min, max))
        end
    end
end

if modifier_lier_scarlet_t == nil then modifier_lier_scarlet_t = class({}) end
function modifier_lier_scarlet_t:IsHidden() return true end
function modifier_lier_scarlet_t:IsPurgable() return false end
function modifier_lier_scarlet_t:RemoveOnDeath() return false end
--function modifier_lier_scarlet_t:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_lier_scarlet_t:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end if not self:GetParent():IsIllusion() then
		if not self:GetCaster():HasModifier("modifier_lier_scarlet_pieces_thinker") then self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_pieces_thinker", {}) end
end end end
function modifier_lier_scarlet_t:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end
function modifier_lier_scarlet_t:GetModifierExtraHealthPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("max_hp_pct") * (-1) end
end
function modifier_lier_scarlet_t:GetModifierTotalDamageOutgoing_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("total_dmg") end
end

--------------------
-- Lier Scarlet M --
--------------------
LinkLuaModifier("modifier_lier_scarlet_m", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
if item_lier_scarlet_m == nil then item_lier_scarlet_m = class({}) end
function item_lier_scarlet_m:GetIntrinsicModifierName() return "modifier_lier_scarlet_m" end
function item_lier_scarlet_m:Spawn()
    if IsServer() then
        local parent = self:GetParent()
        if self.SetCurrentCharges and self:GetCurrentCharges() == 0 then
            local min, max = 1, 6
            if parent and parent:HasModifier("modifier_super_scepter") then
                min = 3
            end
            self:SetCurrentCharges(RandomInt(min, max))
        end
    end
end

if modifier_lier_scarlet_m == nil then modifier_lier_scarlet_m = class({}) end
function modifier_lier_scarlet_m:IsHidden() return true end
function modifier_lier_scarlet_m:IsPurgable() return false end
function modifier_lier_scarlet_m:RemoveOnDeath() return false end
--function modifier_lier_scarlet_m:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_lier_scarlet_m:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end if not self:GetParent():IsIllusion() then
		if not self:GetCaster():HasModifier("modifier_lier_scarlet_pieces_thinker") then self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_pieces_thinker", {}) end
		local aoe_interval = self:GetAbility():GetSpecialValueFor("aoe_interval")
		self:StartIntervalThink(aoe_interval)
end end end
function modifier_lier_scarlet_m:OnIntervalThink()
	if IsServer() then if not self:GetAbility() then self:Destroy() return end
		local caster = self:GetCaster()
		local heal_pct = self:GetAbility():GetSpecialValueFor("heal_pct")
		local aoe_dmg = self:GetAbility():GetSpecialValueFor("aoe_dmg")
		local aoe_radius = self:GetAbility():GetSpecialValueFor("aoe_radius")
		local dmg = caster:GetAverageTrueAttackDamage(caster) * aoe_dmg / 100
		local heal = (self:GetCaster():GetMaxHealth() * heal_pct / 100)
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, aoe_radius--[[FIND_UNITS_EVERYWHERE]], DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,enemy in pairs(enemies) do
			if enemy ~= self:GetCaster() then
				local damageTable = {victim = enemy, attacker = self:GetCaster(), damage = dmg, damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL, ability = self:GetAbility()}
				ApplyDamage(damageTable)
				local aoe_interval = self:GetAbility():GetSpecialValueFor("aoe_interval")
				Timers:CreateTimer((aoe_interval / 3), function() ApplyDamage(damageTable) end)
				Timers:CreateTimer((aoe_interval / 3 * 2), function() ApplyDamage(damageTable) end)
			end
		end
		self:GetCaster():Heal(heal,self:GetCaster())
	end
end
function modifier_lier_scarlet_m:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE}
end
function modifier_lier_scarlet_m:GetModifierExtraHealthPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("max_hp_pct") * (-1) end
end

--------------------
-- Lier Scarlet B --
--------------------
LinkLuaModifier("modifier_lier_scarlet_b", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
if item_lier_scarlet_b == nil then item_lier_scarlet_b = class({}) end
function item_lier_scarlet_b:GetIntrinsicModifierName() return "modifier_lier_scarlet_b" end
function item_lier_scarlet_b:Spawn()
    if IsServer() then
        local parent = self:GetParent()
        if self.SetCurrentCharges and self:GetCurrentCharges() == 0 then
            local min, max = 1, 6
            if parent and parent:HasModifier("modifier_super_scepter") then
                min = 3
            end
            self:SetCurrentCharges(RandomInt(min, max))
        end
    end
end

if modifier_lier_scarlet_b == nil then modifier_lier_scarlet_b = class({}) end
function modifier_lier_scarlet_b:IsHidden() return true end
function modifier_lier_scarlet_b:IsPurgable() return false end
function modifier_lier_scarlet_b:RemoveOnDeath() return false end
--function modifier_lier_scarlet_b:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_lier_scarlet_b:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end if not self:GetParent():IsIllusion() then
		if not self:GetCaster():HasModifier("modifier_lier_scarlet_pieces_thinker") then self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_pieces_thinker", {}) end
end end end
function modifier_lier_scarlet_b:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE}
end
function modifier_lier_scarlet_b:GetModifierExtraHealthPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("max_hp_pct") * (-1) end
end
function modifier_lier_scarlet_b:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_ms_pct") end
end
function modifier_lier_scarlet_b:GetModifierAttackSpeedPercentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_as_pct") end
end


----------------------------------------
-- Shortened Reach Pieces (thinker) --
----------------------------------------
LinkLuaModifier("modifier_lier_scarlet_pieces_thinker", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_lier_scarlet_pieces_thinker == nil then modifier_lier_scarlet_pieces_thinker = class({}) end
function modifier_lier_scarlet_pieces_thinker:IsHidden() return true end
function modifier_lier_scarlet_pieces_thinker:GetTexture() return "custom/lier_scarlet_2_piece" end
function modifier_lier_scarlet_pieces_thinker:IsPurgable() return false end
function modifier_lier_scarlet_pieces_thinker:RemoveOnDeath() return false end
function modifier_lier_scarlet_pieces_thinker:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end if not self:GetParent():IsIllusion() then
		self:StartIntervalThink(FrameTime())
end end end
function modifier_lier_scarlet_pieces_thinker:OnIntervalThink()
	if IsServer() then
		local lier_scarlet_t = self:GetCaster():HasModifier("modifier_lier_scarlet_t")
		local lier_scarlet_m = self:GetCaster():HasModifier("modifier_lier_scarlet_m")
		local lier_scarlet_b = self:GetCaster():HasModifier("modifier_lier_scarlet_b")
		--2piece
		if (lier_scarlet_t and lier_scarlet_m) or (lier_scarlet_m and lier_scarlet_b) or (lier_scarlet_b and lier_scarlet_t) then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_2_pieces", {})
		elseif self:GetCaster():HasModifier("modifier_lier_scarlet_2_pieces") then
			self:GetCaster():RemoveModifierByName("modifier_lier_scarlet_2_pieces")
		end
		--------
		--3piece
		if lier_scarlet_t and lier_scarlet_m and lier_scarlet_b and not self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff_cd") and not self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff") then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_3_pieces", {})
		elseif self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces") then
			self:GetCaster():RemoveModifierByName("modifier_lier_scarlet_3_pieces")
		end
		if self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff_cd") and self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff") then
			self:GetCaster():RemoveModifierByName("modifier_lier_scarlet_3_pieces")
		end
		--------
		if lier_scarlet_t or lier_scarlet_m or lier_scarlet_b then else
			self:GetCaster():RemoveModifierByName("modifier_lier_scarlet_pieces_thinker")
		end
	end
end


------------------------------
-- Shortened Reach 2 Pieces --
------------------------------
LinkLuaModifier("modifier_lier_scarlet_2_pieces", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_lier_scarlet_2_pieces == nil then modifier_lier_scarlet_2_pieces = class({}) end
function modifier_lier_scarlet_2_pieces:IsHidden() return false end
function modifier_lier_scarlet_2_pieces:GetTexture() return "custom/lier_scarlet_2_piece" end
function modifier_lier_scarlet_2_pieces:IsPurgable() return false end
function modifier_lier_scarlet_2_pieces:RemoveOnDeath() return false end
function modifier_lier_scarlet_2_pieces:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
	self.phys_dmg_reduction = self:GetAbility():GetSpecialValueFor("phys_dmg_reduction")
	self.bonus_status_resist = self:GetAbility():GetSpecialValueFor("bonus_status_resist")
end
function modifier_lier_scarlet_2_pieces:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE}
end
function modifier_lier_scarlet_2_pieces:GetModifierIncomingPhysicalDamage_Percentage()
	if self:GetAbility() then return self.phys_dmg_reduction * (-1) end
end
function modifier_lier_scarlet_2_pieces:GetModifierStatusResistance()
	if self:GetAbility() then return self.bonus_status_resist end
end


-------------------------
-- Sword Soul 3 Pieces --
-------------------------
LinkLuaModifier("modifier_lier_scarlet_3_pieces", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lier_scarlet_3_pieces_buff", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lier_scarlet_3_pieces_buff_cd", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_lier_scarlet_3_pieces == nil then modifier_lier_scarlet_3_pieces = class({}) end
function modifier_lier_scarlet_3_pieces:IsHidden() return false end
function modifier_lier_scarlet_3_pieces:GetTexture() return "custom/lier_scarlet_3_piece" end
function modifier_lier_scarlet_3_pieces:IsPurgable() return false end
function modifier_lier_scarlet_3_pieces:RemoveOnDeath() return false end
function modifier_lier_scarlet_3_pieces:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		self:StartIntervalThink(0.2)
	end
end
function modifier_lier_scarlet_3_pieces:DeclareFunctions()
	return {MODIFIER_PROPERTY_MIN_HEALTH}
end
function modifier_lier_scarlet_3_pieces:GetMinHealth()
	if self:GetAbility() then
		if not self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff_cd") then
			return 1
		end
	end
end
function modifier_lier_scarlet_3_pieces:OnIntervalThink()
	if IsServer() then if not self:GetAbility() then self:Destroy() return end
	local max_health = self:GetCaster():GetMaxHealth()
	local health_threshold = self:GetAbility():GetSpecialValueFor("health_threshold")
	local buff_duration = self:GetAbility():GetSpecialValueFor("3_pieces_duration")
	local trigger = max_health * (health_threshold / 100)
		if not self:GetCaster():IsIllusion() and not self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff_cd") and not self:GetCaster():HasModifier("modifier_lier_scarlet_3_pieces_buff") then
			if self:GetCaster():GetHealth() < trigger then
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_3_pieces_buff", {duration = buff_duration})
			end
		end
	end
end

------------------------------
-- Sword Soul 3 Pieces Buff --
------------------------------
if modifier_lier_scarlet_3_pieces_buff == nil then modifier_lier_scarlet_3_pieces_buff = class({}) end
function modifier_lier_scarlet_3_pieces_buff:IsHidden() return false end
function modifier_lier_scarlet_3_pieces_buff:GetTexture() return "custom/lier_scarlet_3_piece_immune" end
function modifier_lier_scarlet_3_pieces_buff:GetEffectName() return "particles/custom/items/lier_scarlet/lier_scarlet_immune.vpcf" end
function modifier_lier_scarlet_3_pieces_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_lier_scarlet_3_pieces_buff:IsPurgable() return false end
function modifier_lier_scarlet_3_pieces_buff:RemoveOnDeath() return false end
function modifier_lier_scarlet_3_pieces_buff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_lier_scarlet_3_pieces_buff:OnDestroy()
	if IsServer() then if not self:GetAbility() then self:Destroy() return end
		local pieces_cd = self:GetAbility():GetSpecialValueFor("3_pieces_cd")
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_3_pieces_buff_cd", {duration = pieces_cd})
	end
end
function modifier_lier_scarlet_3_pieces_buff:DeclareFunctions()
	return {--MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_lier_scarlet_3_pieces_buff:GetModifierCritDMG()
	if IsServer() then if not self:GetAbility() then self:Destroy() return end
		local lvl = self:GetParent():GetLevel()
		local bonus_crit = self:GetAbility():GetSpecialValueFor("bonus_crit")
		local bonus_crit_dmg = self:GetAbility():GetSpecialValueFor("bonus_crit_dmg") * lvl
		if RollPseudoRandom(bonus_crit, self:GetAbility()) then
			return bonus_crit_dmg
		end
	end
	return 0
end


function modifier_lier_scarlet_3_pieces_buff:OnTooltip()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_crit") end
end
function modifier_lier_scarlet_3_pieces_buff:GetModifierIncomingDamage_Percentage()
	if self:GetAbility() then return -100 end
end
function modifier_lier_scarlet_3_pieces_buff:GetMinHealth()
	if self:GetAbility() then return 1 end
end
function modifier_lier_scarlet_3_pieces_buff:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end
function modifier_lier_scarlet_3_pieces_buff:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("spell_amp") end
end

if modifier_lier_scarlet_3_pieces_buff_cd == nil then modifier_lier_scarlet_3_pieces_buff_cd = class({}) end
function modifier_lier_scarlet_3_pieces_buff_cd:IsHidden() return false end
function modifier_lier_scarlet_3_pieces_buff_cd:GetTexture() return "custom/lier_scarlet_3_piece_immune" end
function modifier_lier_scarlet_3_pieces_buff_cd:IsDebuff() return true end
function modifier_lier_scarlet_3_pieces_buff_cd:IsPurgable() return false end
function modifier_lier_scarlet_3_pieces_buff_cd:RemoveOnDeath() return false end
function modifier_lier_scarlet_3_pieces_buff_cd:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local duration = self:GetDuration()
--		self:SetStackCount(duration)
		self:StartIntervalThink(1)
	end
end
function modifier_lier_scarlet_3_pieces_buff_cd:OnIntervalThink()
	if IsServer() then
		local duration = self:GetStackCount() - 1 
--		self:SetStackCount(duration)
	end
end

----------------------------------------
-- Lier Scarlet Ascendant - Combined  --
----------------------------------------

-- LinkLuaModifier calls for new modifiers
LinkLuaModifier("modifier_lier_scarlet_ascendant", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_player_lier_scarlet_ascendant_strength_tier", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_player_lier_scarlet_ascendant_agility_tier", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_player_lier_scarlet_ascendant_intelligence_tier", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_player_lier_scarlet_ascendant_spell_amp_tier", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_player_lier_scarlet_ascendant_base_atk_tier", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lier_scarlet_ascendant_3_piece_buff", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lier_scarlet_ascendant_3_piece_buff_cd", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lier_scarlet_ascendant_lunar_buff", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lier_scarlet_ascendant_min_health", "items/lier_scarlet.lua", LUA_MODIFIER_MOTION_NONE)

-- Item Definition
if item_lier_scarlet_ascendant == nil then item_lier_scarlet_ascendant = class({}) end
function item_lier_scarlet_ascendant:GetIntrinsicModifierName()
    return "modifier_lier_scarlet_ascendant"
end

-- New Modifier for Min Health
if modifier_lier_scarlet_ascendant_min_health == nil then modifier_lier_scarlet_ascendant_min_health = class({}) end
function modifier_lier_scarlet_ascendant_min_health:IsHidden() return true end
function modifier_lier_scarlet_ascendant_min_health:IsPurgable() return false end
function modifier_lier_scarlet_ascendant_min_health:RemoveOnDeath() return true end
function modifier_lier_scarlet_ascendant_min_health:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MIN_HEALTH,
    }
end
function modifier_lier_scarlet_ascendant_min_health:GetMinHealth()
    if not self:GetAbility() then return 0 end
    -- This provides the "don't die" aspect when the 3-piece buff is NOT active but CD is also not active
    if self:GetCaster() and self:GetCaster():HasModifier("modifier_lier_scarlet_ascendant") and not self:GetCaster():HasModifier("modifier_lier_scarlet_ascendant_3_piece_buff") and not self:GetCaster():HasModifier("modifier_lier_scarlet_ascendant_3_piece_buff_cd") then
        return 1
    end
end

-- Hidden Player Stat Modifiers
-- Strength Tier
if modifier_player_lier_scarlet_ascendant_strength_tier == nil then modifier_player_lier_scarlet_ascendant_strength_tier = class({}) end
function modifier_player_lier_scarlet_ascendant_strength_tier:IsHidden() return true end
function modifier_player_lier_scarlet_ascendant_strength_tier:IsPurgable() return false end
function modifier_player_lier_scarlet_ascendant_strength_tier:RemoveOnDeath() return false end
function modifier_player_lier_scarlet_ascendant_strength_tier:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

-- Agility Tier
if modifier_player_lier_scarlet_ascendant_agility_tier == nil then modifier_player_lier_scarlet_ascendant_agility_tier = class({}) end
function modifier_player_lier_scarlet_ascendant_agility_tier:IsHidden() return true end
function modifier_player_lier_scarlet_ascendant_agility_tier:IsPurgable() return false end
function modifier_player_lier_scarlet_ascendant_agility_tier:RemoveOnDeath() return false end
function modifier_player_lier_scarlet_ascendant_agility_tier:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

-- Intelligence Tier
if modifier_player_lier_scarlet_ascendant_intelligence_tier == nil then modifier_player_lier_scarlet_ascendant_intelligence_tier = class({}) end
function modifier_player_lier_scarlet_ascendant_intelligence_tier:IsHidden() return true end
function modifier_player_lier_scarlet_ascendant_intelligence_tier:IsPurgable() return false end
function modifier_player_lier_scarlet_ascendant_intelligence_tier:RemoveOnDeath() return false end
function modifier_player_lier_scarlet_ascendant_intelligence_tier:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

-- Spell Amp Tier
if modifier_player_lier_scarlet_ascendant_spell_amp_tier == nil then modifier_player_lier_scarlet_ascendant_spell_amp_tier = class({}) end
function modifier_player_lier_scarlet_ascendant_spell_amp_tier:IsHidden() return true end
function modifier_player_lier_scarlet_ascendant_spell_amp_tier:IsPurgable() return false end
function modifier_player_lier_scarlet_ascendant_spell_amp_tier:RemoveOnDeath() return false end
function modifier_player_lier_scarlet_ascendant_spell_amp_tier:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

-- Base Attack Tier
if modifier_player_lier_scarlet_ascendant_base_atk_tier == nil then modifier_player_lier_scarlet_ascendant_base_atk_tier = class({}) end
function modifier_player_lier_scarlet_ascendant_base_atk_tier:IsHidden() return true end
function modifier_player_lier_scarlet_ascendant_base_atk_tier:IsPurgable() return false end
function modifier_player_lier_scarlet_ascendant_base_atk_tier:RemoveOnDeath() return false end
function modifier_player_lier_scarlet_ascendant_base_atk_tier:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

-- Main Combined Item Modifier
if modifier_lier_scarlet_ascendant == nil then modifier_lier_scarlet_ascendant = class({}) end
function modifier_lier_scarlet_ascendant:IsHidden() return false end
function modifier_lier_scarlet_ascendant:IsPurgable() return false end
function modifier_lier_scarlet_ascendant:RemoveOnDeath() return true end -- Removed with item
function modifier_lier_scarlet_ascendant:GetTexture() return "custom/lier_scarlet_ascendant" end -- Placeholder icon

function modifier_lier_scarlet_ascendant:OnCreated()
    if IsServer() then
        if not self:GetAbility() then self:Destroy(); return end
        if self:GetParent():IsIllusion() then self:Destroy(); return end

        -- Initialize values from AbilitySpecial for precursor item effects
        -- Item T
        self.total_dmg_pct = self:GetAbility():GetSpecialValueFor("total_dmg_t")
        -- Item M
        self.heal_pct_m = self:GetAbility():GetSpecialValueFor("heal_pct_m")
        self.aoe_dmg_m = self:GetAbility():GetSpecialValueFor("aoe_dmg_m") / 100
        self.aoe_radius_m = self:GetAbility():GetSpecialValueFor("aoe_radius_m")
        self.aoe_dmg_interval_m = self:GetAbility():GetSpecialValueFor("aoe_dmg_interval_m")
        -- Item B
        self.bonus_ms_pct_b = self:GetAbility():GetSpecialValueFor("bonus_ms_pct_b")
        self.bonus_as_pct_b = self:GetAbility():GetSpecialValueFor("bonus_as_pct_b")
        -- 2-Piece Set
        self.phys_dmg_reduction_2p = self:GetAbility():GetSpecialValueFor("phys_dmg_reduction_2p")
        self.bonus_status_resist_2p = self:GetAbility():GetSpecialValueFor("bonus_status_resist_2p")
        -- 3-Piece Set (for triggering its buff)
        self.health_threshold_3p = self:GetAbility():GetSpecialValueFor("health_threshold_3p")
        self.buff_duration_3p = self:GetAbility():GetSpecialValueFor("buff_duration_3p")
        
        self:StartIntervalThink(self.aoe_dmg_interval_m) --0.25
    end
end

function modifier_lier_scarlet_ascendant:OnIntervalThink()
    if IsServer() then
        if not self:GetAbility() or not self:GetParent() or self:GetParent():IsNull() then self:Destroy(); return end
        if self:GetParent():IsIllusion() then return end
        if not self:GetParent():IsRealHero() then return end
        if not self:GetParent():IsAlive() then return end

        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local caster_lvl = caster:GetLevel()

        -- Ensure the min_health modifier is present
        if not caster:HasModifier("modifier_lier_scarlet_ascendant_min_health") then
            caster:AddNewModifier(caster, ability, "modifier_lier_scarlet_ascendant_min_health", {})
        end

        -- Item M's AOE Damage and Heal
        if self.aoe_radius_m > 0 and self.aoe_dmg_m > 0 then
            local aoe_dmgmult_lvl = self.aoe_dmg_m * caster_lvl
            local dmg_m = caster:GetAverageTrueAttackDamage(caster) * aoe_dmgmult_lvl
            local enemies_m = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, self.aoe_radius_m, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
            for _,enemy_m in pairs(enemies_m) do
                if enemy_m ~= caster then
                    local damageTable_m = {victim = enemy_m, attacker = caster, damage = dmg_m, damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL, ability = ability}
                    ApplyDamage(damageTable_m)
                end
            end
            -- Heal only every 4th call (every 1s)
            self._lier_scarlet_asc_heal_counter = (self._lier_scarlet_asc_heal_counter or 0) + 1
            if self._lier_scarlet_asc_heal_counter >= 4 then
                local heal_m = (caster:GetMaxHealth() * self.heal_pct_m / 100)
                if heal_m > 0 then caster:Heal(heal_m, caster) end
                self._lier_scarlet_asc_heal_counter = 0
            end
        end

        -- 3-Piece Set Bonus Logic (triggering the buff)
        if not caster:HasModifier("modifier_lier_scarlet_ascendant_3_piece_buff_cd") and not caster:HasModifier("modifier_lier_scarlet_ascendant_3_piece_buff") then
            local max_health = caster:GetMaxHealth()
            local trigger_health = max_health * (self.health_threshold_3p / 100)
            if caster:GetHealth() < trigger_health then
                caster:AddNewModifier(caster, ability, "modifier_lier_scarlet_ascendant_3_piece_buff", {duration = self.buff_duration_3p})
                -- Remove lunar buff if present when 3-piece buff triggers
                if caster:HasModifier("modifier_lier_scarlet_ascendant_lunar_buff") then
                    caster:RemoveModifierByName("modifier_lier_scarlet_ascendant_lunar_buff")
                end
            end
        end

        -- Lunar Shield Ascendant Buff Logic (independent of 3-piece buff CD, but still health threshold based)
        if caster:HasItemInInventory("item_lunar_shield") and caster:HasModifier("modifier_super_scepter") then
            if not caster:HasModifier("modifier_lier_scarlet_ascendant_3_piece_buff") and not caster:HasModifier("modifier_lier_scarlet_ascendant_lunar_buff") then
                local max_health = caster:GetMaxHealth()
                local trigger_health = max_health * (self.health_threshold_3p / 100)
                if caster:GetHealth() < trigger_health then
                    caster:AddNewModifier(caster, ability, "modifier_lier_scarlet_ascendant_lunar_buff", {duration = self.buff_duration_3p})
                end
            end
        else
            if caster:HasModifier("modifier_lier_scarlet_ascendant_lunar_buff") then
                caster:RemoveModifierByName("modifier_lier_scarlet_ascendant_lunar_buff")
            end
        end
    end
end

function modifier_lier_scarlet_ascendant:DeclareFunctions()
    return {
        -- Dynamic Stats
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, -- Base Spell Amp from dynamic stats
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,

        -- Item T effects
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE, -- Will sum T, M, B HP reductions
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, -- From T

        -- Item B effects
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, -- From B
        MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE, -- From B

        -- 2-Piece Set effects
        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE, -- From 2P
        MODIFIER_PROPERTY_STATUS_RESISTANCE, -- From 2P

        
    }
end

function modifier_lier_scarlet_ascendant:GetModifierExtraHealthPercentage()
    if not self:GetAbility() then return 0 end
    local hp_reduction_t = self:GetAbility():GetSpecialValueFor("max_hp_pct_t")
    local hp_reduction_m = self:GetAbility():GetSpecialValueFor("max_hp_pct_m")
    local hp_reduction_b = self:GetAbility():GetSpecialValueFor("max_hp_pct_b")
    return (hp_reduction_t + hp_reduction_m + hp_reduction_b) * (-1)
end

function modifier_lier_scarlet_ascendant:GetModifierTotalDamageOutgoing_Percentage()
    if not self:GetAbility() then return 0 end
    return self:GetAbility():GetSpecialValueFor("total_dmg_t")
end

function modifier_lier_scarlet_ascendant:GetModifierMoveSpeedBonus_Percentage()
    if not self:GetAbility() then return 0 end
    return self:GetAbility():GetSpecialValueFor("bonus_ms_pct_b")
end

function modifier_lier_scarlet_ascendant:GetModifierAttackSpeedPercentage()
    if not self:GetAbility() then return 0 end
    return self:GetAbility():GetSpecialValueFor("bonus_as_pct_b")
end

function modifier_lier_scarlet_ascendant:GetModifierIncomingPhysicalDamage_Percentage()
    if not self:GetAbility() then return 0 end
    return self:GetAbility():GetSpecialValueFor("phys_dmg_reduction_2p") * (-1)
end

function modifier_lier_scarlet_ascendant:GetModifierStatusResistance()
    if not self:GetAbility() then return 0 end
    return self:GetAbility():GetSpecialValueFor("bonus_status_resist_2p")
end


function modifier_lier_scarlet_ascendant:GetModifierBonusStats_Strength()
    local hero = self:GetParent()
    if not hero then return 0 end
    local rolled_stacks = hero:GetModifierStackCount("modifier_player_lier_scarlet_ascendant_strength_tier", hero) or 0
    if rolled_stacks > 0 then
        -- Base T1=14, Base T5=70. Value_Per_Stack_Unit = 1.4
        local final_base_strength = 14 + (rolled_stacks - 10) * 1.4
        return final_base_strength * hero:GetLevel()
    end
    return 0
end

function modifier_lier_scarlet_ascendant:GetModifierBonusStats_Agility()
    local hero = self:GetParent()
    if not hero then return 0 end
    local rolled_stacks = hero:GetModifierStackCount("modifier_player_lier_scarlet_ascendant_agility_tier", hero) or 0
    if rolled_stacks > 0 then
        -- Base T1=14, Base T5=70. Value_Per_Stack_Unit = 1.4
        local final_base_agility = 14 + (rolled_stacks - 10) * 1.4
        return final_base_agility * hero:GetLevel()
    end
    return 0
end

function modifier_lier_scarlet_ascendant:GetModifierBonusStats_Intellect()
    local hero = self:GetParent()
    if not hero then return 0 end
    local rolled_stacks = hero:GetModifierStackCount("modifier_player_lier_scarlet_ascendant_intelligence_tier", hero) or 0
    if rolled_stacks > 0 then
        -- Base T1=7, Base T5=35. Value_Per_Stack_Unit = 0.7
        local final_base_intelligence = 7 + (rolled_stacks - 10) * 0.7
        return final_base_intelligence * hero:GetLevel()
    end
    return 0
end

function modifier_lier_scarlet_ascendant:GetModifierSpellAmplify_Percentage()
    local hero = self:GetParent()
    local ability = self:GetAbility()
    if not hero or not ability then return 0 end

    local rolled_stacks = hero:GetModifierStackCount("modifier_player_lier_scarlet_ascendant_spell_amp_tier", hero) or 0
    if rolled_stacks > 0 then
        local final_base_spell_amp_percent = 1 + (rolled_stacks - 10) * 0.1
        return final_base_spell_amp_percent * hero:GetLevel()
    end
    return 0
end

function modifier_lier_scarlet_ascendant:GetModifierBaseAttack_BonusDamage()
    local hero = self:GetParent()
    if not hero then return 0 end
    local rolled_stacks = hero:GetModifierStackCount("modifier_player_lier_scarlet_ascendant_base_atk_tier", hero) or 0
    if rolled_stacks > 0 then
        -- Base T1=100, Base T5=500. Value_Per_Stack_Unit = 10
        local final_base_attack_damage = 100 + (rolled_stacks - 10) * 10
        return final_base_attack_damage * hero:GetLevel()
    end
    return 0
end


-- Combination Function
function LierScarlet_CombineAscendant(keys)
    local caster = keys.caster
    local forced_benefit_id = tonumber(keys.forced_benefit_id) -- 1:Str, 2:Agi, 3:Int, 4:SpellAmp, 5:BaseAtk

    if not caster or not caster.IsRealHero or not caster:IsRealHero() then
        if caster and caster.GetName then
            print("[Lier Scarlet Ascendant] Error: Caster (" .. caster:GetName() .. ") is not a real hero or invalid.")
        else
            print("[Lier Scarlet Ascendant] Error: Caster not found or invalid.")
        end
        return
    end

    -- Validate precursor items and count their charges
    local item_t_name = "item_lier_scarlet_t"
    local item_m_name = "item_lier_scarlet_m"
    local item_b_name = "item_lier_scarlet_b"

    local item_t_instance, item_m_instance, item_b_instance
    local t_charges, m_charges, b_charges = 0, 0, 0

    for i=0, 8 do
        local item = caster:GetItemInSlot(i)
        if item then
            local item_name = item:GetAbilityName()
            if item_name == item_t_name then
                item_t_instance = item
                t_charges = item:GetCurrentCharges() or 0
            end
            if item_name == item_m_name then
                item_m_instance = item
                m_charges = item:GetCurrentCharges() or 0
            end
            if item_name == item_b_name then
                item_b_instance = item
                b_charges = item:GetCurrentCharges() or 0
            end
        end
    end

    if not (item_t_instance and item_m_instance and item_b_instance) then
        if caster.PlayerLastSaid then 
            if GameRules:GetGameTime() - caster.PlayerLastSaid < 2.0 then return end
        end
        caster.PlayerLastSaid = GameRules:GetGameTime()
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, 0, nil)
        return
    end

    -- Calculate minimum conceptual tier budget based on precursor item charges
    local min_budget = math.max(t_charges, 0) + math.max(m_charges, 0) + math.max(b_charges, 0)
    -- If all are 0, min_budget is 0, so allow random as before
    local conceptual_tier_budget
    if min_budget > 0 then
        conceptual_tier_budget = RandomInt(min_budget, 25)
    else
        conceptual_tier_budget = RandomInt(1, 25)
    end

    -- Remove precursor items
    if item_t_instance then caster:TakeItem(item_t_instance); item_t_instance = nil; end
    if item_m_instance then caster:TakeItem(item_m_instance); item_m_instance = nil; end
    if item_b_instance then caster:TakeItem(item_b_instance); item_b_instance = nil; end

    -- Grant new item and set its charges to conceptual_tier_budget
    local new_item = caster:AddItemByName("item_lier_scarlet_ascendant")
    if not new_item then
        print("[Lier Scarlet Ascendant] Error: Failed to create new item 'item_lier_scarlet_ascendant'.")
        return
    end
    if new_item.SetCurrentCharges then
        new_item:SetCurrentCharges(conceptual_tier_budget)
    end

    -- Allocate Conceptual Tiers
    local stat_keys = {"strength", "agility", "intelligence", "spell_amp", "base_atk"}
    local assigned_conceptual_tiers = {}
    for _, key in ipairs(stat_keys) do
        assigned_conceptual_tiers[key] = 1
    end

    local points_to_allocate = conceptual_tier_budget
    local forced_stat_key = nil
    if forced_benefit_id and forced_benefit_id >= 1 and forced_benefit_id <= #stat_keys then
        forced_stat_key = stat_keys[forced_benefit_id]
    end

    -- Only force a stat to min tier 3 if forced_benefit_id is valid and not 0
    if forced_stat_key then
        local current_tier_for_forced = assigned_conceptual_tiers[forced_stat_key]
        local min_forced_tier = 3
        local desired_forced_conceptual_tier = RandomInt(min_forced_tier, 5)
        local cost_to_min3 = min_forced_tier - current_tier_for_forced
        if points_to_allocate < cost_to_min3 then
            -- Not enough budget, forcibly set to tier 3, budget goes to 0
            assigned_conceptual_tiers[forced_stat_key] = min_forced_tier
            points_to_allocate = 0
        else
            -- Enough budget for tier 3, maybe higher
            local max_possible_tier = math.min(5, current_tier_for_forced + points_to_allocate)
            desired_forced_conceptual_tier = math.min(desired_forced_conceptual_tier, max_possible_tier)
            local cost_for_forced = desired_forced_conceptual_tier - current_tier_for_forced
            assigned_conceptual_tiers[forced_stat_key] = desired_forced_conceptual_tier
            points_to_allocate = points_to_allocate - cost_for_forced
        end
    end

    -- Remaining Stats Allocation
    local remaining_stat_keys_for_random_alloc = {}
    for _, key in ipairs(stat_keys) do
        if key ~= forced_stat_key then
            table.insert(remaining_stat_keys_for_random_alloc, key)
        end
    end
    for i = #remaining_stat_keys_for_random_alloc, 2, -1 do
        local j = RandomInt(1, i)
        remaining_stat_keys_for_random_alloc[i], remaining_stat_keys_for_random_alloc[j] = remaining_stat_keys_for_random_alloc[j], remaining_stat_keys_for_random_alloc[i]
    end
    for _, stat_key in ipairs(remaining_stat_keys_for_random_alloc) do
        if points_to_allocate <= 0 then break end
        local current_tier_for_stat = assigned_conceptual_tiers[stat_key]
        if current_tier_for_stat < 5 then 
            local max_additional_points_for_this_stat = math.min(5 - current_tier_for_stat, points_to_allocate)
            if max_additional_points_for_this_stat > 0 then
                local actual_points_added = RandomInt(0, max_additional_points_for_this_stat)
                assigned_conceptual_tiers[stat_key] = current_tier_for_stat + actual_points_added
                points_to_allocate = points_to_allocate - actual_points_added
            end
        end
    end

    -- Roll Actual Stacks for Each Stat and Apply Modifiers
    for _, stat_key in ipairs(stat_keys) do
        local conceptual_tier = assigned_conceptual_tiers[stat_key]
        conceptual_tier = math.max(1, math.min(5, conceptual_tier))
        local rolled_stacks = 0
        if conceptual_tier == 1 then rolled_stacks = RandomInt(10, 19)
        elseif conceptual_tier == 2 then rolled_stacks = RandomInt(20, 29)
        elseif conceptual_tier == 3 then rolled_stacks = RandomInt(30, 39)
        elseif conceptual_tier == 4 then rolled_stacks = RandomInt(40, 49)
        elseif conceptual_tier == 5 then rolled_stacks = RandomInt(50, 59)
        end
        local hidden_mod_name = "modifier_player_lier_scarlet_ascendant_" .. stat_key .. "_tier"
        local existing_player_mod = caster:FindModifierByName(hidden_mod_name)
        if existing_player_mod then
            caster:RemoveModifierByName(hidden_mod_name)
        end
        local player_stat_mod = caster:AddNewModifier(caster, new_item, hidden_mod_name, {})
        if player_stat_mod then
            player_stat_mod:SetStackCount(rolled_stacks)
        else
            print("[Lier Scarlet Ascendant] Error: Failed to apply hidden modifier: " .. hidden_mod_name .. " for caster " .. caster:GetName())
        end
    end

    -- Notify player of rolled stats (short summary)
    local stat_short = {strength = "STR", agility = "AGI", intelligence = "INT", spell_amp = "AMP", base_atk = "ATK"}
    local msg_parts = {}
    for _, stat_key in ipairs(stat_keys) do
        local tier = assigned_conceptual_tiers[stat_key]
        local mod_name = "modifier_player_lier_scarlet_ascendant_" .. stat_key .. "_tier"
        local stacks = caster:FindModifierByName(mod_name) and caster:FindModifierByName(mod_name):GetStackCount() or 0
        table.insert(msg_parts, string.format("%s T%d: %d", stat_short[stat_key], tier, stacks))
    end
    local msg = table.concat(msg_parts, " | ") .. " (Roll Min-max is: 10-59)"
    local plyID = caster.GetPlayerOwnerID and caster:GetPlayerOwnerID() or nil
    if plyID and Notifications and Notifications.Top then
        Notifications:Top(plyID, {text=msg, duration=18.0, style={color="red"}})
    end

    if caster.PlayerLastSaid then 
        if GameRules:GetGameTime() - caster.PlayerLastSaid < 2.0 then return end
    end
    caster.PlayerLastSaid = GameRules:GetGameTime()
    print("[Lier Scarlet Ascendant] Combined for " .. caster:GetName() .. ". Budget: " .. conceptual_tier_budget .. ". Forced ID: " .. (forced_benefit_id or "None"))
    for k,v in pairs(assigned_conceptual_tiers) do
        print("  Stat " .. k .. ": Conceptual Tier " .. v .. ", Stacks: " .. (caster:FindModifierByName("modifier_player_lier_scarlet_ascendant_"..k.."_tier") and caster:FindModifierByName("modifier_player_lier_scarlet_ascendant_"..k.."_tier"):GetStackCount() or "N/A"))
    end
end

---------------------------------------------------------
-- Lier Scarlet Ascendant - 3 Piece Buff & CD Sub-Modifiers --
---------------------------------------------------------

-- Ascendant 3 Piece Buff (similar to original modifier_lier_scarlet_3_pieces_buff)
if modifier_lier_scarlet_ascendant_3_piece_buff == nil then modifier_lier_scarlet_ascendant_3_piece_buff = class({}) end
function modifier_lier_scarlet_ascendant_3_piece_buff:IsHidden() return false end
function modifier_lier_scarlet_ascendant_3_piece_buff:GetTexture() return "custom/lier_scarlet_3_piece_immune" end -- Use same texture or new one
function modifier_lier_scarlet_ascendant_3_piece_buff:GetEffectName() return "particles/custom/items/lier_scarlet/lier_scarlet_immune.vpcf" end
function modifier_lier_scarlet_ascendant_3_piece_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_lier_scarlet_ascendant_3_piece_buff:IsPurgable() return false end
function modifier_lier_scarlet_ascendant_3_piece_buff:RemoveOnDeath() return false end -- Buff persists through death if duration allows

function modifier_lier_scarlet_ascendant_3_piece_buff:OnCreated(params)
    --if IsServer() then
        if not self:GetAbility() then self:Destroy(); return end
        self.bonus_crit_3p = self:GetAbility():GetSpecialValueFor("bonus_crit_3p")
        self.bonus_crit_dmg_3p = self:GetAbility():GetSpecialValueFor("bonus_crit_dmg_3p")
        self.spell_amp_3p_buff = self:GetAbility():GetSpecialValueFor("spell_amp_3p_buff")
    --end
end

function modifier_lier_scarlet_ascendant_3_piece_buff:OnDestroy()
    if IsServer() then
        if not self:GetAbility() or not self:GetCaster() or self:GetCaster():IsNull() then return end
        local cd_duration = self:GetAbility():GetSpecialValueFor("cooldown_3p")
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lier_scarlet_ascendant_3_piece_buff_cd", {duration = cd_duration})
    end
end

function modifier_lier_scarlet_ascendant_3_piece_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, -- For crit damage
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, -- For the buff's own spell amp
        MODIFIER_PROPERTY_TOOLTIP, -- For crit chance display
        MODIFIER_PROPERTY_TOOLTIP2 --for crit damage display
    }
end

function modifier_lier_scarlet_ascendant_3_piece_buff:GetModifierPreAttack_CriticalStrike(params)
    if IsServer() then
        if not self:GetAbility() then return 0 end
        local lvl = self:GetParent():GetLevel()
        -- Roll for crit chance, then return damage if crit
        if RollPercentage(self.bonus_crit_3p) then
            return self.bonus_crit_dmg_3p * lvl -- Crit damage is hero level scaled
        end
    end
    return 0
end

function modifier_lier_scarlet_ascendant_3_piece_buff:OnTooltip()
    if self:GetAbility() then return self.bonus_crit_3p end -- Show crit chance
    return 0
end
-- crit * parent lvl
function modifier_lier_scarlet_ascendant_3_piece_buff:OnTooltip2()
    if self:GetAbility() then return self.bonus_crit_dmg_3p * self:GetParent():GetLevel() end -- Show crit damage
    return 0
end

function modifier_lier_scarlet_ascendant_3_piece_buff:GetModifierIncomingDamage_Percentage()
    if self:GetAbility() then return -100 end -- Damage immunity
    return 0
end

function modifier_lier_scarlet_ascendant_3_piece_buff:GetMinHealth()
    if self:GetAbility() then return 1 end -- Death immunity
    return 0
end

function modifier_lier_scarlet_ascendant_3_piece_buff:CheckState()
    return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_lier_scarlet_ascendant_3_piece_buff:GetModifierSpellAmplify_Percentage()
    if self:GetAbility() then return self.spell_amp_3p_buff end -- This is flat, not hero level scaled by default from original item
    return 0
end

-- Ascendant 3 Piece Buff CD (similar to original modifier_lier_scarlet_3_pieces_buff_cd)
if modifier_lier_scarlet_ascendant_3_piece_buff_cd == nil then modifier_lier_scarlet_ascendant_3_piece_buff_cd = class({}) end
function modifier_lier_scarlet_ascendant_3_piece_buff_cd:IsHidden() return false end
function modifier_lier_scarlet_ascendant_3_piece_buff_cd:GetTexture() return "custom/lier_scarlet_3_piece_immune" end -- Use same texture or new one, maybe with CD overlay
function modifier_lier_scarlet_ascendant_3_piece_buff_cd:IsDebuff() return true end
function modifier_lier_scarlet_ascendant_3_piece_buff_cd:IsPurgable() return false end
function modifier_lier_scarlet_ascendant_3_piece_buff_cd:RemoveOnDeath() return false end -- CD persists through death

-- Lunar Shield Ascendant Buff (like 3-piece buff, but no death/damage immunity, has magic immune state, and only triggers on health threshold, not affected by 3-piece buff CD)
if modifier_lier_scarlet_ascendant_lunar_buff == nil then modifier_lier_scarlet_ascendant_lunar_buff = class({}) end
function modifier_lier_scarlet_ascendant_lunar_buff:IsHidden() return false end
function modifier_lier_scarlet_ascendant_lunar_buff:GetTexture() return "custom/lier_scarlet_3_piece" end
function modifier_lier_scarlet_ascendant_lunar_buff:GetEffectName() return "particles/items_fx/black_king_bar_avatar.vpcf" end
function modifier_lier_scarlet_ascendant_lunar_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_lier_scarlet_ascendant_lunar_buff:IsPurgable() return false end
function modifier_lier_scarlet_ascendant_lunar_buff:RemoveOnDeath() return true end

function modifier_lier_scarlet_ascendant_lunar_buff:OnCreated(params)
    if not self:GetAbility() then self:Destroy(); return end
    self.bonus_crit_3p = self:GetAbility():GetSpecialValueFor("bonus_crit_3p")
    self.bonus_crit_dmg_3p = self:GetAbility():GetSpecialValueFor("bonus_crit_dmg_3p")
    self.spell_amp_3p_buff = self:GetAbility():GetSpecialValueFor("spell_amp_3p_buff")
end

function modifier_lier_scarlet_ascendant_lunar_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_TOOLTIP2
    }
end

function modifier_lier_scarlet_ascendant_lunar_buff:GetModifierPreAttack_CriticalStrike(params)
    if IsServer() then
        if not self:GetAbility() then return 0 end
        local lvl = self:GetParent():GetLevel()
        if RollPercentage(self.bonus_crit_3p) then
            return self.bonus_crit_dmg_3p * lvl
        end
    end
    return 0
end

function modifier_lier_scarlet_ascendant_lunar_buff:OnTooltip()
    if self:GetAbility() then return self.bonus_crit_3p end
    return 0
end
function modifier_lier_scarlet_ascendant_lunar_buff:OnTooltip2()
    if self:GetAbility() then return self.bonus_crit_dmg_3p * self:GetParent():GetLevel() end
    return 0
end
function modifier_lier_scarlet_ascendant_lunar_buff:GetModifierSpellAmplify_Percentage()
    if self:GetAbility() then return self.spell_amp_3p_buff end
    return 0
end
function modifier_lier_scarlet_ascendant_lunar_buff:CheckState()
    return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

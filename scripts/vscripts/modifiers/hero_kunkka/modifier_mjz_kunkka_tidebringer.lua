LinkLuaModifier("modifier_mjz_kunkka_tidebringer_effect", "modifiers/hero_kunkka/modifier_mjz_kunkka_tidebringer_effect.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mjz_kunkka_tidebringer = class({})
local modifier_class = modifier_mjz_kunkka_tidebringer

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
	
	function modifier_class:OnCreated(keys)
		local parent = self:GetParent()
		local ability = self:GetAbility()
        self.modifier_effect_name = "modifier_mjz_kunkka_tidebringer_effect"

        if IsServer() then
            if not ability:GetAutoCastState() then
                ability:ToggleAutoCast()
            end

            parent:AddNewModifier(parent, ability, self.modifier_effect_name, {})
            self:StartIntervalThink(0.1)
        end
    end

    function modifier_class:OnRefresh()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        -- Add weapon glow effect only if the ability is off cooldown
        if IsServer() then
            if ability:IsCooldownReady() and (not parent:IsSilenced()) then
                if ability:GetAutoCastState() == true then
                    parent:AddNewModifier(parent, ability, self.modifier_effect_name, {})
                else
                    -- Autocast is off
                    parent:RemoveModifierByName(self.modifier_effect_name)
                    -- manual cast? doesn't work but don't remove
                    if self.manual_cast then
                        parent:AddNewModifier(parent, ability, self.modifier_effect_name, {})
                    end
                end
            else
                parent:RemoveModifierByName(self.modifier_effect_name)
            end
        end
    end

    function modifier_class:OnIntervalThink()
        if IsServer() then
            self:ForceRefresh()
        end
    end

	function modifier_class:DeclareFunctions() 
		local funcs = {
		    MODIFIER_EVENT_ON_ATTACK,
		    MODIFIER_EVENT_ON_ATTACK_LANDED
		}
		return funcs 
	end
    
    function modifier_class:OnAttack(event)
        local parent = self:GetParent()
        local ability = self:GetAbility()
        
        if event.attacker ~= parent then
            return
        end
    
        if parent:GetCurrentActiveAbility() ~= ability then
            return
        end
        
        -- Manual cast detected
        self.manual_cast = true
    end
    
    function modifier_class:OnAttackLanded(event)
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local target = event.target
        
        if event.attacker == parent and ability:IsCooldownReady() and (not parent:IsSilenced()) then
            if ability:GetAutoCastState() == true then
                -- The Attack while autocast is on
                self:HolyStrike(event)
            else
                -- The Attack while autocast is off
                if self.manual_cast then
                    self:HolyStrike(event)
                end
            end
        end
    end

    function modifier_class:HolyStrike(event)
        if IsServer() and event then
            local attacker = event.attacker or self:GetParent()
            local target = event.target
            local ability = self:GetAbility()	
            local attack_damage = event.original_damage
    
            -- If the attack target is a building or a ward then stop (return)
            if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() then
                return
            end
            
            -- If the attacker is an illusion then stop (return)
            if attacker:IsIllusion() then
                return
            end

            local strength_damage_pct = GetTalentSpecialValueFor(ability, "strength_damage_pct")
            local bonus_damage = attacker:GetStrength() * (strength_damage_pct / 100)
    
            local damage_table = {
                attacker = attacker,
                victim = target,
                ability = ability,
                damage = bonus_damage,
                damage_type = ability:GetAbilityDamageType(),
            }
            ApplyDamage(damage_table)

            self:_DoCleaveAttack(attacker, ability, target, attack_damage + bonus_damage)
            
            -- local player = attacker:GetPlayerOwner()
            -- SendOverheadEventMessage(player, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, true_damage, player)
    
            attacker:EmitSound("Hero_Kunkka.Tidebringer.Attack")
    
            ability:UseResources(true, false, true)
    
            -- Remove weapon glow effect
            attacker:RemoveModifierByName(self.modifier_effect_name)
            ability:StartCooldown(ability:GetCooldownTimeRemaining())
    
            self.manual_cast = nil
        end
    end

    function modifier_class:_DoCleaveAttack(caster, ability, target, attack_damage)
        local cleave_percent = GetTalentSpecialValueFor(ability, "cleave_damage")
        local cleave_start_radius = GetTalentSpecialValueFor(ability, "cleave_starting_width")
        local cleave_end_radius = GetTalentSpecialValueFor(ability, "cleave_ending_width")
        local cleave_distance = GetTalentSpecialValueFor(ability, "cleave_distance")

        local cleaveDamage = attack_damage * (cleave_percent / 100.0)

        local cleave_effect_kunkka = "particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf"
        local cleave_effect_kunkka_fxset = "particles/econ/items/kunkka/divine_anchor/hero_kunkka_dafx_weapon/kunkka_spell_tidebringer_fxset.vpcf"
        local cleave_effect_sven = "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf"
        local cleave_effect_sven_ti7_crit  = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_crit.vpcf"
        local cleave_effect_sven_ti7_gods_crit = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength_crit.vpcf"

        local cleave_effectName = cleave_effect_kunkka_fxset

        DoCleaveAttack(caster, target, ability, cleaveDamage, cleave_start_radius, cleave_end_radius, cleave_distance, cleave_effectName)
    end
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
LinkLuaModifier( "modifier_item_mjz_manta", "items/item_mjz_manta", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjz_manta_invulnerable", "items/item_mjz_manta", LUA_MODIFIER_MOTION_NONE )

---------------------------------------------------------------------------------------

function item_mjz_manta_CastTarget( item, target )
    local caster = item:GetCaster()
	if caster and IsValidEntity(caster) and caster:IsRealHero() then
		local pszAbilityName = "mjz_general_mirror_image_hidden"
		local ability = caster:FindAbilityByName(pszAbilityName)
		if ability == nil then
			ability = caster:AddAbility(pszAbilityName)
			ability:SetStealable(false)
		end
		if ability then
			ability:SetLevel(item:GetLevel() - 1)
			ability:EndCooldown()
			ability:CastAbility()
			-- ExecuteOrderFromTable({
			-- 	UnitIndex = caster:entindex(),
			-- 	OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			-- 	AbilityIndex = ability:entindex(),
			-- 	Queue = false,
			-- })
		end
	end
end

function item_mjz_manta_CastTarget_old( item, target )
    local caster = item:GetCaster()
    if caster and IsValidEntity(caster) and caster:IsRealHero() then
        local images_count = item:GetSpecialValueFor("images_count")
        local illusion_duration = item:GetSpecialValueFor("illusion_duration")
        local invulnerability_duration = item:GetSpecialValueFor("invuln_duration")
        local cooldown_melee = item:GetSpecialValueFor("cooldown_melee")
        local images_do_damage_percent_melee = item:GetSpecialValueFor("images_do_damage_percent_melee")
        local images_take_damage_percent_melee = item:GetSpecialValueFor("images_take_damage_percent_melee")
        local images_do_damage_percent_ranged = item:GetSpecialValueFor("images_do_damage_percent_ranged")
        local images_take_damage_percent_ranged = item:GetSpecialValueFor("images_take_damage_percent_ranged")
        
        local outgoingDamage = images_do_damage_percent_ranged
        local incomingDamage = images_take_damage_percent_ranged
         
        if not caster:IsRangedAttacker() then
            outgoingDamage = images_do_damage_percent_melee
            incomingDamage = images_take_damage_percent_melee
            item:EndCooldown()
            item:StartCooldown(cooldown_melee)
        end

        if not caster.item_mjz_manta_list then
            caster.item_mjz_manta_list = {}
        end
        for _,v in pairs(caster.item_mjz_manta_list) do
            if v and IsValidEntity(v) then
                v:ForceKill(false)
            end
        end


        caster:Purge(false, true, false, false, false)
        caster:AddNewModifier(caster, self, "modifier_item_mjz_manta_invulnerable", {duration = invulnerability_duration})
    
        caster:EmitSound("DOTA_Item.Manta.Activate")
        local manta_particle = ParticleManager:CreateParticle("particles/items2_fx/manta_phase.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

        Timers:CreateTimer(invulnerability_duration, function()
            FindClearRandomPositionAroundUnit(caster, caster, 100)

			for i=1,images_count do
				Timers:CreateTimer(0.1, function()
					local illusion = item_mjz_manta_CreateIllusion(caster, item, outgoingDamage, incomingDamage)
					illusion._mjz_manta_illusion = true
					table.insert(caster.item_mjz_manta_list, illusion)
					-- FindClearRandomPositionAroundUnit(illusion, illusion, 100)
				end)
            end

            ParticleManager:DestroyParticle(manta_particle, false)
		    ParticleManager:ReleaseParticleIndex(manta_particle)
        end)

    end
end

function item_mjz_manta_CreateIllusion(caster, ability, outgoingDamage, incomingDamage)
	local unit = caster:GetUnitName()
	local origin = caster:GetAbsOrigin() + RandomVector(100)
	local duration  = ability:GetSpecialValueFor("illusion_duration")
	local outgoingDamage = outgoingDamage or ability:GetSpecialValueFor( "illusion_outgoing_damage" )
	local incomingDamage = incomingDamage or ability:GetSpecialValueFor( "illusion_incoming_damage" )


	local illusion = CreateUnitByName(unit, origin, true, caster, nil, caster:GetTeamNumber())
	illusion:SetPlayerID(caster:GetPlayerID())
	illusion:SetOwner(caster)
	illusion:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)

	-- illusion:SetForwardVector(target:GetAbsOrigin() - illusion:GetAbsOrigin())

	-- Level Up the unit to the casters level
	local casterLevel = caster:GetLevel()
	for i=1,casterLevel-1 do
		illusion:HeroLevelUp(false)
	end

	-- Set the skill points to 0 and learn the skills of the caster
	illusion:SetAbilityPoints(0)
	for abilitySlot=0,15 do
		local ability = caster:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			if IsValidEntity(illusionAbility) then
				illusionAbility:SetLevel(abilityLevel)
			end
		end
	end

	-- Recreate the items of the caster
	for itemSlot=0,5 do
		item_mjz_manta_CopyItem(caster, illusion, itemSlot)
	end

	-- 15, 16 分别为TP槽位和自然物品槽位
	for itemSlot=15,16 do
		item_mjz_manta_CopyItem(caster, illusion, itemSlot)
	end


	-- Set the unit as an illusion
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration + 1, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()
	illusion:SetHealth(caster:GetHealth())
	illusion:SetMana(caster:GetMana())
	
	return illusion
end

function item_mjz_manta_CopyItem(caster, illusion, itemSlot)
	local item = caster:GetItemInSlot(itemSlot)
	local item_illusion = illusion:GetItemInSlot(itemSlot)
	if item_illusion then
		item_illusion:RemoveSelf()
	end
	if item ~= nil then
		local itemName = item:GetName()
		if not IsIllusionExcludeItem(item) then
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end
end

---------------------------------------------------------------------------------------

-- item_mjz_manta_1 = class({})

-- function item_mjz_manta_1:GetIntrinsicModifierName()
-- 	return "modifier_item_mjz_manta"
-- end

-- function item_mjz_manta_1:OnSpellStart()
--     if IsServer() then
--         item_mjz_manta_CastTarget(self, self:GetCursorTarget())
--     end
-- end

---------------------------------------------------------------------------------------

item_mjz_manta_2 = class({})

function item_mjz_manta_2:GetIntrinsicModifierName()
	return "modifier_item_mjz_manta"
end

function item_mjz_manta_2:OnSpellStart()
    if IsServer() then
        item_mjz_manta_CastTarget(self, self:GetCursorTarget())
    end
end

---------------------------------------------------------------------------------------

item_mjz_manta_3 = class({})

function item_mjz_manta_3:GetIntrinsicModifierName()
	return "modifier_item_mjz_manta"
end

function item_mjz_manta_3:OnSpellStart()
    if IsServer() then
        item_mjz_manta_CastTarget(self, self:GetCursorTarget())
    end
end

---------------------------------------------------------------------------------------

item_mjz_manta_4 = class({})

function item_mjz_manta_4:GetIntrinsicModifierName()
	return "modifier_item_mjz_manta"
end

function item_mjz_manta_4:OnSpellStart()
    if IsServer() then
        item_mjz_manta_CastTarget(self, self:GetCursorTarget())
    end
end

---------------------------------------------------------------------------------------

item_mjz_manta_5 = class({})

function item_mjz_manta_5:GetIntrinsicModifierName()
	return "modifier_item_mjz_manta"
end

function item_mjz_manta_5:OnSpellStart()
    if IsServer() then
        item_mjz_manta_CastTarget(self, self:GetCursorTarget())
    end
end

---------------------------------------------------------------------------------------

if modifier_item_mjz_manta == nil then modifier_item_mjz_manta = class({}) end
function modifier_item_mjz_manta:IsPassive() return true end
function modifier_item_mjz_manta:IsHidden() return true end
function modifier_item_mjz_manta:IsPurgable() return false end

function modifier_item_mjz_manta:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return decFuncs
end

function modifier_item_mjz_manta:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end

function modifier_item_mjz_manta:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_item_mjz_manta:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_item_mjz_manta:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_mjz_manta:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

-------------------------------------------------------------------------------

modifier_item_mjz_manta_invulnerable = class({})
function modifier_item_mjz_manta_invulnerable:IsHidden() return true end
function modifier_item_mjz_manta_invulnerable:CheckState()
	local state =
		{
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_OUT_OF_GAME] = true,
		}
	return state
end
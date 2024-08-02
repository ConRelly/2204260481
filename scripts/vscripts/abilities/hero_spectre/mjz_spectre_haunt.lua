
LinkLuaModifier( "modifier_mjz_spectre_haunt_illusion_buff", "abilities/hero_spectre/mjz_spectre_haunt.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------------

mjz_spectre_haunt_single = class({})

function mjz_spectre_haunt_single:OnSpellStart()
	if not IsServer() then return nil end
	local caster = self:GetCaster()
	local ability = self
	local point = self:GetCursorPosition()
	local ability_haunt = caster:FindAbilityByName("mjz_spectre_haunt")

	if not caster:HasScepter() then
		return false
	end
	if ability_haunt and ability_haunt:GetLevel() > 0 then
		EmitSoundOn("Hero_Spectre.HauntCast", caster)
		ability_haunt:CreateIllusion(caster, point)
	end
end

--------------------------------------------------------------------------------------

mjz_spectre_haunt = class({})

function mjz_spectre_haunt:OnItemEquipped(hItem)
	-- print("Equipped!" )
	self:_CheckScepter()
end
function mjz_spectre_haunt:OnInventoryContentsChanged()
	-- print("Equipped!" )
	self:_CheckScepter()
end
function mjz_spectre_haunt:_CheckScepter()
	if IsServer() then
		local caster = self:GetCaster()
		local ability_single = caster:FindAbilityByName("mjz_spectre_haunt_single")
		if ability_single then
			if caster:HasScepter() then
				if ability_single:IsHidden() then
					ability_single:SetLevel(1)
					ability_single:SetHidden(false)
				 end
			else
				 if not ability_single:IsHidden() then
					ability_single:SetLevel(0)
					ability_single:SetHidden(true)
				 end
			end
		end
	end
end

function mjz_spectre_haunt:OnSpellStart()
	if not IsServer() then return nil end

	local caster = self:GetCaster()
	local ability = self
	local illusion_count = ability:GetSpecialValueFor("illusion_count")

	EmitSoundOn("Hero_Spectre.HauntCast", caster)

	for i=1,illusion_count do
		self:CreateIllusion(caster)
	end
end

function mjz_spectre_haunt:CreateIllusion(caster, point)
	if not IsServer() then return nil end
	local spawnPoint = point or caster:GetAbsOrigin()
	local unit = caster:GetUnitName()
	local ability = self
	local duration  = ability:GetSpecialValueFor("illusion_duration")
	local outgoingDamage = GetTalentSpecialValueFor(ability, "illusion_damage_outgoing")
	local incomingDamage = ability:GetSpecialValueFor( "illusion_damage_incoming")
	local pszScriptName = "modifier_mjz_spectre_haunt_illusion_buff"

	local illusion_kv = { duration = duration + 1, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage }

	-- ( hOwner, hHeroToCopy, hModiiferKeys, nNumIllusions, nPadding, bScramblePosition, bFindClearSpace )
	local illusions = CreateIllusions(caster, caster, illusion_kv, 1, 50, true, true )
	local illusion = illusions[1]
	illusion:SetPlayerID(caster:GetPlayerID())
	illusion:SetOwner(caster)
	illusion._mjz_spectre_haunt_illusion = true


	illusion:AddNewModifier(caster, ability, pszScriptName, {duration = duration})

	-- FindClearRandomPositionAroundUnit(illusion, illusion, 25)
	FindClearSpaceForUnit( illusion, spawnPoint + RandomVector(100), false )
	
	return illusion
end

function mjz_spectre_haunt:CreateIllusion_old(caster, point)

	local spawnPoint = point or caster:GetAbsOrigin()
	local unit = caster:GetUnitName()
	local ability = self
	local duration  = ability:GetSpecialValueFor("illusion_duration")
	local outgoingDamage = ability:GetSpecialValueFor( "illusion_outgoing_damage")
	local incomingDamage = ability:GetSpecialValueFor( "illusion_incoming_damage")
	local pszScriptName = "modifier_mjz_spectre_haunt_illusion_buff"


	local illusion = CreateUnitByName(unit, spawnPoint, true, caster, nil, caster:GetTeamNumber())
	illusion:SetPlayerID(caster:GetPlayerID())
	illusion:SetOwner(caster)
	illusion._mjz_spectre_haunt_illusion = true

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
			if illusionAbility then
				illusionAbility:SetLevel(abilityLevel)
			end
		end
	end

	-- Recreate the items of the caster
	for itemSlot=0,5 do
		self:CopyItem(caster, illusion, itemSlot)
	end

	-- 15, 16 分别为TP槽位和自然物品槽位
	for itemSlot=15,16 do
		self:CopyItem(caster, illusion, itemSlot)
	end

	-- Set the unit as an illusion
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration + 1, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()

	illusion:AddNewModifier(caster, ability, pszScriptName, {duration = duration})

	FindClearRandomPositionAroundUnit(illusion, illusion, 25)
	
	return illusion
end


function mjz_spectre_haunt:CopyItem(caster, illusion, itemSlot)
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
			newItem:SetStacksWithOtherOwners(true)
			newItem:SetPurchaser(nil)
			if newItem:RequiresCharges() then
				newItem:SetCurrentCharges(item:GetCurrentCharges())
			end
			if newItem:IsToggle() and item:GetToggleState() then
				newItem:ToggleAbility()
			end
		end
	end
	illusion:SetHasInventory(false)
	illusion:SetCanSellItems(false)
end

function mjz_spectre_haunt:LevelUpReality (keys)
	local caster = keys.caster
	local ability_reality = caster:FindAbilityByName("spectre_reality")
	if ability_reality ~= nil then
		ability_reality:SetLevel(1)
	end

	caster.haunting = false
end


--------------------------------------------------------------------------------------

modifier_mjz_spectre_haunt_illusion_buff = class({})
local modifier_buff = modifier_mjz_spectre_haunt_illusion_buff

function modifier_buff:IsHidden() return true end
function modifier_buff:IsPurgable() return false end


function modifier_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		--MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_buff:GetModifierMoveSpeed_Absolute( params )
    return 650
end

--[[function modifier_buff:OnTakeDamage( params )
	if not IsServer() then return nil end

	local caster = self:GetCaster()
	local parent = self:GetParent()
	local spell = self:GetAbility()
	local Attacker = params.attacker
	local Target = params.unit
	-- local Ability = params.inflictor
	local flDamage = params.damage
	local attacker = params.attacker
	local target = params.attacker
	local damage = params.damage

	if params.unit ~= self:GetParent() or Target == nil then
		-- print("OnTakeDamage: params.unit ~= self:GetParent()")
		return 0
	end
	if params.attacker == params.unit then return end

	local ability = spell
	local unit = parent
	local hero = unit:GetOwnerEntity()
	local attack_damage = damage   --keys.DamageTaken

	local illusion_heal_damage_per  = ability:GetSpecialValueFor("illusion_heal_damage_per")
	local hero_heal_damage_per = ability:GetSpecialValueFor( "hero_heal_damage_per")
	local illusion_heal_damage = attack_damage * illusion_heal_damage_per / 100
	local hero_heal_damage = attack_damage * hero_heal_damage_per / 100

	if hero and unit._mjz_spectre_haunt_illusion then
		unit:Heal(illusion_heal_damage, nil)
		hero:Heal(hero_heal_damage, nil)
	end

end]]

function modifier_buff:OnDestroy()
	if not IsServer() then return nil end
	local unit = self:GetParent()
	if unit and IsValidEntity(unit) then
		unit:RemoveSelf()
	end
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
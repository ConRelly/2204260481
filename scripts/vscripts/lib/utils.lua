require("lib/string")
require("lib/projectiles")
--require("lib/notifications")
function GetAllRealHeroes()
    local rheroes = {}
    local heroes = HeroList:GetAllHeroes()
    
    for i=1,#heroes do
        if heroes[i]:IsRealHero() then
            table.insert(rheroes,heroes[i])
        end
    end
    return rheroes
end

local NotRegister = {
    ["npc_playerhelp"] = true,
    ["npc_dota_target_dummy"] = true,
    ["npc_dummy_unit"] = true,
    ["npc_dota_hero_target_dummy"] = true,
    ["npc_courier_replacement"] = true,
	["npc_dota_totem_item_holder"] = true,
}
function GetAllRealHeroesCon()
	local rheroes = {}
	for i = 0, DOTA_MAX_PLAYERS - 1 do
		if PlayerResource:IsValidPlayer(i) then
			if PlayerResource:GetPlayer(i) then
				local hero = PlayerResource:GetSelectedHeroEntity(i)
				if not NotRegister[hero:GetUnitName()] then
					table.insert(rheroes, hero)
				end
			end   
		end
	end
    return rheroes
end




function RefreshPlayers()
    local heroes = GetAllRealHeroes()
    for i=1, #heroes do
		if not heroes[i]:IsAlive() then
            heroes[i]:SetRespawnPosition(heroes[i]:GetOrigin())
            heroes[i]:RespawnHero( false, false )
		end
		heroes[i]:SetHealth(heroes[i]:GetMaxHealth())
		heroes[i]:SetMana(heroes[i]:GetMaxMana())
        --local heal = ParticleManager:CreateParticle("particles/items_fx/bloodstone_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, heroes[i])  --paricle not clearing
        --ParticleManager:ReleaseParticleIndex(heal)
	end
	RefillBottle()
end


function RefillBottle()
    local heroes = GetAllRealHeroes()
    for i=1, #heroes do
        for y=0, 9, 1 do
            local current_item = heroes[i]:GetItemInSlot(y)
            if current_item ~= nil then
                if current_item:GetName() == "item_bottle" then
                    current_item:SetCurrentCharges(3)
					heroes[i]:EmitSoundParams("Bottle.Cork", 1, 0.5, 0)
					local rf = ParticleManager:CreateParticle("particles/custom/abilities/refresh_players/refill_bottle.vpcf", PATTACH_ABSORIGIN_FOLLOW, heroes[i])
					ParticleManager:ReleaseParticleIndex(rf)
                end
            end
        end
	end
end

function SetCameraToPosForPlayer(playerID,vector)
    -- print(playerID)
	local netTable = {}
	netTable["PosX"] = vector[1]
	netTable["PosY"] = vector[2]
	netTable["PosZ"] = vector[3]

	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "move_camera", netTable )
end

function ChangeWorldBounds(vMin, vMax)
    local oldBounds = Entities:FindByClassname(nil, "world_bounds")
	if oldBounds then 
		oldBounds:RemoveSelf()
	end

    SpawnEntityFromTableSynchronous("world_bounds", {Min = vMin, Max = vMax})
    
    -- FireGameEvent("change_world_bounds", {Min = vMin, Max = vMax})
end

function DisplayError(playerId, message)
	local player = PlayerResource:GetPlayer(playerId)
	if player then
		CustomGameEventManager:Send_ServerToPlayer(player, "display_custom_error", { message = message })
	end
end

function IsFreeSpaceInInventory(hero)
    for i=0,14 do
        if hero:GetItemInSlot(i) == nil then
            return true
        end
    end
    return false
end


----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
function CDOTA_BaseNPC:HasTalent(talentName)
	if self and not self:IsNull() and self:HasAbility(talentName) then
		if self:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end
	return false
end
function CDOTA_BaseNPC:FindTalentValue(talentName)
	if self:HasAbility(talentName) then
		return self:FindAbilityByName(talentName):GetSpecialValueFor("value")
	end
	return 0
end
function CDOTA_BaseNPC:FindTalentCustomValue(talentName, key)
	if self:HasAbility(talentName) then
		local value_name = key or "value"
		return self:FindAbilityByName(talentName):GetSpecialValueFor(value_name)
	end
	return 0
end
function talent_value(caster, talent_name)
	local talent = caster:FindAbilityByName(talent_name)
	if talent and talent:GetLevel() > 0 then
		return talent:GetSpecialValueFor("value")
	end
	return 0
end
function CDOTA_BaseNPC:CustomValue(AbilityName, var_type)
	local Ability = self:FindAbilityByName(AbilityName)
	if Ability and Ability:GetLevel() > 0 then
		return Ability:GetSpecialValueFor(var_type)
	end
	return 0
end

function CDOTABaseAbility:GetTalentSpecialValueFor(value)
	local base = self:GetSpecialValueFor(value)
	local talentName
	local kv = self:GetAbilityKeyValues()
	for k,v in pairs(kv) do 
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
				end
			end
		end
	end
	if talentName then
		local talent = self:GetCaster():FindAbilityByName(talentName)
		if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
	end
	return base
end

function CDOTABaseAbility:GetTalentSpecialValueFor(value)
    local base = self:GetSpecialValueFor(value)
    local talentName
    local bonusOperation
    local kv = self:GetAbilityKeyValues()
    
    if kv.AbilityValues then
        local valueData = kv.AbilityValues[value]
        if type(valueData) == "table" then
            talentName = valueData.LinkedSpecialBonus
            bonusOperation = valueData.LinkedSpecialBonusOperation
        end
    end
    
    if talentName then 
        local talent = self:GetCaster():FindAbilityByName(talentName)
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

function FindWearables(unit, wearable_model_name)
	local model = unit:FirstMoveChild()
	while model ~= nil do
		if model:GetClassname() == "dota_item_wearable" then
			local modelName = model:GetModelName()
			if modelName == wearable_model_name then
				return true
			end
		end
		model = model:NextMovePeer()
	end
	return false
end

function create_popup(data)
    local target = data.target
    local value = math.floor(data.value)
    local type = data.type or "null"
    local color = data.color or Vector(255, 255, 255)
    local duration = data.duration or 1.0
	local offset = data.offset or Vector(0,0,0)
    local size = string.len(value)
    local pre = data.pre or nil
    local pattach = data.pattach or PATTACH_ROOTBONE_FOLLOW
    if pre ~= nil then
        size = size + 1
    end
    local pos = data.pos or nil
    if pos ~= nil then
        size = size + 1
    end
    local particle_path = "particles/msg_fx/msg_" .. type .. ".vpcf"
    local particle = ParticleManager:CreateParticle(particle_path, pattach, target)
	ParticleManager:SetParticleControl(particle, 0, offset)
    ParticleManager:SetParticleControl(particle, 1, Vector(pre, value, pos))
    ParticleManager:SetParticleControl(particle, 2, Vector(duration, size, 0))
    ParticleManager:SetParticleControl(particle, 3, color)
end

function CreateAOE(owner, point, radius, duration, color)
    color = color or Vector(255, 255, 255)
    local particle = ParticleManager:CreateParticle("particles/aoe_marker.vpcf", PATTACH_ABSORIGIN, owner.unit or owner)

    ParticleManager:SetParticleControl(particle, 0, point)
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, duration, 1))
    ParticleManager:SetParticleControl(particle, 2, color)
    ParticleManager:ReleaseParticleIndex(particle)
end

function CreateLine(owner, point, target, duration, start_radius, end_radius)
    local particle = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_ABSORIGIN, owner.unit or owner)

    ParticleManager:SetParticleControl(particle, 1, point)
    ParticleManager:SetParticleControl(particle, 2, target)
    ParticleManager:SetParticleControl(particle, 3, Vector(end_radius, start_radius, 0))
    ParticleManager:SetParticleControl(particle, 4, Vector(duration, 0, 0))
    ParticleManager:ReleaseParticleIndex(particle)
end

function spell_crit(attacker, victim, damageTable)
	if attacker and attacker:IsHero() then
		if bit.band(damageTable.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) == DOTA_DAMAGE_FLAG_HPLOSS or bit.band(damageTable.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then return end
		local mana = attacker:GetMana()
		local health = attacker:GetHealth()
		local damage_mult = 1.8
		local mana_cost = damageTable.damage * 0.8 * (150 / (150 + attacker:GetIntellect(false)))
		if not attacker:HasModifier("immortal_spells_req_hp") then
			if mana >= mana_cost and mana >= 150 then
				if victim and victim ~= attacker and victim:GetTeamNumber() ~= attacker:GetTeamNumber() then
					damageTable.damage = damageTable.damage * damage_mult
					create_popup({
						target = victim,
						value = damageTable.damage,
						color = Vector(100, 149, 237),
						type = "crit",
						pos = 4
					})
					local firstAbility = attacker:GetAbilityByIndex(0)
					-- Ensure the ability exists (it should for a hero)
					if firstAbility then
						-- Spend the specified amount of mana using the first ability
						attacker:SpendMana(mana_cost, firstAbility)
					else
						-- Handle the case where the hero has no abilities (very unlikely)
						print("Error: The hero has no abilities to reference for SpendMana.")
					end						
					--attacker:SpendMana(mana_cost, nil)
				end
			end
		else
			if health >= mana_cost and health >= 150 then
				if victim and victim ~= attacker and victim:GetTeamNumber() ~= attacker:GetTeamNumber() then
					damageTable.damage = damageTable.damage * damage_mult
					create_popup({
						target = victim,
						value = damageTable.damage,
						color = Vector(100, 149, 18),
						type = "crit",
						pos = 4
					})
					attacker:SetHealth(attacker:GetHealth() - mana_cost)
				end
			end
		end
	end
    return damageTable.damage
end





function HasSuperScepter(npc)
	if npc:HasModifier("modifier_super_scepter") then
		return true
	end
    return false
end

function CDOTA_BaseNPC:HasSuperScepter()
	if self:HasModifier("modifier_super_scepter") then
		return true
	end
    return false
end

function CDOTA_BaseNPC:HasShard()
	if self:HasModifier("modifier_item_aghanims_shard") then
		return true
	end
	return false
end

function CDOTA_BaseNPC:FindAbilityWithHighestCooldown()
	local highest_cd_ability = nil

	for i = 0, 24 do
		local ability = self:GetAbilityByIndex(i)

		if ability then
			if highest_cd_ability == nil then
				highest_cd_ability = ability
			elseif ability:IsTrained() then
				if ability:GetCooldownTimeRemaining() > highest_cd_ability:GetCooldownTimeRemaining() then
					highest_cd_ability = ability
				end
			end
		end
	end

	return highest_cd_ability
end

function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
end

function increase_modifier(caster, target, ability, modifier)
	if target:HasModifier(modifier) then
		local newCount = target:GetModifierStackCount(modifier, caster) + 1
        target:SetModifierStackCount(modifier, caster, newCount)
	else
		ability:ApplyDataDrivenModifier(caster, target, modifier, nil)
		target:SetModifierStackCount(modifier, caster, 1)
    end
end
function decrease_modifier(caster, target, modifier)
	if target:HasModifier(modifier) then
		local count = target:GetModifierStackCount(modifier, caster)

		if count > 1 then
			target:SetModifierStackCount(modifier, caster, count - 1)
		else 
			target:RemoveModifierByName(modifier)
		end
	end
end

function IsValid(h)
	return h ~= nil and not h:IsNull()
end

function DFX(index, force)
    ParticleManager:DestroyParticle(index, force)
	if force then
		ParticleManager:ReleaseParticleIndex(index)
	end
end
function GiveItem( ... )
	local caster,itemName,itemOwner = ...
	if itemOwner == nil then
		itemOwner = caster
	end
	if IsFullSolt(caster, 12) == false then
		local newItem = CreateItem(itemName, itemOwner, itemOwner)
		caster:AddItem(newItem)
		return newItem
	else
		return false
	end
end
function IsFullSolt( ... )
	local caster,bagType = ...
	if bagType == nil then
		bagType = 6
	end
	local itemCount = 0
	for i=1,bagType do
        local itemSolt = caster:GetItemInSlot(i-1)
        if itemSolt then
        	itemCount = itemCount + 1
        end
    end
    if itemCount == bagType then
    	return true
    else
    	return false
    end
end

function CDOTA_BaseNPC:DropItem(hItem, sNewItemName, bLaunchLoot, owner, purchaser)
	local vLocation = GetGroundPosition(self:GetAbsOrigin(), self)
	local sName
	local vRandomVector = RandomVector(100)

	if hItem then
		sName = hItem:GetName()
		self:DropItemAtPositionImmediate(hItem, vLocation)
	else
		sName = sNewItemName
		hItem = CreateItem(sNewItemName, owner, purchaser)
		CreateItemOnPositionSync(vLocation, hItem)
	end

	if sName == "item_rapier_cus" then
		hItem:GetContainer():SetRenderColor(230,240,35)
	elseif sName == "item_arcane_rapier_cus" then
		hItem:GetContainer():SetRenderColor(35,35,240)
	elseif sName == "item_wraith_rapier" then
		hItem:GetContainer():SetRenderColor(95,172,119)
	end

	if bLaunchLoot then
		hItem:LaunchLoot(false, 250, 0.5, vLocation + vRandomVector, nil)
	end
end

-- Checks if the attacker's damage is classified as "hero damage".	 More `or`s may need to be added.
function CDOTA_BaseNPC:IsHeroDamage(damage)
	if damage > 0 then
		if self:GetName() == "npc_dota_roshan" or self:IsControllableByAnyPlayer() or self:GetName() == "npc_dota_shadowshaman_serpentward" then
			return true
		end
	end

	return false
end

-- Rolls a Psuedo Random chance. If failed, chances increases, otherwise chances are reset
-- Numbers taken from https://gaming.stackexchange.com/a/290788
function RollPseudoRandom(base_chance, entity)
	local chances_table = {
		{1, 0.015604},
		{2, 0.062009},
		{3, 0.138618},
		{4, 0.244856},
		{5, 0.380166},
		{6, 0.544011},
		{7, 0.735871},
		{8, 0.955242},
		{9, 1.201637},
		{10, 1.474584},
		{11, 1.773627},
		{12, 2.098323},
		{13, 2.448241},
		{14, 2.822965},
		{15, 3.222091},
		{16, 3.645227},
		{17, 4.091991},
		{18, 4.562014},
		{19, 5.054934},
		{20, 5.570404},
		{21, 6.108083},
		{22, 6.667640},
		{23, 7.248754},
		{24, 7.851112},
		{25, 8.474409},
		{26, 9.118346},
		{27, 9.782638},
		{28, 10.467023},
		{29, 11.171176},
		{30, 11.894919},
		{31, 12.637932},
		{32, 13.400086},
		{33, 14.180520},
		{34, 14.981009},
		{35, 15.798310},
		{36, 16.632878},
		{37, 17.490924},
		{38, 18.362465},
		{39, 19.248596},
		{40, 20.154741},
		{41, 21.092003},
		{42, 22.036458},
		{43, 22.989868},
		{44, 23.954015},
		{45, 24.930700},
		{46, 25.987235},
		{47, 27.045294},
		{48, 28.100764},
		{49, 29.155227},
		{50, 30.210303},
		{51, 31.267664},
		{52, 32.329055},
		{53, 33.411996},
		{54, 34.736999},
		{55, 36.039785},
		{56, 37.321683},
		{57, 38.583961},
		{58, 39.827833},
		{59, 41.054464},
		{60, 42.264973},
		{61, 43.460445},
		{62, 44.641928},
		{63, 45.810444},
		{64, 46.966991},
		{65, 48.112548},
		{66, 49.248078},
		{67, 50.746269},
		{68, 52.941176},
		{69, 55.072464},
		{70, 57.142857},
		{71, 59.154930},
		{72, 61.111111},
		{73, 63.013699},
		{74, 64.864865},
		{75, 66.666667},
		{76, 68.421053},
		{77, 70.129870},
		{78, 71.794872},
		{79, 73.417722},
		{80, 75.000000},
		{81, 76.543210},
		{82, 78.048780},
		{83, 79.518072},
		{84, 80.952381},
		{85, 82.352941},
		{86, 83.720930},
		{87, 85.057471},
		{88, 86.363636},
		{89, 87.640449},
		{90, 88.888889},
		{91, 90.109890},
		{92, 91.304348},
		{93, 92.473118},
		{94, 93.617021},
		{95, 94.736842},
		{96, 95.833333},
		{97, 96.907216},
		{98, 97.959184},
		{99, 98.989899},	
		{100, 100}
	}
	entity.pseudoRandomModifier = entity.pseudoRandomModifier or 0
	local prngBase
	for i = 1, #chances_table do
		if base_chance == chances_table[i][1] then		  
			prngBase = chances_table[i][2]
		end	 
	end
	if not prngBase then
		return false
	end
	if RollPercentage( prngBase + entity.pseudoRandomModifier ) then
		entity.pseudoRandomModifier = 0
		return true
	else
		entity.pseudoRandomModifier = entity.pseudoRandomModifier + prngBase		
		return false
	end
end

for _, listenerId in ipairs(registeredCustomEventListeners or {}) do
	CustomGameEventManager:UnregisterListener(listenerId)
end
registeredCustomEventListeners = {}
function RegisterCustomEventListener(eventName, callback)
	local listenerId = CustomGameEventManager:RegisterListener(eventName, function(_, args)
		callback(args)
	end)

	table.insert(registeredCustomEventListeners, listenerId)
end

for _, listenerId in ipairs(registeredGameEventListeners or {}) do
	StopListeningToGameEvent(listenerId)
end
registeredGameEventListeners = {}
function RegisterGameEventListener(eventName, callback)
	local listenerId = ListenToGameEvent(eventName, callback, nil)
	table.insert(registeredGameEventListeners, listenerId)
end


----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
---AI SEGMENT---------------------------------------------------------------------------------------------------
--From: 2224000967

function ai_random_alive_hero() return random_from_table(ai_alive_heroes()) end
function ai_weakest_alive_hero_current()
	local function get_weakest(hero1, hero2)
		if hero1:GetHealth() > hero2:GetHealth() then
			return hero2
		end
		return hero1
	end
	local heroes = ai_alive_heroes()
	if #heroes < 1 then
		return nil
	end
	local weakest = nil
	for i, hero in ipairs(heroes) do
		if weakest == nil then
			weakest = hero
		else
			weakest = get_weakest(weakest, hero)
		end
	end
	return weakest
end

function ai_weakest_alive_hero()
	local function get_weakest(hero1, hero2)
		if hero1:GetMaxHealth() > hero2:GetMaxHealth() then
			return hero2
		end
		return hero1
	end
	local heroes = ai_alive_heroes()
	if #heroes < 1 then
		return nil
	end
	local weakest = nil
	for i, hero in ipairs(heroes) do
		if weakest == nil then
			weakest = hero
		else
			weakest = get_weakest(weakest, hero)
		end
	end
	return weakest
end
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
-- Autoattack lifesteal
function CDOTA_BaseNPC:GetLifesteal()
	local lifesteal = 0
	local multiplier = 0
	for _, parent_modifier in pairs(self:FindAllModifiers()) do
		if parent_modifier.GetModifierLifesteal and parent_modifier:GetModifierLifesteal() then
			lifesteal = lifesteal + parent_modifier:GetModifierLifesteal()
		end
	end
	for _, parent_modifier in pairs(self:FindAllModifiers()) do
		if parent_modifier.GetModifierLifestealAmplify and parent_modifier:GetModifierLifestealAmplify() then
			multiplier = multiplier + parent_modifier:GetModifierLifestealAmplify()
		end
	end
	if lifesteal ~= 0 and multiplier ~= 0 then
		lifesteal = lifesteal * (multiplier / 100)
	end
	return lifesteal
end
-- Pure attack lifesteal
function CDOTA_BaseNPC:GetPureLifesteal()
	local lifesteal = 0
	local multiplier = 0
	for _, parent_modifier in pairs(self:FindAllModifiers()) do
		if parent_modifier.GetModifierPureLifesteal and parent_modifier:GetModifierPureLifesteal() then
			lifesteal = lifesteal + parent_modifier:GetModifierPureLifesteal()
		end
	end
	for _, parent_modifier in pairs(self:FindAllModifiers()) do
		if parent_modifier.GetModifierLifestealAmplify and parent_modifier:GetModifierLifestealAmplify() then
			multiplier = multiplier + parent_modifier:GetModifierLifestealAmplify()
		end
	end
	if lifesteal ~= 0 and multiplier ~= 0 then
		lifesteal = lifesteal * (multiplier / 100)
	end
	return lifesteal
end

-- Crit Damage
function CDOTA_BaseNPC:GetCritDMG()
	local CritDMG = 0
	for _, parent_modifier in pairs(self:FindAllModifiers()) do
		if parent_modifier.GetModifierCritDMG and parent_modifier:GetModifierCritDMG() then
			CritDMG = CritDMG + parent_modifier:GetModifierCritDMG()
		end
	end
	return CritDMG
end

-- Cooldown Manipulation
function CDOTA_BaseNPC:GetCustomStackingCooldownReduction()
	local Reduction = 1
	local talent12 = talent_value(self, "special_bonus_cdr_12") or 1
	local talent15 = talent_value(self, "special_bonus_cdr_15") or 1
	local talent20 = talent_value(self, "special_bonus_cdr_20") or 1
	local talent25 = talent_value(self, "special_bonus_cdr_25") or 1
	local talent30 = talent_value(self, "special_bonus_cdr_30") or 1
	local talent40 = talent_value(self, "special_bonus_cdr_40") or 1
	for _, parent_modifier in pairs(self:FindAllModifiers()) do
		if parent_modifier.GetCustomStackingCDR and parent_modifier:GetCustomStackingCDR() then
			Reduction = Reduction * (1 - (parent_modifier:GetCustomStackingCDR() / 100))
		end
	end
	Reduction = Reduction * (1 - (talent12 / 100)) * (1 - (talent15 / 100)) * (1 - (talent20 / 100)) * (1 - (talent25 / 100)) * (1 - (talent30 / 100)) * (1 - (talent40 / 100))
	return 1 - Reduction
end

-- Spell lifesteal
function CDOTA_BaseNPC:GetSpellLifesteal()
	local lifesteal = 0
	local multiplier = 0
	for _, parent_modifier in pairs(self:FindAllModifiers()) do
		if parent_modifier.GetModifierSpellLifesteal and parent_modifier:GetModifierSpellLifesteal() then
			lifesteal = lifesteal + parent_modifier:GetModifierSpellLifesteal()
		end
	end
	for _, parent_modifier in pairs(self:FindAllModifiers()) do
		if parent_modifier.GetModifierSpellLifestealAmplify and parent_modifier:GetModifierSpellLifestealAmplify() then
			multiplier = multiplier + parent_modifier:GetModifierSpellLifestealAmplify()
		end
	end
	if lifesteal ~= 0 and multiplier ~= 0 then
		lifesteal = lifesteal * (multiplier / 100)
	end
	return lifesteal
end

-- Pure spell lifesteal
function CDOTA_BaseNPC:GetPureSpellLifesteal()
	local lifesteal = 0
	local multiplier = 0
	for _, parent_modifier in pairs(self:FindAllModifiers()) do
		if parent_modifier.GetModifierPureSpellLifesteal and parent_modifier:GetModifierPureSpellLifesteal() then
			lifesteal = lifesteal + parent_modifier:GetModifierPureSpellLifesteal()
		end
	end
	for _, parent_modifier in pairs(self:FindAllModifiers()) do
		if parent_modifier.GetModifierSpellLifestealAmplify and parent_modifier:GetModifierSpellLifestealAmplify() then
			multiplier = multiplier + parent_modifier:GetModifierSpellLifestealAmplify()
		end
	end
	if lifesteal ~= 0 and multiplier ~= 0 then
		lifesteal = lifesteal * (multiplier / 100)
	end
	return lifesteal
end

-- Universal damage amplification
function CDOTA_BaseNPC:GetIncomingDamagePct()
	-- Fetch damage amp from modifiers
	local damage_amp = 1
	local vanguard_damage_reduction = 1
	for _, parent_modifier in pairs(self:FindAllModifiers()) do
		-- Vanguard-based damage reduction does not stack
		if parent_modifier.GetCustomIncomingDamageReductionUnique then
			vanguard_damage_reduction = math.min(vanguard_damage_reduction, (100 - parent_modifier:GetCustomIncomingDamageReductionUnique()) * 0.01)
		end
		-- Stack all other custom sources of damage amp
		if parent_modifier.GetCustomIncomingDamagePct then
			damage_amp = damage_amp * (100 + parent_modifier:GetCustomIncomingDamagePct()) * 0.01
		end
	end
	-- Calculate total damage amp
	damage_amp = damage_amp * vanguard_damage_reduction
	return (damage_amp - 1) * 100
end

-- Physical damage block
function CDOTA_BaseNPC:GetDamageBlock()
	-- Fetch damage block from custom modifiers
	local damage_block = 0
	local unique_damage_block = 0
	for _, parent_modifier in pairs(self:FindAllModifiers()) do
		-- Vanguard-based damage block does not stack
		if parent_modifier.GetCustomDamageBlockUnique then
			unique_damage_block = math.max(unique_damage_block, parent_modifier:GetCustomDamageBlockUnique())
		end
		-- Stack all other sources of damage block
		if parent_modifier.GetCustomDamageBlock then
			damage_block = damage_block + parent_modifier:GetCustomDamageBlock()
		end
	end
	-- Calculate total damage block
	damage_block = damage_block + unique_damage_block
	-- Ranged attackers only benefit from part of the damage block
	if self:IsRangedAttacker() then
		return 0.6 * damage_block
	else
		return damage_block
	end
end

function CDOTA_Modifier_Lua:CheckMotionControllers()
	local parent = self:GetParent()
	local modifier_priority = self:GetMotionControllerPriority()
	local is_motion_controller = false
	local motion_controller_priority
	local found_modifier_handler

	local non_motion_controllers =
	{"modifier_brewmaster_storm_cyclone",
	 "modifier_dark_seer_vacuum",
	 "modifier_eul_cyclone",
	 "modifier_earth_spirit_rolling_boulder_caster",
	 "modifier_huskar_life_break_charge",
	 "modifier_invoker_tornado",
	 "modifier_item_forcestaff_active",
	 "modifier_rattletrap_hookshot",
	 "modifier_phoenix_icarus_dive",
	 "modifier_shredder_timber_chain",
	 "modifier_slark_pounce",
	 "modifier_spirit_breaker_charge_of_darkness",
	 "modifier_tusk_walrus_punch_air_time",
	 "modifier_earthshaker_enchant_totem_leap"}
	

	-- Fetch all modifiers
	local modifiers = parent:FindAllModifiers()	

	for _,modifier in pairs(modifiers) do		
		-- Ignore the modifier that is using this function
		if self ~= modifier then			

			-- Check if this modifier is assigned as a motion controller
			if modifier.IsMotionController then
				if modifier:IsMotionController() then
					-- Get its handle
					found_modifier_handler = modifier

					is_motion_controller = true

					-- Get the motion controller priority
					motion_controller_priority = modifier:GetMotionControllerPriority()

					-- Stop iteration					
					break
				end
			end

			-- If not, check on the list
			for _,non_motion_controller in pairs(non_motion_controllers) do				
				if modifier:GetName() == non_motion_controller then
					-- Get its handle
					found_modifier_handler = modifier

					is_motion_controller = true

					-- We assume that vanilla controllers are the highest priority
					motion_controller_priority = DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST

					-- Stop iteration					
					break
				end
			end
		end
	end

	-- If this is a motion controller, check its priority level
	if is_motion_controller and motion_controller_priority then

		-- If the priority of the modifier that was found is higher, override
		if motion_controller_priority > modifier_priority then			
			return false

		-- If they have the same priority levels, check which of them is older and remove it
		elseif motion_controller_priority == modifier_priority then			
			if found_modifier_handler:GetCreationTime() >= self:GetCreationTime() then				
				return false
			else				
				found_modifier_handler:Destroy()
				return true
			end

		-- If the modifier that was found is a lower priority, destroy it instead
		else			
			parent:InterruptMotionControllers(true)
			found_modifier_handler:Destroy()
			return true
		end
	else
		-- If no motion controllers were found, apply
		return true
	end
end

-- Dota IMBA utils -------------------------------

-- Separate Tables
function TableToStringCommaEnt(table)
	local string = ""
	local first_value = true

	for _,handle in pairs(table) do
		if first_value then
			string = string..tostring(handle:entindex())
			first_value = false
		else
			string = string..","
			string = string..tostring(handle:entindex())
		end
	end
	return string
end
function StringToTableEnt(string, separator)
	local gmatch_sign

	if separator == " " then
		gmatch_sign = "%S+"
	elseif separator == "," then
		gmatch_sign = "([^,]+)"
	end

	local return_table = {}
	for str in string.gmatch(string, gmatch_sign) do
		local handle = EntIndexToHScript(tonumber(str))
		table.insert(return_table, handle)
	end
	return return_table
end
--------------------------------------------------

----------BossHpBar-----
function UpdateBossBar(boss, team)
	CustomNetTables:SetTableValue("game_options", "boss", {
		level = boss:GetLevel(),
		HP = boss:GetHealth(),
		HP_alt = boss:GetHealthPercent(),
		maxHP = boss:GetMaxHealth(),
		label = boss:GetUnitName(),
		short_label = string.gsub(boss:GetUnitName(), "npc_", ""),
		team_contest = team
	})
end

----------Drops item near player if inventory is full -----

function DropItemOrInventory(playerID, itemName)
	if IsServer() then
		if PlayerResource:IsValidPlayer(playerID) then
			if PlayerResource:GetPlayer(playerID) then
				Timers:CreateTimer((0.01 + playerID) / 10, function()		
					local player = PlayerResource:GetPlayer(playerID)
					local hero = player:GetAssignedHero()
					local item = CreateItem(itemName, nil, nil)
					local success = hero:AddItem(item)
					if not success then
						local origin = hero:GetAbsOrigin()
						local newItem = CreateItem(itemName, nil, nil)
						newItem:SetPurchaseTime(0)
						local drop = CreateItemOnPositionSync(origin, newItem )
						local pos_launch = origin+RandomVector(RandomFloat(150,200))
						newItem:LaunchLoot(false, 200, 0.75, pos_launch, nil)
						Notifications:Top(playerID,{text="Your inventory is full, item has been dropped near you", style={color="red"}, duration=5})
					end
				end)
			end	
		end		
	end	
end
----------Drops item near player if inventory is full Owner -----

function DropItemOrInventory2(playerID, itemName)
	if IsServer() then
		if PlayerResource:IsValidPlayer(playerID) then
			if PlayerResource:GetPlayer(playerID) then
				Timers:CreateTimer((0.01 + playerID) / 10, function()		
					local player = PlayerResource:GetPlayer(playerID)
					local hero = player:GetAssignedHero()
					local item = CreateItem(itemName, hero, hero)
					local success = hero:AddItem(item)
					if not success then
						local origin = hero:GetAbsOrigin()
						local newItem = CreateItem(itemName, hero, hero)
						newItem:SetPurchaseTime(0)
						local drop = CreateItemOnPositionSync(origin, newItem )
						local pos_launch = origin+RandomVector(RandomFloat(150,200))
						newItem:LaunchLoot(false, 200, 0.75, pos_launch, nil)
						Notifications:Top(playerID,{text="Your inventory is full, item has been dropped near you(owner)", style={color="red"}, duration=5})
					end
				end)
			end	
		end		
	end	
end

-------Lot Drops-----
--local received_item = {}
local NotRegister = {
    ["npc_playerhelp"] = true,
    ["npc_dota_target_dummy"] = true,
    ["npc_dummy_unit"] = true,
    ["npc_dota_hero_target_dummy"] = true,
    ["npc_courier_replacement"] = true,
	["npc_dota_totem_item_holder"] = true,
}
local max_item_count = 1
local item_count = {

}

function OnLootDropItem(itemName)
      -- Get a list of all players in the game
	local players = {}
	for i = 0, DOTA_MAX_PLAYERS - 1 do
		if PlayerResource:IsValidPlayer(i) then
			if PlayerResource:GetPlayer(i) then
				local hero = PlayerResource:GetSelectedHeroEntity(i)
				if not NotRegister[hero:GetUnitName()] then
					table.insert(players, i)
				end
			end
		end
	end

	-- Check if all players have received the maximum allowed number of the item
	local all_received = true
	for _, playerID in pairs(players) do
		if item_count[playerID .. "_" .. itemName] then
			if item_count[playerID .. "_" .. itemName] < max_item_count then
				all_received = false
				break	
			end
		else
			all_received = false
			break	
		end	
	end

	-- Reset the count for the item if all players have received the maximum allowed number
	if all_received then
		for _, playerID in pairs(players) do
			item_count[playerID .. "_" .. itemName] = 0
		end
		print("all players received the maximum number of " .. itemName)
	end


	-- Shuffle the list of players
	players = shuffle(players)
	-- Give the item to the first player in the list who hasn't received the maximum allowed number of that item
	for _, playerID in pairs(players) do
		if PlayerResource:GetPlayer(playerID) then
			if not item_count[playerID .. "_" .. itemName] or item_count[playerID .. "_" .. itemName] < max_item_count then
				-- Give the item to the player
				DropLootOrInventory(playerID, itemName)
				item_count[playerID .. "_" .. itemName] = (item_count[playerID .. "_" .. itemName] or 0) + 1
				break
			end
		end
	end
end
function shuffle(t)
    local n = #t
    while n > 1 do
        local k = math.random(n)
        t[n], t[k] = t[k], t[n]
        n = n - 1
    end
    return t
end


----drops for loot items --
function DropLootOrInventory(playerID, itemName)
	if IsServer() then
		if PlayerResource:IsValidPlayer(playerID) then
			if PlayerResource:GetPlayer(playerID) then
				Timers:CreateTimer((0.01 + playerID) / 10, function()
					local player = PlayerResource:GetPlayer(playerID)
					local hero = player:GetAssignedHero()
					local item = CreateItem(itemName, nil, nil)
					local success = hero:AddItem(item)
					if not success then
						local origin = hero:GetAbsOrigin()
						local newItem = CreateItem(itemName, nil, nil)
						newItem:SetPurchaseTime(0)
						local drop = CreateItemOnPositionSync(origin, newItem )
						local pos_launch = origin+RandomVector(RandomFloat(150,200))
						newItem:LaunchLoot(false, 200, 0.75, pos_launch, nil)
					end
				end)
			end	
		end	
	end	
end


---sunday check including holliday
function IsSunday_2()
    if _G.IsSunday_1 and _G.IsSunday_1_messagge then
        return true
    end   

    local date = StrSplit(GetSystemDate(), '/')
    local y = tonumber(date[3])
    local m = tonumber(date[1])
    local d = tonumber(date[2])

    -- Check if the date is between December 10 and January 2
    if (m == 12 and d >= 10) or (m == 1 and d <= 2) then
        _G.IsSunday_1 = true
        return true
    end
    if (m == 2 and d >= 14) then
        _G.IsSunday_1 = true
        return true
    end

    -- Adjust for leap year
    if m == 1 or m == 2 then
        m = m + 12
        y = y - 1
    end

    local c = math.floor(y / 100)
    y = y % 100

    local w = y + math.floor(y / 4) + math.floor(c / 4) - 2 * c + math.floor(26 * (m + 1) / 10) + d - 1
    local wday = w % 7
    if wday == 0 then
        wday = 7
        _G.IsSunday_1 = true
    end
    return wday == 7
end

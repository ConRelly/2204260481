LinkLuaModifier("modifier_infinite_health", "modifiers/modifier_infinite_health.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_absolute_no_cc", "modifiers/modifier_absolute_no_cc", LUA_MODIFIER_MOTION_NONE )

modifier_infinite_health = modifier_infinite_health or class({})

function modifier_infinite_health:IsPermanent() return true end
function modifier_infinite_health:RemoveOnDeath() return true end
function modifier_infinite_health:IsHidden() return true end 	
function modifier_infinite_health:IsDebuff() return false end 	
function modifier_infinite_health:IsPurgable() return false end
function modifier_infinite_health:GetPriority()
	return MODIFIER_PRIORITY_HIGH + 500000
end

function modifier_infinite_health:OnCreated()
    self.teleport_chance = 100
    local parentt = self:GetParent()
    parentt.mjz_retain = true
    self.last_announced_tier = 0 -- Initialize the last announced tier
    
    self:StartIntervalThink(1)
end


function modifier_infinite_health:OnDestroy()
    if IsServer() then
        if self:GetParent() then
            local parent = self:GetParent()
            local lvl = parent:GetLevel()
            local hp = parent:GetHealthPercent()
            local vcenter = Vector(0,0,0)
            Drop_gold_bag(parent, 35000)
            create_item_drop("item_adamantium_ingot", vcenter + RandomVector(RandomFloat(50, 250)))
            local reward = "Tier I: 1 ingot, 1 gold bag, Dropped in center of the map"
            _G._challenge_bosss = 1
            if _G._endlessMode_started then
                if lvl > 50 then
                    create_item_drop("item_adamantium_ingot", vcenter + RandomVector(RandomFloat(50, 250)))
                    reward = "Tier II: 2 ingots, 2 gold bags, Dropped in center of the map(100 was next tier)"
                    Drop_gold_bag(parent, 35000)
                    _G._challenge_bosss = 2
                end 
                if lvl > 100 then
                    create_item_drop("item_adamantium_ingot", vcenter + RandomVector(RandomFloat(50, 250)))
                    reward = "Tier III: 3 ingots, 3 gold bags, Dropped in center of the map(200 was next tier)"
                    Drop_gold_bag(parent, 35000)
                    _G._challenge_bosss = 3
                end
                if lvl > 200 then
                    create_item_drop("item_adamantium_ingot", vcenter + RandomVector(RandomFloat(50, 250)))
                    create_item_drop("item_edible_fragment", vcenter + RandomVector(RandomFloat(50, 250)))
                    reward = "Tier IV: 4 ingots, 4 gold bags, Edible Fragment, Dropped in center of the map(400 was next tier)"
                    Drop_gold_bag(parent, 35000)
                    _G._challenge_bosss = 4
                end 
                if lvl > 400 then
                    create_item_drop("item_adamantium_ingot", vcenter + RandomVector(RandomFloat(50, 250)))
                    create_item_drop("item_edible_complete", vcenter + RandomVector(RandomFloat(50, 250)))
                    reward = "Tier V: 5 ingots, 5 gold bags, Edible fragment + Edible Complete"
                    Drop_gold_bag(parent, 35000)
                    _G._challenge_bosss = 5

                    -- New logic for levels > 400
                    local bonus_lvl = lvl - 400
                    local guaranteed_drops = math.floor(bonus_lvl / 100)
                    local extra_chance = bonus_lvl % 100

                    -- Drop guaranteed items
                    for i = 1, guaranteed_drops do
                        create_item_drop("item_random_get_ability", vcenter + RandomVector(RandomFloat(50, 250)))
                    end

                    -- Roll for extra item
                    if RollPercentage(extra_chance) then
                        create_item_drop("item_random_get_ability", vcenter + RandomVector(RandomFloat(50, 250)))
                    end

                    -- Update reward string
                    reward = reward .. ", Extra: " .. bonus_lvl .. "% chance for item Random Ability (Rare)"
                end
            else
                if lvl > 150 then
                    create_item_drop("item_adamantium_ingot", vcenter + RandomVector(RandomFloat(50, 250)))
                    reward = "Tier II: 2 ingots, 2 gold bags, Dropped in center of the map"
                    Drop_gold_bag(parent, 45000)
                    _G._challenge_bosss = 2

                    -- Extra reward logic for else branch (max 3 guaranteed drops)
                    local bonus_lvl = lvl - 150
                    local guaranteed_drops = math.min(3, math.floor(bonus_lvl / 100))
                    local extra_chance = bonus_lvl % 100

                    -- Drop guaranteed items (max 3)
                    for i = 1, guaranteed_drops do
                        create_item_drop("item_random_get_ability", vcenter + RandomVector(RandomFloat(50, 250)))
                    end

                    -- Roll for extra item
                    if guaranteed_drops < 3 and RollPercentage(extra_chance) then
                        create_item_drop("item_random_get_ability", vcenter + RandomVector(RandomFloat(50, 250)))
                    end

                    -- Update reward string
                    reward = reward .. ", Extra: " .. bonus_lvl .. "% chance for item Random Ability (Rare, max 3)"
                end                      
            end 
            if _G._endlessMode_started then               
                if _G._hardMode then
                    if _G._extra_mode then
                        Notifications:TopToAll({text="Hard Mode + Extra: You Have Reached Level "..lvl.." and "..hp.."% Heath, Reward "..reward , style={color="red"}, duration=15})
                    else                                         
                        Notifications:TopToAll({text="Hard Mode: You Have Reached Level "..lvl.." and "..hp.."% Heath, Reward "..reward , style={color="red"}, duration=15})
                    end    
                else
                    if _G._extra_mode then
                        Notifications:TopToAll({text="Normal Mode + Extra: You Have Reached Level "..lvl.." and "..hp.."% Heath, Reward "..reward , style={color="red"}, duration=15})   
                    else
                        Notifications:TopToAll({text="Normal Mode: You Have Reached Level "..lvl.." and "..hp.."% Heath, Reward "..reward , style={color="red"}, duration=15})
                    end    
                end
            else
                if _G._hardMode then
                    if _G._extra_mode then
                        Notifications:TopToAll({text="Part 1 Hard Mode + Extra: You Have Reached Level "..lvl.." and "..hp.."% Heath, Reward "..reward , style={color="red"}, duration=15})
                    else                                         
                        Notifications:TopToAll({text="Part 1 Hard Mode: You Have Reached Level "..lvl.." and "..hp.."% Heath, Reward "..reward , style={color="red"}, duration=15})
                    end    
                else
                    if _G._extra_mode then
                        Notifications:TopToAll({text="Part 1 Normal Mode + Extra: You Have Reached Level "..lvl.." and "..hp.."% Heath, Reward "..reward , style={color="red"}, duration=15})   
                    else
                        Notifications:TopToAll({text="Part 1 Normal Mode: You Have Reached Level "..lvl.." and "..hp.."% Heath, Reward "..reward , style={color="red"}, duration=15})
                    end    
                end                
            end 
            if self:GetParent():IsAlive() then
                self:GetParent():SetHealth(1000)
            end 
        end   
    end    
end
function Drop_gold_bag(unit, nGold)
    if IsServer() then
        local newItem = CreateItem("item_bag_of_gold", nil, nil)
        newItem:SetPurchaseTime(0)
        newItem:SetCurrentCharges(nGold)
        local vcenter = Vector(0,0,0)
        local drop = CreateItemOnPositionSync(vcenter, newItem)
        local dropTarget = vcenter + RandomVector(RandomFloat(50, 550))
        newItem:LaunchLoot(false, 300, 0.75, dropTarget, nil)
    end   
end    

function create_item_drop(item_name, pos)
	local item = CreateItem(item_name, nil, nil)
	item:SetPurchaseTime(0)
	item:SetStacksWithOtherOwners(true)

	local drop = CreateItemOnPositionSync(pos, item)
	item:LaunchLoot(false, 300, 0.75, pos, nil)
	drop.Holdout_IsLootDrop = true
end



function modifier_infinite_health:DeclareFunctions()
	return {
    MODIFIER_PROPERTY_MIN_HEALTH,
    MODIFIER_EVENT_ON_DEATH_PREVENTED, 
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,        
    MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
	MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_infinite_health:OnDeathPrevented(params)
	if IsServer() then
		local parent = self:GetParent()
		if parent == params.unit and parent:IsAlive() then
            parent:CreatureLevelUp(1)
            parent:SetHealth(parent:GetMaxHealth())

            local lvl = parent:GetLevel()
            local current_tier = 0
            local reward = ""

            if _G._endlessMode_started then
                if lvl > 400 then
                    current_tier = 5
                    reward = "Tier V: 5 ingots, 5 gold bags, Edible fragment + Edible Complete"
                    reward = reward .. ", Extra: Chance for item Random Ability (Rare) based on bonus level."
                elseif lvl > 200 then
                    current_tier = 4
                    reward = "Tier IV: 4 ingots, 4 gold bags, Edible Fragment, Dropped in center of the map(400 was next tier)"
                elseif lvl > 100 then
                    current_tier = 3
                    reward = "Tier III: 3 ingots, 3 gold bags, Dropped in center of the map(200 was next tier)"
                elseif lvl > 50 then
                    current_tier = 2
                    reward = "Tier II: 2 ingots, 2 gold bags, Dropped in center of the map(100 was next tier)"
                else
                    current_tier = 1
                    reward = "Tier I: 1 ingot, 1 gold bag, Dropped in center of the map"
                end
            else
                if lvl > 150 then
                    current_tier = 2
                    reward = "Tier II: 2 ingots, 2 gold bags, Dropped in center of the map"
                    reward = reward .. ", Extra: Chance for item Random Ability (Rare, max 3) based on bonus level."
                else
                    current_tier = 1
                    reward = "Tier I: 1 ingot, 1 gold bag, Dropped in center of the map"
                end
            end

            if current_tier > self.last_announced_tier then
                local mode_text = "Normal Mode First Part"
                if _G._endlessMode_started then mode_text = "Second Part" end
                if _G._hardMode then mode_text = mode_text .. " Hard Mode" end
                if _G._extra_mode then mode_text = mode_text .. " + Extra" end

                Notifications:TopToAll({text=mode_text..": You Have Reached Level "..lvl..", Reward "..reward , style={color="red"}, duration=10})
                self.last_announced_tier = current_tier
            end
        end
    end
end
function modifier_infinite_health:GetMinHealth()
	return 1
end


function modifier_infinite_health:OnIntervalThink()
    if IsServer() then
        local parent = self:GetParent()
        if parent and IsValidEntity(parent) and parent:IsAlive() then  
            for _, player in pairs(FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
                if not player:IsNull() and IsValidEntity(player) and player:IsAlive() then
                    if RollPercentage(self.teleport_chance) then -- 100% at first then 7% for every tick(1s)
                        local original_loc = player:GetAbsOrigin()
                        FindClearRandomPositionAroundUnit(player, parent, math.random(1900))  
                        local nFXIndex = ParticleManager:CreateParticle ("particles/custom/deadpool_multislash_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, player);
                        ParticleManager:SetParticleControlEnt (nFXIndex, 0, player, PATTACH_POINT_FOLLOW, "attach_hitloc", player:GetOrigin () + Vector (0, 0, 96), true);
                        ParticleManager:SetParticleControl (nFXIndex, 2, Vector (0, 0, 0));
                        ParticleManager:SetParticleControl (nFXIndex, 3, Vector (0, 0, 0));
                        ParticleManager:ReleaseParticleIndex (nFXIndex);
                        local nFXIndexy = ParticleManager:CreateParticle ("particles/deadpool_multislash_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, player);
                        ParticleManager:SetParticleControl (nFXIndexy, 0, player:GetAbsOrigin ());
                        ParticleManager:SetParticleControl (nFXIndexy, 1, original_loc);
                        ParticleManager:ReleaseParticleIndex (nFXIndexy);                             
                    end                          
                end
            end
            self.teleport_chance = 7 
            if RollPercentage(4) then
                if not parent:PassivesDisabled() then
                    parent:AddNewModifier(parent, nil, "modifier_invulnerable", {duration = 3})
                end    
                parent:AddNewModifier(parent, nil, "modifier_absolute_no_cc", {duration = 5})
            end    
        end
    end 
end


function modifier_infinite_health:GetModifierIncomingDamage_Percentage()
    if self:GetParent() then
        local lvl = self:GetParent():GetLevel()
        if lvl < 40 then
            return 40 - lvl
        end    
        return 0 
    end    
end
function modifier_infinite_health:GetModifierExtraHealthBonus()
    if self:GetParent() then
        local lvl = self:GetParent():GetLevel()
        local bonus_hp = math.floor( lvl * 60000 )
        return bonus_hp
    end
end
function modifier_infinite_health:GetModifierMoveSpeed_Absolute()
    if self:GetParent() then
        local lvl = self:GetParent():GetLevel()
        local speed = 100 + math.floor(lvl * 20 )
        return speed
    end
end
function modifier_infinite_health:GetModifierAttackSpeedBonus_Constant()
    if self:GetParent() then
        local lvl = self:GetParent():GetLevel()
        local attack_speed = math.floor(lvl * 20 )
        return attack_speed
    end
end
function modifier_infinite_health:GetModifierTotalDamageOutgoing_Percentage()
    if self:GetParent() then
        local lvl = self:GetParent():GetLevel()
        local damage = math.floor(lvl * 4 ) - 70
        return damage
    end
end
function modifier_infinite_health:GetModifierSpellAmplify_Percentage() 
    if self:GetParent() then
        local lvl = self:GetParent():GetLevel()
        local spell_amp = lvl - 30
        if lvl > 50 then
            spell_amp = spell_amp + lvl 
        end    
        return spell_amp
    end
end
function modifier_infinite_health:GetModifierPreAttack_BonusDamage()
    if self:GetParent() then
        local lvl = self:GetParent():GetLevel()
        local damage_bonus = math.floor(lvl * 100 ) - 500
        return damage_bonus
    end
end
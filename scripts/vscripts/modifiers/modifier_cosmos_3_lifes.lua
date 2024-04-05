
LinkLuaModifier("modifier_cosmos_3_lifes", "modifiers/modifier_cosmos_3_lifes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cosmos_resist_physical", "modifiers/modifier_cosmos_3_lifes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cosmos_resist_magical", "modifiers/modifier_cosmos_3_lifes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cosmos_resist_pure", "modifiers/modifier_cosmos_3_lifes", LUA_MODIFIER_MOTION_NONE)


modifier_cosmos_3_lifes = modifier_cosmos_3_lifes or class({})

function modifier_cosmos_3_lifes:IsPermanent() return true end
function modifier_cosmos_3_lifes:RemoveOnDeath() return false end
function modifier_cosmos_3_lifes:IsHidden() return true end 	
function modifier_cosmos_3_lifes:IsDebuff() return false end 	
function modifier_cosmos_3_lifes:IsPurgable() return false end
function modifier_cosmos_3_lifes:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA + 500000
end




---new
function modifier_cosmos_3_lifes:OnCreated()
    if IsServer() then
        local parent = self:GetParent()
        -- create a table to store the resist modifiers
        if parent then
            self.resist_modifiers = {}
            -- create a table to store the damage types
            self.damage_types = {DAMAGE_TYPE_PHYSICAL, DAMAGE_TYPE_MAGICAL, DAMAGE_TYPE_PURE}        
            -- shuffle the damage types randomly
            self:ShuffleDamageTypes()
            --print the damage type table
            --print(self.damage_types[1])
            --print(self.damage_types[2])
            --print(self.damage_types[3])        
            -- add two resist modifiers to the parent based on the first two damage types
            self:AddResistModifier(self.damage_types[1])
            self:AddResistModifier(self.damage_types[2])
            -- set the current damage type to the third one
            self.current_damage_type = self.damage_types[3]
            --i need text for damage type
            self.stage = 3
            local damage_type = ""
            if self.current_damage_type == DAMAGE_TYPE_PHYSICAL then
                damage_type = "Physical"
            elseif self.current_damage_type == DAMAGE_TYPE_MAGICAL then
                damage_type = "Magical"
            elseif self.current_damage_type == DAMAGE_TYPE_PURE then
                damage_type = "Pure"
            end
            Notifications:TopToAll({text="Stage-- "..self.stage.." Vulnerable to:  "..damage_type.. " ,check his shield buffs for confirmation" , style={color="red"}, duration=15})
            if not Cheats:IsEnabled() then
                if _G.cosmos_defeat_notification then
                    _G.cosmos_defeat_notification = false
                    Notifications:TopToAll({text="Qualified for Old(v3)Vitory role on Discord(Print this)" , style={color="green"}, duration=10})
                    Timers:CreateTimer(10, function()
                        Notifications:TopToAll({text="You Have 20 min to stop Cosmos from wining" , style={color="red"}, duration=10})
                    end)
                    --create a timer for 20 min 
                    Timers:CreateTimer(1200, function()
                        Notifications:TopToAll({text="20 min Have Passed, Cosmos is Destorying your game world" , style={color="red"}, duration=10})
                        Timers:CreateTimer(6, function()
                            _G.cosmos_defeat = false
                        end)
                    end)
                    --create a 10 min timer to announce 10 mil left
                    Timers:CreateTimer(600, function()
                        Notifications:TopToAll({text="10 min left to defeat Cosmos" , style={color="red"}, duration=10})
                    end)
                end
            end
            -- set the current life count to 1
            self.current_life = 1
        end
    end
end

function modifier_cosmos_3_lifes:OnDeathPrevented(params)
    if IsServer() then
        local parent = self:GetParent()
        if parent == params.unit and parent:IsAlive() then
            -- check if the current life count is less than 3
            if self.current_life < 3 then
                self.current_damage_type = self.damage_types[self.current_life]
                self:RemoveResistModifier(self.current_damage_type)
                self.stage = self.stage - 1
                _G.cosmos_stage = self.stage
                local l_stage = "Stage--"
                if self.stage == 1 then
                    l_stage = "Last Stage--"
                end
                local damage_type = ""
                if self.current_damage_type == DAMAGE_TYPE_PHYSICAL then
                    damage_type = "Physical"
                elseif self.current_damage_type == DAMAGE_TYPE_MAGICAL then
                    damage_type = "Magical"
                elseif self.current_damage_type == DAMAGE_TYPE_PURE then
                    damage_type = "Pure"
                end
                Notifications:TopToAll({text= l_stage.." "..self.stage..": Vulnerable to:  "..damage_type , style={color="red"}, duration=15})                
                -- increment the current life count
                self.current_life = self.current_life + 1
                local ad_modif = self.current_life + 1
                if ad_modif > 3 then
                    ad_modif = 1
                end
                self:AddResistModifier(self.damage_types[ad_modif])
                --print("death prevented: "..parent:GetUnitName().." current life: "..self.current_life)
                -- level up the parent
                parent:CreatureLevelUp(1)
                -- restore the parent's health
                parent:SetHealth(parent:GetMaxHealth())
            else
                if self then
                    self:Destroy()
                end               
            end
        end
    end
end


--
--[[ function modifier_cosmos_3_lifes:OnCreated()
    if IsServer() then
        local parent = self:GetParent()
        -- create a table to store the resist modifiers
        if parent then
            self.resist_modifiers = {}
            -- create a table to store the damage types
            self.damage_types = {DAMAGE_TYPE_PHYSICAL, DAMAGE_TYPE_MAGICAL, DAMAGE_TYPE_PURE}
            -- shuffle the damage types randomly
            self:ShuffleDamageTypes()
            -- add two resist modifiers to the parent based on the first two damage types
            self:AddResistModifier(self.damage_types[1])
            self:AddResistModifier(self.damage_types[2])
            -- set the current damage type to the third one
            self.current_damage_type = self.damage_types[3]
            --i need text for damage type
            self.stage = 3
            local damage_type = ""
            if self.current_damage_type == DAMAGE_TYPE_PHYSICAL then
                damage_type = "Physical"
            elseif self.current_damage_type == DAMAGE_TYPE_MAGICAL then
                damage_type = "Magical"
            elseif self.current_damage_type == DAMAGE_TYPE_PURE then
                damage_type = "Pure"
            end
            print("dmg_type: " .. damage_type)
            -- set the current life count to 1
            self.current_life = 1
        end
    end
end ]]
-- helper function to shuffle the damage types table
function modifier_cosmos_3_lifes:ShuffleDamageTypes()
    local n = #self.damage_types
    for i = 1, n do
        local j = math.random(i, n)
        self.damage_types[i], self.damage_types[j] = self.damage_types[j], self.damage_types[i]
    end
end

-- helper function to add a resist modifier to the parent
function modifier_cosmos_3_lifes:AddResistModifier(damage_type)
    local parent = self:GetParent()
    local modifier_name = ""
    if damage_type == DAMAGE_TYPE_PHYSICAL then
        modifier_name = "modifier_cosmos_resist_physical"
    elseif damage_type == DAMAGE_TYPE_MAGICAL then
        modifier_name = "modifier_cosmos_resist_magical"
    elseif damage_type == DAMAGE_TYPE_PURE then
        modifier_name = "modifier_cosmos_resist_pure"
    end
    -- add the modifier and store it in the table
    local modifier = parent:AddNewModifier(parent, nil, modifier_name, {})
    print("modifier_cosmos_3_lifes:AddResistModifier: "..modifier_name)
    self.resist_modifiers[damage_type] = modifier
end

-- helper function to remove a resist modifier from the parent
function modifier_cosmos_3_lifes:RemoveResistModifier(damage_type)
    local parent = self:GetParent()
    local modifier = self.resist_modifiers[damage_type]
    if modifier then
        -- remove the modifier and delete it from the table
        modifier:Destroy()
        self.resist_modifiers[damage_type] = nil
    end
end


---

function modifier_cosmos_3_lifes:DeclareFunctions()
	return {
    MODIFIER_PROPERTY_MIN_HEALTH,
    MODIFIER_EVENT_ON_DEATH_PREVENTED, 
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,        
 
	}
end
function modifier_cosmos_3_lifes:GetMinHealth()
	return 1
end

function modifier_cosmos_3_lifes:GetModifierIncomingDamage_Percentage()
    local parent = self:GetParent()
    if parent then
        local ptc_healt_left = parent:GetHealthPercent() / 100
        if parent:GetLevel() > 100 then
            local ptc_hp_reduction = (-10.0 + ptc_healt_left) + 0.001
            return ptc_hp_reduction
        end
        if ptc_healt_left < 0.25 then
            return -9.5  
        elseif ptc_healt_left < 0.50 then
            return -7    
        end
        return -6
    end    
end


---rezist modifiers
--modifier for physical resistance
modifier_cosmos_resist_physical = class({})
function modifier_cosmos_resist_physical:IsHidden() return false end
function modifier_cosmos_resist_physical:IsPurgable() return false end
function modifier_cosmos_resist_physical:RemoveOnDeath() return false end   
function modifier_cosmos_resist_physical:GetTexture() return "custom/cosmos_physical" end

function modifier_cosmos_resist_physical:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
	}
end

function modifier_cosmos_resist_physical:GetAbsoluteNoDamagePhysical()
    return 1
end

--modifier for magical resistance
modifier_cosmos_resist_magical = class({})
function modifier_cosmos_resist_magical:IsHidden() return false end
function modifier_cosmos_resist_magical:IsPurgable() return false end
function modifier_cosmos_resist_magical:RemoveOnDeath() return false end   
function modifier_cosmos_resist_magical:GetTexture() return "custom/cosmos_magic" end

function modifier_cosmos_resist_magical:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
	}
end


function modifier_cosmos_resist_magical:GetAbsoluteNoDamageMagical()
    return 1
end

--modifier for pure resistance
modifier_cosmos_resist_pure = class({})
function modifier_cosmos_resist_pure:IsHidden() return false end
function modifier_cosmos_resist_pure:IsPurgable() return false end
function modifier_cosmos_resist_pure:RemoveOnDeath() return false end   
function modifier_cosmos_resist_pure:GetTexture() return "custom/cosmos_pure" end


function modifier_cosmos_resist_pure:DeclareFunctions()
	return {
    MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
	}
end

function modifier_cosmos_resist_pure:GetAbsoluteNoDamagePure()
    return 1
end


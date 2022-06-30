
LinkLuaModifier("modifier_double_trouble", "modifiers/modifier_double_trouble.lua", LUA_MODIFIER_MOTION_NONE)

modifier_double_trouble = modifier_double_trouble or class({})

function modifier_double_trouble:IsPermanent() return true end
function modifier_double_trouble:RemoveOnDeath() return true end
function modifier_double_trouble:IsHidden() return true end 	
function modifier_double_trouble:IsDebuff() return false end 	
function modifier_double_trouble:IsPurgable() return false end

-- thinking maybe to make no effect until self.solo boss is true and then have some effect(maybe wings) end/or get bigger size. for now No effect
--function modifier_double_trouble:GetEffectName() return self.effect end  
--function modifier_double_trouble:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

function modifier_double_trouble:OnCreated()
    self.solo_boss = false
    self.teleport_chance = 100
    self:StartIntervalThink(1)
end

function modifier_double_trouble:OnIntervalThink()
    if IsServer() then
        local parent = self:GetParent()
        if parent and IsValidEntity(parent) and parent:IsAlive() then
            if self.troble_active then
                self.solo_boss = true
                for _, unit in pairs(FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
                    if not unit:IsNull() and IsValidEntity(unit) and unit:IsAlive() then
                        if unit ~= parent then -- don't use :GetName()  or it will enable the solo_boss effects on 2 bosses with same name
                            if unit:GetUnitName() == "npc_boss_guesstuff_Moran" or unit:GetUnitName() == "npc_boss_randomstuff_aiolos" then
                                self.solo_boss = false
                            end
                        end    
                    end
                end
            else
                for _, unit in pairs(FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
                    if not unit:IsNull() and IsValidEntity(unit) and unit:IsAlive() then
                        if unit:GetUnitName() ~= parent:GetUnitName() then -- makes sure it does not activate on -double by removing self and copy of self
                            if unit:GetUnitName() == "npc_boss_guesstuff_Moran" or unit:GetUnitName() == "npc_boss_randomstuff_aiolos" then
                                self.troble_active = true
                            end
                        end    
                    end
                end                
            end   
            if self.solo_boss then -- teleport players around the solo boss(random distance)
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
            end 
            if self.solo_boss and not self.announce_msg then
                self.announce_msg = true
                Notifications:TopToAll({text="Double Trouble Enrage", style={color="red"}, duration=7})
            end    
        end
    end 
end

function modifier_double_trouble:DeclareFunctions()
	return {
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,        
    MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
	MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

-- a little anoying that because the self.solo_boss variable is on Only on server side and it will not update the UI with correct numbers like the Speed. (visual only)
function modifier_double_trouble:GetModifierIncomingDamage_Percentage()
    if not self.solo_boss then return end    
	return -5  --95 total 
end
function modifier_double_trouble:GetModifierHealAmplify_PercentageTarget()
    if not self.solo_boss then return end
	return 50
end
function modifier_double_trouble:GetModifierMoveSpeed_Absolute()
    if not self.solo_boss then return end
	return 1500
end
function modifier_double_trouble:GetModifierAttackSpeedBonus_Constant()
    if not self.solo_boss then return end
	return 500
end
function modifier_double_trouble:GetModifierTotalDamageOutgoing_Percentage()
    if not self.solo_boss then return end
	return 120
end
function modifier_double_trouble:GetModifierSpellAmplify_Percentage()
    if not self.solo_boss then return end    
	return 100
end
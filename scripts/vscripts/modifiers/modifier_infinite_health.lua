LinkLuaModifier("modifier_infinite_health", "modifiers/modifier_infinite_health.lua", LUA_MODIFIER_MOTION_NONE)

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
    self:StartIntervalThink(1)
end
function modifier_infinite_health:OnDestroy()
    if IsServer() then
        if self:GetParent() then
            local parent = self:GetParent()
            local lvl = parent:GetLevel()
            local hp = parent:GetHealthPercent()
            create_item_drop("item_adamantium_ingot", self:GetParent():GetAbsOrigin())
            if lvl > 50 then
                create_item_drop("item_adamantium_ingot", self:GetParent():GetAbsOrigin())
            end 
            if lvl > 80 then
                create_item_drop("item_adamantium_ingot", self:GetParent():GetAbsOrigin())
            end
            if lvl > 120 then
                create_item_drop("item_adamantium_ingot", self:GetParent():GetAbsOrigin())
            end 
            if lvl > 160 then
                create_item_drop("item_adamantium_ingot", self:GetParent():GetAbsOrigin())
            end                                       
            Notifications:TopToAll({text="You Have Reached Level "..lvl.." and "..hp.."% Heath" , style={color="red"}, duration=15})
        end   
    end    
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
        end
    end 
end




function modifier_infinite_health:GetModifierIncomingDamage_Percentage()
    if self:GetParent() then
        local lvl = self:GetParent():GetLevel()
        if lvl < 40 then
            return 40 - lvl
        end    
        return 0  --99 max
    end    
end
function modifier_infinite_health:GetModifierExtraHealthBonus()
    if self:GetParent() then
        local lvl = self:GetParent():GetLevel()
        local bonus_hp = math.floor( lvl * 50000 )
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
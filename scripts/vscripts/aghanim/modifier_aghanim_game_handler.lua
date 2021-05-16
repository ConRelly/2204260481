modifier_aghanim_game_handler = class({})
LinkLuaModifier("modifier_aghanim_game_handler_animation", "aghanim/modifier_aghanim_game_handler.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_aghanim_game_handler:IsHidden() return true end
function modifier_aghanim_game_handler:IsPermanent() return true end

function modifier_aghanim_game_handler:OnCreated()
    self.orderEnums = {}
    self.orderEnums[1] = "Move"
    self.orderEnums[2] = "Move"
    self.orderEnums[3] = "Attack"
    self.orderEnums[4] = "Attack"
    self.orderEnums[5] = "Cast"
    self.orderEnums[6] = "Cast"
    self.orderEnums[8] = "Cast"
    self.orderEnums[16] = "Buy"
    self.orderEnums[28] = "Move"
    self.orderEnums[29] = "Move"
    self.orderEnums[33] = "Move"

    if IsServer() then self:EmitVO("Spawn") end


end

function modifier_aghanim_game_handler:OnIntervalThink()
    self.OnCooldown = false

    self:StartIntervalThink(-1)
end

function modifier_aghanim_game_handler:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_RESPAWN,
        MODIFIER_EVENT_ON_ORDER
    }
end

function modifier_aghanim_game_handler:GetAttackSound() return "Hero_Invoker.Attack" end

function modifier_aghanim_game_handler:OnAttackStart(keys)
    if keys.attacker == self:GetParent() then
        EmitSoundOn("Hero_Invoker.PreAttack", self:GetParent())

        local rate = 1 / self:GetParent():GetSecondsPerAttack()
        --print(rate, self:GetParent():GetSecondsPerAttack())
        self:UpdateAnimation( ACT_DOTA_CAST_ABILITY_1, rate )
    end
end

function modifier_aghanim_game_handler:OnAttackLanded(keys)
    if keys.attacker == self:GetParent() then
        EmitSoundOn("Hero_Invoker.ProjectileImpact", self:GetParent() )
    end
end

function modifier_aghanim_game_handler:OnDeath(keys)

    if keys.unit == self:GetParent() then
        if keys.unit:IsOwnedByAnyPlayer() then 
            local enemy_player = keys.attacker:GetPlayerOwnerID()
            EmitAnnouncerSoundForPlayer("Death", enemy_player)
        end
        self:EmitVO( "Death" )
        self:UpdateAnimation( ACT_DOTA_DIE )

    elseif keys.unit:IsRealHero() and keys.attacker:IsOwnedByAnyPlayer() then
        if keys.attacker:GetPlayerOwnerID() == self:GetParent():GetPlayerOwnerID() then
            local enemy_player = keys.unit:GetPlayerOwnerID()
            EmitAnnouncerSoundForPlayer("Kill", enemy_player)
            self:EmitVO( "Kill" )
        end

    elseif keys.unit:GetTeamNumber() == self:GetParent():GetTeamNumber() and keys.attacker == self:GetParent() then
        self:EmitVO( "Deny" )
    end

end

function modifier_aghanim_game_handler:OnRespawn(keys)
    if IsServer() and keys.unit == self:GetParent() then
        self:EmitVO( "Spawn" )
    end
end

function modifier_aghanim_game_handler:OnOrder(keys)
    if not IsServer() then return end
    if keys.unit ~= self:GetParent() then return end

    self:EmitVO( self.orderEnums[ keys.order_type ] )
end

function modifier_aghanim_game_handler:EmitVO( sound )
    if sound == nil then return end

    local chance = self:GetChance( sound )

    if not self.OnCooldown or chance == 100 then 
        if RollPercentage( chance ) then 
            print("Emitting Voice Line: Aghanim."..sound)

            if sound ~= "Deny" then 
                EmitAnnouncerSoundForPlayer( "Aghanim."..sound, self:GetParent():GetPlayerOwnerID() )
            else
                EmitSoundOnLocationWithCaster( self:GetParent():GetAbsOrigin(), "Aghanim."..sound, self:GetParent() )
            end

            self.OnCooldown = true
            self:StartIntervalThink( RandomFloat(8.0, 12.0) )
        end
    end
end

function modifier_aghanim_game_handler:GetChance( sound )
    local chances = {
        Spawn = 100,
        Move = 15,
        Attack = 30,
        Cast = 90,
        Buy = 80,
        Deny = 70,
        Kill = 100,
        Death = 100
    }
    return chances[ sound ]
end


function modifier_aghanim_game_handler:UpdateAnimation( enum, rate )
    self:GetParent():AddNewModifier(
        self:GetParent(), 
        nil, 
        "modifier_aghanim_game_handler_animation", 
        { animation = enum, rate = rate, duration = self:GetParent():GetSecondsPerAttack() }
    )
end

--===============================================================================================

modifier_aghanim_game_handler_animation = class({})
function modifier_aghanim_game_handler_animation:IsHidden() return false end
function modifier_aghanim_game_handler_animation:IsPurgable() return false end

function modifier_aghanim_game_handler_animation:OnCreated(kv)
    if not IsServer() then return end

    self.animation = kv.animation
    self.rate = kv.rate
    if not self.rate then self.rate = 1 end

    self:SetHasCustomTransmitterData(true)
end

function modifier_aghanim_game_handler_animation:AddCustomTransmitterData( )
	return {
        enum = self.animation,
        rate = self.rate
	}
end

function modifier_aghanim_game_handler_animation:HandleCustomTransmitterData( data ) 
	if data.enum ~= nil and self.animation ~= data.enum then self.animation = data.enum end
	if data.rate ~= nil and self.rate ~= data.rate then self.rate = data.rate end
end

function modifier_aghanim_game_handler_animation:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
    }
end

function modifier_aghanim_game_handler_animation:GetOverrideAnimation() return self.animation end
function modifier_aghanim_game_handler_animation:GetOverrideAnimationRate() return self.rate end
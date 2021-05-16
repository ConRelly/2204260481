

function FrostmourneRuin(event)
	if IsServer() then
        -- body
    end
end

-- TODO: 有BUG，死亡时不一定掉落
function DropFrostmourne(event)
    if IsServer() then
        local killedUnit = EntIndexToHScript( event.caster_entindex )

        if not killedUnit:IsAlive() then 
            --DropItemOnDeath(event)
        end
    end
end

function FrostmourneAttack(event)
    if IsServer() then
        local ability = event.ability
        local caster = event.caster
        if not caster:IsIllusion() and ability:IsCooldownReady() then
            HealthAttack(event)
        end    
        -- body
    end
end

function HealthAttack(event)
    --Deal 5% of the target's current health in physical damage
    --造成目标当前生命值5%的物理伤害
    local ability = event.ability
    local caster = event.caster
    if caster:IsRealHero() and ability:IsCooldownReady() then
        local health_damage_pct = event.health_damage_pct
        ApplyDamage({
            ability = ability,
            victim = event.target,
            attacker = event.caster,
            damage = event.target:GetHealth() * health_damage_pct,
            damage_type = DAMAGE_TYPE_PHYSICAL
        })
        ability:StartCooldown(4)
        local coil = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, event.target)
        ParticleManager:SetParticleControl(coil, 0, event.target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(coil)                      
    end                   
end

function HealAndDamageByTargetHP( event )   --FrostmourneRuin
    --take 15% of targets max HP
    local targetHP = event.target:GetMaxHealth() * 0.15
    ApplyDamage({
        victim = event.target,
        attacker = event.caster,
        damage = event.target:GetMaxHealth() * 0.15,
        damage_type = DAMAGE_TYPE_PHYSICAL
    })
    event.caster:Heal(targetHP, event.caster)
    local coil = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, event.target)
    ParticleManager:SetParticleControl(coil, 0, event.target:GetAbsOrigin())

end


function DropItemOnDeath(keys)
    local killedUnit = EntIndexToHScript( keys.caster_entindex )
    local itemName = tostring(keys.ability:GetAbilityName()) 
    if killedUnit:HasInventory() then 
        for itemSlot = 0, 5, 1 do
            if killedUnit ~= nil then
                local Item = killedUnit:GetItemInSlot( itemSlot )
                if Item ~= nil and Item:GetName() == itemName then
                    local newItem = CreateItem(itemName, nil, nil)
                    CreateItemOnPositionSync(killedUnit:GetOrigin(), newItem)
                    killedUnit:RemoveItem(Item)
                end
            end
        end
    end
end
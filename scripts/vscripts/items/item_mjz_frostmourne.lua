

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

local function monkey_in_inventory(unit)
    if IsServer() then
        for i = 0, 5 do
            local Item = unit:GetItemInSlot(i)        
            if Item ~= nil and IsValidEntity(Item) then
                if Item:GetName() == "item_mjz_monkey_king_bar_5" then
                    return true	
                end	
            end
        end   
        return false
    end    		
end

function HealthAttack(event)
    --Deal 5% of the target's current health in physical damage
    --造成目标当前生命值5%的物理伤害
    if not IsServer() then return end
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
        if caster:HasModifier("modifier_super_scepter") then
            local caster_attack = caster:GetAverageTrueAttackDamage(caster)
            local speed = math.floor(caster:GetIdealSpeed()) * event.speed_mult_dmg
            local hp_regen = math.floor(caster:GetHealthRegen()) * event.healt_reg_mult_dmg
            local bonus_agi = event.bonus_base_agi
            local ss_damage = caster_attack + speed + hp_regen
            if speed > 50000 then
                bonus_agi = 1 + bonus_agi + math.floor(speed / 100000)   -- gain 1 extra base agi at 5k speed and for every 10k speed (takes in account the 10x speed mult)
                if bonus_agi > 13 then
                    bonus_agi = 13
                end    
            end    
            caster:ModifyAgility(bonus_agi)   
            ApplyDamage({
                ability = ability,
                victim = event.target,
                attacker = event.caster,
                damage = ss_damage,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                damage_flags = DOTA_DAMAGE_FLAG_IGNORES_BASE_PHYSICAL_ARMOR
            })
        end
        local lvl = caster:GetLevel()
        if lvl > 69 and monkey_in_inventory(caster) then
            local cdr = 4 * caster:GetCooldownReduction()
            ability:StartCooldown(cdr)
        else   
            ability:StartCooldown(4)
        end   
        local coil = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, event.target)
        ParticleManager:SetParticleControl(coil, 0, event.target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(coil)                      
    end                   
end
--not used, heal effects tend to lag if is trigger many times/s
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
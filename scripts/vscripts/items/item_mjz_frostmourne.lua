LinkLuaModifier("modifier_frostmore_stack_agi",  "items/item_mjz_frostmourne.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_frostmore_mkb_up",  "items/item_mjz_frostmourne.lua",LUA_MODIFIER_MOTION_NONE )
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
        for i = 0, 7 do
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
    local dmg_flag = DOTA_DAMAGE_FLAG_NONE
    if caster:HasModifier("modifier_super_scepter") then
        dmg_flag = DOTA_DAMAGE_FLAG_IGNORES_BASE_PHYSICAL_ARMOR
    end
    local cd_rdy =  ability:IsCooldownReady()
    if caster:IsRealHero() and cd_rdy then
        if event.target then
            local health_damage_pct = event.health_damage_pct
            local hp_damage = event.target:GetHealth() * health_damage_pct
            ApplyDamage({
                ability = ability,
                victim = event.target,
                attacker = event.caster,
                damage = hp_damage,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                damage_flags = dmg_flag
            })
            if caster:HasModifier("modifier_super_scepter") then
                local caster_attack = caster:GetAverageTrueAttackDamage(caster)
                local speed = math.floor(caster:GetIdealSpeed()) * event.speed_mult_dmg
                local hp_regen = math.floor(caster:GetHealthRegen()) * event.healt_reg_mult_dmg
                local bonus_agi = event.bonus_base_agi
                local ss_damage = caster_attack + speed + hp_regen
                if speed > 50000 then
                    bonus_agi = 1 + bonus_agi + math.floor(speed / 100000)   -- gain 1 extra base agi at 5k speed and for every 10k speed (takes in account the 10x speed mult)
                    if bonus_agi > 15 then
                        bonus_agi = 15
                    end    
                end    
                caster:ModifyAgility(bonus_agi) 
                if not caster:HasModifier("modifier_frostmore_stack_agi") then 
                    caster:AddNewModifier(caster, ability, "modifier_frostmore_stack_agi", {})
                    _Updatestack_count(bonus_agi, caster)
                else   
                    _Updatestack_count(bonus_agi, caster) 
                end  
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
            local has_mkb_up = caster:HasModifier("modifier_frostmore_mkb_up")
            if lvl > 35 and monkey_in_inventory(caster) then
                local cdr = 3 * caster:GetCooldownReduction()
                ability:StartCooldown(cdr)
                if not has_mkb_up then
                    caster:AddNewModifier(caster, ability, "modifier_frostmore_mkb_up", {})
                end    
            else 
                ability:StartCooldown(3)
                if has_mkb_up then
                    caster:RemoveModifierByName("modifier_frostmore_mkb_up")
                end    
            end   
            local coil = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, event.target)
            ParticleManager:SetParticleControl(coil, 0, event.target:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(coil)  
        end                    
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
                    --killedUnit:RemoveItem(Item)
                    killedUnit:TakeItem(Item)
                end
            end
        end
    end
end

function check_mkb_up(keys)
    if IsServer() then
        local caster = keys.caster
        local has_mkb_up = caster:HasModifier("modifier_frostmore_mkb_up") 
        if has_mkb_up then
            caster:RemoveModifierByName("modifier_frostmore_mkb_up") 
        end
    end    
end    

----stack tooltip
if modifier_frostmore_stack_agi == nil then modifier_frostmore_stack_agi = class({}) end


function modifier_frostmore_stack_agi:IsHidden() return false end
function modifier_frostmore_stack_agi:IsPurgable() return false end
function modifier_frostmore_stack_agi:IsDebuff() return false end
function modifier_frostmore_stack_agi:RemoveOnDeath() return false end
function modifier_frostmore_stack_agi:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_frostmore_stack_agi:OnTooltip()
	return self:GetStackCount()
end

function _Updatestack_count( count, owner )
    local modifier = "modifier_frostmore_stack_agi"

    if owner:HasModifier(modifier) then
        local newCount = owner:GetModifierStackCount(modifier, owner) + count
        owner:SetModifierStackCount(modifier, owner, newCount) 
    end 
end
--- MKB UP true strike
if modifier_frostmore_mkb_up == nil then modifier_frostmore_mkb_up = class({}) end


function modifier_frostmore_mkb_up:IsHidden() return false end
function modifier_frostmore_mkb_up:IsPurgable() return false end
function modifier_frostmore_mkb_up:IsDebuff() return false end
function modifier_frostmore_mkb_up:RemoveOnDeath() return false end
function modifier_frostmore_mkb_up:DeclareFunctions()
	return {MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT}
end
function modifier_frostmore_mkb_up:CheckState()
	return {[MODIFIER_STATE_CANNOT_MISS] = true}
end
function modifier_frostmore_mkb_up:GetModifierIgnoreMovespeedLimit() return 1 end
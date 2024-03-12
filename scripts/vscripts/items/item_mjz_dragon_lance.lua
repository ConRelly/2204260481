LinkLuaModifier("modifier_item_mjz_dragon_lance",  "items/item_mjz_dragon_lance.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_item_mjz_dragon_lance_stats",  "items/item_mjz_dragon_lance.lua",LUA_MODIFIER_MOTION_NONE )

function OnEquip(keys)
    if not IsServer() then return nil end
    local caster = keys.caster
	local ability = keys.ability
    local modifier = 'modifier_item_mjz_dragon_lance'
    local modifier_stats = 'modifier_item_mjz_dragon_lance_stats'
    if caster then
        if not caster:IsRangedAttacker() then return nil end
        if caster:HasModifier(modifier_stats) then return nil end
        if caster:HasModifier(modifier) then caster:RemoveModifierByName(modifier) end
        caster:AddNewModifier(caster, ability, modifier, {})
    end   
end
function OnUnequip(keys)
    if not IsServer() then return nil end
    local caster = keys.caster
    local modifier = 'modifier_item_mjz_dragon_lance'
    if caster then
        if caster:HasModifier(modifier) then caster:RemoveModifierByName(modifier) end
    end   
end
function OnSpellStart(keys)
    if not IsServer() then return nil end
    local caster = keys.caster
	local ability = keys.ability
	local modifier = 'modifier_item_mjz_dragon_lance'
    local modifier_stats = 'modifier_item_mjz_dragon_lance_stats'
    local sound_cast = keys.sound_cast
    if ability and caster then
        local item_name = ability:GetAbilityName()
        if caster:HasModifier(modifier_stats) then return nil end
        caster:AddNewModifier(caster, ability, modifier_stats, {})
        caster:EmitSound(sound_cast)
        ability:SetCurrentCharges(ability:GetCurrentCharges() - 1)
        --caster:RemoveItem(ability)
        caster:TakeItem(ability)
        caster:RemoveModifierByName(modifier)

        -- Create a Item for one game frame to prevent regular dota interactions from going bad
        if Timers then
            local item_dummy = CreateItem(item_name, caster, caster)
            caster:AddItem(item_dummy)
            Timers:CreateTimer(FrameTime(), function()
                if caster then
                    --caster:RemoveItem(item_dummy)
                    caster:TakeItem(item_dummy)
                end    
            end)   
        end
    end  
end


modifier_item_mjz_dragon_lance = class({})
function modifier_item_mjz_dragon_lance:IsHidden() return true end
function modifier_item_mjz_dragon_lance:IsPurgable() return false end
function modifier_item_mjz_dragon_lance:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_item_mjz_dragon_lance:GetTexture() return "modifiers/mjz_dragon_lance" end
function modifier_item_mjz_dragon_lance:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS} end
function modifier_item_mjz_dragon_lance:GetModifierAttackRangeBonus(htable) return self:GetAbility():GetSpecialValueFor("base_attack_range") end


modifier_item_mjz_dragon_lance_stats = class({})
function modifier_item_mjz_dragon_lance_stats:IsHidden() return false end
function modifier_item_mjz_dragon_lance_stats:IsPurgable() return false end
function modifier_item_mjz_dragon_lance_stats:OnCreated(keys)
	if IsServer() then if not self:GetAbility() then self:Destroy() end end
end
function modifier_item_mjz_dragon_lance_stats:AllowIllusionDuplicate() return true end    
function modifier_item_mjz_dragon_lance_stats:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_item_mjz_dragon_lance_stats:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA + 100000
end
function modifier_item_mjz_dragon_lance_stats:GetPriority()
	return MODIFIER_PRIORITY_ULTRA + 100000
end
function modifier_item_mjz_dragon_lance_stats:GetTexture() return "modifiers/mjz_dragon_lance" end
function modifier_item_mjz_dragon_lance_stats:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_TOOLTIP} end
function modifier_item_mjz_dragon_lance_stats:GetModifierAttackRangeBonus(htable) return 440 end
function modifier_item_mjz_dragon_lance_stats:OnTooltip() return 440 end

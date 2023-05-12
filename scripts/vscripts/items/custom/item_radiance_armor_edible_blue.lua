

LinkLuaModifier("modifier_item_radiance_armor_blue_edible", "items/custom/item_radiance_armor_blue_edible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_radiance_armor_aura_blue_edible", "items/custom/item_radiance_armor_blue_edible", LUA_MODIFIER_MOTION_NONE)

function OnSpellStart( keys )
    if not IsServer() then return nil end

    local caster = keys.caster
	local ability = keys.ability
    local modifier_stats2 = 'modifier_item_radiance_armor_blue_edible'
    local modifier_stats3 = "modifier_item_radiance_armor_aura_blue_edible"    
    if ability:GetCurrentCharges() < 1 then return end

    local sound_cast = keys.sound_cast
    local item_name = ability:GetAbilityName()
	local radiance_table = {
	"modifier_item_radiance_armor",
	"modifier_item_radiance_armor_3",
	"modifier_item_radiance_armor_blue",
    "modifier_item_radiance_armor_green",
    "modifier_item_radiance_armor_3_edible",
	"modifier_item_radiance_armor_blue_edible",
    "modifier_item_radiance_armor_green_edible", 
	}
	for i = 1 , 7 do
		if caster:HasModifier(radiance_table[i]) then
            --print(radiance_table[i])
            return nil
		end	
    end     
   
    if caster:HasModifier(modifier_stats2) or caster:HasModifier(modifier_stats3) then
		return nil
    end
    
    caster:AddNewModifier(caster, ability, modifier_stats2, {})
    caster:EmitSound(sound_cast)
    ability:SetCurrentCharges( ability:GetCurrentCharges() - 1 )

end
function OnCreated_(keys)
    if not IsServer() then return nil end

    local caster = keys.caster
	local ability = keys.ability
    if caster and ability then
        DropNeutralItemAtPositionForHero("item_radiance_armor_blue_edible", caster:GetAbsOrigin(), caster, 5, false)
        caster:RemoveItem(ability) 
    end
end

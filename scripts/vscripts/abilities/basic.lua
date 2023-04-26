function BuffStackIncrement(params)
	local caster = params.caster
	local ability = params.ability
	local modifier_buff = params.modifier_buff
	local previous_stack_count = 0
		if caster:HasModifier(modifier_buff) then
			previous_stack_count = caster:GetModifierStackCount(modifier_buff, nil)
			
			--We have to remove and replace the modifier so the duration will refresh (so it will show the duration of the latest Essence Shift).
			caster:RemoveModifierByName(modifier_buff)
		end
		ability:ApplyDataDrivenModifier(caster, caster, modifier_buff, nil)
		caster:SetModifierStackCount(modifier_buff, nil, previous_stack_count + 1)

end

function BuffStackOnDestroy(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = keys.modifier_buff

	if caster:HasModifier(modifier) then
		local previous_stack_count = caster:GetModifierStackCount(modifier, nil)
		if previous_stack_count > 1 then
			caster:SetModifierStackCount(modifier, nil, previous_stack_count - 1)
		else
			caster:RemoveModifierByName(modifier)
		end
	end
end

function DebuffStackIncrement(params)
	local caster = params.caster
	local target = params.target
	local ability = params.ability
	local modifier = params.modifier_debuff
	local previous_stack_count = 0
	
		if target:HasModifier(modifier) then
			previous_stack_count = target:GetModifierStackCount(modifier, nil)
			
			--We have to remove and replace the modifier so the duration will refresh (so it will show the duration of the latest Essence Shift).
			target:RemoveModifierByName(modifier)
		end
		ability:ApplyDataDrivenModifier(caster, target, modifier, nil)
		target:SetModifierStackCount(modifier, nil, previous_stack_count + 1)

end

function DebuffStackOnDestroy(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = keys.modifier_debuff

	if target:HasModifier(modifier) then
		local previous_stack_count = target:GetModifierStackCount(modifier, nil)
--		print("stack count = "..previous_stack_count)
		if previous_stack_count > 1 then
			target:SetModifierStackCount(modifier, nil, previous_stack_count - 1)
		else
			target:RemoveModifierByName(modifier)
		end
	end
end

function DamageApply( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local target_max_hp = target:GetMaxHealth() / 100
	local aura_damage = ability:GetLevelSpecialValueFor("aura_damage", (ability:GetLevel() - 1))
	local aura_damage_interval = ability:GetLevelSpecialValueFor("aura_damage_interval", (ability:GetLevel() - 1))


	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = caster
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.ability = ability
	damage_table.damage = 1
	damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS -- Doesnt trigger abilities and items that get disabled by damage

	ApplyDamage(damage_table)
end

function SetLevelForSubAbility(main_ability, sub_ability_name, target, level_required, level_to_set)
	local main_ability_level = main_ability:GetLevel()
	local sub_ability = target:FindAbilityByName(sub_ability_name)
	if sub_ability == nil then
		return
	end
	
	if main_ability_level < level_required then
		return
	end
	
	if level_to_set == nil then
		sub_ability:SetLevel(main_ability_level)
	else
		sub_ability:SetLevel(level_to_set)
	end
	
end

function DropItemWithTimer( unit, item_name, loot_duration )

	local spawnPoint = unit:GetAbsOrigin()	
	local newItem = CreateItem( item_name, nil, nil )
	local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )
	local dropRadius = RandomFloat( 50, 100 )

	--newItem:LaunchLootInitialHeight( false, 0, 150, 0.5, spawnPoint + RandomVector( dropRadius ) )
	if loot_duration then
		newItem:SetContextThink( "KillLoot", function() return KillLoot( newItem, drop ) end, loot_duration )
	end
end

function DropItemWithTimerGround( unit, item_name, loot_duration )

	local spawnPoint = unit:GetAbsOrigin()	
	local newItem = CreateItem( item_name, nil, nil )
	local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )

	--newItem:LaunchLootInitialHeight( false, 0, 150, 0.5, spawnPoint )
	if loot_duration then
		newItem:SetContextThink( "KillLoot", function() return KillLoot( newItem, drop ) end, loot_duration )
	end
end

function DropItemWithTimerAndRoll( unit, item_name, roll_percentage, loot_duration )
	if RollPercentage(roll_percentage) then
		return
	end
	local spawnPoint = unit:GetAbsOrigin()	
	local newItem = CreateItem( item_name, nil, nil )
	local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )
	local dropRadius = RandomFloat( 50, 100 )

	--newItem:LaunchLootInitialHeight( false, 0, 150, 0.5, spawnPoint + RandomVector( dropRadius ) )
	if loot_duration then
		newItem:SetContextThink( "KillLoot", function() return KillLoot( newItem, drop ) end, loot_duration )
	end
	
end

function KillLoot( item, drop )

	if drop:IsNull() then
		return
	end

	local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, drop )
	ParticleManager:SetParticleControl( nFXIndex, 0, drop:GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
	ParticleManager:DestroyParticle(nFXIndex, false)
	ParticleManager:ReleaseParticleIndex( nFXIndex )
--	EmitGlobalSound("Item.PickUpWorld")

	UTIL_Remove( item )
	UTIL_Remove( drop )
end

function SetUnitParams( unit, health, damage, armor )

	if unit == nil then
		print ("unit not found !")
		return
	end	
	if damage ~= nil then
		unit:SetBaseDamageMin( damage )
		unit:SetBaseDamageMax( damage )
	end	
	if armor ~= nil then
		unit:SetPhysicalArmorBaseValue( armor )
	end	
	if health ~= nil then
		unit:SetMaxHealth( health)
		unit:SetBaseMaxHealth( health )
		unit:SetHealth( health )
	end	
		
end

function ModifyUnitParams( unit, health, damage, armor )

	if unit == nil then
		print ("unit not found !")
		return
	end	
	if damage ~= nil then
		unit:SetBaseDamageMin(unit:GetBaseDamageMin() + damage )
		unit:SetBaseDamageMax(unit:GetBaseDamageMax() + damage )
	end	
	if armor ~= nil then
		unit:SetPhysicalArmorBaseValue(unit:GetPhysicalArmorBaseValue() + armor )
	end	
	if health ~= nil then
		local modified_health = unit:GetMaxHealth() + health
		local current_health = unit:GetCurrentHealth() + health
		unit:SetMaxHealth( modified_health)
		unit:SetBaseMaxHealth( modified_health )
		unit:SetHealth( current_health )
	end	
		
end

function CreateNewItem( keys )
	local caster = keys.caster
	local item_name = keys.item_name
	local spawnPoint = caster:GetAbsOrigin()	
	local newItem = CreateItem( item_name, nil, nil )
	local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )
	local dropRadius = RandomFloat( 50, 100 )

	--newItem:LaunchLootInitialHeight( false, 0, 150, 0.5, spawnPoint + RandomVector( dropRadius ) )
end

function DealDamagePerTick( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local damage_type = ability:GetAbilityDamageType() or DAMAGE_TYPE_MAGICAL
	local dmg_per_sec = ability:GetSpecialValueFor("dmg_per_sec")
	local interval = ability:GetSpecialValueFor("interval")
	local damage = dmg_per_sec * interval

	DealDamage(caster, target, damage, damage_type, nil, ability)
	
end


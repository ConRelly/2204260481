function autoapply( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_item_aghanims_shard") or caster:HasModifier("modifier_arc_warden_tempest_double") then
		return nil
	else
		caster:AddNewModifier(caster, ability, "modifier_item_aghanims_shard", {})
	end
	ability:SetCurrentCharges( ability:GetCurrentCharges() - 1 )
	caster:RemoveItem(ability)
end


function OnSpellStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_item_aghanims_shard") and (caster:HasModifier("modifier_item_ultimate_scepter_consumed") or caster:HasModifier("modifier_item_ultimate_scepter")) then
		if ability:GetCurrentCharges() >= keys.Super_Scepter then
			if (ability:GetCurrentCharges() - keys.Super_Scepter) == 0 then
				caster:RemoveItem(ability)
			else
				ability:SetCurrentCharges(ability:GetCurrentCharges() - keys.Super_Scepter)
			end
			local item = CreateItem("item_imba_ultimate_scepter_synth2", nil, nil)
			item:SetPurchaseTime(0)
			caster:AddItem(item)
			caster:EmitSoundParams("Item.MoonShard.Consume", 1, 0.5, 0)
		end
	elseif caster:HasModifier("modifier_item_aghanims_shard") then
		if ability:GetCurrentCharges() >= keys.Scepter then
			if (ability:GetCurrentCharges() - keys.Scepter) == 0 then
				caster:RemoveItem(ability)
			else
				ability:SetCurrentCharges(ability:GetCurrentCharges() - keys.Scepter)
			end
			local item = CreateItem("item_ultimate_scepter", nil, nil)
			item:SetPurchaseTime(0)
			caster:AddItem(item)
			caster:EmitSoundParams("Item.MoonShard.Consume", 1, 0.5, 0)
		end
	else
		if ability:GetCurrentCharges() >= keys.Shard then
			if (ability:GetCurrentCharges() - keys.Shard) == 0 then
				caster:RemoveItem(ability)
			else
				ability:SetCurrentCharges(ability:GetCurrentCharges() - keys.Shard)
			end
			local item = CreateItem("item_aghanims_shard", nil, nil)
			item:SetPurchaseTime(0)
			caster:AddItem(item)
			caster:EmitSoundParams("Item.MoonShard.Consume", 1, 0.5, 0)
		end
	end
end

function NoPurchaser(keys)
	if not keys.caster then return end  -- seems roshan getting killed by aghanim very rare it gives a nill caster error (it might give even if he just dies by anybody and drops shard)
	if keys.caster:IsNull() then return end
	if not keys.caster:IsAlive() then return end
	if keys.ability and not keys.ability:IsNull() then
		keys.ability:SetPurchaser(nil)
	end	
end

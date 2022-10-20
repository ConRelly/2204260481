LinkLuaModifier("modifier_item_red_divine_rapier", "items/item_red_divine_rapier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_red_divine_rapier_edible_5", "items/item_red_divine_rapier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_red_divine_rapier_deff_bonus", "items/item_red_divine_rapier.lua", LUA_MODIFIER_MOTION_NONE)


item_red_divine_rapier = class({})
function item_red_divine_rapier:GetIntrinsicModifierName() return "modifier_item_red_divine_rapier" end

item_red_divine_rapier_lv1 = class(item_red_divine_rapier)
item_red_divine_rapier_lv2 = class(item_red_divine_rapier)
item_red_divine_rapier_lv3 = class(item_red_divine_rapier)
item_red_divine_rapier_lv4 = class(item_red_divine_rapier)
item_red_divine_rapier_lv5 = class(item_red_divine_rapier)

modifier_item_red_divine_rapier = class({})


function item_red_divine_rapier_lv5:OnSpellStart()
    if not IsServer() then return nil end
	print("start consuming")
    local caster = self:GetCaster()
	local ability = self
	if ability then
		local modifier_stats = 'modifier_item_red_divine_rapier_edible_5'
		local modifier_stats2 = "modifier_item_red_divine_rapier"
		if ability:GetCurrentCharges() < 1 then return end

		local sound_cast = "Hero_Alchemist.Scepter.Cast"
		local item_name = ability:GetAbilityName()
	
		if caster:HasModifier(modifier_stats) then
			print("has modifier")
			return nil
		end
		caster:AddNewModifier(caster, ability, modifier_stats, {})


		caster:EmitSound(sound_cast)
		ability:SetCurrentCharges( ability:GetCurrentCharges() - 1 )
		caster:RemoveItem(ability)
	end
end



function modifier_item_red_divine_rapier:IsPurgable() return false end
function modifier_item_red_divine_rapier:IsHidden() return true end
function modifier_item_red_divine_rapier:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_item_red_divine_rapier:OnCreated()
end
function modifier_item_red_divine_rapier:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_red_divine_rapier:OnRefresh()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local modif_deff_bonus = "modifier_item_red_divine_rapier_deff_bonus"		
		if self.trigger then
			if self.trigger > 0 then
				self.trigger = 0
				caster:AddNewModifier(caster, ability, modif_deff_bonus, {duration = 420})
			end	
		end	
	end	
end
function modifier_item_red_divine_rapier:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() and self:GetParent() then
		if self:GetParent():GetName() ~= "npc_dota_hero_sven" then
			return self:GetAbility():GetSpecialValueFor("bonus_damage")
		end
		return 0
	end	
end
function modifier_item_red_divine_rapier:GetModifierTotalDamageOutgoing_Percentage(params)
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local target = params.target
	if parent == nil then return end
	if target == nil then target = params.unit end
	if target == nil then return end
	if params.attacker ~= parent then return end
	if params.attacker == target then return end
	if ability then
		if parent:IsHero() then
			local damage = ability:GetSpecialValueFor("swrod_master_bonus_ptc")			
			if target:GetUnitName() == "npc_boss_juggernaut_4" then
				if not self.trigger then
					self.trigger = 1	
					self:OnRefresh()
				end	
				return damage
			else
				return 0
			end
		end	
		return 0
	end	
end

function modifier_item_red_divine_rapier:GetModifierBaseAttack_BonusDamage()
	if self:GetAbility() and self:GetParent() then
		if self:GetParent():GetName() == "npc_dota_hero_sven" then
			return self:GetAbility():GetSpecialValueFor("bonus_damage")
		end	
		return 0
	end	
end

function modifier_item_red_divine_rapier:GetModifierSpellAmplify_Percentage()
	if self:GetAbility()then
		return self:GetAbility():GetSpecialValueFor("bonus_spell_amp")
	end	
end

--------------Def bonus Modifier--------------------
modifier_item_red_divine_rapier_deff_bonus = class({})
function modifier_item_red_divine_rapier_deff_bonus:IsPurgable() return false end
function modifier_item_red_divine_rapier_deff_bonus:IsHidden() return false end
function modifier_item_red_divine_rapier_deff_bonus:RemoveOnDeath() return false end
function modifier_item_red_divine_rapier_deff_bonus:GetTexture() return "red_divine_rapier" end
function modifier_item_red_divine_rapier_deff_bonus:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end

function modifier_item_red_divine_rapier_deff_bonus:GetModifierTotal_ConstantBlock(kv)
	if IsServer() then
		local parent = self:GetParent()
		local attacker = kv.attacker
		if kv.target ~= parent then return end
		if attacker == parent then return end
		local dmg_reduction = 0
		if self:GetAbility() then
			dmg_reduction = self:GetAbility():GetSpecialValueFor("reduction_shield")  / 100
		else
			dmg_reduction = 0.76
		end	
		if attacker:GetUnitName() ~= "npc_boss_juggernaut_4" then return end
		if not parent:HasModifier("modifier_abaddon_borrowed_time") and kv.damage > 0 and bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS then
			local block = math.floor(kv.damage * dmg_reduction)
			return block
		end
	end
end

---------------- Edible Rapier 5 effect ------------
modifier_item_red_divine_rapier_edible_5 = class({})


function modifier_item_red_divine_rapier_edible_5:IsPurgable() return false end
function modifier_item_red_divine_rapier_edible_5:IsHidden() return false end
function modifier_item_red_divine_rapier_edible_5:RemoveOnDeath() return false end
function modifier_item_red_divine_rapier_edible_5:GetTexture() return "red_divine_rapier" end
function modifier_item_red_divine_rapier_edible_5:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function modifier_item_red_divine_rapier_edible_5:OnCreated()
end
function modifier_item_red_divine_rapier_edible_5:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_red_divine_rapier_edible_5:OnRefresh()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local modif_deff_bonus = "modifier_item_red_divine_rapier_deff_bonus"		
		if self.trigger then
			if self.trigger > 0 then
				self.trigger = 0
				caster:AddNewModifier(caster, ability, modif_deff_bonus, {duration = 420})
			end	
		end	
	end	
end

function modifier_item_red_divine_rapier_edible_5:GetModifierPreAttack_BonusDamage()
	if self:GetParent() then
		if self:GetParent():HasModifier("modifier_item_red_divine_rapier") then return 0 end
		if self:GetParent():GetName() ~= "npc_dota_hero_sven" then
			return 75000
		end
		return 0
	end	
end
function modifier_item_red_divine_rapier_edible_5:GetModifierTotalDamageOutgoing_Percentage(params)
	local parent = self:GetParent()
	local target = params.target
	if parent == nil then return end
	if target == nil then target = params.unit end
	if target == nil then return end
	if params.attacker ~= parent then return end
	if params.attacker == target then return end
	if self:GetParent():HasModifier("modifier_item_red_divine_rapier") then return 0 end
	if parent:IsHero() then
		local damage = 240
		if target:GetUnitName() == "npc_boss_juggernaut_4" then  --npc_dota_dummy_misha  --npc_boss_juggernaut_4
			if not self.trigger then
				self.trigger = 1	
				self:OnRefresh()
			end			
			return damage
		else
			return 0
		end
	end	
	return 0
end

function modifier_item_red_divine_rapier_edible_5:GetModifierBaseAttack_BonusDamage()
	if self:GetParent() then
		if self:GetParent():HasModifier("modifier_item_red_divine_rapier") then return 0 end
		if self:GetParent():GetName() == "npc_dota_hero_sven" then
			return 75000
		end	
		return 0
	end	
end

function modifier_item_red_divine_rapier_edible_5:GetModifierSpellAmplify_Percentage()
	if self:GetParent() then
		if self:GetParent():HasModifier("modifier_item_red_divine_rapier") then return 0 end
		return 250
	end
end
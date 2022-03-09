LinkLuaModifier("modifier_owner_buff", "abilities/custom/owner_buff", LUA_MODIFIER_MOTION_NONE)
if not owner_buff then owner_buff = class({}) end
function owner_buff:GetIntrinsicModifierName() return "modifier_owner_buff" end


if not modifier_owner_buff then modifier_owner_buff = class({}) end
function modifier_owner_buff:IsHidden() return false end
function modifier_owner_buff:OnCreated()
	if IsServer() then
		Timers:CreateTimer(0.2, function()
			local abillity = self:GetAbility()
			local parent = self:GetParent()
			local owner = parent:GetOwner()
			if not IsValidEntity(owner) then return end 
			--print(owner)
			local owner_attack = owner:GetAverageTrueAttackDamage(owner) * 1.5
			local owner_spell = owner:GetSpellAmplification(false) * 5000
			local owner_armor = owner:GetPhysicalArmorValue(false) * 100
			local owner_hp_mp = (owner:GetMaxMana() + owner:GetMaxHealth()) / 2
			local bonus_dmg = owner_attack
			local lvl = owner:GetLevel()
			--parent:SetHealth(owner:GetMaxHealth())
			if lvl > 30 then
				bonus_dmg = math.ceil(bonus_dmg + owner_spell + owner_armor + owner_hp_mp)
			end
			if parent:GetUnitName()== "npc_playerhelp" then
				bonus_dmg = math.ceil(bonus_dmg / 3)
			elseif parent:GetUnitName() == "npc_dota_clinkz_skeleton_archer_frostivus2018" or parent:GetUnitName() == "npc_dota_clinkz_skeleton_archer_frostivus20182" then
				bonus_dmg = math.ceil(bonus_dmg / 5)
			end
			self.bonus = bonus_dmg
		end)
	end
end
function modifier_owner_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end
function modifier_owner_buff:GetModifierBaseAttack_BonusDamage()
	return self.bonus or 20
end

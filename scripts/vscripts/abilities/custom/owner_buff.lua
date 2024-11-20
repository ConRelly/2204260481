LinkLuaModifier("modifier_owner_buff", "abilities/custom/owner_buff", LUA_MODIFIER_MOTION_NONE)
if not owner_buff then owner_buff = class({}) end
function owner_buff:GetIntrinsicModifierName() return "modifier_owner_buff" end


if not modifier_owner_buff then modifier_owner_buff = class({}) end
function modifier_owner_buff:IsHidden() return false end
function modifier_owner_buff:OnCreated()
	if IsServer() then
		Timers:CreateTimer(0.2, function()
			if self == nil then return end
			if not self:GetParent() then return end
			if not self:GetParent():IsAlive() then return end
			local parent = self:GetParent()
			local owner = parent:GetOwner()
			if parent:GetUnitLabel() == "spirit_bear" then
				for playerID = 0, 4 do
					if PlayerResource:IsValidPlayerID(playerID) then
						if PlayerResource:HasSelectedHero(playerID) then
							if PlayerResource:GetPlayer(playerID) then
								local hero = PlayerResource:GetSelectedHeroEntity(playerID)
								if hero:GetUnitName()== "npc_dota_hero_lone_druid" then
									owner = hero
								end	
							end	
						end
					end
				end				
			end	
			if not IsValidEntity(owner) then print("no Owner") return end 
			--print(owner)
			if owner and owner ~= nil then
				local owner_attack = owner:GetAverageTrueAttackDamage(parent) * 2.0
				local owner_spell = owner:GetSpellAmplification(false) * 5000
				local owner_armor = owner:GetPhysicalArmorValue(false) * 500
				local owner_hp_mp = (owner:GetMaxMana() * 2 ) + (owner:GetMaxHealth() / 2)
				local bonus_dmg = owner_attack
				local lvl = owner:GetLevel()
				--parent:SetHealth(owner:GetMaxHealth())
				if lvl > 30 then
					bonus_dmg = math.ceil(bonus_dmg + owner_spell + owner_armor + owner_hp_mp)
				end
				if parent:GetUnitName()== "npc_playerhelp" then
					bonus_dmg = math.ceil(bonus_dmg / 2)
				elseif parent:GetUnitName() == "npc_dota_clinkz_skeleton_archer_frostivus2018" or parent:GetUnitName() == "npc_dota_clinkz_skeleton_archer_frostivus20182" or parent:GetUnitName() == "npc_dota_clinkz_skeleton_archer" then
					bonus_dmg = math.ceil(bonus_dmg / 3)
				end
				self.bonus = bonus_dmg
			end
		end)
		self:StartIntervalThink(20)
	end
end
function modifier_owner_buff:OnIntervalThink()
	if IsServer() then
		self:OnCreated()
	end
end	


function modifier_owner_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end

function modifier_owner_buff:GetModifierBaseAttack_BonusDamage()
	return self.bonus or 20
end



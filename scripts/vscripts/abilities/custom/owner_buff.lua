LinkLuaModifier("modifier_owner_buff", "abilities/custom/owner_buff", LUA_MODIFIER_MOTION_NONE)

owner_buff = owner_buff or class({})
function owner_buff:GetIntrinsicModifierName() return "modifier_owner_buff" end

local function GetOwnerUnit(summon)
	local owner = summon:GetOwner()
	if owner and not owner:IsNull() and owner ~= summon then
		if owner.GetAverageTrueAttackDamage and summon:GetUnitLabel() ~= "spirit_bear" then return owner end
		if owner.IsRealHero and owner:IsRealHero() then return owner end
		if owner.GetAssignedHero then return owner:GetAssignedHero() end
	end
	local playerID = summon:GetPlayerOwnerID()
	if PlayerResource:IsValidPlayerID(playerID) then
		return PlayerResource:GetSelectedHeroEntity(playerID)
	end
end

modifier_owner_buff = modifier_owner_buff or class({})
function modifier_owner_buff:IsHidden() return false end

function modifier_owner_buff:OnCreated()
	if not IsServer() then return end
	self:SetHasCustomTransmitterData(true)
	-- Ownership may be assigned in the spawn callback after the intrinsic is created.
	self:StartIntervalThink(0.2)
end

function modifier_owner_buff:OnIntervalThink()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if not parent or parent:IsNull() or not ability or ability:IsNull() then
		self:StartIntervalThink(-1)
		return
	end
	if not parent:IsAlive() then return end

	local owner = GetOwnerUnit(parent)
	if not owner or owner:IsNull() or owner == parent then
		self:StartIntervalThink(1)
		return
	end

	local bonus = owner:GetAverageTrueAttackDamage(owner) * ability:GetSpecialValueFor("owner_attack") / 100
	if owner:GetLevel() > 30 then
		bonus = math.ceil(bonus
			+ owner:GetSpellAmplification(false) * ability:GetSpecialValueFor("owner_amp") * 100
			+ owner:GetPhysicalArmorValue(false) * ability:GetSpecialValueFor("owner_armor")
			+ owner:GetMaxHealth() * ability:GetSpecialValueFor("owner_hp_mp_tooltip") / 100
			+ owner:GetMaxMana() * ability:GetSpecialValueFor("owner_mp_tooltip") / 100)
	end

	local unitName = parent:GetUnitName()
	if unitName == "npc_playerhelp" then
		bonus = math.ceil(bonus / 2)
	elseif unitName == "npc_dota_clinkz_skeleton_archer_frostivus2018"
		or unitName == "npc_dota_clinkz_skeleton_archer_frostivus20182"
		or unitName == "npc_dota_clinkz_skeleton_archer" then
		bonus = math.ceil(bonus / 3)
	end

	if self.bonus ~= bonus then
		self.bonus = bonus
		self:SendBuffRefreshToClients()
	end
	self:StartIntervalThink(20)
end

function modifier_owner_buff:AddCustomTransmitterData()
	return {bonus = self.bonus or 20}
end

function modifier_owner_buff:HandleCustomTransmitterData(data)
	self.bonus = data.bonus
end

function modifier_owner_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end

function modifier_owner_buff:GetModifierBaseAttack_BonusDamage()
	return self.bonus or 20
end

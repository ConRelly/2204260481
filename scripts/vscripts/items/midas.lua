-----------------
--HAND OF MIDAS--
-----------------
item_hom = class({})
LinkLuaModifier("modifier_hom", "items/midas", LUA_MODIFIER_MOTION_NONE)
function item_hom:GetAbilityTextureName() return "item_hand_of_midas" end

--UP: Aghanim's Shard
function item_hom:GetCastRange(location, target) if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then return nil else return 600 end end
---------------------

function item_hom:CastFilterResultTarget(target)
	if IsServer() then
		local caster = self:GetCaster()
		if target:GetTeamNumber() == caster:GetTeamNumber() then return 	UF_FAIL_FRIENDLY end
		if target:IsHero() then return 										UF_FAIL_HERO end
		if target:IsOther() then return 									UF_FAIL_CUSTOM end
		if string.find(target:GetUnitName(), "necronomicon") then return 	UF_FAIL_CUSTOM end
		if target:IsConsideredHero() then return 							UF_FAIL_CONSIDERED_HERO end
		if target:IsBuilding() then return 									UF_FAIL_BUILDING end
		return UF_SUCCESS
	end
end
function item_hom:GetCustomCastErrorTarget(target)
	if IsServer() then
		local caster = self:GetCaster()
		if target:IsOther() then return "#dota_hud_error_cant_use_on_wards" end
		if string.find(target:GetUnitName(), "necronomicon") then return "#dota_hud_error_cant_use_on_necrobook" end
	end
end
function item_hom:GetAbilityTextureName()
	local caster = self:GetCaster()
	local caster_name = caster:GetUnitName()
	local animal_heroes = {
		["npc_dota_hero_brewmaster"] = true,
		["npc_dota_hero_magnataur"] = true,
		["npc_dota_hero_lone_druid"] = true,
		["npc_dota_lone_druid_bear1"] = true,
		["npc_dota_lone_druid_bear2"] = true,
		["npc_dota_lone_druid_bear3"] = true,
		["npc_dota_lone_druid_bear4"] = true,
		["npc_dota_lone_druid_bear5"] = true,
		["npc_dota_lone_druid_bear6"] = true,
		["npc_dota_lone_druid_bear7"] = true,
		["npc_dota_hero_broodmother"] = true,
		["npc_dota_hero_lycan"] = true,
		["npc_dota_hero_ursa"] = true,
		["npc_dota_hero_malfurion"] = true,
	}
	if animal_heroes[caster_name] then return "custom/paw_of_midas" end
	return "hand_of_midas"
end
function item_hom:OnSpellStart()
	local owner = self:GetCaster()
	local target = self:GetCursorTarget()
	local gold = self:GetSpecialValueFor("bonus_gold")
	if self:IsFullyCastable() then
		Midas(owner, target, self, gold)
	end
end
function item_hom:GetIntrinsicModifierName() return "modifier_hom" end
modifier_hom = class({})
function modifier_hom:IsHidden() return true end
function modifier_hom:IsPurgable() return false end
function modifier_hom:RemoveOnDeath() return false end
function modifier_hom:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_hom:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_hom:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
end

--------------------
--GAUTLET OF MIDAS--
--------------------
item_gom = class({})
LinkLuaModifier("modifier_gom", "items/midas", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gom_changedhands_buff", "items/midas", LUA_MODIFIER_MOTION_NONE)
function item_gom:GetAbilityTextureName() return "custom/gautlet_of_midas" end
function item_gom:GetIntrinsicModifierName() return "modifier_gom" end
modifier_gom = class({})
function modifier_gom:IsHidden() return false end
function modifier_gom:IsPurgable() return false end
function modifier_gom:IsDebuff() return false end
function modifier_gom:RemoveOnDeath() return false end
function modifier_gom:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_gom:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end self:StartIntervalThink(FrameTime()) end
end
function modifier_gom:OnDestroy() if IsServer() then self:GetCaster():RemoveModifierByName("modifier_gom_changedhands_buff") self:Destroy() end end
function modifier_gom:OnIntervalThink()
	if IsServer() then
		if self:GetAbility():IsCooldownReady() and self:GetAbility():IsOwnersManaEnough() and not self:GetCaster():IsIllusion() then modifier = true else modifier = false end
		if modifier then self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_gom_changedhands_buff", {}) else self:GetCaster():RemoveModifierByName("modifier_gom_changedhands_buff") end
	end
end
function modifier_gom:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_TOOLTIP} end
function modifier_gom:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetCaster()
		local target = keys.target
		if owner ~= keys.attacker then return end
		local ability = self:GetAbility()
		local bonus_gold = ability:GetSpecialValueFor("bonus_gold")
		local stacks = self:GetStackCount()
		local add_gold = ability:GetSpecialValueFor("add_per_use")
		local stack_proc = ability:GetSpecialValueFor("stack_proc")
		local gold = bonus_gold + (add_gold * stacks)
		if ability:IsCooldownReady() and ability:IsOwnersManaEnough() and not owner:IsIllusion() then
			Midas(owner, target, ability, gold)

			--UP: Aghanim's Scepter
			if self:GetCaster():HasScepter() then
				self:IncrementStackCount()
			end
			-----------------------

		end

		--UP: Aghanim's Shard + Aghanim's Scepter
		if self:GetCaster():HasModifier("modifier_item_aghanims_shard") and self:GetCaster():HasScepter() then
			if RollPseudoRandom(stack_proc, self) then
				self:IncrementStackCount()
				local gold = add_gold * stacks
				owner:ModifyGold(gold, true, 0)
				SendOverheadEventMessage(PlayerResource:GetPlayer(owner:GetPlayerOwnerID()), OVERHEAD_ALERT_GOLD, target, gold, nil)
			end
		end
		-----------------------------------------

	end
end
function modifier_gom:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
end
function modifier_gom:OnTooltip()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("add_per_use") * self:GetStackCount() end
end
function modifier_gom:CheckState()
	return {[MODIFIER_STATE_CANNOT_MISS] = true}
end
-- Money changes hands --
modifier_gom_changedhands_buff = class({})
function modifier_gom_changedhands_buff:IsHidden() return false end
function modifier_gom_changedhands_buff:IsPurgable() return false end
function modifier_gom_changedhands_buff:RemoveOnDeath() return false end
function modifier_gom_changedhands_buff:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_gom_changedhands_buff:OnCreated()
	if IsServer() then if not self:GetAbility() then self:Destroy() end
		local earnedgold_dmg = self:GetAbility():GetSpecialValueFor("earnedgold_dmg")
		local earnedgold = PlayerResource:GetTotalEarnedGold(self:GetCaster():GetPlayerID())
		networth = (475 + earnedgold) * earnedgold_dmg / 100
		self:SetStackCount(networth)
	end
end
function modifier_gom_changedhands_buff:OnRefresh() self:OnCreated() end
function modifier_gom_changedhands_buff:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetStackCount() end
end
function modifier_gom_changedhands_buff:OnAttackLanded(keys)
	local parent = self:GetParent()
	if keys.attacker == parent and self:GetAbility() and not parent:IsIllusion() and self:GetParent():FindAllModifiersByName(self:GetName())[1] == self then
		self:GetCaster():RemoveModifierByName("modifier_gom_changedhands_buff")
	end
end


--заработки в интернетах
function Midas(caster, target, ability, bonus_gold)
	local sound_cast = "DOTA_Item.Hand_Of_Midas"
	local cd = ability:GetSpecialValueFor("base_cooldown")
	local aghs_cd = ability:GetSpecialValueFor("aghs_cd")
	local aghs_gold = ability:GetSpecialValueFor("aghs_gold")

	--UP: Aghanim's Scepter
	if caster:HasScepter() then bonus_gold = (bonus_gold + aghs_gold) end
	-----------------------

	--UP: Aghanim's Shard + Aghanim's Scepter
	if caster:HasModifier("modifier_item_aghanims_shard") and caster:HasScepter() then cd = (cd - aghs_cd) end
	-----------------------------------------

	local player_x = PlayerResource:GetPlayerCount()
	local bonus_gpp = bonus_gold * (3.5 - (0.5 * player_x))
	ability:StartCooldown(cd)
	target:EmitSound(sound_cast)
	SendOverheadEventMessage(PlayerResource:GetPlayer(caster:GetPlayerOwnerID()), OVERHEAD_ALERT_GOLD, target, bonus_gpp, nil)
	local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(midas_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
	if not caster:IsHero() then caster = caster:GetPlayerOwner():GetAssignedHero() end
	caster:ModifyGold(bonus_gpp, true, 0)
end
local THIS_LUA = "abilities/hero_clinkz/mjz_clinkz_wind_walk.lua"
LinkLuaModifier("modifier_mjz_clinkz_wind_walk_fade", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_clinkz_wind_walk", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_clinkz_wind_walk_strafe", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_clinkz_wind_walk_skeleton", THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_summon_timer", "lib/modifiers/modifier_generic_summon_timer.lua", LUA_MODIFIER_MOTION_NONE)


mjz_clinkz_wind_walk = mjz_clinkz_wind_walk or class({}) 
local ability_class = mjz_clinkz_wind_walk

function ability_class:OnSpellStart( )
	if not IsServer() then return end

	local ability = self
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = ability:GetSpecialValueFor('duration')
	local fade_time = ability:GetSpecialValueFor('fade_time')
	

	local modifier_name = 'modifier_mjz_clinkz_wind_walk_fade'
	caster:AddNewModifier(caster, ability, modifier_name, {duration = fade_time})

	caster:EmitSound("Hero_Clinkz.WindWalk")
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_windwalk.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetOrigin(), true)
    ParticleManager:ReleaseParticleIndex(particle)

end


function ability_class:TargetIsEnemy( target )
	local caster = self:GetCaster()
	local ability = self
	local nTargetTeam = ability:GetAbilityTargetTeam()
	local nTargetType = ability:GetAbilityTargetType()
	local nTargetFlags = ability:GetAbilityTargetFlags()
	local nTeam = caster:GetTeamNumber()
	local ufResult = UnitFilter(target, nTargetTeam, nTargetType, nTargetFlags, nTeam)
	return ufResult == UF_SUCCESS
end

---------------------------------------------------------------------------------------

modifier_mjz_clinkz_wind_walk_fade = class({})
local modifier_class = modifier_mjz_clinkz_wind_walk_fade

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
	function modifier_class:OnCreated(table)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
	end

	function modifier_class:OnDestroy(table)
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local duration = ability:GetSpecialValueFor('duration')
		local modifier_name = "modifier_mjz_clinkz_wind_walk"
		if parent and IsValidEntity(parent) then
			parent:AddNewModifier(caster, ability, modifier_name, {duration = duration})
		end
	end
end


---------------------------------------------------------------------------------------

modifier_mjz_clinkz_wind_walk = class({})

function modifier_mjz_clinkz_wind_walk:IsHidden() return false end
function modifier_mjz_clinkz_wind_walk:IsPurgable() return false end

function modifier_mjz_clinkz_wind_walk:CheckState() 
    local state = {
        -- [MODIFIER_STATE_PROVIDES_VISION] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
    return state
end

function modifier_mjz_clinkz_wind_walk:DeclareFunctions()
	local funcs = {
		-- MODIFIER_EVENT_ON_DEATH, -- OnDeath
		MODIFIER_EVENT_ON_ATTACK_START,		-- OnAttackStart
		-- MODIFIER_EVENT_ON_ABILITY_EXECUTED, 	-- OnAbilityExecuted
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,  --
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	}
	return funcs
end

function modifier_mjz_clinkz_wind_walk:GetModifierInvisibilityLevel(params)
    return 100
end

function modifier_mjz_clinkz_wind_walk:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("move_speed_bonus_pct")
end

function modifier_mjz_clinkz_wind_walk:OnAttackStart(event)
	if not IsServer() then return end
	if self:GetParent() ~= event.attacker then return end
	self:_Remove()
end

function modifier_mjz_clinkz_wind_walk:OnAbilityExecuted(event)
	if not IsServer() then return end
	if self:GetParent() ~= event.unit then return end
	self:_Remove()
end

function modifier_mjz_clinkz_wind_walk:_Remove( )
	self:Destroy()
end

function modifier_mjz_clinkz_wind_walk:OnDestroy()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local duration = GetTalentSpecialValueFor(ability, "attack_speed_duration")
		parent:AddNewModifier(caster, ability, "modifier_mjz_clinkz_wind_walk_strafe", {duration = duration})

		self:_Scepter()
	end
end

if IsServer() then

	function modifier_mjz_clinkz_wind_walk:_Scepter(keys)
		local ability = self:GetAbility()
		-- local caster = self:GetCaster()
		local parent = self:GetParent()
		local caster = parent
		local SKELETON_NAME  = "npc_dota_clinkz_skeleton_archer_frostivus2018"
		local ability_arrows = "frostivus2018_clinkz_searing_arrows"
		local skeleton_duration = ability:GetSpecialValueFor("scepter_skeleton_duration")

		if caster:HasScepter() then
			local caster_origin = caster:GetOrigin()
			local caster_direction = caster:GetRightVector()
			local offset = Vector(100, 0 , 0)
			local p = caster:GetAbsOrigin()
			local fv = caster:GetForwardVector()
			local p3 = p + 150 * RotateVector2D(fv, math.rad(90))
			local p2 = p - 150 * RotateVector2D(fv, math.rad(90))
			local skeleton = CreateUnitByName(SKELETON_NAME, p3, true, caster, caster:GetOwner(),caster:GetTeamNumber())
			local skeleton2 = CreateUnitByName(SKELETON_NAME, p2, true, caster, caster:GetOwner(),caster:GetTeamNumber())
			skeleton:SetControllableByPlayer(caster:GetPlayerID(), true)
			skeleton2:SetControllableByPlayer(caster:GetPlayerID(), true)
			skeleton:SetOwner(caster)
			skeleton2:SetOwner(caster)
	
			if caster:HasAbility(ability_arrows) then
				skeleton:RemoveAbility(ability_arrows)
				local searing = skeleton:AddAbility(ability_arrows)
				searing:UpgradeAbility(true)
				searing:SetLevel( caster:FindAbilityByName(ability_arrows):GetLevel() )
				searing:ToggleAutoCast()
				skeleton2:RemoveAbility(ability_arrows)
				local searing2 = skeleton2:AddAbility(ability_arrows)
				searing2:UpgradeAbility(true)
				searing2:SetLevel( caster:FindAbilityByName(ability_arrows):GetLevel() )
				searing2:ToggleAutoCast()
			end

			local caster_damage = (caster:GetBaseDamageMax() + caster:GetBaseDamageMin()) / 2
			skeleton:SetBaseAttackTime(1.0)
			skeleton:SetBaseDamageMin(caster_damage)
			skeleton:SetBaseDamageMax(caster_damage)
			skeleton2:SetBaseAttackTime(1.0)
			skeleton2:SetBaseDamageMin(caster_damage)
			skeleton2:SetBaseDamageMax(caster_damage)


			skeleton:AddNewModifier(caster, ability, "modifier_mjz_clinkz_wind_walk_skeleton", {duration = skeleton_duration})
			skeleton2:AddNewModifier(caster, ability, "modifier_mjz_clinkz_wind_walk_skeleton", {duration = skeleton_duration})
			skeleton:AddNewModifier(caster, ability, "modifier_generic_summon_timer", {duration = skeleton_duration})
			skeleton2:AddNewModifier(caster, ability, "modifier_generic_summon_timer", {duration = skeleton_duration})
		end
	end
	
	function RotateVector2D(v,theta)
		local xp = v.x*math.cos(theta)-v.y*math.sin(theta)
		local yp = v.x*math.sin(theta)+v.y*math.cos(theta)
		return Vector(xp,yp,v.z):Normalized()
	end


	
end

---------------------------------------------------------------------------------------

modifier_mjz_clinkz_wind_walk_strafe = class({})

function modifier_mjz_clinkz_wind_walk_strafe:IsHidden() return false end
function modifier_mjz_clinkz_wind_walk_strafe:IsPurgable() return false end

function modifier_mjz_clinkz_wind_walk_strafe:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,  --GetModifierAttackSpeedBonus_Constant
	}
	return funcs
end

function modifier_mjz_clinkz_wind_walk_strafe:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
end


---------------------------------------------------------------------------------------

modifier_mjz_clinkz_wind_walk_skeleton = class({})

function modifier_mjz_clinkz_wind_walk_skeleton:IsHidden() return true end
function modifier_mjz_clinkz_wind_walk_skeleton:IsPurgable() return false end

-- function modifier_mjz_clinkz_wind_walk_skeleton:CheckState() 
--     local state = {
--         [MODIFIER_STATE_INVISIBLE] = true,
--     }
--     return state
-- end

if IsServer() then
	function modifier_mjz_clinkz_wind_walk_skeleton:OnCreated()
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		parent:SetHasInventory(true)
		self:CopyItem()
	end

	function modifier_mjz_clinkz_wind_walk_skeleton:CopyItem( )
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local illusion = self:GetParent()

		for itemSlot=0,5 do
			self:CopyItemSlot(caster, illusion, itemSlot)
		end

		-- 15, 16 分别为TP槽位和自然物品槽位
		for itemSlot=15,16 do
			self:CopyItemSlot(caster, illusion, itemSlot)
		end
	end

	function modifier_mjz_clinkz_wind_walk_skeleton:CopyItemSlot(caster, illusion, itemSlot)
		local item = caster:GetItemInSlot(itemSlot)
		local item_illusion = illusion:GetItemInSlot(itemSlot)
		if item_illusion then
			item_illusion:RemoveSelf()
		end
		if item ~= nil then
			local itemName = item:GetName()
			if not IsIllusionExcludeItem(item) then
				local newItem = CreateItem(itemName, illusion, illusion)
				illusion:AddItem(newItem)
				newItem:SetStacksWithOtherOwners(true)
				newItem:SetPurchaser(nil)
				if newItem:RequiresCharges() then
					newItem:SetCurrentCharges(item:GetCurrentCharges())
				end
				if newItem:IsToggle() and item:GetToggleState() then
					newItem:ToggleAbility()
				end
				newItem:SetActivated(false)
			end
		end
		illusion:SetHasInventory(false)
		illusion:SetCanSellItems(false)
	end
	

end

-----------------------------------------------------------------------------------------

-- 是否学习了指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
    end
    return base
end
LinkLuaModifier("amalgamation_modifier", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_target", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_target_magic_armor", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_target_phys_armor", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_target", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_bonus", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
---symbiot--
LinkLuaModifier("amalgamation_target_str", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_target_agi", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_target_int", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_target_spell_amp", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_target_ms_bonus", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_target_bonus_attack", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("amalgamation_target_base_attack", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
--
LinkLuaModifier("modifier_carnage", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venom", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
--
LinkLuaModifier("modifier_symbiosis_exhaust", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_symbiosis_exhaust_trigger", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_amalgamation", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_symbiosis_carnage", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_symbiosis_venom", "heroes/hero_wisp/amalgamation", LUA_MODIFIER_MOTION_NONE)

------------------
-- Amalgamation --
------------------
amalgamation = class({})
function amalgamation:GetIntrinsicModifierName() return "modifier_amalgamation" end
function amalgamation:GetBehavior()
	local behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	if self:GetCaster():HasModifier("modifier_super_scepter") then
		behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	end	
	if self:GetCaster():HasModifier("amalgamation_modifier") then
		behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
		if self:GetCaster():HasModifier("modifier_super_scepter") then
			behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE + DOTA_ABILITY_BEHAVIOR_AUTOCAST
		end	
	end
	return behavior
end
function amalgamation:GetManaCost(lvl)
	if self:GetCaster():HasModifier("amalgamation_modifier") then
		return 0
	end
	return 0--self.BaseClass.GetManaCost(self, lvl)
end
function amalgamation:GetAbilityTextureName()
	local has_modifier = self:GetCaster():HasModifier("amalgamation_modifier")
	local super_scept = self:GetCaster():HasModifier("modifier_super_scepter")
	local carnage = self:GetCaster():HasModifier("modifier_symbiosis_carnage")
	local venom = self:GetCaster():HasModifier("modifier_symbiosis_venom")
    if has_modifier and super_scept then
		if venom then
			return "vhenom_passive"
			
		elseif carnage then		
			return "carnage"
		end	
    end
	return "custom/abilities/amalgamation"
end

function amalgamation:OnSpellStart()
	if self:GetCaster():HasModifier("amalgamation_modifier") then
		self:EndSymbiosis()
	else
		self:StartSymbiosis(self:GetCursorTarget())
	end
end
function amalgamation:CastFilterResultTarget(target)
	local caster = self:GetCaster()
	local casterID = caster:GetPlayerOwnerID()
	local targetID = target:GetPlayerOwnerID()
	if caster == target then return UF_FAIL_CUSTOM end
	if caster:HasModifier("amalgamation_target") then return UF_FAIL_CUSTOM end
	if caster:HasModifier("modifier_life_stealer_infest") then return UF_FAIL_CUSTOM end
	if IsServer() and not target:IsOpposingTeam(caster:GetTeamNumber()) and PlayerResource:IsDisableHelpSetForPlayerID(targetID,casterID) then
		return UF_FAIL_DISABLE_HELP
	end

	return UnitFilter(target,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_CHECK_DISABLE_HELP,
		caster:GetTeamNumber())
end

function amalgamation:GetCustomCastErrorTarget(target)
	if self:GetCaster() == target then return "#dota_hud_error_cant_cast_on_self" end
	if self:GetCaster():HasModifier("amalgamation_target") then return "#DOTA_Error_amalgamation_no_inception" end
	if self:GetCaster():HasModifier("modifier_life_stealer_infest") then return "#DOTA_Error_amalgamation_no_inception" end
end

function amalgamation:StartSymbiosis(target)
	local caster = self:GetCaster()
	if caster:HasModifier("amalgamation_target") then return end
	EmitSoundOnLocationWithCaster(caster:GetOrigin(), "Hero_Bane.Nightmare", caster)

	local Modifier = target:AddNewModifier(caster, self, "amalgamation_target", {})
	local SymbiotModifier = caster:AddNewModifier(caster, self, "amalgamation_modifier", {})
	SymbiotModifier:SetHost(target, Modifier)
	Modifier:InitSymbiot(SymbiotModifier)
--	Timers:CreateTimer(FrameTime(), function()
		self:EndCooldown()
		self:StartCooldown(1)
--	end)
end

function amalgamation:EndSymbiosis()
	local SymbiotModifier = self:GetCaster():FindModifierByName("amalgamation_modifier")
	SymbiotModifier:Terminate(nil)
	self:UseResources(false, false, false, true)
end
function amalgamation:OnDestroy()
	self:EndSymbiosis()  
end	

-------------------------
-- Amalgamation Caster --
-------------------------
amalgamation_modifier = class({})
function amalgamation_modifier:IsHidden() return true end
function amalgamation_modifier:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT end
function amalgamation_modifier:AllowIllusionDuplicate() return false end
function amalgamation_modifier:GetModifierModelChange() return "models/development/invisiblebox.vmdl" end
function amalgamation_modifier:GetModifierInvisibilityLevel() return 1 end
function amalgamation_modifier:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA + 11111 end

function amalgamation_modifier:OnCreated(kv)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
--		self.scale = self:GetParent():GetModelScale()
--		self:GetParent():SetModelScale(0.001)
	end
end

function amalgamation_modifier:OnDestroy()
	if IsServer() then
		if self.Modifier ~= nil then self.Modifier:Destroy() end
--		self:GetParent():SetModelScale(self.scale)
		EmitSoundOnLocationWithCaster(self:GetParent():GetOrigin(), "Hero_Bane.Nightmare.End", self:GetParent())
	end
end

function amalgamation_modifier:SetHost(target, Modifier)
	self.Host = target
	self.Modifier = Modifier
	local AbdPos = self.Host:GetAbsOrigin()
--	local up = Vector(0,0,0)
	self:GetParent():SetAbsOrigin(AbdPos)
end

function amalgamation_modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_EVENT_ON_SPENT_MANA,
		MODIFIER_EVENT_ON_SET_LOCATION,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_EVENT_ON_ORDER
	}
end

function amalgamation_modifier:OnOrder(params)
	if params.unit ~= self:GetCaster() then return end
    if not self:GetCaster():HasModifier("modifier_super_scepter") then return end
	if not self:GetCaster():HasModifier("amalgamation_modifier") then return end
	if params.order_type == DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO then
		if params.ability then
			if params.ability:GetAbilityName() ~= "amalgamation" then return end
			local amalga = self:GetCaster():FindAbilityByName("amalgamation")
			if amalga then
				amalga:EndSymbiosis()
			end			
		end		
	end	
end


function amalgamation_modifier:OnStackCountChanged(old)
	if IsServer() then self:GetParent():CalculateStatBonus(true) end
end
function amalgamation_modifier:GetModifierManaBonus()
	if self:GetAbility() then return self:GetStackCount() end
end

function amalgamation_modifier:CheckState()
	if self:GetAbility() then
		local ability = self:GetAbility()
		local state = {
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_FROZEN] = true,
			[MODIFIER_STATE_DISARMED] = not ability:GetAutoCastState(),
			[MODIFIER_STATE_OUT_OF_GAME] = true,
			[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
			[MODIFIER_STATE_INVISIBLE] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = ability:GetAutoCastState(),
		}
		if (self.Host ~= nil) then
			state[MODIFIER_STATE_STUNNED] = self.Host:IsStunned()
			state[MODIFIER_STATE_SILENCED] = self.Host:IsSilenced()
			state[MODIFIER_STATE_MUTED] = self.Host:IsMuted()
			if self.Host:IsCommandRestricted() then 
				state[MODIFIER_STATE_COMMAND_RESTRICTED] = self.Host:IsCommandRestricted()
			end
		end
		return state
	end	
end

function amalgamation_modifier:OnDeath(kv)
	if IsServer() then
		if kv.unit ~= self:GetParent() then return end
		self:Destroy()
	end
end

function amalgamation_modifier:OnTakeDamage(kv)
	if IsServer() then
		if kv.unit ~= self.Host then return end
		if self:GetAbility():GetCooldownTimeRemaining() < 1 then
			self:GetAbility():StartCooldown(1)
		end
	end
end
function amalgamation_modifier:OnSetLocation(kv)
	if IsServer() then
		if kv.unit ~= self:GetParent() then return end
		local casterID = self:GetCaster():GetPlayerOwnerID()
		local targetID = self:GetParent():GetPlayerOwnerID()
		if PlayerResource:IsDisableHelpSetForPlayerID(targetID,casterID) then
			if self:GetAbility():IsCooldownReady() then
				self:Terminate(nil)
			end
		else
			if self.Host ~= nil and not self.Host:HasModifier("modifier_life_stealer_infest") then
				ProjectileManager:ProjectileDodge(self.Host)
				FindClearSpaceForUnit(self.Host,self:GetParent():GetOrigin(),true)
			end
		end
	end
end
function amalgamation_modifier:OnSpentMana(kv)
	if IsServer() then
		local parent = self:GetParent()
		local ability = kv.ability
		if kv.unit ~= parent then return end
		if self.Host == nil then return end
--		if ability and ability:GetAbilityName() == "amalgamation" then return end
		if kv.cost <= 0 then return end
		local casterID = self:GetCaster():GetPlayerOwnerID()
		local targetID = self.Host:GetPlayerOwnerID()
		local mana = self.Host:GetMana()
		if self.Host:GetMana() >= kv.cost then
			self.Host:SpendMana(kv.cost, nil)
		else
			local hpcost = kv.cost - mana
			self.Host:SetMana(0)
			ApplyDamage({
				victim = self.Host,
				attacker = parent,
				damage = hpcost,
				damage_type = DAMAGE_TYPE_PURE,
				ability = nil,
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NON_LETHAL
			})
		end
		parent:SetMana(parent:GetMaxMana())
	end
end

function amalgamation_modifier:Terminate(attacker)
	if attacker then
		self:GetParent():Kill(self:GetAbility(), attacker)
	end
	self:Destroy()
end

function amalgamation_modifier:OnAttackLanded(kv)
	if IsServer() then
		if kv.attacker ~= self:GetParent() then return end
		if self.Host == nil then return end
		self.Modifier:Show(self:GetAbility():GetSpecialValueFor("vis_duration"))
	end
end

function amalgamation_modifier:OnAbilityExecuted(kv)
	if IsServer() then
		if kv.unit ~= self:GetParent() then return end
		if self.Host == nil then return end
		self.Modifier:Show(self:GetAbility():GetSpecialValueFor("vis_duration"))
	end
end

function amalgamation_modifier:OnIntervalThink()
	if IsServer() then
		if not self:GetParent():IsAlive() then self:Terminate(nil) end
		if self.Host == nil then return end
		local AbdPos = self.Host:GetAbsOrigin()
--		local up = Vector(0,0,0)
		self:GetParent():SetAbsOrigin(AbdPos)
		self:SetStackCount(self.Host:GetMaxMana())
	end
end


-------------------------
-- Amalgamation Target --
-------------------------
amalgamation_target = class({})
function amalgamation_target:IsHidden() return false end
function amalgamation_target:AllowIllusionDuplicate() return false end
function amalgamation_target:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT end




function amalgamation_target:OnCreated()
	if IsServer() then
		self:StartIntervalThink(2) --frame time greatlly will influence the Compatibility stacks
	end
end
function amalgamation_target:OnDestroy()
	if IsServer() then
		if self:GetParent():HasModifier("amalgamation_target_magic_armor") then
			self:GetParent():RemoveModifierByName("amalgamation_target_magic_armor")
		end
		if self:GetParent():HasModifier("amalgamation_target_phys_armor") then
			self:GetParent():RemoveModifierByName("amalgamation_target_phys_armor")
		end
		--Symbiosis
		if self:GetParent():HasModifier("amalgamation_target_str") then
			self:GetParent():RemoveModifierByName("amalgamation_target_str")
		end
		if self:GetParent():HasModifier("amalgamation_target_agi") then
			self:GetParent():RemoveModifierByName("amalgamation_target_agi")
		end
		if self:GetParent():HasModifier("amalgamation_target_int") then
			self:GetParent():RemoveModifierByName("amalgamation_target_int")
		end
		if self:GetParent():HasModifier("amalgamation_target_spell_amp") then
			self:GetParent():RemoveModifierByName("amalgamation_target_spell_amp")
		end	
		if self:GetParent():HasModifier("amalgamation_target_ms_bonus") then
			self:GetParent():RemoveModifierByName("amalgamation_target_ms_bonus")
		end
		if self:GetParent():HasModifier("amalgamation_target_bonus_attack") then
			self:GetParent():RemoveModifierByName("amalgamation_target_bonus_attack")
		end	
		if self:GetParent():HasModifier("amalgamation_target_base_attack") then
			self:GetParent():RemoveModifierByName("amalgamation_target_base_attack")
		end	
		if self:GetParent():HasModifier("modifier_symbiosis_exhaust_trigger") then
			self:GetParent():RemoveModifierByName("modifier_symbiosis_exhaust_trigger")
		end				
	end
end
function amalgamation_target:OnIntervalThink()
	if IsServer() then
		if not self:GetAbility() then return end
		if not self:GetParent() then return end
		if not self:GetParent():IsAlive() then return end
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local venom_on = false
		local carnage_on = false
		local marci = false
		local transfrom_duration = ability:GetSpecialValueFor("transfrom_duration")
		local stack_chance = ability:GetSpecialValueFor("symbiot_stack_chance")
		local HostMagicResist = math.floor(self:GetCaster():Script_GetMagicalArmorValue(false, self:GetCaster()) * self:GetAbility():GetSpecialValueFor("magic_armor"))
		local HostArmor = math.floor(self:GetCaster():GetPhysicalArmorValue(false) * self:GetAbility():GetSpecialValueFor("physical_armor") / 100)
		local HostMagicResist_Modifier = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "amalgamation_target_magic_armor", {})
		HostMagicResist_Modifier:SetStackCount(HostMagicResist)

		local HostArmor_Modifier = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "amalgamation_target_phys_armor", {})
		HostArmor_Modifier:SetStackCount(HostArmor)

		local casterID = self:GetCaster():GetPlayerOwnerID()
		local targetID = self:GetParent():GetPlayerOwnerID()
		if PlayerResource:IsDisableHelpSetForPlayerID(targetID, casterID) then
			local amalgamation_modifier = self:GetCaster():FindModifierByName("amalgamation_modifier")
			amalgamation_modifier:Terminate(nil)
		end
		if caster:HasModifier("modifier_super_scepter") then
			--if not _G.symbiosisOn then return end -- "symbiosis" comand will turn off even the gaining stacks
			-- marci SS
			if parent:HasModifier("modifier_super_scepter") then
				if parent:HasModifier("modifier_marci_unleash_flurry") then
					marci = true
				end                                 
			end	
			---		
			if not parent:HasModifier("modifier_venom") then
				parent:AddNewModifier(caster, ability, "modifier_venom", {})
			else
				local venom_modif = parent:FindModifierByName("modifier_venom")
				if venom_modif  then
					if not ability:GetAutoCastState() and (venom_modif:GetStackCount() > 99) then venom_on = true end
					if marci and (venom_modif:GetStackCount() > 99) then venom_on = true end
					if not ability:GetAutoCastState() and RollPercentage(stack_chance) and not (venom_modif:GetStackCount() > 99) then			
						venom_modif:SetStackCount(venom_modif:GetStackCount() + 1)
					end	
				end	
			end	
			if not parent:HasModifier("modifier_carnage") then
				parent:AddNewModifier(caster, ability, "modifier_carnage", {})
			else
				local carnage_modif = parent:FindModifierByName("modifier_carnage")
				if carnage_modif then
					if ability:GetAutoCastState() and (carnage_modif:GetStackCount() > 99) then carnage_on = true end
					if marci and (carnage_modif:GetStackCount() > 99) then carnage_on = true end
					if ability:GetAutoCastState() and RollPercentage(stack_chance) and not (carnage_modif:GetStackCount() > 99) then
						carnage_modif:SetStackCount(carnage_modif:GetStackCount() + 1)
					end	
				end
			end	
			local amalgat = self:GetCaster():FindAbilityByName("amalgatoggle")
			if amalgat then
				if amalgat:GetAutoCastState() then
                    caster:AddNewModifier(caster, self, "modifier_symbiosis_ready", {})    
                else
                    if caster:HasModifier("modifier_symbiosis_ready") then
                        caster:RemoveModifierByName("modifier_symbiosis_ready")
                    end
                end 				
			end
			if parent:HasModifier("modifier_symbiosis_exhaust") then return end
			if not _G.symbiosisOn then return end 
			if not parent:IsHero() then return end
			if not caster:HasModifier("modifier_symbiosis_ready") then return end
			local caster_str = caster:GetStrength()
			local caster_agi = caster:GetAgility()
			local caster_int = caster:GetIntellect()
			local caster_spellamp = math.floor(caster:GetSpellAmplification(false) * ability:GetSpecialValueFor("venom_spellamp"))
			local caster_base_ms = caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed(), false) * (ability:GetSpecialValueFor("carnage_base_ms") / 100)
			local caster_basedmg = caster:GetAttackDamage()
			local caster_greendmg = caster:GetAverageTrueAttackDamage(caster) - caster_basedmg
			if caster_base_ms > 30000 then -- in case dota fixes Io Q 
				caster_base_ms = 30000
			end	

			if (not ability:GetAutoCastState() and venom_on) or (marci and venom_on) then
				if parent and parent:IsAlive() then
					if not parent:HasModifier("modifier_symbiosis_exhaust_trigger") then
						parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_symbiosis_exhaust_trigger", {duration = transfrom_duration})
					end
								
				    ---stats
					local target_str_Modifier = parent:AddNewModifier(caster, ability, "amalgamation_target_str", {})
					target_str_Modifier:SetStackCount(caster_str * (ability:GetSpecialValueFor("venom_str") / 100) )
					local target_agi_Modifier = parent:AddNewModifier(caster, ability, "amalgamation_target_agi", {})
					target_agi_Modifier:SetStackCount(caster_agi * (ability:GetSpecialValueFor("venom_agi") / 100) )
					local target_int_Modifier = parent:AddNewModifier(caster, ability, "amalgamation_target_int", {})
					target_int_Modifier:SetStackCount(caster_int * (ability:GetSpecialValueFor("venom_int") / 100) )
					---stats
					local target_spellamp_Modifier = parent:AddNewModifier(caster, ability, "amalgamation_target_spell_amp", {})
					target_spellamp_Modifier:SetStackCount(caster_spellamp)	
				end			
			end
			if (ability:GetAutoCastState() and carnage_on) or (marci and carnage_on) then
				if parent and parent:IsAlive() then
					if not parent:HasModifier("modifier_symbiosis_exhaust_trigger") then
						parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_symbiosis_exhaust_trigger", {duration = transfrom_duration})
					end
								
					---stats
					local target_str_Modifier = parent:AddNewModifier(caster, ability, "amalgamation_target_str", {})
					target_str_Modifier:SetStackCount(caster_str * (ability:GetSpecialValueFor("carnage_str") / 100) )
					local target_agi_Modifier = parent:AddNewModifier(caster, ability, "amalgamation_target_agi", {})
					target_agi_Modifier:SetStackCount(caster_agi * (ability:GetSpecialValueFor("carnage_agi") / 100) )
					local target_int_Modifier = parent:AddNewModifier(caster, ability, "amalgamation_target_int", {})
					target_int_Modifier:SetStackCount(caster_int * (ability:GetSpecialValueFor("carnage_int") / 100) )
					---stats
					local target_ms_Modifier = parent:AddNewModifier(caster, ability, "amalgamation_target_ms_bonus", {})
					target_ms_Modifier:SetStackCount(caster_base_ms * (ability:GetSpecialValueFor("carnage_base_ms") /100))
					local target_greendmg_Modifier = parent:AddNewModifier(caster, ability, "amalgamation_target_bonus_attack", {})
					target_greendmg_Modifier:SetStackCount((caster_basedmg * (ability:GetSpecialValueFor("carnage_greendmg") / 100) /1000) ) -- /1000 to avoid to high amount stacks
					local target_basedmg_Modifier = parent:AddNewModifier(caster, ability, "amalgamation_target_base_attack", {})
					target_basedmg_Modifier:SetStackCount((caster_greendmg * (ability:GetSpecialValueFor("carnage_basedmg") / 100)/100) )	-- /100 to avoid to high amount stacks							
				end

			end	

		end
	end
end

function amalgamation_target:InitSymbiot(Modifier)
	if IsServer() then
		self.symbiot = Modifier
		self.maxdistance = Modifier:GetAbility():GetSpecialValueFor("range_scepter")
	end
end

function amalgamation_target:Show(time)
	if self:GetParent():IsInvisible() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_dustofappearance", {duration = time})
	end
end

function amalgamation_target:DeclareFunctions()
	return {
	MODIFIER_EVENT_ON_DEATH,
	MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
}
end

function amalgamation_target:OnDeath(kv)
	if IsServer() then
		if kv.unit == self:GetParent() then if self.symbiot ~= nil then self.symbiot:Terminate(kv.attacker) end return end
		if not self:GetParent():IsRealHero() then return end
		if not self:GetCaster():HasScepter() then return end
--		local stat = kv.unit:GetPrimaryAttribute()
		if kv.unit:GetTeam() ~= self:GetParent():GetTeam() then
			local dist = CalcDistanceBetweenEntityOBB(kv.unit, self:GetParent())
			if dist > self.maxdistance then return end
			local amount = self.symbiot:GetAbility():GetSpecialValueFor("stat_scepter")
--			if stat == 0 then
				self:GetParent():ModifyStrength(amount)
--			elseif stat == 1 then
				self:GetParent():ModifyAgility(amount)
--			elseif stat == 2 then
				self:GetParent():ModifyIntellect(amount)
--			end
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "amalgamation_bonus", {})
		end
	end
end

function amalgamation_target:GetModifierTotalPercentageManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("mana_regen") end
end


-----------------------------------
-- Amalgamation Target Reduction --
-----------------------------------
amalgamation_target_magic_armor = class({})
function amalgamation_target_magic_armor:IsHidden() return true end
function amalgamation_target_magic_armor:RemoveOnDeath() return false end
function amalgamation_target_magic_armor:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function amalgamation_target_magic_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end
function amalgamation_target_magic_armor:GetModifierMagicalResistanceBonus()
	if self:GetAbility() then return self:GetStackCount() end
end

amalgamation_target_phys_armor = class({})
function amalgamation_target_phys_armor:IsHidden() return true end
function amalgamation_target_phys_armor:RemoveOnDeath() return false end
function amalgamation_target_phys_armor:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function amalgamation_target_phys_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end
function amalgamation_target_phys_armor:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then return self:GetStackCount() end
end


------------------------
-- Amalgamation Bonus --
------------------------
amalgamation_bonus = class({})
function amalgamation_bonus:RemoveOnDeath() return false end
function amalgamation_bonus:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function amalgamation_bonus:OnCreated(kv)
	if IsServer() then
		self:SetStackCount(1)
	end
end

function amalgamation_bonus:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(self:GetStackCount() + 1)
	end
end

function amalgamation_bonus:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function amalgamation_bonus:OnTooltip()
	if self:GetAbility() then return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stat_scepter") end
end

------------------------
-- Amalgamation Symbiosis target --
------------------------

amalgamation_target_str = class({})
function amalgamation_target_str:IsHidden() return true end
function amalgamation_target_str:RemoveOnDeath() return false end
function amalgamation_target_str:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function amalgamation_target_str:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end
function amalgamation_target_str:GetModifierBonusStats_Strength()
	if self:GetAbility() then return self:GetStackCount() end
end

amalgamation_target_agi = class({})
function amalgamation_target_agi:IsHidden() return true end
function amalgamation_target_agi:RemoveOnDeath() return false end
function amalgamation_target_agi:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function amalgamation_target_agi:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end
function amalgamation_target_agi:GetModifierBonusStats_Agility()
	if self:GetAbility() then return self:GetStackCount() end
end

amalgamation_target_int = class({})
function amalgamation_target_int:IsHidden() return true end
function amalgamation_target_int:RemoveOnDeath() return false end
function amalgamation_target_int:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function amalgamation_target_int:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function amalgamation_target_int:GetModifierBonusStats_Intellect()
	if self:GetAbility() then return self:GetStackCount() end
end

amalgamation_target_spell_amp = class({})
function amalgamation_target_spell_amp:IsHidden() return true end
function amalgamation_target_spell_amp:RemoveOnDeath() return false end
function amalgamation_target_spell_amp:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function amalgamation_target_spell_amp:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
function amalgamation_target_spell_amp:GetModifierSpellAmplify_Percentage()
	if self:GetAbility() then return self:GetStackCount() end
end

amalgamation_target_ms_bonus = class({})
function amalgamation_target_ms_bonus:IsHidden() return true end
function amalgamation_target_ms_bonus:RemoveOnDeath() return false end
function amalgamation_target_ms_bonus:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function amalgamation_target_ms_bonus:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end
function amalgamation_target_ms_bonus:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then return self:GetStackCount() end
end

amalgamation_target_bonus_attack = class({})
function amalgamation_target_bonus_attack:IsHidden() return true end
function amalgamation_target_bonus_attack:RemoveOnDeath() return false end
function amalgamation_target_bonus_attack:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function amalgamation_target_bonus_attack:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end
function amalgamation_target_bonus_attack:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetStackCount() * 1000 end
end

amalgamation_target_base_attack = class({})
function amalgamation_target_base_attack:IsHidden() return true end
function amalgamation_target_base_attack:RemoveOnDeath() return false end
function amalgamation_target_base_attack:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function amalgamation_target_base_attack:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end
function amalgamation_target_base_attack:GetModifierBaseAttack_BonusDamage()
	if self:GetAbility() then return self:GetStackCount() * 100 end
end


---Transfrom Stacks--- 100 = On

modifier_venom = class({})
function modifier_venom:IsHidden() return false end
function modifier_venom:RemoveOnDeath() return false end
function modifier_venom:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_venom:GetTexture()
	return "vhenom_passive"
end


modifier_carnage = class({})
function modifier_carnage:IsHidden() return false end
function modifier_carnage:RemoveOnDeath() return false end
function modifier_carnage:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_carnage:GetTexture() return "carnage" end


----Symbiosis Exhaust---- target
modifier_symbiosis_exhaust = class({})
function modifier_symbiosis_exhaust:IsHidden() return false end
function modifier_symbiosis_exhaust:IsDebuff() return true end
function modifier_symbiosis_exhaust:GetTexture() return "modifier_exhaust" end
function modifier_symbiosis_exhaust:RemoveOnDeath() return false end
function modifier_symbiosis_exhaust:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_symbiosis_exhaust:OnCreated()
	if IsServer() then
		if self:GetParent():HasModifier("amalgamation_target") then
			self:GetCaster():FindAbilityByName("amalgamation"):EndSymbiosis()
		end	
	end	
end	
---Duration -- Exhaust trigger--
modifier_symbiosis_exhaust_trigger = class({})
function modifier_symbiosis_exhaust_trigger:IsHidden() return false end
function modifier_symbiosis_exhaust_trigger:IsDebuff() return true end
function modifier_symbiosis_exhaust_trigger:GetTexture()
	if self:GetCaster():HasModifier("modifier_symbiosis_carnage") then
		return "carnage"
	elseif self:GetCaster():HasModifier("modifier_symbiosis_venom") then
		return "venom_passive"
	end
end
function modifier_symbiosis_exhaust_trigger:RemoveOnDeath() return false end
function modifier_symbiosis_exhaust_trigger:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_symbiosis_exhaust_trigger:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}
end

function modifier_symbiosis_exhaust_trigger:GetModifierModelChange()
	if IsServer() then 
		if self:GetAbility() and self:GetAbility():GetAutoCastState() then	
			return "models/heroes/hero_carnage/carnage.vmdl"
		else
			return "models/heroes/hero_venom/venom.vmdl"
		end
	end	
end

function modifier_symbiosis_exhaust_trigger:OnDestroy()
	if not IsServer() then return end
	local parent = self:GetParent()
	if self:GetAbility() and parent and not parent:IsNull() and parent:IsAlive() then
		if not parent:HasModifier("modifier_symbiosis_exhaust") then
			local exhaust_duration = self:GetAbility():GetSpecialValueFor("exhaust_duration") * (1 - parent:GetStatusResistance())
			if exhaust_duration < 25 then 
				exhaust_duration = 25
			end	
			parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_symbiosis_exhaust", {duration = exhaust_duration})
		end
	end	
end



modifier_amalgamation = class({})
function modifier_amalgamation:IsHidden() return true end
function modifier_amalgamation:OnCreated()
	self:StartIntervalThink(FrameTime())
end
function modifier_amalgamation:OnIntervalThink()
	if not IsServer() then return end
	if self:GetAbility():GetAutoCastState() then
		if not self:GetCaster():HasModifier("modifier_symbiosis_carnage") then
			if self:GetCaster():HasModifier("modifier_symbiosis_venom") then
				self:GetCaster():RemoveModifierByName("modifier_symbiosis_venom")
			end	
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_symbiosis_carnage", {})
				
		end
	else
		if not self:GetCaster():HasModifier("modifier_symbiosis_venom") then
			if self:GetCaster():HasModifier("modifier_symbiosis_carnage") then
				self:GetCaster():RemoveModifierByName("modifier_symbiosis_carnage")
			end	
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_symbiosis_venom", {})
				
		end
	end
end

modifier_symbiosis_carnage = class({})
function modifier_symbiosis_carnage:IsHidden() return true end
function modifier_symbiosis_carnage:IsPurgable() return false end
function modifier_symbiosis_carnage:RemoveOnDeath() return false end

modifier_symbiosis_venom = class({})
function modifier_symbiosis_venom:IsHidden() return true end
function modifier_symbiosis_venom:IsPurgable() return false end
function modifier_symbiosis_venom:RemoveOnDeath() return false end

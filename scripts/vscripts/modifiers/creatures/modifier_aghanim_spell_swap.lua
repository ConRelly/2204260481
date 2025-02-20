modifier_aghanim_spell_swap = class({})

---------------------------------------------------------------------------

function modifier_aghanim_spell_swap:IsHidden()
	return false
end

---------------------------------------------------------------------------

function modifier_aghanim_spell_swap:IsPurgable()
	return false
end

-----------------------------------------------------------------------------------------

function modifier_aghanim_spell_swap:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap:OnCreated( kv )
	if IsServer() then
		local parent = self:GetParent()
		if parent and not parent:IsNull() then
			local skills_nr = 0
			for i=0, 31 do
				local hAbility = self:GetParent():GetAbilityByIndex( i )
				if hAbility and not hAbility:IsCosmetic( nil ) then
					--print( "Counting Ability: ".. skills_nr .. " ".. hAbility:GetAbilityName() .. "  slot " .. i )
					skills_nr = skills_nr + 1
				end
			end
			print("number skills " .. skills_nr)
			if skills_nr < 32 then 
				self:DisableSpell()
			end	
		end		
	end
end

----------------------------------------------------------------------------------

function modifier_aghanim_spell_swap:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_DEATH,
	}

	return funcs
end

--------------------------------------------------------------------------------


function modifier_aghanim_spell_swap:OnDeath( params )
	if IsServer() then
		if params.unit == self.hCrystal then
			if self:IsNull() then return end
			self:Destroy()
		end
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap:DisableSpell()
	if IsServer() then
		local NormalAbilities = {}
		local exclude_table = {
			--mjz_ember_spirit_sleight_of_fist = true,
			--spirit_breaker_greater_bash = true,
			--lion_custom_finger_of_death = true,
			--mjz_finger_of_death = true,
			--mjz_lina_laguna_blade = true,
			keeper_of_the_light_illuminate = true,
			keeper_of_the_light_spirit_form_illuminate = true,
			keeper_of_the_light_blinding_light = true,
			keeper_of_the_light_recall = true,
			temporary_slot_used = true,
			doom_bringer_empty2 = true,
			lesser_cancel = true,
			divine_cancel = true,
		}		
		for i=0, 31 do
			local hAbility = self:GetParent():GetAbilityByIndex( i )
			if hAbility and not hAbility:IsCosmetic( nil ) and not hAbility:IsAttributeBonus() and hAbility:GetAssociatedPrimaryAbilities() == nil and not hAbility:IsHidden() and not hAbility.bAghDisabled == true and not hAbility.bAghDummy == true and hAbility:IsActivated() and not exclude_table[hAbility:GetAbilityName()] then
				print( "considering ability for disable: " .. hAbility:GetAbilityName() )
				table.insert( NormalAbilities, hAbility )
			end
		end

		local nNextAghDummy = nil
		for j=1,4 do		
			local szName = tostring( "aghanim_empty_spell" .. j )
			local hDummyAbility = self:GetParent():FindAbilityByName( szName )
			nNextAghDummy = j
			if not hDummyAbility then
				break
			end
		end	

	
		local nIndexToDisable = math.random( 1, #NormalAbilities )
		local hAbilityToDisable = NormalAbilities[ nIndexToDisable ]

		if nNextAghDummy == nil or hAbilityToDisable == nil then
			if not self:IsNull() then
				self:Destroy()
			end	
			print( "Cannot disable spell:" )
			print( "Next agh dummy: " .. nNextAghDummy )
			if hAbilityToDisable ~= nil then
				print( "hAbilityToDisable " .. hAbilityToDisable:GetAbilityName() )
			end
			return
		end	

		local hNewDummyAbility = self:GetParent():AddAbility( tostring( "aghanim_empty_spell" .. nNextAghDummy ) )
		if hNewDummyAbility then
			print( "adding dummy ability for disable: " .. hNewDummyAbility:GetAbilityName() )
			hNewDummyAbility:UpgradeAbility( true )
			hNewDummyAbility:SetActivated( true )
			hNewDummyAbility.bAghDummy = true
			hNewDummyAbility.nOriginalIndex = hNewDummyAbility:GetAbilityIndex()
		end
		

		hAbilityToDisable.bAghDisabled = true
		print( "disabling " .. hAbilityToDisable:GetAbilityName() )
		if hAbilityToDisable:GetToggleState() then
			--print( "toggling ability off" )
			hAbilityToDisable:OnToggle()
		end

		hAbilityToDisable:SetActivated( false )
		hAbilityToDisable.nOriginalIndex = hAbilityToDisable:GetAbilityIndex()

		self.hDisabledAbility = hAbilityToDisable
		self.hDummyAbility = hNewDummyAbility

		self:GetParent():SwapAbilities( self.hDisabledAbility:GetAbilityName(), self.hDummyAbility:GetAbilityName(), false, true )
		self.hDummyAbility:SetActivated( false )

		--self.hDisabledAbility:SetAbilityIndex( self.hDummyAbility.nOriginalIndex )
		--self.hDisabledAbility:SetHidden( true )
		--self.hDummyAbility:SetAbilityIndex( self.hDisabledAbility.nOriginalIndex )
		--self.hDummyAbility:SetHidden( false )

		self.hCrystal = CreateUnitByName( "npc_dota_boss_aghanim_crystal", self:GetCaster():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber() )
		if self.hCrystal then
			self.hCrystal:SetControllableByPlayer( self:GetCaster():GetPlayerOwnerID(), false )
			self.hCrystal:SetOwner( self:GetCaster() )
			self.hCrystal:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_aghanim_spell_swap_crystal", {} )
		end
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap:RestoreSpell()
	if IsServer() then
		if self.hDisabledAbility and self.hDummyAbility and IsValidEntity(self.hDisabledAbility) and IsValidEntity(self.hDummyAbility) then
			self.hDisabledAbility:SetActivated( true )
			self.hDisabledAbility.bAghDisabled = false
			self.hDisabledAbility:SetHidden( false )
			self:GetParent():RemoveAbilityFromIndexByName( self.hDisabledAbility:GetAbilityName() )
			self:GetParent():SetAbilityByIndex( self.hDisabledAbility, self.hDisabledAbility.nOriginalIndex ) -- this destroys the dummy spell
			
			if self.hCrystal then
				self.hCrystal:AddEffects( EF_NODRAW )
				if self.hCrystal:IsAlive() then
					self.hCrystal:ForceKill( false )
				end

				local nFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_crystal_destroy.vpcf", PATTACH_CUSTOMORIGIN, nil )
				ParticleManager:SetParticleControl( nFXIndex, 0, self.hCrystal:GetAbsOrigin() )
				ParticleManager:ReleaseParticleIndex( nFXIndex )

				EmitSoundOn( "Hero_Wisp.Spirits.Destroy", self.hCrystal )

				local nFXIndex2 = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_crystal_spellswap_replenish.vpcf", PATTACH_CUSTOMORIGIN, nil )	
				ParticleManager:SetParticleControlEnt( nFXIndex2, 0, self.hCrystal, PATTACH_POINT_FOLLOW, "attach_attack1", self.hCrystal:GetAbsOrigin(), true )
				ParticleManager:SetParticleControlEnt( nFXIndex2, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
				ParticleManager:ReleaseParticleIndex( nFXIndex2 )
			end
		end
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap:OnDestroy()
	if IsServer() then
		self:RestoreSpell()
	end
end


-------------------------------------------
-- Coup De Grace
-------------------------------------------

imba_phantom_assassin_coup_de_grace = class({})

LinkLuaModifier("modifier_imba_coup_de_grace", "heroes/hero_phantom_assassin/coup_de_grace", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_coup_de_grace_crit", "heroes/hero_phantom_assassin/coup_de_grace", LUA_MODIFIER_MOTION_NONE)

function imba_phantom_assassin_coup_de_grace:GetIntrinsicModifierName()
  return "modifier_imba_coup_de_grace"
end


-------------------------------------------
-- Coup De Grace modifier
-------------------------------------------

modifier_imba_coup_de_grace = class({})

function modifier_imba_coup_de_grace:GetTexture()
	return "coup_de_grace_imba"
end
function modifier_imba_coup_de_grace:AllowIllusionDuplicate()
	return true
end	

function modifier_imba_coup_de_grace:OnCreated()	
	-- Ability properties
	if self:GetAbility() then
		self.caster = self:GetCaster()
		--if self.caster:IsIllusion() then return end
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
	--	self.ps_coup_modifier = "modifier_imba_phantom_strike_coup_de_grace"			
		self.modifier_stacks = "modifier_imba_coup_de_grace_crit"

		-- Ability specials
		self.crit_chance = self.ability:GetSpecialValueFor("crit_chance")								
	--	self.crit_increase_duration = self.ability:GetSpecialValueFor("crit_increase_duration")		 			
		self.crit_bonus = self.ability:GetSpecialValueFor("crit_bonus")
		self.crit_stack_mult = self.ability:GetSpecialValueFor("crit_increase_mult")

		if IsServer() then
			local caster = self:GetCaster()
			local parent = self:GetParent()
			local ability = self:GetAbility()
			if parent:IsIllusion() or parent:HasModifier("modifier_arc_warden_tempest_double") then
				
				local mod1 = "modifier_imba_coup_de_grace"
			-- print("ilusion")
				local owner = PlayerResource:GetSelectedHeroEntity(parent:GetPlayerOwnerID())
				if owner then       
					if parent:HasModifier(mod1) then
						local modifier1 = parent:FindModifierByName(mod1)
						if owner:HasModifier(mod1) then
							local modifier2 = owner:FindModifierByName(mod1)
							modifier1:SetStackCount(modifier2:GetStackCount())
						end	
						--print("illusion nevermore2")
					end    
				end    
			end
		end
	end		
end

function modifier_imba_coup_de_grace:OnRefresh()
	self:OnCreated()
end

function modifier_imba_coup_de_grace:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_imba_coup_de_grace:OnTooltip() return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("crit_increase_mult") end

function modifier_imba_coup_de_grace:GetModifierPreAttack_CriticalStrike(keys)	
	if IsServer() then
		--if self.caster:IsIllusion() then return end		
		local target = keys.target							-- TALENT: +8 sec Coup de Grace bonus damage duration
--		local crit_duration = self.crit_increase_duration + self.caster:FindTalentValue("special_bonus_imba_phantom_assassin_7")
		local crit_chance_total = self.crit_chance
		local crit_stack_mult = self.crit_stack_mult

		-- Ignore crit for buildings
		if target:IsBuilding() then 
			return end      

        -- if we have phantom strike modifier, apply bonus percentage to our crit_chance        

        if RollPercentage(crit_chance_total) then        				

			
			StartSoundEvent("Hero_PhantomAssassin.CoupDeGrace", target)
			local responses = {"phantom_assassin_phass_ability_coupdegrace_01",
				"phantom_assassin_phass_ability_coupdegrace_02",
				"phantom_assassin_phass_ability_coupdegrace_03",
				"phantom_assassin_phass_ability_coupdegrace_04"
			}
--			self.caster:EmitCasterSound("npc_dota_hero_phantom_assassin",responses, 50, DOTA_CAST_SOUND_FLAG_BOTH_TEAMS, 20,"coup_de_grace")

			-- If the caster doesn't have the stacks modifier, give it to him 
--			if not self.caster:HasModifier(self.modifier_stacks) then
--				self.caster:AddNewModifier(self.caster, self.ability, self.modifier_stacks, {duration = crit_duration})
--			end


			-- TALENT: +100% Coup de Grace crit damage			
			local crit_bonus = self.crit_bonus + self:GetStackCount()*crit_stack_mult
			
			-- increment multiplayer stacks
			-- Mark the attack as a critical in order to play the bloody effect on attack landed
			self.crit_strike = true
            return crit_bonus
		else
			-- If this attack wasn't a critical strike, remove possible markers from it.
			self.crit_strike = false
        end

        return nil        
	end
end

function modifier_imba_coup_de_grace:OnAttackLanded(keys)
	if IsServer() then
		local target = keys.target
		local attacker = keys.attacker
		
		--if target:GetUnitName() == "npc_dota_hero_target_dummy" then
		--	return
		--end
		
		--if target:IsBuilding() then 
		--	return
		--end   
			
		-- Only apply if the attacker is the caster and it was a critical strike
		if self:GetCaster() == attacker and self.crit_strike then
			
			self:IncrementStackCount()
		
			-- If that attack was marked as a critical strike, apply the particles
			--local coup_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, attacker)			
			--ParticleManager:SetParticleControlEnt(coup_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			--ParticleManager:SetParticleControlEnt(coup_pfx, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", target:GetAbsOrigin(), true)
			--ParticleManager:ReleaseParticleIndex(coup_pfx)
		end			
	end
end

function modifier_imba_coup_de_grace:IsPassive() return true end

function modifier_imba_coup_de_grace:IsHidden()	
	local stacks = self:GetStackCount()
	if stacks > 0 then
		return false
	end

	return true 
end


modifier_imba_coup_de_grace_crit = class({})

function modifier_imba_coup_de_grace_crit:OnCreated(params)    
        -- Ability properties
        self.caster = self:GetCaster()
        self.ability = self:GetAbility()
        self.parent = self:GetParent()        

        -- Ability specials
        self.crit_increase_duration = params.duration
        self.crit_increase_damage = self.ability:GetSpecialValueFor("crit_increase_damage")        

    if IsServer() then
        -- Initialize table
        self.stacks_table = {}        

        -- Start thinking
        self:StartIntervalThink(0.1)
    end
end

function modifier_imba_coup_de_grace_crit:OnIntervalThink()
    if IsServer() then
        -- Check if there are any stacks left on the table
        if #self.stacks_table > 0 then

            -- For each stack, check if it is past its expiration time. If it is, remove it from the table
            for i = #self.stacks_table, 1, -1 do
                if self.stacks_table[i] + self.crit_increase_duration < GameRules:GetGameTime() then
                    table.remove(self.stacks_table, i)                          
                end
            end
            
            -- If after removing the stacks, the table is empty, remove the modifier.
            if #self.stacks_table == 0 then
				if self:IsNull() then return end
                self:Destroy()

            -- Otherwise, set its stack count
            else
                self:SetStackCount(#self.stacks_table)
            end

            -- Recalculate bonus based on new stack count
           self:GetParent():CalculateStatBonus(false)

        -- If there are no stacks on the table, just remove the modifier.
        else
			if self:IsNull() then return end
            self:Destroy()
        end
    end
end

function modifier_imba_coup_de_grace_crit:OnRefresh()
    if IsServer() then
        -- Insert new stack values
        table.insert(self.stacks_table, GameRules:GetGameTime())
    end
end

function modifier_imba_coup_de_grace_crit:IsHidden() return false end
function modifier_imba_coup_de_grace_crit:IsPurgable() return true end
function modifier_imba_coup_de_grace_crit:IsDebuff() return false end


function modifier_imba_coup_de_grace_crit:DeclareFunctions()
    local decFunc = {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}

    return decFunc
end

function modifier_imba_coup_de_grace_crit:GetModifierPreAttack_BonusDamage()	
 	return self.crit_increase_damage * self:GetStackCount()
end
--[[
LinkLuaModifier("modifier_triple_blow_passive", "heroes/hero_phantom_assassin/coup_de_grace", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_triple_blow_haste", "heroes/hero_phantom_assassin/coup_de_grace", LUA_MODIFIER_MOTION_NONE)
-------------------------------------------

imba_phantom_assassin_triple_blow = class({})

-------------------------------------------
function imba_phantom_assassin_triple_blow:GetIntrinsicModifierName()
    return "modifier_triple_blow_passive"
end

-------------------------------------------
modifier_triple_blow_passive = class({})
function modifier_triple_blow_passive:IsDebuff() return false end
function modifier_triple_blow_passive:IsHidden() return true end
function modifier_triple_blow_passive:IsPermanent() return true end
function modifier_triple_blow_passive:IsPurgable() return false end
function modifier_triple_blow_passive:IsPurgeException() return false end
function modifier_triple_blow_passive:IsStunDebuff() return false end
function modifier_triple_blow_passive:RemoveOnDeath() return false end


function modifier_triple_blow_passive:DeclareFunctions()
    local decFuns =
    {
		MODIFIER_EVENT_ON_ATTACK_START
	}
    return decFuns
end



function modifier_triple_blow_passive:OnAttackStart(keys)
	local item = self:GetAbility()
	local parent = self:GetParent()
	if item then
		if (keys.attacker == parent) and (parent:IsRealHero() or parent:IsClone()) then
			if item:IsCooldownReady() then
				parent:AddNewModifier(parent, item, "modifier_triple_blow_haste", {})
				item:UseResources(false,false,true)			
			end
		end
	end
end
-------------------------------------------
modifier_triple_blow_haste = class({})
function modifier_triple_blow_haste:IsDebuff() return false end
function modifier_triple_blow_haste:IsHidden() return true end
function modifier_triple_blow_haste:IsPurgable() return false end
function modifier_triple_blow_haste:IsPurgeException() return false end
function modifier_triple_blow_haste:IsStunDebuff() return false end
function modifier_triple_blow_haste:RemoveOnDeath() return true end
-------------------------------------------
function modifier_triple_blow_haste:OnCreated()
	local item = self:GetAbility()
	self.parent = self:GetParent()
	if item then
		local current_speed = self.parent:GetIncreasedAttackSpeed()
		current_speed = current_speed * 2

		local max_hits = item:GetSpecialValueFor("max_hits")
		self:SetStackCount(max_hits)
		self.attack_speed_buff = math.max(item:GetSpecialValueFor("attack_speed_buff"), current_speed)
	end
end

function modifier_triple_blow_haste:DeclareFunctions()
    local decFuns =
    {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK
    }
    return decFuns
end

function modifier_triple_blow_haste:OnAttack(keys)
	if self.parent == keys.attacker then
		
		-- If the target is a deflector, do nothing
	
		if self:GetStackCount() == 1 then
			self:Destroy()
			return nil
		end

		self:DecrementStackCount()
	end
end

function modifier_triple_blow_haste:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed_buff
end
-------------------------------------------
]]

modifier_mjz_spell_lifesteal_unique = class({})
local modifier_class = modifier_mjz_spell_lifesteal_unique

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end


function modifier_class:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

if IsServer() then


	function modifier_class:OnCreated()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		-- self.lifesteal = self.ability:GetSpecialValueFor("lifesteal") * 0.01
		self.lifesteal = self:GetStackCount()
		self.particle_name = "particles/items3_fx/octarine_core_lifesteal.vpcf"
	end

	function modifier_class:OnTakeDamage(keys)
		if self.parent == keys.attacker and keys.unit ~= self.parent then
			local lifesteal = self:GetStackCount() * 0.01
			if lifesteal == 0 then return end
			if self:_CanHeal(keys) then
				-- print("heal :" .. keys.original_damage * lifesteal)
				self.parent:Heal(keys.original_damage * lifesteal, self.ability)
				ParticleManager:CreateParticle(self.particle_name, PATTACH_ABSORIGIN_FOLLOW, self.parent)
			end
		end
	end

	function modifier_class:_CanHeal( keys )
		local ability = keys.inflictor
		if keys.damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
			if keys.damage_type == DAMAGE_TYPE_PHYSICAL then
				if ability then
					-- return true
					local behavior = ability:GetBehavior()
					if self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET ) or 
						self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET ) or
						self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_POINT ) or
						self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_AOE )
					then
						return true
					end
				end
				return false
			end
			return true
		end
		return false
	end

	-- Helper: Flags
	function modifier_class:FlagExist(a,b)--Bitwise Exist
		local p,c,d=1,0,b
		while a>0 and b>0 do
			local ra,rb=a%2,b%2
			if ra+rb>1 then c=c+p end
			a,b,p=(a-ra)/2,(b-rb)/2,p*2
		end
		return c==d
	end
end


-------------------------------------------------

modifier_mjz_spell_lifesteal_octarine_core = class(modifier_mjz_spell_lifesteal_unique)
-- modifier_mjz_spell_lifesteal_unique_3 = class(modifier_mjz_spell_lifesteal_unique)
-- modifier_mjz_spell_lifesteal_unique_4 = class(modifier_mjz_spell_lifesteal_unique)
-- modifier_mjz_spell_lifesteal_unique_5 = class(modifier_mjz_spell_lifesteal_unique)

modifier_mjz_spell_lifesteal = class(modifier_mjz_spell_lifesteal_unique)
function modifier_mjz_spell_lifesteal:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end



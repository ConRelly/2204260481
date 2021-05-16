
modifier_mjz_phoenix_supernova_caster = class({})
local modifier_class = modifier_mjz_phoenix_supernova_caster

function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

function modifier_class:CheckState() 
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] 		= true,
		[MODIFIER_STATE_STUNNED]					= true,
		[MODIFIER_STATE_INVULNERABLE]				= true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]			= true,
		[MODIFIER_STATE_OUT_OF_GAME]				= true,
		[MODIFIER_STATE_NO_HEALTH_BAR]				= true,
		-- [MODIFIER_STATE_DISARMED] 			= true,
		-- [MODIFIER_STATE_STUNNED] 			= true,
		-- [MODIFIER_STATE_FLYING]				= true,

	}
	return state
end

-- function modifier_class:DeclareFunctions()
-- 	return {
-- 	}
-- end


if IsServer() then
	function modifier_class:OnCreated(table)
		local parent = self:GetParent()
		local caster = parent
		local ability = self:GetAbility()
		self.radius = ability:GetSpecialValueFor("aura_radius")
		self.delay = 0.25  -- ability:GetSpecialValueFor("tree_destroy_delay")
		self.trees = {}

		local particleName = "particles/units/heroes/hero_phoenix/phoenix_supernova_start.vpcf"
		local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, parent )
		ParticleManager:SetParticleControlEnt( pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true )
		ParticleManager:ReleaseParticleIndex(pfx)

		parent:AddNoDraw()

		self:StartIntervalThink(0.25)
	end


	function modifier_class:OnDestroy()
		local parent = self:GetParent()
		parent:RemoveNoDraw()
	end

	function modifier_class:OnIntervalThink()
		local trees = GridNav:GetAllTreesAroundPoint( self:GetParent():GetAbsOrigin(), self.radius, true )
		for _, tree in ipairs( trees ) do
			if tree:IsStanding() then
				if not self.trees[tree] then
					self.trees[tree] = 0
				else
					self.trees[tree] = self.trees[tree] + 0.25
					if self.trees[tree] >= self.delay then
						self.trees[tree] = nil
						tree:CutDown( self:GetParent():GetTeam() )
					end
				end
			end
		end
	end

end



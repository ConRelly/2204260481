

LinkLuaModifier("modifier_mjz_campfire", "abilities/ability_campfire.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_campfire_hidden", "abilities/ability_campfire.lua", LUA_MODIFIER_MOTION_NONE)

ability_campfire = class({})
local ability_class = ability_campfire

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_campfire"
end


modifier_mjz_campfire = class({})

function modifier_mjz_campfire:IsHidden() return true end
function modifier_mjz_campfire:IsPurgable() return false end

function modifier_mjz_campfire:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_EVENT_ON_ATTACKED,
	}

	return funcs
end

function modifier_mjz_campfire:CheckState() 
    return {
        [MODIFIER_STATE_NOT_ON_MINIMAP] 		= true,
		[MODIFIER_STATE_ROOTED]         		= true,
		[MODIFIER_STATE_MAGIC_IMMUNE] 			= true,
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY]  	= true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]		= true,
    } 
end

function modifier_mjz_campfire:OnCreated()
	self.vOffset = Vector(0, 0, 50)
	self.active = false
	self.duration = 180
	self.vision_range = 2000 -- 900
	if IsServer() then
		self:StartIntervalThink(0.5)
		--self:GetParent():SetCustomHealthLabel("Hit campfire for vision!", 200, 0, 0)
	end
end

function modifier_mjz_campfire:OnIntervalThink()
	if not self:GetParent():HasModifier("modifier_invulnerable") then
		self.active = false
	end

	if self.active == false then
		if self.nFXIndex then
			ParticleManager:DestroyParticle(self.nFXIndex, false)
			ParticleManager:ReleaseParticleIndex(self.nFXIndex)
			self.nFXIndex = nil
		end
	end
end

function modifier_mjz_campfire:OnAttacked(kv)
	if IsServer() then
		if kv.target ~= self:GetParent() then
			return
		end
		local parent = self:GetParent()
		self.nFXIndex = ParticleManager:CreateParticle("particles/act_2/campfire_flame.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(self.nFXIndex, 2, self:GetCaster():GetOrigin() + self.vOffset)
		AddFOWViewer(kv.attacker:GetTeamNumber(), parent:GetAbsOrigin(), self.vision_range, self.duration, true)
		parent:AddNewModifier(parent, nil, "modifier_invulnerable", {duration = self.duration})
		parent:AddNewModifier(parent, nil, "modifier_mjz_campfire_hidden", {duration = self.duration})
		self.active = true
	end
end

function modifier_mjz_campfire:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_mjz_campfire:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_mjz_campfire:GetAbsoluteNoDamagePure()
	return 1
end



modifier_mjz_campfire_hidden = class({})

function modifier_mjz_campfire_hidden:IsHidden() return true end
function modifier_mjz_campfire_hidden:IsPurgable() return false end


function modifier_mjz_campfire_hidden:CheckState() 
    return {
        [MODIFIER_STATE_OUT_OF_GAME] 		= true,
    } 
end


modifier_tower_rock_golem = class({})
local modifier = modifier_tower_rock_golem

function modifier:IsHidden() return true end
function modifier:IsPurgable() return false end

function modifier:CheckState() 
    return {
        -- [MODIFIER_STATE_NOT_ON_MINIMAP] 		= true,
        -- [MODIFIER_STATE_FROZEN]                 = true,
        [MODIFIER_STATE_ROOTED]         		= true,
		[MODIFIER_STATE_MAGIC_IMMUNE] 			= true,
		-- [MODIFIER_STATE_LOW_ATTACK_PRIORITY]  	= true,
		-- [MODIFIER_STATE_NO_UNIT_COLLISION]		= true,
    } 
end

if IsServer() then
    
    function modifier:DeclareFunctions() 
        return { 
            -- MODIFIER_PROPERTY_MODEL_CHANGE
        }
    end
    
    function modifier:GetModifierModelChange()
        return self.targetModel
    end

    function modifier:OnCreated(table)
        -- self:OnIntervalThink()
        -- self:StartIntervalThink(60 * 5)
    end

    function modifier:OnIntervalThink()
        local parent = self:GetParent()
        -- local playerID = parent:GetPlayerOwnerID()
        local modelName = "models/props_structures/rock_golem/tower_radiant_rock_golem.vmdl"
        local pModelName = "particles/econ/world/towers/rock_golem/radiant_rock_golem_attack.vpcf"
        -- "DestructionEffect"	"particles/econ/world/towers/rock_golem/radiant_rock_golem_destruction.vpcf"
        if parent:GetModelName() ~= modelName then
            self.targetModel = modelName
			parent:SetOriginalModel( modelName )
            parent:SetModel(modelName)
            parent:SetRangedProjectileName(pModelName)
        end

        if not parent:HasModifier("modifier_rock_golem_animations") then
            parent:AddNewModifier(parent, nil, "modifier_rock_golem_animations", {})
        end
    end
end

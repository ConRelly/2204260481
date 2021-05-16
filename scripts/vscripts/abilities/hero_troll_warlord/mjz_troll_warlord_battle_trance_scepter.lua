
LinkLuaModifier("modifier_mjz_troll_warlord_battle_trance_scepter","abilities/hero_troll_warlord/mjz_troll_warlord_battle_trance_scepter.lua", LUA_MODIFIER_MOTION_NONE)


mjz_troll_warlord_battle_trance_scepter = class({})

function mjz_troll_warlord_battle_trance_scepter:GetIntrinsicModifierName()
    return "modifier_mjz_troll_warlord_battle_trance_scepter"
end

function mjz_troll_warlord_battle_trance_scepter:OnSpellStart( ... )
	if not IsServer() then return end

	local ability = self
	local caster = self:GetCaster()

	if not caster:HasScepter() then
		ability:EndCooldown()
		return 
	end

	local ab_bt = caster:FindAbilityByName("mjz_troll_warlord_battle_trance")
	if ab_bt and ab_bt:IsFullyCastable() then
		local cooldown = ab_bt:GetCooldown(ab_bt:GetLevel() - 1)
		cooldown = cooldown * caster:GetCooldownReduction()
		ab_bt:EndCooldown()
        ab_bt:StartCooldown(cooldown)

		ab_bt:CastBattleTrance_Friendly()
	end
end


---------------------------------------------------------------------------------------

modifier_mjz_troll_warlord_battle_trance_scepter = class({})
local modifier_class = modifier_mjz_troll_warlord_battle_trance_scepter

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
    function modifier_class:OnCreated(table)
        self:StartIntervalThink(0.5)
    end
    function modifier_class:OnIntervalThink(table)
        local ability = self:GetAbility()
        local parent = self:GetParent()
        local IsActivated = ability:IsActivated()

        if parent:HasScepter() then
            if not IsActivated then
                ability:SetActivated(true)
            end
        else
            if IsActivated then
                ability:SetActivated(false)
            end
        end
    end

end
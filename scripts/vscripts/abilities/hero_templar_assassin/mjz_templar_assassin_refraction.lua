LinkLuaModifier("modifier_mjz_templar_assassin_refraction_buff", "modifiers/hero_templar_assassin/modifier_mjz_templar_assassin_refraction_buff.lua", LUA_MODIFIER_MOTION_NONE)

mjz_templar_assassin_refraction = class({})
local ability_class = mjz_templar_assassin_refraction

function ability_class:IsRefreshable() return true end
function ability_class:IsStealable() return true end	-- 是否可以被法术偷取。


if IsServer() then
	function ability_class:OnSpellStart()
		local ability = self
		local caster = self:GetCaster()
		local duration = ability:GetSpecialValueFor('duration')
		local modifier_buff_name = 'modifier_mjz_templar_assassin_refraction_buff'

		EmitSoundOn("Hero_TemplarAssassin.Refraction", caster)
		caster:AddNewModifier(caster, ability, modifier_buff_name, {duration = duration})
	end
end

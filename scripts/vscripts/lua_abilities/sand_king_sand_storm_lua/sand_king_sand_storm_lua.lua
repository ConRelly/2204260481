sand_king_sand_storm_lua = class({})
LinkLuaModifier( "modifier_sand_king_sand_storm_lua", "lua_abilities/sand_king_sand_storm_lua/modifier_sand_king_sand_storm_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function sand_king_sand_storm_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_sand_king_sand_storm_lua", -- modifier name
		{
			duration = self:GetDuration(),
			start = true,
		} -- kv
	)

	-- effects
	local sound_cast = "Ability.SandKing_SandStorm.start"
	EmitSoundOn( sound_cast, caster )
end

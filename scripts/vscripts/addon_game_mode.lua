require("AOHGameMode")
require("lib/animations")
require("lib/utils")
--require("hack/precache_resource")

function do_precache(elements, handle)
	for _, e in ipairs(elements) do
		handle(e)
	end
end


function Precache(context)
	local items = {
		"item_bag_of_gold",
		"item_tombstone",
	}

	local models = {
		"models/heroes/dragon_knight_persona/dk_persona_base.vmdl",
		"models/heroes/dragon_knight_persona/dk_persona_weapon.vmdl",
		"models/heroes/dragon_knight_persona/dk_persona_shoulder_cape.vmdl",
		"models/heroes/dragon_knight_persona/dk_persona_head.vmdl",
		"models/heroes/dragon_knight_persona/dk_persona_head_hair.vmdl",
		"models/heroes/dragon_knight_persona/dk_persona_shoulder_pauldrons.vmdl",
		"models/heroes/dragon_knight_persona/dk_persona_weapon_alt.vmdl"
	}
	local particles = {
		"particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf",
		"particles/generic_gameplay/generic_break.vpcf",

	}

	local soundevents = {
		"soundevents/game_sounds_heroes/game_sounds_silencer.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_elder_titan.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts",
		--"soundevents/game_sounds_heroes/game_sounds_earthshaker.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_lina.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_mars.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_techies.vsndevts",
		"soundevents/game_sounds_custom.vsndevts",
		"soundevents/game_sounds_storegga.vsndevts",
		"soundevents/custom_sounds.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_invoker.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_magnataur.vsndevts",
		"soundevents/voscripts/game_sounds_vo_zoom.vsndevts",  
		"soundevents/game_sounds_heroes/game_sounds_jugger_abilities.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_dark_willow.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_spirit_breaker.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_riki.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_lion.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_troll_warlord.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_leshrac.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_primal_beast.vsndevts",
	}

	local units = { 
		"npc_dota_brewmaster_earth_3",
		"npc_dota_brewmaster_storm_3",
		"npc_dota_brewmaster_fire_3",
		"npc_dota_hero_dragon_knight",
	}



	do_precache(items, 
		function(e) 
			PrecacheItemByNameSync(e, context) 
		end
	)

	do_precache(models, 
		function(e) 
			PrecacheModel(e, context)
		end
	)

	do_precache(particles, 
		function(e) 
			PrecacheResource("particle", e, context)
		end
	)

	do_precache(soundevents, 
		function(e) 
			PrecacheResource("soundfile", e, context)
			--PrecacheResource("soundfile", "soundevents/game_sounds_custom_2.vsndevts", context )
			--PrecacheResource("soundfile", "soundevents/game_sounds_storegga.vsndevts", context )
		end
	)

	do_precache(units, 
		function(e) 
			PrecacheUnitByNameSync(e, context)
		end
	)
	Precache_Resource(context)
end



function Activate()
	GameRules.GameMode = AOHGameMode()
	GameRules.GameMode:InitGameMode()
end

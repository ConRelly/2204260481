
local BUNE_BOSS_LIST = {
    "npc_boss_skeletal_archer_new", "npc_boss_skeletal_archer_new_s1", "npc_boss_skeletal_archer_new_s2",
    "npc_boss_juggernaut",
    "npc_boss_chaos_knight",
    "npc_boss_witch_doctor",
    "npc_boss_grimstroke",
    "npc_boss_ursa",
    "npc_bristle_large",
    "npc_boss_luna",
    "npc_boss_treant",
    "npc_boss_tidehunter",
    "npc_boss_nyx",
    "npc_boss_dragon_guard",
    "npc_boss_winter_wyvern",
    "npc_boss_phoenix",
    "npc_boss_enigma",
    "npc_boss_razor",
    "npc_boss_zeus",
    "npc_boss_lycan",
    "npc_boss_doom",
    "npc_boss_kunkka",
    "npc_boss_crystal_queen", "npc_boss_crystal_maiden",
    "npc_boss_medusa",
    "npc_boss_tinker",
    "npc_boss_nevermore",
    "npc_boss_phantomlancer",
    "npc_boss_spectre",
    "npc_boss_antimage_female", "npc_boss_antimage",
    "npc_boss_worldsmith",
    "npc_boss_lich_king",
    "npc_boss_spiritbreaker",
    "npc_boss_rubick",
    "npc_boss_demon_marauder",
    "npc_boss_wisp_new",
    "npc_boss_skeleton_king_new",
	"npc_dota_creature_siltbreaker",
}

-- TODO: MonsterStyle
function HackGameMode:_OnBossSpawn( npc )
    local npcName = npc:GetUnitName()
    for _,name in ipairs(BUNE_BOSS_LIST) do
        if npcName == name then
            npc:AddNewModifier(npc, nil, "modifier_boss_runes", {})
            break
        end
    end
end

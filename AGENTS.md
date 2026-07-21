# Project Notes

Keep this file compact and self-improving. When a task reveals a durable project rule, naming convention, file location, bug pattern, or balance/design intent that would help future agents reach the correct outcome faster, add or refine a short note here. Avoid one-off details, long explanations, and anything that only helps the current edit.

- This is a Dota 2 custom game addon with very large KV and localization files. Search narrowly with `rg -n -C` for ability names, tooltip tokens, or talent names instead of reading whole files.
- Common locations: Lua ability scripts in `scripts/vscripts/abilities/...`, ability KV in `scripts/npc/npc_abilities_custom.txt`, English tooltips in `resource/addon_english.txt`.
- Patch notes live in `patch note.txt`. Append at the end, follow the existing informal bullet style, use tooltip/visible ability names rather than code names, and separate update blocks with `---`.
- Prefer normal `ability:GetSpecialValueFor(...)` when the KV links talents directly in the `AbilityValues` block, for example: `"crit_chance" { "value" "2 2 3 4 5" "special_bonus_unique_pa_coup_de_grace_crit_chance" "5" }`.
- `GetTalentSpecialValueFor` exists in older Lua files, but newer correctly-written KV can make it unnecessary.
- Super Scepter is custom. Lua usually checks it with `local has_ss = caster:HasModifier("modifier_super_scepter")`; patch notes may call it `Super Scepter` or `SS` if that matches nearby style.
- The underdog list is controlled by `UnitLabel` in `scripts/npc/npc_heroes_custom.txt`. Add/remove heroes by uncommenting/commenting `"UnitLabel" "no_underdog"`; `fix_atr_for_hero2` in main(aohgamemode.lua) filters this and gives the permanent post-level-34 buff modifier.
- Tooltip custom section colors: `#DE3163` Super Scepter, `#0094FF` Aghanim's Scepter, `#F70707` Challenge Boss, `#2AD563` UP item sections, `#86C91F` Extra Passive, `#F17C26` Info, `#FFA32B` Exclusive label. Keep existing hero/exclusive colors when editing nearby tooltip text.
- For multi-line Super Scepter or ability descriptions, use `<br>` between numbered items (e.g. `1. ...<br>2. ...`) without extra blank lines or `\n` paragraph breaks to avoid excessive vertical spacing in the UI.
- Some heavy visual effects respect `_G._effect_rate`; common pattern is `local randomSeed = math.random(1, 100)` then only play the effect when `randomSeed <= _G._effect_rate`. Tooltip info often tells host to use `-effect_rate 1-20`.
- Be careful with unrelated context in the big files. Keep edits scoped to the exact ability, tooltip, or talent being worked on.


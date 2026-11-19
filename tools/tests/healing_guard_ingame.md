# Healing guard engine test

The guard is enabled automatically in a fresh lobby. Vampire Fangs is only a
reproduction tool; there is no item-specific handling in the guard.

The initial ON/OFF test showed negative heal values reaching the filter; the
guard rejected them, and disabling it reproduced the 1 HP bug. `-fixhp` did not
recover the corrupted hero and has been removed, along with `-hpdebug`, all
per-heal counters, and per-heal logging.

1. Start a fresh Tools/cheats lobby with the updated scripts. Check the server
   console for `[HealingGuard] v2 installed`. Use `-healguard` to confirm ON and
   installed. Do not rely on an existing match loading changed Lua files.
2. Test excessive attack lifesteal and excessive spell lifesteal separately,
   using the same item values, damage, and targets that previously reproduced
   the bug. Begin with some HP missing. Repeat at full HP and with healing /
   lifesteal amplification equipped. Keep attacking/casting for several seconds.
3. Check that HP and regeneration remain normal during and after attacking.
   Repeat with the map's highest attack rate and additional attack sources.
   There should be no per-heal console messages or HUD notifications.
4. If needed for A/B comparison, the test host (player 0) can use
   `-healguard off`, reproduce the original failure, then `-healguard on`.
   OFF returns immediately without modifying heals or inspecting entities.
   Use a fresh hero/lobby for prevention tests if the OFF test already corrupted
   the hero. Leave the guard ON afterward.
5. If the hero sticks at 1 HP despite the guard, capture the reproduction and
   `-healguard` status. Coverage of other engine healing paths and amplification
   order still require in-game verification; do not assume all causes are fixed.

Also check ordinary small/fractional healing, anti-heal, and damage-derived
custom heals. Direct `SetHealth` changes are outside this healing filter.

Each accepted heal is capped to the minimum of the unit's max HP, 1,000,000,
and 100,000,000 minus current HP. The 100M value bounds current HP plus this heal;
it does not change the max HP stat. Units already at or above 100M current HP
receive no healing through the guard until they fall below that boundary.

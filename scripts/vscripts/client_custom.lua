
--[[ LinkLuaModifier("modifier_boss", "modifiers/modifier_boss.lua", LUA_MODIFIER_MOTION_NONE)

print("before server check")
if IsClient() then
    print("Client-side code")
else
    print("Server-side code")
end ]]
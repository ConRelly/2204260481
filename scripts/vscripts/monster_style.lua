
if MonsterStyle == nil then
	_G.MonsterStyle = class({})
end

function MonsterStyle:InitGameMode()
	self:_ReadGameConfiguration()

end

function MonsterStyle:GetRandomStyle( npcClassName )
    local t = self._vStyles[npcClassName]
    if t then
        local list = {}
        for k,v in pairs(t) do
            -- print(k,v)
            table.insert( list, v)
        end
        local style = list[ RandomInt(1, #list) ]
        -- print(style)
        return style
    end
    return npcClassName
end

function MonsterStyle:_ReadGameConfiguration()
	-- local kv = LoadKeyValues("scripts/config/aoh2_config.txt") or {}
	local kv = LoadKeyValues("scripts/config/" .. "monster_style.txt") or {}
	self._vStyles = kv
end


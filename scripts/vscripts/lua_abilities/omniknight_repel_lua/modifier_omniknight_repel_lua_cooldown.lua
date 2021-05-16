modifier_omniknight_repel_lua_cooldown = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_omniknight_repel_lua_cooldown:IsHidden()
	return false
end

function modifier_omniknight_repel_lua_cooldown:IsDebuff()
	return true
end

function modifier_omniknight_repel_lua_cooldown:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_omniknight_repel_lua_cooldown:OnCreated( kv )
end

function modifier_omniknight_repel_lua_cooldown:OnRefresh( kv )
end

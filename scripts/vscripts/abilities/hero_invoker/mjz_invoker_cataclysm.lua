LinkLuaModifier("modifier_mjz_invoker_cataclysm","abilities/hero_invoker/mjz_invoker_cataclysm.lua", LUA_MODIFIER_MOTION_NONE)

mjz_invoker_cataclysm = class({})
local ability_class = mjz_invoker_cataclysm

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_invoker_cataclysm"
end
function mjz_invoker_cataclysm:Spawn()
	if IsServer() then
		self:SetHidden(true)
		self:SetLevel(1)
	end
end


---------------------------------------------------------------------------------------

modifier_mjz_invoker_cataclysm = class({})
local modifier_class = modifier_mjz_invoker_cataclysm

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
    function modifier_class:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_START,
            MODIFIER_EVENT_ON_ABILITY_EXECUTED,
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }
        return funcs
    end

    function modifier_class:OnAbilityStart(params)
        if params.unit ~= self:GetParent() then return nil end
        if params.ability and params.ability:IsItem() then return nil end

        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local ability_exe = params.ability
        local now_time = GameRules:GetGameTime()
        -- print('OnAbilityStart')
        -- print(now_time, ability_exe:GetName(), ability_exe:GetCooldownTimeRemaining())
    end

    function modifier_class:OnAbilityExecuted(params)
        if params.unit ~= self:GetParent() then return nil end
        if params.ability and params.ability:IsItem() then return nil end

        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local ability_exe = params.ability
        local now_time = GameRules:GetGameTime()
        -- print('OnAbilityExecuted')
        -- print(now_time, ability_exe:GetName(), ability_exe:GetCooldownTimeRemaining())
    end

    function modifier_class:OnAbilityFullyCast(params)
        if params.unit ~= self:GetParent() then return nil end
        if params.ability and params.ability:IsItem() then return nil end

        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local ability_exe = params.ability
        local now_time = GameRules:GetGameTime()
        -- print('OnAbilityFullyCast')
        -- print(now_time, ability_exe:GetName(), ability_exe:GetCooldownTimeRemaining())

        self:_OnAbilityFullyCast( caster, ability, ability_exe )
    end

    
    function modifier_class:_OnAbilityFullyCast( caster, ability, ability_exe )
        if ability_exe:GetName() ~= 'invoker_sun_strike' then return nil end
        
        local cooldown = ability_exe:GetCooldown(ability_exe:GetLevel())
        local cooldown_re = ability_exe:GetCooldownTimeRemaining()

        if cooldown_re > cooldown then
            self:_CastCataclysm( caster, ability, ability_exe)
        end
    end

    function modifier_class:_CastCataclysm(caster, ability, ability_exe)
        local points = 18
        local point_step = 3
        local range = ability:GetSpecialValueFor('range')
        local range_variance = 300
        local range_min = 300
        local delay = 0.5
        local caster_pos = caster:GetAbsOrigin()
        Timers:CreateTimer(function()
            local cycle = 0
            local i = 0
            while i < points do
                local b = i / points
                local c = cycle + (360 * b)
                local x = range * math.sin(math.rad(c)) + caster_pos.x
                local y = range * math.cos(math.rad(c)) + caster_pos.y
                local point_loc = Vector(x, y, 0)
                
                caster:SetCursorPosition(point_loc)
                ability_exe:OnSpellStart()

                i = i + 1
            end
            range = range - range_variance
            -- points = points - point_step
            points = points - math.floor( points * 0.33 )
            if range >= range_min then
                return delay
            else
                caster:SetCursorPosition(caster_pos)
                ability_exe:OnSpellStart()
                return nil
            end
        end)
    end

end
--[[
function modifier_class:OnInventoryContentsChanged( params )
	local caster = self:GetCaster()

	-- get data
	local scepter = caster:HasScepter()
	local ability = caster:FindAbilityByName( "mjz_invoker_cataclysm" )

	-- if there's no ability, then add it
	if not ability then 
		ability = caster:AddAbility( "mjz_invoker_cataclysm" )
	end

	ability:SetActivated( scepter )
	ability:SetHidden( not scepter )

	if ability:GetLevel()~=1 then
		ability:SetLevel( 1 )
	end
end]]


-----------------------------------------------------------------------------------------

-- 是否学习了指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
    end
    return base
end
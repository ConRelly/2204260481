LinkLuaModifier("modifier_golden_mine_passive", "abilities/golden_mine_passive.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_golden_mine_buff", "abilities/golden_mine_passive.lua", LUA_MODIFIER_MOTION_NONE)


golden_mine_passive = class({})

function golden_mine_passive:GetIntrinsicModifierName()
    return "modifier_golden_mine_passive"
end


modifier_golden_mine_passive = class({})

function modifier_golden_mine_passive:IsHidden() return true end
function modifier_golden_mine_passive:IsPurgable() return false end

function modifier_golden_mine_passive:CheckState() 
    return {
        -- [MODIFIER_STATE_NOT_ON_MINIMAP] 		= true,
		-- [MODIFIER_STATE_ROOTED]         		= true,
		-- [MODIFIER_STATE_MAGIC_IMMUNE] 			= true,
		-- [MODIFIER_STATE_LOW_ATTACK_PRIORITY]  	= true,
        -- [MODIFIER_STATE_NO_UNIT_COLLISION]		= true,
        [MODIFIER_STATE_NO_HEALTH_BAR]          = true,
    } 
end

function modifier_golden_mine_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACKED,
	}

	return funcs
end

function modifier_golden_mine_passive:OnAttacked(kv)
	if IsServer() then
		if kv.target ~= self:GetParent() then
			return
        end
        local attacker = kv.attacker
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local interval = 1
        if attacker and attacker:IsRealHero() then
            local m_name = "modifier_golden_mine_buff"
            if not attacker:HasModifier(m_name) then
                attacker:AddNewModifier(parent, ability, m_name, {duration = interval})
            end
            -- local golden_mine_time = attacker._golden_mine_time or 0
            -- if (GameRules:GetGameTime() - golden_mine_time) >= interval then
            --     attacker._golden_mine_time = GameRules:GetGameTime()
            --     self:_AddGoldAndEXP(attacker)
            --     attacker:AddNewModifier(parent, ability, "modifier_golden_mine_buff", {duration = interval})
            -- end
        end
	end
end

function modifier_golden_mine_passive:_AddGoldAndEXP(target)
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local exp = ability:GetSpecialValueFor("exp")
    local gold = ability:GetSpecialValueFor("gold")

    target:AddExperience(exp, DOTA_ModifyGold_Unspecified, false, false) ---给触发者增加经验

    target:ModifyGold(gold, true, 0)
    -- local playerid = target:GetPlayerID()
    -- PlayerResource:ModifyGold(playerid, gold, false, 0)

    -- 不使用声效
    if IsInToolsMode() then
        target:EmitSound("General.CoinsBig")
    end
    -- target:EmitSound("DOTA_Item.Hand_Of_Midas")
    -- target:EmitSound('Hero_BountyHunter.Jinada')

end

----------------------------------------------------

modifier_golden_mine_buff = class({})

function modifier_golden_mine_buff:IsHidden() return false end
function modifier_golden_mine_buff:IsPurgable() return false end

if IsServer() then

    function modifier_golden_mine_buff:OnCreated(table)
        local parent = self:GetParent()
        if parent:IsRealHero() then
            self:StartIntervalThink(0.98)
        end
    end
    function modifier_golden_mine_buff:OnIntervalThink()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local exp = ability:GetSpecialValueFor("exp")
        local gold = ability:GetSpecialValueFor("gold")

        parent:AddExperience(exp, DOTA_ModifyGold_Unspecified, false, false) ---给触发者增加经验

        parent:ModifyGold(gold, true, 0)
        -- local playerid = parent:GetPlayerID()
        -- PlayerResource:ModifyGold(playerid, gold, false, 0)

        -- 不使用声效
        if IsInToolsMode() then
            parent:EmitSound("General.CoinsBig")
        end
        -- parent:EmitSound("DOTA_Item.Hand_Of_Midas")
        -- parent:EmitSound('Hero_BountyHunter.Jinada')

        self:StartIntervalThink(-1)
    end

end
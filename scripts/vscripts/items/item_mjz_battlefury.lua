LinkLuaModifier( "modifier_item_mjz_battlefury", "items/item_mjz_battlefury", LUA_MODIFIER_MOTION_NONE )

---------------------------------------------------------------------------------------

function item_mjz_battlefury_CastTarget(item, target)
	local caster = item:GetCaster()
	if caster and IsValidEntity(caster) and caster:IsRealHero() then
		local target_class = target:GetClassname()
		if target_class == "ent_dota_tree" then 
			local target_tree = target
			if target_tree and IsValidEntity(target_tree) and target_tree:IsStanding() then 
				target_tree:CutDown(caster:GetTeamNumber())
			end
		end
	end
end

---------------------------------------------------------------------------------------

item_mjz_battlefury_2 = class({})
item_mjz_battlefury_3 = class({})
item_mjz_battlefury_4 = class({})
item_mjz_battlefury_5 = class({})

function item_mjz_battlefury_2:GetIntrinsicModifierName() return "modifier_item_mjz_battlefury" end
function item_mjz_battlefury_3:GetIntrinsicModifierName() return "modifier_item_mjz_battlefury" end
function item_mjz_battlefury_4:GetIntrinsicModifierName() return "modifier_item_mjz_battlefury" end
function item_mjz_battlefury_5:GetIntrinsicModifierName() return "modifier_item_mjz_battlefury" end

function item_mjz_battlefury_2:OnSpellStart()
	if IsServer() then item_mjz_battlefury_CastTarget(self, self:GetCursorTarget()) end
end
function item_mjz_battlefury_3:OnSpellStart()
	if IsServer() then item_mjz_battlefury_CastTarget(self, self:GetCursorTarget()) end
end
function item_mjz_battlefury_4:OnSpellStart()
	if IsServer() then item_mjz_battlefury_CastTarget(self, self:GetCursorTarget()) end
end
function item_mjz_battlefury_5:OnSpellStart()
	if IsServer() then item_mjz_battlefury_CastTarget(self, self:GetCursorTarget()) end
end

---------------------------------------------------------------------------------------

if modifier_item_mjz_battlefury == nil then modifier_item_mjz_battlefury = class({}) end
function modifier_item_mjz_battlefury:IsPassive() return true end
function modifier_item_mjz_battlefury:IsHidden() return true end
function modifier_item_mjz_battlefury:IsPurgable() return false end
function modifier_item_mjz_battlefury:AllowIllusionDuplicate() return false end
function modifier_item_mjz_battlefury:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_item_mjz_battlefury:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, 

		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_item_mjz_battlefury:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_damage") end
end
function modifier_item_mjz_battlefury:GetModifierConstantHealthRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
end
function modifier_item_mjz_battlefury:GetModifierConstantManaRegen()
	if self:GetAbility() then return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
end

function modifier_item_mjz_battlefury:OnAttackLanded(params)
	local attacker = params.attacker
	local target = params.target
	if not IsServer() then return end
	if params.target == nil then return end
	if params.attacker ~= self:GetParent() then return end
	if params.attacker:IsIllusion() then return end
	if params.target:GetClassname() == "dota_item_drop" then return end
	
	local ability = self:GetAbility()
	local bonus_damage = ability:GetSpecialValueFor("bonus_damage")
	local cleave_damage_percent = ability:GetSpecialValueFor("cleave_damage_percent")
	local cleave_starting_width = ability:GetSpecialValueFor("cleave_starting_width")
	local cleave_ending_width = ability:GetSpecialValueFor("cleave_ending_width")
	local cleave_distance = ability:GetSpecialValueFor("cleave_distance")
	
	if not params.attacker:IsRangedAttacker() then
		if UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, attacker:GetTeamNumber()) == UF_SUCCESS then
			local particlePath = ParticleManager:GetParticleReplacement("particles/items_fx/battlefury_cleave.vpcf", attacker)
			DoCleaveAttack(attacker, target, self:GetAbility(), params.original_damage * cleave_damage_percent*0.01, cleave_starting_width, cleave_ending_width, cleave_distance, particlePath)
			attacker:EmitSound("DOTA_Item.BattleFury")
		end
	end
end

-- 力量增强 
LinkLuaModifier( "modifier_ability_flagstone_bonus_agi", "ability/flagstone/ability_flagstone_bonus_agi",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_flagstone_bonus_agi_effect", "ability/flagstone/ability_flagstone_bonus_agi",LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------
if ability_flagstone_bonus_agi == nil then ability_flagstone_bonus_agi = {} end

function ability_flagstone_bonus_agi:GetIntrinsicModifierName()
 	return "modifier_ability_flagstone_bonus_agi"
end
--------------------------------------------------
if modifier_ability_flagstone_bonus_agi == nil then modifier_ability_flagstone_bonus_agi = {} end
function modifier_ability_flagstone_bonus_agi:IsHidden()return true end
function modifier_ability_flagstone_bonus_agi:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_ability_flagstone_bonus_agi:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end
	local chance = self:GetAbility():GetSpecialValueFor( "chance" )
	local nowChance = RandomInt(0,100)
	if nowChance > chance then
		return false
	end
	local duration = self:GetAbility():GetSpecialValueFor( "duration" )
	local max_stack = self:GetAbility():GetSpecialValueFor( "max_stack" )
	local hCaster = self:GetCaster()
	local ModifybonusName = "modifier_ability_flagstone_bonus_agi_effect" 
	local ModifiersTable = hCaster:FindAllModifiersByName(ModifybonusName)
	local nowStack = #ModifiersTable
	if nowStack >= max_stack then
		hCaster:RemoveModifierByName(ModifybonusName)
	end
	hCaster:AddNewModifier( 
		self:GetCaster(), 
		self:GetAbility(), 
		ModifybonusName, 
		{ duration = duration} 
	)
end
---------------

if modifier_ability_flagstone_bonus_agi_effect == nil then
	modifier_ability_flagstone_bonus_agi_effect = class({})
end

function modifier_ability_flagstone_bonus_agi_effect:IsHidden() 
	return true
end

function modifier_ability_flagstone_bonus_agi_effect:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_ability_flagstone_bonus_agi_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
	return funcs
end

function modifier_ability_flagstone_bonus_agi_effect:OnCreated( kv )
	if not IsServer() then return end
	self.bonus = self:GetCaster():GetBaseStrength() * self:GetAbility():GetSpecialValueFor( "coefficient" )
end

function modifier_ability_flagstone_bonus_agi_effect:GetModifierBonusStats_Agility( kv )
	return self.bonus
end


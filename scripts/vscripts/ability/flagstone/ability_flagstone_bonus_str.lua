-- 力量增强 
LinkLuaModifier( "modifier_ability_flagstone_bonus_str", "ability/flagstone/ability_flagstone_bonus_str",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_flagstone_bonus_str_effect", "ability/flagstone/ability_flagstone_bonus_str",LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------
if ability_flagstone_bonus_str == nil then ability_flagstone_bonus_str = {} end

function ability_flagstone_bonus_str:GetIntrinsicModifierName()
 	return "modifier_ability_flagstone_bonus_str"
end
--------------------------------------------------
if modifier_ability_flagstone_bonus_str == nil then modifier_ability_flagstone_bonus_str = {} end
function modifier_ability_flagstone_bonus_str:IsHidden()return true end
function modifier_ability_flagstone_bonus_str:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_ability_flagstone_bonus_str:OnAttackLanded( params )
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
	local ModifybonusName = "modifier_ability_flagstone_bonus_str_effect" 
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

if modifier_ability_flagstone_bonus_str_effect == nil then
	modifier_ability_flagstone_bonus_str_effect = class({})
end

function modifier_ability_flagstone_bonus_str_effect:IsHidden() 
	return true
end

function modifier_ability_flagstone_bonus_str_effect:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_ability_flagstone_bonus_str_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
	return funcs
end

function modifier_ability_flagstone_bonus_str_effect:OnCreated( kv )
	if not IsServer() then return end
	self.bonus = self:GetCaster():GetBaseStrength() * self:GetAbility():GetSpecialValueFor( "coefficient" )
end

function modifier_ability_flagstone_bonus_str_effect:GetModifierBonusStats_Strength( kv )
	return self.bonus
end


--亡命护盾
LinkLuaModifier("modifier_item_flee_shield", "item/item_flee_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_flee_shield_bonus_property", "item/item_flee_shield", LUA_MODIFIER_MOTION_NONE)

if item_flee_shield == nil then 
	item_flee_shield = class({})
end

function item_flee_shield:GetIntrinsicModifierName()
 	return "modifier_item_flee_shield"
end
--------------------------------------------------
if modifier_item_flee_shield == nil then
	modifier_item_flee_shield = class({})
end

function modifier_item_flee_shield:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_flee_shield:Passive() -- 默认拥有
	return true
end

function modifier_item_flee_shield:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HEALTH_BONUS, -- 生命值
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
	return funcs
end

function modifier_item_flee_shield:OnCreated(kv)
	--local caster = kv.caster
	self.strength = self:GetAbility():GetSpecialValueFor("strength")
	--self.spell_resistance = self:GetAbility():GetSpecialValueFor("spell_resistance")
	self.health_point = self:GetAbility():GetSpecialValueFor("health_point")
	self.max_health = self:GetAbility():GetSpecialValueFor("max_health")
	self.max_health = self.max_health + self.health_point
end

function modifier_item_flee_shield:GetModifierBonusStats_Strength( kv ) -- 官方方法 返回获取到护甲 到面板
	return self.strength
end

function modifier_item_flee_shield:GetModifierHealthBonus( kv ) -- 增加生命值
	return self.max_health
end
-----------------------------------------被动：增加自身10%的生命值----------------------------
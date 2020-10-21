-- 力量腰带
LinkLuaModifier("modifier_item_strength_belt", "item/item_strength_belt", LUA_MODIFIER_MOTION_NONE)

if item_strength_belt == nil then 
	item_strength_belt = class({})
end

function item_strength_belt:GetIntrinsicModifierName()
 	return "modifier_item_strength_belt"
end
--------------------------------------------------
if modifier_item_strength_belt == nil then
	modifier_item_strength_belt = class({})
end

function modifier_item_strength_belt:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_strength_belt:Passive() -- 默认拥有
	return true
end

function modifier_item_strength_belt:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, -- 获得力量 + 绿字
		MODIFIER_PROPERTY_HEALTH_BONUS, -- 生命上限
		--MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, -- 生命回复
	}
	return funcs
end

function modifier_item_strength_belt:OnCreated(kv)
	self.strength = self:GetAbility():GetSpecialValueFor("strength")
	self.health = self:GetAbility():GetSpecialValueFor("health")
end

function modifier_item_strength_belt:GetModifierBonusStats_Strength( kv ) -- 官方方法 返回获取到的属性值(力量) 到面板
	return self.strength
end

function modifier_item_strength_belt:GetModifierHealthBonus( kv ) -- 返回生命上限到面板 的官方方法
	return self.health
end
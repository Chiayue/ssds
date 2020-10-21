-- 敏捷之靴
LinkLuaModifier("modifier_item_boots_of_agile", "item/item_boots_of_agile", LUA_MODIFIER_MOTION_NONE)

if item_boots_of_agile == nil then 
	item_boots_of_agile = class({})
end

function item_boots_of_agile:GetIntrinsicModifierName()
 	return "modifier_item_boots_of_agile"
end
--------------------------------------------------
if modifier_item_boots_of_agile == nil then
	modifier_item_boots_of_agile = class({})
end

function modifier_item_boots_of_agile:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_boots_of_agile:Passive() -- 默认拥有
	return true
end

function modifier_item_boots_of_agile:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS, -- 敏捷
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT -- 移动速度
	}
	return funcs
end

function modifier_item_boots_of_agile:OnCreated(kv)
	--local caster = self:GetCaster()
	--local ability = self:GetParent()
	self.agitle = self:GetAbility():GetSpecialValueFor("agitle")
	self.move_speed = self:GetAbility():GetSpecialValueFor("move_speed")

end

function modifier_item_boots_of_agile:GetModifierBonusStats_Agility( kv ) -- 官方方法 返回获取到的属性值(敏捷) 到面板
	return self.agitle
end

function modifier_item_boots_of_agile:GetModifierMoveSpeedBonus_Constant( kv ) -- 返回移动速度到面板 的官方方法
	return self.move_speed
end
-- 防御指环
LinkLuaModifier("modifier_item_defense_ring", "item/item_defense_ring", LUA_MODIFIER_MOTION_NONE)

if item_defense_ring == nil then 
	item_defense_ring = class({})
end

function item_defense_ring:GetIntrinsicModifierName()
 	return "modifier_item_defense_ring"
end
--------------------------------------------------
if modifier_item_defense_ring == nil then
	modifier_item_defense_ring = class({})
end

function modifier_item_defense_ring:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_defense_ring:Passive() -- 默认拥有
	return true
end

function modifier_item_defense_ring:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, -- 护甲
	}
	return funcs
end

function modifier_item_defense_ring:OnCreated()
	--local caster = self:GetCaster()
	self.armor = self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_item_defense_ring:GetModifierPhysicalArmorBonus( kv ) -- 官方方法 返回获取到的护甲值 到面板
	return self.armor
end
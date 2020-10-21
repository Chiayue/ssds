-- 智慧披风
LinkLuaModifier("modifier_item_cloak_of_intellg", "item/item_cloak_of_intellg", LUA_MODIFIER_MOTION_NONE)

if item_cloak_of_intellg == nil then 
	item_cloak_of_intellg = class({})
end

function item_cloak_of_intellg:GetIntrinsicModifierName()
 	return "modifier_item_cloak_of_intellg"
end
--------------------------------------------------
if modifier_item_cloak_of_intellg == nil then
	modifier_item_cloak_of_intellg = class({})
end

function modifier_item_cloak_of_intellg:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_cloak_of_intellg:Passive() -- 默认拥有
	return true
end

function modifier_item_cloak_of_intellg:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, -- 智力
		MODIFIER_PROPERTY_MANA_BONUS -- 魔法上限
	}
	return funcs
end

function modifier_item_cloak_of_intellg:OnCreated(kv)
	--local caster = self:GetCaster()
	--local ability = self:GetParent()
	self.intellig = self:GetAbility():GetSpecialValueFor("intellig")
	self.magic = self:GetAbility():GetSpecialValueFor("magic")

end

function modifier_item_cloak_of_intellg:GetModifierBonusStats_Intellect( kv ) -- 官方方法 返回获取到的属性值(智力) 到面板
	return self.intellig
end

function modifier_item_cloak_of_intellg:GetModifierManaBonus( kv ) -- 返回魔法上限到面板 的官方方法
	return self.magic
end
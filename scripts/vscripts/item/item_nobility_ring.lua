-- 贵族饰环
LinkLuaModifier("modifier_item_nobility_ring", "item/item_nobility_ring", LUA_MODIFIER_MOTION_NONE)

if item_nobility_ring == nil then 
	item_nobility_ring = class({})
end

function item_nobility_ring:GetIntrinsicModifierName()
 	return "modifier_item_nobility_ring"
end
--------------------------------------------------
if modifier_item_nobility_ring == nil then
	modifier_item_nobility_ring = class({})
end

function modifier_item_nobility_ring:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_nobility_ring:Passive() -- 默认拥有
	return true
end

function modifier_item_nobility_ring:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, -- 攻击力
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, -- 力量
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS, -- 敏捷
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, -- 智力
	}
	return funcs
end

function modifier_item_nobility_ring:OnCreated(kv)
	--local caster = self:GetCaster()
	--local ability = self:GetParent()
	self.attack = self:GetAbility():GetSpecialValueFor("attack")
	self.strength = self:GetAbility():GetSpecialValueFor("strength")
	self.agitle = self:GetAbility():GetSpecialValueFor("agitle")
	self.intellig = self:GetAbility():GetSpecialValueFor("intellig")
end

function modifier_item_nobility_ring:GetModifierPreAttack_BonusDamage( kv ) -- 官方方法 返回获取到的攻击值 到面板
	return self.attack
end

function modifier_item_nobility_ring:GetModifierBonusStats_Strength( kv ) -- 官方方法 返回获取到的属性值(力量) 到面板
	return self.strength
end

function modifier_item_nobility_ring:GetModifierBonusStats_Agility( kv ) -- 官方方法 返回获取到的属性值(敏捷) 到面板
	return self.agitle
end

function modifier_item_nobility_ring:GetModifierBonusStats_Intellect( kv ) -- 官方方法 返回获取到的属性值(智力) 到面板
	return self.intellig
end

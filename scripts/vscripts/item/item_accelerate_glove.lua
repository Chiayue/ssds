-- 加速手套
LinkLuaModifier("modifier_item_accelerate_glove", "item/item_accelerate_glove", LUA_MODIFIER_MOTION_NONE)

if item_accelerate_glove == nil then 
	item_accelerate_glove = class({})
end

function item_accelerate_glove:GetIntrinsicModifierName()
 	return "modifier_item_accelerate_glove"
end
--------------------------------------------------
if modifier_item_accelerate_glove == nil then
	modifier_item_accelerate_glove = class({})
end

function modifier_item_accelerate_glove:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_accelerate_glove:Passive() -- 默认拥有
	return true
end

function modifier_item_accelerate_glove:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, -- 攻击速度
	}
	return funcs
end

function modifier_item_accelerate_glove:OnCreated()
	--local caster = self:GetCaster()
	self.attack_speed = self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_item_accelerate_glove:GetModifierAttackSpeedBonus_Constant( kv ) -- 官方方法 返回获取到的攻击速度 到面板
	return self.attack_speed
end
-- 攻击之爪
LinkLuaModifier("modifier_item_attack_claw", "item/item_attack_claw", LUA_MODIFIER_MOTION_NONE)

if item_attack_claw == nil then 
	item_attack_claw = class({})
end

function item_attack_claw:GetIntrinsicModifierName()
 	return "modifier_item_attack_claw"
end
--------------------------------------------------
if modifier_item_attack_claw == nil then
	modifier_item_attack_claw = class({})
end

function modifier_item_attack_claw:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_attack_claw:Passive() -- 默认拥有
	return true
end

function modifier_item_attack_claw:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, -- 攻击力
	}
	return funcs
end

function modifier_item_attack_claw:OnCreated(kv)
	self.attack = self:GetAbility():GetSpecialValueFor("attack")
end

function modifier_item_attack_claw:GetModifierPreAttack_BonusDamage( kv ) -- 官方方法 返回获取到的攻击值 到面板
	return self.attack
end
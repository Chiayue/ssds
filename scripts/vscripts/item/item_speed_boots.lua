-- 速度之靴
LinkLuaModifier("modifier_item_speed_boots", "item/item_speed_boots", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_speed_boots_speed_buff", "item/item_speed_boots", LUA_MODIFIER_MOTION_NONE)

-- 全局变量数值
local speed_number = 
{
	["MOVE_SPEED"] = 5, -- buff增加的敏捷系数
}

if item_speed_boots == nil then 
	item_speed_boots = class({})
end

function item_speed_boots:GetIntrinsicModifierName()
 	return "modifier_item_speed_boots"
end
--------------------------------------------------
if modifier_item_speed_boots == nil then
	modifier_item_speed_boots = class({})
end

function modifier_item_speed_boots:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_speed_boots:Passive() -- 默认拥有
	return true
end

function modifier_item_speed_boots:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT -- 移动速度
	}
	return funcs
end

function modifier_item_speed_boots:OnCreated(kv)
	self.speed = self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_item_speed_boots:GetModifierMoveSpeedBonus_Constant( kv ) -- 返回移动速度到面板 的官方方法
	return self.speed
end

---------------------------------实现增加%10的移动------------------------------

function modifier_item_speed_boots:OnAttackLanded( keys )
	local attacker = self:GetParent() -- 当前攻击 = Mordifier所继承的单位
	local nowChance = RandomInt(0,100)
	local duration_timer = self:GetAbility():GetSpecialValueFor("duration_timer")
	local chance = self:GetAbility():GetSpecialValueFor("chance") -- 技能的攻击概率
	if nowChance  > chance then
		return 0
	end

	attacker:AddNewModifier(attacker, self, "modifier_item_speed_boots_speed_buff", {duration = duration_timer})
end

if modifier_item_speed_boots_speed_buff == nil then 
	modifier_item_speed_boots_speed_buff = class({})
end

function modifier_item_speed_boots_speed_buff:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_item_speed_boots_speed_buff:OnCreated(keys)
	self.move_speed = speed_number.MOVE_SPEED
end

function modifier_item_speed_boots_speed_buff:GetModifierMoveSpeedBonus_Percentage( kv ) -- 返回移动速度到面板 的官方方法
	return self.move_speed
end
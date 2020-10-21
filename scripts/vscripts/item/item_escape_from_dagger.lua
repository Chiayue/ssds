-- 逃脱匕首
LinkLuaModifier("modifier_item_escape_from_dagger", "item/item_escape_from_dagger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_escape_from_dagger_extra_agi", "item/item_escape_from_dagger", LUA_MODIFIER_MOTION_NONE)

if item_escape_from_dagger == nil then 
	item_escape_from_dagger = class({})
end

-- 全局变量数值
local attacker_number = 
{
	["AGI_COEFFICIENT"] = 0.2, -- buff增加的敏捷系数
}

function item_escape_from_dagger:GetIntrinsicModifierName()
 	return "modifier_item_escape_from_dagger"
end
--------------------------------------------------
if modifier_item_escape_from_dagger == nil then
	modifier_item_escape_from_dagger = class({})
end

function modifier_item_escape_from_dagger:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_escape_from_dagger:Passive() -- 默认拥有
	return true
end

function modifier_item_escape_from_dagger:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, -- 移动速度
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, -- 攻击速度
	}
	return funcs
end

function modifier_item_escape_from_dagger:OnCreated(kv)
	self.attack_speed = self:GetAbility():GetSpecialValueFor("attack_speed")
	self.move_speed = self:GetAbility():GetSpecialValueFor("move_speed")
end

function modifier_item_escape_from_dagger:GetModifierMoveSpeedBonus_Constant( kv ) -- 官方方法 返回获取到移动速度 到面板
	return self.move_speed
end

function modifier_item_escape_from_dagger:GetModifierAttackSpeedBonus_Constant( kv ) -- 官方方法 返回获取到的攻击速度 到面板
	return self.attack_speed
end
-----------------------------------------10%提高自身的20%的敏捷----------------------------
function modifier_item_escape_from_dagger:OnAttackLanded( keys )
	if keys.attacker ~= self:GetParent() then -- 防止敌人攻击自家英雄执行函数
		return 0
	end
	local caster = self:GetParent()
	local nowChance = RandomInt(0,100)
	local chance = self:GetAbility():GetSpecialValueFor("chance") -- 技能的攻击概率
	local duration_timer = self:GetAbility():GetSpecialValueFor("duration_timer") -- 
	if nowChance  > chance then
		return 0
	end
	
	caster:AddNewModifier(caster, self, "modifier_item_escape_from_dagger_extra_agi", {duration = duration_timer})
end

if modifier_item_escape_from_dagger_extra_agi == nil then
	modifier_item_escape_from_dagger_extra_agi = class({})
end

function modifier_item_escape_from_dagger_extra_agi:IsHidden()
	return true
end

function modifier_item_escape_from_dagger_extra_agi:Passive( ... )
	return true
end

function modifier_item_escape_from_dagger_extra_agi:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS, -- 敏捷
	}
	return funcs
end

function modifier_item_escape_from_dagger_extra_agi:OnCreated(kv)
	local agi_coefficient = attacker_number.AGI_COEFFICIENT -- 得到增加敏捷的系数
	self.extra_agi = self:GetCaster():GetAgility() * agi_coefficient
end

function modifier_item_escape_from_dagger_extra_agi:GetModifierBonusStats_Agility( kv ) -- 官方方法 返回获取到的属性值(敏捷) 到面板
	return self.extra_agi
end
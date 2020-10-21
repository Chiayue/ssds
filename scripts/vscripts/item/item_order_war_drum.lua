-- 号令战鼓
LinkLuaModifier("modifier_item_order_war_drum", "item/item_order_war_drum", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_order_war_drum_attack_buff", "item/item_order_war_drum", LUA_MODIFIER_MOTION_NONE)

if item_order_war_drum == nil then 
	item_order_war_drum = class({})
end

-- 全局变量数值
local attack_number = 
{
	["ATTACK_DAMAGE"] = 50, -- buff增加的攻击力
	["ATTACK_SPEED"] = 50, -- buff增加的攻击速度
}

function item_order_war_drum:GetIntrinsicModifierName()
 	return "modifier_item_order_war_drum"
end
--------------------------------------------------
if modifier_item_order_war_drum == nil then
	modifier_item_order_war_drum = class({})
end

function modifier_item_order_war_drum:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_order_war_drum:Passive() -- 默认拥有
	return true
end

function modifier_item_order_war_drum:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		MODIFIER_PROPERTY_HEALTH_BONUS, -- 生命值
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, -- 护甲
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, -- 魔抗
	}
	return funcs
end

function modifier_item_order_war_drum:OnCreated(kv)
	self.armor = self:GetAbility():GetSpecialValueFor("armor")
	self.spell_resistance = self:GetAbility():GetSpecialValueFor("spell_resistance")
	self.health_point = self:GetAbility():GetSpecialValueFor("health_point")
end

function modifier_item_order_war_drum:GetModifierPhysicalArmorBonus( kv ) -- 官方方法 返回获取到护甲 到面板
	return self.armor
end

function modifier_item_order_war_drum:GetModifierMagicalResistanceBonus( kv ) -- 官方方法 返回获取到的魔抗 到面板
	return self.spell_resistance
end

function modifier_item_order_war_drum:GetModifierHealthBonus( kv ) -- 增加生命值
	return self.health_point
end

-----------------------------------------10%提高自身50点攻速----------------------------
function modifier_item_order_war_drum:OnAttackLanded( keys )
	if keys.attacker ~= self:GetParent() then -- 防止敌人攻击自家英雄执行函数
		return 0
	end
	
	local attacker = self:GetParent() -- 当前攻击 = Mordifier所继承的单位
	local nowChance = RandomInt(0,100)
	local chance = self:GetAbility():GetSpecialValueFor("chance") -- 技能的攻击概率
	local duration_timer = self:GetAbility():GetSpecialValueFor("duration_timer") -- 
	if nowChance  > chance then
		return 0
	end

	attacker:AddNewModifier(attacker, self, "modifier_item_order_war_drum_attack_buff", {duration = duration_timer})
end

-------------------------------------------实现攻速、攻击力提升-----------------------------------------
if modifier_item_order_war_drum_attack_buff == nil then 
	modifier_item_order_war_drum_attack_buff = class({})
end

function modifier_item_order_war_drum_attack_buff:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_item_order_war_drum_attack_buff:OnCreated(keys)
	self.attack_damage = attack_number.ATTACK_DAMAGE -- 攻击力
	self.attack_speed = attack_number.ATTACK_SPEED -- 攻击速度
end

function modifier_item_order_war_drum_attack_buff:GetModifierPreAttack_BonusDamage( kv ) -- 增加生命值
	return self.attack_damage
end

function modifier_item_order_war_drum_attack_buff:GetModifierAttackSpeedBonus_Constant( kv ) -- 增加生命值
	return self.attack_speed
end
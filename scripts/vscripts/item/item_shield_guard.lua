-- 守护盾
LinkLuaModifier("modifier_item_shield_guard", "item/item_shield_guard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_shield_guard_bonus_property", "item/item_shield_guard", LUA_MODIFIER_MOTION_NONE)

if item_shield_guard == nil then 
	item_shield_guard = class({})
end

function item_shield_guard:OnSpellStart( keys )
	
		local attacker = self:GetParent() -- 当前 Mordifier所继承的单位)
		local duration_timer = self:GetSpecialValueFor("duration_timer") -- 持续时间
		--print("OnSpellStart")
		attacker:AddNewModifier(attacker, self, "modifier_item_shield_guard_bonus_property", {duration = duration_timer})
		
end


function item_shield_guard:GetIntrinsicModifierName()
 	return "modifier_item_shield_guard"
end
--------------------------------------------------
if modifier_item_shield_guard == nil then
	modifier_item_shield_guard = class({})
end

function modifier_item_shield_guard:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_shield_guard:Passive() -- 默认拥有
	return true
end

function modifier_item_shield_guard:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HEALTH_BONUS, -- 生命值
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, -- 护甲
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, -- 魔抗
	}
	return funcs
end

function modifier_item_shield_guard:OnCreated(kv)
	self.armor = self:GetAbility():GetSpecialValueFor("armor")
	self.spell_resistance = self:GetAbility():GetSpecialValueFor("spell_resistance")
	self.health_point = self:GetAbility():GetSpecialValueFor("health_point")
end

function modifier_item_shield_guard:GetModifierPhysicalArmorBonus( kv ) -- 官方方法 返回获取到护甲 到面板
	return self.armor
end

function modifier_item_shield_guard:GetModifierMagicalResistanceBonus( kv ) -- 官方方法 返回获取到的魔抗 到面板
	return self.spell_resistance
end

function modifier_item_shield_guard:GetModifierHealthBonus( kv ) -- 增加生命值
	return self.health_point
end

-----------------------------------------主动：增加10点护甲、魔抗、500生命最大值、持续10秒----------------------------
if modifier_item_shield_guard_bonus_property == nil then 
	modifier_item_shield_guard_bonus_property = class({})
end

--print("0")
function modifier_item_shield_guard_bonus_property:DeclareFunctions()
	--print("1")
	local funcs = 
	{
		MODIFIER_PROPERTY_HEALTH_BONUS, -- 生命值
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, -- 护甲
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, -- 魔抗
	}
	return funcs
end

function modifier_item_shield_guard_bonus_property:OnCreated(keys) -- 添加自身的奖励属性
	--print("2")
	self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor") -- 奖励护甲
	self.bonus_spell_resistance = self:GetAbility():GetSpecialValueFor("bonus_spell_resistance") -- 奖励魔抗
	self.bonus_health_point = self:GetAbility():GetSpecialValueFor("bonus_health_point") -- 奖励生命值
end

function modifier_item_shield_guard_bonus_property:GetModifierPhysicalArmorBonus( kv ) -- 官方方法 返回获取到护甲 到面板
	return self.bonus_armor
end

function modifier_item_shield_guard_bonus_property:GetModifierMagicalResistanceBonus( kv ) -- 官方方法 返回获取到的魔抗 到面板
	return self.bonus_spell_resistance
end

function modifier_item_shield_guard_bonus_property:GetModifierHealthBonus( kv ) -- 增加生命值
	return self.bonus_health_point
end
-- 反曲之弓
LinkLuaModifier("modifier_item_contrary_flexure_bow", "item/item_contrary_flexure_bow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_contrary_flexure_bow_attack_speed_buff", "item/item_contrary_flexure_bow", LUA_MODIFIER_MOTION_NONE)

if item_contrary_flexure_bow == nil then 
	item_contrary_flexure_bow = class({})
end

local attack_number = 
{
	["ATTACK_SPEED"] = 100,
}

function item_contrary_flexure_bow:GetIntrinsicModifierName()
 	return "modifier_item_contrary_flexure_bow"
end
--------------------------------------------------
if modifier_item_contrary_flexure_bow == nil then
	modifier_item_contrary_flexure_bow = class({})
end

function modifier_item_contrary_flexure_bow:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_contrary_flexure_bow:Passive() -- 默认拥有
	return true
end

function modifier_item_contrary_flexure_bow:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, -- 攻击力
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, -- 力量
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS, -- 敏捷
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, -- 智力
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, -- 攻击速度
	}
	return funcs
end

function modifier_item_contrary_flexure_bow:OnCreated()
	self.strength = self:GetAbility():GetSpecialValueFor("strength")
	self.agility = self:GetAbility():GetSpecialValueFor("agility")
	self.intellige = self:GetAbility():GetSpecialValueFor("intellige")
	self.attack_speed = self:GetAbility():GetSpecialValueFor("attack_speed")
	self.damage_base = self:GetAbility():GetSpecialValueFor("damage_base")
end

function modifier_item_contrary_flexure_bow:GetModifierAttackSpeedBonus_Constant( kv ) -- 官方方法 返回获取到的攻击速度 到面板
	return self.attack_speed
end

function modifier_item_contrary_flexure_bow:GetModifierPreAttack_BonusDamage( kv ) -- 官方方法 返回获取到的攻击值 到面板
	return self.attack_damage
end

function modifier_item_contrary_flexure_bow:GetModifierBonusStats_Strength( kv ) -- 官方方法 返回获取到的属性值(力量) 到面板
	return self.strength
end

function modifier_item_contrary_flexure_bow:GetModifierBonusStats_Agility( kv ) -- 官方方法 返回获取到的属性值(敏捷) 到面板
	return self.agility
end

function modifier_item_contrary_flexure_bow:GetModifierBonusStats_Intellect( kv ) -- 官方方法 返回获取到的属性值(智力) 到面板
	return self.intellige
end


function modifier_item_contrary_flexure_bow:OnAttackLanded( keys )
	if keys.attacker ~= self:GetParent() then -- 防止敌人攻击自家英雄执行函数
		return 0
	end

	local attacker = self:GetParent()
	local nowChance = RandomInt(0,100)
	--print("nowChance = ", nowChance)
	local chance = self:GetAbility():GetSpecialValueFor('chance') -- 技能的攻击概率
	local duration_timer = self:GetAbility():GetSpecialValueFor("duration_timer") -- 
	--print("chance = ", chance)
	if nowChance  > chance then
		return 0
	end

	attacker:AddNewModifier(attacker, self, "modifier_item_contrary_flexure_bow_attack_speed_buff", {duration = duration_timer})
end

-------------------------------------------实现攻速提升----------------------------------------------
if modifier_item_contrary_flexure_bow_attack_speed_buff == nil then 
	modifier_item_contrary_flexure_bow_attack_speed_buff = class({})
end

function modifier_item_contrary_flexure_bow_attack_speed_buff:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_item_contrary_flexure_bow_attack_speed_buff:OnCreated(keys)
	self.attack_speed = attack_number.ATTACK_SPEED -- 攻击速度
end

function modifier_item_contrary_flexure_bow_attack_speed_buff:GetModifierAttackSpeedBonus_Constant( kv ) -- 增加生命值
	return self.attack_speed
end
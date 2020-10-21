-- 阿丽亚之笛
-- 生成一个900码的攻击速度光环   攻击速度 + 30  攻击力 + 50 

LinkLuaModifier("modifier_item_ariane_flute", "item/item_ariane_flute", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_item_ariane_flute_aura", "item/item_ariane_flute", LUA_MODIFIER_MOTION_NONE)

if item_ariane_flute == nil then 
	item_ariane_flute = class({})
end

function item_ariane_flute:GetIntrinsicModifierName()
 	return "modifier_item_ariane_flute"
end
-------------------------------------创建的第一个修饰器---------------------------------------
if modifier_item_ariane_flute == nil then
	modifier_item_ariane_flute = class({}) -- 生成第一个 修饰器
end

function modifier_item_ariane_flute:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_ariane_flute:Passive() -- 默认拥有
	return true
end

function modifier_item_ariane_flute:OnCreated(kv)
	self.aura_radius = self:GetAbility():GetSpecialValueFor("aura_radius") -- 获取到光环范围 的数值
end

function modifier_item_ariane_flute:IsAura() -- 光环效果 如果是 光环 就需要在建一个光环的修饰器
	return not self:GetParent():IsIllusion() and self:GetParent():GetUnitLabel() ~= "builder"
end

function modifier_item_ariane_flute:GetAuraRadius( kv ) -- 光环范围
	return self.aura_radius
end

function modifier_item_ariane_flute:GetAuraSearchTeam() -- 是否是友方队伍
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_ariane_flute:GetAuraSearchType() -- 类型
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC -- 英雄 + 基本
end 

function modifier_item_ariane_flute:GetModifierAura() -- 第一个为光环  施加第二个修饰器
	return "modifier_item_item_ariane_flute_aura"
end

---------------------------------------光环修饰器-----------------------------------------------

if modifier_item_item_ariane_flute_aura == nil then 
	modifier_item_item_ariane_flute_aura = class({})
end

function modifier_item_item_ariane_flute_aura:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_item_ariane_flute_aura:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, --攻击力
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, -- 攻击速度
	}
	return funcs
end

function modifier_item_item_ariane_flute_aura:OnCreated(kv)
	self.attack = self:GetAbility():GetSpecialValueFor("attack")
	self.attack_speed = self:GetAbility():GetSpecialValueFor("attack_speed") 
	--self.aura_radius = self:GetAbilitySpecialValueFor("aura_radius") -- 获取到光环范围 的数值
end


--function modifier_item_assault_custom_positive_aura:GetAuraSearchFlags() -- 标记
--	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE -- 无敌
--end

function modifier_item_item_ariane_flute_aura:GetModifierPreAttack_BonusDamage( kv ) -- 官方方法 返回获取到的攻击值 到面板
	return self.attack
end

function modifier_item_item_ariane_flute_aura:GetModifierAttackSpeedBonus_Constant( kv ) -- 官方方法 返回获取到的攻击速度 到面板
	return self.attack_speed
end
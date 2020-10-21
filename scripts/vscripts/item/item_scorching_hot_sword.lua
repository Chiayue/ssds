-- 灼热之剑
LinkLuaModifier("modifier_item_scorching_hot_sword", "item/item_scorching_hot_sword", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_item_scorching_hot_sword_critical_strike", "item/item_scorching_hot_sword", LUA_MODIFIER_MOTION_NONE)

if item_scorching_hot_sword == nil then 
	item_scorching_hot_sword = class({})
end

function item_scorching_hot_sword:GetIntrinsicModifierName()
 	return "modifier_item_scorching_hot_sword"
end
--------------------------------------------------
if modifier_item_scorching_hot_sword == nil then
	modifier_item_scorching_hot_sword = class({})
end

function modifier_item_scorching_hot_sword:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_scorching_hot_sword:Passive() -- 默认拥有
	return true
end

function modifier_item_scorching_hot_sword:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, -- 攻击力
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE, -- 百分比攻击力
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, -- 攻击速度
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}
	return funcs
end

function modifier_item_scorching_hot_sword:OnCreated(kv)
	self.attack = self:GetAbility():GetSpecialValueFor("attack")
	self.attack_percent = self:GetAbility():GetSpecialValueFor("attack_percent")
	self.attack_speed = self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_item_scorching_hot_sword:GetModifierPreAttack_BonusDamage( kv ) -- 官方方法 返回获取攻击力 到面板
	return self.attack
end

function modifier_item_scorching_hot_sword:GetModifierDamageOutgoing_Percentage( kv ) -- 官方方法 返回获取百分比攻击力 到面板
	return self.attack_percent
end

function modifier_item_scorching_hot_sword:GetModifierAttackSpeedBonus_Constant( kv ) -- 官方方法 返回获取攻击速度 到面板
	return self.attack_speed
end

-----------------------------------------10%触发暴击----------------------------
function modifier_item_scorching_hot_sword:OnAttackLanded( keys )
	if keys.attacker ~= self:GetParent() then -- 防止敌人攻击自家英雄执行函数
		return 0
	end
	local attacker = self:GetParent() -- 当前攻击 = Mordifier所继承的单位
	local nowChance = RandomInt(0,100)
	local chance = self:GetAbility():GetSpecialValueFor("chance") -- 技能的攻击概率
	if nowChance  > chance then
		return 0
	end

	local hTarget = keys.target
	local damage_table = 
			{
				victim = hTarget,
				attacker = self:GetCaster(),
				damage = self.total,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}

	ApplyDamage( damage_table )
end

-------------------------------------------实现暴击-----------------------------------------
function modifier_item_scorching_hot_sword:GetModifierPreAttack_CriticalStrike(keys) -- 计算当前单位的伤害系数   
	if IsServer() then                           --GetModifierPreAttack_CriticalStrike
		local attacker = self:GetParent() -- GetParent() 获取这个Mordifier所继承的单位
		local caster = self:GetCaster()
		local this_attack = caster:GetAttackDamage() -- 当前单位的攻击力
		--print("this_attack = ", this_attack)
		--local percentage = ability:GetSpecialValueFor('percentage') -- 技能的基础伤害
		local agi = attacker:GetAgility() -- 获取敏捷值
		local percentage_per_agi = 2 -- 获取敏捷伤害系数
		self.total = this_attack + agi * percentage_per_agi -- 基础伤害 + 敏捷 * 敏捷的伤害系数
		--print("total = ", total)
		return self.total -- 返回伤害
	end
end
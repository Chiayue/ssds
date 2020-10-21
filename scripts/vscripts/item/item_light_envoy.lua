-- 光明使者    使敌人流血5秒     每秒造成目标自身最大生命值5%的伤害
LinkLuaModifier("modifier_item_light_envoy", "item/item_light_envoy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_light_envoy_enemy_debuff", "item/item_light_envoy", LUA_MODIFIER_MOTION_NONE)

if item_light_envoy == nil then 
	item_light_envoy = class({})
end

function item_light_envoy:GetIntrinsicModifierName()
 	return "modifier_item_light_envoy"
end
--------------------------------------------------
if modifier_item_light_envoy == nil then
	modifier_item_light_envoy = class({})
end

function modifier_item_light_envoy:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_light_envoy:Passive() -- 默认拥有
	return true
end

function modifier_item_light_envoy:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		-- MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, -- 攻击力
		-- MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, -- 力量
		-- MODIFIER_PROPERTY_STATS_AGILITY_BONUS, -- 敏捷
		-- MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, -- 智力
		-- MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, -- 攻击速度
	}
	return funcs
end

function modifier_item_light_envoy:OnAttackLanded( keys )
	if keys.attacker ~= self:GetParent() then -- 防止敌人攻击自家英雄执行函数
		return 0
	end

	local attacker = self:GetParent()
	local enemy = keys.target
	local nowChance = RandomInt(0,100)
	--print("nowChance = ", nowChance)
	local chance = 100 --self:GetAbility():GetSpecialValueFor('chance') -- 技能的攻击概率
	local duration_timer = 10 --self:GetAbility():GetSpecialValueFor("duration_timer") -- 
	--print("chance = ", chance)
	if nowChance  > chance then
		return 0
	end

	enemy:AddNewModifier(attacker, self, "modifier_item_light_envoy_enemy_debuff", {duration = duration_timer})
end


if modifier_item_light_envoy_enemy_debuff == nil then
	modifier_item_light_envoy_enemy_debuff = class({})
end
function modifier_item_light_envoy_enemy_debuff:IsHidden()
	return false
end

function modifier_item_light_envoy_enemy_debuff:IsDebuff()
	return true
end

function modifier_item_light_envoy_enemy_debuff:IsPurgable()
	return true
end

function modifier_item_light_envoy_enemy_debuff:IsPurgeException()
	return true
end

-- function modifier_item_light_envoy_enemy_debuff:DeclareFunctions()
-- 	return {
-- 		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
-- 	}
-- end

function modifier_item_light_envoy_enemy_debuff:GetEffectName()
	return "particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff.vpcf"
end

function modifier_item_light_envoy_enemy_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_item_light_envoy_enemy_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function modifier_item_light_envoy_enemy_debuff:OnCreated( kv )
	
	self:OnIntervalThink(1)
	--self.blood_damage = -self:GetParent():GetMaxHealth() * 0.5
end

function modifier_item_light_envoy_enemy_debuff:OnIntervalThink(  )
	local hTarget = self:GetParent()

	local damage_table =
		{
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = hTarget:GetMaxHealth() * 0.5,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}

		ApplyDamage( damage_table )
end
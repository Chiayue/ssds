-- 卡赞的诅咒
LinkLuaModifier("modifier_item_kazan_of_curse", "item/item_kazan_of_curse", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_item_scorching_hot_sword_critical_strike", "item/item_kazan_of_curse", LUA_MODIFIER_MOTION_NONE)

if item_kazan_of_curse == nil then 
	item_kazan_of_curse = class({})
end

function item_kazan_of_curse:GetIntrinsicModifierName()
 	return "modifier_item_kazan_of_curse"
end
--------------------------------------------------
if modifier_item_kazan_of_curse == nil then
	modifier_item_kazan_of_curse = class({})
end

function modifier_item_kazan_of_curse:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_kazan_of_curse:Passive() -- 默认拥有
	return true
end

function modifier_item_kazan_of_curse:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, -- 攻击力
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE, -- 百分比攻击力
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, -- 攻击速度
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, -- 攻击范围
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		--MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, -- 百分比生命回复
	}
	return funcs
end

function modifier_item_kazan_of_curse:OnCreated(kv)
	self.damage_base = self:GetAbility():GetSpecialValueFor("damage_base")
	self.attack_percent = self:GetAbility():GetSpecialValueFor("attack_percent")
	self.attack_speed = self:GetAbility():GetSpecialValueFor("attack_speed")
	self.attack_range = self:GetAbility():GetSpecialValueFor("attack_range")
end

function modifier_item_kazan_of_curse:GetModifierPreAttack_BonusDamage( kv ) -- 官方方法 返回获取攻击力 到面板
	return self.damage_base
end

function modifier_item_kazan_of_curse:GetModifierDamageOutgoing_Percentage( kv ) -- 官方方法 返回获取百分比攻击力 到面板
	return self.attack_percent
end

function modifier_item_kazan_of_curse:GetModifierAttackSpeedBonus_Constant( kv ) -- 官方方法 返回获取攻击速度 到面板
	return self.attack_speed
end

function modifier_item_kazan_of_curse:GetModifierAttackRangeBonus( kv ) -- 官方方法 返回获取攻击范围 到面板
	return self.attack_range
end
-----------------------------------------10%回复造成所有属性5%的伤害----------------------------
function modifier_item_kazan_of_curse:OnAttackLanded( keys )
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
	local all_property = attacker:GetStrength() + attacker:GetAgility() + attacker:GetIntellect() -- 所有属性
	--print("all_property = ", all_property)
	local base_attack = attacker:GetAttackDamage()
	--print("base_attack = ", base_attack)
	local always_damage = base_attack + all_property * self:GetAbility():GetSpecialValueFor( "property_damage" )
	--print("always_damage = ", always_damage)
	local radius = self:GetAbility():GetSpecialValueFor( "radius" )

	local EffectName = "particles/units/heroes/hero_void_spirit/pulse/void_spirit_pulse.vpcf"
	local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hTarget)
	ParticleManager:SetParticleControl(nFXIndex, 1, Vector(radius, radius, radius))

	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(), 
		hTarget:GetOrigin(), 
		hTarget, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 0, false 
	)
	
	for _,enemy in pairs(enemies) do
		if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
			local damage = {
				victim = enemy,
				attacker = self:GetCaster(),
				damage = always_damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}

			ApplyDamage( damage )
		end
	end
end
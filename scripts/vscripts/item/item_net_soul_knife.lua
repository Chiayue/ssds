-- 净魂之刃
LinkLuaModifier("modifier_item_net_soul_knife", "item/item_net_soul_knife", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_item_net_soul_knife_attack_speed_buff", "item/item_net_soul_knife", LUA_MODIFIER_MOTION_NONE)

if item_net_soul_knife == nil then 
	item_net_soul_knife = class({})
end

-- local attack_number = 
-- {
-- 	["ATTACK_SPEED"] = 100,
-- }

function item_net_soul_knife:GetIntrinsicModifierName()
 	return "modifier_item_net_soul_knife"
end
--------------------------------------------------
if modifier_item_net_soul_knife == nil then
	modifier_item_net_soul_knife = class({})
end

function modifier_item_net_soul_knife:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_net_soul_knife:Passive() -- 默认拥有
	return true
end

function modifier_item_net_soul_knife:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, -- 攻击力
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, -- 力量
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS, -- 敏捷
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, -- 智力
		--MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, -- 攻击速度
	}
	return funcs
end

function modifier_item_net_soul_knife:OnCreated()
	self.strength = self:GetAbility():GetSpecialValueFor("strength")
	self.agility = self:GetAbility():GetSpecialValueFor("agility")
	self.intellige = self:GetAbility():GetSpecialValueFor("intellige")
	--self.attack_speed = self:GetAbility():GetSpecialValueFor("attack_speed")
	self.damage_base = self:GetAbility():GetSpecialValueFor("damage_base")
end

-- function modifier_item_net_soul_knife:GetModifierAttackSpeedBonus_Constant( kv ) -- 官方方法 返回获取到的攻击速度 到面板
-- 	return self.attack_speed
-- end

function modifier_item_net_soul_knife:GetModifierPreAttack_BonusDamage( kv ) -- 官方方法 返回获取到的攻击值 到面板
	return self.damage_base
end

function modifier_item_net_soul_knife:GetModifierBonusStats_Strength( kv ) -- 官方方法 返回获取到的属性值(力量) 到面板
	return self.strength
end

function modifier_item_net_soul_knife:GetModifierBonusStats_Agility( kv ) -- 官方方法 返回获取到的属性值(敏捷) 到面板
	return self.agility
end

function modifier_item_net_soul_knife:GetModifierBonusStats_Intellect( kv ) -- 官方方法 返回获取到的属性值(智力) 到面板
	return self.intellige
end


function modifier_item_net_soul_knife:OnAttackLanded( keys )
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
	local strength_property = attacker:GetStrength()  -- 力量
	--print("all_property = ", all_property)
	local base_attack = attacker:GetAttackDamage()
	--print("base_attack = ", base_attack)
	local always_damage = base_attack + strength_property * self:GetAbility():GetSpecialValueFor( "property_damage" )
	--print("always_damage = ", always_damage)
	local radius = self:GetAbility():GetSpecialValueFor( "radius" )

	local EffectName = "particles/units/heroes/hero_queenofpain/queen_scream_of_pain_owner.vpcf"
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
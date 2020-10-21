-- 疾风电锤 
LinkLuaModifier("modifier_item_near_gale_electric_hammer", "item/item_near_gale_electric_hammer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_speed_boots_stun_buff", "item/item_near_gale_electric_hammer", LUA_MODIFIER_MOTION_NONE)

--全局变量数值
local agi_number = 
{
	["AGI_DAMAGE"] = 0.2, -- buff增加的敏捷系数
}

if item_near_gale_electric_hammer == nil then 
	item_near_gale_electric_hammer = class({})
end

function item_near_gale_electric_hammer:GetIntrinsicModifierName()
 	return "modifier_item_near_gale_electric_hammer"
end
--------------------------------------------------
if modifier_item_near_gale_electric_hammer == nil then
	modifier_item_near_gale_electric_hammer = class({})
end

function modifier_item_near_gale_electric_hammer:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_near_gale_electric_hammer:Passive() -- 默认拥有
	return true
end

function modifier_item_near_gale_electric_hammer:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, -- 移动速度
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, -- 攻击速度
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS, -- 敏捷
	}
	return funcs
end

function modifier_item_near_gale_electric_hammer:OnCreated(kv)
	self.move_speed = self:GetAbility():GetSpecialValueFor("move_speed")
	self.speed_attack = self:GetAbility():GetSpecialValueFor("speed_attack")
	self.agiellig = self:GetAbility():GetSpecialValueFor("agiellig")
end

function modifier_item_near_gale_electric_hammer:GetModifierMoveSpeedBonus_Constant( kv ) -- 返回移动速度到面板 的官方方法
	return self.move_speed
end

function modifier_item_near_gale_electric_hammer:GetModifierAttackSpeedBonus_Constant( kv ) -- 官方方法 返回获取到移动速度 到面板
	return self.speed_attack
end

function modifier_item_near_gale_electric_hammer:GetModifierBonusStats_Agility( kv ) -- 官方方法 返回获取到的属性值(敏捷) 到面板
	return self.agiellig
end
---------------------------------实现增加%10的移动------------------------------

function modifier_item_near_gale_electric_hammer:OnAttackLanded( keys )
	local attacker = self:GetParent() -- 当前攻击 = Mordifier所继承的单位
	local nowChance = RandomInt(0,100)
	local duration_timer = self:GetAbility():GetSpecialValueFor("duration_timer")
	local chance = self:GetAbility():GetSpecialValueFor("chance") -- 技能的攻击概率
	if nowChance  > chance then
		return 0
	end

	local hTarget = keys.target
	local abil_damage = attacker:GetAgility()
	local radius = self:GetAbility():GetSpecialValueFor( "radius" )

	--创建特效
	local EffectName = "particles/econ/items/lina/lina_ti6/lina_ti6_laguna_blade_endpoint_wave.vpcf"
	local effFXIndex = ParticleManager:CreateParticle( effFXIndex, PATTACH_RENDERORIGIN_FOLLOW, hTarget )
	ParticleManager:SetParticleControl(nFXIndex, 1, Vector(radius, radius, radius))

	-- 对敌人范围
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
		if enemy ~= nil  then
			local damage = {
				victim = enemy,
				attacker = self:GetCaster(),
				damage = abil_damage * agi_number.AGI_DAMAGE,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			ApplyDamage( damage )
		end
		enemy:AddNewModifier( 
				attacker, -- self:GetCaster()
				self, --:GetAbility()
				"modifier_item_speed_boots_stun_buff", 
				{ duration = duration_timer } 
			)
	end
end
--------------------------------------------实现敌人眩晕-----------------------------------------
if modifier_item_speed_boots_stun_buff == nil then 
	modifier_item_speed_boots_stun_buff = class({})
end

function modifier_item_speed_boots_stun_buff:IsDebuff()
	return true
end

function modifier_item_speed_boots_stun_buff:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end

function modifier_item_speed_boots_stun_buff:IsStunDebuff() -- 是否是眩晕的效果
	print("IsStunDebuff")
	return true
end

function modifier_item_speed_boots_stun_buff:CheckState() -- 修饰器的状态 调整为启用眩晕
	return
	{
		[MODIFIER_STATE_STUNNED] = true, 
	}
end

function modifier_item_speed_boots_stun_buff:GetEffectName() -- 获取效果的名字
	return "particles/generic_gameplay/generic_stunned.vpcf" -- 返回眩晕的特效
end

function modifier_item_speed_boots_stun_buff:GetEffectAttachType() -- 特效绑定的位置
	return PATTACH_OVERHEAD_FOLLOW -- 绑定在   目标头顶
end

function modifier_item_speed_boots_stun_buff:GetOverrideAnimation( params ) -- 覆盖的动画
	return ACT_DOTA_DISABLED -- 伤残动画
end
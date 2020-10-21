-- 雷霆神符
LinkLuaModifier("modifier_item_thunderbolt_symbol", "item/item_thunderbolt_symbol", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_item_thunderbolt_symbol_agi_damage", "item/item_thunderbolt_symbol", LUA_MODIFIER_MOTION_NONE)

if item_thunderbolt_symbol == nil then 
	item_thunderbolt_symbol = class({})
end



function item_thunderbolt_symbol:GetIntrinsicModifierName()
 	return "modifier_item_thunderbolt_symbol"
end
--------------------------------------------------
if modifier_item_thunderbolt_symbol == nil then
	modifier_item_thunderbolt_symbol = class({})
end

function modifier_item_thunderbolt_symbol:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_thunderbolt_symbol:Passive() -- 默认拥有
	return true
end

function modifier_item_thunderbolt_symbol:DeclareFunctions()
	local funcs = 
	{
		--MODIFIER_EVENT_ON_ATTACK_START, -- 
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, -- 力量
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS, -- 敏捷
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, -- 智力
		MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
	}
	return funcs
end

function modifier_item_thunderbolt_symbol:OnCreated(kv)
	self.strength = self:GetAbility():GetSpecialValueFor("strength")
	self.agiltle = self:GetAbility():GetSpecialValueFor("agiltle")
	self.intellig = self:GetAbility():GetSpecialValueFor("intellig")
end

function modifier_item_thunderbolt_symbol:GetModifierBonusStats_Strength( kv ) -- 官方方法 返回获取到的属性值(力量) 到面板
	return self.strength
end

function modifier_item_thunderbolt_symbol:GetModifierBonusStats_Agility( kv ) -- 官方方法 返回获取到的属性值(敏捷) 到面板
	return self.agiltle
end

function modifier_item_thunderbolt_symbol:GetModifierBonusStats_Intellect( kv ) -- 官方方法 返回获取到的属性值(智力) 到面板
	return self.intellig
end

-----------------------------------------10%造成自身80%的敏捷伤害----------------------------
function modifier_item_thunderbolt_symbol:OnAttackLanded( keys )
	if keys.attacker ~= self:GetParent() then
		return 0
	end

	local radius = self:GetAbility():GetSpecialValueFor( "radius" )
	local nowChance = RandomInt(0,100)
	--print("nowChance = ", nowChance)
	local chance = self:GetAbility():GetSpecialValueFor('chance') -- 技能的攻击概率
	--print("chance = ", chance)
	if nowChance  > chance then
		return 0
	end

	local hTarget = keys.target -- 攻击的目标
	local EffectName = "particles/econ/items/disruptor/disruptor_ti8_immortal_weapon/disruptor_ti8_immortal_thunder_strike_aoe.vpcf"
	local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hTarget )
	ParticleManager:SetParticleControl(nFXIndex, 1, Vector(radius, radius, radius))
	
	local abil_damage = self:GetCaster():GetAgility() * self:GetAbility():GetSpecialValueFor( "percentage_per_agi" )
	--print("abil_damage = ", abil_damage)
	-- 范围伤害
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
				damage = abil_damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
			}
			--print("args")
			ApplyDamage( damage )
		end
	end
end
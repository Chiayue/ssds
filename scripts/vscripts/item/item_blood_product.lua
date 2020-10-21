 -- 血刃    杀敌增加生命最大值  并对敌人造成最大生命值的额外伤害
 LinkLuaModifier("modifier_item_blood_product", "item/item_blood_product", LUA_MODIFIER_MOTION_NONE)
 LinkLuaModifier("modifier_item_blood_product_bouns_dealth", "item/item_blood_product", LUA_MODIFIER_MOTION_NONE)

 if item_blood_product == nil then 
 	item_blood_product = class({})
 end

function item_blood_product:GetIntrinsicModifierName()
 	return "modifier_item_blood_product"
end

if modifier_item_blood_product == nil then 
	modifier_item_blood_product = class({})
end

function modifier_item_blood_product:IsHidden()
	return true --(self:GetStackCount() == 0)
end
function modifier_item_blood_product:IsDebuff()
	return false
end
function modifier_item_blood_product:IsPurgable()
	return false
end
function modifier_item_blood_product:IsPurgeException()
	return false
end
function modifier_item_blood_product:IsStunDebuff()
	return false
end
function modifier_item_blood_product:AllowIllusionDuplicate()
	return false
end

function modifier_item_blood_product:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE -- 不multiple就不会叠加  装备唯一
end

function modifier_item_blood_product:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, -- 攻击力
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, -- 攻击速度
		MODIFIER_PROPERTY_HEALTH_BONUS,             -- 生命值
		MODIFIER_EVENT_ON_DEATH,			-- 死亡监听
		MODIFIER_EVENT_ON_ATTACK_LANDED,     -- 攻击命中
	}
	
end

function modifier_item_blood_product:OnCreated( params )
	local hParent = self:GetParent()

	self.bouns_attack = self:GetAbility():GetSpecialValueFor("bouns_attack") -- 攻击力
	self.bouns_attack_speed = self:GetAbility():GetSpecialValueFor("bouns_attack_speed") -- 攻击速度
	self.bouns_health = self:GetAbility():GetSpecialValueFor("bouns_health") -- 生命值奖励
	self.max_health_damage = self:GetAbility():GetSpecialValueFor("max_health_damage") -- 最大生命值造成伤害的百分比
	--self.bouns_kill_health = self:GetAbility():GetSpecialValueFor("bouns_kill_health") -- 击杀敌人的生命值奖励	
end

function modifier_item_blood_product:OnAttackLanded( params )
	if params.attacker ~= self:GetParent() then
		return 0
	end
	local hParent = self:GetParent()

	local death_damage = hParent:GetMaxHealth() * self.max_health_damage
	print("death_damage=", death_damage)
	local damage_table = 
			{
				victim = params.target,
				attacker = self:GetCaster(),
				damage = death_damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			ApplyDamage(damage_table)
end

function modifier_item_blood_product:GetModifierPreAttack_BonusDamage()
	return self.bouns_attack
end

function modifier_item_blood_product:GetModifierAttackSpeedBonus_Constant()
	return self.bouns_attack_speed
end

function modifier_item_blood_product:GetModifierHealthBonus()
	return self.bouns_health
end

function modifier_item_blood_product:OnDeath( params ) -- 判断当前被攻击的单位是否死亡
	local hCaster = self:GetCaster()
	local hAttacker = params.attacker
	if IsValidEntity(hAttacker) then

		hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_item_blood_product_bouns_dealth", {})
	end
end


if modifier_item_blood_product_bouns_dealth == nil then
	modifier_item_blood_product_bouns_dealth = class({})
end

function modifier_item_blood_product_bouns_dealth:IsHidden()
	return false
end

-- function modifier_item_blood_product_bouns_dealth:GetAttributes()
-- 	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT
-- end

function modifier_item_blood_product_bouns_dealth:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_HEALTH_BONUS,             -- 生命值
	}
	
end

function modifier_item_blood_product_bouns_dealth:OnCreated(  )
	self.bouns_kill_health = self:GetAbility():GetSpecialValueFor("bouns_kill_health") -- 击杀敌人的生命值奖励
	self:SetStackCount(1)
end

function modifier_item_blood_product_bouns_dealth:OnRefresh(  )
	if IsServer() then
		self:IncrementStackCount()
		self:GetParent():CalculateStatBonus()
	end
end

function modifier_item_blood_product_bouns_dealth:GetModifierHealthBonus()
	--print("factor=", self.factor)
	return self:GetStackCount() * self.bouns_kill_health 
end
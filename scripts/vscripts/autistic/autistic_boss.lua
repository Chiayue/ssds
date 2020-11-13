-- 敌人Boss技能

-- 【潜力爆发】受到伤害移动速度提高
LinkLuaModifier("modifier_ability_boss_speed_burst", "autistic/autistic_boss", LUA_MODIFIER_MOTION_NONE)
ability_boss_speed_burst = {}
function ability_boss_speed_burst:GetIntrinsicModifierName()
	return "modifier_ability_boss_speed_burst"
end

modifier_ability_boss_speed_burst = {}
function modifier_ability_boss_speed_burst:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN
    }
end
function modifier_ability_boss_speed_burst:IsHidden() return false end
function modifier_ability_boss_speed_burst:OnCreated() self:SetStackCount(0) end
function modifier_ability_boss_speed_burst:GetModifierMoveSpeed_AbsoluteMin() return 250 + self:GetStackCount() * 20 end
function modifier_ability_boss_speed_burst:GetModifierIncomingDamage_Percentage(keys) 
	local nDamagePer = self:GetStackCount()
	if nDamagePer > 50 then nDamagePer = 50 end
	return -nDamagePer
end

function modifier_ability_boss_speed_burst:OnTakeDamage(keys)
	local hParent = self:GetParent()
	if keys.unit == hParent and self:GetAbility():IsCooldownReady() then
		self:GetAbility():UseResources(true, true, true)
		self:IncrementStackCount()
	end
	
end
---------------   攻击速度奖励  -----------------------------------
local reweard = {5,10,15}

if modifier_reward_attackspeed == nil then
	modifier_reward_attackspeed = class({})
end

function modifier_reward_attackspeed:IsHidden()
	return true
end

function modifier_reward_attackspeed:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_reward_attackspeed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_reward_attackspeed:GetModifierAttackSpeedBonus_Constant()
	local stack = self:GetStackCount()
	return reweard[stack]
end
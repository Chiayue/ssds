---------------   射程奖励  -----------------------------------
local reweard = {40,50,60}

if modifier_reward_range_bonus == nil then
	modifier_reward_range_bonus = class({})
end

function modifier_reward_range_bonus:IsHidden()
	return true
end

function modifier_reward_range_bonus:GetTexture()
	return "attribute_bonus"
end

function modifier_reward_range_bonus:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_reward_range_bonus:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
	return funcs
end

function modifier_reward_range_bonus:GetModifierAttackRangeBonus()
	local stack = self:GetStackCount()
	return reweard[stack]
end
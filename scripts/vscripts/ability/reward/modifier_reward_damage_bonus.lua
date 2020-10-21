---------------   最终伤害奖励  -----------------------------------
if modifier_reward_damage_bonus == nil then
	modifier_reward_damage_bonus = class({})
end

function modifier_reward_damage_bonus:IsHidden() return true end
function modifier_reward_damage_bonus:RemoveOnDeath() return false end
function modifier_reward_damage_bonus:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

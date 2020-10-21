---------------   生命恢复奖励  -----------------------------------
local reweard = {5,10,20,50,100}

if modifier_reward_hp_regen == nil then
	modifier_reward_hp_regen = class({})
end

function modifier_reward_hp_regen:IsHidden()
	return true
end

function modifier_reward_hp_regen:GetTexture()
	return "attribute_bonus"
end

function modifier_reward_hp_regen:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_reward_hp_regen:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

function modifier_reward_hp_regen:GetModifierConstantHealthRegen()
	local stack = self:GetStackCount()
	return reweard[stack]
end
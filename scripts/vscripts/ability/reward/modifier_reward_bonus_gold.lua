local reward = {1,2,3}

if modifier_reward_bonus_gold == nil then
	modifier_reward_bonus_gold = class({})
end

function modifier_reward_bonus_gold:IsHidden()
	return true
end

function modifier_reward_bonus_gold:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_reward_bonus_gold:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_reward_bonus_gold:OnDeath(params)
	local hCaster = self:GetCaster()
	local hAttacker = params.attacker
	if hAttacker ~= hCaster then
		return
	end
	local nPlayerID = self:GetCaster():GetPlayerID()
	local bonus = self:GetStackCount()
	PlayerResource:ModifyGold(nPlayerID,bonus,true,DOTA_ModifyGold_CreepKill)
	PopupGoldGain(hCaster, bonus)
end
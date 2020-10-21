LinkLuaModifier( "modifier_ability_flagstone_bounty_hunter", "ability/flagstone/ability_flagstone_bounty_hunter.lua",LUA_MODIFIER_MOTION_NONE )

local hBonusGold = {2,4,8}
if ability_flagstone_bounty_hunter == nil then
	ability_flagstone_bounty_hunter = {}
end

function ability_flagstone_bounty_hunter:GetIntrinsicModifierName()
	return "modifier_ability_flagstone_bounty_hunter"
end

if modifier_ability_flagstone_bounty_hunter == nil then
	modifier_ability_flagstone_bounty_hunter = {}
end

function  modifier_ability_flagstone_bounty_hunter:IsHidden()
	return true
end
function modifier_ability_flagstone_bounty_hunter:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_ability_flagstone_bounty_hunter:OnCreated()
	local nLevel = self:GetAbility():GetLevel() or 1
	self.bonus = hBonusGold[nLevel]
end

function modifier_ability_flagstone_bounty_hunter:OnRefresh()
	local nLevel = self:GetAbility():GetLevel() or 1
	self.bonus = hBonusGold[nLevel]
end

function modifier_ability_flagstone_bounty_hunter:OnDeath(args)
	if not IsServer() then return end
	local hAttacker = args.attacker
	local hCaster = self:GetParent()
	if hAttacker ~= hCaster then
		return
	end
	local nPlayerID = self:GetCaster():GetPlayerID()
	PlayerResource:ModifyGold(nPlayerID,self.bonus,true,DOTA_ModifyGold_CreepKill)
	PopupGoldGain(hCaster, self.bonus)
end

LinkLuaModifier( "modifier_Upgrade_Kill_Bonus", "ability/upgrade/Upgrade_Kill_Bonus.lua",LUA_MODIFIER_MOTION_NONE )


if Upgrade_Kill_Bonus == nil then
	Upgrade_Kill_Bonus = {}
end

function Upgrade_Kill_Bonus:GetIntrinsicModifierName()
 	return "modifier_Upgrade_Kill_Bonus"
end

if modifier_Upgrade_Kill_Bonus == nil then
	modifier_Upgrade_Kill_Bonus = {}
end

function modifier_Upgrade_Kill_Bonus:IsHidden()
	return true
end

function modifier_Upgrade_Kill_Bonus:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_Upgrade_Kill_Bonus:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_Upgrade_Kill_Bonus:OnCreated()
end

function modifier_Upgrade_Kill_Bonus:OnRefresh()
	if IsServer() then
		self:IncrementStackCount()
	end

end

function modifier_Upgrade_Kill_Bonus:OnDeath(args)
	if not IsServer() then return end
	local hAttacker = args.attacker
	local hCaster = self:GetParent()
	if hAttacker ~= hCaster then
		return
	end
	local nPlayerID = self:GetCaster():GetPlayerID()
	local nBonus = self:GetStackCount() * self:GetAbility():GetSpecialValueFor( "Upgrade_Kill_Bonus" )
	local nMaxBonus = 2
	PlayerResource:ModifyGold(nPlayerID,nBonus,true,DOTA_ModifyGold_CreepKill)
	PopupGoldGain(hCaster, nBonus)
	if self:GetStackCount() == 10 then
		Player_Data():AddPoint(nPlayerID,nMaxBonus)
		PopupWoodGain(hCaster, nMaxBonus)
	end
end

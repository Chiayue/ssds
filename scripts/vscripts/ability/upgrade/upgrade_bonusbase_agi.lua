LinkLuaModifier( "modifier_Upgrade_bonusBase_Agi", "ability/upgrade/Upgrade_bonusBase_Agi.lua",LUA_MODIFIER_MOTION_NONE )

if modifier_Upgrade_bonusBase_Agi == nil then
	modifier_Upgrade_bonusBase_Agi = {}
end

function modifier_Upgrade_bonusBase_Agi:IsHidden()
	return true
end

function modifier_Upgrade_bonusBase_Agi:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

-- function modifier_Upgrade_bonusBase_Agi:OnCreated()
-- 	self.nBonus = 0
-- end

-- function modifier_Upgrade_bonusBase_Agi:DeclareFunctions()
-- 	local funcs = {
-- 		MODIFIER_PROPERTY_STATS_AGILITY_BONUS
-- 	}
-- 	return funcs
-- end

function modifier_Upgrade_bonusBase_Agi:OnRefresh()
	if IsServer() then
		self:IncrementStackCount()
	end
end

-- function modifier_Upgrade_bonusBase_Agi:OnIntervalThink()
-- 	-- body
-- 	if IsServer() then 
-- 		local nAttr = self:GetCaster():GetAgility() - self:GetModifierBonusStats_Agility()
-- 		self.nBonus = nAttr * 0.3
-- 	end
-- end

-- function modifier_Upgrade_bonusBase_Agi:GetModifierBonusStats_Agility()
-- 	return self.nBonus
-- end
LinkLuaModifier( "modifier_Upgrade_bonusBase_Int", "ability/upgrade/Upgrade_bonusBase_Int.lua",LUA_MODIFIER_MOTION_NONE )

if modifier_Upgrade_bonusBase_Int == nil then
	modifier_Upgrade_bonusBase_Int = {}
end

function modifier_Upgrade_bonusBase_Int:IsHidden()
	return true
end

function modifier_Upgrade_bonusBase_Int:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

-- function modifier_Upgrade_bonusBase_Int:DeclareFunctions()
-- 	local funcs = {
-- 		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
-- 	}
-- 	return funcs
-- end

-- function modifier_Upgrade_bonusBase_Int:OnCreated()
-- 	self.nBonus = 0
-- end

function modifier_Upgrade_bonusBase_Int:OnRefresh()
	if IsServer() then
		self:IncrementStackCount()
		-- if self:GetStackCount() == 10 then 
		-- 	self:StartIntervalThink(1)
		-- end
	end
end

-- function modifier_Upgrade_bonusBase_Int:OnIntervalThink()
-- 	-- body
-- 	if IsServer() then 
-- 		local nAttr = self:GetCaster():GetIntellect() - self:GetModifierBonusStats_Intellect()
-- 		self.nBonus = nAttr * 0.3
-- 	end
-- end

-- function modifier_Upgrade_bonusBase_Int:GetModifierBonusStats_Intellect()
-- 	return self.nBonus
-- end
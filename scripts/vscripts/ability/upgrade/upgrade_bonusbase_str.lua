LinkLuaModifier( "modifier_Upgrade_bonusBase_Str", "ability/upgrade/Upgrade_bonusBase_Str.lua",LUA_MODIFIER_MOTION_NONE )

if modifier_Upgrade_bonusBase_Str == nil then
	modifier_Upgrade_bonusBase_Str = {}
end

function modifier_Upgrade_bonusBase_Str:IsHidden()
	return true
end

function modifier_Upgrade_bonusBase_Str:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

-- function modifier_Upgrade_bonusBase_Str:DeclareFunctions()
-- 	local funcs = {
-- 		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
-- 	}
-- 	return funcs
-- end

-- function modifier_Upgrade_bonusBase_Str:OnCreated()
-- 	self.nBonus = 0
-- end	

function modifier_Upgrade_bonusBase_Str:OnRefresh()
	if IsServer() then
		self:IncrementStackCount()
		-- if self:GetStackCount() == 10 then 
		-- 	self:StartIntervalThink(1)
		-- end
	end
end

-- function modifier_Upgrade_bonusBase_Str:OnIntervalThink()
-- 	if IsServer() then 
-- 		local nAttr = self:GetCaster():GetStrength() - self:GetModifierBonusStats_Strength()
-- 		self.nBonus = nAttr * 0.3
-- 	end
-- end

-- function modifier_Upgrade_bonusBase_Str:GetModifierBonusStats_Strength()
-- 	return self.nBonus
-- end

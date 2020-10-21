LinkLuaModifier( "modifier_Upgrade_MaxHeath", "ability/upgrade/Upgrade_MaxHeath.lua",LUA_MODIFIER_MOTION_NONE )

if modifier_Upgrade_MaxHeath == nil then
	modifier_Upgrade_MaxHeath = {}
end

function modifier_Upgrade_MaxHeath:IsHidden()
	return true
end

function modifier_Upgrade_MaxHeath:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_Upgrade_MaxHeath:OnCreated()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_MaxHeath" )
	self.max_bonus = 0
end

function modifier_Upgrade_MaxHeath:OnRefresh()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_MaxHeath" )
	if IsServer() then
		self:IncrementStackCount()
		-- if self:GetStackCount() == 10 then
		-- 	self:StartIntervalThink(0.2)
		-- end
	end
	
end

function modifier_Upgrade_MaxHeath:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

-- function modifier_Upgrade_MaxHeath:OnIntervalThink()
-- 	-- body
-- 	if IsServer() then 
-- 		self:GetParent():CalculateStatBonus()
-- 		local nMaxHealth = self:GetCaster():GetMaxHealth() - self.max_bonus
-- 		self.max_bonus = math.floor(nMaxHealth * 0.5)
-- 	end
-- end

function modifier_Upgrade_MaxHeath:GetModifierHealthBonus()
	return self.bonus * self:GetStackCount()
end

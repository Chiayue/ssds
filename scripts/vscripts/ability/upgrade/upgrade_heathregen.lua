LinkLuaModifier( "modifier_Upgrade_HeathRegen", "ability/upgrade/Upgrade_HeathRegen.lua",LUA_MODIFIER_MOTION_NONE )

if modifier_Upgrade_HeathRegen == nil then
	modifier_Upgrade_HeathRegen = {}
end

function modifier_Upgrade_HeathRegen:IsHidden()
	return true
end

function modifier_Upgrade_HeathRegen:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_Upgrade_HeathRegen:OnCreated()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_HeathRegen" )
	self.max_bonus = 0
end

function modifier_Upgrade_HeathRegen:OnRefresh()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_HeathRegen" )
	if IsServer() then
		self:IncrementStackCount()
	end
	if self:GetStackCount() == 10 then 
		self.max_bonus = 3
	end
end

function modifier_Upgrade_HeathRegen:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
	}
	return funcs
end

function modifier_Upgrade_HeathRegen:GetModifierConstantHealthRegen()
	return self.bonus * self:GetStackCount()
end

function modifier_Upgrade_HeathRegen:GetModifierHealthRegenPercentage()
	return self.max_bonus
end

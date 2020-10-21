LinkLuaModifier( "modifier_Upgrade_MaxDamage", "ability/upgrade/Upgrade_MaxDamage.lua",LUA_MODIFIER_MOTION_NONE )

if modifier_Upgrade_MaxDamage == nil then
	modifier_Upgrade_MaxDamage = {}
end

function modifier_Upgrade_MaxDamage:IsHidden()
	return true
end

function modifier_Upgrade_MaxDamage:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_Upgrade_MaxDamage:OnCreated()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_MaxDamage" )
	self.max_bonus = 0
end

function modifier_Upgrade_MaxDamage:OnRefresh()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_MaxDamage" )
	if IsServer() then
		self:IncrementStackCount()
	end
	if self:GetStackCount() == 10 then
		self.max_bonus = 60
	end
end

function modifier_Upgrade_MaxDamage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE
	}
	return funcs
end

function modifier_Upgrade_MaxDamage:GetModifierBaseAttack_BonusDamage()
	return self.bonus * self:GetStackCount()
end

function modifier_Upgrade_MaxDamage:GetModifierBaseDamageOutgoing_Percentage()
	return self.max_bonus
end
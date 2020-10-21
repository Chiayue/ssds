LinkLuaModifier( "modifier_Upgrade_Armor", "ability/upgrade/Upgrade_Armor.lua",LUA_MODIFIER_MOTION_NONE )

if modifier_Upgrade_Armor == nil then
	modifier_Upgrade_Armor = {}
end

function modifier_Upgrade_Armor:IsHidden()
	return true
end

function modifier_Upgrade_Armor:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_Upgrade_Armor:OnCreated()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_Armor" )
	self.max_bonus = 0
end

function modifier_Upgrade_Armor:OnRefresh()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_Armor" )
	if IsServer() then
		--print(self.bonus)
		self:IncrementStackCount()
		if self:GetStackCount() == 10 then
			self.max_bonus = 30
		end
	end
	
end

function modifier_Upgrade_Armor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
	}
	return funcs
end

function modifier_Upgrade_Armor:GetModifierPhysicalArmorBonus()
	return self.bonus * self:GetStackCount()
end
function modifier_Upgrade_Armor:GetModifierEvasion_Constant()
	return self.max_bonus
end
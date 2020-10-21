LinkLuaModifier( "modifier_Upgrade_Base_Attackspeed", "ability/upgrade/Upgrade_Base_Attackspeed.lua",LUA_MODIFIER_MOTION_NONE )

if modifier_Upgrade_Base_Attackspeed == nil then
	modifier_Upgrade_Base_Attackspeed = {}
end

function modifier_Upgrade_Base_Attackspeed:IsHidden()
	return true
end

function modifier_Upgrade_Base_Attackspeed:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_Upgrade_Base_Attackspeed:OnCreated()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_Base_Attackspeed" )

end

function modifier_Upgrade_Base_Attackspeed:OnRefresh()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_Base_Attackspeed" )
	if IsServer() then
		self:IncrementStackCount()
		if self:GetStackCount() == 10 then
			local hBonusBA = self:GetCaster():FindAbilityByName("bonus_base_attackspeed")
			if hBonusBA ~= nil then 
				hBonusBA:SetHidden(false)
			end
		end
	end
	
end

function modifier_Upgrade_Base_Attackspeed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}
	return funcs
end

function modifier_Upgrade_Base_Attackspeed:GetModifierBaseAttackTimeConstant()
	if self:GetCaster():HasModifier("modifier_bonus_base_attackspeed") then
		return 0.9
	else
		return 0.6 - (self.bonus * self:GetStackCount())
	end
end

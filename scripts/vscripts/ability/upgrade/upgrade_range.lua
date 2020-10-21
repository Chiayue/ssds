LinkLuaModifier( "modifier_Upgrade_Range", "ability/upgrade/Upgrade_Range.lua",LUA_MODIFIER_MOTION_NONE )

if modifier_Upgrade_Range == nil then
	modifier_Upgrade_Range = {}
end

function modifier_Upgrade_Range:IsHidden()
	return true
end

function modifier_Upgrade_Range:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_Upgrade_Range:OnCreated()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_Range" )
	self.max_bonus = 0
end

function modifier_Upgrade_Range:OnRefresh()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_Range" )
	if IsServer() then
		self:IncrementStackCount()
		if self:GetStackCount() == 10 then
			self:StartIntervalThink(1)
		end
	end
	
end

function modifier_Upgrade_Range:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
	}
	return funcs
end

function modifier_Upgrade_Range:GetModifierAttackRangeBonus()
	return self.bonus * self:GetStackCount()
end


function modifier_Upgrade_Range:OnIntervalThink()
	if IsServer() then
		--  射程来自 武器，天赋
		local nBaseRange = self:GetCaster():GetBaseAttackRange()
		local nBowRange = 0
		local hBow = self:GetCaster():FindModifierByName("modifier_item_archer_bow")
		if hBow ~= nil then
			nBowRange = hBow:GetModifierAttackRangeBonus()
		end
		local nRangeTotal = 500 + nBowRange + nBaseRange
		self.max_bonus = nRangeTotal * 0.5
	end
end

function modifier_Upgrade_Range:GetModifierBaseAttack_BonusDamage()
	return self.max_bonus
end
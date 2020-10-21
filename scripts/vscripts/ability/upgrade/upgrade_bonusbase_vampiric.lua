LinkLuaModifier( "modifier_Upgrade_bonusBase_vampiric", "ability/upgrade/Upgrade_bonusBase_vampiric.lua",LUA_MODIFIER_MOTION_NONE )

if modifier_Upgrade_bonusBase_vampiric == nil then
	modifier_Upgrade_bonusBase_vampiric = {}
end

function modifier_Upgrade_bonusBase_vampiric:IsHidden()
	return true
end

function modifier_Upgrade_bonusBase_vampiric:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_Upgrade_bonusBase_vampiric:OnCreated()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_bonusBase_vampiric" )
end

function modifier_Upgrade_bonusBase_vampiric:OnRefresh()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_bonusBase_vampiric" )
	if IsServer() then
		self:IncrementStackCount()
	end
	
end

function modifier_Upgrade_bonusBase_vampiric:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_Upgrade_bonusBase_vampiric:OnAttackLanded(params)
	if IsServer() then
		local hTarget = params.target
		local hAttacker = params.attacker
		-- 普通攻击时有一定的几率对目标范围造成的伤害。 
		if hAttacker == self:GetParent() and hAttacker:HasModifier("modifier_Upgrade_bonusBase_vampiric") then
			local nHealAmount = self:GetStackCount() * self:GetAbility():GetSpecialValueFor( "Upgrade_bonusBase_vampiric" )
			hAttacker:Heal(nHealAmount,hAttacker)
			if self:GetStackCount() == 10 then
				local nDamage = params.original_damage
				local nHeal = nDamage * 0.01
				hAttacker:Heal( nHeal, hAttacker )
				nHealAmount = nHealAmount + nHeal
			end
			--PopupHealing(hAttacker, nHealAmount)
		end
	end
end

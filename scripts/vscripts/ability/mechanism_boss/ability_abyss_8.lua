-- 钢铁护甲		ability_abyss_8

LinkLuaModifier("modifier_ability_abyss_8", "ability/mechanism_Boss/ability_abyss_8", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_8 == nil then 
	ability_abyss_8 = class({})
end

function ability_abyss_8:IsHidden( ... )
	return true
end

function ability_abyss_8:GetIntrinsicModifierName()
	return "modifier_ability_abyss_8"
end

if modifier_ability_abyss_8 == nil then 
	modifier_ability_abyss_8 = class({})
end

function modifier_ability_abyss_8:IsHidden( ... )
	return false
end

function modifier_ability_abyss_8:OnCreated( kv )
	local hCaster = self:GetCaster()
	self.IncomingDamage_value = -100
	if IsServer() then 
		self:SetStackCount(10)
		--hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_ability_abyss_8_Reduction_of_injury", {})
	end 
end

function modifier_ability_abyss_8:DeclareFunctions( ... )
	return 
		{
			MODIFIER_EVENT_ON_ATTACKED, 
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, -- 减伤
		}
end

function modifier_ability_abyss_8:OnAttacked( kv )
	local hAttacker = kv.attacker   -- 攻击者	英雄
	local target = kv.target   		-- 受害者   是我
	local units = kv.units
	--print("1")
	local IncomingDamage_Count = self:GetStackCount()

	if hAttacker ~= nil and IncomingDamage_Count > 0 then 
		
		self.IncomingDamage_value = (IncomingDamage_Count * (-10) )

	else
		self:GetParent():RemoveModifierByName("modifier_ability_abyss_8")
	end
end

function modifier_ability_abyss_8:GetModifierIncomingDamage_Percentage( ... )
	return self.IncomingDamage_value
end
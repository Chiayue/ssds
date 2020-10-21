LinkLuaModifier( "modifier_ability_flagstone_maxhealth", "ability/flagstone/ability_flagstone_maxhealth.lua",LUA_MODIFIER_MOTION_NONE )

if ability_flagstone_maxhealth == nil then
	ability_flagstone_maxhealth = {}
end

function ability_flagstone_maxhealth:GetIntrinsicModifierName()
	return "modifier_ability_flagstone_maxhealth"
end

if modifier_ability_flagstone_maxhealth == nil then
	modifier_ability_flagstone_maxhealth = {}
end

function  modifier_ability_flagstone_maxhealth:IsHidden()
	return true
end

function modifier_ability_flagstone_maxhealth:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

function modifier_ability_flagstone_maxhealth:OnCreated()
	self.bonus = 0
	if IsServer() then 
		self:StartIntervalThink(1)
	end
end

function modifier_ability_flagstone_maxhealth:OnIntervalThink()
	if IsServer() then 
		self:GetParent():CalculateStatBonus()
		local nMaxHealth = self:GetCaster():GetMaxHealth() - self:GetModifierHealthBonus()
		self.bonus = nMaxHealth * self:GetAbility():GetSpecialValueFor( "bonus" ) * 0.01
		--print(self.bonus_maxhealth)
	end
end



function modifier_ability_flagstone_maxhealth:GetModifierHealthBonus()
	return self.bonus
end
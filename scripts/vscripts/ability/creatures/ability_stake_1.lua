LinkLuaModifier("modifier_ability_stake_1", "ability/creatures/ability_stake_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_stake_1_disable", "ability/creatures/ability_stake_1", LUA_MODIFIER_MOTION_NONE)



if ability_stake_1 == nil then ability_stake_1 = {} end
function ability_stake_1:GetIntrinsicModifierName() return "modifier_ability_stake_1" end

if modifier_ability_stake_1 == nil then modifier_ability_stake_1 = {} end

function modifier_ability_stake_1:IsHidden() return true end
function modifier_ability_stake_1:DeclareFunctions() 
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MIN_HEALTH
	} 
end

function modifier_ability_stake_1:OnTakeDamage(keys)
	if IsServer() then
		if keys.unit == self:GetParent() and keys.attacker ~= self:GetParent() then
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ability_stake_1_disable", {duration = 3})
		end
	end
end

function modifier_ability_stake_1:GetModifierHealthRegenPercentage()
	if self:GetParent():HasModifier("modifier_ability_stake_1_disable") then
		return 0
	else
		return 30
	end
end

function modifier_ability_stake_1:GetMinHealth()
	return 1
end
if modifier_ability_stake_1_disable == nil then modifier_ability_stake_1_disable ={} end
function modifier_ability_stake_1_disable:IsHidden() return true end
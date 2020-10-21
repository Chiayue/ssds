LinkLuaModifier( "modifier_archon_passive_rage", "ability/archon_passive_rage.lua",LUA_MODIFIER_MOTION_NONE )

-------------------------------------------------
--Abilities
if archon_passive_rage == nil then
	archon_passive_rage = class({})
end

function archon_passive_rage:GetIntrinsicModifierName()
 	return "modifier_archon_passive_rage"
end
--------------------------------------------------
if modifier_archon_passive_rage == nil then
	modifier_archon_passive_rage = class({})
end

function modifier_archon_passive_rage:IsHidden() return true end

function modifier_archon_passive_rage:OnCreated()
	if IsServer() then
		self.damage_max = 0
		self.damage_loss = 0
		self.regen = 0
		self.series_damage = 0
		self.series_attackspeed = 0
		
		self:StartIntervalThink(0.2) 
	end
end

function modifier_archon_passive_rage:OnRefresh()
	-- Variables
	if IsServer() then
		self:GetParent():CalculateStatBonus()
	end
end

function modifier_archon_passive_rage:OnAttack(params)
	-- if not IsServer() then return end
	local hAttacker = params.attacker
	if hAttacker == self:GetParent() and hAttacker:HasAbility("archon_passive_rage") then
		if hAttacker:HasModifier("modifier_item_archer_bow_multe") then return end
		if hAttacker:HasModifier("modifier_tech_max_attackspeed_multe") then return end

		local caster = self:GetParent()
		local health = caster:GetHealth()
		local health_cost = health * 0.02
	    local new_health = (health - health_cost)
	    caster:ModifyHealth(new_health, ability, false, 0)
	end
end

function modifier_archon_passive_rage:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local max_health = caster:GetMaxHealth()
		local health = caster:GetHealth()
		local nTalentStack = self:GetCaster():GetModifierStackCount("modifier_series_reward_talent_ruin", self:GetCaster() )
		local nSeriesBonus = 0
		if nTalentStack >= 2 then nSeriesBonus = 5 end
		self.damage_max = max_health * self:GetAbility():GetSpecialValueFor( "bonus_damage_health" ) * 0.01
		self.damage_loss = (max_health - health) * (self:GetAbility():GetSpecialValueFor( "bonus_damage_loss" ) + nSeriesBonus )* 0.01
		self.regen = (max_health - health) * 0.02
	end
end

function modifier_archon_passive_rage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_archon_passive_rage:GetModifierBaseAttack_BonusDamage()
	return self.damage_max + self.damage_loss
end

function modifier_archon_passive_rage:GetModifierAttackSpeedBonus_Constant()
	return self.series_attackspeed
end


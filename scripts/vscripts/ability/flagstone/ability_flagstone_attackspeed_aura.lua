-- 加速光环
LinkLuaModifier( "modifier_ability_flagstone_attackspeed_aura", "ability/flagstone/ability_flagstone_attackspeed_aura.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_flagstone_attackspeed_aura_effect", "ability/flagstone/ability_flagstone_attackspeed_aura.lua",LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------
local hBonusAttackspeed = {10,20,40}

if ability_flagstone_attackspeed_aura == nil then
	ability_flagstone_attackspeed_aura = class({})
end

function ability_flagstone_attackspeed_aura:GetIntrinsicModifierName()
 	return "modifier_ability_flagstone_attackspeed_aura"
end
--------------------------------------------------
if modifier_ability_flagstone_attackspeed_aura == nil then
	modifier_ability_flagstone_attackspeed_aura = class({})
end

function modifier_ability_flagstone_attackspeed_aura:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_attackspeed_aura:IsAura()
	return true
end

function modifier_ability_flagstone_attackspeed_aura:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_ability_flagstone_attackspeed_aura:RemoveOnDeath()
    return false -- 死亡不移除
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_attackspeed_aura:GetModifierAura()
	return "modifier_ability_flagstone_attackspeed_aura_effect"
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_attackspeed_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_attackspeed_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_attackspeed_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_attackspeed_aura:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_attackspeed_aura:OnCreated( kv )
	self.aura_radius = 1200
	if IsServer() and self:GetParent() ~= self:GetCaster() then
		self:StartIntervalThink( 1 )
	end
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_attackspeed_aura:OnRefresh( kv )
	self.aura_radius = 1200
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_attackspeed_aura:OnIntervalThink()
	if self:GetCaster() ~= self:GetParent() and self:GetCaster():IsAlive() then
		self:Destroy()
	end
end

if modifier_ability_flagstone_attackspeed_aura_effect == nil then
	modifier_ability_flagstone_attackspeed_aura_effect ={}
end

function modifier_ability_flagstone_attackspeed_aura_effect:OnCreated( kv )
	local nLevel = self:GetAbility():GetLevel() or 1
	self.attack_speed = hBonusAttackspeed[nLevel]
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_attackspeed_aura_effect:OnRefresh( kv )
	local nLevel = self:GetAbility():GetLevel() or 1
	self.attack_speed = hBonusAttackspeed[nLevel]
end

function modifier_ability_flagstone_attackspeed_aura_effect:IsDebuff()
	return false
end

function modifier_ability_flagstone_attackspeed_aura_effect:IsHidden()
	return true
end

function modifier_ability_flagstone_attackspeed_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_ability_flagstone_attackspeed_aura_effect:GetModifierAttackSpeedBonus_Constant( params )
	return 40
end
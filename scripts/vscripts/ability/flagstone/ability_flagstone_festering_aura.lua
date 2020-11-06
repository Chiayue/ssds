-- 腐蚀光环
LinkLuaModifier( "modifier_ability_flagstone_festering_aura", "ability/flagstone/ability_flagstone_festering_aura.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_flagstone_festering_aura_effect", "ability/flagstone/ability_flagstone_festering_aura.lua",LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------
local nFestering = {10,20,40}
if ability_flagstone_festering_aura == nil then
	ability_flagstone_festering_aura = class({})
end

function ability_flagstone_festering_aura:GetIntrinsicModifierName()
 	return "modifier_ability_flagstone_festering_aura"
end
--------------------------------------------------
if modifier_ability_flagstone_festering_aura == nil then
	modifier_ability_flagstone_festering_aura = class({})
end

function modifier_ability_flagstone_festering_aura:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_festering_aura:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_festering_aura:GetModifierAura()
	return "modifier_ability_flagstone_festering_aura_effect"
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_festering_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_festering_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_festering_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_festering_aura:GetAuraRadius()
	return 1200
end



if modifier_ability_flagstone_festering_aura_effect == nil then
	modifier_ability_flagstone_festering_aura_effect ={}
end

function modifier_ability_flagstone_festering_aura_effect:OnCreated( kv )
	self.bonus = self:GetAbility():GetSpecialValueFor( "bonus" )
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_festering_aura_effect:OnRefresh( kv )
	self.bonus = self:GetAbility():GetSpecialValueFor( "bonus" )
end

function modifier_ability_flagstone_festering_aura_effect:IsDebuff()
	return true
end

function modifier_ability_flagstone_festering_aura_effect:IsHidden()
	return false
end

function modifier_ability_flagstone_festering_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
end

function modifier_ability_flagstone_festering_aura_effect:GetModifierMagicalResistanceBonus( params )
	return -self.bonus
end
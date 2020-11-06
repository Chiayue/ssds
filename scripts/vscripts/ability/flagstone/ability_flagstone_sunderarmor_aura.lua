-- 腐蚀光环
LinkLuaModifier( "modifier_ability_flagstone_sunderarmor_aura", "ability/flagstone/ability_flagstone_sunderarmor_aura.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_flagstone_sunderarmor_aura_effect", "ability/flagstone/ability_flagstone_sunderarmor_aura.lua",LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------
local nFestering = {5,10,20}

if ability_flagstone_sunderarmor_aura == nil then
	ability_flagstone_sunderarmor_aura = class({})
end

function ability_flagstone_sunderarmor_aura:GetIntrinsicModifierName()
 	return "modifier_ability_flagstone_sunderarmor_aura"
end
--------------------------------------------------
if modifier_ability_flagstone_sunderarmor_aura == nil then
	modifier_ability_flagstone_sunderarmor_aura = class({})
end

function modifier_ability_flagstone_sunderarmor_aura:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_sunderarmor_aura:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_sunderarmor_aura:GetModifierAura()
	return "modifier_ability_flagstone_sunderarmor_aura_effect"
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_sunderarmor_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_sunderarmor_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_sunderarmor_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_sunderarmor_aura:GetAuraRadius()
	return 1200
end

--------------------------------------------------------------------------------

if modifier_ability_flagstone_sunderarmor_aura_effect == nil then
	modifier_ability_flagstone_sunderarmor_aura_effect ={}
end


function modifier_ability_flagstone_sunderarmor_aura_effect:IsDebuff()
	return true
end

function modifier_ability_flagstone_sunderarmor_aura_effect:IsHidden()
	return true
end

function modifier_ability_flagstone_sunderarmor_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end

function modifier_ability_flagstone_sunderarmor_aura_effect:GetModifierPhysicalArmorBonus( params )
	return -20
end
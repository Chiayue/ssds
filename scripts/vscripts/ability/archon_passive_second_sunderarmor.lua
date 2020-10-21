-- 破甲光环

LinkLuaModifier( "modifier_archon_passive_second_sunderarmor", "ability/archon_passive_second_sunderarmor.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_second_sunderarmor_debuff", "ability/archon_passive_second_sunderarmor.lua",LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------
if archon_passive_second_sunderarmor == nil then
	archon_passive_second_sunderarmor = class({})
end

function archon_passive_second_sunderarmor:GetIntrinsicModifierName()
 	return "modifier_archon_passive_second_sunderarmor"
end
--------------------------------------------------
if modifier_archon_passive_second_sunderarmor == nil then
	modifier_archon_passive_second_sunderarmor = class({})
end

function modifier_archon_passive_second_sunderarmor:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_sunderarmor:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_sunderarmor:GetModifierAura()
	return "modifier_archon_passive_second_sunderarmor_debuff"
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_sunderarmor:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_sunderarmor:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_sunderarmor:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_sunderarmor:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_sunderarmor:OnCreated( kv )
	self.aura_radius = 1200
	if IsServer() and self:GetParent() ~= self:GetCaster() then
		self:StartIntervalThink( 0.5 )
	end
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_sunderarmor:OnRefresh( kv )
	self.aura_radius = 1200
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_sunderarmor:OnIntervalThink()
	if self:GetCaster() ~= self:GetParent() and self:GetCaster():IsAlive() then
		self:Destroy()
	end
end

if modifier_archon_passive_second_sunderarmor_debuff == nil then
	modifier_archon_passive_second_sunderarmor_debuff ={}
end

function modifier_archon_passive_second_sunderarmor_debuff:OnCreated( kv )
	self.reduce_armor = self:GetAbility():GetSpecialValueFor( "reduce_armor" )
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_sunderarmor_debuff:OnRefresh( kv )
	self.reduce_armor = self:GetAbility():GetSpecialValueFor( "reduce_armor" )
end

function modifier_archon_passive_second_sunderarmor_debuff:IsDebuff()
	return true
end

function modifier_archon_passive_second_sunderarmor_debuff:IsHidden()
	return true
end

function modifier_archon_passive_second_sunderarmor_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end

function modifier_archon_passive_second_sunderarmor_debuff:GetModifierPhysicalArmorBonus( params )
	return -self.reduce_armor
end
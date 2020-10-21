-- 恐怖光环

LinkLuaModifier( "modifier_archon_passive_second_terrified", "ability/archon_passive_second_terrified.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_second_terrified_debuff", "ability/archon_passive_second_terrified.lua",LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------
if archon_passive_second_terrified == nil then
	archon_passive_second_terrified = class({})
end

function archon_passive_second_terrified:GetIntrinsicModifierName()
 	return "modifier_archon_passive_second_terrified"
end
--------------------------------------------------
if modifier_archon_passive_second_terrified == nil then
	modifier_archon_passive_second_terrified = class({})
end

function modifier_archon_passive_second_terrified:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_terrified:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_terrified:GetModifierAura()
	return "modifier_archon_passive_second_terrified_debuff"
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_terrified:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_terrified:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_terrified:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_terrified:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_terrified:OnCreated( kv )
	self.aura_radius = 1200
	if IsServer() and self:GetParent() ~= self:GetCaster() then
		self:StartIntervalThink( 0.5 )
	end
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_terrified:OnRefresh( kv )
	self.aura_radius = 1200
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_terrified:OnIntervalThink()
	if self:GetCaster() ~= self:GetParent() and self:GetCaster():IsAlive() then
		self:Destroy()
	end
end

if modifier_archon_passive_second_terrified_debuff == nil then
	modifier_archon_passive_second_terrified_debuff ={}
end

function modifier_archon_passive_second_terrified_debuff:OnCreated( kv )
	self.coefficient = self:GetAbility():GetSpecialValueFor( "coefficient" )
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_terrified_debuff:OnRefresh( kv )
	self.coefficient = self:GetAbility():GetSpecialValueFor( "coefficient" )
end

function modifier_archon_passive_second_terrified_debuff:IsDebuff()
	return true
end

function modifier_archon_passive_second_terrified_debuff:IsHidden()
	return true
end

function modifier_archon_passive_second_terrified_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE
	}
	return funcs
end

function modifier_archon_passive_second_terrified_debuff:GetModifierBaseDamageOutgoing_Percentage( params )
	return -self.coefficient
end
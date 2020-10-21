-- 护甲光环
LinkLuaModifier( "modifier_ability_flagstone_armor_aura", "ability/flagstone/ability_flagstone_armor_aura.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_flagstone_armor_aura_effect", "ability/flagstone/ability_flagstone_armor_aura.lua",LUA_MODIFIER_MOTION_NONE )

local hArmor = {5,10,20}
-------------------------------------------------
if ability_flagstone_armor_aura == nil then
	ability_flagstone_armor_aura = class({})
end

function ability_flagstone_armor_aura:GetIntrinsicModifierName()
 	return "modifier_ability_flagstone_armor_aura"
end
--------------------------------------------------
if modifier_ability_flagstone_armor_aura == nil then
	modifier_ability_flagstone_armor_aura = class({})
end

function modifier_ability_flagstone_armor_aura:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_armor_aura:IsAura()
	return true
end

function modifier_ability_flagstone_armor_aura:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_ability_flagstone_armor_aura:RemoveOnDeath()
    return false -- 死亡不移除
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_armor_aura:GetModifierAura()
	return "modifier_ability_flagstone_armor_aura_effect"
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_armor_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_armor_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_armor_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_armor_aura:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_armor_aura:OnCreated( kv )
	self.aura_radius = 1200
	if IsServer() and self:GetParent() ~= self:GetCaster() then -- 
		self:StartIntervalThink( 0.5 )
	end
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_armor_aura:OnRefresh( kv )
	self.aura_radius = 1200
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_armor_aura:OnIntervalThink()
	if IsServer() then
		if self:GetCaster() ~= self:GetParent() and self:GetCaster():IsAlive() then
			self:Destroy()
		end
	end
end

if modifier_ability_flagstone_armor_aura_effect == nil then
	modifier_ability_flagstone_armor_aura_effect ={}
end

function modifier_ability_flagstone_armor_aura_effect:OnCreated( kv )
	self.bonus = 20
end

--------------------------------------------------------------------------------

function modifier_ability_flagstone_armor_aura_effect:OnRefresh( kv )
	self.bonus = 20
end

function modifier_ability_flagstone_armor_aura_effect:IsDebuff()
	return false
end

function modifier_ability_flagstone_armor_aura_effect:IsHidden()
	return true
end

function modifier_ability_flagstone_armor_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end

function modifier_ability_flagstone_armor_aura_effect:GetModifierPhysicalArmorBonus( params )
	return self.bonus
end
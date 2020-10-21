LinkLuaModifier( "modifier_archon_passive_second_vampiric", "ability/archon_passive_second_vampiric.lua",LUA_MODIFIER_MOTION_NONE )


if archon_passive_second_vampiric == nil then
	archon_passive_second_vampiric = class({})
end

function archon_passive_second_vampiric:GetIntrinsicModifierName()
 	return "modifier_archon_passive_second_vampiric"
end

if modifier_archon_passive_second_vampiric == nil then
	modifier_archon_passive_second_vampiric = class({})
end

function modifier_archon_passive_second_vampiric:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_archon_passive_second_vampiric:IsHidden() 
	return true
end

function modifier_archon_passive_second_vampiric:OnAttackLanded( params )
	if not IsServer() then return end
	local Attacker = params.attacker
	if params.attacker ~= self:GetParent() then
		return 0
	end
	-- 概率计算
	local nowChance = RandomInt(0,100)
	local chance = self:GetAbility():GetSpecialValueFor( "chance" )
	if nowChance  > chance then
		return 0
	end
	local level_heal = Attacker:GetLevel() * self:GetAbility():GetSpecialValueFor( "level_bonus" )
	local heal = (Attacker:GetMaxHealth() - Attacker:GetHealth()) * self:GetAbility():GetSpecialValueFor( "health_loss" ) * 0.01
	heal = heal +  level_heal
	Attacker:Heal( heal, Attacker )
	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_omniknight/omniknight_loadout.vpcf", PATTACH_ABSORIGIN_FOLLOW, Attacker )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	
end
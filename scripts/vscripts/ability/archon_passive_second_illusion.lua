LinkLuaModifier( "modifier_archon_passive_second_illusion", "ability/archon_passive_second_illusion.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_second_illusion_buff", "ability/archon_passive_second_illusion.lua",LUA_MODIFIER_MOTION_NONE )

-------------------------------------------------
-- 幻象
if archon_passive_second_illusion == nil then
	archon_passive_second_illusion = class({})
end

function archon_passive_second_illusion:GetIntrinsicModifierName()
 	return "modifier_archon_passive_second_illusion"
end
--------------------------------------------------
if modifier_archon_passive_second_illusion == nil then
	modifier_archon_passive_second_illusion = class({})
end

function modifier_archon_passive_second_illusion:IsHidden()
	return true
end

function modifier_archon_passive_second_illusion:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_archon_passive_second_illusion:OnAttackLanded( params )
	if params.attacker ~= self:GetParent() then
		return 0
	end
	print("archon_passive_second_illusion")
	local hTarget = params.target
	local hCaster = self:GetParent()
	local hHero = hCaster
	local duration = self:GetAbility():GetSpecialValueFor( "duration" )
	local fHullRadius = hCaster:GetHullRadius()
	local fDistance = 64 + fHullRadius
	local fDistance_X = (RandomInt(0, 1) == 0) and fDistance or (0 - fDistance)
	fDistance_X = (0 % 2 == 0) and fDistance_X or 0
	local fDistance_Y = (RandomInt(0, 1) == 0) and fDistance or (0 - fDistance)
	fDistance_Y = (0 % 2 == 1) and fDistance_Y or 0
	local vLocation = hCaster:GetAbsOrigin() + Vector(fDistance_X, fDistance_Y, 0)
	local hIllusion = CreateIllusions( 
		hCaster:GetTeamNumber(), 
		hHero, 
		"modifier_archon_passive_second_illusion_buff", 
		1, 
		vLocation, 
		false, 
		false 
	)

end

if modifier_archon_passive_second_illusion_buff == nil then
	modifier_archon_passive_second_illusion_buff = class({})
end
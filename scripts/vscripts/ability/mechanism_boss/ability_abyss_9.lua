-- 维修队		ability_abyss_9

LinkLuaModifier("modifier_ability_abyss_9", "ability/mechanism_Boss/ability_abyss_9", LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_ability_abyss_9_damage", "ability/mechanism_Boss/ability_abyss_9", LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_ability_abyss_9_effects", "ability/mechanism_Boss/ability_abyss_9", LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_ability_abyss_9_Reduction_of_injury", "ability/mechanism_Boss/ability_abyss_9", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_9 == nil then 
	ability_abyss_9 = class({})
end

function ability_abyss_9:IsHidden( ... )
	return true
end

function ability_abyss_9:OnSpellStart( ... )
	local hCaster = self:GetCaster()
	print("hCaster_TEAM",hCaster:GetTeam())

	for i = 1, 12 do
		self.mob = CreateUnitByName("repair_crew_unit", hCaster:GetAbsOrigin() + RandomVector(1) * RandomFloat(0, 1000), true, nil, nil, DOTA_TEAM_BADGUYS)
		-- self.mob:AddNewModifier(hCaster, self, "modifier_ability_abyss_9", {})
		-- self.mob:AddNewModifier(hCaster, self, "modifier_ability_abyss_9_effects", {})
		self.mob:SetTeam(3)
	end
end
-- 维修队		ability_abyss_9

if ability_abyss_9 == nil then 
	ability_abyss_9 = class({})
end

function ability_abyss_9:IsHidden( ... )
	return true
end

function ability_abyss_9:OnSpellStart( ... )
	local hCaster = self:GetCaster()

	for i = 1, 12 do
		self.mob = CreateUnitByName("repair_crew_unit", hCaster:GetAbsOrigin() + RandomVector(1) * RandomFloat(0, 1000), true, nil, nil, DOTA_TEAM_BADGUYS)
		self.mob:SetTeam(3)
	end
end
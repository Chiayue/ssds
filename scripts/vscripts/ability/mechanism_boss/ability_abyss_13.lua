-- 元素泄露		ability_abyss_13

if ability_abyss_13 == nil then 
	ability_abyss_13 = class({})
end

function ability_abyss_13:IsHidden( ... )
	return true
end

function ability_abyss_13:OnSpellStart( ... )
	local hCaster = self:GetCaster()
	
	for i = 1, 7 do
		local newItem = CreateItem( "item_the_wind_elements_invulnerable", nil, nil )
		local drop = CreateItemOnPositionSync( hCaster:GetAbsOrigin() + RandomVector(1) * RandomFloat(0, 1000), newItem ) 
	end

	for i = 1, 3 do
		local newItem = CreateItem( "item_ray_elements", nil, nil )
		local drop = CreateItemOnPositionSync( hCaster:GetAbsOrigin() + RandomVector(1) * RandomFloat(0, 1000), newItem ) 
	end
end
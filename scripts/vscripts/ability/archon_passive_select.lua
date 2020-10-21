if archon_passive_select == nil then
	archon_passive_select = class({})
end

function archon_passive_select:OnToggle( params)
	local hHero = self:GetCaster()
	local nPlayerID = hHero:GetPlayerID()
	if self:GetToggleState() then
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"show_ability_select",{})
	else
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"closed_ability_select",{})
	end

end
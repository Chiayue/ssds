if archon_deputy_select_first == nil then
	archon_deputy_select_first = class({})
end
if archon_deputy_select_second == nil then
	archon_deputy_select_second = class({})
end

function archon_deputy_select_first:OnToggle( params)
	local hHero = self:GetCaster()
	local nPlayerID = hHero:GetOwner():GetPlayerID()
	if self:GetToggleState() then
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"show_deputy_select",{})
	else
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"closed_deputy_select",{})
	end
end

function archon_deputy_select_second:OnToggle( params)
	local hHero = self:GetCaster()
	local nPlayerID = hHero:GetOwner():GetPlayerID()
	if self:GetToggleState() then
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"show_deputy_select",{})
	else
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"closed_deputy_select",{})
	end
end
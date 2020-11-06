if item_silver_spade_complete == nil then item_silver_spade_complete = {} end

function item_silver_spade_complete:OnSpellStart() 
	if not IsServer() then return end
	local hCaster = self:GetCaster()

	self:SpendCharge()
end
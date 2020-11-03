if item_silver_spade_fragment == nil then item_silver_spade_fragment = {} end

function item_silver_spade_fragment:OnSpellStart() 
	if not IsServer() then return end
	local hCaster = self:GetCaster()
	local nNowCharges = self:GetCurrentCharges()
	if nNowCharges >= 4 then
		for i=0,3 do self:SpendCharge() end
		hCaster:AddItemByName('item_silver_spade_complete')
	end
end
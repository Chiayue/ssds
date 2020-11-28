if item_gold_spade_fragment == nil then item_gold_spade_fragment = {} end

function item_gold_spade_fragment:OnSpellStart() 
	if not IsServer() then return end
	local hCaster = self:GetCaster()
	local nNowCharges = self:GetCurrentCharges()
	if nNowCharges >= 4 then
		hCaster:AddItemByName('item_gold_spade_complete')
		self:SetCurrentCharges(nNowCharges - 4 )
		if self:GetCurrentCharges() == 0 then
			self:Destroy()
		end
	end
end
if item_tpscroll == nil then item_tpscroll = {} end

function item_tpscroll:OnSpellStart() 
	print("OnSpellStart")
end

function item_tpscroll:OnToggle( params)
	print("OnToggle")
end
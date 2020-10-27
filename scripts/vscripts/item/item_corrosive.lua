-- 腐蚀剂	item_corrosive

if item_corrosive == nil then 
	item_corrosive = class({})
end

function item_corrosive:OnSpellStart( ... )
	--local hCaster = self:GetCaster()
	local hTarght_pos = self:GetCursorTarget()
	--hTarght_pos:
	--print("hTarght_pos====", hTarght_pos)
	if IsValidEntity(hTarght_pos) then 
		if hTarght_pos:HasModifier("modifier_steel_armor") then 
			--local hTarght_modifier_count = hTarght_pos:FindModifierByName("modifier_steel_armor"):GetStackCount()
			hTarght_pos:FindModifierByName("modifier_steel_armor"):DecrementStackCount()
			self:SpendCharge()
		end
	end
end
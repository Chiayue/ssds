-- 腐蚀剂	item_corrosive

if item_corrosive == nil then 
	item_corrosive = class({})
end

function item_corrosive:OnSpellStart( ... )
	--local hCaster = self:GetCaster()
	local hTarget_pos = self:GetCursorTarget()
	--hTarght_pos:
	--print("hTarght_pos====", hTarght_pos)
	if IsValidEntity(hTarget_pos) then 
		if hTarget_pos:HasModifier("modifier_ability_abyss_8") then
			--local hTarght_modifier_count = hTarght_pos:FindModifierByName("modifier_steel_armor"):GetStackCount()
			hTarget_pos:FindModifierByName("modifier_ability_abyss_8"):DecrementStackCount()
			self:SpendCharge()
		end
	end
end
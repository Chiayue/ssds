-- 特殊石板技能
if item_special_ability_book == nil then item_special_ability_book = {} end
function item_special_ability_book:OnSpellStart() 
	if IsServer() then
		local hHero = self:GetCaster()
		local sOldAbiName = hHero.passive or "archon_passive_null"
		local hOldAbility = hHero:FindAbilityByName(sOldAbiName)
		if hOldAbility ~= nil then 
			hHero:RemoveAbility(sOldAbiName)
		end
		local nPassiveOrder = RandomInt(1,#GlobalVarFunc.OriginalAbilities)
		local nChance = RandomInt(1,100)
		local sNewName = GlobalVarFunc.OriginalAbilities[nPassiveOrder]
		--print(sNewName)
		local nAbilityLevel = RandomInt(1, 3) 
		local hNewAbility = hHero:AddAbility(sNewName)
		hHero.passive = sNewName
		hNewAbility:SetLevel(nAbilityLevel)
		self:SpendCharge()
	end
end
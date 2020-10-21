-- 石板技能
local randomPassiveTable = {
	"ability_flagstone_sunderarmor",
	"ability_flagstone_bonus_str",
	"ability_flagstone_bonus_agi",
	"ability_flagstone_bonus_int",
	"ability_flagstone_bounty_hunter",
	"ability_flagstone_festering_aura",
	"ability_flagstone_attackspeed_aura",
	"ability_flagstone_armor_aura",
	"ability_flagstone_sunderarmor_aura",
	--"ability_flagstone_warlord_fervor"
}

if item_study_passive == nil then item_study_passive = {} end
function item_study_passive:OnSpellStart() 
	if IsServer() then
		local hHero = self:GetCaster()
		local sOldAbiName = hHero.passive or "archon_passive_null"
		local hOldAbility = hHero:FindAbilityByName(sOldAbiName)
		if hOldAbility ~= nil then 
			hHero:RemoveAbility(sOldAbiName)
		end
		local nPassiveOrder = RandomInt(1,#randomPassiveTable)
		local nChance = RandomInt(1,100)
		local sNewName = randomPassiveTable[nPassiveOrder]
		--print(sNewName)
		local nAbilityLevel = self:GetSpecialValueFor("ability_level")
		local hNewAbility = hHero:AddAbility(sNewName)
		hHero.passive = sNewName
		hNewAbility:SetLevel(nAbilityLevel)
		self:SpendCharge()
	end
end

if item_study_passive_lv1 == nil then item_study_passive_lv1 = class(item_study_passive) end
if item_study_passive_lv2 == nil then item_study_passive_lv2 = class(item_study_passive) end
if item_study_passive_lv3 == nil then item_study_passive_lv3 = class(item_study_passive) end
--[[
1.全队金钱+15000               20%
2.全队力量+200                 10%
3.全队敏捷+200                 10%
4.全队智力+200                 10%
5.怪物移动速度+5%              10%
6.全队木材+2000                20%
7.什么都没有                   20%
]]
local hSpadeEvent = {
	{ event = "add_gold", amount = 15000 , chance = 20 },
	{ event = "add_str", amount = 200 , chance = 10 },
	{ event = "add_agi", amount = 200 , chance = 10 },
	{ event = "add_int", amount = 200 , chance = 10 },
	{ event = "add_monster_ms", amount = 10 , chance = 10 },
	{ event = "add_wood", amount = 2000 , chance = 20 },
	{ event = "add_item", name = "item_gold_spade_fragment", amount = 1 , chance = 15 },
	{ event = "add_round_income", amount = 700 , chance = 5 },
}
if item_silver_spade_complete == nil then item_silver_spade_complete = {} end
function item_silver_spade_complete:OnSpellStart() 
	if not IsServer() then return end
	local hCaster = self:GetCaster()
	local nCharge = self:GetCurrentCharges() 
	if nCharge >= 1 then
		local nPlayerID = hCaster:GetOwner():GetPlayerID()
		local nNowChance = RandomInt(0,100)
		local nBaseChance = 0
		for _,v in pairs(hSpadeEvent) do
			nBaseChance = nBaseChance + v.chance
			if nNowChance <= nBaseChance then
				RunSpadeEvent(hCaster,"Silver",v)
				break
			end
		end
		self:SetCurrentCharges(nCharge - 1 )
		if self:GetCurrentCharges() == 0 then
			self:Destroy()
		end
	end
end


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
	{ event = "add_gold", amount = 60000 , chance = 20 },
	{ event = "add_str", amount = 800 , chance = 10 },
	{ event = "add_agi", amount = 800 , chance = 10 },
	{ event = "add_int", amount = 800 , chance = 10 },
	{ event = "add_monster_ms", amount = 10 , chance = 10 },
	{ event = "add_wood", amount = 8000 , chance = 20 },
	{ event = "none", amount = 0 , chance = 20 },
}
if item_gold_spade_complete == nil then item_gold_spade_complete = {} end
function item_gold_spade_complete:OnSpellStart() 
	if not IsServer() then return end
	local hCaster = self:GetCaster()
	local nPlayerID = hCaster:GetOwner():GetPlayerID()
	local nNowChance = RandomInt(0,100)
	local nBaseChance = 0
	for _,v in pairs(hSpadeEvent) do
		nBaseChance = nBaseChance + v.chance
		if nNowChance <= nBaseChance then
			RunSpadeEvent(nPlayerID,"Gold",v.event,v.amount)
			break
		end
	end
	self:SpendCharge()
end


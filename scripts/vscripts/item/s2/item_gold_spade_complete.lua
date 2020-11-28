--[[
1.全队金钱+15000               20%
2.全队力量+200                 10%
3.全队敏捷+200                 10%
4.全队智力+200                 10%
5.怪物移动速度+5%              10%
6.全队木材+2000                20%
7.什么都没有                   20%
百分之1 8000力量  百分之1 8000敏捷 百分之1 8000智力 百分之3 几率全队金装 
百分之5 等级提高10级  百分之4 几率怪物移动速度+50% 
1%
]]
local hSpadeEvent = {
	{ event = "none", chance = 5 },
	{ event = "add_round_income", amount = 3000 , chance = 20 },
	{ event = "add_round_income", amount = 15000 , chance = 1 ,screen_arcane = true},
	{ event = "add_str", amount = 800 , chance = 10 },
	{ event = "add_agi", amount = 800 , chance = 10 },
	{ event = "add_int", amount = 800 , chance = 10 },
	{ event = "add_all", amount = 500 , chance = 9 },
	{ event = "add_monster_ms", amount = 20 , chance = 10 },
	--{ event = "add_hero_ms", amount = 10 , chance = 5 },
	{ event = "add_wood", amount = 12000 , chance = 10 },
	{ event = "add_str2", amount = 8000 , chance = 1 ,screen_arcane = true },
	{ event = "add_agi2", amount = 8000 , chance = 1 ,screen_arcane = true },
	{ event = "add_int2", amount = 8000 , chance = 1 ,screen_arcane = true },
	{ event = "add_serieitem", chance = 3 ,screen_arcane = true},
	{ event = "level_up", amount = 10 , chance = 5 },
	{ event = "add_all2", amount = 3000 , chance = 1 ,screen_arcane = true},
	{ event = "add_monster_ms", amount = 30 , chance = 3 },
	
}
if item_gold_spade_complete == nil then item_gold_spade_complete = {} end
function item_gold_spade_complete:OnSpellStart() 
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
				RunSpadeEvent(hCaster,"Gold",v)
				break
			end
		end
		self:SetCurrentCharges(nCharge - 1 )
		if self:GetCurrentCharges() == 0 then
			self:Destroy()
		end
	end
	
end


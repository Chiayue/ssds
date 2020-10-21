if  ArrowSoulReward == nil then ArrowSoulReward = {} end
local hSoulReward = {
	["reward_clearrance_0_reward"] 	= { link = "gameMode_0_clearance" ,count = 35, reward = 1000 },
	["reward_clearrance_1_reward"] 	= { link = "gameMode_1_clearance" ,count  = 35, reward = 1500 },
	["reward_clearrance_2_reward"] 	= { link = "gameMode_2_clearance" ,count  = 35, reward = 2000 },
	["reward_clearrance_3_reward"] 	= { link = "gameMode_3_clearance" ,count  = 35, reward = 2500 },
	["reward_killnum_2000"] 	= { link = "game_killNum" ,count  = 2000, reward = 100 },
	["reward_killnum_5000"] 	= { link = "game_killNum" ,count  = 5000, reward = 200 },
	["reward_killnum_20000"] 	= { link = "game_killNum" ,count  = 20000, reward = 300 },
	["reward_killnum_50000"] 	= { link = "game_killNum" ,count  = 50000, reward = 400 },
	["reward_killnum_200000"]	= { link = "game_killNum" ,count  = 200000, reward = 500 },
	["reward_killnum_500000"] 	= { link = "game_killNum" ,count  = 500000, reward = 800 },
	["reward_killnum_2000000"] 	= { link = "game_killNum" ,count  = 2000000, reward = 1000 }
}
-- 初始化箭魂奖励
function ArrowSoulReward:CheckReward(hHero)
	local nPlayerID =  hHero:GetOwner():GetPlayerID() 
	local hArchiveData = Archive:GetData(nPlayerID)
	local hRows = {}
	for sRewardKey,v in pairs(hSoulReward) do
		local info = hArchiveData[sRewardKey]
		if info == nil then
			local sLinkKey = v["link"]
			local nNeedCount = v["count"]
			local nRewardNum = v["reward"]
			local nCurrentCount = hArchiveData[sLinkKey]
			if nCurrentCount ~= nil then
				if nCurrentCount >= nNeedCount then
					hRows[sRewardKey] = 1
					Store:AddCustomGoodsValue(nPlayerID,"arrow_soul",nRewardNum,sRewardKey,false)
				end
			end
		end
	end
	local nRowsLength = GetTableLength(hRows)
	if nRowsLength > 0 then
		Archive:SaveRowsToPlayer(nPlayerID,hRows)
	end
end

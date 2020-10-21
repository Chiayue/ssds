if  ArrowSoulCompensate == nil then ArrowSoulCompensate = {} end
local hSoulReward = {

}

-- 初始化箭魂奖励
function ArrowSoulCompensate:CheckReward(hHero)
	local nPlayerID =  hHero:GetOwner():GetPlayerID() 
	local hArchiveData = Archive:GetData(nPlayerID)
	local hRows = {}
	for sRewardKey,v in pairs(hSoulReward) do
		local info = hArchiveData[sRewardKey]
		if info == nil then
			--local sLinkKey = v["link"]
			local nRewardNum = v["reward"]
			local nNeedCount = v["count"] or 0
			local nCurrentCount = hArchiveData[sLinkKey] or 0
			if nCurrentCount >= nNeedCount then
				hRows[sRewardKey] = 1
				Store:AddCustomGoodsValue(nPlayerID,"arrow_soul",nRewardNum,sRewardKey,false)
			end
		end
	end
	local nRowsLength = GetTableLength(hRows)
	if nRowsLength > 0 then
		Archive:SaveRowsToPlayer(nPlayerID,hRows)
	end

	-- if GlobalVarFunc.game_type == 100 or GlobalVarFunc.game_type == 101 then
	-- 	local hRows2 = {}
	-- 	for sRewardKey,v in pairs(hSeriesItemReward) do
	-- 		local info = hArchiveData[sRewardKey]
	-- 		if info == nil then
	-- 			local sLinkKey = v["link"]
	-- 			local nRewardNum = v["reward"]
	-- 			local nNeedCount = v["count"]
	-- 			local nCurrentCount = hArchiveData[sLinkKey]
	-- 			if nCurrentCount >= nNeedCount then
	-- 				hRows2[sRewardKey] = 1
	-- 				Store:AddCustomGoodsValue(nPlayerID,"arrow_soul",nRewardNum,sRewardKey,false)
	-- 				local hSeriesItem = v["seriesItem"]
	-- 				local nAffixCont = hSeriesItem["t"] + 1
	-- 				local nTier = hSeriesItem["t"]
	-- 				SeriseSystem:CreateSeriesItem(hHero,nAffixCont,1,nTier)
	-- 			end
	-- 		end
	-- 	end	
	-- 	local nRowsLength = GetTableLength(hRows2)
	-- 	if nRowsLength > 0 then
	-- 		Archive:SaveRowsToPlayer(nPlayerID,hRows2)
	-- 		Archive:SaveServerEqui(nPlayerID)
	-- 	end	
	-- end
	
	
end

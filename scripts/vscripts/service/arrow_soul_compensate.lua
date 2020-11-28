if  ArrowSoulCompensate == nil then ArrowSoulCompensate = {} end
local hSoulReward = {

}

-- 初始化箭魂奖励
function ArrowSoulCompensate:CheckReward(hHero)
	local nPlayerID =  hHero:GetOwner():GetPlayerID() 
	local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
	if CDOTAPlayer == nil then return end
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
end

if Account == nil then
	Account = class({})
end

ACTION_ACCOUNT_LOAD = "account/load_account" 						-- 读取账号晶石数据
ACTION_REWARD_MONEY = "account/reward_money" 						-- 奖励晶石
ACTION_ACCOUNT_GET_RECHARGE_URL = "recharge/payment_url"			-- 支付链接

local account_data = {}
local bLoadingOver = false

-- 读取资料数据初始化
function Account:Init()
	ListenToGameEvent( "game_rules_state_change" ,Dynamic_Wrap( self, 'StageChange' ), self )
	CustomGameEventManager:RegisterListener( "get_recharge_url", self.OnGetRechargeUrl )
	CustomGameEventManager:RegisterListener( "refresh_recharge", self.OnRefreshRecharge )

end

function Account:StageChange()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		local nPlayerCount = PlayerResource:GetPlayerCount()
		for nPlayerID = 0,nPlayerCount - 1 do
			if account_data[nPlayerID] == nil then
				account_data[nPlayerID] = {}
			end
			self:LoadPlayer(nPlayerID)
		end
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_WAIT_FOR_MAP_TO_LOAD then
		CustomNetTables:SetTableValue("service", "player_account", Account:GetData())
	end
end

--请求充值的网页
function Account:OnGetRechargeUrl(args)
	print("OnGetRechargeUrl")
	local nPlayerID = args.PlayerID
	local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
	local recharge_type = args.recharge_type or 1
	local amount = tostring(args.amount)
	
	Service:HTTPRequest("POST", ACTION_ACCOUNT_GET_RECHARGE_URL, { amount = amount, steam_id = nSteamID, recharge_type = recharge_type }, function(iStatusCode, sBody)
			-- print("OnGetRechargeUrl iStatusCode:",iStatusCode)
			-- print(sBody)
			if iStatusCode == 200 then

				local hBody = json.decode(sBody)
				CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"RechargeUrlCallback",hBody)
			else
				CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"RechargeUrlCallback",{code=0,msg="unknow error"})
			end
		end, 
	REQUEST_TIME_OUT)

end


function Account:LoadPlayer(nPlayerID)
	local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
	Service:HTTPRequest("POST", ACTION_ACCOUNT_LOAD, { steam_id = nSteamID }, function(iStatusCode, sBody)
		print("LoadPlayer:",iStatusCode)
		--print(sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			account_data[nPlayerID] = hBody.data
		end 
	end, REQUEST_TIME_OUT)
end

-- 更新账号充值情况
function Account:OnRefreshRecharge(args)
	local nPlayerID = args.PlayerID
	print("OnRefreshRecharge Player:",nPlayerID)
	Account:UpAccount(nPlayerID)
end

-- 获取数据
function Account:GetData(nPlayerID,sKeyword)
	if nPlayerID == nil then
		return account_data
	elseif sKeyword == nil then
		return account_data[nPlayerID]
	else 
		if account_data[nPlayerID][sKeyword] == nil then
			return 0
		else
			return account_data[nPlayerID][sKeyword]
		end
	end
end

-- 更新数据
function Account:UpAccount(nPlayerID)
	local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
	Service:HTTPRequest("POST", ACTION_ACCOUNT_LOAD, { steam_id = nSteamID }, function(iStatusCode, sBody)
		print("LoadPlayer:",iStatusCode)
		--print(sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			-- DeepPrintTable(hBody)
			account_data[nPlayerID] = hBody.data
			CustomNetTables:SetTableValue("service", "player_account", Account:GetData())
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"UpDateAccount",hBody)
		end 
	end, REQUEST_TIME_OUT)
end

-- 奖励钻石
function Account:RewardMoney(nPlayerID,nQuantity,sRemarks)
	-- body
	local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
	Service:HTTPRequest("POST", ACTION_REWARD_MONEY, { 
		steam_id = nSteamID, 
		quantity = nQuantity,
		remarks = sRemarks,
	}, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			account_data[nPlayerID] = hBody.data
			CustomNetTables:SetTableValue("service", "player_account", Account:GetData())
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"UpDateAccount",hBody)
		end
	end, REQUEST_TIME_OUT)
end
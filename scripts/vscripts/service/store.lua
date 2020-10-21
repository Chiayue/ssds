if Store == nil then
	Store = class({})
end

ACTION_STORE_LOAD_GOODS_LIST = "store/load_goods_list"			-- 获取商品列表
ACTION_STORE_LOAD_ACCOUNT = "store/load_account"				-- 获取玩家商品存档
ACTION_STORE_PAY_GOODS = "store/pay_goods"						-- 支付商品
ACTION_STORE_ADD_CURRENCY = "store/add_currency" 				-- 增加自定义货币 [每天都有一定上限，在服务端设置]
ACTION_STORE_USED_CURRENCY = "store/used_currency" 				-- 消耗自定义货币
ACTION_STORE_CLEARANCE_REWARD = "store/clearance_reward" 		-- 增加结算时候的奖励
local hMapsLevelReward = {}


local goods_list = {}
local spend_archive = {}
local hAddCustomCurrencyCallback = {}
hUsedCustomCurrencyCallback = {}
function Store:Init()
	ListenToGameEvent( "game_rules_state_change" ,Dynamic_Wrap( self, 'StageChange' ), self )
	CustomGameEventManager:RegisterListener( "pay_service_item", self.PayGoods )
	CustomGameEventManager:RegisterListener( "service_update_store", self.UpdateStore )

end

function Store:StageChange()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		self:LoadGoodsList()
		self:LoadAllPlayerGoods()
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_WAIT_FOR_MAP_TO_LOAD then
		CustomNetTables:SetTableValue("service", "goods", self:GetGoodsList())
		CustomNetTables:SetTableValue("service", "player_store", self:GetData())
	end
end

-- 读取商品相关存档
function Store:LoadAllPlayerGoods()
	--print("LoadAllAccount")
	local nPlayerCount = PlayerResource:GetPlayerCount()
	for nPlayerID = 0,nPlayerCount - 1 do
		local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
		print("nSteamID:",nSteamID)
		if nSteamID > 0 then
			if spend_archive[nPlayerID] == nil then
				spend_archive[nPlayerID] = {}
				hAddCustomCurrencyCallback[nPlayerID] = {}
				hUsedCustomCurrencyCallback[nPlayerID] = {}
			end
			self:LoadPlayerGoods(nPlayerID)
		end
	end
end

-- 读取商品列表
function Store:LoadGoodsList()
	Service:HTTPRequest("POST", ACTION_STORE_LOAD_GOODS_LIST, {}, function(iStatusCode, sBody)
		print("LoadGoodsList:",iStatusCode)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			goods_list = hBody.data
			for k,v in pairs(goods_list) do
			if v["free_level"] > 0 then
				local hRewardInfo = {}
				hRewardInfo["key"] = v["key"]
				hRewardInfo["stack"] = v["stack"]
				hRewardInfo["price"] = v["price"]
				hMapsLevelReward[v["free_level"]] = hRewardInfo
			end
		end

			CustomNetTables:SetTableValue("service", "store_goods_list", goods_list)
		end
	end, REQUEST_TIME_OUT)

end
-- 
function Store:GetGoodsFreeReward()
	return hMapsLevelReward
end
-- 
function Store:GetGoodsList()
	return goods_list
end

-- 购买物品
function Store:PayGoods(args)
	--DeepPrintTable(args)
	local nPlayerID = args.PlayerID
	local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
	local tParams = {
		steam_id = nSteamID,
		goods_id = args.item_id,
		pay_type = args.pay_type, -- 支付方式 1晶石 2其他
		quantity = args.amount,
	}

	-- 发送请求
	Service:HTTPRequest("POST", ACTION_STORE_PAY_GOODS, tParams, function(iStatusCode, sBody)
		print("PayGoods:",iStatusCode)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			-- 返回购买信息
			local hCurrentStore = hBody.data
			local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
    		local hNewHero = CDOTAPlayer:GetAssignedHero()
			PlayerStoreReward:Set( hNewHero, hCurrentStore)
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"PayServiceItemCallback",hBody)
		else
			local hBody = {code=0,msg="error"}
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"PayServiceItemCallback",hBody)
		end
	end, REQUEST_TIME_OUT)
end


function Store:UpdatePlayerGoods(nPlayerID)
	local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
	Service:HTTPRequest("POST", ACTION_STORE_LOAD_ACCOUNT, { steam_id = nSteamID }, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			spend_archive[nPlayerID] = hBody.data
			CustomNetTables:SetTableValue("service", "player_store", Store:GetData())
		end
	end, REQUEST_TIME_OUT)

end

function Store:LoadPlayerGoods(nPlayerID)
	local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
	Service:HTTPRequest("POST", ACTION_STORE_LOAD_ACCOUNT, { steam_id = nSteamID }, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			spend_archive[nPlayerID] = hBody.data
			CustomNetTables:SetTableValue("service", "player_store", Store:GetData())
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"UpdatPlayerStore",hBody)
		end
	end, REQUEST_TIME_OUT)
end

function Store:GetData(nPlayerID,sKeyword)
	if nPlayerID == nil then
		return spend_archive
	elseif sKeyword == nil then
		return spend_archive[nPlayerID]
	else
		return spend_archive[nPlayerID][sKeyword]
	end
end

function Store:UpdateStore(args)
	local nPlayerID = args.PlayerID
	local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
	Service:HTTPRequest("POST", ACTION_STORE_LOAD_ACCOUNT, { steam_id = nSteamID }, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			spend_archive[nPlayerID] = hBody.data
			-- 更新账号晶石情况
			print("UpdateStore")
			CustomNetTables:SetTableValue("service", "player_store", Store:GetData())
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"UpdatPlayerStore",hBody)
			Account:UpAccount(nPlayerID);
		end
	end, REQUEST_TIME_OUT)
end

-- 关卡结算奖励箭魂
function Store:AddAllArrowSoul(hClearReward,sCurrency,sRemarks)
	Service:HTTPRequest("POST", ACTION_STORE_CLEARANCE_REWARD, { 
		player_info = hClearReward, 
		currency = sCurrency, 
		remarks = sRemarks,
		limit = true, -- 受上限影响
	}, function(iStatusCode, sBody)
		--print(sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			hAddCustomCurrencyCallback= hBody.data
			-- 增加箭魂返回的数据
			CustomNetTables:SetTableValue("service", "add_cc_callback", hAddCustomCurrencyCallback)
		end
	end, REQUEST_TIME_OUT)
end

-- 对应字段新增值，只能是货币类型
function Store:AddCustomGoodsValue(nPlayerID,sCurrency,nQuantity,sRemarks,bLimit)
	-- body
	if bLimit == nil then bLimit = true end
	if sCurrency == 0 then return end
	local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
	if nSteamID == 0 then return end
	Service:HTTPRequest("POST", ACTION_STORE_ADD_CURRENCY, { 
		steam_id = nSteamID, 
		currency = sCurrency, 
		quantity = nQuantity,
		remarks = sRemarks,
		limit = bLimit, -- 受上限影响
	}, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			Store:UpdatePlayerGoods(nPlayerID)
		end
	end, REQUEST_TIME_OUT)
end

-- 消耗自定义货币 比如箭魂
function Store:UsedCustomGoodsValue(nPlayerID,sCurrency,nQuantity,sRemarks)
	-- body
	local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
	Service:HTTPRequest("POST", ACTION_STORE_USED_CURRENCY, { 
		steam_id = nSteamID, 
		currency = sCurrency, 
		quantity = nQuantity,
		remarks = sRemarks,
	}, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			Store:UpdatePlayerGoods(nPlayerID)
			hUsedCustomCurrencyCallback[nPlayerID] = hBody.data["status"]
			-- 消耗箭魂返回信息
			CustomNetTables:SetTableValue("service", "used_cc_callback", hUsedCustomCurrencyCallback)
		end
	end, REQUEST_TIME_OUT)
end


if Archive == nil then
	Archive = class({})
end

local game_archive = {}
local hLoading = false
local hArchiveEqui = {}
local hArchiveEquiLoading = {}
local hSteamID = {}
ACTION_ARCHIVE_LOAD = "archive/load_profile_v2" 				-- 获取游戏存档
ACTION_ARCHIVE_SAVE = "archive/save_profile" 					-- 保存游戏存档存档
ACTION_ARCHIVE_SAVE_V2 = "archive/save_profile_v2" 				-- 保存游戏存档存档v2
ACTION_ARCHIVE_NEW_MATCH = "archive/new_match" 					-- 保存游戏存档存档
ACTION_ARCHIVE_SAVE_EQUIPMENT = "archive/save_equipment" 		-- 保存装备
ACTION_ARCHIVE_LOAD_EQUIPMENT = "archive/load_equipment" 		-- 读取装备
ACTION_ARCHIVE_SEND_RANKING = "ranking/send_ranking" 			-- 提交排名
ACTION_ARCHIVE_GET_RANKING = "ranking/get_ranking" 				-- 获取排名

function Archive:Init() 
	print("Archive:Init() ")
	ListenToGameEvent( "game_rules_state_change" ,Dynamic_Wrap( self, 'StageChange' ), self )
end

function Archive:StageChange()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		self:LoadProfile()
		self.new_match()
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		Archive:RecursionEquiLoading()
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_WAIT_FOR_MAP_TO_LOAD then
		CustomNetTables:SetTableValue("service", "player_archive", self:GetData())
	end
end

function Archive:RecursionEquiLoading()
	if GlobalVarFunc.game_mode == "endless" then
		if Archive:CheckEquiLoading() == false then
			Timer(3,function()
	            Archive:RecursionEquiLoading()
	        end)
		else
			CustomGameEventManager:Send_ServerToAllClients("equipment_loading_over",{})
		end
	else
		CustomNetTables:SetTableValue("service", "player_archive_equi", {status = true})
		CustomGameEventManager:Send_ServerToAllClients("equipment_loading_over",{})
	end
end

function Archive:CheckLoading()
	return hLoading
end

function Archive:CheckEquiLoading()
	local nPlayerCount = PlayerResource:GetPlayerCount() 
	for nPlayerID = 0,nPlayerCount - 1 do
		if hArchiveEquiLoading[nPlayerID] == false then
			CustomNetTables:SetTableValue("service", "player_archive_equi", {status = false})
			return false
		end
	end
	CustomNetTables:SetTableValue("service", "player_archive_equi", {status = true})
	return true
end
-- 比赛ID写入
function Archive:new_match()
	local match_id = tonumber(GameRules:GetMatchID()) or 0
	Service:HTTPRequest("POST", ACTION_ARCHIVE_NEW_MATCH, {match_id = match_id  }, function(iStatusCode, sBody)
		--print("LoadPlayerProfile iStatusCode:",iStatusCode)
	end, REQUEST_TIME_OUT)

end
-- 读取地图存档
function Archive:LoadProfile()
	local hPlayerID = {}
	local nPlayerCount = PlayerResource:GetPlayerCount()
	for nPlayerID = 0,nPlayerCount - 1 do
		if game_archive[nPlayerID] == nil then
			game_archive[nPlayerID] = {}
			hArchiveEquiLoading[nPlayerID] = false
		end
		local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
		table.insert(hPlayerID,nPlayerID)
		table.insert(hSteamID,nSteamID)
	end
	self:LoadPlayerProfile(hPlayerID)
	CustomNetTables:SetTableValue("service", "player_steamid", hSteamID)
	CustomNetTables:SetTableValue("service", "player_archive_equi", {status = false})
end

function Archive:LoadPlayerProfile(hPlayerID)
	local hSteamID = {}
	for k,nPlayerID in pairs(hPlayerID) do
		local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
		table.insert(hSteamID,nSteamID)
	end
	Service:HTTPRequest("POST", ACTION_ARCHIVE_LOAD, { steam_id = hSteamID }, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			-- DeepPrintTable(hBody)
			for nSteamID,hData in pairs(hBody.data) do
				for nPlayerID,v in pairs(game_archive) do
					if tonumber(nSteamID) == PlayerResource:GetSteamAccountID(nPlayerID) then
						game_archive[nPlayerID] = hData

					end
				end
			end
			hLoading = true
		end
	end, REQUEST_TIME_OUT)
end

function Archive:SaveProfile()
	print("SaveProfile")
	local hPlayerID = {}
	local nPlayerCount = PlayerResource:GetPlayerCount()
	for nPlayerID = 0,nPlayerCount - 1 do
		local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
		if CDOTAPlayer ~= nil then
			local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
			if nSteamID ~= 0  then
				table.insert(hPlayerID,nPlayerID)
			end
		end
	end
	self:SavePlayerProfile(hPlayerID)
end

function Archive:SaveRowsToPlayer(nPlayerID,hRows)

	local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
	if nSteamID ~= 0 then
		local rows = hRows

		Service:HTTPRequest("POST", ACTION_ARCHIVE_SAVE, { steam_id = nSteamID, rows = rows }, function(iStatusCode, sBody)
			-- print(sBody)
		end, REQUEST_TIME_OUT)
	end
end

function Archive:SavePlayerProfile(hPlayerID)
	local hRows = {}
	for k,nPlayerID in pairs(hPlayerID) do
		local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
		local rows = self:GetData(nPlayerID)
		hRows[nSteamID] = rows
	end
	
	Service:HTTPRequest("POST", ACTION_ARCHIVE_SAVE_V2, { rows = hRows }, function(iStatusCode, sBody)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			--CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"testcode_callback",hBody)
		else
			print("error Code:",iStatusCode)
			--CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"testcode_callback",{htmlBody = sBody})
		end 
	end, REQUEST_TIME_OUT)
end

function Archive:EditPlayerProfile(nPlayerID,sKeyword,sValue)
	game_archive[nPlayerID][sKeyword] = sValue
end

-- 指定字段值自增
function Archive:SetIncPlayerProfile(nPlayerID,sKeyword,sValue)
	if type(sValue) == "number" then
		if game_archive[nPlayerID][sKeyword] == nil then
			game_archive[nPlayerID][sKeyword] = sValue
		else
			game_archive[nPlayerID][sKeyword] = game_archive[nPlayerID][sKeyword] + sValue
		end
	end
end

-- 获取存档数据
function Archive:GetData(nPlayerID,sKeyword)
	if nPlayerID == nil then
		return game_archive
	elseif sKeyword == nil then
		return game_archive[nPlayerID]
	else 
		if game_archive[nPlayerID][sKeyword] == nil then
			return 0
		else
			return game_archive[nPlayerID][sKeyword]
		end
	end
end

-- 获取特殊存档字段数据
function Archive:GetDataSpecial(nPlayerID,sKeyword)
	if nPlayerID == nil then
		return game_archive
	elseif sKeyword == nil then
		return game_archive[nPlayerID]
	else 
		if game_archive[nPlayerID][sKeyword] == nil then
			if sKeyword == "gamaModeNum" then
				return -1
			else
				return 0
			end
		else
			return game_archive[nPlayerID][sKeyword]
		end
	end
end

-- 获取玩家存档装备数据
function Archive:GetPlayerEqui(nPlayerID)
	return hArchiveEqui[nPlayerID]
end

-- 读取存档装备
function Archive:LoadServerEqui(nPlayerID)
	local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
	Service:HTTPRequest("POST", ACTION_ARCHIVE_LOAD_EQUIPMENT, { steam_id = nSteamID }, function(iStatusCode, sBody)
		--print("LoadServerEqui iStatusCode:",iStatusCode)
		if iStatusCode == 200 then
			--print(sBody)
			local hBody = json.decode(sBody)
			--DeepPrintTable(hBody)
			hArchiveEqui[nPlayerID] = hBody.data
			hArchiveEquiLoading[nPlayerID] = true
		end
	end, REQUEST_TIME_OUT)
end

-- 保存存档装备
function Archive:SaveServerEqui(nPlayerID)
	local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
	local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
    local hHero = CDOTAPlayer:GetAssignedHero()
    -- 物品栏
    local hInventoryTable = {}
    local hBackpackTable = {}
    local hRows = {}
    for i=0,8 do
		local hItem = hHero:GetItemInSlot(i)
		if hItem ~= nil then
			if hItem.bonus ~= nil and hItem:GetPurchaser() == hHero then
				hItem.bonus.itemName = hItem:GetAbilityName()
				local hSaveTime = CopyEquiTable(hItem.bonus)
				hSaveTime.gemslot_info = {}
				table.insert(hInventoryTable, hSaveTime)
			end
		end
	end
	-- 背包
	local hBackpackIndexList = InventoryBackpack:GetBackpack( hHero )
	for k,nIndex in pairs(hBackpackIndexList) do
		if nIndex ~= -1 then
			local hItem = EntIndexToHScript(nIndex)
			if hItem.bonus ~= nil and hItem:GetPurchaser() == hHero then
				hItem.bonus.itemName = hItem:GetAbilityName()
				local hSaveTime = CopyEquiTable(hItem.bonus)
				hSaveTime.gemslot_info = {}
				table.insert(hBackpackTable, hSaveTime)
			end
		end
	end
	hRows["inventory"] = hInventoryTable
	hRows["backpack"] = hBackpackTable
	Service:HTTPRequest("POST", ACTION_ARCHIVE_SAVE_EQUIPMENT, { steam_id = nSteamID ,rows = hRows }, function(iStatusCode, sBody)
	end, REQUEST_TIME_OUT)
end

function CopyEquiTable(hTable)
	local tab = {}
	for k,v in pairs(hTable) do
		if k ~= "itemIndex" and k ~= "gemslot_info" then
			tab[k] = v
		end
	end
	return tab
end

-- 提交排名
function Archive:SendRanking(sGameType,nLayers)
	-- endless  normal
	if nLayers < 4 then return false end
	if GlobalVarFunc.isClearance == false then return false end
	local hRows = {}
	local hTeamColl = {}
	local nPlayerCount = PlayerResource:GetPlayerCount()
	for nPlayerID = 0 ,nPlayerCount - 1 do
		
		local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
		
		if CDOTAPlayer ~= nil then
			local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
			if nSteamID ~= 0 then
	    		local hHero = CDOTAPlayer:GetAssignedHero()
				local hAbility = hHero:GetAbilityByIndex(1)
				local sAbility = hAbility:GetAbilityName()
				table.insert(hTeamColl,{ steam_id = nSteamID, hero = sAbility })
			end
		end
	end
	hRows["game_type"] = sGameType;
	hRows["layers"] = nLayers;
	hRows["team_coll"] = hTeamColl;
	Service:HTTPRequest("POST", ACTION_ARCHIVE_SEND_RANKING, { steam_id = nSteamID ,rows = hRows }, function(iStatusCode, sBody)
		--print("OnGetRechargeUrl iStatusCode:",iStatusCode)
		--print(sBody)
	end, REQUEST_TIME_OUT)
end

-- 获取排名
function Archive:GetRanking(sGameType)
	Service:HTTPRequest("POST", ACTION_ARCHIVE_GET_RANKING, { game_type = sGameType }, function(iStatusCode, sBody)
		--print("LoadServerEqui iStatusCode:",iStatusCode)
		if iStatusCode == 200 then
			local hBody = json.decode(sBody)
			CustomNetTables:SetTableValue("service", "ranking", hBody.data)
		end
	end, REQUEST_TIME_OUT)
end
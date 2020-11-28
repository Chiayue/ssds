function item_baoWu_book( event )
	for nPlayerID = 0, MAX_PLAYER-1 do
		local steam_id = PlayerResource:GetSteamAccountID(nPlayerID)
		if steam_id ~= 0 then
            --团队宝物书掉线玩家不发送
			local hPlayer = PlayerResource:GetPlayer(nPlayerID)
			if hPlayer ~= nil then

				--拥有神赐光环的玩家宝物4选1，没有则3选1
				local selectNum = 3
				local aura_godNum = Store:GetData(nPlayerID,"aura_god")
				if aura_godNum ~= nil and aura_godNum > 0 then
					selectNum = 4
				end

				local newTable = {}
				local hastable = {}
				for i=1,#GlobalVarFunc.player_treasure_list[nPlayerID] do
					hastable[i] = GlobalVarFunc.player_treasure_list[nPlayerID][i]
				end
				for i = 1 , selectNum do
					local randomNum = RandomInt(1, #hastable)
					newTable[i] = hastable[randomNum]
					table.remove( hastable, randomNum )
				end
				GlobalVarFunc.baoWuChiZiTest[nPlayerID + 1] = newTable

				CustomGameEventManager:Send_ServerToPlayer(hPlayer,"show_treasure_select", {treasureTable = newTable})
			end			
		end
	end
end

if item_gerenbaoWu_book == nil then item_gerenbaoWu_book = {} end
function item_gerenbaoWu_book:OnSpellStart( event )
	if not IsServer() then return end
	local hHero = self:GetCaster()
	if hHero.Baowu == nil then
		hHero.Baowu = 0
	end
	local nPlayerID = hHero:GetPlayerID()
	local hPlayer = PlayerResource:GetPlayer(nPlayerID)
	-- 漆黑
	local nDarkWings = Store:GetData(nPlayerID,"dark_wings")
	local nUseLimit = 3
	if nDarkWings ~= nil and nDarkWings > 0 then
		nUseLimit = 5
	end
	if hHero.Baowu < nUseLimit then
		hHero.Baowu = hHero.Baowu + 1
		self:SpendCharge()
		--拥有神赐光环的玩家宝物4选1，没有则3选1
		local selectNum = 3
		local aura_godNum = Store:GetData(nPlayerID,"aura_god")
		if aura_godNum ~= nil and aura_godNum > 0 then
			selectNum = 4
		end

		local newTable = {}
		local hastable = {}
		for i=1,#GlobalVarFunc.player_treasure_list[nPlayerID] do
			hastable[i] = GlobalVarFunc.player_treasure_list[nPlayerID][i]
		end
		for i = 1 , selectNum do
			local randomNum = RandomInt(1, #hastable)
			newTable[i] = hastable[randomNum]
			table.remove( hastable, randomNum )
		end
		GlobalVarFunc.baoWuChiZiTest[nPlayerID + 1] = newTable

		CustomGameEventManager:Send_ServerToPlayer(hPlayer,"show_treasure_select", {treasureTable = newTable})
	else
		CustomGameEventManager:Send_ServerToPlayer(hPlayer,"send_error_message_client",{message="PERSONAL_TREASURE_BOOK_USAGE_LIMIT"})
	end
end

if item_baowu_book_dark_wings == nil then item_baowu_book_dark_wings = {} end
function item_baowu_book_dark_wings:OnSpellStart( event )
	if not IsServer() then return end
	local hHero = self:GetCaster()
	local hPurchaser = self:GetPurchaser() 
	local nPlayerID = hHero:GetPlayerID()
	local hPlayer = PlayerResource:GetPlayer(nPlayerID)
	if hHero == hPurchaser then
		if hHero.BaowuSp == nil then
			hHero.BaowuSp = 0
		end
		if hHero.BaowuSp < 6 then
			hHero.BaowuSp = hHero.BaowuSp + 1
			self:SpendCharge()

			--拥有神赐光环的玩家宝物4选1，没有则3选1
			local selectNum = 3
			local aura_godNum = Store:GetData(nPlayerID,"aura_god")
			if aura_godNum ~= nil and aura_godNum > 0 then
				selectNum = 4
			end

			local newTable = {}
			local hastable = {}
			for i=1,#GlobalVarFunc.player_treasure_list[nPlayerID] do
				hastable[i] = GlobalVarFunc.player_treasure_list[nPlayerID][i]
			end
			for i = 1 , selectNum do
				local randomNum = RandomInt(1, #hastable)
				newTable[i] = hastable[randomNum]
				table.remove( hastable, randomNum )
			end
			GlobalVarFunc.baoWuChiZiTest[nPlayerID + 1] = newTable

			CustomGameEventManager:Send_ServerToPlayer(hPlayer,"show_treasure_select", {treasureTable = newTable})
		else
			CustomGameEventManager:Send_ServerToPlayer(hPlayer,"send_error_message_client",{message="SPECIAL_TREASURE_BOOK_USAGE_LIMIT"})
		end
	end
end

if item_devil_baoWu_book == nil then item_devil_baoWu_book = {} end
function item_devil_baoWu_book:OnSpellStart( event )

	if not IsServer() then return end
	local hHero = self:GetCaster()
	local nPlayerID = hHero:GetPlayerID()
	local hPlayer = PlayerResource:GetPlayer(nPlayerID)
	--2选1
	self:SpendCharge()
	local selectNum = 2
	local newTable = {}
	local hastable = {}
	for i=1,#GlobalVarFunc.player_devil_treasure_list[nPlayerID] do
		hastable[i] = GlobalVarFunc.player_devil_treasure_list[nPlayerID][i]
	end
	for i = 1 , selectNum do
		local randomNum = RandomInt(1, #hastable)
		newTable[i] = hastable[randomNum]
		table.remove( hastable, randomNum )
	end
	GlobalVarFunc.devilDaoWuChiZiTest[nPlayerID + 1] = newTable

	CustomGameEventManager:Send_ServerToPlayer(hPlayer,"show_devil_treasure_select", {treasureTable = newTable})		

end

-- 不记录个人使用上限的宝物书
if item_baowu_book_personage_use_limit == nil then item_baowu_book_personage_use_limit = {} end
function item_baowu_book_personage_use_limit:OnSpellStart( event )
	if not IsServer() then return end
	local hHero = self:GetCaster()
	local hPurchaser = self:GetPurchaser() 
	local nPlayerID = hHero:GetPlayerID()
	local hPlayer = PlayerResource:GetPlayer(nPlayerID)
	if hHero == hPurchaser then

		self:SpendCharge()

		--拥有神赐光环的玩家宝物4选1，没有则3选1
		local selectNum = 3
		local aura_godNum = Store:GetData(nPlayerID,"aura_god")
		if aura_godNum ~= nil and aura_godNum > 0 then
			selectNum = 4
		end

		local newTable = {}
		local hastable = {}
		for i=1,#GlobalVarFunc.player_treasure_list[nPlayerID] do
			hastable[i] = GlobalVarFunc.player_treasure_list[nPlayerID][i]
		end
		for i = 1 , selectNum do
			local randomNum = RandomInt(1, #hastable)
			newTable[i] = hastable[randomNum]
			table.remove( hastable, randomNum )
		end
		GlobalVarFunc.baoWuChiZiTest[nPlayerID + 1] = newTable

		CustomGameEventManager:Send_ServerToPlayer(hPlayer,"show_treasure_select", {treasureTable = newTable})
	end
end

if item_devil_tianzhan_quan == nil then item_devil_tianzhan_quan = {} end
function item_devil_tianzhan_quan:OnSpellStart( event )
	if not IsServer() then return end
	local hHero = self:GetCaster()
	local nPlayerID = hHero:GetPlayerID()
	self:SpendCharge()
	MobSpawner:OnCreatedEMoTianZhan(nPlayerID)
end
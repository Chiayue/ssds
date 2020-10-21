require( "system/inventory/inventory_backpack")
-- require( "system/inventory/inventory_order")

MaxBackpackCount = 20
if InventorySystem == nil then
	InventorySystem = class({})
	InventoryConfig = {}
end

local hGemTable = {
	"item_strength_gemstone_0",
	"item_strength_gemstone_1",
	"item_strength_gemstone_2",
	"item_strength_gemstone_3",
	"item_strength_gemstone_4",
	"item_strength_gemstone_5",
	"item_strength_gemstone_6",
	"item_strength_gemstone_7",
	"item_strength_gemstone_8",
	"item_strength_gemstone_9",
	"item_strength_gemstone_10",
	"item_strength_gemstone_11",
	"item_agility_gemstone_0",
	"item_agility_gemstone_1",
	"item_agility_gemstone_2",
	"item_agility_gemstone_3",
	"item_agility_gemstone_4",
	"item_agility_gemstone_5",
	"item_agility_gemstone_6",
	"item_agility_gemstone_7",
	"item_agility_gemstone_8",
	"item_agility_gemstone_9",
	"item_agility_gemstone_10",
	"item_agility_gemstone_11",
	"item_intelligece_gemstone_0",
	"item_intelligece_gemstone_1",
	"item_intelligece_gemstone_2",
	"item_intelligece_gemstone_3",
	"item_intelligece_gemstone_4",
	"item_intelligece_gemstone_5",
	"item_intelligece_gemstone_6",
	"item_intelligece_gemstone_7",
	"item_intelligece_gemstone_8",
	"item_intelligece_gemstone_9",
	"item_intelligece_gemstone_10",
	"item_intelligece_gemstone_11",
}

function ItemIsGem(hItem)
	local sItemName = hItem:GetAbilityName()
	for _,v in pairs(hGemTable) do
		if sItemName == v then
			return true
		end
	end
	return false
end
function InventorySystem:Init()
	--ListenToGameEvent( "game_rules_state_change" ,Dynamic_Wrap( self, 'StageChange' ), self )
	if GlobalVarFunc.game_mode == "endless" or  GlobalVarFunc.game_type == -2 then
		GameRules: GetGameModeEntity(): SetExecuteOrderFilter(Dynamic_Wrap(self,"ExecuteOrderFilter"),self)
		GameRules: GetGameModeEntity(): SetItemAddedToInventoryFilter(Dynamic_Wrap(self, 'ItemAddedToInventory'), self)
		local BackpackCount = {}
		local TreasureLimit = {}
		local nPlayerCount = PlayerResource:GetPlayerCount() 

		for i=0,nPlayerCount -1 do 
			BackpackCount[i] = MaxBackpackCount
			TreasureLimit[i] = {limit = 3,current = 0}
			Archive:LoadServerEqui(i)
		end
		InventoryConfig.MaxBackpackCount = BackpackCount
		InventoryConfig.TreasureLimit = TreasureLimit
		--self:InitItems()
		ListenToGameEvent("dota_item_picked_up",Dynamic_Wrap(self,"ItemPickedUp"),self)
		ListenToGameEvent("dota_inventory_player_got_item",Dynamic_Wrap(self,"ItemPickedUp"),self)
		ListenToGameEvent("dota_inventory_item_added",Dynamic_Wrap(self,"ItemPickedUp"),self)

		CustomNetTables:SetTableValue("common", "InventoryConfig", InventoryConfig)

		-- 移动物品
		CustomGameEventManager:RegisterListener("inventory_system_event_order",InventorySystem.EventOrder)
		-- 仓库丢弃物品
		CustomGameEventManager:RegisterListener("inventory_system_event_drop",InventorySystem.EventDrop)
		-- 物品事件
		CustomGameEventManager:RegisterListener("inventory_system_event",InventorySystem.ExecuteAbility)
		-- 物品信息
		CustomGameEventManager:RegisterListener("inventory_system_loading_index",InventorySystem.LoadingIndex)
		-- 箭魂分解
		CustomGameEventManager:RegisterListener("inventory_system_refine_series",InventorySystem.RefineSeries)
		-- 宝石镶嵌
		CustomGameEventManager:RegisterListener("inventory_system_event_open_setgem",InventorySystem.OpenSetgemPanel)
		CustomGameEventManager:RegisterListener("inventory_system_event_get_gem",InventorySystem.OnGetGem)
		CustomGameEventManager:RegisterListener("inventory_system_event_setgem_series",InventorySystem.OnSetGemSeries)

	else
		GameRules: GetGameModeEntity(): SetItemAddedToInventoryFilter(Dynamic_Wrap(self, 'ItemAddedToInventoryNormal'), self)
	end
end
function InventorySystem:OnSetGemSeries(args)
	local nPlayerID = args.PlayerID
	local hSeriesItem =  EntIndexToHScript(args.seriesItem)
	local hGemItem = EntIndexToHScript(args.gemIndex)
	local nSlot = args.slot
	local nCurrentGold = PlayerResource:GetGold(nPlayerID)
	local nNeedGetGold = math.ceil(hGemItem:GetCost() /5 )
	local hRes = {}
	if nCurrentGold >= nNeedGetGold then
		local sGemName = hGemItem:GetAbilityName()
		local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
	    local hHero = CDOTAPlayer:GetAssignedHero()
		hSeriesItem.bonus.gemslot_info[nSlot+1] = sGemName
		local bStatus = InventoryBackpack:RemoveItem( hHero, hGemItem  )
		if bStatus == false then
			-- hHero:TakeItem(hGemItem)
			hGemItem:RemoveSelf() 
		end
		PlayerResource:SpendGold(nPlayerID,nNeedGetGold,DOTA_ModifyGold_AbilityCost)
		hRes["status"] = true
		hSeriesItem:OnUnequip()
		hSeriesItem:OnEquip()
	else
		hRes["status"] = false
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="金币不够"})
	end
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"inventory_system_event_setgem_series_callback",hRes)
end
function InventorySystem:OnGetGem(args)
	local nPlayerID = args.PlayerID
	local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
    local hPlayerHero = CDOTAPlayer:GetAssignedHero()
	local hGemList = {}
	local hAllHero = HeroList:GetAllHeroes()
	--背包
	local pack = InventoryBackpack:GetBackpack(hPlayerHero)
	if pack ~= nil then
		for _,itemIndex in pairs(pack) do
			if itemIndex ~= -1 then
				local hItem = EntIndexToHScript(itemIndex)
				local hPurchaser =  hItem:GetPurchaser() 
				local bIsGem = ItemIsGem(hItem)
				if bIsGem == true  and hPurchaser == hPlayerHero then
					table.insert( hGemList, itemIndex )
				end
			end
		end
	end

	for k,hHero in pairs(hAllHero) do
		--物品栏
		for i=0,8 do
			local hItem = hHero:GetItemInSlot(i)
			if hItem ~= nil then
				local bIsGem = ItemIsGem(hItem)
				local hPurchaser =  hItem:GetPurchaser() 
				if bIsGem == true and hPurchaser == hPlayerHero then
					local itemIndex = hItem:GetEntityIndex()
					table.insert( hGemList, itemIndex )
				end
			end
		end
	end
	
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"inventory_system_event_get_gem_callback",hGemList)
end

function InventorySystem:OpenSetgemPanel(args)
	local nPlayerID = args.PlayerID
	local hItem = EntIndexToHScript(args.nItemIndex or -1 )
	if hItem.bonus ~= nil then
		hItem.bonus.itemIndex = nItemIndex
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"inventory_system_event_open_setgem_callback",hItem.bonus)
	end
end


function InventorySystem:GetArrowSoul(hItem)
	local nSeason = hItem.bonus.season
	local nTier = hItem.bonus.tier
	local nArrowSoul = nTier * 20
	return nArrowSoul
end
-- 分解装备
function InventorySystem:RefineSeries(args)
	local nPlayerID = args.PlayerID
	local nSlot = args.Slot
	local sCategory = args.Category
	local hUnit = EntIndexToHScript(args.queryUnit or -1 )
	if sCategory == "backpack" then
		local nItemIndex = InventoryBackpack:GetItemIndex( hUnit, nSlot )
		local hItem = EntIndexToHScript(nItemIndex or -1 )
		local hItemPurchaser = hItem:GetPurchaser()
		if hItem.bonus ~= nil and hUnit == hItemPurchaser then
			local nSeason = hItem.bonus.season
			local nTier = hItem.bonus.tier
			local sItemName = hItem:GetAbilityName()
			InventoryBackpack:RemoveItem( hUnit, hItem  )
			local nArrowSoul = InventorySystem:GetArrowSoul(hItem)
			Store:AddCustomGoodsValue(nPlayerID,"arrow_soul",nArrowSoul,"分解箭魂装备 "..sItemName,false)
			Archive:SaveServerEqui(nPlayerID)
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"inventory_system_item_swap_callback",{})
		end
	elseif sCategory == "equipment" then
		local hItem = hUnit:GetItemInSlot(nSlot)
		local hItemPurchaser = hItem:GetPurchaser()
		if hItem.bonus ~= nil and hUnit == hItemPurchaser then
			local nArrowSoul = InventorySystem:GetArrowSoul(hItem)
			local sItemName = hItem:GetAbilityName()
			hUnit:TakeItem(hItem)
			Store:AddCustomGoodsValue(nPlayerID,"arrow_soul",nArrowSoul,"分解箭魂装备 "..sItemName,false)
			Archive:SaveServerEqui(nPlayerID)
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"inventory_system_item_swap_callback",{})
		end
	end
end
function InventorySystem:LoadingIndex(args)
	-- 读物品
	local nPlayerID = args.PlayerID
	local nItemIndex = args.itemIndex
	local hItemInfo = EntIndexToHScript(nItemIndex or -1)
	if hItemInfo ~= nil then
		if hItemInfo.bonus ~= nil then
			hItemInfo.bonus.itemIndex = nItemIndex
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"inventory_system_iteminfo_callback",hItemInfo.bonus)
		end
	end
end
function InventorySystem:ItemPickedUp( args )
	if args.game_event_name == "dota_item_picked_up" then
		local hHero = EntIndexToHScript(args.HeroEntityIndex or -1)
		local hItem = EntIndexToHScript(args.ItemEntityIndex or -1)
		if hItem.bonus ~= nil then
			local hItemPurchaser = hItem:GetPurchaser()
			--print(hItemPurchaser,hHero)
			if hItemPurchaser ~= hHero then
				local vVector = hHero:GetAbsOrigin()
				hHero:DropItemAtPositionImmediate(hItem,vVector)
			end
		end
	end
end

function InventorySystem:ExecuteAbility(args)
	-- DeepPrintTable(args)
	local order = args.order
	local packIndex = args.source_slot
	local nPlayerID = args.PlayerID 
	local unit = PlayerResource:GetSelectedHeroEntity(nPlayerID)
	if order == "activate" then
		-- 双击物品
		local nItem = InventoryBackpack:GetItemIndex( unit, packIndex )
		local newOrder = {
	 		UnitIndex = unit:entindex(), 
	 		OrderType = DOTA_UNIT_TARGET_ALL,
	 		TargetIndex = unit:entindex()
	 	}

	 	-- DeepPrintTable(newOrder)
		-- ExecuteOrderFromTable(newOrder)
	end
end
function InventorySystem:StageChange()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		Timer(1,function()
            for nPlayerID = 0,PlayerResource:GetPlayerCount() - 1 do
                local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
                if hHero ~= nil then
                   InventoryBackpack:RegisterUnit( hHero )
                end
            end
        end)    
	end
end

function InventorySystem:EventDrop(args)
	-- print("drop")
	local nSlot = args.source_slot
	local nPlayerID = args.PlayerID
	local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
	local nItemIndex = InventoryBackpack:GetItemIndex( hHero, nSlot )
	local hItem = EntIndexToHScript(nItemIndex)
	InventoryBackpack:DropItemToOtherUnit(hHero, hHero, hItem)	
end

function InventorySystem:EventOrder(args)
	-- DeepPrintTable(args)
	local target = args.target
	local source = args.source
	local nPlayerID = args.PlayerID
	local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
	if target ~= source then
		local slot = -1
		local packIndex = -1
		if source == "equipment" then
			slot = args.source_slot
			packIndex = args.target_slot
		else
			slot = args.target_slot
			packIndex = args.source_slot
		end
		InventoryBackpack:SwapInInventory(hHero, packIndex, slot)
	elseif source == "backpack" then
		local packIndex1 = args.source_slot
		local packIndex2 = args.target_slot
		InventoryBackpack:SwapItem( hHero, packIndex1, packIndex2 )
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"inventory_system_item_swap_callback",{})
	end
end

function InventorySystem:ExecuteOrderFilter(params)
	
	local orderType = params.order_type
	local playerID = params.issuer_player_id_const
	-- local queue = params.queue
	-- DeepPrintTable(params)
	if orderType == 16 then
		-- DeepPrintTable(params)
		-- local hItem = EntIndexToHScript(params.entindex_ability or -1)
		-- local sItemName = hItem:GetAbilityName()
		-- if sItemName == "item_gerenbaoWu_book" then
		-- 	local TreasureLimit = InventoryConfig.TreasureLimit
		-- 	local nCurrent = TreasureLimit["current"]
		-- 	local nLimit = TreasureLimit["limit"]
		-- 	if nCurrent < nLimit then
		-- 		TreasureLimit["current"] = TreasureLimit["current"] + 1
		-- 		InventoryConfig.TreasureLimit = TreasureLimit
		-- 		return true
		-- 	else
		-- 		return false
		-- 	end
		-- end
	end
	if orderType == 19 then
		local target = params.entindex_target
		if target > 8 then
			-- 移动到仓库
			local hHero = EntIndexToHScript(params.units["0"])
			local packIndex = InventoryBackpack:GetNotUseIndex( hHero )
			if packIndex ~= -1 then
				InventoryBackpack:SwapInInventory(hHero, packIndex, target)
			end
		end
	end
	-- 禁止把存档装备给其他玩家
	if orderType == 13 then 
		local hHero = EntIndexToHScript(params.units["0"])
		local hItem = EntIndexToHScript(params.entindex_ability or -1)
		local hTarget = EntIndexToHScript(params.entindex_target or -1)
		local hItemPurchaser = hItem:GetPurchaser()
		if hItem.bonus ~= nil then
			if hItemPurchaser ~= hTarget then
				return false
			end
		end
	end                     	
	return true
end

function InventorySystem:ItemAddedToInventoryNormal(keys)
	local iItemIndex = keys.item_entindex_const
	local hItem = EntIndexToHScript(iItemIndex)

	local sItemName = hItem:GetAbilityName()
	if sItemName == "item_tpscroll" then
		hItem:EndCooldown()
		return true
	end
	if sItemName == "item_enchanted_mango" then
		return false
	end
	if ITEM_CUSTOM[sItemName] == nil then
		return false
	else
		return true
	end
end
function InventorySystem:ItemAddedToInventory(keys)
	-- print("ItemAddedToInventory")
	--DeepPrintTable(keys)

	local iInventoryParentIndex = keys.inventory_parent_entindex_const
	local hInventoryParent = EntIndexToHScript(keys.inventory_parent_entindex_const)
	local vVector = hInventoryParent:GetOrigin()

	local player = hInventoryParent:GetPlayerOwner()
	local nPlayerID = hInventoryParent:GetPlayerOwnerID()
	local courier

	local iItemParentIndex = keys.item_parent_entindex_const
	local hItemParent = EntIndexToHScript(keys.item_parent_entindex_const)

	local iItemIndex = keys.item_entindex_const
	local hItem = EntIndexToHScript(iItemIndex)

	local sItemName = hItem:GetAbilityName()
	if sItemName == "item_tpscroll" then
		hItem:EndCooldown()
		return true
	end

	if sItemName == "item_enchanted_mango" then
		return false
	end

	-- 判断是否开启背包
	local pack = InventoryBackpack:GetBackpack(hInventoryParent)
	if pack then
		--print("backpack")
		-- 如果是可叠加的物品
		local nCharges = hItem:GetCurrentCharges()
		if nCharges > 0 then
			for i = 0,8 do 
				local hInvItem = hInventoryParent:GetItemInSlot(i)
				if hInvItem ~= nil then
					local sInvItemName = hInvItem:GetAbilityName()
					if sItemName == sInvItemName then
						return true
					end
				end
			end
		end
		-- hItem:SetPurchaser(nil)
		if hInventoryParent:GetUnitName() == "unit_courier" then
			if player and player:GetAssignedHero() then
				courier = hInventoryParent
				hInventoryParent = player:GetAssignedHero()
			end
		end
		--
		-- 检车同部位装备

		if ITEM_CUSTOM[sItemName].position ~= nil then
			local sPosition = ITEM_CUSTOM[sItemName].position
			for i = 0,8 do
				local hInvItem = hInventoryParent:GetItemInSlot(i)
				if hInvItem ~= nil then
					local sInvItemName = hInvItem:GetAbilityName()
					if hItem ~= hInvItem then
						if ITEM_CUSTOM[sInvItemName].position == sPosition then
							-- 放进背包
							local status = InventoryBackpack:AddItemImmediate( hInventoryParent, hItem )
							-- 背包满了
							--print("backpack status",status)
							if status == false then
								-- 丢弃
								--print("drop")
								local drop = CreateItemOnPositionSync( vVector + RandomVector(RandomFloat(50, 150)) , hItem)
								if drop then drop:SetContainedItem( hItem ) end
							end
							return false
						end
					end
					
				end
			end
		end
		--print("courier",hInventoryParent:GetNumItemsInInventory())
		if hInventoryParent:GetNumItemsInInventory() < 9 then
			if not courier then
				return true
			end
		end
		
		local status = InventoryBackpack:AddItemImmediate( hInventoryParent, hItem )
		--print("status",status)
		if status == false then

			local drop = CreateItemOnPositionSync( vVector + RandomVector(RandomFloat(50, 150)) , hItem)
			if drop then drop:SetContainedItem( hItem ) end
		end
		return false
	else
		--print("add true")
		return true
	end
	
end

function InventorySystem:InitItems()
	local items_custom = LoadKeyValues("scripts/npc/npc_items_custom.txt")

	for sItemName,v in pairs(items_custom) do
		--print(sItemName)
		local t = GetSpecialData(v)
		--CustomNetTables:SetTableValue("item_system", sItemName, t)
	end
	--CustomNetTables:SetTableValue("item_system", k, v)

end

function GetSpecialData( o )
	if type(o) ~= "table" then
		return nil
	end
	local SpecialHide = {
		["var_type"] = true,
	}
	if o.AbilitySpecial ~= nil then
		local t = {}
		for _,special in pairs(o.AbilitySpecial) do
			for k,v in pairs(special) do
				if not SpecialHide[k] then
					if type(v) == "number" and math.floor(v) < v then
						t[k] = string.format("%.2f",v)
					else
						t[k] = v
					end
				end
			end
		end
		return t
	end
	return nil
end
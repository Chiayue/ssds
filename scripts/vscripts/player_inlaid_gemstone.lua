-- 玩家镶嵌宝石系统   监听

if Player_Inlaid_Gemstone == nil then 
	Player_Inlaid_Gemstone = class({})
end

--ITEM_NAME = ""
--isInit = false
local gemstone_table = {}
gemstone_table["ItemName"] = "v"

function Player_Inlaid_Gemstone:init() -- 玩家镶嵌宝石的网表
	-- if isInit == true then
 --        return
 --    end
    --isInit = true
    print("{is gmestone init yes}")
    
	CustomNetTables:SetTableValue( "gemstone", "gemstone", gemstone_table)

end

--得到宝石名字的方法
function Player_Inlaid_Gemstone:GetItemName( itemname )
	--local itemName = itemname
	print("itemName=", itemname)

	gemstone_table["ItemName"] = itemname
	CustomNetTables:SetTableValue( "gemstone", "gemstone", gemstone_table)
	--return itemName
end

---------------------------------------未使用--------------------------------------
--local gemstone_name = ""
-- if Player_Inlaid_Gemstone == nil then 
-- 	Player_Inlaid_Gemstone = class({})
-- end

-- function Player_Inlaid_Gemstone:init(  )
-- 	print("this is gemstone init")
-- 	CustomGameEventManager:RegisterListener( "SetGemstoneName", self.OnGemstoneInlay)
-- end

-- function Player_Inlaid_Gemstone:OnGemstoneInlay( event )
-- 	print(DeepPrintTable(event))
	
-- 	local item_name = GetItemName()

-- 	--if unit:IsHero() then
-- 		local nPlayerID = event.PlayerID
-- 		print("nPlayerID=", nPlayerID)
-- 		if IsValidEntity(nPlayerID) then 
-- 			print("OnGemstoneInlay.item_name=", item_name)
-- 			self:SetItemName(nPlayerID, item_name)
-- 		end
-- 	--end
-- end

-- function Player_Inlaid_Gemstone:SetItemName( PlayerID, ItemName )
-- 	print("args_1")
-- 	print("SetItemName.ItemName =", ItemName)
-- 	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(PlayerID), 
-- 		"SetItemName", {gemstone_name = ItemName})
-- end





-- function Player_Inlaid_Gemstone:GetItemName( ItemName )
-- 	local item_name = ItemName
-- 	print("name=", item_name)
-- 	--CustomGameEventManager:RegisterListener( "SetItemName", self.OnGemstoneInlay)
-- 	return item_name
-- end

-- function GameMode:RegisterUIEventListeners()
-- 	CustomGameEventManager:RegisterListener("player_select_ability",function(_, keys)
-- 		self:OnPlayerSelectAbility(keys)
-- 	end)
-- end

-- -- 玩家镶嵌宝石
-- function GameMode:OnPlayerSelectAbility(keys)
-- 	local itemName = keys.ItemName -- 物品名字
-- 	local playerID = keys.PlayerID -- 玩家ID
-- 	local player = PlayerResource:GetPlayer(playerID) -- 当前玩家
-- 	local hero  = player:GetAssignedHero() -- 当前英雄
-- 	if not hero then return end

-- 	-- 找到一个空白的物品栏来替换
-- 	local itemName_Replace

-- 	local empty_itemes = 
-- 		{
-- 			"empty_gemstone_inventory_1",
-- 			"empty_gemstone_inventory_2",
-- 			-- "empty_gemstone_inventory_3",
-- 		}

-- 	for _, name in pairs(empty_itemes) do
-- 		if hero:HasItemInInventory(name) then
-- 			itemName_Replace = name
-- 			break
-- 		end
-- 	end
-- end
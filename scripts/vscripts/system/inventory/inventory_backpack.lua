
m_UnitItems = {}

if InventoryBackpack == nil then
	InventoryBackpack = {}
	--print("setmetatable(InventoryBackpack,InventoryBackpack)")
	setmetatable(InventoryBackpack,InventoryBackpack)
end

--@description 发送事件到UI，通知UI更新相应的格子
--@param unit handle 单位
--@param packIndex int 背包的位置
--@return nil
function InventoryBackpack:UpdateItem( unit, packIndex )
	local pack = self:GetBackpack(unit)

	if pack then
		assert(packIndex,"packIndex should be a number")
		local itemIndex = pack[packIndex]
		local event = "inventory_system_update_item_"..tostring(packIndex)
		CustomGameEventManager:Send_ServerToPlayer(unit:GetPlayerOwner(),event,{SlotIndex = packIndex,itemIndex = itemIndex})
		-- 储存到网表
		-- print(event)
		-- DeepPrintTable(m_UnitItems[unit:GetEntityIndex()])
		local nEnitIndex = unit:GetEntityIndex()
		CustomNetTables:SetTableValue("backpack_system", "pack_"..nEnitIndex, m_UnitItems[nEnitIndex])
	end
end


--@description 获取单位的背包
--@param unit handle 单位
--@return table
function InventoryBackpack:GetBackpack( unit )
	if type(unit) ~= "table" then return nil end
	if unit:IsNull() then return nil end
	return m_UnitItems[unit:GetEntityIndex()]
end


--@description 获取背包中的物品数量
--@param unit handle 单位
--@return int
function InventoryBackpack:GetItemCount( unit )

	local pack = self:GetBackpack(unit)

	if pack then
		local num = 0

		for _,itemIndex in pairs(pack) do
			if itemIndex ~= -1 then
				num = num + 1
			end
		end

		return num
	end

	return -1
end

--@description 获取背包中某物品的数量
--@param unit handle 单位
--@return int
function InventoryBackpack:GetItemCountByItemName( unit,itemName )

	local pack = self:GetBackpack(unit)

	if pack then
		local num = 0

		for _,itemIndex in pairs(pack) do
			if itemIndex ~= -1 then
				local item = EntIndexToHScript(itemIndex)
				if item:GetAbilityName() == itemName then
					if item:IsStackable() then
						num = num + item:GetCurrentCharges()
					else
						num = num + 1
					end
				end
			end
		end

		return num
	end

	return 0
end

--@description 获得物品在背包中的位置
--@param unit handle 单位
--@param item handle 物品
--@return int
function InventoryBackpack:GetItemBagIndex( unit, item )
	local pack = self:GetBackpack(unit)

	if pack then
		local index = item:GetEntityIndex()

		for packIndex,itemIndex in pairs(pack) do
	 		if itemIndex == index then
	 			return packIndex
	 		end
	 	end
	end

	return -1
end

--@description 判断单位是否有背包
--@param unit handle 单位
--@return bool
function InventoryBackpack:HasBackpack( unit )
	return self:GetBackpack(unit) ~= nil
end

--@description 判断背包是否填满
--@param unit handle 单位
--@return bool
function InventoryBackpack:IsFull( unit )
	return self:GetItemCount(unit) == MaxBackpackCount
end

--@description 判断背包中是否有物品
--@param unit handle 单位
--@param itemIndex int 物品EntityIndex
--@return bool,int
function InventoryBackpack:HasItem( unit, itemIndex )

	local pack = self:GetBackpack(unit)

	if pack then
		assert(itemIndex,"itemIndex should be a number")

		for packIndex,index in pairs(pack) do
			if index == itemIndex then
				return true,packIndex
			end
		end
	end

	return false,-1
end

--@description 删除物品
--@param unit handle 单位
--@param item handle 物品
--@return bool
function InventoryBackpack:RemoveItem( unit, item  )
	if item == nil then return false end
	if item:IsNull() then return false end

	local hasItem,packIndex = self:HasItem( unit, item:GetEntityIndex() )

	if hasItem then
		local box = item:GetContainer()
		if box and not box:IsNull() then
			box:RemoveSelf()
		end

		item:RemoveSelf()

		local pack = self:GetBackpack(unit)
		pack[packIndex] = -1;

		self:UpdateItem( unit, packIndex )

		return true
	end

	return false
end

--@description 消耗物品
--@param unit handle 单位
--@param item handle 物品
--@oparam charges int 可选，如果是有可叠加的物品，传入charges消耗相应数量，不传入则是整个删除，charges必须小于等于当前叠加数量
--@oparam isRemove bool 可选，如果叠加数量消耗为0是否删除
--@return bool
function InventoryBackpack:UseItem( unit, item, charges, isRemove )
	if item == nil then return false end
	if item:IsNull() then return false end
	if type(charges) == "number" then return false end
 
	if item:GetCurrentCharges() >= charges then
		item:SetCurrentCharges(item:GetCurrentCharges()-charges)

		if item:GetCurrentCharges() == 0 and isRemove then
			return self:RemoveItem( unit, item  )
		end

		return true
	end
end


--@description 将物品从背包中移除，而不是删除
--@param unit handle 单位
--@param item handle 物品
--@return bool
function InventoryBackpack:Undock( unit, item )
	local packIndex = self:GetItemBagIndex( unit, item )

	if packIndex ~= -1 then
		local pack = self:GetBackpack(unit)
		pack[packIndex] = -1;
		self:UpdateItem( unit, packIndex )

		return true
	end

	return false
end

--@description 查找物品
--@param unit handle 单位
--@param itemName string 物品名称
--@return item,packIndex 如果没有为nil
function InventoryBackpack:FindItemByName( unit, itemName )
	local pack = self:GetBackpack(unit)

	if pack then
	 	for packIndex,itemIndex in pairs(pack) do
	 		local item = EntIndexToHScript(itemIndex)
	 		if item and not item:IsNull() and item:GetAbilityName() == itemName then
	 			return item,packIndex
	 		end
	 	end
	end

	return nil
end

--@description 查看物品是否在背包中
--@param unit handle 单位
--@param item handle 物品
--@return bool
function InventoryBackpack:HasItemInBackpack( unit, item )
	if type(item) ~= "table" then return false end
	if item:IsNull() then return false end

	return self:HasItem( unit, item:GetEntityIndex() )
end

--@description 获取一个空的物品格
--@param unit handle 单位
--@return int
function InventoryBackpack:GetNotUseIndex( unit )
	if not self:IsFull(unit) then
		local pack = self:GetBackpack(unit) or {}
		for packIndex,itemIndex in pairs(pack) do
			if itemIndex == -1 then
				return packIndex
			end
		end
	end

	return -1
end

--@description 获取物品
--@param unit handle 单位
--@param packIndex int 背包中的位置
--@return int
function InventoryBackpack:GetItemIndex( unit, packIndex )
	local pack = self:GetBackpack(unit)

	if pack then
	 	local itemIndex = pack[packIndex]

	 	if itemIndex then
	 		return itemIndex
	 	end
	end

	return -1
end

--@description 添加物品到背包，这个主要用于从地上捡起物品
--@param unit handle 单位
--@param item handle 物品
--@return bool
function InventoryBackpack:AddItem( unit, item )
	if type(item) ~= "table" then return false end
	if item:IsNull() then return false end

	if self:IsFull(unit) then return false end

	if self:HasItemInBackpack( unit, item ) then return false end

	local box = item:GetContainer()
	if box and not box:IsNull() then box:RemoveSelf() end

	if unit:GetNumItemsInInventory() >= 6 then
		-- unit:AddItem(item)
	end

	unit:SetContextThink(DoUniqueString("Backpack"), function( )
		local packIndex = self:GetNotUseIndex(unit)

		if packIndex ~= - 1 then
			local pack = self:GetBackpack(unit)

			if pack then
				pack[packIndex] = item:GetEntityIndex()
				-- item.m_IsEquipped = false
				unit:TakeItem(item)

				self:UpdateItem( unit, packIndex )
				return nil
			end
		end

	end, 0.2)

	return true
end

--@description 立即添加物品
--@param unit handle 单位
--@param item handle 物品
--@return bool
function InventoryBackpack:AddItemImmediate( unit, item )
	if type(item) ~= "table" then return false end
	if item:IsNull() then return false end
	local itemName = item:GetAbilityName()
	local charges = item:GetCurrentCharges()
	if charges > 0 then
		backpackItem,packindex = self:FindItemByName( unit, itemName )

		if packindex ~= nil and packindex ~= -1 then
			-- 有该物品，叠加
			unit:TakeItem(item)
			local backpackCharges = backpackItem:GetCurrentCharges()
			backpackItem:SetCurrentCharges(backpackCharges + charges)
			return true
		end
	end
	if self:IsFull(unit) then return false end
	-- print("hasitem",self:HasItemInBackpack( unit, item ))
	-- if self:HasItemInBackpack( unit, item ) then return false end

	if unit:GetNumItemsInInventory() >= 6 then
		local box = item:GetContainer()
		if box and not box:IsNull() then box:RemoveSelf() end
		-- unit:AddItem(item)
	end



	local packIndex = self:GetNotUseIndex(unit)
	print("packIndex:",packIndex)
	if packIndex ~= -1 then
		local pack = self:GetBackpack(unit)

		if pack then
			pack[packIndex] = item:GetEntityIndex()
			item.m_IsEquipped = false
			unit:TakeItem(item)
			self:UpdateItem( unit, packIndex )
		end
	end

	return true
end

--@description 掉落物品
--@param unit handle 单位
--@param item handle 物品
function InventoryBackpack:DropItem( unit, item )
	if type(item) ~= "table" then return nil end
	if item:IsNull() then return nil end

	local hasItem,packIndex = self:HasItem(unit,item:GetEntityIndex())

	if hasItem then
		local pos = unit:GetOrigin()

		local drop = CreateItemOnPositionSync( pos + RandomVector(RandomFloat(50, 150)) , item)
		if drop then
			drop:SetContainedItem( item )
		end

		self:Undock( unit, item )
	end

end

--@description 掉落物品到其它单位
--@param parent handle 单位
--@param unit handle 单位
--@param item handle 物品
function InventoryBackpack:DropItemToOtherUnit( parent, unit, item )
	if type(item) ~= "table" then return nil end
	if item:IsNull() then return nil end

	local hasItem,packIndex = self:HasItem(parent,item:GetEntityIndex())

	if hasItem then
		local pos = unit:GetOrigin()

		local drop = CreateItemOnPositionSync( pos + RandomVector(RandomFloat(50, 150)) , item)
		if drop then
			drop:SetContainedItem( item )
		end

		self:Undock( parent, item )
	end

end

--@description 掉落物品到某位置
--@param unit handle 单位
--@param item handle 物品
--@param pos vector 位置
function InventoryBackpack:DropItemToPosition( unit, item, pos )
	if type(item) ~= "table" then return nil end
	if type(pos) ~= "userdata" then return nil end
	if item:IsNull() then return nil end

	local hasItem,packIndex = self:HasItem(unit,item:GetEntityIndex())

	if hasItem then

		ExecuteOrderFromTable
		{
			UnitIndex = unit:GetEntityIndex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = pos,
			Queue = 0
		}

		unit.m_Backpack_DropItemToPosition_OrderType = DOTA_UNIT_ORDER_DROP_ITEM

		unit:SetContextThink(DoUniqueString("DropItemToPosition"), function()

			if unit.m_Backpack_DropItemToPosition_OrderType ~= DOTA_UNIT_ORDER_DROP_ITEM then
				return nil
			end

			if (unit:GetOrigin() - pos):Length2D() <= 150 then

				local drop = CreateItemOnPositionSync( pos , item)
				if drop then
					drop:SetContainedItem( item )
				end

				unit:Stop()

				self:Undock( unit, item )

				return nil
			end

			return 0.2
		end, 0)

	end
end

--@description 掉落物品其它单位的某位置
--@param parent handle 单位
--@param unit handle 单位
--@param item handle 物品
--@param pos vector 位置
function InventoryBackpack:DropItemToOtherUnitPosition( parent, unit, item, pos )
	if type(item) ~= "table" then return nil end
	if type(pos) ~= "userdata" then return nil end
	if item:IsNull() then return nil end

	local hasItem,packIndex = self:HasItem(parent,item:GetEntityIndex())

	if hasItem then

		ExecuteOrderFromTable
		{
			UnitIndex = unit:GetEntityIndex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = pos,
			Queue = 0
		}

		unit.m_Backpack_DropItemToPosition_OrderType = DOTA_UNIT_ORDER_DROP_ITEM

		local itemIndex = item:GetEntityIndex()
		local pack = self:GetBackpack(parent)

		unit:SetContextThink(DoUniqueString("DropItemToPosition"), function()

			if unit.m_Backpack_DropItemToPosition_OrderType ~= DOTA_UNIT_ORDER_DROP_ITEM then
				return nil
			end

			if (unit:GetOrigin() - pos):Length2D() <= 150 then

				if pack[packIndex] ~= itemIndex then
					return nil
				end

				local drop = CreateItemOnPositionSync( pos , item)
				if drop then
					drop:SetContainedItem( item )
				end

				unit:Stop()

				self:Undock( parent, item )

				return nil
			end

			return 0.2
		end, 0)

	end
end

--@description 对换位置
--@param unit handle 单位
--@param packIndex1 int 背包中的位置
--@param packIndex2 int 背包中的位置
function InventoryBackpack:SwapItem( unit, packIndex1, packIndex2 )
	if packIndex1 > MaxBackpackCount or packIndex1 < 0 then return false end
	if packIndex2 > MaxBackpackCount or packIndex2 < 0 then return false end

	local pack = self:GetBackpack(unit)

	if pack then
	 	local temp = pack[packIndex1]
	 	pack[packIndex1] = pack[packIndex2]
	 	pack[packIndex2] = temp

	 	self:UpdateItem( unit, packIndex1 )
	 	self:UpdateItem( unit, packIndex2 )
	end
end

--@description 与物品栏位置对换
--@param unit handle 单位
--@param packIndex int 背包中的位置
--@param slot int 物品栏中的位置
--@return bool
function InventoryBackpack:SwapInInventory( unit, packIndex, slot )
	-- print("SwapInInventory","packIndex:",packIndex,"  slot",slot)
	if packIndex == -1 then
		return false
	end
	-- print(unit, packIndex, slot)
	-- print(self:HasBackpack(unit))
	if self:HasBackpack(unit) then
		-- if slot > 15 then return false end

		local pack = self:GetBackpack(unit)
		local item = unit:GetItemInSlot(slot)
		if item ~= nil then
			if item:IsDroppable() == false then
				return false
			end
		end
		
		if item == nil and pack[packIndex] == -1 then return false end
		-- 背包物品
		local packItem = EntIndexToHScript(pack[packIndex])
		-- 如果背包物品与装备栏里物品有相同部件
		if packItem then
			local sItemName = packItem:GetAbilityName()
			local sPosition = ITEM_CUSTOM[sItemName].position
			if sPosition ~= nil then
				for i = 0,8 do
					local hInvItem = unit:GetItemInSlot(i)
					if hInvItem ~= nil then
						local sInvItemName = hInvItem:GetAbilityName()
						local sInvPosition = ITEM_CUSTOM[sInvItemName].position
						if ITEM_CUSTOM[sInvItemName].position == sPosition then
							return false
						end
					end
				end

			end
		end

		if item then
			pack[packIndex] = item:GetEntityIndex()
			-- item.m_IsEquipped = false
			unit:TakeItem(item)
		else
			pack[packIndex] = -1
		end

		if packItem then
			


			-- packItem.m_IsEquipped = true
			unit:AddItem(packItem)

			local s = 0
			for i=0,8 do
				local item = unit:GetItemInSlot(i)
				if item == packItem then
					s = i
				end
			end
			--print("SwapItems",s,"<>",slot)
			unit:SwapItems(s,slot)
		end

		self:UpdateItem( unit, packIndex )

		return true
	end

	return false
end

--@description 遍历 Traverse
--@param unit handle 单位
--@param func function 函数，每遍历一个物品调用一次，空的格子不遍历，返回true终止遍历，固有参数(pack,packIndex,itemIndex)
function InventoryBackpack:Look( unit, func )
	if self:HasBackpack(unit) then
		local pack = self:GetBackpack(unit)

		for packIndex,itemIndex in pairs(pack) do
			if itemIndex ~= -1 then
				if func(pack,packIndex,itemIndex) then return end
			end
		end
	end
end

--@description 创建物品
--@param unit handle 单位
--@param itemName string 物品名称
function InventoryBackpack:CreateItem( unit, itemName )
	if self:HasBackpack(unit) then
		if self:IsFull(unit) then
			local pos = unit:GetOrigin()
			local addItem = CreateItem(itemName, nil, nil)
			local drop = CreateItemOnPositionSync( pos + RandomVector(RandomFloat(50, 150)) , addItem)
			if drop then
				drop:SetContainedItem( addItem )
			end

			return addItem
		else
			local addItem = CreateItem(itemName, nil, nil)
			InventoryBackpack:AddItemImmediate( unit, addItem )

			return addItem
		end
	end
end

--@description 出售物品
--@param unit handle 单位
--@param item handle 物品
function InventoryBackpack:SellItem( unit, item )
	if type(item) ~= "table" then return nil end
	if item:IsNull() then return nil end

	local cost = item:GetCost()

	local data = item_table[item:GetAbilityName()]

	if data then
		if data.quality == 1 then
			cost = 100
		elseif data.quality == 2 then
			cost = 100
		elseif data.quality == 3 then
			cost = 100
		elseif data.quality == 4 then
			cost = 300
		elseif data.quality == 5 then
			cost = 300
		elseif data.quality == 6 then
			cost = 900
		elseif data.quality == 7 then
			cost = 900
		elseif data.quality == 8 then
			cost = 900
		end
	end

	if cost == 0 then return end

	if InventoryBackpack:RemoveItem( unit, item ) then
		PlayerResource:ModifyGold(unit:GetPlayerOwnerID(),cost,false,DOTA_ModifyGold_SellItem)
		EmitSoundOnClient("General.Coins",unit:GetPlayerOwner())

		local p = ParticleManager:CreateParticle("particles/econ/items/alchemist/alchemist_midas_knuckles/alch_knuckles_lasthit_coins.vpcf",PATTACH_CUSTOMORIGIN,unit)
		ParticleManager:SetParticleControl(p,1,unit:GetOrigin())
		ParticleManager:ReleaseParticleIndex(p)
	end
end

--@description 放置末尾
--@param unit handle 单位
--@param item handle 物品
function InventoryBackpack:ItemPosToEnd( unit, packIndex )
	local count = MaxBackpackCount

	
	if packIndex > count or packIndex < 0 then return false end

	local pack = self:GetBackpack(unit)

	if pack then
		for i=count,1,-1 do
			if pack[i] == -1 then
				InventoryBackpack:SwapItem( unit, packIndex, i )
				break
			end
		end
	end
end

-- 初始化，给予单位背包从这里开始
function InventoryBackpack:RegisterUnit( unit )
	print("InventoryBackpack:__call")
	if type(unit) ~= "table" then return end
	if unit:IsNull() then return end
	if not unit:HasInventory() then return end

	local unitIndex = unit:GetEntityIndex()
	local data = {}
	for i=0,MaxBackpackCount - 1 do
		data[i] = -1
	end

	m_UnitItems[unitIndex] = data
	CustomNetTables:SetTableValue("backpack_system", "pack_"..unitIndex, m_UnitItems[unitIndex])
	local pack = self:GetBackpack(unit)
	unit:SetContextThink(DoUniqueString("Backpack"), function( )
		for packIndex,itemIndex in pairs(pack) do
			if itemIndex ~= -1 then
				local item = EntIndexToHScript(itemIndex)
				if item == nil then
					pack[packIndex] = -1
					self:UpdateItem( unit, packIndex )
				end
			end
		end
		--DeepPrintTable(m_UnitItems[unitIndex])
		return 3
	end, 3)

end
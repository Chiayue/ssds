-- 炼金术士   把两个同等级的宝石升级为下一级的宝石
-- LinkLuaModifier( "modifier_archon_ability_tornado", "ability/archon_ability_tornado.lua",LUA_MODIFIER_MOTION_NONE )

if gold_metallurgy_warlock == nil then 
	gold_metallurgy_warlock = class({})
end

function gold_metallurgy_warlock:OnSpellStart()


	local caster = self:GetCaster() -- 技能拥有着
	-- 1.获取当前背包的 1 2 格有没有相同的宝石(ID是否相同)
	--local player = self:GetPlayerID()
	local playerBag_0 = caster:GetItemInSlot(0) -- 第一个背包格子的物品
	local playerBag_1 = caster:GetItemInSlot(1) -- 第二个背包格子的物品

	-- 判断当前玩家背包的宝石是否是自己的  有：可实行  无：return
	-- GetContainer() 物品的所有者
	-- local player_item = playerBag_0:GetContainer()
	-- print("player_item", player_item)

	if playerBag_0 == nil or playerBag_1 == nil then
		return 
	end

   	local stoneName1 = playerBag_0:GetAbilityName()
   	local stoneName2 = playerBag_1:GetAbilityName()

	if playerBag_0 == nil or playerBag_1 == nil then 
		return
	end

	-- 2.判断是否是同等级装备
	if playerBag_0:GetAbilityName() == playerBag_1:GetAbilityName() then
		-- 2.1 升级成为下一级物品
		--item_up(playerBag_0:GetAbilityName(), playerBag_1:GetAbilityName(), caster)
		--item_up(playerBag_0, playerBag_1, caster)
		
		local item_name_pre = string.sub(playerBag_0:GetAbilityName(), 0, 
							  string.len(playerBag_0:GetAbilityName())-1) -- 截取字符串的字节数
   	 	local level = tonumber(string.sub(playerBag_0:GetAbilityName(), -1))
   	 	local level_2 = tonumber(string.sub(playerBag_1:GetAbilityName(), -1))
   	 	-- 
    	if level >= 9 or level_2 >=9 then
			return
    	end

 		-- 2.2.消除当前背包的 1 2 格的相同宝石，在 1 的位置 得到一个更高级的宝石
 		-- caster:TakeItem(playerBag_0)
 		-- caster:TakeItem(playerBag_1)
 		playerBag_0:RemoveSelf()
 		playerBag_1:RemoveSelf()
 		Say(nil, item_name_pre .. level + 1, false)
 		caster:AddItemByName(item_name_pre..level + 1)

 	-- 3.1: 当 0 的位置是力量  1 的位置是敏捷
 	elseif stoneName1 == "item_strength_gemstone_8"  and 
 			stoneName2 == "item_agility_gemstone_8" then
 				local item_str_agi = "item_strength_gemstone_10" -- 力敏宝石
 				caster:TakeItem(playerBag_0)
 				caster:TakeItem(playerBag_1)
 				caster:AddItemByName(item_str_agi)

 	-- 3.2: 当 0 的位置是力量  1 的位置是智力
 	elseif stoneName1 == "item_strength_gemstone_8"  and 
 			stoneName2 == "item_intelligece_gemstone_8" then
 				local item_str_int = "item_strength_gemstone_11" -- 力智宝石
 				caster:TakeItem(playerBag_0)
 				caster:TakeItem(playerBag_1)
 				caster:AddItemByName(item_str_int)

	-- 3.3: 当 0 的位置是敏捷  1 的位置是智力
 	elseif stoneName1 == "item_agility_gemstone_8"  and 
 			stoneName2 == "item_intelligece_gemstone_8" then
 				local item_agi_int = "item_agility_gemstone_10" -- 敏智宝石
 				caster:TakeItem(playerBag_0)
 				caster:TakeItem(playerBag_1)
 				caster:AddItemByName(item_agi_int)

	-- 3.4: 当 0 的位置是敏捷  1 的位置是力量
 	elseif stoneName1 == "item_agility_gemstone_8"  and 
 			stoneName2 == "item_strength_gemstone_8" then
 				local item_agi_str = "item_agility_gemstone_11" -- 敏力宝石
 				caster:TakeItem(playerBag_0)
 				caster:TakeItem(playerBag_1)
 				caster:AddItemByName(item_agi_str)

	-- 3.5: 当 0 的位置是智力  1 的位置是敏捷
 	elseif stoneName1 == "item_intelligece_gemstone_8"  and 
 			stoneName2 == "item_agility_gemstone_8" then
 				local item_int_agi = "item_intelligece_gemstone_10" -- 智敏宝石
 				caster:TakeItem(playerBag_0)
 				caster:TakeItem(playerBag_1)
 				caster:AddItemByName(item_int_agi)

	-- 3.6: 当 0 的位置是智力  1 的位置是力量
 	elseif stoneName1 == "item_intelligece_gemstone_8"  and 
 			stoneName2 == "item_strength_gemstone_8" then
 				local item_int_str = "item_intelligece_gemstone_11" -- 智力宝石
 				caster:TakeItem(playerBag_0)
 				caster:TakeItem(playerBag_1)
 				caster:AddItemByName(item_int_str)
	end
end
-- 神器 亡灵宝典  可镶嵌宝石的   
LinkLuaModifier("modifier_item_ghost_esoterica", "item/item_ghost_esoterica", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ghost_esoterica_extra_intellect", "item/item_ghost_esoterica", LUA_MODIFIER_MOTION_NONE)

--局部变量数值
local gemstone_number = 
{
	["GEMSTONE_INT"] = 0, -- 智力宝石属性
	["GEMSTONE_STR"] = 0, -- 力量宝石属性
	["GEMSTONE_AGI"] = 0, -- 敏捷宝石属性
}

local gemstone_pool = "" -- 保存当前镶嵌的宝石

if item_ghost_esoterica == nil then 
	item_ghost_esoterica = class({})
end

------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- 装备该装备时 检查第二个装备栏是否有宝石，如果有：消失宝石获取宝石的属性并显示到该装备上
-- 施法：检查第二个格子的宝石
----------------------------------------------------------------------------------------------------
function item_ghost_esoterica:OnSpellStart()
	local caster = self:GetCaster() -- 装备拥有者
	local playerBag_0 = caster:GetItemInSlot(0) -- 第一个背包格子的物品
	local playerBag_1 = caster:GetItemInSlot(1) -- 第二个背包格子的物品

	if playerBag_0 == nil or -- 第一个背包格子的物品为空
		 playerBag_1 == nil then --第二个背包格子的物品为空
		return
	end

	local stoneName_0 = playerBag_0:GetAbilityName() -- 第一个背包格子的名字
	local stoneName_1 = playerBag_1:GetAbilityName() -- 第二个背包格子的名字

	-- 检测是否是宝石 如果不是就 不执行
	local item_name_pre = string.sub(playerBag_1:GetAbilityName(), 0, 
							  string.len(playerBag_1:GetAbilityName())-1) -- 截取字符串的字节数
	--print("item_name_pre=", item_name_pre)

	if item_name_pre ~= "item_strength_gemstone_" and item_name_pre ~= "item_agility_gemstone_" 
				and item_name_pre ~= "item_intelligece_gemstone_" then
		--print("0")
		return
	end

	if stoneName_0 == "item_ghost_esoterica" then -- 当第一个装备名称是该装备名称时执行
		--print("1")
		local hCaster = self:GetCaster()
		local strength_modifer = hCaster:FindModifierByName("modifier_item_ghost_esoterica")
		-- 实体才能获取属性值 找到名字是无法获取的
		--print("stoneName_1.strength=", playerBag_1:GetSpecialValueFor("strength"))
		-- local bouns_gemstone_strength = playerBag_1:GetSpecialValueFor("strength")
		if IsServer() then 
			-- strength_modifer.bouns_gemstone_strength = playerBag_1:GetSpecialValueFor("strength")
			-- strength_modifer.bouns_gemstone_agility = playerBag_1:GetSpecialValueFor("agility")
			-- strength_modifer.bouns_gemstone_intellect = playerBag_1:GetSpecialValueFor("intelligece")
			gemstone_number.GEMSTONE_INT = playerBag_1:GetSpecialValueFor("intelligece")
			gemstone_number.GEMSTONE_STR = playerBag_1:GetSpecialValueFor("strength")
			gemstone_number.GEMSTONE_AGI = playerBag_1:GetSpecialValueFor("agility")
			-- -- 一个位置只能镶嵌一颗宝石 和 增加一种属性
			-- caster:SetContextNum("bouns_gemstone_intellect", strength_modifer.bouns_gemstone_intellect, 0)


			-- 传给JS端当前的宝石名称
			Player_Inlaid_Gemstone:GetItemName(playerBag_1:GetAbilityName()) -- 获取宝石名字
			-- 当我镶嵌成功后，该装备记录已经存在宝石了，丢掉装备后宝石的显示跟着消失
			-- gemstone_pool = playerBag_1:GetAbilityName()

			caster:TakeItem(playerBag_1)
		end
	else
		return
	end
end

------------------------------------------------------------------

function item_ghost_esoterica:GetIntrinsicModifierName()
 	return "modifier_item_ghost_esoterica"
end
--------------------------------------------------
if modifier_item_ghost_esoterica == nil then
	modifier_item_ghost_esoterica = class({})
end

function modifier_item_ghost_esoterica:IsHidden() -- 隐藏图标
	return true
end

-- function modifier_item_ghost_esoterica:GetAttributes()
-- 	return MODIFIER_ATTRIBUTE_NONE
-- end

function modifier_item_ghost_esoterica:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,    -- 智力
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,     -- 护甲
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, -- 魔抗
		MODIFIER_PROPERTY_HEALTH_BONUS,             -- 生命值
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,      -- 敏捷
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,     -- 力量
	}
	return funcs
end

function modifier_item_ghost_esoterica:OnCreated(kv)
	local hCaster = self:GetCaster()
	--if IsServer() then 
		self.bouns_intellect = self:GetAbility():GetSpecialValueFor("bouns_intellect") -- 智力奖励
		self.bouns_armor = self:GetAbility():GetSpecialValueFor("bouns_armor") --护甲奖励
		self.bouns_magical = self:GetAbility():GetSpecialValueFor("bouns_magical") -- 魔抗奖励
		self.bouns_health = self:GetAbility():GetSpecialValueFor("bouns_health") -- 生命值奖励
		self.bouns_intellect_multiple = self:GetAbility():GetSpecialValueFor("bouns_intellect_multiple") -- 智力倍数奖励
		-- self.bouns_gemstone_strength = 0 -- 宝石力量奖励
		-- self.bouns_gemstone_agility = 0  -- 宝石的敏捷奖励
		-- self.bouns_gemstone_intellect = 0 -- 宝石的智力奖励
		self.increase_int = 0 -- 记录当前得到的40%智力加成
		self.bese_int = 0 -- 基础装备的40%加成 或 镶嵌智力宝石后的40%属性加成
		self:StartIntervalThink(1)
		self.intellect_gemstone = gemstone_number.GEMSTONE_INT
	-- 额外的40%加成属性生成的与NPC不相关的modifier
	--if IsServer() then 
		-- local inlay_gemstone = self.bouns_intellect + self.bouns_gemstone_intellect
		-- self.bouns_intellect = self.bouns_intellect + inlay_gemstone * self.bouns_intellect_multiple

		--local extra_intellect = CreateModifierThinker(hCaster, self:GetAbility(), "modifier_item_ghost_esoterica_extra_intellect", nil, hCaster:GetAbsOrigin(), hCaster:GetTeamNumber(), false)
	--end
end

function modifier_item_ghost_esoterica:OnIntervalThink() -- 每秒检查装备栏中是否有宝石
	local hCaster = self:GetCaster()
	if IsServer() then 	
		--local strength_modifer = hCaster:FindModifierByName("item_ghost_esoterica")
		local total_bouns_intellect = 0 -- 总的宝石属性
		local inlay_gemstone = 0
		for i = 0, 5 do
			local item_add = hCaster:GetItemInSlot(i)
			if IsValidEntity(item_add) then
				-- 检测是否是宝石 如果不是就 不执行
				local item_name_string = string.sub(item_add:GetAbilityName(), 0, 
										  string.len(item_add:GetAbilityName())-1) -- 截取字符串的字节数
			
				if item_name_string == "item_intelligece_gemstone_" then
					local bouns_intellect_gemstone = item_add:GetSpecialValueFor("intelligece")
					total_bouns_intellect = total_bouns_intellect + bouns_intellect_gemstone
				end
			end
		end
		
		
		-- 如果当前的装备没有镶嵌了智力宝石
		if gemstone_number.GEMSTONE_INT <= 0 then 
			inlay_gemstone = self.bouns_intellect * self.bouns_intellect_multiple
			self.bese_int = inlay_gemstone
		-- 如果当前的装备已经镶嵌了智力宝石
		elseif gemstone_number.GEMSTONE_INT > 0 then
			inlay_gemstone = (self.bouns_intellect + gemstone_number.GEMSTONE_INT) * self.bouns_intellect_multiple
			self.bese_int = inlay_gemstone
		end



		-- -- 如果当前的装备没有镶嵌了智力宝石
		-- if self.bouns_gemstone_intellect <= 0 then 
		-- 	inlay_gemstone = self.bouns_intellect * self.bouns_intellect_multiple
		-- 	self.bese_int = inlay_gemstone
		-- -- 如果当前的装备已经镶嵌了智力宝石
		-- elseif self.bouns_gemstone_intellect > 0 then
		-- 	inlay_gemstone = (self.bouns_intellect + self.bouns_gemstone_intellect) * self.bouns_intellect_multiple
		-- 	self.bese_int = inlay_gemstone
		-- end

		self.increase_int = total_bouns_intellect * self.bouns_intellect_multiple
	end
end

function modifier_item_ghost_esoterica:GetModifierBonusStats_Intellect( kv ) -- 官方方法 返回获取智力 + 宝石的智力 到面板
	-- print("intellect_gemstone=", gemstone_number.GEMSTONE_INT)
	-- print("bese_int=", self.bese_int)
	-- print("increase_int=", self.increase_int)
	if gemstone_number.GEMSTONE_INT <= 0 then 
		-- 当没有镶嵌宝石的属性加成
		return self.bouns_intellect + self.bese_int + self.increase_int 
	elseif gemstone_number.GEMSTONE_INT > 0 then
		-- 当镶嵌了宝石后的属性加成
		return self.bouns_intellect + gemstone_number.GEMSTONE_INT + self.bese_int + self.increase_int 
	end
end

function modifier_item_ghost_esoterica:GetModifierPhysicalArmorBonus( kv ) -- 官方方法 返回获取护甲 到面板
	return self.bouns_armor
end

function modifier_item_ghost_esoterica:GetModifierMagicalResistanceBonus( kv ) -- 官方方法 返回获取魔抗 到面板
	return self.bouns_magical
end

function modifier_item_ghost_esoterica:GetModifierHealthBonus( kv ) -- 官方方法 返回获取生命值 到面板
	return self.bouns_health
end

function modifier_item_ghost_esoterica:GetModifierBonusStats_Strength( kv ) -- 官方方法 返回获取宝石的力量 到面板
	return gemstone_number.GEMSTONE_STR
end

function modifier_item_ghost_esoterica:GetModifierBonusStats_Agility( kv ) -- 官方方法 返回获取宝石的敏捷 到面板
	return gemstone_number.GEMSTONE_AGI
end

------------------------------------------------未使用额外的modifier--------------------------------------------------




-------------------------------------额外的40%智力加成----------------------------------------------------
if modifier_item_ghost_esoterica_extra_intellect == nil then
	modifier_item_ghost_esoterica_extra_intellect = class({})
end

function modifier_item_ghost_esoterica_extra_intellect:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_ghost_esoterica_extra_intellect:OnCreated(kv)
	self.bouns_intellect_multiple = self:GetAbility():GetSpecialValueFor("bouns_intellect_multiple") -- 智力倍数奖励
	self.increase_int = 0
	self:StartIntervalThink(1)
end

function modifier_item_ghost_esoterica_extra_intellect:OnIntervalThink() -- 每秒检查装备栏中是否有宝石
	local hCaster = self:GetCaster()
	if IsServer() then 	

		local total_bouns_intellect = 0
		for i = 0, 5 do
			local item_add = hCaster:GetItemInSlot(i)

			if IsValidEntity(item_add) then
				-- 检测是否是宝石 如果不是就 不执行
				local item_name_string = string.sub(item_add:GetAbilityName(), 0, 
										  string.len(item_add:GetAbilityName())-1) -- 截取字符串的字节数
				print("item_name_pre=", item_name_string)
			
				if item_name_string == "item_intelligece_gemstone_" then
					local bouns_gemstone_intellect = item_add:GetSpecialValueFor("intelligece")
					print("bouns_gemstone_intellect=", bouns_gemstone_intellect)
					--local intellect_int = item_nuber:GetModifierBonusStats_Intellect()
					total_bouns_intellect = total_bouns_intellect + bouns_gemstone_intellect
				-- else
				-- 	local intellect_int = item_add:GetModifierBonusStats_Intellect()
				-- 	total_bouns_intellect = total_bouns_intellect + intellect_int
				end
			end
		end
		self.increase_int = total_bouns_intellect * self.bouns_intellect_multiple
	end
end

function modifier_item_ghost_esoterica_extra_intellect:GetModifierBonusStats_Intellect( kv ) -- 官方方法 返回获取智力 + 宝石的智力 到面板
	print("increase_int=", self.increase_int)
	return self.increase_int
end

-- local hCaster = self:GetCaster()
-- 	local item_nuber = 0 -- 装备数量
-- 	if IsServer() then 	

-- 		 self.increase_int = self:GetParent():GetIntellect() * self.bouns_intellect_multiple

		-- for i=0,6 do
		-- 	local item_add = hCaster:GetItemInSlot(i)
		-- 	if IsValidEntity(item_add) then
		-- 		item_nuber = item_nuber + 1
		-- 	end

		-- 	if item_add ~= nil then 
		-- 		print("1")
				
		-- 		if self.item_refresh_nuber == item_nuber then
		-- 			print("is item_refresh = true")
		-- 			self.item_refresh = true
		-- 		end

		-- 		local item_name_pre = string.sub(item_add:GetAbilityName(), 0, 
		-- 					  string.len(item_add:GetAbilityName())-1) -- 截取字符串的字节数
		-- 		print("item_nuber=", item_nuber)
		-- 		print("item_refresh=", self.item_refresh)
		-- 		print("item_refresh_nuber=", self.item_refresh_nuber)
		-- 		if  item_name_pre == "item_intelligece_gemstone_" and self.item_refresh == true then
			
		-- 			print("args")
		-- 			print("item_refresh_nuber=",self.item_refresh_nuber)
		-- 			self.item_refresh = false
		-- 			self.intellect_int = 0
		-- 			self.base_int = self:GetCaster():GetIntellect()
		-- 			self.intellect_int = self.base_int * self.bouns_intellect_multiple
		-- 			self.item_refresh_nuber = item_nuber + 1
		-- 		end

		-- 		-- if not item_add:GetAbilityName() == "item_intelligece_gemstone_" then 
		-- 		-- 	print("not item_add")
		-- 		-- 	self.intellect_int = 0
		-- 		-- end
		-- 	end
		--end
	--end
-- 神器 狂徒宝典  可镶嵌宝石的   
LinkLuaModifier("modifier_item_zealot_esoterica", "item/item_zealot_esoterica", LUA_MODIFIER_MOTION_NONE)

if item_zealot_esoterica == nil then 
	item_zealot_esoterica = class({})
end

--local intellect_gemstone = 0

function item_zealot_esoterica:OnCreated( ... )
	self.strength_gemstone = 0 	  -- 存储力量属性
	self.agility_gemstone = 0 	  -- 存储敏捷属性
	self.intelligece_gemstone = 0 -- 存储智力属性
end

------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- 装备该装备时 检查第二个装备栏是否有宝石，如果有：消失宝石获取宝石的属性并显示到该装备上
-- 施法：检查第二个格子的宝石
----------------------------------------------------------------------------------------------------
function item_zealot_esoterica:OnSpellStart()
	local hCaster = self:GetCaster() -- 装备拥有者
	local playerBag_0 = hCaster:GetItemInSlot(0) -- 第一个背包格子的物品
	local playerBag_1 = hCaster:GetItemInSlot(1) -- 第二个背包格子的物品

	if playerBag_0 == nil or -- 第一个背包格子的物品为空
		 playerBag_1 == nil then --第二个背包格子的物品为空
		return
	end

	local stoneName_0 = playerBag_0:GetAbilityName() -- 第一个背包格子的名字
	local stoneName_1 = playerBag_1:GetAbilityName() -- 第二个背包格子的名字

	-- 检测是否是宝石 如果不是就 不执行
	local item_name_pre = string.sub(stoneName_1, 0, 
							  string.len(stoneName_1)-1) -- 截取字符串的字节数

	if item_name_pre ~= "item_strength_gemstone_" and item_name_pre ~= "item_agility_gemstone_" 
				and item_name_pre ~= "item_intelligece_gemstone_" then
		return
	end

	if stoneName_0 == "item_zealot_esoterica" then -- 当第一个装备名称是该装备名称时执行
		--local hCaster = self:GetCaster()
		-- local strength_modifer = hCaster:FindModifierByName("modifier_item_zealot_esoterica")

		-- strength_modifer.bonus_gemstone_strength = playerBag_1:GetSpecialValueFor("strength")
		-- strength_modifer.bonus_gemstone_agility = playerBag_1:GetSpecialValueFor("agility")
		-- strength_modifer.bonus_gemstone_intellect = playerBag_1:GetSpecialValueFor("intelligece")

		self.strength_gemstone = playerBag_1:GetSpecialValueFor("strength")
		self.agility_gemstone = playerBag_1:GetSpecialValueFor("agility")
		self.intelligece_gemstone = playerBag_1:GetSpecialValueFor("intelligece")

		-- print("strength_gemstone=", self.strength_gemstone)
		-- print("agility_gemstone=", self.agility_gemstone)
		-- print("intelligece_gemstone=", self.intelligece_gemstone)

		hCaster:TakeItem(playerBag_1)
	else
		return
	end
end

-- function item_zealot_esoterica:OnCreated( ... )
-- 	self.strength_gemstone = 0
-- end

------------------------------------------------------------------

function item_zealot_esoterica:GetIntrinsicModifierName()
 	return "modifier_item_zealot_esoterica"
end
--------------------------------------------------
if modifier_item_zealot_esoterica == nil then
	modifier_item_zealot_esoterica = class({})
end

function modifier_item_zealot_esoterica:IsHidden() -- 隐藏图标
	return true
end

-- function modifier_item_ghost_esoterica:Passive() -- 默认拥有
-- 	return true
-- end

function modifier_item_zealot_esoterica:DeclareFunctions()
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

function modifier_item_zealot_esoterica:OnCreated(kv)
	self.bonus_strength = self:GetAbility():GetSpecialValueFor("bonus_strength") -- 力量奖励
	self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor") --护甲奖励
	self.bonus_magical = self:GetAbility():GetSpecialValueFor("bonus_magical") -- 魔抗奖励
	self.bonus_health = self:GetAbility():GetSpecialValueFor("bonus_health") -- 生命值奖励
	self.bonus_strength_multiple = self:GetAbility():GetSpecialValueFor("bonus_strength_multiple") -- 力量倍数奖励
	-- self.bonus_gemstone_strength = 0 -- 宝石力量奖励
	-- self.bonus_gemstone_agility = 0  -- 宝石的敏捷奖励
	-- self.bonus_gemstone_intellect = 0 -- 宝石的智力奖励
	self.increase_str = 0 -- 记录当前得到的40%力量加成
	self.bese_str = 0 -- 基础装备的40%加成 或 镶嵌力量宝石后的40%属性加成
	self:StartIntervalThink(1)
	--self.x = self:GetAbility().strength_gemstone
end


function modifier_item_zealot_esoterica:OnIntervalThink() -- 每秒检查装备栏中是否有宝石
	local hCaster = self:GetCaster()
	if IsServer() then 	

		local total_bonus_strength = 0 -- 总的宝石属性
		local inlay_gemstone = 0
		for i = 0, 5 do
			local item_add = hCaster:GetItemInSlot(i)
			if IsValidEntity(item_add) then
				-- 检测是否是宝石 如果不是就 不执行
				local item_name_string = string.sub(item_add:GetAbilityName(), 0, 
										  string.len(item_add:GetAbilityName())-1) -- 截取字符串的字节数
			
				if item_name_string == "item_strength_gemstone_" then
					-- 得到物品栏中力量宝石的力量属性
					local bonus_strength_gemstone = item_add:GetSpecialValueFor("strength") 
					total_bonus_strength = total_bonus_strength + bonus_strength_gemstone
				end
			end
		end

		-- 如果当前的装备没有镶嵌了力量宝石
		if self:GetAbility().strength_gemstone == nil or self:GetAbility().strength_gemstone <= 0 then 
			inlay_gemstone = self.bonus_strength * self.bonus_strength_multiple
			self.bese_str = inlay_gemstone
		-- 如果当前的装备已经镶嵌了力量宝石
		elseif self:GetAbility().strength_gemstone ~= nil and self:GetAbility().strength_gemstone > 0 then
			inlay_gemstone = (self.bonus_strength + self:GetAbility().strength_gemstone ) * self.bonus_strength_multiple
			self.bese_str = inlay_gemstone
		end

		-- -- 如果当前的装备没有镶嵌了力量宝石
		-- if self.bonus_gemstone_strength <= 0 then 
		-- 	inlay_gemstone = self.bonus_strength * self.bonus_strength_multiple
		-- 	self.bese_str = inlay_gemstone
		-- -- 如果当前的装备已经镶嵌了力量宝石
		-- elseif self.bonus_gemstone_strength > 0 then
		-- 	inlay_gemstone = (self.bonus_strength + self.bonus_gemstone_strength) * self.bonus_strength_multiple
		-- 	self.bese_str = inlay_gemstone
		-- end

		self.increase_str = total_bonus_strength * self.bonus_strength_multiple
	end
end

function modifier_item_zealot_esoterica:GetModifierBonusStats_Intellect( kv ) -- 官方方法 返回获取智力 + 宝石的智力 到面板
	return self:GetAbility().intelligece_gemstone
end

function modifier_item_zealot_esoterica:GetModifierPhysicalArmorBonus( kv ) -- 官方方法 返回获取护甲 到面板
	return self.bonus_armor
end

function modifier_item_zealot_esoterica:GetModifierMagicalResistanceBonus( kv ) -- 官方方法 返回获取魔抗 到面板
	return self.bonus_magical
end

function modifier_item_zealot_esoterica:GetModifierHealthBonus( kv ) -- 官方方法 返回获取生命值 到面板
	return self.bonus_health
end

function modifier_item_zealot_esoterica:GetModifierBonusStats_Strength( kv ) -- 官方方法 返回获取宝石的力量 到面板
	--print("strength_gemstone", self:GetAbility().strength_gemstone)
	-- if self.bonus_gemstone_strength <= 0 then 
	-- 	-- 当没有镶嵌宝石的属性加成
	-- 	return self.bonus_strength + self.bese_str + self.increase_str
	-- elseif self.bonus_gemstone_strength > 0 then
	-- 	-- 当镶嵌了宝石后的属性加成
	-- 	return self.bonus_strength + self.bonus_gemstone_strength + self.bese_str + self.increase_str 
	-- end


	if self:GetAbility().strength_gemstone == nil or self:GetAbility().strength_gemstone <= 0 then 
		-- 当没有镶嵌宝石的属性加成
		return self.bonus_strength + self.bese_str + self.increase_str
	elseif self:GetAbility().strength_gemstone ~= nil and self:GetAbility().strength_gemstone > 0 then
		-- 当镶嵌了宝石后的属性加成
		return self.bonus_strength + self:GetAbility().strength_gemstone + self.bese_str + self.increase_str 
	end

end

function modifier_item_zealot_esoterica:GetModifierBonusStats_Agility( kv ) -- 官方方法 返回获取宝石的敏捷 到面板
	--print("agility_gemstone=", self:GetAbility().agility_gemstone)
	return self:GetAbility().agility_gemstone
end
-- 装备词条 --
-- 属性都为百分比加成
--[[

总力量 1%-7%
总敏捷 1%-7%
总智力 1%-7%
总生命 1%-7%
总魔法上限 1%-10%
攻速 1%-40%
防御力 1-15
攻击力 1%-7%
全属性 1%-5%
]]

if SeriseSystem == nil then SeriseSystem = {} end
AFFIX_FOR_EQUIPMENT = {
	["s1"] = {
		str = {1,7},
		agi = {1,7},
		int = {1,7},
		all = {1,5},
		mana = {2,10}, -- 最大每秒回蓝
		health = {1,15}, -- 最大生命恢复 0.1 - 1.5 1 - 15
		as = {10,25},
		armor = {1,15},
		damage = {1,7},
		-- magic = {1,7}
	},
	["s2"] = {
		str = {3,8},
		agi = {3,8},
		int = {3,8},
		all = {2,6},
		as = {10,25},
		armor = {2,15},
		damage = {2,8}, -- 攻击力
		magic = {2,8},
		physical = {2,8},
	},
	
}
--[[
【闪烁】*2 每释放4次闪烁，会在5秒内增加自己30%攻击速度 *3 80%
【炼金】*2 强化资本家，投资收益从25%提升为35% *3 50%
【伐木】*2 强化伐木工，奖励上限提升至250 *3 每秒木材从1提升至2
【医生】*2 冷却降低为60秒 *3 2%
【拾荒】 *2强化拾荒，额外收益从12.5%提升为15% *3 20%
【杀手】*2强化杀手，上限从等级*15提高为等级*20 *3 30
【工匠大师】*2强化工匠大师，合成时有5%几率额外制造一颗宝石 *3 15%几率
]]
AFFIX_FOR_DEPUTY  = {
	s1 = {
		--- s1词条
		"blink", -- 【闪烁】
		"investment", -- 【炼金】
		"technology", --【伐木】
		"doctor",
		"killer",
		"scavenging",
		"forging",
		-- "boxer",
		"idler",
	},
	s2 = {
		"s2_boxer", -- s2拳师
		"s2_killer", --s2杀手
	}
	
}

--[[
【光能】 *2 神圣，火焰触发概率提高5% *3 每隔15秒触发一次，技能触发概率提高为100%，持续2秒
【寒冷】 *2 冰霜，黑暗触发概率提高5%*3  敌人身上每个负面状态会提高你对其造成的15%伤害
【火焰】 *2 炼金，自然触发概率提高5% *3  暴击时提高自己5%暴击伤害，每5秒重置一次
【活力】 *2  魔力，大地触发概率提高5% *3  每隔10秒触发一次，回复自己20%生命值&100%魔法值
【毁灭】 *2 穿透，狂暴的攻速提高35% *3 提高25%的攻击力
]]
AFFIX_FOR_TALENT = {
	s1 = {
		"light", -- 【光能】
		"clod", -- 【寒冷】
		"flame", --【火焰】
		"vitality", -- 【活力】 
		"ruin",  --【毁灭】
	},
	s2 = {
		"s2_light", -- 【光S2】
		"s2_clod", -- 【寒冷】
		"s2_flame", --【火焰】
		"s2_vitality",
		"s2_ruin",
	}
	
}

hGemAttrTable = {
	["item_strength_gemstone_0"] = {str = 2},
	["item_strength_gemstone_1"] = {str = 4},
	["item_strength_gemstone_2"] = {str = 8},
	["item_strength_gemstone_3"] = {str = 16},
	["item_strength_gemstone_4"] = {str = 32},
	["item_strength_gemstone_5"] = {str = 64},
	["item_strength_gemstone_6"] = {str = 128},
	["item_strength_gemstone_7"] = {str = 256},
	["item_strength_gemstone_8"] = {str = 512},
	["item_strength_gemstone_9"] = {str = 912},
	["item_strength_gemstone_10"] = {str = 512 , agi = 400},
	["item_strength_gemstone_11"] = {str = 512 , int = 400},

	["item_agility_gemstone_0"] = {agi = 2},
	["item_agility_gemstone_1"] = {agi = 4},
	["item_agility_gemstone_2"] = {agi = 8},
	["item_agility_gemstone_3"] = {agi = 16},
	["item_agility_gemstone_4"] = {agi = 32},
	["item_agility_gemstone_5"] = {agi = 64},
	["item_agility_gemstone_6"] = {agi = 128},
	["item_agility_gemstone_7"] = {agi = 256},
	["item_agility_gemstone_8"] = {agi = 512},
	["item_agility_gemstone_9"] = {agi = 912},
	["item_agility_gemstone_10"] = {agi = 512 , int = 400},
	["item_agility_gemstone_11"] = {agi = 512 , str = 400},


	["item_intelligece_gemstone_0"] = {int = 2},
	["item_intelligece_gemstone_1"] = {int = 4},
	["item_intelligece_gemstone_2"] = {int = 8},
	["item_intelligece_gemstone_3"] = {int = 16},
	["item_intelligece_gemstone_4"] = {int = 32},
	["item_intelligece_gemstone_5"] = {int = 64},
	["item_intelligece_gemstone_6"] = {int = 128},
	["item_intelligece_gemstone_7"] = {int = 256},
	["item_intelligece_gemstone_8"] = {int = 512},
	["item_intelligece_gemstone_9"] = {int = 912},
	["item_intelligece_gemstone_10"] = {int = 512 , agi = 400},
	["item_intelligece_gemstone_11"] = {int = 512 , str = 400},

}

-- 设置装备的赛季词缀和属性。
function SeriseSystem:SetItemAttr(hItem,nAffix,nSeason,nTier)
	if nSeason == nil then nSeason = 1 end
	if nTier == nil then nTier = 1 end
	local hTalentAffixList = AFFIX_FOR_TALENT["s"..nSeason]
	local hDeputyAffixList = AFFIX_FOR_DEPUTY["s"..nSeason]
	local hAttrAffixList = AFFIX_FOR_EQUIPMENT["s"..nSeason]
	-- local sItemName = hItem:GetAbilityName()
	local hSlotList = self:GetRandomRatioValue(0,nTier) - 1
	hItem.bonus = {}
	-- 系列装备
	hItem.bonus.season = nSeason
	hItem.bonus.tier = nTier
	-- 宝石孔
	hItem.bonus.gemslot = hSlotList
	hItem.bonus.gemslot_info = {}
	-- 随机词条
	hItem.bonus.attr = {}
	hItem.bonus.talent = hTalentAffixList[RandomInt(1, #hTalentAffixList)]
	hItem.bonus.deputy = hDeputyAffixList[RandomInt(1, #hDeputyAffixList)]
	-- hItem.bonus.talent = "ruin"
	-- hItem.bonus.deputy = "forging"
	-- 获取随机N个属性词条 
	local hAttrBonus = {}
	local nCurrentCount = self:GetAffixCount( hAttrAffixList )
	local hAffixList = {}
	for k,v in pairs(hAttrAffixList) do	table.insert(hAffixList, k) end
	local hRandomAffixOrder = {}
	RandFetch(hRandomAffixOrder,nAffix,nCurrentCount)
	for _,nOrder in pairs(hRandomAffixOrder) do
		local sAttr = hAffixList[nOrder]
		local nMin = hAttrAffixList[sAttr][1]
		local nMax = hAttrAffixList[sAttr][2]
		--print(sAttr,nMin,nMax)
		local nValue = self:GetRandomRatioValue(nMin,nMax) + nMin - 1
		hAttrBonus[sAttr] = nValue + nTier - 1
	end
	hItem.bonus.attr = hAttrBonus
	
end
function SeriseSystem:CreateEquipmentInUnit(hArchiveEqui,hHero)
	local hEquipmentTable = hArchiveEqui["equipment"]
	if hEquipmentTable ~= nil then 
		-- DeepPrintTable(hEquipmentTable)
		local hInventory = hEquipmentTable["inventory"]
		local hBackpack = hEquipmentTable["backpack"]
		local hPlayer = hHero:GetOwner()
		-- 物品栏
		for k,v in pairs(hInventory) do
			local sItemName = v.itemName
			local hNewItem = CreateItem( sItemName, hPlayer, hPlayer )
			v.gemslot_info = {}
			hNewItem.bonus = v
			hNewItem:SetPurchaser(hHero)
			hHero:AddItem(hNewItem)
		end
		-- 背包栏
		for k,v in pairs(hBackpack) do
			local sItemName = v.itemName
			local hNewItem = CreateItem( sItemName, hPlayer, hPlayer )
			v.gemslot_info = {}
			hNewItem.bonus = v
			hNewItem:SetPurchaser(hHero)
			InventoryBackpack:AddItem( hHero, hNewItem )
		end
	end
end

function SeriseSystem:CreateRandomRatio(nMin,nMax)
	local nTotal = 0
	local nMaxNum = nMax - nMin + 1
	local hLevelData = {}
	local hLevelRaito = {}
	for i=1, nMaxNum do
		local nBonus = 0+i*i/2
		hLevelData[nMaxNum-i+1] = nBonus
		nTotal = nTotal + nBonus
	end
	local fEver = 100/nTotal
	for k,v in pairs(hLevelData) do
		hLevelRaito[k] = v*fEver - (v*fEver) % 0.01
	end
	return hLevelRaito
end

function SeriseSystem:GetRandomRatioValue(nMin,nMax)
	local hRatio = self:CreateRandomRatio(nMin,nMax)
	local fRandom = RandomFloat(0,100)
	local nListLength = #hRatio
	local nBase = 0
	for k,v in pairs(hRatio) do
		nBase = nBase + v
		if fRandom < nBase then
			return k
		end
	end
	return #hRatio
end


function SeriseSystem:GetAffixCount( hAttrAffixList )
	local nCount = 0
	for _,v in pairs(hAttrAffixList) do
		nCount = nCount + 1
	end
	return nCount
end

-- 创建一个词条装备
function SeriseSystem:CreateSeriesItem(hHero,nAffix,nSeason,nTier)
	local hPosition = {"chest","foot","hand"}
	local nRand = RandomInt(1, #hPosition)
	local sSet = hPosition[nRand]
	local sItemName = "item_series_s"..nSeason.."_t"..nTier.."_"..sSet
	local hItemHand = CreateItem( sItemName, nil, nil )
	hItemHand:SetPurchaser(hHero)
	SeriseSystem:SetItemAttr(hItemHand,nAffix,nSeason,nTier)
	hHero:AddItem(hItemHand)
	return hItemHand
end
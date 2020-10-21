if Treasure_selected == nil then
	Treasure_selected = class({})
end

--宝物池子
local Treasure_list = {
    "gem_pinbenshishadewo",
    "gem_yezhendebuyaole",
    "gem_chainmail",
    "gem_platemail",
    "gem_huiguang_fu",
    "gem_shuangren_fu",
    "gem_budao_fu",
    "gem_zuizhongzhijian_lua",
    "gem_xunjizhijian_lua",
    "gem_shixue_lua",
    "gem_god_left_hand",
    "gem_god_right_hand",
    "gem_bow_of_aeolus",
    "gem_arrow_of_aeolus",
    "gem_blacksmith_left_wristbands",
    "gem_blacksmith_right_wristbands",
    "gem_bubaizhidun",
    "gem_yuanshemoshi",
    "gem_liliangcuncu_huang",
    "gem_liliangcuncu_zi",
    "gem_xiaozhiliao",
    "gem_zhongzhiliao",
    "gem_dazhiliao",
    "gem_busishengbei",
    "gem_yinxuejian",
    "gem_yongmengmoshi",
    "gem_tanlanmianju",
    "gem_emoqiyue",
    "gem_budengzhiduihuan",
    "gem_yongmengzhiren_xiao",
    "gem_yongmengzhiren_zhong",
    "gem_yongmengzhiren_da",
    "gem_canbaizhiren",
    "gem_shihunshengbei",
    "gem_shufuzhiren",
    "gem_duohunfazhang",
    "gem_devil_head",
    "gem_devil_left_hand",
    "gem_devil_right_hand",
    "gem_devil_left_foot",
    "gem_devil_right_foot",
    "gem_gangtieheji",

    "gem_void_lock",
    "gem_die_venom",
    "gem_Ice_storm",
    "gem_raging_fire_interrogate",
    "gem_earth_burst",
    "gem_shadow_quiet",

    "mucai_xiaojiejin",
    "mucai_dajiejin",
    "gold_jinkuai",
    "gold_jinbidai",

    "huihedashang",
    "tanyuzhihu",
    "zuanshi_touzi",

    "gold_jinbiboyi", 
    -- "mucai_mucaiboyi",
-- "baiyin_touzi",
-- "huangjin_touzi",

-- "huihexiaoshang",
-- "huihezhongshang",
}

function Treasure_selected:Init()
    CustomGameEventManager:RegisterListener("treasure_selected", self.OnAddTreasure)

    --初始化玩家宝物池子
    for i = 0 , MAX_PLAYER - 1 do
        local steam_id = PlayerResource:GetSteamAccountID(i)
        if steam_id ~= 0 then
            GlobalVarFunc.player_treasure_list[i] = {}
            for key, value in ipairs(Treasure_list) do
                GlobalVarFunc.player_treasure_list[i][key] = value
            end
        end
    end
end

function Treasure_selected:OnAddTreasure(args)
    -- DeepPrintTable(args)
    local treasureName = args.treasure_name
    local nPlayerID = args.PlayerID
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID), "closed_treasure_select", {})
    Timer(1,function()
        --防止连点器作弊
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"baowu_prevent_cheat",{})
    end)
    
    if type(treasureName) == "table" then
		return
    end
    
    if hHero:IsNull() then
        return
    end
    -- 技能
    -- 判断当前等级
    local hAbility = hHero:FindAbilityByName("upgrade_ability_core")
    if hAbility == nil then
        hAbility = hHero:AddAbility("upgrade_ability_core")
        hAbility:SetLevel(1)
    end
    
    --移除已选择的宝物
    for i = 1, #GlobalVarFunc.player_treasure_list[nPlayerID] do
        if treasureName == GlobalVarFunc.player_treasure_list[nPlayerID][i] then
            table.remove(GlobalVarFunc.player_treasure_list[nPlayerID], i)
        end    
    end
    
    if string.find(treasureName, "item") then
        hHero:AddItemByName(treasureName)
    elseif string.find(treasureName, "gem") then
        -- local Ability = hHero:AddAbility(treasureName)
        -- Ability:SetLevel(1)
        
        --添加宝物的modifier
        hHero:AddNewModifier( hHero, hAbility, "modifier_"..treasureName, {} )
    else
        -- 宝物既不是技能也不是物品的时候
        if treasureName == "mucai_xiaojiejin" then
            Player_Data:AddPoint(nPlayerID,1500)
        end
        if treasureName == "mucai_dajiejin" then
            Player_Data:AddPoint(nPlayerID,2000)
        end
        if treasureName == "gold_jinkuai" then
            local gold = 10000
            PlayerResource:ModifyGold(nPlayerID,gold,true,DOTA_ModifyGold_Unspecified)
            PopupGoldGain(hHero, gold)
        end
        if treasureName == "gold_jinbidai" then
            local gold = 15000
            PlayerResource:ModifyGold(nPlayerID,gold,true,DOTA_ModifyGold_Unspecified)
            PopupGoldGain(hHero, gold)
        end
        if treasureName == "gold_jinbiboyi" then
            local random = RandomInt(1,100)
            local gold = PlayerResource:GetGold(nPlayerID)
            gold = math.floor(gold * 0.5)
            if random <= 51 then
                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="金币博弈成功"})
                PlayerResource:ModifyGold(nPlayerID,gold,true,DOTA_ModifyGold_Unspecified)
                PopupGoldGain(hHero, gold)
            else
                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="金币博弈失败"})
                PlayerResource:SpendGold(nPlayerID,gold,DOTA_ModifyGold_AbilityCost)
            end
        end
        if treasureName == "mucai_mucaiboyi" then
            local random = RandomInt(1,100)
            local wood = Player_Data:getPoints(nPlayerID)
            wood = math.floor(wood * 0.5)
            if random <= 51 then
                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="木材博弈成功"})
                Player_Data:AddPoint(nPlayerID,wood)
            else
                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="木材博弈失败"})
                Player_Data:AddPoint(nPlayerID, -wood)
            end
        end
        if treasureName == "huihexiaoshang" then
            Treasure_selected:OnInvestmentRewardCoefficient(nPlayerID,"huihexiaoshang")
        end
        if treasureName == "huihezhongshang" then
            Treasure_selected:OnInvestmentRewardCoefficient(nPlayerID,"huihezhongshang")
        end
        if treasureName == "huihedashang" then
            Treasure_selected:OnInvestmentRewardCoefficient(nPlayerID,"huihedashang")
        end
        if treasureName == "baiyin_touzi" then
            Treasure_selected:OnInvestmentRewardCoefficient(nPlayerID,"baiyin_touzi")
        end
        if treasureName == "huangjin_touzi" then
            Treasure_selected:OnInvestmentRewardCoefficient(nPlayerID,"huangjin_touzi")
        end
        if treasureName == "zuanshi_touzi" then
            Treasure_selected:OnInvestmentRewardCoefficient(nPlayerID,"zuanshi_touzi")
        end
        if treasureName == "tanyuzhihu" then
            hHero:AddItemByName("item_baowu_book_dark_wings")
            hHero:AddItemByName("item_baowu_book_dark_wings")
        end
        if treasureName == "yebuyaole" then
           local bHasZhendebuyaole = hHero:HasModifier("modifier_gem_yezhendebuyaole")
           if bHasZhendebuyaole == true then
                Player_Data():AddPoint(nPlayerID,500)
                PlayerResource:ModifyGold(nPlayerID, 20000, true, DOTA_ModifyGold_Unspecified)
                hHero:AddNewModifier(hHero, hAbility, "modifier_gem_yezhendebuyaole", {})
           end
        end
    end
end

--宝物回合收入和投资网表
function Treasure_selected:OnInvestmentRewardCoefficient(nPlayerID,treasureName)
    local player_successChallenge = CustomNetTables:GetTableValue( "gameInfo", "challenge" )

    for k,v in pairs(player_successChallenge) do
        if tonumber(k) == nPlayerID then
        
            if treasureName =="baiyin_touzi" then
                v.InvestmentRewardCoefficient = v.InvestmentRewardCoefficient + 0.05
                GlobalVarFunc.InvestmentRewardCoefficient[nPlayerID+1] = GlobalVarFunc.InvestmentRewardCoefficient[nPlayerID+1] + 0.05
            elseif treasureName =="huangjin_touzi" then
                v.InvestmentRewardCoefficient = v.InvestmentRewardCoefficient + 0.10
                GlobalVarFunc.InvestmentRewardCoefficient[nPlayerID+1] = GlobalVarFunc.InvestmentRewardCoefficient[nPlayerID+1] + 0.10
            elseif treasureName =="zuanshi_touzi" then
                v.InvestmentRewardCoefficient = v.InvestmentRewardCoefficient + 0.15
                GlobalVarFunc.InvestmentRewardCoefficient[nPlayerID+1] = GlobalVarFunc.InvestmentRewardCoefficient[nPlayerID+1] + 0.15
            elseif treasureName =="huihexiaoshang" then
                v.OperateRewardCoefficient = v.OperateRewardCoefficient + 0.05
                GlobalVarFunc.OperateRewardCoefficient[nPlayerID+1] = GlobalVarFunc.OperateRewardCoefficient[nPlayerID+1] + 0.05
            elseif treasureName =="huihezhongshang" then
                v.OperateRewardCoefficient = v.OperateRewardCoefficient + 0.10
                GlobalVarFunc.OperateRewardCoefficient[nPlayerID+1] = GlobalVarFunc.OperateRewardCoefficient[nPlayerID+1] + 0.10
            elseif treasureName =="huihedashang" then
                v.OperateRewardCoefficient = v.OperateRewardCoefficient + 0.15
                GlobalVarFunc.OperateRewardCoefficient[nPlayerID+1] = GlobalVarFunc.OperateRewardCoefficient[nPlayerID+1] + 0.15
            end
                
            CustomNetTables:SetTableValue( "gameInfo", "challenge", player_successChallenge)

        end
    end
end
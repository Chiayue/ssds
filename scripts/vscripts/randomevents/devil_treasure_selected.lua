if Devil_Treasure_selected == nil then
	Devil_Treasure_selected = class({})
end

local devil_treasure_list = {
	"gem_ripple_devil", -- 大法师
    "gem_as_divine_wrath", -- 匠神
    "gem_ares_meaning", -- 战神
    "gem_look_my_health", -- 生命
    "gem_look_my_armor",    -- 护甲
    "gem_special_suit_buff",    -- buff
    "gem_the_power_of_the_undead", -- 亡灵
    "gem_strength_explode",     -- 力爆
    "gem_agility_explode",      -- 敏爆
    "gem_intelligence_explode", -- 智爆
    "gem_demonic_contract_true",   -- 恶契
    "gem_wind_howling",    -- 风神
    "gem_greed_mask_true",      -- 贪婪
    "gem_super_storage_yellow", -- 超级黄
    "gem_super_storage_purple", -- 超级紫
    "gem_devil_greed",  -- 团队
    "gem_demon_summoned",   -- 恶召唤
    "gem_investment_in_secret", -- 投资
    "gem_eats_the_soul_god_cup", --神杯
    "gem_falling_of_sword",     -- 圣剑
    "gem_devil_add_strength",   --力增
    "gem_devil_add_agility",    -- 敏增
    "gem_devil_add_intelligence",   -- 智增
    "gem_devil_chosen_people",  -- 天选
    "gem_devil_drinking_blood_jian_of_soul",    -- 饮血剑之魂
    "gem_devil_start_all_over_again",   -- 从头再来
    "gem_devil_demon_game",     -- 恶魔博弈
}

function Devil_Treasure_selected:Init()
    CustomGameEventManager:RegisterListener("devil_treasure_selected", self.OnAddDevilTreasure)
    CustomGameEventManager:RegisterListener("duihuan_emobaowushu", self.OnDuiHanEMoBaoWuShu)
    CustomGameEventManager:RegisterListener("duihuan_emotiaozhanquan", self.OnDuiHanEMoTianZhanQuan)
    ListenToGameEvent("entity_killed", Dynamic_Wrap(Devil_Treasure_selected, "OnKillDvil"), self)

    --初始化玩家宝物池子
    for i = 0 , MAX_PLAYER - 1 do
        local steam_id = PlayerResource:GetSteamAccountID(i)
        if steam_id ~= 0 then
            GlobalVarFunc.player_devil_treasure_list[i] = {}
            for key, value in ipairs(devil_treasure_list) do
                GlobalVarFunc.player_devil_treasure_list[i][key] = value
            end
        end
    end
end

function Devil_Treasure_selected:OnAddDevilTreasure(args)
    -- DeepPrintTable(args)
    local treasureName = args.treasure_name
    local nPlayerID = args.PlayerID
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID), "closed_devil_treasure_select", {})
    Timer(1,function()
        --防止连点器作弊
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"devil_baowu_prevent_cheat",{})
    end)
    
    if type(treasureName) == "table" then
		return
    end
    
    local isOK = false 
    for i = 1, #GlobalVarFunc.devilDaoWuChiZiTest[nPlayerID + 1] do
        if treasureName == GlobalVarFunc.devilDaoWuChiZiTest[nPlayerID + 1][i] then
            isOK = true
        end
    end
    GlobalVarFunc.devilDaoWuChiZiTest[nPlayerID + 1] = {}
    if not isOK then
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
    for i = 1, #GlobalVarFunc.player_devil_treasure_list[nPlayerID] do
        if treasureName == GlobalVarFunc.player_devil_treasure_list[nPlayerID][i] then
            table.remove(GlobalVarFunc.player_devil_treasure_list[nPlayerID], i)
        end    
    end
    
    if string.find(treasureName, "item") then
        hHero:AddItemByName(treasureName)
    elseif string.find(treasureName, "gem") then
        -- local Ability = hHero:AddAbility(treasureName)
        -- Ability:SetLevel(1)
        
        --添加宝物的modifier
        hHero:AddNewModifier( hHero, hAbility, "modifier_"..treasureName, {} )
        -- 添加宝物到表中
        table.insert(GlobalVarFunc.devilNameCount[nPlayerID + 1], "modifier_"..treasureName)
        --DeepPrintTable(GlobalVarFunc.devilNameCount)
    else
        -- 宝物既不是技能也不是物品的时候
    end
end

--创建商人
function Devil_Treasure_selected:OnCreateBusinessMan()

    if GlobalVarFunc.businessNum < 2 then
        GlobalVarFunc.businessNum = GlobalVarFunc.businessNum + 1
    else
        return
    end

    CustomGameEventManager:Send_ServerToAllClients("show_event_tip",{event_name="shenmishangren"})

    local name = "npc_dota_creature_businessman"
    local position = Vector(-300, -1700, 130)
    local businessMan = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    businessMan:AddNewModifier(nil, nil, "modifier_invulnerable", {})
    CustomGameEventManager:Send_ServerToAllClients("businessMan_index",{index=businessMan:entindex()})

    local time = 120
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("businessMan_think"), 
    function()
        if GameRules:IsGamePaused() then
            return 0.1
        end
        if time > 0 then
            time = time - 1
            return 1
        else
            UTIL_Remove(businessMan)
            CustomGameEventManager:Send_ServerToAllClients("closed_item_select",{})
            return nil
        end
    end, 0)
end

function Devil_Treasure_selected:OnDuiHanEMoBaoWuShu(data)
    local nPlayerID = data.PlayerID
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

    -- local item = Devil_Treasure_selected:GetItemName(hHero,"item_gerenbaoWu_book")
    -- if item == nil then
    --     CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="没有个人宝物书"})
    -- else
 
    --     if  GlobalVarFunc.duihuanEMoBaoWuShuNum[nPlayerID + 1] > 3 then
    --         CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="兑换次数已达上限"})
    --     else

    --         local woods = Player_Data:getPoints(nPlayerID)
    --         if woods < GlobalVarFunc.duihuanEMoBaoWuShuNum[nPlayerID + 1] * 100000 then
    --             CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="WOOD_NOT_ENOUGH"})
    --         else

    --             Player_Data:AddPoint(nPlayerID, -GlobalVarFunc.duihuanEMoBaoWuShuNum[nPlayerID + 1] * 100000)
    --             GlobalVarFunc.duihuanEMoBaoWuShuNum[nPlayerID + 1] =  GlobalVarFunc.duihuanEMoBaoWuShuNum[nPlayerID + 1] + 1
    --             local nNowCharges = item:GetCurrentCharges()
    --             if nNowCharges > 1 then
    --                 item:SetCurrentCharges(nNowCharges - 1)
    --             elseif nNowCharges == 1 then
    --                 UTIL_Remove(item)
    --             end
    --             hHero:AddItemByName("item_devil_baoWu_book")

    --         end

    --     end

    -- end

    if  GlobalVarFunc.duihuanEMoBaoWuShuNum[nPlayerID + 1] > 3 then
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="兑换次数已达上限"})
    else
        local woods = Player_Data:getPoints(nPlayerID)
        if woods < GlobalVarFunc.duihuanEMoBaoWuShuNum[nPlayerID + 1] * 100000 then
            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="WOOD_NOT_ENOUGH"})
        else

            Player_Data:AddPoint(nPlayerID, -GlobalVarFunc.duihuanEMoBaoWuShuNum[nPlayerID + 1] * 100000)
            GlobalVarFunc.duihuanEMoBaoWuShuNum[nPlayerID + 1] =  GlobalVarFunc.duihuanEMoBaoWuShuNum[nPlayerID + 1] + 1
            hHero:AddItemByName("item_devil_baoWu_book")

        end
    end

end

function Devil_Treasure_selected:GetItemName(hHero,sItemName)
	for i = 0, 8 do
        local hItem = hHero:GetItemInSlot(i)
        if hItem == nil then
            return
        end
        local ItemName = hItem:GetAbilityName() 
		if ItemName == sItemName then
			return hItem
		end
	end
	return nil
end

function Devil_Treasure_selected:OnDuiHanEMoTianZhanQuan(data)
    local nPlayerID = data.PlayerID
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

    if  GlobalVarFunc.duihuanEMoTianZhanQuanNum[nPlayerID + 1] > 2 then
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="兑换次数已达上限"})
    else

        local woods = Player_Data:getPoints(nPlayerID)
        local needWoods = 0
        if GlobalVarFunc.duihuanEMoTianZhanQuanNum[nPlayerID + 1] == 1 then
            needWoods = 50000
        else
            needWoods = 150000
        end
        if woods < needWoods then
            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="WOOD_NOT_ENOUGH"})
        else

            Player_Data:AddPoint(nPlayerID, -needWoods)
            GlobalVarFunc.duihuanEMoTianZhanQuanNum[nPlayerID + 1] =  GlobalVarFunc.duihuanEMoTianZhanQuanNum[nPlayerID + 1] + 1
            hHero:AddItemByName("item_devil_tianzhan_quan")

        end

    end

end

function Devil_Treasure_selected:OnKillDvil(event)
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    if killedUnit:GetUnitName() == "npc_eMo_boss" then
        local nPlayerID = tonumber(killedUnit.nPlayerID)
        local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
        hHero:AddItemByName("item_devil_baoWu_book")
    end
end
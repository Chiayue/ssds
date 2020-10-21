if MonsterChallenge == nil then
    MonsterChallenge = class({})
end

local player_successChallenge = {}

function MonsterChallenge:Start()
    for i = 0 , MAX_PLAYER - 1 do
        player_successChallenge[i] = {}
        player_successChallenge[i]["successChallengeNum"] = 0
        player_successChallenge[i]["AbilityImage_1"] = ""
        player_successChallenge[i]["AbilityImage_2"] = ""
        player_successChallenge[i]["AbilityImage_3"] = ""
        player_successChallenge[i]["AbilityImage_4"] = ""
        player_successChallenge[i]["DuLiuNum"] = 0
        player_successChallenge[i]["InvestmentAndOperate"] = 1
        player_successChallenge[i]["InvestmentRewardCoefficient"] = 1
        player_successChallenge[i]["OperateRewardCoefficient"] = 1
    end
    CustomNetTables:SetTableValue( "gameInfo", "challenge", player_successChallenge)

    ListenToGameEvent("entity_killed", Dynamic_Wrap(MonsterChallenge, "OnKillChallengeMonster"), self)
    CustomGameEventManager:RegisterListener("challenge_selected", self.OnChallengeMonster)
end

function MonsterChallenge:OnChallengeMonster(args)
    local itemName = args.item_name
    local itemCost = args.item_cost
    
    if itemName == "ability_qingtong" then
        itemCost = 1000
    elseif itemName == "ability_baiyin" then
        itemCost = 2850
    elseif itemName == "ability_huangjin" then
        itemCost = 4500
    elseif itemName == "ability_chuanshuo" then
        itemCost = 6800
    elseif itemName == "ability_shishi" then
        itemCost = 8800
    elseif itemName == "ability_tianjue" then
        itemCost = 10500
    end

    local nPlayerID = args.PlayerID
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    if hHero:IsNull() then
        return
    end

    if itemCost > PlayerResource:GetGold(nPlayerID) then
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="金币不够"})
        --防止连点器作弊
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"isCheck_prevent_cheat",{})
    else
        PlayerResource:ModifyGold(nPlayerID,-itemCost,true,DOTA_ModifyGold_PurchaseItem)
        if string.find(itemName, "ability_duliu") then
            --挑战毒瘤发育
            send_tips_message(nPlayerID, "使用了贪婪！")
            MonsterChallenge:OnRewardGold(nPlayerID)
            GlobalVarFunc.duliuLevel = GlobalVarFunc.duliuLevel + 1
            MonsterChallenge:OnDuLiuAddNum(nPlayerID)
            CustomGameEventManager:Send_ServerToAllClients("duliu_level",{level=GlobalVarFunc.duliuLevel})
        elseif string.find(itemName, "ability_qingtong") then
            MonsterChallenge:OnCreateMonster("challenge_qingtong",50,150,20,"青铜级弓箭导师",nPlayerID)
        elseif string.find(itemName, "ability_baiyin") then
            MonsterChallenge:OnCreateMonster("challenge_baiyin",200,200,200,"白银级弓箭导师",nPlayerID)
        elseif string.find(itemName, "ability_huangjin") then
            MonsterChallenge:OnCreateMonster("challenge_huangjin",250,250,0,"黄金级弓箭导师",nPlayerID)
        elseif string.find(itemName, "ability_chuanshuo") then
            MonsterChallenge:OnCreateMonster("challenge_chuanshuo",250,80,0,"传说级弓箭导师",nPlayerID)
        elseif string.find(itemName, "ability_shishi") then
            MonsterChallenge:OnCreateMonster("challenge_shishi",50,0,0,"史诗级弓箭导师",nPlayerID)
        elseif string.find(itemName, "ability_tianjue") then
            MonsterChallenge:OnCreateMonster("challenge_tianjue",180,0,250,"天绝神弓",nPlayerID)
        end
    end
end

function MonsterChallenge:OnRewardGold(nPlayerID)
    local otherGold = 0
    local otherWood = 0

    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    if hHero ~= nil then 
        local gold = 1200 + 200 * hHero:GetLevel()
        otherGold = gold * 0.2
        PlayerResource:ModifyGold(nPlayerID,gold,true,DOTA_ModifyGold_PurchaseItem)
        local wood = 100 + 10 * hHero:GetLevel()
        otherWood = wood * 0.2
        Player_Data:AddPoint(nPlayerID,wood)
        local tip = "发起贪婪获得了"..gold.."金币和"..wood.."木头！"
        send_tips_message(nPlayerID, tip)
    end

    for i = 0,MAX_PLAYER - 1 do
        local hero = PlayerResource:GetSelectedHeroEntity(i)
        if hero ~= nil then
            if i ~= nPlayerID then
                PlayerResource:ModifyGold(i,otherGold,true,DOTA_ModifyGold_PurchaseItem)
                Player_Data:AddPoint(i,otherWood)
                local tips = "通过队友发起贪婪获得了"..otherGold.."金币和"..otherWood.."木头！"
                send_tips_message(i, tips)
            end
        end
    end

end

function MonsterChallenge:OnCreateMonster(name,color1,color2,color3,tips,PlayerID)

    local animation_str = "qingtong1"
    local position = Vector(5900, 5600, 0)
    if string.find(name, "challenge_qingtong") then
        position = Vector(4800, 4900, 0)
        animation_str = "qingtong1"
    elseif string.find(name, "challenge_baiyin") then
        position = Vector(5000, 4700, 0)
        animation_str = "baiyin1"
    elseif string.find(name, "challenge_huangjin") then
        position = Vector(5200, 4500, 0)
        animation_str = "huangjin1"
    elseif string.find(name, "challenge_chuanshuo") then
        position = Vector(5100, 4900, 0)
        animation_str = "chuanshuo1"
    elseif string.find(name, "challenge_shishi") then
        position = Vector(5300, 5100, 0)
        animation_str = "shishi1"
    elseif string.find(name, "challenge_tianjue") then
        position = Vector(5500, 5300, 0)
        animation_str = "tianjue1"
    end

    --发送挑战提示动画
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(PlayerID),"challenge_event_tip",{event_name=animation_str})

    local bigBoss = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    bigBoss:SetRenderColor(color1, color2, color3) 
    bigBoss.challengerID = tostring(PlayerID) 

    local tip = "发起了弓箭导师挑战，注意啦"..tips.."出现在地图右上角，存在时间90秒！"
    send_tips_message(PlayerID, tip)

    --挑战冷却时间
    MonsterChallenge:OnCoolDown(PlayerID)

    local time = 90
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("spawn_creep_think"), 
    function()
        if GameRules:IsGamePaused() then
            return 0.1
        end
        if time > 0 then
            time = time - 1
            return 1
        else
            UTIL_Remove(bigBoss)
            --防止连点器作弊
            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(PlayerID),"isCheck_prevent_cheat",{})
            return nil
        end
    end, 0) 
end

function MonsterChallenge:OnKillChallengeMonster(event)

    local killedUnit = EntIndexToHScript(event.entindex_killed)
    if killedUnit.challengerID then
        local animation_str = "qingtong2"
        local PlayerID = tonumber(killedUnit.challengerID)
        if killedUnit:GetUnitName() == "challenge_qingtong" then
            MonsterChallenge:OnAddChallengeAbility(PlayerID,"ability_qingtong","ability_qingtong_challenge")
            animation_str = "qingtong2"
        elseif killedUnit:GetUnitName() == "challenge_baiyin" then
            MonsterChallenge:OnAddChallengeAbility(PlayerID,"ability_baiyin","ability_baiyin_challenge")
            animation_str = "baiyin2"
        elseif killedUnit:GetUnitName() == "challenge_huangjin" then
            MonsterChallenge:OnAddChallengeAbility(PlayerID,"ability_huangjin","ability_huangjin_challenge")
            animation_str = "huangjin2"
        elseif killedUnit:GetUnitName() == "challenge_chuanshuo" then
            MonsterChallenge:OnAddChallengeAbility(PlayerID,"ability_chuanshuo","ability_chuanshuo_challenge")
            animation_str = "chuanshuo2"
        elseif killedUnit:GetUnitName() == "challenge_shishi" then
            MonsterChallenge:OnAddChallengeAbility(PlayerID,"ability_shishi","ability_shishi_challenge")
            animation_str = "shishi2"
        elseif killedUnit:GetUnitName() == "challenge_tianjue" then
            MonsterChallenge:OnAddChallengeAbility(PlayerID,"ability_tianjue","ability_tianjue_challenge")
            animation_str = "tianjue2"
        end

        --发送挑战提示动画
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(PlayerID),"challenge_event_tip",{event_name=animation_str})
    end

end

function MonsterChallenge:OnAddChallengeAbility(PlayerID,ability,heroAbility)
    local player_successChallenge = CustomNetTables:GetTableValue( "gameInfo", "challenge" )

    for k,v in pairs(player_successChallenge) do
        if tonumber(k) == PlayerID then
        
            if v.successChallengeNum >=4 then
                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(PlayerID),"send_error_message_client",{message="进阶槽已满，只能进阶4次哦！"})
            else

                v.successChallengeNum = v.successChallengeNum + 1
                if v.successChallengeNum == 1 then
                    v.AbilityImage_1 = ability
                elseif v.successChallengeNum == 2 then
                    v.AbilityImage_2 = ability
                elseif v.successChallengeNum == 3 then
                    v.AbilityImage_3 = ability
                elseif v.successChallengeNum == 4 then
                    v.AbilityImage_4 = ability
                end

                if ability =="ability_qingtong" then
                    v.InvestmentAndOperate = v.InvestmentAndOperate + 0.05
                    GlobalVarFunc.InvestmentAndOperate[PlayerID+1] = GlobalVarFunc.InvestmentAndOperate[PlayerID+1] + 0.05
                elseif ability =="ability_baiyin" then
                    v.InvestmentAndOperate = v.InvestmentAndOperate + 0.07
                    GlobalVarFunc.InvestmentAndOperate[PlayerID+1] = GlobalVarFunc.InvestmentAndOperate[PlayerID+1] + 0.07
                elseif ability =="ability_huangjin" then
                    v.InvestmentAndOperate = v.InvestmentAndOperate + 0.09
                    GlobalVarFunc.InvestmentAndOperate[PlayerID+1] = GlobalVarFunc.InvestmentAndOperate[PlayerID+1] + 0.09
                elseif ability =="ability_chuanshuo" then
                    v.InvestmentAndOperate = v.InvestmentAndOperate + 0.11
                    GlobalVarFunc.InvestmentAndOperate[PlayerID+1] = GlobalVarFunc.InvestmentAndOperate[PlayerID+1] + 0.11
                elseif ability =="ability_shishi" then
                    v.InvestmentAndOperate = v.InvestmentAndOperate + 0.13
                    GlobalVarFunc.InvestmentAndOperate[PlayerID+1] = GlobalVarFunc.InvestmentAndOperate[PlayerID+1] + 0.13
                elseif ability =="ability_tianjue" then
                    v.InvestmentAndOperate = v.InvestmentAndOperate + 0.15
                    GlobalVarFunc.InvestmentAndOperate[PlayerID+1] = GlobalVarFunc.InvestmentAndOperate[PlayerID+1] + 0.15
                end
                
                CustomNetTables:SetTableValue( "gameInfo", "challenge", player_successChallenge)
                send_tips_message(PlayerID, "进阶成功！")

                local hHero = PlayerResource:GetSelectedHeroEntity(PlayerID)
                if hHero:IsNull() then
                    return
                end
                local Ability = hHero:AddAbility(heroAbility)
                Ability:SetLevel(1)

            end

        end
    end

end

function MonsterChallenge:OnDuLiuAddNum(PlayerID)
    local player_successChallenge = CustomNetTables:GetTableValue( "gameInfo", "challenge" )

    for k,v in pairs(player_successChallenge) do
        if tonumber(k) == PlayerID then
            v.DuLiuNum = v.DuLiuNum + 1
            CustomNetTables:SetTableValue( "gameInfo", "challenge", player_successChallenge)
        end
    end

end

--挑战冷却
function MonsterChallenge:OnCoolDown(nPlayerID)
    
    local time = 90
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("cool_down_think"), 
    function()
        if GameRules:IsGamePaused() then
            return 0.1
        end

        local nPlayer = PlayerResource:GetPlayer(nPlayerID)
        if nPlayer ~= nil then
            CustomGameEventManager:Send_ServerToPlayer(nPlayer,"cool_down_time",{coolDownTime= time})
        end

        if time > 0 then
            time = time - 1            
            return 1
        else
            return nil
        end
    end, 0)  
end






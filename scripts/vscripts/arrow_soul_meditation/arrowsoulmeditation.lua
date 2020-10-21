if ArrowSoulMeditation == nil then 
    ArrowSoulMeditation = class({})
end

function ArrowSoulMeditation:Start() 
    CustomGameEventManager:RegisterListener( "arrowSoul_meditation", self.OnMeditationArrowSoul)
    ListenToGameEvent( "dota_player_gained_level" ,Dynamic_Wrap(ArrowSoulMeditation,"OnPlayerGainedLevel"),self)
end

--力量/敏捷/智力 成长
function ArrowSoulMeditation:OnPlayerGainedLevel(args)
    local hHero = PlayerResource:GetSelectedHeroEntity(args.PlayerID)
    local steam_id = PlayerResource:GetSteamAccountID(args.PlayerID)
    if hHero ~= nil and steam_id ~= 0 then
        --获取当前箭魂修炼等级
        local arrowSoul_meditationNum = Archive:GetData(args.PlayerID,"arrowSoul_meditation")
        if arrowSoul_meditationNum >= 22 then
            ArrowSoulMeditation:AddBasebonus(hHero,DOTA_ATTRIBUTE_STRENGTH)
        end
        if arrowSoul_meditationNum >= 23 then
            ArrowSoulMeditation:AddBasebonus(hHero,DOTA_ATTRIBUTE_AGILITY)  
        end
        if arrowSoul_meditationNum >= 24 then
            ArrowSoulMeditation:AddBasebonus(hHero,DOTA_ATTRIBUTE_INTELLECT)
        end
    end
end

function ArrowSoulMeditation:AddBasebonus(hHero,sAttr)
    local BaseAttr = 0
    if sAttr == DOTA_ATTRIBUTE_STRENGTH then
        BaseAttr = hHero:GetBaseStrength()
        hHero:SetBaseStrength(BaseAttr+3) 
    end
    if sAttr == DOTA_ATTRIBUTE_AGILITY then
        BaseAttr = hHero:GetBaseAgility()
        hHero:SetBaseAgility(BaseAttr+3) 
    end
    if sAttr == DOTA_ATTRIBUTE_INTELLECT then
        BaseAttr = hHero:GetBaseIntellect()
        hHero:SetBaseIntellect(BaseAttr+3)
    end
end

function ArrowSoulMeditation:OnMeditationArrowSoul(args)

    --获取当前箭魂修炼来判断箭魂消耗
    local arrowSoul_meditationNum = Archive:GetData(args.PlayerID,"arrowSoul_meditation")
    local cost_arrowSoul = 0
    if arrowSoul_meditationNum < 6 then
        cost_arrowSoul = 200
    elseif arrowSoul_meditationNum < 12 then
        cost_arrowSoul = 500
    elseif arrowSoul_meditationNum < 18 then
        cost_arrowSoul = 1000
    elseif arrowSoul_meditationNum < 24 then
        cost_arrowSoul = 2000
    elseif arrowSoul_meditationNum < 30 then
        cost_arrowSoul = 3000
    elseif arrowSoul_meditationNum <= 36 then
        cost_arrowSoul = 6000
    end
    
    local playerArrowSoulNum =  Store:GetData(args.PlayerID,"arrow_soul")
    
    if playerArrowSoulNum >= cost_arrowSoul then

        Timer(5,function()
            --防止连点器作弊
            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(args.PlayerID),"arrowSoul_prevent_cheat",{})
        end)

        arrowSoul_meditationNum = arrowSoul_meditationNum + 1
        Archive:EditPlayerProfile(args.PlayerID,"arrowSoul_meditation",arrowSoul_meditationNum)
        -- 消耗自定义货币 比如箭魂
        Store:UsedCustomGoodsValue(args.PlayerID,"arrow_soul",cost_arrowSoul,"箭魂修炼")

        --箭魂修炼数据存档
        local hRows = {}
        hRows["arrowSoul_meditation"] = arrowSoul_meditationNum
        Archive:SaveRowsToPlayer(args.PlayerID,hRows)

        --发送存档信息
        local playerData = Archive:GetData(args.PlayerID)
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(args.PlayerID),"init_player_file",playerData)

        local hHero = PlayerResource:GetSelectedHeroEntity(args.PlayerID)
        if hHero:IsNull() then
            return
        end

        if not hHero:HasModifier("modifier_arrowSoul_meditation")  then
            hHero:AddNewModifier( hHero, nil, "modifier_arrowSoul_meditation", {} )
        end
        hHero:SetModifierStackCount( "modifier_arrowSoul_meditation", hHero, arrowSoul_meditationNum)
     
        --箭魂通关奖励+15%
        if arrowSoul_meditationNum == 4 then
            GlobalVarFunc.arrowSoulRewardCoefficient[args.PlayerID+1] = GlobalVarFunc.arrowSoulRewardCoefficient[args.PlayerID+1] + 0.15
        end
        --木材+100
        if arrowSoul_meditationNum == 7 then
            Player_Data:AddPoint(args.PlayerID,100)
        end
        --木材+300
        if arrowSoul_meditationNum == 25 then
            Player_Data:AddPoint(args.PlayerID,300)
        end
        --投资收益率+10%
        if arrowSoul_meditationNum == 29 then
            GlobalVarFunc.InvestmentRewardCoefficient[args.PlayerID+1] = GlobalVarFunc.InvestmentRewardCoefficient[args.PlayerID+1] + 0.10
        end
        --回合收益率+10%
        if arrowSoul_meditationNum == 30 then
            GlobalVarFunc.OperateRewardCoefficient[args.PlayerID+1] = GlobalVarFunc.OperateRewardCoefficient[args.PlayerID+1] + 0.10
        end
        --初始金币+600
        if arrowSoul_meditationNum == 31 then
            PlayerResource:ModifyGold(args.PlayerID,600,true,DOTA_ModifyGold_Unspecified)
        end

    else
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(args.PlayerID),"send_error_message_client",{message="箭魂不够"})
        --防止连点器作弊
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(args.PlayerID),"arrowSoul_prevent_cheat",{})
    end

end

function ArrowSoulMeditation:OnInitArrowSoulMeditation(hHero)
    local nPlayerCount = PlayerResource:GetPlayerCount()

    local nPlayerID = hHero:GetOwner():GetPlayerID() 
    local arrowSoul_meditationNum = Archive:GetData(nPlayerID,"arrowSoul_meditation")

    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    if hHero:IsNull() then
        return
    end
    if not hHero:HasModifier("modifier_arrowSoul_meditation")  then
        hHero:AddNewModifier( hHero, nil, "modifier_arrowSoul_meditation", {} )
    end
    hHero:SetModifierStackCount( "modifier_arrowSoul_meditation", hHero, arrowSoul_meditationNum)
    --箭魂通关奖励+15%
    if arrowSoul_meditationNum >= 4 then
        GlobalVarFunc.arrowSoulRewardCoefficient[nPlayerID+1] = GlobalVarFunc.arrowSoulRewardCoefficient[nPlayerID+1] + 0.15
    end
    --木材+100
    if arrowSoul_meditationNum >= 7 then
        Player_Data:AddPoint(nPlayerID,100)
    end
    --木材+300
    if arrowSoul_meditationNum >= 25 then
        Player_Data:AddPoint(nPlayerID,300)
    end
    --投资收益率+10%
    if arrowSoul_meditationNum >= 29 then
        GlobalVarFunc.InvestmentRewardCoefficient[nPlayerID+1] = GlobalVarFunc.InvestmentRewardCoefficient[nPlayerID+1] + 0.10
    end
    --回合收益率+10%
    if arrowSoul_meditationNum >= 30 then
        GlobalVarFunc.OperateRewardCoefficient[nPlayerID+1] = GlobalVarFunc.OperateRewardCoefficient[nPlayerID+1] + 0.10
    end
    --初始金币+600
    if arrowSoul_meditationNum >= 31 then
        PlayerResource:ModifyGold(nPlayerID,600,true,DOTA_ModifyGold_Unspecified)
    end
    
end


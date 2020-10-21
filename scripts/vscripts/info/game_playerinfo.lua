if game_playerinfo == nil then
    game_playerinfo = class({})
end

--存档模拟数据
-- {
--     0                               	= table: 0x0024ab40 (table)                --PlayerID
--     { 
--        game_killNum                    	= 0 (number)                           --杀怪数
--        game_time                       	= 0 (number)                           --游戏总时间
--        endless_waves                   	= 0 (number)                           --无尽模式波数
--        gamaModeNum                    	= 0 (number)                           --记录玩家最高的游戏模式
--        gameMode_0_clearance            	= 0 (number)                           --0模式通关次数
--        gameMode_1_clearance            	= 0 (number)                           --1模式通关次数
--        gameMode_2_clearance            	= 0 (number)                           --2模式通关次数
--        gameMode_3_clearance            	= 0 (number)                           --3模式通关次数
--        gameMode_4_clearance            	= 0 (number)                           --4模式通关次数    
--        arrowSoul_meditation               = 0 (number)                                             
--     }
--  }

--玩家存档字段
local player_STR = {
    "endless_waves",
    "game_killNum",
    "game_time",
    "gamaModeNum",
    "gameMode_0_clearance",
    "gameMode_1_clearance",
    "gameMode_2_clearance",
    "gameMode_3_clearance",
    "gameMode_4_clearance",
    "gameMode_7_clearance",
    "gameMode_10_clearance",
    "arrowSoul_meditation",
    "weekly_waves",
} 
--玩家存档数据网表
local playersData = {}

function game_playerinfo:Init()
    --读取存档数据
    self:Start()

    CustomGameEventManager:RegisterListener("get_players_file", self.OnGetPlayerData)
end

function game_playerinfo:Start()
    print("init game_playerinfo")
    local nPlayerCount = PlayerResource:GetPlayerCount()
    for nPlayerID = 0,nPlayerCount - 1 do
        self:create_playerinfo(nPlayerID)
    end
end

function game_playerinfo:create_playerinfo(nPlayerID)
    -- 初次建档的玩家数据初始化
    for i = 1,#player_STR do
        local value = Archive:GetDataSpecial(nPlayerID,player_STR[i])
        if value == 0 then
            Archive:EditPlayerProfile(nPlayerID,player_STR[i],0)
        elseif value == -1 then
            Archive:EditPlayerProfile(nPlayerID,player_STR[i],-1)
        end
    end
end

function game_playerinfo:SaveData()
    --更新玩家游戏数据
    self:update_playerInfo()
end

--更新玩家游戏数据
function game_playerinfo:update_playerInfo()
    CustomNetTables:SetTableValue( "player_data", "damage", GlobalVarFunc.damage)
    local nData_common = CustomNetTables:GetTableValue( "player_data", "score" )
    local hClearReward = {}
    for k,v in pairs(nData_common) do
        local PlayerID = tonumber(k)
        local steam_id = PlayerResource:GetSteamAccountID(PlayerID)
        if steam_id ~= 0 then
            --掉线玩家处理
            local nPlayer = PlayerResource:GetPlayer(PlayerID)
            if nPlayer ~= nil then
                local game_killNum = tonumber(v.Kills) + Archive:GetData(PlayerID,"game_killNum")
                Archive:EditPlayerProfile(PlayerID,"game_killNum",game_killNum)
    
                local game_time = math.floor(GameRules:GetDOTATime(false,false)) + Archive:GetData(PlayerID,"game_time")
                Archive:EditPlayerProfile(PlayerID,"game_time",game_time)
    
                if GlobalVarFunc.isClearance then
                    if GlobalVarFunc.game_type==0 then
                        local gameMode_0_clearance = Archive:GetData(PlayerID,"gameMode_0_clearance") + 1
                        Archive:EditPlayerProfile(PlayerID,"gameMode_0_clearance",gameMode_0_clearance)
                    elseif GlobalVarFunc.game_type==1 then 
                        local gameMode_1_clearance = Archive:GetData(PlayerID,"gameMode_1_clearance") + 1
                        Archive:EditPlayerProfile(PlayerID,"gameMode_1_clearance",gameMode_1_clearance)
                    elseif GlobalVarFunc.game_type==2 then
                        local gameMode_2_clearance = Archive:GetData(PlayerID,"gameMode_2_clearance") + 1
                        Archive:EditPlayerProfile(PlayerID,"gameMode_2_clearance",gameMode_2_clearance)
                    elseif GlobalVarFunc.game_type==3 then
                        local gameMode_3_clearance = Archive:GetData(PlayerID,"gameMode_3_clearance") + 1
                        Archive:EditPlayerProfile(PlayerID,"gameMode_3_clearance",gameMode_3_clearance)
                    elseif GlobalVarFunc.game_type==4 then
                        local gameMode_4_clearance = Archive:GetData(PlayerID,"gameMode_4_clearance") + 1
                        Archive:EditPlayerProfile(PlayerID,"gameMode_4_clearance",gameMode_4_clearance)
                    elseif GlobalVarFunc.game_type==7 then
                        local gameMode_7_clearance = Archive:GetData(PlayerID,"gameMode_7_clearance") + 1
                        Archive:EditPlayerProfile(PlayerID,"gameMode_7_clearance",gameMode_7_clearance)
                    elseif GlobalVarFunc.game_type==10 then
                        local gameMode_10_clearance = Archive:GetData(PlayerID,"gameMode_10_clearance") + 1
                        Archive:EditPlayerProfile(PlayerID,"gameMode_10_clearance",gameMode_10_clearance)
                    end
    
                    --记录玩家最高的游戏模式
                    local gameModeNum = Archive:GetData(PlayerID,"gamaModeNum")
                    if gameModeNum < GlobalVarFunc.game_type then
                        gameModeNum = gameModeNum + 1
                        Archive:EditPlayerProfile(PlayerID,"gamaModeNum",gameModeNum)
                    end
    
                end
    
                if GlobalVarFunc.game_mode == "endless" then
                    if Archive:GetData(PlayerID,"endless_waves") <= GlobalVarFunc.MonsterWave then
                        Archive:EditPlayerProfile(PlayerID,"endless_waves",GlobalVarFunc.MonsterWave)
                    end

                    if GlobalVarFunc.game_type==1001 then
                        local weekly_wavesNum = Archive:GetData(PlayerID,"weekly_waves") + GlobalVarFunc.MonsterWave
                        Archive:EditPlayerProfile(PlayerID,"weekly_waves",weekly_wavesNum)
                        
                        --每周自闭模式地图经验奖励
                        self:OnWeekly_wavesReward(PlayerID)
                    end

                    --无尽装备存档
                    Archive:SaveServerEqui(PlayerID)
                end 
    
                --箭魂奖励结算
                
                table.insert(hClearReward,self:OnArrowSoulReward(PlayerID))
            end
        end
    end
    local tip = ""
    if GlobalVarFunc.isClearance then 
        tip = "第"..GlobalVarFunc.game_type.."章[通关]箭魂奖励"
    else
        tip = "第"..GlobalVarFunc.game_type.."章【失败】箭魂奖励"
    end
    Store:AddAllArrowSoul(hClearReward,"arrow_soul",tip)
    Archive:SendRanking("normal",GlobalVarFunc.game_type)
    Archive:SaveProfile()
    CustomNetTables:SetTableValue( "gameInfo", "playersData", Archive:GetData())
end

function game_playerinfo:OnWeekly_wavesReward(nPlayerID)
    if GlobalVarFunc.MonsterWave >= 200 then
        local game_time = 30*60 + Archive:GetData(nPlayerID,"game_time")
        Archive:EditPlayerProfile(nPlayerID,"game_time",game_time)
    end
end

--箭魂奖励结算
function game_playerinfo:OnArrowSoulReward(nPlayerID)
    local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
    local hHero = CDOTAPlayer:GetAssignedHero()
    local isHaveArrowSoulReward = hHero:HasModifier("modifier_store_reward_clearance_gifbag")
    
    local nReward = GlobalVarFunc.arrowSoulRewardCoefficient[nPlayerID+1]
    if isHaveArrowSoulReward == true then nReward = nReward + 0.35 end
    local nBaseArrowSoulReward = 0
    if GlobalVarFunc.game_mode == "endless" then
        if GlobalVarFunc.MonsterWave >= 70 then
            nBaseArrowSoulReward = 100
        elseif GlobalVarFunc.MonsterWave >= 60 then
            nBaseArrowSoulReward = 90
        elseif GlobalVarFunc.MonsterWave >= 50 then
            nBaseArrowSoulReward = 80
        elseif GlobalVarFunc.MonsterWave >= 40 then
            nBaseArrowSoulReward = 70
        elseif GlobalVarFunc.MonsterWave >= 30 then
            nBaseArrowSoulReward = 60
        elseif GlobalVarFunc.MonsterWave >= 20 then
            nBaseArrowSoulReward = 40
        end
    else
        if GlobalVarFunc.isClearance then 
            if GlobalVarFunc.game_type > 9 then
                nBaseArrowSoulReward = 200
            else
                nBaseArrowSoulReward = math.floor( (GlobalVarFunc.game_type + 1) * 20  )
            end
        else
            nBaseArrowSoulReward = GlobalVarFunc.MonsterWave
        end
    end
    local nArrowSoulNum = nBaseArrowSoulReward * nReward
    local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
    return {steam_id = nSteamID, quantity = nArrowSoulNum }
end

function game_playerinfo:get_player_info()
    local playersData = Archive:GetData()
    return playersData
end

function game_playerinfo:OnGetPlayerData(args)
    local nPlayerID = args.PlayerID
    --发送存档信息
    local playerData = Archive:GetData(nPlayerID)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"init_player_file",playerData)
end
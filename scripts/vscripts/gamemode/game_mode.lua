if GameMode == nil then 
    GameMode = class({})
end

local game_info = {}

function GameMode:Start()
    print("GameMode Start")
    game_info["gameModeClass"] = "common"
    game_info["gameMode"] = 0
    game_info["monsterWaves"] = 0
    game_info["gameOver_state"] = -3
    CustomNetTables:SetTableValue( "gameInfo","gameInfo", game_info)
    CustomGameEventManager:RegisterListener( "gamemode_selection", self.OnSelectionGameMode)
    CustomGameEventManager:RegisterListener( "updata_loading", self.OnUpdata_loading)
    ListenToGameEvent( "player_team" ,Dynamic_Wrap(GameMode,"_OnPlayerTeam"),self)
end

function GameMode:OnSelectionGameMode(data)
    GlobalVarFunc.game_mode =  data.gameMode
    GlobalVarFunc.game_type = data.gameType
    game_info["gameModeClass"] = data.gameMode
    game_info["gameMode"] = data.gameType
    CustomNetTables:SetTableValue( "gameInfo","gameInfo", game_info)
end

function GameMode:_OnPlayerTeam(event)
    --显示游戏模式界面
    CustomGameEventManager:Send_ServerToAllClients("show_game_mode_panel",{})
end

function GameMode:UpdateGameInfoNetTable(data)
    game_info["gameModeClass"] = data.gameMode
    game_info["gameMode"] = data.gameType
    game_info["monsterWaves"] = data.gameWaves
    CustomNetTables:SetTableValue( "gameInfo","gameInfo", game_info)
end

function GameMode:OnUpdata_loading(data)

    local isDataOk = Archive:CheckLoading()
    if isDataOk then

        GameMode:OnPlayersNum()
        --进行数据读档，玩家存档信息初始化
        game_playerinfo:Init()
        local playerData = Archive:GetData(0)
        --设置默认游戏模式
        GlobalVarFunc.game_type = Archive:GetData(0,"gamaModeNum") + 1
        game_info["gameMode"] = GlobalVarFunc.game_type
        game_info["gameModeClass"] = GlobalVarFunc.game_mode
        CustomNetTables:SetTableValue( "gameInfo","gameInfo", game_info)
        CustomGameEventManager:Send_ServerToAllClients("show_unlock",playerData)
        return nil
    else 
        Timer(3,function()
            GameMode:OnUpdata_loading()
        end)
    end
end

--统计玩家数量
function GameMode:OnPlayersNum()
   GlobalVarFunc.playersNum = PlayerResource:GetPlayerCount()
end
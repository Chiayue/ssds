if MonsterExerciseRoom == nil then 
    MonsterExerciseRoom = class({})
end

local spawner_config = require("monster/monster_config")

local roomVec = {
    Vector(-7600, 2500, 0),
    Vector(-7600, -700, 0),
    Vector(-7600, -3700, 0),
    Vector(7600, 2400, 0),
    Vector(7600, -700, 0),
    Vector(7600, -3700, 0)
}
local roomSwitch = {false,false,false,false,false,false}
local roomMonsterNum = {0,0,0,0,0,0}
local roomLevel = {0,0,0,0,0,0}
local roomStopLevel = {false,false,false,false,false,false}

local PK_state = false
local PK_rank = {0,0,0,0,0,0}

function MonsterExerciseRoom:Start() 
    GameRules:GetGameModeEntity():SetThink("OnThinkerExerciseRoom",self)

    ListenToGameEvent("entity_killed", Dynamic_Wrap(MonsterExerciseRoom, "OnKillExerciseRoom"), self)

    CustomGameEventManager:RegisterListener("EnterExerciseRoom", self.OnEnterExerciseRoom)
    CustomGameEventManager:RegisterListener("BackExerciseRoom", self.OnBackExerciseRoom)
    CustomGameEventManager:RegisterListener("AddExerciseRoomLevel", self.OnAddExerciseRoomLevel)
    CustomGameEventManager:RegisterListener("ReduceExerciseRoomLevel", self.OnReduceExerciseRoomLevel)
    CustomGameEventManager:RegisterListener("StopExerciseRoomLevel", self.OnStopExerciseRoomLevel)
end

function MonsterExerciseRoom:OnThinkerExerciseRoom()

    --判断是否暂停游戏
    if GameRules:IsGamePaused() then
        return 1
    end
    --判断是否游戏结束
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end

    if GlobalVarFunc.game_type ~= 1002 then
        return 1
    end

    local now = GameRules:GetDOTATime(false, false)  --返回Dota游戏内的时间。（是否包含赛前时间或负时间)
    now = math.floor(now)

    self:OnTraverseRoom(now)

    return 1
end

function MonsterExerciseRoom:OnTraverseRoom(now)
    if now == 0 or now % 3 ~= 0 then
        return
    end

    for i=1, #roomVec do 
        if roomSwitch[i] and (roomMonsterNum[i] == 0) then

            if roomStopLevel[i] then
                roomLevel[i] = roomLevel[i]
            else
                roomLevel[i] = roomLevel[i] + 1
            end

            if roomLevel[i] == 0 then
                return
            end
        
            local nPlayer = PlayerResource:GetPlayer(i - 1)
            CustomGameEventManager:Send_ServerToPlayer(nPlayer,"ShowExerciseRoomLevel", {level = roomLevel[i]}) 


            self:OnCreateMonster(i, roomVec[i], roomLevel[i])
        end 
    end
end

function MonsterExerciseRoom:OnCreateMonster(index, vec, level)

    if level % 10 == 0 then

        local model = level
        if level <= 50 then 
            model = level
        else
            if level%50==0 then 
                model = 1
            else
                model = level%50
            end
        end 

        local position = vec + RandomVector( RandomFloat( 200, 400 ))
        local monster_name = "npc_dota_creature_monster_"..model
        -- 创建单位 
        local boss = CreateUnitByNameInPool(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
        boss:SetModelScale(3)
        self:setMonsterBaseInformation(boss, level)
        local roomIndex = tostring(index)
        boss:SetContext("exerciseRoom", roomIndex, 0)
    
        roomMonsterNum[index] = roomMonsterNum[index] + 1

    else

        for i=1, 10 do

            local model = level
            if level <= 50 then 
                model = level
            else
                if level%50==0 then 
                    model = 1
                else
                    model = level%50
                end
            end 
            local position = vec + RandomVector( RandomFloat( 200, 400 ))
            local monster_name = "npc_dota_creature_monster_"..model
            -- 创建单位 
            local mob = CreateUnitByNameInPool(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
            self:setMonsterBaseInformation(mob, level)
            local roomIndex = tostring(index)
            mob:SetContext("exerciseRoom", roomIndex, 0)
        
            roomMonsterNum[index] = roomMonsterNum[index] + 1
        end

    end

end

function MonsterExerciseRoom:OnEnterExerciseRoom(data)
    
    local nPlayer = PlayerResource:GetPlayer(data.PlayerID)
    local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if (not hero:IsAlive()) and (not hero:IsRealHero()) then
        return 
    end
    local position = roomVec[data.PlayerID + 1]
    FindClearSpaceForUnit(hero, position,true)
    CustomGameEventManager:Send_ServerToPlayer(nPlayer,"Show_Camera", {Vec = position})

    roomSwitch[data.PlayerID + 1] = true
    
end

function MonsterExerciseRoom:OnBackExerciseRoom(data)
    
    local nPlayer = PlayerResource:GetPlayer(data.PlayerID)
    local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if (not hero:IsAlive()) and (not hero:IsRealHero()) then
        return 
    end
    local position = Vector(-300, -1700, 130)
    FindClearSpaceForUnit(hero, position,true)
    CustomGameEventManager:Send_ServerToPlayer(nPlayer,"Show_Camera", {Vec = position})

    roomSwitch[data.PlayerID + 1] = false 

end

function MonsterExerciseRoom:OnAddExerciseRoomLevel(data)

    roomStopLevel[data.PlayerID +1] = false

    -- roomLevel[data.PlayerID +1] = roomLevel[data.PlayerID +1] + 1
    -- local nPlayer = PlayerResource:GetPlayer(data.PlayerID)
    -- CustomGameEventManager:Send_ServerToPlayer(nPlayer,"ShowExerciseRoomLevel", {level = roomLevel[data.PlayerID +1]})
end

function MonsterExerciseRoom:OnReduceExerciseRoomLevel(data)
    if roomLevel[data.PlayerID +1] == 0 then
        return
    end
    roomLevel[data.PlayerID +1] = roomLevel[data.PlayerID +1] - 1

    local nPlayer = PlayerResource:GetPlayer(data.PlayerID)
    CustomGameEventManager:Send_ServerToPlayer(nPlayer,"ShowExerciseRoomLevel", {level = roomLevel[data.PlayerID +1]})
end

function MonsterExerciseRoom:OnStopExerciseRoomLevel(data)
    roomStopLevel[data.PlayerID +1] = true
end

function MonsterExerciseRoom:OnKillExerciseRoom(event) 
    if GlobalVarFunc.game_type ~= 1002 then
        return
    end

    local killedUnit = EntIndexToHScript(event.entindex_killed)

    -- if PK_state and killedUnit:IsHero() then
    --     local nPlayerID = killedUnit:GetPlayerID()
    --     PK_rank[nPlayerID + 1] 
    -- end

    local index = killedUnit:GetContext("exerciseRoom")
    if index == nil then
        return
    else
        roomMonsterNum[index] = roomMonsterNum[index] - 1
    end
end

--经验房怪物属性
function MonsterExerciseRoom:setMonsterBaseInformation(unit , level)
    local health = self:Health(level)
    local healthRegen = self:HealthRegen(level)
    local attack = self:AttackDamage(level)
    local armor = self:Armor(level)
    local magicalResistance = self:MagicalResistance(level)
    local xp = self:DeathXP(level)
    local gold = self:DeathGold(level)

    --血量上限20亿
    if health > 2000000000 then
        health = 2000000000
    end
    
    unit:SetBaseMaxHealth(health)   
	unit:SetMaxHealth(health)
	unit:SetHealth(health)
	unit:SetBaseHealthRegen(healthRegen)
	unit:SetDeathXP(xp)
	unit:SetMaximumGoldBounty(gold)
	unit:SetMinimumGoldBounty(gold)
	unit:SetBaseDamageMax(attack)
    unit:SetBaseDamageMin(attack)
    unit:SetPhysicalArmorBaseValue(armor)
    unit:SetBaseMagicalResistanceValue(magicalResistance)
	unit:CreatureLevelUp(1)
end

function MonsterExerciseRoom:AttackDamage(level)
    local attack = (level * level * 20) * (GlobalVarFunc.duliuLevel*0.03 + 1) * GlobalVarFunc.MonsterViolent
    return attack
end

function MonsterExerciseRoom:Health(level) 
    local health = level * level * level * 10
    return health
end

function MonsterExerciseRoom:HealthRegen(level) 
    return level
end

function MonsterExerciseRoom:DeathXP(level) 
    return level
end

function MonsterExerciseRoom:DeathGold(level) 
    return level
end

function MonsterExerciseRoom:Armor(level) 
    return level
end

function MonsterExerciseRoom:MagicalResistance(level) 
    return level
end

function MonsterExerciseRoom:OnReadyCountDown()
    local time = 5
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("pk_think"), 
    function()
        if GameRules:IsGamePaused() then
            return 0.1
        end
        GlobalVarFunc:OnGameCountDown(time)
        if time > 0 then
            time = time - 1
            return 1
        else
            MonsterExerciseRoom:OnStartPK()
            return nil
        end
    end, 0) 
end

function MonsterExerciseRoom:OnReadyPK()
    for i = 0 , MAX_PLAYER - 1 do
        local steam_id = PlayerResource:GetSteamAccountID(i)
        if steam_id ~= 0 then
            local nPlayer = PlayerResource:GetPlayer(i)
            if nPlayer ~= nil then
                local hHero = PlayerResource:GetSelectedHeroEntity(i)
                local position = roomVec[i + 1]
                FindClearSpaceForUnit(hHero, position,true)
                CustomGameEventManager:Send_ServerToPlayer(nPlayer,"Show_Camera", {Vec = position})
            
                roomSwitch[i + 1] = false
            end
        end
    end
end

function MonsterExerciseRoom:OnStartPK()
    for i = 0 , MAX_PLAYER - 1 do
        local steam_id = PlayerResource:GetSteamAccountID(i)
        if steam_id ~= 0 then
            local nPlayer = PlayerResource:GetPlayer(i)
            if nPlayer ~= nil then
                local hHero = PlayerResource:GetSelectedHeroEntity(i)
                --减伤光环
                hHero:AddNewModifier(hHero, nil, "modifier_abyss_jianshang", {duration = 30})
                hHero:SetTeam( 6 + i)
                Timer(30, function()
                    hHero:SetTeam( DOTA_TEAM_GOODGUYS )
                    PK_state = false
                end)
                local position = GlobalVarFunc:IsCanFindPath(1000, 4500)
                FindClearSpaceForUnit(hHero, position,true)
                CustomGameEventManager:Send_ServerToPlayer(nPlayer,"Show_Camera", {Vec = position})
            
                roomSwitch[i + 1] = false
            end
        end
    end

    PK_state = true
end

function MonsterExerciseRoom:OnAbyssGameLink()
   
    if GlobalVarFunc.MonsterWave == 3 then
        --恶魔来袭环节
        --深渊野怪池子的数量
        spawner_config.monsterSurplusNum = 500
        GlobalVarFunc.monsterIsShuaMan = true
    elseif GlobalVarFunc.MonsterWave == 5 then
        --宝箱环节
        RandomEvents:OnCreatedBaoXiang()
    elseif GlobalVarFunc.MonsterWave == 7 then
        --杀鸡环节
        RandomEvents:OnCreateChicken()
    elseif GlobalVarFunc.MonsterWave == 9 then
        --英雄PK环节
        self:OnReadyCountDown()
        self:OnReadyPK()
    end

    GlobalVarFunc.abyss_spawn_state = true
end
if MonsterExerciseRoom == nil then 
    MonsterExerciseRoom = class({})
end

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
local roomLevel = {1,1,1,1,1,1}

function MonsterExerciseRoom:Start() 
    GameRules:GetGameModeEntity():SetThink("OnThinkerExerciseRoom",self)

    ListenToGameEvent("entity_killed", Dynamic_Wrap(MonsterExerciseRoom, "OnKillExerciseRoomMonster"), self)

    CustomGameEventManager:RegisterListener("EnterExerciseRoom", self.OnEnterExerciseRoom)
    CustomGameEventManager:RegisterListener("BackExerciseRoom", self.OnBackExerciseRoom)
    CustomGameEventManager:RegisterListener("AddExerciseRoomLevel", self.OnAddExerciseRoomLevel)
    CustomGameEventManager:RegisterListener("ReduceExerciseRoomLevel", self.OnReduceExerciseRoomLevel)
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

    self:OnTraverseRoom()

    return 2
end

function MonsterExerciseRoom:OnTraverseRoom()
    for i=1, #roomVec do 
        if roomSwitch[i] and (roomMonsterNum[i] == 0) then
            self:OnCreateMonster(i, roomVec[i], roomLevel[i])
        end 
    end
end

function MonsterExerciseRoom:OnCreateMonster(index, vec, level)
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

function MonsterExerciseRoom:OnEnterExerciseRoom(data)
    
    local nPlayer = PlayerResource:GetPlayer(data.PlayerID)
    local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hero:IsAlive() and hero:IsNull() and hero:IsRealHero() then
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
    if hero:IsAlive() and hero:IsNull() and hero:IsRealHero() then
        return 
    end
    local position = Vector(-300, -1700, 130)
    FindClearSpaceForUnit(hero, position,true)
    CustomGameEventManager:Send_ServerToPlayer(nPlayer,"Show_Camera", {Vec = position})

    roomSwitch[data.PlayerID + 1] = false 

end

function MonsterExerciseRoom:OnAddExerciseRoomLevel(data)
    roomLevel[data.PlayerID +1] = roomLevel[data.PlayerID +1] + 1

    local nPlayer = PlayerResource:GetPlayer(data.PlayerID)
    CustomGameEventManager:Send_ServerToPlayer(nPlayer,"ShowExerciseRoomLevel", {level = roomLevel[data.PlayerID +1]})
end

function MonsterExerciseRoom:OnReduceExerciseRoomLevel(data)
    if roomLevel[data.PlayerID +1] == 1 then
        return
    end
    roomLevel[data.PlayerID +1] = roomLevel[data.PlayerID +1] - 1

    local nPlayer = PlayerResource:GetPlayer(data.PlayerID)
    CustomGameEventManager:Send_ServerToPlayer(nPlayer,"ShowExerciseRoomLevel", {level = roomLevel[data.PlayerID +1]})
end

function MonsterExerciseRoom:OnKillExerciseRoomMonster(event) 
    local killedUnit = EntIndexToHScript(event.entindex_killed)
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
if MonsterOperate == nil then
    MonsterOperate = class({})
end

--运营野怪被动技能光环
local operate_ability = {
    "ability_operate_attack",                      
    "ability_operate_attack_speed",              
    "ability_operate_move_speed",
    "ability_operate_armor",
    "ability_operate_magicalResistance"                         
}
local operateInfo = {}

function MonsterOperate:Start()
    for i = 0 , MAX_PLAYER - 1 do
        operateInfo[i] = {}
        operateInfo[i]["operate_gold"] = 0
        operateInfo[i]["operate_1"] = 0
        operateInfo[i]["operate_2"] = 0 
        operateInfo[i]["operate_3"] = 0
        operateInfo[i]["operate_4"] = 0
        operateInfo[i]["operate_5"] = 0
        operateInfo[i]["operate_6"] = 0 
        operateInfo[i]["operate_7"] = 0
        operateInfo[i]["operate_8"] = 0
    end
    CustomNetTables:SetTableValue( "gameInfo", "operate", operateInfo)
    CustomGameEventManager:RegisterListener("operate_challange", self.OnChallengeOperate)
    ListenToGameEvent("entity_killed", Dynamic_Wrap(MonsterOperate, "OnKillOperateMonster"), self)
end

function MonsterOperate:OnChallengeOperate(args)
    local operate_Index = args.operateMode
    local nPlayerID = args.PlayerID
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    if hHero:IsNull() then
        return
    end

    --木头
    -- local woods = Player_Data:getPoints(nPlayerID)
    -- if woods<200 then
    --     CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="科技点不够，无法挑战运营怪"})
    -- else
    --     Player_Data:AddPoint(nPlayerID,-200)
    --     MonsterOperate:OnCreateMonster(nPlayerID,operate_Index)
    -- end

    --金币
    local gold = PlayerResource:GetGold(nPlayerID)

    if operate_Index >= 7 then
        if gold < 25000 then
            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="金币不够，无法挑战运营怪"})
        else
            PlayerResource:SpendGold(nPlayerID,25000,DOTA_ModifyGold_AbilityCost)
            MonsterOperate:OnCreateMonster(nPlayerID,operate_Index)
        end
    else
        if gold < 2500 then
            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="金币不够，无法挑战运营怪"})
        else
            PlayerResource:SpendGold(nPlayerID,2500,DOTA_ModifyGold_AbilityCost)
            MonsterOperate:OnCreateMonster(nPlayerID,operate_Index)
        end
    end
end

function MonsterOperate:OnCreateMonster(PlayerID,index) 

    local position = Vector(0, 0, 0) + RandomVector( RandomFloat( 1000, 4500 ))
    local path_ok =  GridNav:CanFindPath(position, Vector(1000, 0, 0))
    --判断是否能从某个起始点移动到某个终点
    if not path_ok then
        position = Vector(1000, 0, 0)
    end
    local bigBoss = CreateUnitByName("create_operate_challenge_monster", position, true, nil, nil, DOTA_TEAM_BADGUYS)
    bigBoss.operateID = tostring(PlayerID)
    bigBoss.operateIndex = tostring(index) 
    MonsterOperate:setMonsterBaseInformation(bigBoss,index)

    local time = 60
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
            return nil
        end
    end, 0)  
end

function MonsterOperate:setMonsterBaseInformation(bigBoss,index)

    if index == 1 then
        bigBoss:SetRenderColor(165, 255, 38)
        MonsterOperate:setOperateInformation(bigBoss, 500, 30)
    elseif index == 2 then
        MonsterOperate:OnAddAbility(bigBoss, 1)
        bigBoss:SetRenderColor(255, 180, 33)
        MonsterOperate:setOperateInformation(bigBoss, 10000, 30)
    elseif index == 3 then
        bigBoss:SetRenderColor(255, 84, 38)
        MonsterOperate:setOperateInformation(bigBoss, 10000, 210)
    elseif index == 4 then
        MonsterOperate:OnAddAbility(bigBoss, 2)
        bigBoss:SetRenderColor(189, 39, 255)
        MonsterOperate:setOperateInformation(bigBoss, 150000, 210)
    elseif index == 5 then
        bigBoss:SetRenderColor(251, 255, 38)
        MonsterOperate:setOperateInformation(bigBoss, 150000, 1000)
    elseif index == 6 then
        MonsterOperate:OnAddAbility(bigBoss, 2)
        bigBoss:SetRenderColor(30, 223, 255)
        MonsterOperate:setOperateInformation(bigBoss, 1500000, 1000)
    elseif index == 7 then
        bigBoss:SetRenderColor(255, 40, 182)
        MonsterOperate:setOperateInformation(bigBoss, 1500000, 2500)
    elseif index == 8 then
        MonsterOperate:OnAddAbility(bigBoss, 2)
        bigBoss:SetRenderColor(102, 179, 148)
        MonsterOperate:setOperateInformation(bigBoss, 10000000, 2500)
    end 
    
end

function MonsterOperate:setOperateInformation(unit, health, damage)
    unit:SetBaseMaxHealth(health)   
	unit:SetMaxHealth(health)
	unit:SetHealth(health)
	unit:SetBaseDamageMax(damage)
    unit:SetBaseDamageMin(damage)
end

--index 光环数量
function MonsterOperate:OnAddAbility(unit, index)
    --随机分配技能光环
    local random1 = RandomInt(1,#operate_ability)
    local random2 = random1 + 1
    if random1 == 5 then
        random2 = 1
    end
    local abilityName1 = operate_ability[random1]
    local abilityName2 = operate_ability[random2]

    local Ability1= unit:AddAbility(abilityName1)
    Ability1:SetLevel(1)

    if index == 2 then
        local Ability2= unit:AddAbility(abilityName2)
        Ability2:SetLevel(1)
    end
end

function MonsterOperate:OnKillOperateMonster(event)
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    if killedUnit:GetUnitName() == "create_operate_challenge_monster" then
        local operateInfo = CustomNetTables:GetTableValue( "gameInfo", "operate" )
        if killedUnit.operateID then
            local PlayerID = tonumber(killedUnit.operateID)
            local index = tonumber(killedUnit.operateIndex)
            for k,v in pairs(operateInfo) do
                if tonumber(k) == PlayerID then
                    if index == 1 then
                        v.operate_1 = v.operate_1 + 1
                    elseif index == 2 then
                        v.operate_2 = v.operate_2 + 1
                    elseif index == 3 then
                        v.operate_3 = v.operate_3 + 1
                    elseif index == 4 then
                        v.operate_4 = v.operate_4 + 1
                    elseif index == 5 then
                        v.operate_5 = v.operate_5 + 1
                    elseif index == 6 then
                        v.operate_6 = v.operate_6 + 1
                    elseif index == 7 then
                        v.operate_7 = v.operate_7 + 1
                    elseif index == 8 then
                        v.operate_8 = v.operate_8 + 1
                    end
                    v.operate_gold = v.operate_1*200 + v.operate_2*225 + v.operate_3*225 + v.operate_4*250 + v.operate_5*250 + v.operate_6*275 + v.operate_7*2750 + v.operate_8*3000

                    CustomNetTables:SetTableValue( "gameInfo", "operate", operateInfo)
                end
            end
        end
    end
end

function MonsterOperate:operateReward()
    local operateInfo = CustomNetTables:GetTableValue( "gameInfo", "operate" )
    for k,v in pairs(operateInfo) do
        local steam_id = PlayerResource:GetSteamAccountID(tonumber(k))
        if steam_id ~= 0 then
            local PlayerID = tonumber(k)
            local nPlayer = PlayerResource:GetPlayer(PlayerID)

            if nPlayer ~= nil then
                local aHero = nPlayer:GetAssignedHero()
                --金币
                local gold = v.operate_gold * GlobalVarFunc.InvestmentAndOperate[PlayerID+1] * GlobalVarFunc.OperateRewardCoefficient[PlayerID+1]
               
                PlayerResource:ModifyGold(PlayerID,gold,true,DOTA_ModifyGold_Unspecified)
                send_tips_message(PlayerID, "获得回合收入"..gold.."金币！")

                --木头
                -- local wood = v.operate_gold * GlobalVarFunc.InvestmentAndOperate[PlayerID+1] * GlobalVarFunc.OperateRewardCoefficient[PlayerID+1]
                -- Player_Data:AddPoint(PlayerID,wood)
                -- send_tips_message(PlayerID, "获得回合收入"..wood.."木材！")
            end
        end
    end
end
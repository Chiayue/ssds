local spawner_config = require("monster/monster_config")

function CAddonTemplateGameMode:OnEntityKill(event) 
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    if killedUnit:GetName() == "npc_dota_creature" then 

        --无尽 boss
        if killedUnit:GetContext("boss") then
            if GlobalVarFunc.game_mode == "endless" then

                GlobalVarFunc.endless_boss_isAlive = false 
                --无尽存档装备掉落
                self:OnBossCreatedSeriesItem()

                if GlobalVarFunc.game_type == 1000 and GlobalVarFunc.MonsterWave >= 700 then
                    self:OnGoodguysWinner()
                end

                --深渊击杀boss进入下一波
                if GlobalVarFunc.game_type == 1002 then
                    if GlobalVarFunc.MonsterWave == 10 then
                        self:OnGoodguysWinner()
                    else
                        GlobalVarFunc.abyss_spawn_state = false
                        MobSpawner:SpawnAbyssNextWave()
                    end
                end
                
            else
                --停止boss音效
                GlobalVarFunc:OnStopBossSound()
            end
        end

        spawner_config.monsterTable[tostring(event.entindex_killed)] = nil

        if GlobalVarFunc.game_mode == "common" then
            self:IsGoodguysWinner()
        end

        --创建宝物书   杀怪掉落   第一本1/500   第二本1/2000   第三本1/5000
        if GlobalVarFunc.baowushu_num < 4 then
            self:OnCreatedBaoWuBook(killedUnit) 
        end    

        --铲子掉落
        self:OnCreatedChanZi(killedUnit)
    end

    if killedUnit:IsHero() then
        --判断英雄是否拥有不死圣杯
        if killedUnit:HasModifier("modifier_gem_busishengbei") then
            killedUnit:SetTimeUntilRespawn(0)
            return nil
        end
        
        self:IsBadguysWinner()

        local nPlayerID = killedUnit:GetPlayerID()
        local time = GlobalVarFunc.resurrectionTime[nPlayerID + 1]
        killedUnit:SetTimeUntilRespawn(time)
        GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("spawn_creep_think"), 
        function()
            if GameRules:IsGamePaused() then
                return 0.1
            end
            if time > 0 then
                time = time - 1
                return 1
            else
                if killedUnit:IsAlive() == false then
                    killedUnit:RespawnHero(true,true)
                end
                return nil
            end
        end, 0)  

    end
end

function CAddonTemplateGameMode:IsGoodguysWinner() 
    local count = 0
    for k,v in pairs(spawner_config.monsterTable) do 
        count = count +1
    end
    spawner_config.monsterNumber = count

    if (GlobalVarFunc.game_type==0) and (count == 0) and (spawner_config.mosterWave == 12) then
        self:OnGoodguysWinner()
    elseif (GlobalVarFunc.game_type==1) and (count == 0) and (spawner_config.mosterWave == 16) then
        self:OnGoodguysWinner()
    elseif (GlobalVarFunc.game_type>=2) and (count == 0) and (spawner_config.mosterWave == 20) then
        self:OnGoodguysWinner()
    end
end

function CAddonTemplateGameMode:IsBadguysWinner() 
    --遍历一下游戏内的英雄，如果全是死亡状态则游戏结束
    local allHeroList = HeroList:GetAllHeroes()
    for k, hero in pairs(allHeroList) do
        if (hero:IsIllusion() == false) then
            if hero:IsAlive() then
                return
            end
        end
    end
    --单个玩家死亡游戏不结束，多1条命
    if GlobalVarFunc.playersNum == 1 then
        if GlobalVarFunc.singlePlayerLife == 0 then
            self:OnSetBadguysWinner()
        else
            GlobalVarFunc.singlePlayerLife = GlobalVarFunc.singlePlayerLife - 1
        end
    else
        self:OnSetBadguysWinner()
    end
end

function CAddonTemplateGameMode:OnSetBadguysWinner()
     --判断是否游戏结束
     if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end
    --游戏结束进行玩家数据存档
    game_playerinfo:SaveData()
    --游戏结束类型
    GlobalVarFunc:OnGameOverState(-2)
    --指定夜宴队胜利
    GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
end

function CAddonTemplateGameMode:OnGoodguysWinner()
    --判断是否游戏结束
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end
    if GlobalVarFunc.game_mode == "common" then
        --玩家通关
        GlobalVarFunc.isClearance = true
    end
    --游戏结束进行玩家数据存档
    game_playerinfo:SaveData()
    --游戏结束类型
    GlobalVarFunc:OnGameOverState(GlobalVarFunc.game_type)
    --指定天辉队胜利
    GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
end

function CAddonTemplateGameMode:OnNPCSpawned(event)
    local npc = EntIndexToHScript(event.entindex)
    if npc:IsHero() then
		npc:AddNewModifier(nil, nil, "modifier_invulnerable", {duration = 2})
	end
end

--创建宝物书
function CAddonTemplateGameMode:OnCreatedBaoWuBook(unit)
    local position = unit:GetOrigin()

    local randNumMax = 3000
    if GlobalVarFunc.baowushu_num == 0 then
        randNumMax = 300
    elseif GlobalVarFunc.baowushu_num == 1 then
        randNumMax = 600
    elseif GlobalVarFunc.baowushu_num == 2 then
        randNumMax = 1200
    elseif GlobalVarFunc.baowushu_num == 3 then
        randNumMax = 2400
    end

    local randNum = RandomInt(1,randNumMax)
    if randNum == 1 then
        GlobalVarFunc.baowushu_num = GlobalVarFunc.baowushu_num + 1

        local newItem = CreateItem( "item_baoWu_book", nil, nil )
	    local drop = CreateItemOnPositionSync( position, newItem )
	    local dropTarget = position 
        newItem:LaunchLoot( false, 300, 0.75, dropTarget )
        --添加特效提示
        ParticleManager:CreateParticle("particles/diy_particles/treasuretips.vpcf", PATTACH_ABSORIGIN_FOLLOW,newItem:GetContainer())
        -- 发送minimap
        CustomGameEventManager:Send_ServerToAllClients("send_ping_minimap",{dropTarget = dropTarget})
        --宝物音效
        GlobalVarFunc:OnGameSound("baowubook_sound")
    end
end

--存档装备掉落
function CAddonTemplateGameMode:OnBossCreatedSeriesItem()

    if spawner_config.mosterWave>10 and spawner_config.mosterWave%10==0 then

        for nPlayerID = 0, MAX_PLAYER - 1 do
            local nPlayer = PlayerResource:GetPlayer(nPlayerID)
            if nPlayer ~= nil then
                local aHero = nPlayer:GetAssignedHero()
                local randNum = RandomInt(1,100)
                local probability = 0 
                if game_enum.nMoeNoviceCount > 0 then
                    probability = 2 * game_enum.nMoeNoviceCount
                end
                if spawner_config.mosterWave > 600 then
                    if randNum <= 10 then
                        SeriseSystem:CreateSeriesItemS2(aHero)      -- T4
                    else
                        SeriseSystem:CreateSeriesItem(aHero,4,1,3)      -- T3
                    end
                elseif spawner_config.mosterWave > 400 then
                    if randNum <= 5 then
                        SeriseSystem:CreateSeriesItemS2(aHero)      -- T4
                    else
                        SeriseSystem:CreateSeriesItem(aHero,4,1,3)      -- T3
                    end
                elseif spawner_config.mosterWave > 320 then
                    if spawner_config.mosterWave % 20 == 0 then
                        if randNum <= 5 then
                            SeriseSystem:CreateSeriesItemS2(aHero)      -- T4
                        else
                            SeriseSystem:CreateSeriesItem(aHero,4,1,3)      -- T3
                        end
                    end
                elseif spawner_config.mosterWave > 270 then
                    SeriseSystem:CreateSeriesItem(aHero,4,1,3)      -- T3
                elseif spawner_config.mosterWave >= 180 then
                    if randNum <= 50 then
                        SeriseSystem:CreateSeriesItem(aHero,4,1,3)      -- T3
                    else
                        SeriseSystem:CreateSeriesItem(aHero,3,1,2)      -- T2
                    end
                elseif spawner_config.mosterWave >= 70 then
                    if randNum <= 40 then
                        SeriseSystem:CreateSeriesItem(aHero,4,1,3)      -- T3
                    else
                        SeriseSystem:CreateSeriesItem(aHero,3,1,2)      -- T2
                    end
                elseif spawner_config.mosterWave == 60 then
                    if randNum <= 30 then
                        SeriseSystem:CreateSeriesItem(aHero,4,1,3)      -- T3
                    else
                        SeriseSystem:CreateSeriesItem(aHero,3,1,2)      -- T2
                    end
                elseif spawner_config.mosterWave == 50 then
                    if randNum <= 20 then
                        SeriseSystem:CreateSeriesItem(aHero,4,1,3)      -- T3
                    else
                        SeriseSystem:CreateSeriesItem(aHero,3,1,2)      -- T2
                    end
                elseif spawner_config.mosterWave == 40 then 
                    if randNum <= 10 then
                        SeriseSystem:CreateSeriesItem(aHero,4,1,3)      -- T3
                    elseif randNum <= 50 then
                        SeriseSystem:CreateSeriesItem(aHero,3,1,2)        -- T2
                    else
                        SeriseSystem:CreateSeriesItem(aHero,2,1,1)        -- T1
                    end
                elseif spawner_config.mosterWave == 30 then
                    if randNum <= 20 then
                        SeriseSystem:CreateSeriesItem(aHero,3,1,2)       -- T2
                    else
                        SeriseSystem:CreateSeriesItem(aHero,2,1,1)       -- T1
                    end
                elseif spawner_config.mosterWave == 20 then
                    SeriseSystem:CreateSeriesItem(aHero,2,1,1)         -- T1
                end

                --新手额外金装爆率
                if spawner_config.mosterWave >= 100  then
                    if randNum <= probability then
                        SeriseSystem:CreateSeriesItem(aHero,4,1,3)      -- T3
                    end
                end
    
                --无尽装备存档
                Archive:SaveServerEqui(nPlayerID)
            end
        end

    end
end

--铲子掉落
function CAddonTemplateGameMode:OnCreatedChanZi(unit)
    if (spawner_config.mosterWave >= 5) and (GlobalVarFunc.game_type == 1003) then
        local position = unit:GetOrigin()
        local randNum = RandomInt(1,100)
        if unit:GetContext("boss") then
            if spawner_config.mosterWave >= 100 then
                if randNum <= 20 then
                    GlobalVarFunc:OnCreateChanzi(position,"item_gold_spade_fragment")
                end
            elseif spawner_config.mosterWave >= 10 then
                if randNum <= 10 then
                    GlobalVarFunc:OnCreateChanzi(position,"item_gold_spade_fragment")
                end
            end
        else
            if randNum <= 1 then
                GlobalVarFunc:OnCreateChanzi(position,"item_silver_spade_fragment")
            end
        end
    end

end

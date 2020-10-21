require("info/game_playerinfo")
require("gameMode/game_mode")
require("monster/monster_ability")
require("monster/monster_operate")
require("randomEvents/random_events")

local spawner_config = require("monster/monster_config")

if MobSpawner == nil then
    MobSpawner = class({})
end
-- 启动刷怪逻辑
function MobSpawner:Start()
    print("MobSpawner:Start")

    --挂机模式
    CustomGameEventManager:RegisterListener("guajimoshi", self.OnJieShuGuaji)

    --萝莉跳舞
    CustomGameEventManager:RegisterListener("luoli_tiaowu", self.OnLuoliTiaoWu)

    GameRules:GetGameModeEntity():SetThink("OnThink", self)  --GetGameModeEntity()设置游戏模型实体
end

-- 每1秒判断一次，时间到了就刷怪，然后想要停止这个 Thinker只需要return nil
function MobSpawner:OnThink()

    --判断是否暂停游戏
    if GameRules:IsGamePaused() then
        return 0.01
    end
    --判断是否游戏结束
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end

    local now = GameRules:GetDOTATime(false, false)  --返回Dota游戏内的时间。（是否包含赛前时间或负时间)
    now = math.floor(now)

    --创建地图logo 和 萝莉
    if now == 1 then
        self:OnCreateArcherLogo()

        self:OnCreaterLuoLi()
    end

    --10分钟存一次档
    MobSpawner:OnGameTimeSave(now)

    --挂机模式
    if GlobalVarFunc.game_type==-2 and now ~= 0 then

        --创建木桩
        MobSpawner:OnCreateMuZhuang()
        --挂机模式下每分钟给英雄增加1点经验,1个金币 
        MobSpawner:OnAddExperience(now)

    --每周自闭模式
    elseif GlobalVarFunc.game_type==1001 then

        --判断是否刷池子怪
        MobSpawner:OnNowTotalMonsterNum()
        --剩余野怪数量
        MobSpawner:totalMonsterNum()
        --无尽模式
        self:OnGameModeEndless(now)

    --深渊模式
    elseif GlobalVarFunc.game_type==1002 then

    else
        --判断是否刷池子怪
        MobSpawner:OnNowTotalMonsterNum()
    
        --剩余野怪数量
        MobSpawner:totalMonsterNum()
        
        --判断当前游戏模式
        if GlobalVarFunc.game_type~=1000 then
            --普通模式
            self:OnGameModeNormal(now)
        else
            --无尽模式
            self:OnGameModeEndless(now)
        end
    
    end

    return 1
end

--普通模式
function MobSpawner:OnGameModeNormal(now)
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        if spawner_config.mosterWave <= 20 then
            --序章游戏准备时间为30秒
            if GlobalVarFunc.game_type==0 then
                self:OnNextMonTimeXu()
            else
                self:OnNextMonTime()
            end
        end 
    end

    --序章游戏准备时间为30秒
    if GlobalVarFunc.game_type==0 then
        if now >= spawner_config.spawn_xu_time then
            spawner_config.spawn_xu_time = spawner_config.spawn_interval_time + spawner_config.spawn_xu_time
            self:SpawnNextWave()
        end
    else
        if now >= spawner_config.spawn_start_time then
            spawner_config.spawn_start_time = spawner_config.spawn_interval_time + spawner_config.spawn_start_time
            if spawner_config.mosterWave < 20 then
                self:SpawnNextWave()
            end 
        end
    end

end

--无尽模式
function MobSpawner:OnGameModeEndless(now)
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        --准备阶段时间
        self:OnEndlessNextMonTime1() 
    end
    
    if now > spawner_config.spawn_start_time then
        if not GlobalVarFunc.endless_boss_isAlive then
            if GlobalVarFunc.suspend > 0 then
                GlobalVarFunc.suspend = GlobalVarFunc.suspend - 1
            else
                self:SpawnNextWave()
                GlobalVarFunc.suspend = 1

                if spawner_config.mosterWave ~= 1 then
                    if spawner_config.mosterWave > 50 then
                        spawner_config.spawn_interval_endless_time_tips = spawner_config.spawn_interval_endless_time_tips + 0
                    elseif spawner_config.mosterWave > 20 then
                        spawner_config.spawn_interval_endless_time_tips = spawner_config.spawn_interval_endless_time_tips + 30
                    else
                        spawner_config.spawn_interval_endless_time_tips = spawner_config.spawn_interval_endless_time_tips + 60
                    end
                end
            end
        
        end 
        self:OnEndlessNextMonTime2()
        
    end

end

-- 下一波
function MobSpawner:SpawnNextWave()
    
    if GlobalVarFunc.playersNum == 0 then
        print("player is 0")
        return 
    end

    spawner_config.mosterWave = spawner_config.mosterWave + 1
    GlobalVarFunc.MonsterWave = spawner_config.mosterWave

    --野怪提示动画
    self:OnTipsAnimation()

    --运营奖励
    MonsterOperate():operateReward()
    
    --打开竞技场
    GlobalVarFunc:OnOpenDoor()
    
    --每周自闭模式
    if GlobalVarFunc.game_type==1001 then
        --野怪池子的数量
        spawner_config.monsterSurplusNum = 800
        GlobalVarFunc.monsterIsShuaMan = false

        --25波之后不刷小兵
        if spawner_config.mosterWave <= 25 then
            self:OnWeeklySpawnMonsterEndless()
        end
        
        self:OnWeeklySpawnBossEndless()

    elseif GlobalVarFunc.game_type~=1000 then
        --开始随机事件
        RandomEvents():Start()

        if spawner_config.mosterWave > 20 then 
            return 
        end
    
        self:SpawnMonster()
        if spawner_config.mosterWave%4 == 0 then 
            self:SpawnBoss()
        end

        --野怪池子的数量
        spawner_config.monsterSurplusNum = 56
        GlobalVarFunc.monsterIsShuaMan = false
    else

        --野怪池子的数量
        spawner_config.monsterSurplusNum = 800
        GlobalVarFunc.monsterIsShuaMan = false

        --25波之后不刷小兵
        if spawner_config.mosterWave <= 25 then
            self:SpawnMonsterEndless()
        end
        
        self:SpawnBossEndless()
    end

    --更新gameInfo网表信息
    GameMode:UpdateGameInfoNetTable({gameMode = GlobalVarFunc.game_mode, gameType = GlobalVarFunc.game_type, gameWaves = spawner_config.mosterWave})

end

--序章普通模式刷怪时间提示
function MobSpawner:OnNextMonTimeXu()
    --判断是否暂停游戏
    if GameRules:IsGamePaused() then
        return 0.01
    end

    if spawner_config.spawn_start_state and (not spawner_config.spawn_next_state) and spawner_config.spawn_xu_time_tips>0 then 
        CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_xu_time_tips;maxTime=spawner_config.spawn_interval_time;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
        spawner_config.spawn_xu_time_tips = spawner_config.spawn_xu_time_tips-1
    else
        spawner_config.spawn_xu_time_tips = spawner_config.spawn_xu_time
        spawner_config.spawn_start_state = false
        spawner_config.spawn_next_state = true
    end
    
    if spawner_config.spawn_next_state and (not spawner_config.spawn_start_state) and spawner_config.spawn_interval_time_tips>0 then 
        CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_interval_time_tips;maxTime=spawner_config.spawn_interval_time;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
        --倒计时10秒，显示UI提示
        if spawner_config.spawn_interval_time_tips <= 10 and spawner_config.monsterNumber > 0 then
            CustomGameEventManager:Send_ServerToAllClients("monsterNum_time_count_down",{time=spawner_config.spawn_interval_time_tips;isShow=1})

            -- if spawner_config.spawn_interval_time_tips > 1 then
            --     --倒计时音效
            --     GlobalVarFunc:OnGameSound("miaojishi_sound")
            -- else
            --     --siwang音效
            --     GlobalVarFunc:OnGameSound("siwang_sound")
            -- end
            
        else
            CustomGameEventManager:Send_ServerToAllClients("monsterNum_time_count_down",{time=0;isShow=0})
        end

        spawner_config.spawn_interval_time_tips = spawner_config.spawn_interval_time_tips-1
    else
        if spawner_config.spawn_interval_time_tips == 0 then
            
            --野怪没清完将失败
            if spawner_config.monsterNumber > 0 then
                self:OnGameOver()
                return nil 
            end
            CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_interval_time_tips;maxTime=spawner_config.spawn_interval_time;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
            
        end
        spawner_config.spawn_interval_time_tips = spawner_config.spawn_interval_time-1   --游戏每次运行到else后会耗费1秒来赋值
    end

end

--普通模式刷怪时间提示
function MobSpawner:OnNextMonTime()
    --判断是否暂停游戏
    if GameRules:IsGamePaused() then
        return 0.01
    end

    if spawner_config.spawn_start_state and (not spawner_config.spawn_next_state) and spawner_config.spawn_start_time_tips>0 then 
        CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_start_time_tips;maxTime=spawner_config.spawn_interval_time;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
        spawner_config.spawn_start_time_tips = spawner_config.spawn_start_time_tips-1
    else
        spawner_config.spawn_start_time_tips = spawner_config.spawn_start_time
        spawner_config.spawn_start_state = false
        spawner_config.spawn_next_state = true
    end
    
    if spawner_config.spawn_next_state and (not spawner_config.spawn_start_state) and spawner_config.spawn_interval_time_tips>0 then 
        CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_interval_time_tips;maxTime=spawner_config.spawn_interval_time;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
        --倒计时10秒，显示UI提示
        if spawner_config.spawn_interval_time_tips <= 10 and spawner_config.monsterNumber > 0 then
            CustomGameEventManager:Send_ServerToAllClients("monsterNum_time_count_down",{time=spawner_config.spawn_interval_time_tips;isShow=1})

            -- if spawner_config.spawn_interval_time_tips > 1 then
            --     --倒计时音效
            --     GlobalVarFunc:OnGameSound("miaojishi_sound")
            -- else
            --     --siwang音效
            --     GlobalVarFunc:OnGameSound("siwang_sound")
            -- end

        else
            CustomGameEventManager:Send_ServerToAllClients("monsterNum_time_count_down",{time=0;isShow=0})
        end

        spawner_config.spawn_interval_time_tips = spawner_config.spawn_interval_time_tips-1
    else
        if spawner_config.spawn_interval_time_tips == 0 then
            CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_interval_time_tips;maxTime=spawner_config.spawn_interval_time;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
            
            --野怪没清完将失败
            if spawner_config.monsterNumber > 0 then
                self:OnGameOver()
                return nil
            end
        end
        spawner_config.spawn_interval_time_tips = spawner_config.spawn_interval_time-1   --游戏每次运行到else后会耗费1秒来赋值
    end

end

--无尽模式未刷怪阶段时间提示
function MobSpawner:OnEndlessNextMonTime1()
    --判断是否暂停游戏
    if GameRules:IsGamePaused() then
        return 0.01
    end

    if spawner_config.spawn_start_state and (not spawner_config.spawn_next_state) and spawner_config.spawn_start_time_tips>0 then 
        CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_start_time_tips;maxTime=spawner_config.spawn_interval_endless_time;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
        spawner_config.spawn_start_time_tips = spawner_config.spawn_start_time_tips-1
    else
        spawner_config.spawn_start_time_tips = spawner_config.spawn_start_time
        spawner_config.spawn_start_state = false
        spawner_config.spawn_next_state = true
    end

end

--无尽模式以及刷怪阶段时间提示
function MobSpawner:OnEndlessNextMonTime2()
    --判断是否暂停游戏
    if GameRules:IsGamePaused() then
        return 0.01
    end

    if spawner_config.spawn_next_state and (not spawner_config.spawn_start_state) and spawner_config.spawn_interval_endless_time_tips>0 then 
        CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_interval_endless_time_tips;maxTime=spawner_config.spawn_interval_endless_time;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})

        --倒计时10秒，显示UI提示
        if spawner_config.spawn_interval_endless_time_tips <= 10 then
            CustomGameEventManager:Send_ServerToAllClients("monsterNum_time_count_down",{time=spawner_config.spawn_interval_endless_time_tips;isShow=1})
        else
            CustomGameEventManager:Send_ServerToAllClients("monsterNum_time_count_down",{time=0;isShow=0})
        end

        spawner_config.spawn_interval_endless_time_tips = spawner_config.spawn_interval_endless_time_tips-1
    else
        if spawner_config.spawn_interval_endless_time_tips == 0 then
            --游戏时间为0，判定游戏结束
            self:OnGameOver()
            return nil
        end
    end

end

-- 普通小怪
function MobSpawner:SpawnMonster()

    --随机分配野怪技能
    local ability = self:_addAbility()

    --小兵模型
    local wave_info_waves = spawner_config.waves
    local count = 0
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("spawn_creep_think"), 
    function()
        
        --判断是否暂停游戏
        if GameRules:IsGamePaused() then
            return 0.01
        end

        --判断是否游戏结束
        if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
            return nil
        end

        local position = Vector(0, 0, 0) + RandomVector( RandomFloat( 1000, 4500 ))
        local path_ok =  GridNav:CanFindPath(position, Vector(1000, 0, 0))
        --判断是否能从某个起始点移动到某个终点
        if not path_ok then
            position = Vector(1000, 0, 0)
        end
        local monster_name = wave_info_waves.name..spawner_config.mosterWave
        -- 创建单位 
        local mob = CreateUnitByName(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)

        if spawner_config.mosterWave>=8 then
            mob:AddAbility(ability)
        end

        self:setMonsterBaseInformation(mob)

        spawner_config.monsterTable[tostring(mob:entindex())] = mob 
    
          -- 当前怪物计数
          count = count + 1
          -- 刷满退出
          if count < spawner_config.monsterNumMax then
              return 0.2
          else
              GlobalVarFunc.monsterIsShuaMan = true
              return nil
          end
          
    end, 0)
    
end

--普通boss
function MobSpawner:SpawnBoss()
    --boss音效
    GlobalVarFunc:OnRandomBossSound()

    --随机分配野怪技能
    local ability1 = self:_addAbility()
    local ability2 = self:_addAbility()

    local wave_info_boss = spawner_config.boss
    local bossname = wave_info_boss.name 

    local position = Vector(0, 0, 0) + RandomVector( RandomFloat( 4000, 4500 ))
    local path_ok =  GridNav:CanFindPath(position, Vector(1000, 0, 0))
    --判断是否能从某个起始点移动到某个终点
    if not path_ok then
        position = Vector(1000, 0, 0)
    end
    local monster_name = bossname..spawner_config.mosterWave
    local boss = CreateUnitByName(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    boss:AddAbility(ability1)
    if spawner_config.mosterWave>=12 then
        boss:AddAbility(ability2)
    end
    boss:SetContext("boss", "1", 0)
    self:setMonsterBaseInformation(boss)

    spawner_config.monsterTable[tostring(boss:entindex())] = boss    
    
end

-- 无尽模式刷Boss
function MobSpawner:SpawnBossEndless()
    --boss音效
    GlobalVarFunc:OnRandomBossSound()

    --随机分配野怪技能
    local ability1 = self:_addAbility()
    local ability2 = self:_addAbility()

    local wave_info_waves = spawner_config.boss
    local bossModel = spawner_config.mosterWave 
    if spawner_config.mosterWave <= 50 then 
        bossModel = spawner_config.mosterWave
    else
        if spawner_config.mosterWave%50==0 then 
            bossModel = 1
        else
            bossModel = spawner_config.mosterWave%50
        end
    end 
       
    local position = Vector(0, 0, 0) + RandomVector( RandomFloat( 2000, 3000 ))
    local path_ok =  GridNav:CanFindPath(position, Vector(1000, 0, 0))
    --判断是否能从某个起始点移动到某个终点
    if not path_ok then
        position = Vector(1000, 0, 0)
    end
    local boss_name = wave_info_waves.name..bossModel
    local boss = CreateUnitByName(boss_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    boss:AddAbility(ability1)
    if spawner_config.mosterWave>=12 then
        boss:AddAbility(ability2)
    end
    if spawner_config.mosterWave >= 90 then
        --减少伤技能
        local Ability3= boss:AddAbility("monster_jianshang")
        Ability3:SetLevel(1)
    end
    boss:SetContext("boss", "1", 0)
    self:setMonsterBaseInformation(boss)

    GlobalVarFunc.endless_boss_isAlive = true
    
    spawner_config.monsterTable[tostring(boss:entindex())] = boss

end

--无尽模式刷小兵
function MobSpawner:SpawnMonsterEndless()

    --随机分配野怪技能
    local ability = self:_addAbility()
   
    local count = 0
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("spawn_creep_think"), 
        function()
           
            --判断是否暂停游戏
            if GameRules:IsGamePaused() then
                return 0.01
            end

            --判断是否游戏结束
            if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
                return nil
            end

            --小兵模型
            local wave_info_waves = spawner_config.waves
            local model = spawner_config.mosterWave 
            if spawner_config.mosterWave <= 50 then 
                model = spawner_config.mosterWave
            else
                if spawner_config.mosterWave%50==0 then 
                    model = 1
                else
                    model = spawner_config.mosterWave%50
                end
            end 

            if GlobalVarFunc.endless_boss_isAlive then

                if spawner_config.monsterNumber >= spawner_config.monsterNumMax_endless then
                    return 0.2
                end

                local position = Vector(0, 0, 0) + RandomVector( RandomFloat( 1000, 4500 ))

                local path_ok =  GridNav:CanFindPath(position, Vector(1000, 0, 0))
                --判断是否能从某个起始点移动到某个终点
                if not path_ok then
                    position = Vector(1000, 0, 0)
                end

                local monster_name = wave_info_waves.name..model
                -- 创建单位 
                local mob = CreateUnitByName(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
                if spawner_config.mosterWave>=8 then
                    mob:AddAbility(ability)
                end
                self:setMonsterBaseInformation(mob)
    
                spawner_config.monsterTable[tostring(mob:entindex())] = mob 
        
                -- 当前怪物计数
                count = count + 1
                -- 刷满退出
                if count < spawner_config.monsterNumMax_endless then
                    return 0.2
                else
                    GlobalVarFunc.monsterIsShuaMan = true
                    return nil
                end
            else
                return nil
            end
             
       end, 0)    
end

--每周自闭模式刷小兵
function MobSpawner:OnWeeklySpawnMonsterEndless()

    --随机分配野怪技能
    local ability = self:_addAbility()
   
    local count = 0
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("spawn_creep_think"), 
        function()
           
            --判断是否暂停游戏
            if GameRules:IsGamePaused() then
                return 0.01
            end

            --判断是否游戏结束
            if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
                return nil
            end

            --小兵模型
            local wave_info_waves = spawner_config.waves
            local model = spawner_config.mosterWave 
            if spawner_config.mosterWave <= 50 then 
                model = spawner_config.mosterWave
            else
                if spawner_config.mosterWave%50==0 then 
                    model = 1
                else
                    model = spawner_config.mosterWave%50
                end
            end 

            if GlobalVarFunc.endless_boss_isAlive then

                if spawner_config.monsterNumber >= spawner_config.monsterNumMax_endless then
                    return 0.2
                end

                local position = Vector(0, 0, 0) + RandomVector( RandomFloat( 1000, 4500 ))

                local path_ok =  GridNav:CanFindPath(position, Vector(1000, 0, 0))
                --判断是否能从某个起始点移动到某个终点
                if not path_ok then
                    position = Vector(1000, 0, 0)
                end

                local monster_name = wave_info_waves.name..model
                -- 创建单位 
                local mob = CreateUnitByName(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
                if spawner_config.mosterWave>=8 then
                    mob:AddAbility(ability)
                end

                --增加移动速度
                mob:AddAbility("ability_zibi")
                --设置该生物每级增加的控制抗性 
                mob:SetDisableResistanceGain(100)

                self:setMonsterBaseInformation(mob)
    
                spawner_config.monsterTable[tostring(mob:entindex())] = mob 
        
                -- 当前怪物计数
                count = count + 1
                -- 刷满退出
                if count < spawner_config.monsterNumMax_endless then
                    return 0.2
                else
                    GlobalVarFunc.monsterIsShuaMan = true
                    return nil
                end
            else
                return nil
            end
             
       end, 0)    
end

-- 每周自闭模式刷Boss
function MobSpawner:OnWeeklySpawnBossEndless()
    --boss音效
    GlobalVarFunc:OnRandomBossSound()

    --随机分配野怪技能
    local ability1 = self:_addAbility()
    local ability2 = self:_addAbility()

    local wave_info_waves = spawner_config.boss
    local bossModel = spawner_config.mosterWave 
    if spawner_config.mosterWave <= 50 then 
        bossModel = spawner_config.mosterWave
    else
        if spawner_config.mosterWave%50==0 then 
            bossModel = 1
        else
            bossModel = spawner_config.mosterWave%50
        end
    end 
       
    local position = Vector(0, 0, 0) + RandomVector( RandomFloat( 2000, 3000 ))
    local path_ok =  GridNav:CanFindPath(position, Vector(1000, 0, 0))
    --判断是否能从某个起始点移动到某个终点
    if not path_ok then
        position = Vector(1000, 0, 0)
    end
    local boss_name = wave_info_waves.name..bossModel
    local boss = CreateUnitByName(boss_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    boss:AddAbility(ability1)
    if spawner_config.mosterWave>=12 then
        boss:AddAbility(ability2)
    end
    if spawner_config.mosterWave >= 90 then
        --减少伤技能
        local Ability3= boss:AddAbility("monster_jianshang")
        Ability3:SetLevel(1)
    end

    --增加移动速度
    boss:AddAbility("ability_zibi_boss")
    --设置该生物每级增加的控制抗性 
    boss:SetDisableResistanceGain(100)

    boss:SetContext("boss", "1", 0)
    self:setMonsterBaseInformation(boss)

    GlobalVarFunc.endless_boss_isAlive = true
    
    spawner_config.monsterTable[tostring(boss:entindex())] = boss

end

-- 刷怪物池子里的小怪
function MobSpawner:OnSpawnMonster()

    --随机分配野怪技能
    local ability = self:_addAbility()

    --小兵模型
    local wave_info_waves = spawner_config.waves
    local model = spawner_config.mosterWave 
    if spawner_config.mosterWave <= 50 then 
        model = spawner_config.mosterWave
    else
        if spawner_config.mosterWave%50==0 then 
            model = 1
        else
            model = spawner_config.mosterWave%50
        end
    end 

    local position = Vector(0, 0, 0) + RandomVector( RandomFloat( 2000, 3000 ))
    local path_ok =  GridNav:CanFindPath(position, Vector(1000, 0, 0))
    --判断是否能从某个起始点移动到某个终点
    if not path_ok then
        position = Vector(1000, 0, 0)
    end
    local monster_name = wave_info_waves.name..model
    -- 创建单位 
    local mob = CreateUnitByName(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)

    if spawner_config.mosterWave>=8 then
        mob:AddAbility(ability)
    end

    if GlobalVarFunc.game_type == 1001 then
        --增加移动速度
        mob:AddAbility("ability_zibi")
        --设置该生物每级增加的控制抗性 
        mob:SetDisableResistanceGain(100)
    end

    self:setMonsterBaseInformation(mob)

    spawner_config.monsterTable[tostring(mob:entindex())] = mob 
end

--设置怪物基本属性
function MobSpawner:setMonsterBaseInformation(unit)
    local health = self:_Health()
    local healthRegen = self:_HealthRegen()
    local attack = self:_AttackDamage()
    local armor = self:_Armor()
    local magicalResistance = self:_MagicalResistance()
    local xp = self:_DeathXP()
    local gold = self:_DeathGold()

    if unit:GetContext("boss") then  
        health = health*15
        attack = attack*5
        xp = xp*5
        gold = gold*5

        if GlobalVarFunc.playersNum~=0 then
            health = health*(GlobalVarFunc.playersNum*0.5+0.5)
        end
    end

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

--野怪攻击力
function MobSpawner:_AttackDamage()
    local attack = ((spawner_config.mosterWave-1)*(spawner_config.mosterWave-1)*20+30)*(GlobalVarFunc.duliuLevel*0.05 + 1) * GlobalVarFunc.MonsterViolent
    if GlobalVarFunc.game_mode == "common" then
        return attack * (GlobalVarFunc.game_type*0.3+0.5)
    else
        if spawner_config.mosterWave > 20 then
            return attack * 6
        else
            return attack * 2
        end
    end
end

function MobSpawner:_Health() 
    local health =((spawner_config.mosterWave-1)*(spawner_config.mosterWave-1)*(spawner_config.mosterWave-1)*35+30)
    if spawner_config.mosterWave>=20 then
        health = health *10
    elseif spawner_config.mosterWave >=16 then
        health = health *5
    elseif spawner_config.mosterWave >=12 then
        health = health *2
    end

    if GlobalVarFunc.game_mode == "common" then
        return health * (GlobalVarFunc.game_type*0.3+0.5)
    else
        if spawner_config.mosterWave > 20 then
            return health * 2 * 0.1
        else
            return health * 2 
        end
    end
end

function MobSpawner:_HealthRegen() 
    return 0
end

function MobSpawner:_DeathXP() 
    return spawner_config.mosterWave*3 + 15
end

function MobSpawner:_DeathGold() 
    return 12
end

function MobSpawner:_Armor() 
    if GlobalVarFunc.game_mode == "common" then
        return spawner_config.mosterWave
    else
        if spawner_config.mosterWave>69 then
            return 400
        elseif spawner_config.mosterWave>39 then
            return 146
        elseif spawner_config.mosterWave>20 then
            return 68
        else
            return spawner_config.mosterWave
        end
    end
end

function MobSpawner:_MagicalResistance() 
    if spawner_config.mosterWave <= 20 then
        return spawner_config.mosterWave * 2
    elseif spawner_config.mosterWave < 40 then
        return 80
    elseif spawner_config.mosterWave < 69 then
        return 90
    else
        return 94
    end
end

function MobSpawner:_addAbility()
    --随机分配野怪技能
    local random = RandomInt(1,#monster_ability)
    local abilityName =  monster_ability[random]
    return abilityName
end

--当前野怪计数
function MobSpawner:totalMonsterNum()
    local count = 0
    for k,v in pairs(spawner_config.monsterTable) do 
        count = count +1
    end
    spawner_config.monsterNumber = count
end

--根据场上野怪数量来刷池子里的怪
function MobSpawner:OnNowTotalMonsterNum()
    if GlobalVarFunc.monsterIsShuaMan then

        if GlobalVarFunc.game_mode == "common" then
            if spawner_config.monsterNumber < spawner_config.monsterNumMax and spawner_config.monsterSurplusNum > 0 then
                for i=1,2 do
                    self:OnSpawnMonster()
                    spawner_config.monsterSurplusNum = spawner_config.monsterSurplusNum - 1;
                end
            end
        else
            if spawner_config.monsterNumber < spawner_config.monsterNumMax_endless and spawner_config.monsterSurplusNum > 0 then
                for i=1,5 do
                    self:OnSpawnMonster()
                    spawner_config.monsterSurplusNum = spawner_config.monsterSurplusNum - 1;
                end
            end
        end
        
    end
end

--设置野怪仇恨
function MobSpawner:OnSetForceAttackTarget(unit)

    local killMaxNum = 0
    local killMaxPlayerID = 0

    local nData_score = CustomNetTables:GetTableValue( "player_data", "score" )

    for k,v in pairs(nData_score) do
        local PlayerID = tonumber(k)
        local steam_id = PlayerResource:GetSteamAccountID(PlayerID)
        if steam_id ~= 0 then

            local kill = tonumber(v.Kills)
            if kill > killMaxNum then
                killMaxNum = kill
                killMaxPlayerID = PlayerID
            end

        end
    end

    local hHero = PlayerResource:GetSelectedHeroEntity(killMaxPlayerID)

    unit:SetForceAttackTarget(hHero)

    Timer(10, function()
        if unit == nil then               --当这个怪被击杀了，找不到这个单位，此时单位类型是none
            return
        end
        unit:SetForceAttackTarget(nil)
    end)

end

--游戏失败判定 
function MobSpawner:OnGameOver()
    print("Game defeated")
    --判断是否游戏结束
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end
    --游戏结束进行玩家数据存档
    game_playerinfo:SaveData()
    --游戏结束类型
    GlobalVarFunc:OnGameOverState(-1)
    --指定夜宴队胜利
    GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
end

--野怪提示动画
function MobSpawner:OnTipsAnimation()

    local animate_name = ""
    if spawner_config.mosterWave == 1 then
        animate_name = "monster1"
    elseif spawner_config.mosterWave == 4 then
        animate_name = "boss4"
    elseif spawner_config.mosterWave == 8 then
        animate_name = "boss8"
    elseif spawner_config.mosterWave == 12 then
        animate_name = "boss12"
    elseif spawner_config.mosterWave == 16 then
        animate_name = "boss16"
    elseif spawner_config.mosterWave == 20 then
        animate_name = "boss20"
    else
        return
    end
    
    CustomGameEventManager:Send_ServerToAllClients("challenge_event_tip",{event_name=animate_name})
end

--创建地图logo
function MobSpawner:OnCreateArcherLogo()
    local name = "npc_dota_creature_shibei"
    local position = Vector(-268.315, -1286.22, 128)
    local shibei = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    shibei:AddNewModifier(nil, nil, "modifier_invulnerable", {})
    CustomGameEventManager:Send_ServerToAllClients("shibei_index",{index=shibei:entindex()})
end

--结束挂机
function MobSpawner:OnJieShuGuaji(data)
    --避免观战玩家搞事情
    local hHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
    if hHero ~= nil then
        MobSpawner:OnGameOver()
    end
end

--游戏时间10分钟存一次档
function MobSpawner:OnGameTimeSave(time)
    time = math.floor(time)
    if (time ~= 0) and (time%600 == 0) then
        for i = 0 , MAX_PLAYER - 1 do
            local steam_id = PlayerResource:GetSteamAccountID(i)
            if steam_id ~= 0 then
                --掉线玩家处理
                local nPlayer = PlayerResource:GetPlayer(i)
                if nPlayer ~= nil then
                    --国庆50%的地图经验奖励
                    local game_time = time + Archive:GetData(i,"game_time")
                    --时间数据存档
                    local hRows = {}
                    hRows["game_time"] = game_time
                    Archive:SaveRowsToPlayer(i, hRows)
                end
            end
        end
    end
end

--创建木桩
function MobSpawner:OnCreateMuZhuang()
    if GlobalVarFunc.isCreateMuZhuang == false then
        local name = "npc_dota_creature_stake"
        local position = Vector(-268.315, -1500, 128)
        local muzhuang = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
        GlobalVarFunc.isCreateMuZhuang = true
    end
end

--挂机模式下每分钟给英雄增加1点经验,1个金币   
function MobSpawner:OnAddExperience(time)
    time = math.floor(time)
    if (time ~= 0) and (time%60 == 0) then
        for i = 0 , MAX_PLAYER - 1 do
            local steam_id = PlayerResource:GetSteamAccountID(i)
            if steam_id ~= 0 then
                --掉线玩家处理
                local nPlayer = PlayerResource:GetPlayer(i)
                if nPlayer ~= nil then
                    local hHero = PlayerResource:GetSelectedHeroEntity(i)
                    hHero:AddExperience(1, 1, false, false)

                    PlayerResource:ModifyGold(i,1,true,DOTA_ModifyGold_Unspecified)
                    PopupGoldGain(hHero, 1)
                end
            end
        end
    end
end

--创建萝莉单位
function MobSpawner:OnCreaterLuoLi()
    local name = "npc_dota_creature_luoli"
    local position = Vector(5400, -4800, 0)
    GlobalVarFunc.Luoli = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    GlobalVarFunc.Luoli:AddNewModifier(nil, nil, "modifier_invulnerable", {})
    -- --旋转萝莉角度方法1
    -- local vStartPosition = luoli:GetOrigin()
    -- local vTargetPosition = vStartPosition + luoli:GetForwardVector() * 100
    -- vTargetPosition = RotatePosition(vStartPosition, QAngle(0,270, 0), vTargetPosition)
    -- luoli:SetForwardVector(vTargetPosition)
    -- --旋转萝莉角度方法2
    -- local face_position = GlobalVarFunc.Luoli:GetOrigin()
    -- face_position.y = face_position.y - 180
    -- GlobalVarFunc.Luoli:FaceTowards(face_position)
    -- GlobalVarFunc.Luoli:StartGesture(ACT_DOTA_IDLE)

    CustomGameEventManager:Send_ServerToAllClients("luoli_index",{index=GlobalVarFunc.Luoli:entindex()})

end

function MobSpawner:OnLuoliTiaoWu(args)

    local playerArrowSoulNum =  Store:GetData(args.PlayerID,"arrow_soul")
    if playerArrowSoulNum >= 888 then    --888

        -- GlobalVarFunc.Luoli:StartGesture(ACT_DOTA_WUDAO)
        GlobalVarFunc.Luoli:StartGesture(ACT_DOTA_CAST_ABILITY_1)

        EmitSoundOn("custom_music.luoli" ,GlobalVarFunc.Luoli)
        -- 消耗自定义货币 比如箭魂
        Store:UsedCustomGoodsValue(args.PlayerID,"arrow_soul",888,"萝莉跳舞")
        --萝莉跳舞冷却
        MobSpawner:OnCoolDown()
    else
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(args.PlayerID),"send_error_message_client",{message="箭魂不够"})
    end
end

--萝莉跳舞冷却
function MobSpawner:OnCoolDown()
    
    local time = 210
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("luoli_cool_down_think"), 
    function()
        if GameRules:IsGamePaused() then
            return 0.1
        end

        CustomGameEventManager:Send_ServerToAllClients("luoli_cool_down_time",{coolDownTime= time})

        if time > 0 then
            time = time - 1            
            return 1
        else
            return nil
        end
    end, 0)  
end
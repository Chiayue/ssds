require("monster/monster_ability")
require("monster/monster_abyss")

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

        --创建金矿
        MobSpawner:OnCreateGoldMonster()
    end

    --10分钟存一次档
    MobSpawner:OnGameTimeSave(now)

    --挂机模式
    if GlobalVarFunc.game_type==-2 and now ~= 0 then

        --创建木桩
        MobSpawner:OnCreateMuZhuang()
        --挂机模式下每分钟给英雄增加1点经验,1个金币 
        MobSpawner:OnAddExperience(now)

    --无尽模式
    elseif GlobalVarFunc.game_type==1000 then 

        if (now ~= 0) and (now%1500==0 or now%1920==0) then
            --创建商人
            Devil_Treasure_selected():OnCreateBusinessMan()
        end
        --判断是否刷池子怪
        MobSpawner:OnNowTotalMonsterNum()
        --剩余野怪数量
        MobSpawner:totalMonsterNum()
        --无尽模式
        self:OnGameModeEndless(now)

    --每周自闭模式     自闭PLUS模式
    elseif GlobalVarFunc.game_type==1001 or GlobalVarFunc.game_type == 1003 then

        --判断是否刷池子怪
        MobSpawner:OnNowTotalMonsterNum()
        --剩余野怪数量
        MobSpawner:totalMonsterNum()
        --无尽模式
        self:OnGameModeEndless(now)

    --深渊模式
    elseif GlobalVarFunc.game_type==1002 then
        --判断是否刷池子怪
        MobSpawner:OnNowTotalMonsterNum()
        --剩余野怪数量
        MobSpawner:totalMonsterNum()
        --深渊模式
        self:OnGameModeAbyss(now)

    --普通模式
    else

        --判断是否刷池子怪
        MobSpawner:OnNowTotalMonsterNum()
        --剩余野怪数量
        MobSpawner:totalMonsterNum()
        --普通模式
        self:OnGameModeNormal(now)
    
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

--深渊模式
function MobSpawner:OnGameModeAbyss(now)
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        self:OnAbyssNextMonTime()
    end

    if now == 10 then
        --深渊第一波
        MobSpawner:SpawnAbyssNextWave()
    end
    
    --深渊野怪属性层级  60秒层级加1
    GlobalVarFunc.abyss_monster_level =  math.floor(now/60) + 1
    
end

--深渊模式下一波
function MobSpawner:SpawnAbyssNextWave()

    if GlobalVarFunc.abyss_spawn_state then
        spawner_config.spawn_abyss_monster_time = spawner_config.spawn_abyss_boss_time
    else
        spawner_config.spawn_abyss_monster_time = 200
    end

    spawner_config.mosterWave = spawner_config.mosterWave + 1
    GlobalVarFunc.MonsterWave = spawner_config.mosterWave

    --野怪提示动画
    self:OnTipsAnimation()
    --运营奖励
    MonsterOperate():operateReward()
    --打开竞技场
    GlobalVarFunc:OnOpenDoor()

    --深渊模式
    if GlobalVarFunc.game_type==1002 then
        --野怪池子的数量
        spawner_config.monsterSurplusNum = 0
        GlobalVarFunc.monsterIsShuaMan = false
        --深渊模式刷小兵
        self:SpawnMonsterAbyss()
        --深渊模式刷boss
        self:SpawnBossAbyss()

        --深渊游戏环节
        MonsterExerciseRoom():OnAbyssGameLink()
    end

    --更新gameInfo网表信息
    GameMode:UpdateGameInfoNetTable({gameMode = GlobalVarFunc.game_mode, gameType = GlobalVarFunc.game_type, gameWaves = spawner_config.mosterWave})
end

--下一波
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

    
    --无尽模式
    if GlobalVarFunc.game_type==1000 then

        --野怪池子的数量
        spawner_config.monsterSurplusNum = 800
        GlobalVarFunc.monsterIsShuaMan = false

        if spawner_config.mosterWave == 51 and spawner_config.spawn_interval_endless_time_tips >= 1900 then
            self:OnCreatedCaiDanBoss1()
        end

        if spawner_config.mosterWave == 100 or spawner_config.mosterWave == 180 or spawner_config.mosterWave == 260 then
            self:OnCreatedCaiDanBoss2()
        end

        --25波之后不刷小兵
        if spawner_config.mosterWave <= 25 then
            self:SpawnMonsterEndless()
        end
        self:SpawnBossEndless()

    --每周自闭模式    自闭PLUS模式
    elseif GlobalVarFunc.game_type==1001 or GlobalVarFunc.game_type == 1003 then
        --野怪池子的数量
        spawner_config.monsterSurplusNum = 800
        GlobalVarFunc.monsterIsShuaMan = false

        --25波之后不刷小兵
        if spawner_config.mosterWave <= 25 then
            self:OnWeeklySpawnMonsterEndless()
        end
        self:OnWeeklySpawnBossEndless()

    --普通模式  
    else
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

    if (spawner_config.spawn_state == 0) and (spawner_config.spawn_xu_time_tips > 0) then 
        CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_xu_time_tips;gameType = GlobalVarFunc.game_type;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
        spawner_config.spawn_xu_time_tips = spawner_config.spawn_xu_time_tips-1
    else
        spawner_config.spawn_xu_time_tips = spawner_config.spawn_xu_time
        spawner_config.spawn_state = 1
    end
    
    if (spawner_config.spawn_state == 1) and (spawner_config.spawn_interval_time_tips > 0) then 
        CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_interval_time_tips;gameType = GlobalVarFunc.game_type;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
        --倒计时10秒，显示UI提示
        GlobalVarFunc:OnGameCountDown(spawner_config.spawn_interval_time_tips, spawner_config.monsterNumber)

        spawner_config.spawn_interval_time_tips = spawner_config.spawn_interval_time_tips-1
    else
        if spawner_config.spawn_interval_time_tips == 0 then
            
            --野怪没清完将失败
            if spawner_config.monsterNumber > 0 then
                self:OnGameOver()
                return nil 
            end
            CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_interval_time_tips;gameType = GlobalVarFunc.game_type;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
            
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

    if (spawner_config.spawn_state == 0) and (spawner_config.spawn_start_time_tips > 0) then 
        CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_start_time_tips;gameType = GlobalVarFunc.game_type;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
        spawner_config.spawn_start_time_tips = spawner_config.spawn_start_time_tips-1
    else
        spawner_config.spawn_start_time_tips = spawner_config.spawn_start_time
        spawner_config.spawn_state = 1
    end
    
    if (spawner_config.spawn_state == 1) and (spawner_config.spawn_interval_time_tips > 0) then 
        CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_interval_time_tips;gameType = GlobalVarFunc.game_type;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
        --倒计时10秒，显示UI提示
        GlobalVarFunc:OnGameCountDown(spawner_config.spawn_interval_time_tips, spawner_config.monsterNumber)

        spawner_config.spawn_interval_time_tips = spawner_config.spawn_interval_time_tips-1
    else
        if spawner_config.spawn_interval_time_tips == 0 then
            CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_interval_time_tips;gameType = GlobalVarFunc.game_type;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
            
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

    if (spawner_config.spawn_state == 0) and (spawner_config.spawn_start_time_tips > 0) then 
        CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_start_time_tips;gameType = GlobalVarFunc.game_type;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
        spawner_config.spawn_start_time_tips = spawner_config.spawn_start_time_tips-1
    else
        spawner_config.spawn_start_time_tips = spawner_config.spawn_start_time
        spawner_config.spawn_state = 1
    end

end

--无尽模式以及刷怪阶段时间提示
function MobSpawner:OnEndlessNextMonTime2()
    --判断是否暂停游戏
    if GameRules:IsGamePaused() then
        return 0.01
    end

    if (spawner_config.spawn_state == 1) and (spawner_config.spawn_interval_endless_time_tips > 0) then 
        CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_interval_endless_time_tips;gameType = GlobalVarFunc.game_type;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})

        --倒计时10秒，显示UI提示
        GlobalVarFunc:OnGameCountDown(spawner_config.spawn_interval_endless_time_tips)

        spawner_config.spawn_interval_endless_time_tips = spawner_config.spawn_interval_endless_time_tips-1
    else
        if spawner_config.spawn_interval_endless_time_tips == 0 then
            --游戏时间为0，判定游戏结束
            self:OnGameOver()
            return nil
        end
    end

end

--深渊模式刷怪时间提示
function MobSpawner:OnAbyssNextMonTime()

    --判断是否暂停游戏
    if GameRules:IsGamePaused() then
        return 0.01
    end

    if (spawner_config.spawn_state == 0) and (spawner_config.spawn_start_time_tips > 0) then 
        CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_start_time_tips;gameType = GlobalVarFunc.game_type;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
        spawner_config.spawn_start_time_tips = spawner_config.spawn_start_time_tips - 1
    else
        spawner_config.spawn_start_time_tips = spawner_config.spawn_start_time
        spawner_config.spawn_state = 1
    end
    
    if (spawner_config.spawn_state == 1) and (spawner_config.spawn_abyss_monster_time > 0) then 
        CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_abyss_monster_time;gameType = GlobalVarFunc.game_type;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
        --倒计时10秒，显示UI提示
        GlobalVarFunc:OnGameCountDown(spawner_config.spawn_abyss_monster_time, spawner_config.monsterNumber)

        spawner_config.spawn_abyss_monster_time = spawner_config.spawn_abyss_monster_time - 1
    else
        if spawner_config.spawn_abyss_monster_time == 0 then
            CustomGameEventManager:Send_ServerToAllClients("OnNextMonsterTip",{time=spawner_config.spawn_abyss_monster_time;gameType = GlobalVarFunc.game_type;num = spawner_config.mosterWave;monsterNum=spawner_config.monsterNumber;monsterchizi=spawner_config.monsterSurplusNum})
            
            --野怪没清完将失败
            if spawner_config.monsterNumber > 0 then
                self:OnGameOver()
                return nil
            end

            --深渊下一波
            MobSpawner:SpawnAbyssNextWave()
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

        local position = GlobalVarFunc:IsCanFindPath(1000, 4500)
        local monster_name = wave_info_waves.name..spawner_config.mosterWave
        -- 创建单位 
        local mob = CreateUnitByNameInPool(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)

        self:setMonsterBaseInformation(mob)

        if spawner_config.mosterWave >= 8 then
            mob:AddAbility(ability)
        end

        GlobalVarFunc:_addMoveSpeedAbility(mob)

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
    local position = GlobalVarFunc:IsCanFindPath(4000, 4500)
    local monster_name = bossname..spawner_config.mosterWave
    local boss = CreateUnitByNameInPool(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    boss:SetContext("boss", "1", 0)
    self:setMonsterBaseInformation(boss)
    boss:AddAbility(ability1)
    if spawner_config.mosterWave>=12 then
        boss:AddAbility(ability2)
    end
    GlobalVarFunc:_addMoveSpeedAbility(boss)

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

                local position = GlobalVarFunc:IsCanFindPath(1000, 4500)
                local monster_name = wave_info_waves.name..model
                -- 创建单位 
                local mob = CreateUnitByNameInPool(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
                self:setMonsterBaseInformation(mob)
                if spawner_config.mosterWave>=8 then
                    mob:AddAbility(ability)
                end
                GlobalVarFunc:_addMoveSpeedAbility(mob)
    
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

    local position = GlobalVarFunc:IsCanFindPath(2000, 3000)
    local boss_name = wave_info_waves.name..bossModel
    local boss = CreateUnitByNameInPool(boss_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    boss:SetContext("boss", "1", 0)
    self:setMonsterBaseInformation(boss)

    if spawner_config.mosterWave<=10 then
        --减少boss移动速度
        boss:AddNewModifier(boss, nil, "modifier_stop_move", nil)
    end

    boss:AddAbility(ability1)
    if spawner_config.mosterWave>=12 then
        boss:AddAbility(ability2)
    end
    --减少伤技能
    local Ability3= boss:AddAbility("monster_jianshang")
    Ability3:SetLevel(1)
    
    GlobalVarFunc:_addMoveSpeedAbility(boss)

    GlobalVarFunc.endless_boss_isAlive = true
    
    spawner_config.monsterTable[tostring(boss:entindex())] = boss

end

--深渊模式刷小兵
function MobSpawner:SpawnMonsterAbyss()

    if GlobalVarFunc.abyss_spawn_state then
        return
    end

    --野怪池子的数量
    spawner_config.monsterSurplusNum = 0
    GlobalVarFunc.monsterIsShuaMan = false

    --小兵模型
    -- local wave_info_waves = spawner_config.waves
    -- local count = 0
    -- GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("spawn_creep_think"), 
    -- function()
        
    --     --判断是否暂停游戏
    --     if GameRules:IsGamePaused() then
    --         return 0.01
    --     end
    --     --判断是否游戏结束
    --     if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
    --         return nil
    --     end

    --     local position = GlobalVarFunc:IsCanFindPath(1000, 4500)
    --     local model =  RandomInt(1,50)
    --     local monster_name = wave_info_waves.name..model
    --     -- 创建单位 
    --     local mob = CreateUnitByNameInPool(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    --     self:setAbyssMonsterBaseInformation(mob)

    --     --随机分配野怪技能
    --     local ability = self:_addAbility()
    --     mob:AddAbility(ability)

    --     spawner_config.monsterTable[tostring(mob:entindex())] = mob 
    
    --     -- 当前怪物计数
    --     count = count + 1
    --     -- 刷满退出
    --     if count < spawner_config.monsterNumMax then
    --         return 0.2
    --     else
    --         GlobalVarFunc.monsterIsShuaMan = true
    --         GlobalVarFunc.abyss_spawn_state = true
    --         return nil
    --     end
          
    -- end, 0)
end

-- 深渊模式刷Boss
function MobSpawner:SpawnBossAbyss()

    if not GlobalVarFunc.abyss_spawn_state then
        return
    end

    --野怪池子的数量
    spawner_config.monsterSurplusNum = 0
    GlobalVarFunc.monsterIsShuaMan = false

    local position = GlobalVarFunc:IsCanFindPath(1000, 2500)
    local bossModel = self:_addAbyssModel()
    local boss = CreateUnitByNameInPool(bossModel, position, true, nil, nil, DOTA_TEAM_BADGUYS)

    boss:SetContext("boss", "1", 0)
    self:setAbyssMonsterBaseInformation(boss)

    --深渊boss技能
    self:_addAbyssAbility(boss,4)
    
    spawner_config.monsterTable[tostring(boss:entindex())] = boss

    GlobalVarFunc.abyss_boss = boss

    MobSpawner:OnAbyssUpdateHealth(GlobalVarFunc.abyss_boss)
end

function MobSpawner:OnAbyssUpdateHealth(unit)
    if unit == nil then
        CustomGameEventManager:Send_ServerToAllClients("close_boss_health_bar", nil)
        return
    end

    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("update_boss_health"), function ()
        if GameRules:IsGamePaused() then
            return 0.1
        end
        if unit and not unit:IsNull() and unit:IsAlive() then
            CustomGameEventManager:Send_ServerToAllClients("show_boss_health_bar", {
                name = unit:GetUnitName(),
                maxHealth = unit:GetMaxHealth(),
                health = unit:GetHealth()
            })
            return 0.1
        else
            CustomGameEventManager:Send_ServerToAllClients("close_boss_health_bar", nil)
        end
        return nil
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

                local position = GlobalVarFunc:IsCanFindPath(1000, 4500)
                local monster_name = wave_info_waves.name..model
                -- 创建单位 
                local mob = CreateUnitByNameInPool(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
                self:setMonsterBaseInformation(mob)
                if spawner_config.mosterWave>=8 then
                    mob:AddAbility(ability)
                end

                GlobalVarFunc:_addMoveSpeedAbility(mob)
                GlobalVarFunc:OnWeeklyGameChange(mob)
    
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
       
    local position = GlobalVarFunc:IsCanFindPath(2000, 3000)
    local boss_name = wave_info_waves.name..bossModel
    local boss = CreateUnitByNameInPool(boss_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    boss:SetContext("boss", "1", 0)
    self:setMonsterBaseInformation(boss)

    boss:AddAbility(ability1)
    if spawner_config.mosterWave>=12 then
        boss:AddAbility(ability2)
    end

    --减少伤技能
    local Ability3= boss:AddAbility("monster_jianshang")
    Ability3:SetLevel(1)
    
    GlobalVarFunc:_addMoveSpeedAbility(boss)
    GlobalVarFunc:OnWeeklyGameChange(boss)

    GlobalVarFunc.endless_boss_isAlive = true
    
    spawner_config.monsterTable[tostring(boss:entindex())] = boss

end

-- 深渊刷怪物池子里的小怪
function MobSpawner:OnAbyssSpawnMonster()

    --小兵模型
    local wave_info_waves = spawner_config.waves
    local model =  RandomInt(1,50)
    local monster_name = wave_info_waves.name..model
    local position = GlobalVarFunc:IsCanFindPath(2000, 3000)
    -- 创建单位 
    local mob = CreateUnitByNameInPool(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    self:setAbyssMonsterBaseInformation(mob)

    --随机分配野怪技能
    local ability = self:_addAbility()
    mob:AddAbility(ability)

    spawner_config.monsterTable[tostring(mob:entindex())] = mob 
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

    local position = GlobalVarFunc:IsCanFindPath(2000, 3000)
    local monster_name = wave_info_waves.name..model
    -- 创建单位 
    local mob = CreateUnitByNameInPool(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)

    self:setMonsterBaseInformation(mob)

    if spawner_config.mosterWave>=8 then
        mob:AddAbility(ability)
    end

    if GlobalVarFunc.game_type == 1001 or GlobalVarFunc.game_type == 1003 then
        GlobalVarFunc:OnWeeklyGameChange(mob)
    end

    GlobalVarFunc:_addMoveSpeedAbility(mob)

    spawner_config.monsterTable[tostring(mob:entindex())] = mob 
end

--深渊怪的基本属性设置
function MobSpawner:setAbyssMonsterBaseInformation(unit)
    local health = self:abyss_Health()
    local healthRegen = self:abyss_HealthRegen()
    local attack = self:abyss_AttackDamage()
    local armor = self:abyss_Armor()
    local magicalResistance = self:abyss_MagicalResistance()
    local xp = self:abyss_DeathXP()
    local gold = self:abyss_DeathGold()

    if unit:GetContext("boss") then  
        
        health ,attack = self:abyss_boss_info(unit, health, attack)
    
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

function MobSpawner:abyss_boss_info(unit, health, attack)
    -- if unit:GetUnitName() == "npc_dota_creature_boss_diao" then
    --     health = health * 50
    --     attack = attack * 30
    -- elseif unit:GetUnitName() == "npc_dota_creature_boss_troops" then
    --     health = health * 30
    --     attack = attack * 10
    -- elseif unit:GetUnitName() == "npc_dota_creature_boss_ice" then
    --     health = health * 20
    --     attack = attack * 10
    -- elseif unit:GetUnitName() == "npc_dota_creature_boss_fire" then
    --     health = health * 20
    --     attack = attack * 10
    -- elseif unit:GetUnitName() == "npc_dota_creature_boss_robot" then
    --     health = health * 40
    --     attack = attack * 10
    -- elseif unit:GetUnitName() == "npc_dota_creature_boss_blademaster" then
    --     health = health * 30
    --     attack = attack * 20
    -- elseif unit:GetUnitName() == "npc_dota_creature_boss_shredder" then
    --     health = health * 35
    --     attack = attack * 10
    -- elseif unit:GetUnitName() == "npc_dota_creature_boss_shadow" then
    --     health = health * 25
    --     attack = attack * 15
    -- elseif unit:GetUnitName() == "npc_dota_creature_boss_celestialgod" then
    --     health = health * 25
    --     attack = attack * 15
    -- elseif unit:GetUnitName() == "npc_dota_creature_boss_madwarrior" then
    --     health = health * 30
    --     attack = attack * 10
    -- end

    health = health * 10000
    attack = attack * 100

    return health, attack
end

--深渊野怪攻击力
function MobSpawner:abyss_AttackDamage()
    local attack = (GlobalVarFunc.abyss_monster_level * GlobalVarFunc.abyss_monster_level * 20) * (GlobalVarFunc.duliuLevel*0.03 + 1) * GlobalVarFunc.MonsterViolent
    return attack
end

function MobSpawner:abyss_Health() 
    local health = GlobalVarFunc.abyss_monster_level * GlobalVarFunc.abyss_monster_level * GlobalVarFunc.abyss_monster_level * 10
    return health
end

function MobSpawner:abyss_HealthRegen() 
    return 0
end

function MobSpawner:abyss_DeathXP() 
    return 20
end

function MobSpawner:abyss_DeathGold() 
    return 20
end

function MobSpawner:abyss_Armor() 
    return 0
end

function MobSpawner:abyss_MagicalResistance() 
    return 0
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

    if unit:GetContext("boss") or unit:GetUnitName() == "npc_caidan_monster_2" or unit:GetUnitName() == "npc_eMo_boss" then  
        health = health*15
        attack = attack*5
        xp = xp*5
        gold = gold*5

        if GlobalVarFunc.playersNum~=0 then
            health = health*(GlobalVarFunc.playersNum*0.5+0.5)
        end
    end

    --自闭PLUS攻击和血量*5倍
    if GlobalVarFunc.game_type == 1003 then
        health = health*5
        attack = attack*5
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
    local attack = ((spawner_config.mosterWave-1)*(spawner_config.mosterWave-1)*20+30)*(GlobalVarFunc.duliuLevel*0.03 + 1) * GlobalVarFunc.MonsterViolent
    if GlobalVarFunc.game_mode == "common" then
        if GlobalVarFunc.game_type == 0 then
            return attack * 0.3
        else
            return attack * (GlobalVarFunc.game_type*0.3+0.5)
        end
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
        if GlobalVarFunc.game_type == 0 then
            return health * 0.3
        else
            return health * (GlobalVarFunc.game_type*0.3+0.5)
        end
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

--随机分配野怪技能
function MobSpawner:_addAbility()
    local random = RandomInt(1,#monster_ability)
    local abilityName =  monster_ability[random]
    return abilityName
end

--随机分配深渊boss技能
function MobSpawner:_addAbyssAbility(unit, index)
    --添加ai
    unit:AddNewModifier(unit, nil, "modifier_cooldown_ai", nil)

    --添加技能
    local newAbyssAbilityTable = {}
    for i=1,#abyss_ability do
        newAbyssAbilityTable[i] = abyss_ability[i]
    end

    for i=1,index do
        local randomNum = RandomInt(1, #newAbyssAbilityTable)
        local abilityName = newAbyssAbilityTable[randomNum]
        table.remove( newAbyssAbilityTable, randomNum )

        local newAbility = unit:AddAbility(abilityName)
        newAbility:SetLevel(1)
    end
end

--随机分配深渊boss模型
function MobSpawner:_addAbyssModel()
    local random = RandomInt(1,#abyss_boss)
    local abyssBossModel =  abyss_boss[random]
    return abyssBossModel
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
                    if GlobalVarFunc.game_type == 1002 then
                        self:OnAbyssSpawnMonster()
                    else
                        self:OnSpawnMonster()
                    end
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
                    
                    local isOk = GlobalVarFunc:IsDoubleExperienceCard(i)
                    if isOk then
                        time = time * 2
                    end

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

        local tiaowuNum =  Archive:GetData(args.PlayerID,"luoli_tiaowu_num")
        tiaowuNum = tiaowuNum + 1

        --萝莉跳舞数据存档
        local hRows = {}
        hRows["luoli_tiaowu_num"] = tiaowuNum
        Archive:SaveRowsToPlayer(args.PlayerID,hRows)

    else
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(args.PlayerID),"send_error_message_client",{message="ARROW_SOUL_NOT_ENOUGH"})
    end
end

--萝莉跳舞冷却\
function MobSpawner:OnCoolDown()
    
    local time = 240
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

function MobSpawner:OnCreateGoldMonster()
    local name = "npc_dota_gold_mine"
    local position = Vector(5000, -4600, 0)
    local goldTree = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
end

function MobSpawner:OnCreatedCaiDanBoss1()
    local monster_name = "npc_caidan_monster"
    local position = Vector(-5000, 5000, 0)
    -- 创建单位 
    local boss = CreateUnitByNameInPool(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    
    --添加ai
    boss:AddNewModifier(boss, nil, "modifier_cooldown_ai", nil)
    local newAbility = boss:AddAbility("ability_abyss_2")
    newAbility:SetLevel(1)
    
    send_tips_message(0, "CAI_DAN_TIP_1")
end

function MobSpawner:OnCreatedCaiDanBoss2()
    local monster_name = "npc_caidan_monster_2"
    local position = Vector(-5000, 5000, 0)
    -- 创建单位 
    local boss = CreateUnitByNameInPool(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    self:setMonsterBaseInformation(boss)
    --添加ai
    boss:AddNewModifier(boss, nil, "modifier_cooldown_ai", nil)
    local newAbility = boss:AddAbility("ability_abyss_1")
    newAbility:SetLevel(1)
    
    send_tips_message(0, "CAI_DAN_TIP_2")
end

function MobSpawner:OnCreatedEMoTianZhan(nPlayerID)
    local monster_name = "npc_eMo_boss"
    local position = Vector(0, 5000, 0)
    -- 创建单位 
    local boss = CreateUnitByNameInPool(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    boss.nPlayerID = nPlayerID
    self:setMonsterBaseInformation(boss)
    --添加ai
    boss:AddNewModifier(boss, nil, "modifier_cooldown_ai", nil)
    --减伤光环
    boss:AddNewModifier(boss, nil, "modifier_abyss_jianshang", nil)
    local newAbility = boss:AddAbility("ability_abyss_1")
    newAbility:SetLevel(1)
end
return {
    --刷怪状态   0：表示没刷怪， 1表示已经刷怪 
    spawn_state = 0,

    -- 刷怪开始时间（秒）
    spawn_start_time = 10,
    --准备刷怪阶段的提示时间
    spawn_start_time_tips = 10,
    --序章刷怪开始时间（秒）
    spawn_xu_time = 30,
    --序章准备刷怪阶段的提示时间
    spawn_xu_time_tips = 30,
    
    --普通模式刷怪间隔时间
    spawn_interval_time = 100,  
    --每波刷怪间隔的提示时间
    spawn_interval_time_tips= 100,

    --无尽模式刷怪间隔时间
    spawn_interval_endless_time = 600,
    --无尽模式刷怪间隔时间提示
    spawn_interval_endless_time_tips = 600,

    --深渊模式刷小怪
    spawn_abyss_monster_time = 500,
    --深渊模式刷boss
    spawn_abyss_boss_time = 100,
    --深渊模式刷怪状态   false表示深渊开始刷小怪，  true表示深渊开始刷boss
    spawn_abyss_state = false,

    --记录野怪数目的表（野怪总数不能超过200个,超过就停止刷怪）
	monsterTable = {},
	--记录野怪的数目
    monsterNumber = 0,
    --场上野怪数量上限
    monsterNumMax = 50,
    --无尽场上野怪数量上限
    monsterNumMax_endless = 50,
    --怪物池子数量
    monsterSurplusNum = 0,
    --当前第0波
    mosterWave = 0,

    -- 波次配置
    waves = {
        -- 小兵怪物单位名称
        name = "npc_dota_creature_monster_",
        -- 本波个数
        num = 40
    },
    boss = {
        -- boss单位名称
        name = "npc_dota_creature_boss_",
        -- 本波个数
        num = 1
    },
    baseInformation = {
        Health = 50, 
        HealthRegen = 0,
        BountyGold = 10,
        BountyXP = 10,
        AttackDamage = 10,
        Armor = 1,
        MagicalResistance = 1,
        level = 1
    }
}

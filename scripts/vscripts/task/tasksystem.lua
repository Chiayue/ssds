
if tasksystem == nil then
    tasksystem = class({})
end

local maplevel_awards = {
    {
        needlevel = 8,
        awardsname = "talent_bar",
        Isget = 0,
    },
    {
        needlevel = 11,
        awardsname = "vip_silver",
        Isget = 0,
    },
    {
        needlevel = 14,
        awardsname = "clearance_gifbag",
        Isget = 0,
    },
    {
        needlevel = 17,
        awardsname = "vip_gold",
        Isget = 0,
    },
    {
        needlevel = 20,
        awardsname = "technology_house",
        Isget = 0,
    },
    {
        needlevel = 23,
        awardsname = "sage_stone",
        Isget = 0,
    },
    {
        needlevel = 26,
        awardsname = "aura_god",
        Isget = 0,
    },
    {
        needlevel = 29,
        awardsname = "arrow_infinite",
        Isget = 0,
    },
}

function tasksystem:get_maplevel_awards(player_id)
    local game_time = Archive:GetData(player_id,"game_time")
    local nLevel = GetPlayerMapLevel(game_time)
    local map_awards = {}
    for key, value in ipairs(maplevel_awards) do
        map_awards[key] = {}
        map_awards[key].needlevel = value.needlevel
        map_awards[key].awardsname = value.awardsname
        map_awards[key].Isget = value.Isget
        if nLevel >= map_awards[key].needlevel then
            map_awards[key].Isget = 1
        else
            map_awards[key].Isget = 0
        end
    end
    return nLevel, map_awards
end

local dayTaskconfig = {
    {quality="R",mapLevel=0,needHeroName="npc_dota_hero_windrunner_archon",needDamage=10000000,needWin=0,killNumber=0,awards={mapExp=30,arrowSoul=100,},},
    {quality="R",mapLevel=0,needHeroName="npc_dota_hero_dark",needDamage=10000000,needWin=0,killNumber=0,awards={mapExp=30,arrowSoul=100,},},
    {quality="R",mapLevel=0,needHeroName="npc_dota_hero_ice",needDamage=10000000,needWin=0,killNumber=0,awards={mapExp=30,arrowSoul=100,},},
    {quality="R",mapLevel=0,needHeroName="npc_dota_hero_fire",needDamage=10000000,needWin=0,killNumber=0,awards={mapExp=30,arrowSoul=100,},},
    {quality="R",mapLevel=0,needHeroName="npc_dota_hero_rage",needDamage=10000000,needWin=0,killNumber=0,awards={mapExp=30,arrowSoul=100,},},
    {quality="R",mapLevel=0,needHeroName="npc_dota_hero_magic",needDamage=10000000,needWin=0,killNumber=0,awards={mapExp=30,arrowSoul=100,},},
    {quality="R",mapLevel=0,needHeroName="npc_dota_hero_earth",needDamage=10000000,needWin=0,killNumber=0,awards={mapExp=30,arrowSoul=100,},},
    {quality="R",mapLevel=0,needHeroName="npc_dota_hero_bank",needDamage=10000000,needWin=0,killNumber=0,awards={mapExp=30,arrowSoul=100,},},
    {quality="R",mapLevel=0,needHeroName="npc_dota_hero_natural",needDamage=10000000,needWin=0,killNumber=0,awards={mapExp=30,arrowSoul=100,},},
    {quality="R",mapLevel=0,needHeroName="npc_dota_hero_light",needDamage=10000000,needWin=0,killNumber=0,awards={mapExp=30,arrowSoul=100,},},
    {quality="R",mapLevel=0,needHeroName="npc_dota_hero_time",needDamage=10000000,needWin=0,killNumber=0,awards={mapExp=30,arrowSoul=100,},},
}

function tasksystem:get_random_taskInfo()
    
end

-- 刷新某格任务
function tasksystem:get_random_taskInfo(steamID, taskindex)
    
end

function tasksystem:Init()
    CustomGameEventManager:RegisterListener("get_award_data",Dynamic_Wrap(self,'get_award_data'))
end

function tasksystem:get_award_data(data)
    local player_id = data.PlayerID
    local level,map_award = tasksystem:get_maplevel_awards(player_id)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(player_id),"response_award_data",{map_level = level,map_award = map_award})
end
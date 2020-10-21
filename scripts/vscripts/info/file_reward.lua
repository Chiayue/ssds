LinkLuaModifier( "modifier_reward_hp_regen", "ability/reward/modifier_reward_hp_regen.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_reward_attackspeed", "ability/reward/modifier_reward_attackspeed.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_reward_range_bonus", "ability/reward/modifier_reward_range_bonus.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_reward_damage_bonus", "ability/reward/modifier_reward_damage_bonus.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_reward_bonus_gold", "ability/reward/modifier_reward_bonus_gold.lua",LUA_MODIFIER_MOTION_NONE )
-- 奖励机制
REWARD_TABLE = {
    game_killNum = {1000, 10000, 50000, 200000, 500000},
    endless_waves = { 15, 25, 35, 45 ,55 ,65 ,75 },
    gameMode_0_clearance = {1, 5, 20 },
    gameMode_1_clearance = {1, 5, 20 },
    gameMode_2_clearance = {1, 5, 20 },
    gameMode_3_clearance = {1, 5, 20 },
}
local hEndLessFinalDamage = {2,3,5,7,9,11,13}
--存档奖励
require("info/game_playerinfo")

if FileReward == nil then 
    FileReward = class({})
end

function FileReward:Start()
    -- print("fileReward Start")
    --ListenToGameEvent( "game_rules_state_change" ,Dynamic_Wrap( self, 'OnGameRulesStateChange' ), self )
end

function FileReward:OnGameRulesStateChange()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        --print("FileReward")
        -- local playerInfo = game_playerinfo:get_player_info()
        -- Timer(2,function()
        --     for nPlayerID = 0,MAX_PLAYER - 1 do
        --         local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
        --         if hHero ~= nil then
        --             --local steam_id =  PlayerResource:GetSteamAccountID(nPlayerID)
        --             --DeepPrintTable(playerInfo[steam_id])
        --             local nAbility = hHero:AddAbility("archon_reward_data")
        --             nAbility:SetLevel(1)
        --             local player_data = playerInfo[nPlayerID]
        --             for sRewardKey,v in pairs(player_data) do
        --                 local reward_lv = getDataOfIndex(v,REWARD_TABLE[sRewardKey])
        --                 --reward_lv = 2 --RandomInt(1,3)
        --                 FileReward:SetReward(sRewardKey,reward_lv,hHero,nAbility)
        --             end
        --         end
        --     end
        -- end)    
    end
end

-- 奖励信息
function FileReward:SetReward(sRewardKey,iLevel,hHero,nAbility)
    if iLevel == 0 then
        return
    end
    --         杀怪数：    1千      1万          5万         20万          50万
    --         回血奖励：  +5       +10          +20         +50           +100 
    -- if sRewardKey == "game_killNum" then
    --     hHero:AddNewModifier( hHero, nAbility, "modifier_reward_hp_regen", { duration = -1} )
    --     hHero:SetModifierStackCount("modifier_reward_hp_regen",hHero,iLevel)
    -- end
    -- N0：初始金币      +100            +200             +300
    if sRewardKey == "gameMode_0_clearance" then
        local reward_gold = {100,200,300}
        local nPlayerID = hHero:GetPlayerOwnerID()
        PlayerResource:ModifyGold(nPlayerID,reward_gold[iLevel],true,DOTA_ModifyGold_Unspecified)
    end
    -- N1：攻击速度      +5  +10% +15%
    -- 初始攻速:244
    if sRewardKey == "gameMode_1_clearance" then
        hHero:AddNewModifier( hHero, nAbility, "modifier_reward_attackspeed", { duration = -1} )
        hHero:SetModifierStackCount("modifier_reward_attackspeed",hHero,iLevel)
    end
    -- N2：杀怪金币      +1 +2 +3 
    if sRewardKey == "gameMode_2_clearance" then
        hHero:AddNewModifier( hHero, nAbility, "modifier_reward_bonus_gold", { duration = -1} )
        hHero:SetModifierStackCount("modifier_reward_bonus_gold",hHero,iLevel)
        
        -- local nGoldAbility = hHero:AddAbility("reward_bonus_gold")
        -- nGoldAbility:SetLevel(iLevel)
        -- hHero:SetModifierStackCount("modifier_reward_bonus_gold",hHero,iLevel)
    end
    -- N3：射程增加      +40 +50  +60  
    if sRewardKey == "gameMode_3_clearance" then
        hHero:AddNewModifier( hHero, nAbility, "modifier_reward_range_bonus", { duration = -1} )
        hHero:SetModifierStackCount("modifier_reward_range_bonus",hHero,iLevel)
    end
    -- 无尽模式波数：       15波     25波         35波       45波
    -- 伤害增加：           +5%     +10%         +15%       +20%
    if sRewardKey == "endless_waves" then
        local nStack = hEndLessFinalDamage[iLevel]
        hHero:AddNewModifier( hHero, nAbility, "modifier_reward_damage_bonus", {} )
        hHero:SetModifierStackCount("modifier_reward_damage_bonus",hHero,nStack)
    end
end

function getDataOfIndex(value,tReward)
    local order = 0
    if tReward == nil then
        return order
    end
    
    for i = 1,#tReward do
        if value < tReward[i] then
            break
        else
            order = order + 1
        end
    end
    return order
end

--所有玩家进游戏后的读档信息playerInfo
--{
    --模拟数据,测试用
    -- [123456789] = {                                     -- steam_id
    --     ["playerID"] = 0,                              --游戏内玩家id
    --     ["endless_waves"] = 0,                          --无尽模式波数记录 
    --     ["game_killNum"] = 0,                           --杀怪数
    --     ["gameMode_0_clearance"] = 0,                   --简单模式通关次数
    --     ["gameMode_1_clearance"] = 0,                   --普通模式通关次数
    --     ["gameMode_2_clearance"] = 0,                   --困难模式通关次数
    --     ["gameMode_3_clearance"] = 0,                   --无尽模式通关次数
    -- },

    -- [123456789] = {                                     -- steam_id
    --     ["playerID"] = 0,                              --游戏内玩家id
    --     ["endless_waves"] = 0,                          --无尽模式波数记录 
    --     ["game_killNum"] = 0,                           --杀怪数
    --     ["gameMode_0_clearance"] = 0,                   --简单模式通关次数
    --     ["gameMode_1_clearance"] = 0,                   --普通模式通关次数
    --     ["gameMode_2_clearance"] = 0,                   --困难模式通关次数
    --     ["gameMode_3_clearance"] = 0,                   --无尽模式通关次数
    -- },
--}

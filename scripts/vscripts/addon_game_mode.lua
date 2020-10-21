-- Generated from template
if CAddonTemplateGameMode == nil then
	_G.CAddonTemplateGameMode = class({})
end

--引入文件
require("global/global_var_func")
require("global/common")
require("utils/msg")
require("utils/timer")
---- 伍松
require("global/modifier_link")
require("gameMode/game_mode")
require("info/game_playerinfo")
require("monster/monster_spawner")
require("monster/monster_neutral")
require("monster/monster_challenge")
require("runes/runes_spawner")
require("monster/monster_operate")
require("monster/monster_bigBoss")
require("randomEvents/random_events")
require("randomEvents/treasure_selected")
require("arrow_Soul_meditation/arrowSoulMeditation")
require("events")
--- 郭源
require("player_data")
require("player_select_ability")
require("filter")
require("precache_unit")
require("service/service")
require("info/file_reward")
require("heroes/wearable_manager")
require("system/inventory/inventory_system")
-- 王黎明
require("player_inlaid_gemstone")
--
require("task/tasksystem")
--排行榜
require("ranking/ranking")

function Precache( context )
	local tPrecacheList  = require("precache_load")
	for sPrecacheMode, tList in pairs(tPrecacheList) do
		for _, sResource in pairs(tList) do
			-- print("PrecacheResource:"," [",sPrecacheMode,"] sResource:",sResource)
			PrecacheResource(sPrecacheMode, sResource, context)
		end
	end
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function CAddonTemplateGameMode:InitGameMode()
	print( "Template addon is loaded." )
	SendToServerConsole('dota_max_physical_items_purchase_limit 9999')
	SendToServerConsole('dota_music_battle_enable 0')

	--设置寻路搜索空间的限制
	LimitPathingSearchDepth(0.2) 

	-- --设置队伍选择时间
	-- GameRules:SetCustomGameSetupAutoLaunchDelay(30)
	--策略时间
	GameRules:SetStrategyTime(0.5)
	GameRules:SetShowcaseTime(0.5)
	-- 把备战时间调短 
	GameRules:GetGameModeEntity():SetAnnouncerDisabled( true )  
	GameRules:SetPreGameTime(0)
	GameRules:SetHeroSelectionTime(60)
	GameRules:SetHeroSelectPenaltyTime(0.5)
	GameRules:SetPostGameTime(3000)

	GameRules:SetTreeRegrowTime(10)

	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, MAX_PLAYER )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	-- 装备
	--设置选择英雄的时间
	--GameRules:SetHeroSelectionTime(0);  
	--禁止玩家买活
	GameRules:GetGameModeEntity():SetBuybackEnabled(false)
	--取消载入
	--GameRules:SetHeroSelectPenaltyTime(0)
	--关闭迷雾
	GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
	-- 关闭击杀提示
	GameRules:GetGameModeEntity():SetHudCombatEventsDisabled(true)
	--设置初始金币
	GameRules:SetStartingGold(200)
	-- 镶嵌宝石数据(王黎明)
	-- Player_Inlaid_Gemstone():init()
	--监听事件
	ListenToGameEvent( "game_rules_state_change" ,Dynamic_Wrap( CAddonTemplateGameMode, 'StageChange' ), self )
	ListenToGameEvent( "player_reconnected" ,Dynamic_Wrap(CAddonTemplateGameMode,"PlayerReconnected"),self)
	ListenToGameEvent( "entity_killed" ,Dynamic_Wrap(CAddonTemplateGameMode,"OnEntityKill"),self)
	ListenToGameEvent( "npc_spawned",Dynamic_Wrap(CAddonTemplateGameMode,"OnNPCSpawned"),self)
	--ListenToGameEvent( "gemstone_inlay" ,Dynamic_Wrap(Player_Inlaid_Gemstone,"OnGemstoneInlay"),self) -- 宝石镶嵌监听
	-- 游戏三维设定
	-- 力量提高真实伤害5000点提高100% 敏捷提高物理伤害 智力提高魔法伤害
	--GameRules: GetGameModeEntity(): SetUseCustomHeroLevels( true)
	--GameRules: GetGameModeEntity(): SetCustomHeroMaxLevel(45)
	
	--GameRules: GetGameModeEntity(): SetPauseEnabled(false)

	-- GameRules: GetGameModeEntity(): SetCustomGameForceHero("npc_dota_hero_wisp")
	GameRules: GetGameModeEntity(): SetLoseGoldOnDeath(false) -- 死亡金钱惩罚
	GameRules: GetGameModeEntity(): SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_DAMAGE, 1)
    GameRules: GetGameModeEntity(): SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP, 10)
    GameRules: GetGameModeEntity(): SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP_REGEN, 0.05)
    GameRules: GetGameModeEntity(): SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_DAMAGE, 1)
    GameRules: GetGameModeEntity(): SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ARMOR, 0.005)
    GameRules: GetGameModeEntity(): SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED, 0.05)
    GameRules: GetGameModeEntity(): SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_DAMAGE, 1)
    GameRules: GetGameModeEntity(): SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA, 10)
	GameRules: GetGameModeEntity(): SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN, 0.05)
	
	--游戏阶段

	-- print("DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD ",DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD)
	-- print("DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP ",DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP)
	-- print("DOTA_GAMERULES_STATE_HERO_SELECTION ",DOTA_GAMERULES_STATE_HERO_SELECTION)
	-- print("DOTA_GAMERULES_STATE_STRATEGY_TIME ",DOTA_GAMERULES_STATE_STRATEGY_TIME)
	-- print("DOTA_GAMERULES_STATE_TEAM_SHOWCASE ",DOTA_GAMERULES_STATE_TEAM_SHOWCASE)
	-- print("DOTA_GAMERULES_STATE_PRE_GAME ",DOTA_GAMERULES_STATE_PRE_GAME)
	-- print("DOTA_GAMERULES_STATE_GAME_IN_PROGRESS ",DOTA_GAMERULES_STATE_GAME_IN_PROGRESS)
	-- print("DOTA_GAMERULES_STATE_POST_GAME ",DOTA_GAMERULES_STATE_POST_GAME)
end

function CAddonTemplateGameMode:StageChange()
	--print("StageChange()",GameRules:State_Get())
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		print("DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP")
		-- 加载资源
		PrecacheUnit:Init()
		--游戏模式选择
		GameMode():Start()
		--创建并启动刷物品
		RunesSpawner():Start()
		--创建并启动刷怪器
		MobSpawner():Start()
		--创建中立野怪
		MonsterNeutral():Start()
		--挑战初始化
		MonsterChallenge():Start()
		--初始化随机事件监听
		RandomEvents():Init()
		--初始宝物选择监听
		Treasure_selected():Init()
		--运营初始化
		MonsterOperate():Start()
		--初始化bigBoss
		MonsterBigBoss():Start()
		--初始化箭魂修炼
		ArrowSoulMeditation():Start()
		-- 存档服务
		Service:init()
		-- 加载玩家数据
		Filter():init()
		--初始化地图奖励
		tasksystem:Init()
		CustomGameEventManager:RegisterListener( "store_effect_toggle", PlayerStoreReward.OnStoreToggle )
		for nPlayerID=0,5 do 
			local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
			if CDOTAPlayer ~= nil then
				CDOTAPlayer:SetSelectedHero("npc_dota_hero_wisp")
			end
		end
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_WAIT_FOR_MAP_TO_LOAD then
		print("DOTA_GAMERULES_STATE_WAIT_FOR_MAP_TO_LOAD")
		Player_Data():init()
		Player_Select_Ability():init()
		InventorySystem:Init()
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
		--_G.GameItems = LoadKeyValues("scripts/items/items_game.txt")
		for nPlayerID=0,5 do 
			local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
			if CDOTAPlayer ~= nil then
				CDOTAPlayer:SetSelectedHero("npc_dota_hero_wisp")
			end
		end
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		print("DOTA_GAMERULES_STATE_GAME_IN_PROGRESS")
		--排行榜
		Ranking:Init()
	end
end
-----------------------------------------------------
-- 断线重连
function CAddonTemplateGameMode:PlayerReconnected( event )
	local nPlayerID = event.PlayerID
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"update_tech_dialog",{})

	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"show_arrowSoul_meditationButton",{})
end



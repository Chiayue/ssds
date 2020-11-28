LinkLuaModifier("modifier_select_ability_standby", "player_select_ability.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_team_buff", "player_select_ability.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_select_skin_time", "player_select_ability.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_select_hero_time", "player_select_ability.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_autistic_every_week", "player_select_ability.lua", LUA_MODIFIER_MOTION_NONE)

require("player_data")
require("customized_reward")
require("heroes/heroes_skin")
require("item/series/serise_system")
require("service/arrow_soul_reward")
require("service/arrow_soul_compensate")
require("autistic/autistic_weeky_init")

----- 技能觉醒 等级
ABILITY_AWAKEN_1 = 2
ABILITY_AWAKEN_2 = 5
--------- 天赋 副职系统
if Player_Select_Ability == nil then
	Player_Select_Ability = class({})
end
--- 加载
local techTable = {}
local pre = 0
local hPassive = {}
local hPlayerBonus = {}
local hRepick = {}
local nDotaMap = nil
local nMagmaTime = 0

function Player_Select_Ability:init()
	-- 科技系统
	local hSelected = {}
	for nPlayerID = 0,MAX_PLAYER-1 do
		local t = {}
		-- 默认为3
		RandFetch(t,#TALENT_LIST,#TALENT_LIST)
		hPassive[nPlayerID] = nil;
		hRepick[nPlayerID] = false
		hSelected[nPlayerID] = 0
		CustomNetTables:SetTableValue( "player_passive", tostring(nPlayerID), t )
		local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
		if CDOTAPlayer ~= nil then
			local nTime = Archive:GetData(nPlayerID,"game_time")
			local nMapLevel = GetPlayerMapLevel(nTime)
			if nMapLevel <= 15 then game_enum.nMoeNoviceCount = game_enum.nMoeNoviceCount + 1 end
		end
	end
	CustomNetTables:SetTableValue( "player_data", "passive_select", hPassive )
	CustomNetTables:SetTableValue( "player_data", "repick", hRepick )
	CustomNetTables:SetTableValue( "player_data", "selected", hSelected )
	-- self.AbilityData = nil
	hPlayerBonus["bonus_ability_time"] = 129600
	CustomNetTables:SetTableValue( "settings", "player_bonus",  hPlayerBonus)
	CustomNetTables:SetTableValue( "common", "deputy", DEPUTY_LIST )
	ListenToGameEvent( "game_rules_state_change" ,Dynamic_Wrap( self, 'OnGameRulesStateChange' ), self )
	ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap(Player_Select_Ability,"scavenging"),self)
	ListenToGameEvent( "player_chat", Dynamic_Wrap(Player_Select_Ability,"OnChat"),self)

	CustomGameEventManager:RegisterListener( "deputy_selected", self.Deputy_Selected )
	CustomGameEventManager:RegisterListener( "ability_selected", self.Talent_Selected )
	CustomGameEventManager:RegisterListener( "challenge_greedy_send", self.ChallengeGreedy )
	CustomGameEventManager:RegisterListener( "store_heroese_repick", self.OnHeroesRepick )
	--CustomGameEventManager:RegisterListener( "InitializeSelection", Player_Select_Ability.InitializeSelection )
end

function Player_Select_Ability:startOnThink()
	GameRules:GetGameModeEntity():SetThink( "OnThinkTechnology", self, "OnThinkTechnology", 1 )
end

--------- 聊天检查
function GetTalentIndex(sTalent)
	for n,k in pairs(TALENT_LIST) do
		if k == "archon_passive_"..sTalent then
			return n
		end
	end
	return 1
end

--------- 重随英雄
function Player_Select_Ability:OnHeroesRepick(args)
	local nPlayerID = args.PlayerID
	if hRepick[nPlayerID] == false then
		hRepick[nPlayerID] = true
		local n = 1
		local t = CustomNetTables:GetTableValue( "player_passive", tostring(nPlayerID))
		local nTalentList = {}
		--DeepPrintTable(t)
		for k,v in pairs(t) do 
			if n > 4 then table.insert(nTalentList,v) end
			n = n+1
		end
		--DeepPrintTable(nTalentList)
		CustomNetTables:SetTableValue( "player_passive", tostring(nPlayerID), nTalentList )
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"heroese_repick_callback",{})
	end
end

function Player_Select_Ability:OnChat(args)
	if MAP_CODE == "archers_survive_test" or IsInToolsMode() then 
		local nPlayerID = args.playerid
		local sText = args.text
		local sCommand1 = string.sub(sText, 0, 1)
		if sCommand1 == "-" then
			local sTalent = string.sub(sText, 2, #sText)
			local nAbilityIndex = GetTalentIndex(sTalent)
			local param = {
				PlayerID = nPlayerID,
				ability_index = nAbilityIndex
			}
			Player_Select_Ability:Talent_Selected(param)
		end
	end
end



-- 毒瘤挑战检测
function Player_Select_Ability:ChallengeGreedy( args )
	-- body
	local nPlayerID = args.PlayerID
    local hDuliu = Player_Data:GetStatusInfo(nPlayerID)
    local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
    local hHero = CDOTAPlayer:GetAssignedHero()
    local hDuliuAbility = hHero:FindAbilityByName("challenge_greedy")
    if hDuliuAbility ~= nil then
	    if hDuliuAbility:IsCooldownReady() == true then
	    	hDuliuAbility:UseResources(true, true, true)
		    local gameEvent = {}
            gameEvent[ "player_id" ] = nPlayerID
            gameEvent[ "teamnumber" ] = -1
            gameEvent[ "message" ] = "#DOTA_HUD_USE_GREED"
            FireGameEvent( "dota_combat_event_message", gameEvent )
		    MonsterChallenge:OnRewardGold(nPlayerID)
		    GlobalVarFunc.duliuLevel = GlobalVarFunc.duliuLevel + 1
		    MonsterChallenge:OnDuLiuAddNum(nPlayerID)
		    CustomNetTables:SetTableValue("common", "greedy_level", { greedy_level = GlobalVarFunc.duliuLevel})
		    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"challenge_greedy_success",{})
		    --------------- 双倍
			if hHero:HasModifier("modifier_gem_devil_greed_additional") then
				local bDouble = false
				if RandomInt(1, 100) <= 35 then bDouble = true end
				if bDouble == true then
					MonsterChallenge:OnDuLiuAddNum(nPlayerID)
				    GlobalVarFunc.duliuLevel = GlobalVarFunc.duliuLevel + 1
				    CustomNetTables:SetTableValue("common", "greedy_level", { greedy_level = GlobalVarFunc.duliuLevel})
				    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"challenge_greedy_success",{})
				end
			end

		else
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="COOLING_IN_PROGRESS"})
		end
	end
end


-- 初始天赋选择
function Player_Select_Ability:Talent_Selected(args)
	local ability_index = args.ability_index
    local nPlayerID = args.PlayerID
    local sAbilityName = TALENT_LIST[ability_index]
    local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
    local hHero = CDOTAPlayer:GetAssignedHero()
    if hHero == nil then
       return
    end
    local hSelected = CustomNetTables:GetTableValue( "player_data", "selected")
    if hHero:HasAbility("archon_passive_select") and hSelected[tostring(nPlayerID)] == 0 then
    	hSelected[tostring(nPlayerID)] = 1
    	CustomNetTables:SetTableValue( "player_data", "selected", hSelected )
    	-- print("ReplaceHeroWith")
    	-- 保存物品
    	local hItemList = {}
    	for i=0,8 do
    		local hItem = hHero:GetItemInSlot(i)
    		if hItem ~= nil then
    			table.insert(hItemList,hItem)
    		end
    	end
    	-- 替换模型
    	local vLoc = hHero:GetAbsOrigin()
    	hHero:RemoveModifierByName("modifier_select_ability_standby")
    	local nCurrentGold = hHero:GetGold()
    	local sHeroName = HeroesSkin:GetTalentToHero(sAbilityName)
    	local hNewHero = PlayerResource:ReplaceHeroWith(nPlayerID,sHeroName,nCurrentGold,0)
	    if hNewHero == nil then return end
	    hNewHero:SetAbsOrigin(vLoc)
	    -- 初始化皮肤系统
	    HeroesSkin:Init(hNewHero)
	    -- 武器
	    hNewHero:AddItemByName("item_archer_bow_level_1")
	    -- 删除多余的天赋技能
	    for i=0,31 do
	    	local hHeroAbility = hNewHero:GetAbilityByIndex(i)
	    	if hHeroAbility ~= nil and hHeroAbility:GetAbilityType() == 2 then
		    	hNewHero:RemoveAbility(hHeroAbility:GetAbilityName())
		    end
	    end
	    -- 技能激活
    	hPassive[nPlayerID] = sAbilityName
    	hNewHero:RemoveAbility("archon_passive_select")
    	-- 天赋被动
	    local hTalent = hNewHero:AddAbility(sAbilityName)
	   	hTalent:SetLevel(1)
    	-- 闪现
    	local hBlink = hNewHero:FindAbilityByName("archon_blink")
    	hBlink:SetLevel(1)
	   	-- 副职
		local hDeputy1 = hNewHero:FindAbilityByName("archon_deputy_select_first")
		hDeputy1:SetLevel(1)
		local hDeputy2 = hNewHero:FindAbilityByName("archon_deputy_select_second")
		hDeputy2:SetLevel(1)
		-- 被动
		local hPassiveNull = hNewHero:FindAbilityByName("archon_passive_null")
		hPassiveNull:SetLevel(1)
		-- 毒瘤
		local hGreedy = hNewHero:FindAbilityByName("challenge_greedy")
		hGreedy:SetLevel(1)
		if sAbilityName == "archon_passive_greed" then 
			hGreedy:StartCooldown(1) 
			Player_Data:Set(nPlayerID,"status","duliu_in_cd",1)
		end
		-- 爆裂
		local hBonusBA = hNewHero:FindAbilityByName("bonus_base_attackspeed")
		hBonusBA:SetLevel(1)
		
		Player_Data:InitModifier( hNewHero )
	    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"closed_ability_select",{})
	    Player_Data():AddPoint(nPlayerID,200)
	    CustomNetTables:SetTableValue( "player_data", "passive_select", hPassive )
	    -- 读取存档奖励
	    local playerInfo = game_playerinfo:get_player_info()
	    local player_data = playerInfo[nPlayerID]
	    if player_data == nil then return end
        for sRewardKey,v in pairs(player_data) do
            local reward_lv = getDataOfIndex(v,REWARD_TABLE[sRewardKey])
            FileReward:SetReward(sRewardKey,reward_lv,hNewHero,hBlink)
        end
         -- 无尽模式下注册背包和UI
	    if GlobalVarFunc.game_mode == "endless" or  GlobalVarFunc.game_type == -2 then
	    	InventoryBackpack:RegisterUnit( hNewHero )
	    	local hArchiveEqui =  Archive:GetPlayerEqui(nPlayerID)
	    	print("GetPlayerEqui")
	    	SeriseSystem:CreateEquipmentInUnit(hArchiveEqui,hNewHero)
	    	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"hero_init_over",{})
	    end
	    -- 特定奖励
	    -- CustomizedReward:SetReward( hNewHero )
	    if MAP_CODE == "archers_survive_test" then
	    	if IsInToolsMode() then 
	    		hNewHero:AddItemByName("item_tools_mode") 
	    		local sp = hNewHero:AddItemByName("item_baowu_book_personage_use_limit") 
	    		sp:SetCurrentCharges(2)
	    		-- local gp = hNewHero:AddItemByName("item_gold_spade_fragment") 
	    		-- gp:SetCurrentCharges(50)
	    		-- SeriseSystem:CreateSeriesItemS2(hNewHero)
	    		-- SeriseSystem:CreateSeriesItemS2(hNewHero)
	    		-- SeriseSystem:CreateSeriesItemS2(hNewHero)
	    	end
			local baowu2 = hNewHero:AddItemByName("item_baoWu_book")
			baowu2:SetCurrentCharges(20)
			local baodian = hNewHero:AddItemByName("item_talent_upgrade")
			baodian:SetCurrentCharges(6)
			PlayerResource:ModifyGold(nPlayerID,99999,true,DOTA_ModifyGold_Unspecified)
		  	if GlobalVarFunc.game_type == -2 then 
		  		Player_Data():AddPoint(nPlayerID,1000000)
		  	end
	    end
	   	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"hero_selected_over",{ hero = sAbilityName})
	   	-- 更新补偿
	   	Timer(1,function()
	   		ArrowSoulCompensate:CheckReward( hNewHero )
	   	end)
	   	-- 自闭模式
	   	if GlobalVarFunc.game_type == 1001 or GlobalVarFunc.game_type == 1003 then
			hNewHero:AddNewModifier(hNewHero, nil, "modifier_autistic_week5_ally", {})
	   	end

	   	-- 提示
	   	local gameEvent = {}
		gameEvent[ "ability_name" ] = sAbilityName
		gameEvent[ "player_id" ] = nPlayerID
		gameEvent[ "teamnumber" ] = -1
		gameEvent[ "message" ] = "#DOTA_HUD_SELECT_HERO"
		FireGameEvent( "dota_combat_event_message", gameEvent )

		-- 读取商品存档信息
		Timer(1,function()
	        local hCurrentStore = Store:GetData(nPlayerID)
	        PlayerStoreReward:Set( hNewHero, hCurrentStore)
	        ArrowSoulMeditation:OnInitArrowSoulMeditation(hNewHero)
	        -- 成就奖励验证
	        ArrowSoulReward:CheckReward( hNewHero )
	        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"show_arrowSoul_meditationButton",{})
	   	end)
    end
end

-- 游戏激活选择技能
function Player_Select_Ability:OnGameRulesStateChange(event)
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		-- 模式判断

		if GlobalVarFunc.game_type == 1001 or GlobalVarFunc.game_type == 1003 then
			Player_Select_Ability:AutisticMode()
		end
		
		-- 测试服资格
		if MAP_CODE ~= "archers_survive" then
			if CheckBeta() == false then
				GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS);
			end
		end

		-- 设置最大英雄等级
		local MAX_LEVEL = 299              
	    -- 每一级的升级所需经验，这个经验要包括之前所有等级的经验，是一个经验总量，而不是当前等级升级还需要的经验。
	    XP_PER_LEVEL_TABLE = {}
	    for i=1,MAX_LEVEL do
	        local xp = 0;
	        if i > 1 then
	            xp = i*100 + XP_PER_LEVEL_TABLE[i - 1]
	        end
	        XP_PER_LEVEL_TABLE[i] = xp
	    end
	    GameRules: GetGameModeEntity(): SetUseCustomHeroLevels(true)
	    GameRules: GetGameModeEntity(): SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
	    local nDelay = 0
		if GlobalVarFunc.game_type == 0 then
			nDelay = 45
		else
			nDelay = 15
		end
		Timer(1,function()
			self:startOnThink()
			local hAllHeroes = HeroList:GetAllHeroes()
			for k,hHero in pairs(hAllHeroes) do 
				local passive_select = hHero:FindAbilityByName("archon_passive_select")
				if passive_select ~= nil then
					passive_select:SetLevel(1)
					hHero:AddNewModifier(hHero, passive_select, "modifier_select_ability_standby", { duration = nDelay})
				end
			end
        end)
	end
end

-- 副职选择
function Player_Select_Ability:Deputy_Selected( args )
	--print("Player Select Ability",args)
	local sAbilityName = args.ability_name
    local nPlayerID = args.PlayerID
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    if hHero:IsNull() then
       return
    end
    deputy_1st = hHero:FindAbilityByName("archon_deputy_select_first")
    deputy_2nd = hHero:FindAbilityByName("archon_deputy_select_second")
    if deputy_1st == nil then
    	if deputy_2nd ~= nil then
	    	hHero:RemoveAbility("archon_deputy_select_second")
		    local Ability = hHero:AddAbility(sAbilityName)
		   	Ability:SetLevel(1)
		end
	else
    	hHero:RemoveAbility("archon_deputy_select_first")
	    local Ability = hHero:AddAbility(sAbilityName)
	   	Ability:SetLevel(1)
	   	-- 无尽模式
	   	if GlobalVarFunc.game_mode == "endless" or GlobalVarFunc.game_mode == "hook" then
	   		deputy_2nd:SetHidden(false)
	   		deputy_2nd:SetLevel(1)
	   	end
    end
 
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"closed_deputy_select",{})
end

------------------------------- 拾荒者副职 ------------------
function Player_Select_Ability:scavenging( args )
	local PlayerID = args.PlayerID 
	local hPlayer = PlayerResource:GetPlayer(PlayerID)
	local aHero = hPlayer:GetAssignedHero()
    if args.itemname == "item_archers_wood" then
    	local itemIndex = args.ItemEntityIndex
		local nItem = EntIndexToHScript(itemIndex)
		local cost = nItem:GetCurrentCharges()
        Player_Data():AddPoint(PlayerID,cost)
        PopupWoodGain(aHero, cost)
       	if aHero:HasAbility("archon_deputy_scavenging") then
       		local nAbility = aHero:FindAbilityByName("archon_deputy_scavenging")
       		local fReward = nAbility:GetSpecialValueFor( "reward" )
       		local nDeputyStack = aHero:GetModifierStackCount("modifier_series_reward_deputy_scavenging", aHero )
       		if nDeputyStack >= 3 then
				fReward = 40
			elseif nDeputyStack >= 2 then
				fReward = 30
			end
       		local woodAmmt = math.floor(( cost * fReward ) * 0.01)
			Player_Data():AddPoint(PlayerID,woodAmmt)
        	PopupWoodGain(aHero, woodAmmt)
        	addHeroRandomAttr(aHero)
       	end
       	GlobalVarFunc:OnGameSound("mutou_sound", PlayerID)
       	--UTIL_Remove(nItem)
       	nItem:RemoveSelf() 
    end
    if args.itemname == "item_archers_gold" then
    	local itemIndex = args.ItemEntityIndex
		local nItem = EntIndexToHScript(itemIndex)
		local cost = nItem:GetCurrentCharges()
        PlayerResource:ModifyGold(PlayerID,cost,true,DOTA_ModifyGold_Unspecified)
        PopupGoldGain(aHero, cost)
    	if aHero:HasAbility("archon_deputy_scavenging")  then
    		local nAbility = aHero:FindAbilityByName("archon_deputy_scavenging")
			local fReward = nAbility:GetSpecialValueFor( "reward" )
			local nDeputyStack = aHero:GetModifierStackCount("modifier_series_reward_deputy_scavenging", aHero )
       		if nDeputyStack >= 3 then
				fReward = 40
			elseif nDeputyStack >= 2 then
				fReward = 30
			end
			local goldAmmt = math.floor(( cost * fReward ) * 0.01)
			PlayerResource:ModifyGold(PlayerID,goldAmmt,true,DOTA_ModifyGold_Unspecified)
			PopupGoldGain(aHero, goldAmmt)
			addHeroRandomAttr(aHero)
		end
		GlobalVarFunc:OnGameSound("jinbi_sound", PlayerID)
		--UTIL_Remove(nItem)
		nItem:RemoveSelf() 
	end
	if args.itemname == "item_baoxiang_gold" then
    	local itemIndex = args.ItemEntityIndex
		local nItem = EntIndexToHScript(itemIndex)
		local cost = nItem:GetCurrentCharges()
        PlayerResource:ModifyGold(PlayerID,cost,true,DOTA_ModifyGold_Unspecified)
        PopupGoldGain(aHero, cost)
    	if aHero:HasAbility("archon_deputy_scavenging")  then
    		local nAbility = aHero:FindAbilityByName("archon_deputy_scavenging")
			local fReward = nAbility:GetSpecialValueFor( "reward" )
			local nDeputyStack = aHero:GetModifierStackCount("modifier_series_reward_deputy_scavenging", aHero )
       		if nDeputyStack >= 3 then
				fReward = 40
			elseif nDeputyStack >= 2 then
				fReward = 30
			end
			local goldAmmt = math.floor(( cost * fReward ) * 0.01)
			PlayerResource:ModifyGold(PlayerID,goldAmmt,true,DOTA_ModifyGold_Unspecified)
			PopupGoldGain(aHero, goldAmmt)

		end
		GlobalVarFunc:OnGameSound("jinbi_sound", PlayerID)
		--UTIL_Remove(nItem)
		nItem:RemoveSelf() 
    end
end

----------------- 科学家/理财/属性 ------------------
function Player_Select_Ability:OnThinkTechnology()
	if GameRules:IsGamePaused() == true then
		return 1
	end
	-- 作弊模式验证
	if GameRules:IsCheatMode() then
		if not IsInToolsMode() then
	 		GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS);
	 	end
	end

	if GlobalVarFunc.MonsterWave >= 1 or GlobalVarFunc.game_type == -2 then
		pre = pre + 1
		nMagmaTime = nMagmaTime + 1

		for nPlayerID = 0,5 do
			local hPlayer = PlayerResource:GetPlayer(nPlayerID)
			if hPlayer ~= nil then
				-- 毒瘤
				local hDuliu = Player_Data:GetStatusInfo(nPlayerID)
				local nDuliuCooddown = hDuliu["duliu_in_cd"];
				if nDuliuCooddown > 0 then
					Player_Data:Modify(nPlayerID,"status","duliu_in_cd",-1)
				end
				local hHero = hPlayer:GetAssignedHero()
				---- 
				local sHeroName = hHero:GetUnitName()
				if sHeroName == "npc_dota_hero_wisp" then
					local hSelected = CustomNetTables:GetTableValue( "player_data", "selected")
					if hHero:HasAbility("archon_passive_select") 
						and hSelected[tostring(nPlayerID)] == 0 
						and hHero:HasModifier("modifier_select_ability_standby") == false then
						local nOrder = RandomInt(1,3)
						local hPlayePassive = CustomNetTables:GetTableValue(  "player_passive", tostring(nPlayerID) )
						local nAbilityIndex = hPlayePassive[tostring(nOrder)]
						local args = {
							PlayerID = nPlayerID,
							ability_index = nAbilityIndex
						}
						Player_Select_Ability:Talent_Selected(args)
					end
				end
				---- 钻石会员
				local bHaVipDiamond = hHero:HasModifier("modifier_store_reward_vip_diamond")
				if bHaVipDiamond == true then
					Player_Data():AddPoint(nPlayerID,1)
				end

				---- 伐木工
				local HDeputyTechnology = hHero:FindAbilityByName("archon_deputy_technology")
				if HDeputyTechnology ~= nil then
					local nLimitSec = HDeputyTechnology:GetSpecialValueFor( "limit_sec" )
					local nLimitReward = HDeputyTechnology:GetSpecialValueFor( "limit_reward" )
					local nLimitAmount = HDeputyTechnology:GetSpecialValueFor( "limit_amount" )
					local nBonusAmount = HDeputyTechnology:GetSpecialValueFor( "bonus_amount" )
					-- 2件套
					local nDeputyStack = hHero:GetModifierStackCount("modifier_series_reward_deputy_technology", hHero )
					if nDeputyStack >= 2 then
						nLimitAmount = 5000
					end
					
					
					if pre >= nLimitSec then
						local nowPoint = Player_Data():getPoints(nPlayerID)
						-- 3件套
						if  nDeputyStack >= 3 then
							nLimitReward = 1.5
						end
						local reward = math.floor((nowPoint * nLimitReward)/100)
						
						if reward > nLimitAmount then
							reward = nLimitAmount
						end
						Player_Data():AddPoint(nPlayerID,reward)
					else
						Player_Data():AddPoint(nPlayerID,nBonusAmount)
					end
				end
				---- 理财
				local PlayerInfo = Player_Data:Get(nPlayerID)
				local Income_Level = PlayerInfo["common"]["Income_Level"]
				-- local Income_Reward = Income_Level
				local nInvsetBonus = 1
				if hHero:HasAbility("archon_deputy_investment") then
					nInvsetBonus = 1.25
					local nDeputyStack = hHero:GetModifierStackCount("modifier_series_reward_deputy_investment", hHero)
					if nDeputyStack >= 3 then
						nInvsetBonus = 2
					elseif nDeputyStack >= 2 then
						nInvsetBonus = 1.4
					end
				end
				local nGemBonus = 1
				if hHero:HasModifier("modifier_gem_investment_in_secret") then nGemBonus = nGemBonus + 0.1 end
				if hHero:HasModifier("modifier_gem_investment_in_secret_additional") then nGemBonus = nGemBonus + 0.1 end
				local nCurrentID = nPlayerID + 1
				local nGlobalBonus = GlobalVarFunc.GoldInvestmentRewards 
				+ GlobalVarFunc.InvestmentAndOperate[nCurrentID] 
				+ GlobalVarFunc.InvestmentRewardCoefficient[nCurrentID]
				- 2 
				
				Income_Reward = math.floor(
					Income_Level * nGlobalBonus * nInvsetBonus * GlobalVarFunc.EquiInvestment[nCurrentID] * nGemBonus
				)
				Player_Data():Set(nPlayerID,"common","Income_Amount",Income_Reward)

				if GlobalVarFunc.game_type == -2 then Income_Reward = 99999 end
				PlayerResource:ModifyGold(nPlayerID, Income_Reward, true, DOTA_ModifyGold_Unspecified)
				PopupGoldGain(hHero, Income_Reward)	
				----- 计算属性 ---------
				--AttributeCalculation(hHero)
			end
		end
		if pre >= 5 then
			pre = 0
		end
		-- local position = Vector(1000, 0, 0)
		-- for n=0,9 do 
		-- 	CreateUnitByNameInPool( "npc_dota_creature_monster_".. RandomInt(1,20), position, true, nil, nil, DOTA_TEAM_BADGUYS)
		-- end
	end
	return 1
end


if modifier_select_ability_standby == nil then modifier_select_ability_standby = class({}) end

function modifier_select_ability_standby:IsHidden() return true end
function modifier_select_ability_standby:GetEffectName() return "particles/status_fx/status_effect_ghost.vpcf" end
function modifier_select_ability_standby:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE]	= true,
		-- [MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_ROOTED] = true,
		-- [MODIFIER_STATE_STUNNED] = true,
		--[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		-- [MODIFIER_STATE_SILENCED] = true,
	}
	return state
end
function modifier_select_ability_standby:OnDestroy()
	if not IsServer() then return false end
	local hHero = self:GetParent()
	local nPlayerID = hHero:GetPlayerID()
	local hSelected = CustomNetTables:GetTableValue( "player_data", "selected")
	if hHero:HasAbility("archon_passive_select") and hSelected[tostring(nPlayerID)] == 0 then
		local nOrder = RandomInt(1,3)
		local hPlayePassive = CustomNetTables:GetTableValue(  "player_passive", tostring(nPlayerID) )
		local nAbilityIndex = hPlayePassive[tostring(nOrder)]
		local args = {
			PlayerID = nPlayerID,
			ability_index = nAbilityIndex
		}
		Player_Select_Ability:Talent_Selected(args)
	end


end
---------------------------------------------------------------------------------
if modifier_select_hero_time == nil then modifier_select_hero_time = {} end
function modifier_select_hero_time:IsHidden() return true end
function modifier_select_hero_time:RemoveOnDeath() return false end
---------------------------------------------------------------------------------
if modifier_select_skin_time == nil then modifier_select_skin_time = {} end
function modifier_select_skin_time:IsHidden() return true end
function modifier_select_skin_time:RemoveOnDeath() return false end
---------------------------------------------------------------------------------
if modifier_team_buff == nil then modifier_team_buff = {} end
function modifier_team_buff:IsHidden() return false end
function modifier_team_buff:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_team_buff:GetTexture() return "huifu" end
function modifier_team_buff:RemoveOnDeath() return false end
function modifier_team_buff:OnRefresh()
	if IsServer() then
		self:IncrementStackCount()
	end
end
function modifier_team_buff:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_TOOLTIP,
	} 
	return funcs
end

function modifier_team_buff:OnTooltip() 
	return self:GetStackCount()
end
-----------
function Player_Select_Ability:AutisticMode()
	local tNpcAbility = LoadKeyValues("scripts/npc/npc_abilities.txt")
	for k,v in pairs(tNpcAbility) do
		if v ~= nil then
			if  type(v) == "table" then
				if v.AbilityType == nil then
					table.insert(GlobalVarFunc.OriginalAbilities,k)
				end
			end
		end
	end
end 

function CheckBeta()
	for n=0,MAX_PLAYER -1 do
		local bHasBeta = Archive:GetData(n)
		if bHasBeta ~= nil then
			if bHasBeta["hasbeta"] ~= nil then
				if bHasBeta["hasbeta"] == 1 then
					return true
				end
			end
		end
	end
	return false
end

if modifier_autistic_every_week == nil then modifier_autistic_every_week = {} end
function modifier_autistic_every_week:IsHidden() return true end 
function modifier_autistic_every_week:RemoveOnDeath() return false end
function modifier_autistic_every_week:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

---------------------  萌新BUFF ---------------
-- 队伍中有萌新时，队伍最终伤害提高5%(乘区D)，可叠加。并且BOSS掉落的装备属性额外提高1~3%，初始属性10点，杀怪额外+3。
LinkLuaModifier("modifier_moe_novice", "player_select_ability.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_moe_novice == nil then modifier_moe_novice = {} end
function modifier_moe_novice:IsHidden() return false end
function modifier_moe_novice:GetTexture() return "moe_novice" end
function modifier_moe_novice:RemoveOnDeath() return false end
function modifier_moe_novice:OnRefresh()
    if not IsServer() then return end
    self:IncrementStackCount()
end
function modifier_moe_novice:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
	} 
	return funcs
end

function modifier_moe_novice:OnTooltip() return self:GetStackCount() end
------------------------------------------ 萌新玩家 ------------------------------------------
LinkLuaModifier("modifier_moe_novice_player", "player_select_ability.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_moe_novice_player == nil then modifier_moe_novice_player = {} end
function modifier_moe_novice_player:IsHidden() return false end
function modifier_moe_novice_player:GetTexture() return "moe_novice" end
function modifier_moe_novice_player:RemoveOnDeath() return false end
function modifier_moe_novice_player:IsDebuff() return true end
function modifier_moe_novice_player:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
	} 
	return funcs
end

function modifier_moe_novice_player:GetModifierBonusStats_Agility() return 50 end
function modifier_moe_novice_player:GetModifierBonusStats_Intellect() return 50 end
function modifier_moe_novice_player:GetModifierBonusStats_Strength()  return 50 end
--- 萌新（无尽）
LinkLuaModifier("modifier_moe_novice_player_endless", "player_select_ability.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_moe_novice_player_endless == nil then modifier_moe_novice_player_endless = {} end
function modifier_moe_novice_player_endless:IsHidden() return true end
function modifier_moe_novice_player_endless:GetTexture() return "moe_novice" end
function modifier_moe_novice_player_endless:RemoveOnDeath() return false end
function modifier_moe_novice_player_endless:IsDebuff() return true end
function modifier_moe_novice_player_endless:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_DEATH
	} 
	return funcs
end

function modifier_moe_novice_player_endless:OnDeath(args) 
	if not IsServer() then return end
	local hAttacker = args.attacker
	local hCaster = self:GetParent()
	if hAttacker ~= hCaster then
		return
	end
	if self:GetStackCount() < 1000 then
		self:IncrementStackCount()
	end
end

function modifier_moe_novice_player_endless:GetModifierBonusStats_Agility() return self:GetStackCount() end
function modifier_moe_novice_player_endless:GetModifierBonusStats_Intellect() return self:GetStackCount() end
function modifier_moe_novice_player_endless:GetModifierBonusStats_Strength()  return self:GetStackCount() end
-------------------
------------------------------------------ 老手玩家 ------------------------------------------
LinkLuaModifier("modifier_moe_old_player", "player_select_ability.lua", LUA_MODIFIER_MOTION_NONE)
if modifier_moe_old_player == nil then modifier_moe_old_player = {} end
function modifier_moe_old_player:IsHidden() return false end
function modifier_moe_old_player:GetTexture() return "moe_novice" end
function modifier_moe_old_player:RemoveOnDeath() return false end
function modifier_moe_old_player:IsDebuff() return true end
function modifier_moe_old_player:DeclareFunctions() 
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
	} 
	return funcs
end
function modifier_moe_old_player:OnDeath(args)
	if not IsServer() then return end
	local hAttacker = args.attacker
	local hCaster = self:GetParent()
	if hAttacker ~= hCaster then
		return
	end
	local nPlayerID = self:GetCaster():GetPlayerID()
	local nBonusWood = 1
	Player_Data():AddPoint(nPlayerID,nBonusWood)
	PopupWoodGain(hCaster, nBonusWood)
end

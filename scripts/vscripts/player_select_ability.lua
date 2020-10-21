LinkLuaModifier("modifier_select_ability_standby", "player_select_ability.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_team_buff", "player_select_ability.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_select_skin_time", "player_select_ability.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_autistic_every_week", "player_select_ability.lua", LUA_MODIFIER_MOTION_NONE)

require("player_data")
require("customized_reward")
require("heroes/heroes_skin")
require("item/series/serise_system")
require("service/arrow_soul_reward")
require("service/arrow_soul_compensate")

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

function Player_Select_Ability:init()
	-- 科技系统
	for nPlayerID = 0,MAX_PLAYER-1 do
		local t = {}
		-- 默认为3
		RandFetch(t,#TALENT_LIST,#TALENT_LIST)
		hPassive[nPlayerID] = nil;
		hRepick[nPlayerID] = false;
		CustomNetTables:SetTableValue( "player_passive", tostring(nPlayerID), t )
	end
	
	CustomNetTables:SetTableValue( "player_data", "passive_select", hPassive )
	CustomNetTables:SetTableValue( "player_data", "repick", hRepick )

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
		local t = {}
		RandFetch(t,#TALENT_LIST,#TALENT_LIST)
		CustomNetTables:SetTableValue( "player_passive", tostring(nPlayerID), t )
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

function Player_Select_Ability:startOnThink()
	GameRules:GetGameModeEntity():SetThink( "OnThinkTechnology", self, "OnThinkTechnology", 1 )
end

-- 毒瘤挑战检测
function Player_Select_Ability:ChallengeGreedy( args )
	-- body
	local nPlayerID = args.PlayerID
    local hDuliu = Player_Data:GetStatusInfo(nPlayerID)
    local nInCooldown = hDuliu["duliu_in_cd"]
    local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
    local hHero = CDOTAPlayer:GetAssignedHero()
    local hDuliuAbility = hHero:FindAbilityByName("challenge_greedy")
    if hDuliuAbility ~= nil then
	    if nInCooldown <= 0 then
		    local nMaxCooldown = hDuliu["duliu_max_cd"]
		    hDuliuAbility:StartCooldown(nMaxCooldown)
		    Player_Data:Set(nPlayerID,"status","duliu_in_cd",nMaxCooldown)
		    send_tips_message(nPlayerID, "使用了贪婪！")
		    MonsterChallenge:OnRewardGold(nPlayerID)
		    GlobalVarFunc.duliuLevel = GlobalVarFunc.duliuLevel + 1
		    MonsterChallenge:OnDuLiuAddNum(nPlayerID)
		    --print(GlobalVarFunc.duliuLevel)
		    CustomNetTables:SetTableValue("common", "greedy_level", { greedy_level = GlobalVarFunc.duliuLevel})
		    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"challenge_greedy_success",{})
		else
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="冷却中"})
		end
	end
end


-- 初始天赋选择
function Player_Select_Ability:Talent_Selected(args)
	local ability_index = args.ability_index
    local nPlayerID = args.PlayerID
    --print(nPlayerID)
    local sAbilityName = TALENT_LIST[ability_index]
    local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
    local hHero = CDOTAPlayer:GetAssignedHero()
    if hHero == nil then
       return
    end
    local hPlayerInfo = PlayerResource:GetPlayer(nPlayerID)
    if hHero:HasAbility("archon_passive_select") then
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
		-- 爆裂
		local hBonusBA = hNewHero:FindAbilityByName("bonus_base_attackspeed")
		hBonusBA:SetLevel(1)
		-- 团队增益BUFF
		hNewHero:AddNewModifier(hNewHero, nil, "modifier_team_buff", {})
		hNewHero:AddNewModifier(hNewHero, nil, "modifier_select_skin_time", { duration = 15})

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
        -- 读取商品存档信息
        Player_Data:InitModifier( hNewHero )
        local hCurrentStore = Store:GetData(nPlayerID)
        PlayerStoreReward:Set( hNewHero, hCurrentStore)
        ArrowSoulMeditation:OnInitArrowSoulMeditation(hNewHero)
        -- 成就奖励验证
        ArrowSoulReward:CheckReward( hNewHero )
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"show_arrowSoul_meditationButton",{})
       	
	    -- 无尽模式下注册背包和UI
	    if GlobalVarFunc.game_mode == "endless" or  GlobalVarFunc.game_type == -2 then
	    	InventoryBackpack:RegisterUnit( hNewHero )
	    	local hArchiveEqui =  Archive:GetPlayerEqui(nPlayerID)
	    	print("GetPlayerEqui")
	    	SeriseSystem:CreateEquipmentInUnit(hArchiveEqui,hNewHero)
	    	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"hero_init_over",{})
	    end
	     -- 特定奖励
	    CustomizedReward:SetReward( hNewHero )
	    if MAP_CODE == "archers_survive_test" then
	    	-- print("IsInToolsMode")
	    	if IsInToolsMode() then hNewHero:AddItemByName("item_tools_mode") end
			
			local baowu2 = hNewHero:AddItemByName("item_baoWu_book")
			baowu2:SetCurrentCharges(20)
			local baodian = hNewHero:AddItemByName("item_talent_upgrade")
			baodian:SetCurrentCharges(6)
			local baowu = hNewHero:AddItemByName("item_study_passive_lv3")
			baowu:SetCurrentCharges(5)
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
	   	if  GlobalVarFunc.game_type == 1001 then
	   		hNewHero:AddNewModifier(hNewHero, nil, "modifier_autistic_every_week", {})
	   	end
    end
end

-- 游戏激活选择技能
function Player_Select_Ability:OnGameRulesStateChange(event)
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		-- 作弊模式验证
		if GameRules:IsCheatMode() then
			 local nPlayerCount = PlayerResource:GetPlayerCount()
			 if nPlayerCount == 1 then
			 	local nSteamID = PlayerResource:GetSteamAccountID(0)
			 	if nSteamID == 147814139 then
			 		print("CheatMode")
			 	elseif not IsInToolsMode() then
			 		GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS);
			 	end
			 else
			 	if not IsInToolsMode() then
			 		GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS);
			 	end
			 end
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
		Timer(1,function()
			self:startOnThink()
			local hAllHeroes = HeroList:GetAllHeroes()
			--print(#hAllHeroes)
			for k,hHero in pairs(hAllHeroes) do 
				local passive_select = hHero:FindAbilityByName("archon_passive_select")
				if passive_select ~= nil then
					passive_select:SetLevel(1)
					hHero:AddNewModifier(hHero, passive_select, "modifier_select_ability_standby", {})
				end
			end
        end)

		local nDelay = 0
		if GlobalVarFunc.game_type == 0 then
			nDelay = 45
		else
			nDelay = 20
		end
		Timer(nDelay,function()
			for nPlayerID = 0,MAX_PLAYER - 1 do
				local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
				if hHero ~= nil then
					if hHero:HasAbility("archon_passive_select") then
						local nOrder = RandomInt(1,2)
						local hPlayePassive = CustomNetTables:GetTableValue(  "player_passive", tostring(nPlayerID) )
						local nAbilityIndex = hPlayePassive[tostring(nOrder)]
						local args = {
							PlayerID = nPlayerID,
							ability_index = nAbilityIndex
						}
						Player_Select_Ability:Talent_Selected(args)
					end
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
    	hHero:RemoveAbility("archon_deputy_select_second")
	    local Ability = hHero:AddAbility(sAbilityName)
	   	Ability:SetLevel(1)
	else
    	hHero:RemoveAbility("archon_deputy_select_first")
	    local Ability = hHero:AddAbility(sAbilityName)
	   	Ability:SetLevel(1)
	   	-- 无尽模式
	   	if GlobalVarFunc.game_mode == "endless" then
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
	if GlobalVarFunc.MonsterWave >= 1 or GlobalVarFunc.game_type == -2 then
		pre = pre + 1
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
						nLimitAmount = 250
					end
					
					if pre >= nLimitSec then
						local nowPoint = Player_Data():getPoints(nPlayerID)
						-- 3件套
						local reward = math.floor((nowPoint * nLimitReward)/100)
						if nDeputyStack >= 3 then
							reward = reward * 2
						end
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
				local Income_Reward = Income_Level
				if hHero:HasAbility("archon_deputy_investment") then
					local nInvsetBonus = 1.25
					local nDeputyStack = hHero:GetModifierStackCount("modifier_series_reward_deputy_investment", hHero)
					if nDeputyStack >= 3 then
						nInvsetBonus = 2
					elseif nDeputyStack >= 2 then
						nInvsetBonus = 1.4
					end
					Income_Reward = Income_Level * nInvsetBonus
				end
				local nCurrentID = nPlayerID+1
				local nGlobalBonus = GlobalVarFunc.GoldInvestmentRewards 
				+ GlobalVarFunc.InvestmentAndOperate[nCurrentID] 
				+ GlobalVarFunc.InvestmentRewardCoefficient[nCurrentID]
				- 2
				
				Income_Reward = math.floor(Income_Reward * nGlobalBonus)
				Player_Data():Set(nPlayerID,"common","Income_Amount",Income_Reward)

				if GlobalVarFunc.game_type == -2 then Income_Reward = 99999 end
				PlayerResource:ModifyGold(nPlayerID, Income_Reward, true, DOTA_ModifyGold_Unspecified)
				PopupGoldGain(hHero, Income_Reward)	
				----- 计算属性 ---------
				AttributeCalculation(hHero)
			end
		end
		if pre >= 5 then
			pre = 0
		end
	end
	return 1
end


if modifier_select_ability_standby == nil then modifier_select_ability_standby = class({}) end

function modifier_select_ability_standby:IsHidden() return true end
function modifier_select_ability_standby:GetEffectName() return "particles/status_fx/status_effect_ghost.vpcf" end
function modifier_select_ability_standby:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE]	= true,
		--[MODIFIER_STATE_UNSELECTABLE] = true,
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
---------------------------------------------------------------------------------
function AttributeCalculation(hHero)
	local nPlayerID = hHero:GetOwner():GetPlayerID() 
	-- 箭魂层数
	local nArrowSoulStack = hHero:GetModifierStackCount("modifier_arrowSoul_meditation",  hHero)
	------- 玩家暴击几率&最终伤害 ------
	local hAttr = GlobalVarFunc.attr[nPlayerID + 1]

	----------------- 会员伤害乘区 -------------------
	local nFdamage_a = 0
	local nDiamond = hHero:GetModifierStackCount("modifier_store_reward_vip_diamond", hHero) * 0.03
	local nDarkWings = hHero:GetModifierStackCount("modifier_store_reward_dark_wings", hHero) * 0.05
	local nArrowInfinite = hHero:GetModifierStackCount("modifier_store_reward_arrow_infinite", hHero) * 0.1
	local nAuraGod = hHero:GetModifierStackCount("modifier_store_reward_aura_god", hHero) * 0.05
	local nGoldedDragon = hHero:GetModifierStackCount("modifier_store_reward_golden_dragon", hHero) * 0.07
	nFdamage_a = nFdamage_a + nDiamond + nDarkWings + nArrowInfinite + nGoldedDragon
	hAttr["fdamage_a"] = nFdamage_a
	----------------- 装备伤害乘区 -------------------
	local hBow = hHero:FindModifierByName("modifier_item_archer_bow")
	hAttr["fdamage_b"] = 0
	if hBow ~= nil then
		hAttr["fdamage_b"] = (hBow.reward_damage*0.01) or 0
	end
	-- 毁灭3件套
	if hHero:HasAbility("archon_passive_dark") or hHero:HasAbility("archon_passive_rage")  then
		local nRuinStack = hHero:GetModifierStackCount("modifier_series_reward_talent_ruin", hHero )
		if nRuinStack >= 3 then
			hAttr["fdamage_b"] = hAttr["fdamage_b"] + 0.2
		end
	end

	---------------- 技能伤害乘区  --------------------
	-- 神圣技能BUFF 
	local nLightStack = hHero:GetModifierStackCount("modifier_archon_passive_light_effect", hHero ) * 0.01
	hAttr["fdamage_c"] = nLightStack
	-- 热血战魂 
	-- local hFervorBuff = hHero:FindModifierByName("modifier_ability_flagstone_warlord_fervor_stacks")
	-- if hFervorBuff ~= nil then
	-- 	local nFervorStack = hFervorBuff:GetStackCount()
	-- 	local nFervorLevel = hFervorBuff:GetAbility():GetLevel() or 1 -- 1,2,4
	-- 	local hDamage = {1,2,4}
	-- 	hAttr["fdamage_c"] = hAttr["fdamage_c"] + (nFervorStack * hDamage[nFervorLevel] * 0.01)
	-- end

	
	--------------- 团队增益乘区 -----------
	hAttr["fdamage_d"] = 0
	local nTeamStack = hHero:GetModifierStackCount("modifier_team_buff", hHero ) * 0.01
	local nEndlessStack = hHero:GetModifierStackCount("modifier_reward_damage_bonus",hHero) * 0.01
	hAttr["fdamage_d"] = nTeamStack + nEndlessStack
	--- 爆裂模式
	hAttr["fdamage_e"] = 0
	local nBurstMode = hHero:HasModifier("modifier_bonus_base_attackspeed") and 1 or 0
	hAttr["fdamage_e"] = hAttr["fdamage_e"] + nBurstMode
	-- 乘区F
	hAttr["fdamage_f"] = 0
	-- 大地BUFF
	local hEarthBuff = hHero:FindModifierByName("modifier_archon_passive_earth_buff")
	if hEarthBuff ~= nil then
		local nEarthStack = hEarthBuff:GetStackCount()
		hAttr["fdamage_f"] = hAttr["fdamage_c"] + (nEarthStack * 0.01)
	end
	---------------------通用暴击爆伤----------------------------
	-- 通用暴击
	local nSageBonus = hHero:GetModifierStackCount("modifier_store_reward_sage_stone", hHero ) * 3
	-- 通用爆伤
	local nFlameBonus = hHero:GetModifierStackCount("modifier_series_reward_talent_flame_effect", hHero ) * 3
	local nHeimo = hHero:HasModifier( "modifier_gem_yongmengzhiren_heimo" ) and 200 or 0
	-------------------- 物理暴击几率 --------------------
	local nPhysicalCritUp1 = hHero:GetModifierStackCount("modifier_Upgrade_Physical_Critical", hHero ) * 4
	local nPhysicalCritUp2 = hHero:GetModifierStackCount( "modifier_tech_max_physical_critical_buff", hHero ) * 3
	local nCanbaiCrit = hHero:GetModifierStackCount( "modifier_gem_canbaizhiren" ,hHero) * -20
	local nShufuCrit = hHero:GetModifierStackCount( "modifier_gem_shufuzhiren",hHero ) * 20 
	hAttr["physical_crit"] = nPhysicalCritUp1 + nPhysicalCritUp2 + nCanbaiCrit + nShufuCrit + nSageBonus
	-------------------- 物理爆伤 --------------------
	local nAgiCritDamage =  0--hHero:GetAgility() * 0.05
	local nPhysicalCritDamageUp1 = hHero:GetModifierStackCount("modifier_Upgrade_Physical_Critical_Damage", hHero ) * 40
	local nPhysicalCritDamageUp2 = hHero:GetModifierStackCount( "modifier_tech_max_physical_critical_damage_buff", hHero ) * 25
	if nArrowSoulStack >= 17 then nPhysicalCritDamageUp1 = nPhysicalCritDamageUp1 + 25 end
	if nArrowSoulStack >= 32 then nPhysicalCritDamageUp1 = nPhysicalCritDamageUp1 + 30 end
	-- 宝物
	local nShufuDamage = hHero:HasModifier( "modifier_gem_shufuzhiren" ) and -75 or 0
	local nCanbaiDamage = hHero:HasModifier( "modifier_gem_canbaizhiren" ) and 120  or 0
	local nYongmengDa = hHero:HasModifier( "modifier_gem_yongmengzhiren_da" ) and 70 or 0
	local nYongmengXiao = hHero:HasModifier( "modifier_gem_yongmengzhiren_xiao") and 30 or 0
	local nYongmengZhong = hHero:HasModifier( "modifier_gem_yongmengzhiren_zhong" ) and 50 or 0
	
	local nBaowu = nYongmengDa + nYongmengXiao + nYongmengZhong + nCanbaiDamage + nShufuDamage
	hAttr["physical_crit_damage"] = 150 + nAgiCritDamage + nPhysicalCritDamageUp1 + nPhysicalCritDamageUp2 + nBaowu + nFlameBonus + nHeimo
	-------------------- 法术暴击几率 --------------------
	local nMagicCritUp1 = hHero:GetModifierStackCount("modifier_Upgrade_Magic_Critical", hHero ) * 4
	local nMagicCritUp2 = hHero:GetModifierStackCount( "modifier_tech_max_physical_magic_buff", hHero ) * 3
	-- 宝物
	local nDuohunCrit = hHero:HasModifier( "modifier_gem_duohunfazhang" ) and 20 or 0
	local nShihunCrit = hHero:HasModifier( "modifier_gem_shihunshengbei" ) and -20 or 0
	hAttr["magic_crit"] = nMagicCritUp1 + nMagicCritUp2 + nDuohunCrit + nShihunCrit + nSageBonus
	-------------------- 法术暴击伤害 --------------------
	local nIntCritDamage =  0 -- hHero:GetIntellect() * 0.05
	local nMagicCritDamageUp1 = hHero:GetModifierStackCount("modifier_Upgrade_Magic_Critical_Damage", hHero ) * 40
	local nMagicCritDamageUp2 = hHero:GetModifierStackCount( "modifier_tech_max_physical_critical_damage_buff", hHero ) * 25
	if nArrowSoulStack >= 18 then nMagicCritDamageUp1 = nMagicCritDamageUp1 + 25 end
	if nArrowSoulStack >= 33 then nMagicCritDamageUp1 = nMagicCritDamageUp1 + 30 end
	-- 宝物
	local nDuohunDamage = hHero:HasModifier( "modifier_gem_duohunfazhang" ) and -75 or 0
	local nShihunDamage = hHero:HasModifier( "modifier_gem_shihunshengbei" ) and 120 or 0
	local nYongmengDa_mag = hHero:HasModifier( "modifier_gem_yongmengzhiren_da" ) and 70 or 0
	local nYongmengXiao_mag = hHero:HasModifier( "modifier_gem_yongmengzhiren_xiao") and 30 or 0
	local nYongmengZhong_mag = hHero:HasModifier( "modifier_gem_yongmengzhiren_zhong" ) and 50 or 0
	hAttr["magic_crit_damage"] = 150 
		+ nMagicCritDamageUp1 + nMagicCritDamageUp2 + nDuohunDamage 
		+ nShihunDamage + nFlameBonus + nIntCritDamage + nYongmengXiao_mag 
		+ nYongmengZhong_mag + nYongmengDa_mag + nHeimo
	------ 伤害加成 通用 --------
	-------------------- 物理伤害加成 --------------------
	local nPhysicalDamage =  hHero:GetAgility() * 0.0002 -- 1W点200%
	local sHeroName = hHero:GetUnitName()
	if sHeroName == "npc_dota_hero_troll_warlord" then
		nPhysicalDamage = nPhysicalDamage * 0.4
	end
	-- local nAgiPhysicalDamage =  hHero:GetAgility() * 0.002 -- 1W点200%
	hAttr["physical_damage"] = nPhysicalDamage
	-------------------- 法术伤害加成 --------------------
	local nMagicDamage = hHero:GetIntellect() * 0.0008 -- 1W点800% 
	hAttr["magic_damage"] = nMagicDamage
	-- DeepPrintTable(hAttr)

	---- 最终伤害
	local nFinalDamage = hHero:GetStrength() * 0.0001 -- 1W点100% 0.01%
	hAttr["final_damage"] = nFinalDamage

	-- DeepPrintTable(hAttr)
	-- local m = collectgarbage('count')
	-- print(string.format("[Lua Memory]  %.3f KB  %.3f MB", m, m / 1024))
		-------------------- 物理伤害加成 --------------------
	-- DeepPrintTable(hAttr)
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
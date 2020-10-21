if Player_Data == nil then
	Player_Data = class({})
end

local table_common = {}
local table_status = {}
local table_tech = {}
local table_score = {}
local isInit = false
BASE_UPGRADE_POINTS     = 100           -- 科技基础消耗
bonus_UPGRADE_POINTS    = 75            -- 科技每级提升消耗
INCOME_BASE_bonus       = 50            -- 投资基础消耗
INCOME_UPGRADE_COST     = 10            -- 投资每级提升
TECH_MAX_LEVEL          = 10            -- 科技最大等级
TECH_AWARD_EVERY        = 5             -- 每点多少次科技，额外奖励属性
------ 裂变 -----

TECH_UPGRADE_LIST = {
    "Upgrade_AttackSpeed",
    "Upgrade_MaxDamage",
    "Upgrade_Range",
    "Upgrade_Base_Attackspeed",
    "Upgrade_Armor",
    "Upgrade_MaxHeath",
    "Upgrade_HeathRegen",
    "Upgrade_bonusBase_vampiric",
    "Upgrade_Physical_Critical",
    "Upgrade_Physical_Critical_Damage",
    "Upgrade_Magic_Critical",
    "Upgrade_Magic_Critical_Damage",
    "Upgrade_bonusBase_Str",
    "Upgrade_bonusBase_Agi",
    "Upgrade_bonusBase_Int",
    "Upgrade_Kill_Bonus",
}

function Player_Data:init()
    -- 初始化玩家数据网表
    if isInit == true then
        return
    end
    isInit = true
    local settings_tech = {}
    settings_tech["BasePoint"] = BASE_UPGRADE_POINTS
    settings_tech["bonusPoint"] = bonus_UPGRADE_POINTS
    settings_tech["IncomeBase"] = INCOME_BASE_bonus
    settings_tech["IncomeUpgrade"] = INCOME_UPGRADE_COST
    settings_tech["TechMaxLevel"] = TECH_MAX_LEVEL
    settings_tech["TechList"] = TECH_UPGRADE_LIST
    for P = 0 , MAX_PLAYER - 1 do
        -- 面板信息
        table_score[P] = {}
        table_score[P]["Kills"] = 0
        -- 常用信息
        table_common[P] = {}
        table_common[P]["Points"] = 0
        table_common[P]["Income_Level"] = 1
        table_common[P]["Income_Amount"] = 1
        table_common[P]["Income_Upgrade"] = INCOME_BASE_bonus
        table_common[P]["Round_Damage"] = 0
        table_common[P]["Total_Damage"] = 0
        -- 其他属性
        table_status[P] = {}
        table_status[P]["duliu_max_cd"] = 300 -- 毒瘤冷却
        table_status[P]["duliu_in_cd"] = 60 -- 毒瘤当前冷却
        -- 科技信息
        table_tech[P] = {}
        table_tech[P]["AwardEvery"] = 0
        for k,v in pairs(TECH_UPGRADE_LIST) do
            table_tech[P][v] = 0
            table_tech[P][v.."_cost"] = BASE_UPGRADE_POINTS
        end
        
    end
    CustomNetTables:SetTableValue( "settings", "talent_list", TALENT_LIST)
    --CustomNetTables:SetTableValue( "settings", "deputy_list", DEPUTY_LIST)
    CustomNetTables:SetTableValue( "settings", "tech", settings_tech)
    CustomNetTables:SetTableValue( "player_data", "common", table_common)
    CustomNetTables:SetTableValue( "player_data", "status", table_status)
    CustomNetTables:SetTableValue( "player_data", "tech", table_tech)
    CustomNetTables:SetTableValue( "player_data", "score", table_score)
    CustomNetTables:SetTableValue("common", "greedy_level", {greedy_level=0})
	CustomGameEventManager:RegisterListener( "upgrade_click", self.upgrade_click )
    CustomGameEventManager:RegisterListener( "buy_income", self.buy_income )
    CustomGameEventManager:RegisterListener( "buy_tech_points", self.buy_tech_points )
    -- 变更皮肤
    CustomGameEventManager:RegisterListener( "store_selected_skin", self.OnSkinSelected )

    ListenToGameEvent( "entity_killed" ,Dynamic_Wrap(Player_Data,"OnEntityKilled"),self)
    ListenToGameEvent( "dota_player_gained_level" ,Dynamic_Wrap(Player_Data,"OnPlayerGainedLevel"),self)
    -- 每秒定时器

end
function Player_Data:OnSkinSelected(args)
    -- DeepPrintTable(args)
    local nPlayerID = args.PlayerID
    local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
    local nSkinID = tonumber(args.skin_num)
    local hHero = CDOTAPlayer:GetAssignedHero()
    if nSkinID > 0 then
        HeroesSkin:ChangeSkin(hHero,nSkinID+1)
        hHero:RemoveModifierByName("modifier_select_skin_time")
    end
end
--力量/敏捷/智力 成长
function Player_Data:OnPlayerGainedLevel(args)
    local hHero = PlayerResource:GetPlayer(args.PlayerID):GetAssignedHero()
    if hHero ~= nil then
        local bHasCustomized = hHero:GetModifierStackCount("modifier_customized_reward_attr_gain_all",hHero)
        Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_STRENGTH,bHasCustomized)
        Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_AGILITY,bHasCustomized)
        Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_INTELLECT,bHasCustomized)
        -- 
        if hHero:GetLevel() == 45 then
            local hAllHero = HeroList:GetAllHeroes()
            for k,v in pairs(hAllHero) do
                for i=0,5 do
                    v:AddNewModifier(v, nil, "modifier_team_buff", {})
                end
            end
        end
    end
end

function Player_Data:GetHeroTalent(hHero)
    for _,v in pairs(TALENT_LIST) do
        local nAbility = hHero:FindAbilityByName(v)
        if nAbility ~= nil then
            return nAbility
        end
    end
    return nil
end

function Player_Data:AddBasebonus(hHero,sAttr,iAmount)
    local BaseAttr = 0
    if sAttr == DOTA_ATTRIBUTE_STRENGTH then
        BaseAttr = hHero:GetBaseStrength()
        hHero:SetBaseStrength(BaseAttr+iAmount)
        
    end
    if sAttr == DOTA_ATTRIBUTE_AGILITY then
        BaseAttr = hHero:GetBaseAgility()
        hHero:SetBaseAgility(BaseAttr+iAmount)
        
    end
    if sAttr == DOTA_ATTRIBUTE_INTELLECT then
        BaseAttr = hHero:GetBaseIntellect()
        hHero:SetBaseIntellect(BaseAttr+iAmount)
        
    end
    return 
end

function Player_Data:buy_tech_points( args )
    local nPlayerID = args.PlayerID
    local nAmonut = args.amount
    local currentGold = PlayerResource:GetGold(nPlayerID)
    if currentGold >= 1000*nAmonut then
        PlayerResource:SpendGold(nPlayerID,1000*nAmonut,DOTA_ModifyGold_AbilityCost)
        Player_Data:AddPoint(nPlayerID,100*nAmonut)
    else
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="金币不够"})
    end
    return
end
function Player_Data:buy_income( args )
    local nPlayerID = args.PlayerID
    local Income_Level = table_common[nPlayerID]["Income_Level"]
    local Income_Upgrade = table_common[nPlayerID]["Income_Upgrade"]
    local currentGold = PlayerResource:GetGold(nPlayerID)
    if currentGold >= Income_Upgrade then
        PlayerResource:SpendGold(nPlayerID,Income_Upgrade,DOTA_ModifyGold_AbilityCost)
        table_common[nPlayerID]["Income_Level"] = Income_Level + 1
        -- table_common[nPlayerID]["Income_Amount"] = table_common[nPlayerID]["Income_Level"] 
        table_common[nPlayerID]["Income_Upgrade"] = Income_Upgrade + INCOME_UPGRADE_COST
        CustomNetTables:SetTableValue( "player_data", "common", table_common )
        -- 如果是炼金
        local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
        local hHero = CDOTAPlayer:GetAssignedHero()
        if hHero:HasAbility("archon_passive_bank") then
            Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_STRENGTH,1)
            Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_AGILITY,1)
            Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_INTELLECT,1)
            hHero:CalculateStatBonus()
        end
    else
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="金币不够"})
    end
    return
end

function Player_Data:InitModifier( hHero )
    local hAbility = hHero:FindAbilityByName("upgrade_ability_core")
    if hAbility == nil then
        hAbility = hHero:AddAbility("upgrade_ability_core")
        hAbility:SetLevel(1)
    end
    for _,sAbilityName in pairs(TECH_UPGRADE_LIST) do
        local sModifier = "modifier_"..sAbilityName
        local hModifier = hHero:AddNewModifier(hHero, hAbility, sModifier, {}) 
        hHero:SetModifierStackCount("sModifier", hHero, 0)
    end
end
function Player_Data:upgrade_click( args )
	-- print("upgrade_click",args.ability_name)
	local nPlayerID = args.player_id
	local panelID = args.panelID
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    if hHero:IsNull() then
       return
    end
    -- 判断科技点
    local userPoints = table_common[nPlayerID]["Points"]
    if userPoints < 1 then
    	return false
    end
    -- 判断当前等级
    local hAbility = hHero:FindAbilityByName("upgrade_ability_core")
    if hAbility == nil then
        hAbility = hHero:AddAbility("upgrade_ability_core")
        hAbility:SetLevel(1)
    end
    local sAbilityName = args.ability_name
    local sModifier = "modifier_"..sAbilityName
    local nNowLevel = hHero:GetModifierStackCount(sModifier,hHero)
    if nNowLevel < TECH_MAX_LEVEL then
        local Points = table_tech[nPlayerID][sAbilityName.."_cost"]
        if userPoints < Points then
            return false
        end


        table_common[nPlayerID]["Points"] = table_common[nPlayerID]["Points"] - Points
        table_tech[nPlayerID][sAbilityName] = table_tech[nPlayerID][sAbilityName] + 1
        table_tech[nPlayerID][sAbilityName.."_cost"] = Points + bonus_UPGRADE_POINTS
        local iAmount = 50
        if sAbilityName == "Upgrade_bonusBase_Str" then
            Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_STRENGTH,iAmount)
        end
        if sAbilityName == "Upgrade_bonusBase_Agi" then
            Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_AGILITY,iAmount)
        end
        if sAbilityName == "Upgrade_bonusBase_Int" then
            Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_INTELLECT,iAmount)
        end
        table_tech[nPlayerID]["AwardEvery"] = table_tech[nPlayerID]["AwardEvery"] + 1
        --print(table_tech[nPlayerID]["AwardEvery"])
        if table_tech[nPlayerID]["AwardEvery"] >= TECH_AWARD_EVERY then
            table_tech[nPlayerID]["AwardEvery"] = 0
            Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_STRENGTH,20)
            Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_AGILITY,20)
            Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_INTELLECT,20)
        end
        ------- 科技屋效果 ------
        hHero:AddNewModifier(hHero, hAbility, sModifier, {}) 
        if hHero:HasModifier("modifier_store_reward_technology_house") then
            table_common[nPlayerID]["Points"] = table_common[nPlayerID]["Points"] + 15
        end
        -------------------------
        CustomNetTables:SetTableValue( "player_data", "common", table_common )
        CustomNetTables:SetTableValue( "player_data", "tech", table_tech )
    end
    hHero:CalculateStatBonus()
end

---OnEntityKilled 实体击杀
function Player_Data:OnEntityKilled(event)
    local hAttacker = EntIndexToHScript(event.entindex_attacker or -1)
    local hKilled =  EntIndexToHScript(event.entindex_killed or -1)
    local team = hAttacker:GetTeam()
    if team == 2 then
        local P = hAttacker:GetOwner():GetPlayerID()
        table_score[P]["Kills"] = table_score[P]["Kills"] + 1
        CustomNetTables:SetTableValue( "player_data", "score", table_score )
        Player_Data:AddPoint(P,1)
        -- 触发BOSS事件 升级天赋
        local sKilledName = hKilled:GetUnitName()
        local nUnitLevel = hKilled:GetLevel()
        if sKilledName == "npc_dota_creature_BigBoss" then
            local tip = "击杀了寒冰之王，团队所有成员天赋等级提高。"
            send_tips_message(P, tip)
            local hAllHero = HeroList:GetAllHeroes()
            local sParticle = "particles/econ/events/ti8/hero_levelup_ti8.vpcf"
            for nPlayerID = 0,5 do
                local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
                if CDOTAPlayer ~= nil then
                    local hHero = CDOTAPlayer:GetAssignedHero()
                    local hTalentPassive = Player_Data:GetHeroTalent(hHero)
                    if hTalentPassive ~= nil then
                        local nLevel = hTalentPassive:GetLevel()
                        if nLevel < 7 then
                            hTalentPassive:SetLevel(nLevel+1)
                            local nFXIndex = ParticleManager:CreateParticle( sParticle, PATTACH_POINT, hHero )
                        end
                    end
                    ---- 神赐光环 ---
                    local nBonusAttr = hHero:GetModifierStackCount("modifier_store_reward_aura_god",hHero) * 50
                    Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_STRENGTH,nBonusAttr)
                    Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_AGILITY,nBonusAttr)
                    Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_INTELLECT,nBonusAttr)
                    -- 寒冰之王等级
                    if nUnitLevel == 1 then
                        if hHero:GetModifierStackCount("modifier_store_reward_golden_dragon",hHero) > 0 then
                            local hSpBaowu = hHero:AddItemByName("item_baowu_book_dark_wings")
                            hSpBaowu:SetPurchaser(hHero)
                        end
                    end
                end
            end
        end
        for nPlayerID = 0,5 do
            local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
            if CDOTAPlayer ~= nil then
                local hHero = CDOTAPlayer:GetAssignedHero()
                -- 混子
                if hAttacker ~= hHero and hHero:HasAbility("archon_deputy_idler") == true then
                    PlayerResource:ModifyGold(nPlayerID,2,true,DOTA_ModifyGold_Unspecified)
                    PopupGoldGain(hHero, 2)
                    local nDeputyStack = hHero:GetModifierStackCount("modifier_series_reward_deputy_idler", hHero )
                    if nDeputyStack >= 2 then
                        if RandomInt(1, 100) >= 50 then 
                            Player_Data:AddPoint(nPlayerID,1) 
                            PopupWoodGain(hHero, 1)
                        end
                    end
                    if nDeputyStack >= 3 then
                        if RandomInt(1, 100) >= 50 then 
                            local bonus_type = RandomInt(0,2)
                            if bonus_type == DOTA_ATTRIBUTE_STRENGTH then
                                local BaseProperty = hHero:GetBaseStrength() 
                                hHero:SetBaseStrength(BaseProperty + 1)
                            end
                            if bonus_type == DOTA_ATTRIBUTE_AGILITY then
                                local BaseProperty = hHero:GetBaseAgility() 
                                hHero:SetBaseAgility(BaseProperty + 1)
                            end
                            if bonus_type == DOTA_ATTRIBUTE_INTELLECT then
                                local BaseProperty = hHero:GetBaseIntellect() 
                                hHero:SetBaseIntellect(BaseProperty + 1)
                            end
                            hHero:CalculateStatBonus()
                        end
                    end
                end
            end
        end
        -- 拾荒者DEBUFF
        local hScaven = hAttacker:FindAbilityByName("archon_deputy_scavenging")
        if  hScaven ~= nil then
            local nPunish = hScaven:GetSpecialValueFor("punish_killbonus")
            PlayerResource:SpendGold(P,nPunish,DOTA_ModifyGold_AbilityCost)
        end

        -- 击杀单位移除
        Timer(1.6,function()
            hKilled:RemoveSelf() 
        	--UTIL_Remove(hKilled)
    	end)
        

    end
end

function Player_Data:CostPoints(PlayerID,nPoint)
    table_common[PlayerID]["Points"] = table_common[PlayerID]["Points"] - nPoint
    CustomNetTables:SetTableValue( "player_data", "common", table_common )
end 

function Player_Data:getPoints(PlayerID)
    return table_common[PlayerID]["Points"]
end

function Player_Data:GetStatusInfo(PlayerID)
    return table_status[PlayerID]
end

function Player_Data:Get(PlayerID)
    local table_player = {}
    table_player["common"] = table_common[PlayerID]
    table_player["status"] = table_status[PlayerID]
    table_player["tech"] = table_tech[PlayerID]
    return table_player
end 

function Player_Data:Set(PlayerID,tableKeyName,key,val,bSend)
    if bSend == nil then
        bSend = false
    end
    if tableKeyName == "common" then
        table_common[PlayerID][key] = val
        CustomNetTables:SetTableValue( "player_data", "common", table_common )
    elseif tableKeyName == "status" then
        table_status[PlayerID][key] = val
        CustomNetTables:SetTableValue( "player_data", "status", table_status )
    elseif tableKeyName == "tech" then
        table_tech[PlayerID][key] = val
        CustomNetTables:SetTableValue( "player_data", "tech", table_tech )
    else
        error("tableKeyName not found!!")
    end
end

function Player_Data:Modify(PlayerID,tableKeyName,key,val,bSend)
    if bSend == nil then
        bSend = false
    end
    if tableKeyName == "common" then
        table_common[PlayerID][key] = table_common[PlayerID][key] + val
        CustomNetTables:SetTableValue( "player_data", "common", table_common )
    elseif tableKeyName == "status" then
        table_status[PlayerID][key] = table_status[PlayerID][key] + val
        CustomNetTables:SetTableValue( "player_data", "status", table_status )
    elseif tableKeyName == "tech" then
        table_tech[PlayerID][key] = table_tech[PlayerID][key] + val
        CustomNetTables:SetTableValue( "player_data", "tech", table_tech )
    else
        error("tableKeyName not found!!")
    end
end

function Player_Data:AddPoint(nPlayerID,Amount )
    Player_Data:Modify(nPlayerID,"common","Points",Amount)
    -- table_common[nPlayerID]["Points"] = table_common[nPlayerID]["Points"] + Amount
    -- CustomNetTables:SetTableValue( "player_data", "common", table_common )
end
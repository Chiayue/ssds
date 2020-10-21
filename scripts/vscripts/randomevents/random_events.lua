if RandomEvents == nil then
    RandomEvents = class({})
end

local player_chickenGold = {}
local players_boxDamage = {}

function RandomEvents:Init()
    ListenToGameEvent("entity_killed", Dynamic_Wrap(RandomEvents, "OnKillRandomEvents"), self)
    ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap(RandomEvents,"OnPickedUpChickenGold"),self)
    CustomGameEventManager:RegisterListener("item_selected", self.OnAddBusinessItem)
end

function RandomEvents:Start()
    print("RandomEvents Start")

    -- --自定义UI商人石板价格根据波数定
    -- CustomGameEventManager:Send_ServerToAllClients("set_item_cost",{monsterWaves=GlobalVarFunc.MonsterWave})
    if GlobalVarFunc.MonsterWave == 5 or GlobalVarFunc.MonsterWave == 9 or GlobalVarFunc.MonsterWave == 13 or GlobalVarFunc.MonsterWave == 17 then 
        
        local randNum = RandomInt(1,6)
        if randNum == 1 then
            self:OnCreatedBaoXiang()
        elseif randNum == 2 then
            self:OnMonsterViolent()
        elseif randNum == 3 then
            self:OnGoldInvestmentRewards()
        elseif randNum == 4 then
            self:OnCreateChicken()
        elseif randNum == 5 then
            self:OnCreateDamageStatisticsBox()
        elseif randNum == 6 then
            self:OnOperateRewards()
        elseif randNum == 7 then
            --self:OnCreatedBigBoss()
        elseif randNum == 8 then
            --self:OnCreateAngelShop()      --自定义商店
            --self:OnCreateBusinessMan()  --自己写的UI商城
        end
    end
    
end

--天降财运，大陆出现了金币潮，所有人金币投资收益+100%，持续120秒
function RandomEvents:OnGoldInvestmentRewards()
    GlobalVarFunc.GoldInvestmentRewards = 2
    CustomGameEventManager:Send_ServerToAllClients("show_event_tip",{event_name="goldInvestmentRewards"})

    local time = 120
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("spawn_creep_think"), 
    function()
        if GameRules:IsGamePaused() then
            return 0.1
        end
        if time > 0 then
            time = time - 1
            return 1
        else
            GlobalVarFunc.GoldInvestmentRewards = 1
            return nil
        end
    end, 0)  
end

--怪物狂暴了，攻击力+50%，当前波数的怪，持续120秒
function RandomEvents:OnMonsterViolent()
    GlobalVarFunc.MonsterViolent = 1.5
    CustomGameEventManager:Send_ServerToAllClients("show_event_tip",{event_name="monsterViolent"})

    local time = 120
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("spawn_creep_think"), 
    function()
        if GameRules:IsGamePaused() then
            return 0.1
        end
        if time > 0 then
            time = time - 1
            return 1
        else
            GlobalVarFunc.MonsterViolent = 1
            return nil
        end
    end, 0) 
end

--回合有回报，所有人立马获得回合收入100%奖励
function RandomEvents:OnOperateRewards()
    local operateInfo = CustomNetTables:GetTableValue( "gameInfo", "operate" )
    for k,v in pairs(operateInfo) do
        local steam_id = PlayerResource:GetSteamAccountID(tonumber(k))
        if steam_id ~= 0 then
            local PlayerID = tonumber(k)
            --木头
            -- local wood = math.floor( v.operate_gold * 1 )
            -- Player_Data:AddPoint(PlayerID,wood)
            -- send_tips_message(PlayerID, "通过随机事件获得"..wood.."木头！")
            --金币
            local gold = v.operate_gold * GlobalVarFunc.InvestmentAndOperate[PlayerID+1] * GlobalVarFunc.OperateRewardCoefficient[PlayerID+1]
            gold = math.floor( gold * 2 )
            PlayerResource:ModifyGold(PlayerID,gold,true,DOTA_ModifyGold_Unspecified)
            send_tips_message(PlayerID, "获得回合收入"..gold.."金币！")
        end
    end

    CustomGameEventManager:Send_ServerToAllClients("show_event_tip",{event_name="operateRewards"})
end

function RandomEvents:InputPlayersBoxDamage(nPlayerID,nDamage)
    players_boxDamage[nPlayerID]["playerBoxDamage"] = players_boxDamage[nPlayerID]["playerBoxDamage"] + nDamage
    CustomNetTables:SetTableValue( "players_boxDamage", "players_boxDamage", players_boxDamage )
end

function RandomEvents:OnCreateDamageStatisticsBox()
    --初始化随机事件宝箱伤害过滤器
    for i = 0 , MAX_PLAYER - 1 do
        players_boxDamage[i] = {}
        players_boxDamage[i]["playerBoxDamage"] = 0
    end
    CustomNetTables:SetTableValue( "players_boxDamage", "players_boxDamage", players_boxDamage )
    CustomGameEventManager:Send_ServerToAllClients("show_BoxDamage_panel",{})
    local name = "npc_dota_creature_damege_baoxiang"
    local position = Vector(0, -200, 0)
    local box = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)          

    CustomGameEventManager:Send_ServerToAllClients("show_event_tip",{event_name="damageBox"})

    local time = 90
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("spawn_creep_think"), 
    function()
        if GameRules:IsGamePaused() then
            return 0.1
        end
        if time > 0 then
            time = time - 1
            return 1
        else
            UTIL_Remove(box)
            self:OnBoxDamageRewardGold()
            return nil
        end
    end, 0)  
end

function RandomEvents:OnBoxDamageRewardGold()
    local playersBoxDamageInfo = CustomNetTables:GetTableValue( "players_boxDamage", "players_boxDamage" )
    for k,v in pairs(playersBoxDamageInfo) do
        local steam_id = PlayerResource:GetSteamAccountID(tonumber(k))
        if steam_id ~= 0 then
            local PlayerID = tonumber(k)
            local nPlayer = PlayerResource:GetPlayer(PlayerID)
            if nPlayer ~= nil then
                local aHero = nPlayer:GetAssignedHero()
                local gold = 0
                if v.playerBoxDamage > 1000000 then
                    gold = v.playerBoxDamage/10000 + 10000
                else
                    gold = v.playerBoxDamage/100 + 100
                end
           
                PlayerResource:ModifyGold(PlayerID,gold,true,DOTA_ModifyGold_Unspecified)
                PopupGoldGain(aHero, gold)
                local tip = "获得宝箱伤害奖励"..math.floor(gold).."金币！"
                send_tips_message(PlayerID, tip)
            end
        end
    end
end

function RandomEvents:OnCreateChicken()
    for i = 0 , MAX_PLAYER - 1 do
        player_chickenGold[i] = {}
        player_chickenGold[i]["ChickenGoldNum"] = 0
    end
    CustomNetTables:SetTableValue( "player_chickenGold", "player_chickenGold", player_chickenGold )
    CustomGameEventManager:Send_ServerToAllClients("show_ChickenGold_panel",{})

    local name = "npc_dota_creature_bonus_chicken"
    local position = Vector(2000, 0, 0)
    local chicken = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)

    CustomGameEventManager:Send_ServerToAllClients("show_event_tip",{event_name="chicken"})
end

function RandomEvents:OnPickedUpChickenGold(args)
    if args.itemname == "item_gold_egg" then
        local PlayerID = args.PlayerID 
        player_chickenGold[PlayerID]["ChickenGoldNum"] = player_chickenGold[PlayerID]["ChickenGoldNum"] + 1
        CustomNetTables:SetTableValue( "player_chickenGold", "player_chickenGold", player_chickenGold )
    end
end

function RandomEvents:OnCreateAngelShop()

    -- local item_cost = GetItemCost("itemName")
    -- print("======================"..item_cost)
    -- GameRules:GetGameModeEntity():RemoveItemFromCustomShop( "itemName", "angel_shop" )
    -- GameRules:GetGameModeEntity():AddItemToCustomShop( "itemName", "angel_shop", "1" )

    --local ent = SpawnEntityFromTableSynchronous("ent_dota_shop", {model = "models/creeps/neutral_creeps/n_creep_gnoll/n_creep_gnoll.vmdl"})
    
    local ent = Entities:FindByName(nil, "angel_shop")
    --ent:SetModel("models/courier/defense3_sheep/defense3_sheep_flying.vmdl")
    ent:SetAbsOrigin(Vector(-1500, 400, 400))
    ParticleManager:CreateParticle( "particles/econ/items/dazzle/dazzle_dark_light_weapon/dazzle_dark_shallow_grave_halo.vpcf", PATTACH_ABSORIGIN_FOLLOW, ent)

    CustomGameEventManager:Send_ServerToAllClients("show_event_tip",{event_name="angelShop"})

    local time = 90
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("spawn_creep_think"), 
    function()
        if GameRules:IsGamePaused() then
            return 0.1
        end
        if time > 0 then
            time = time - 1
            return 1
        else
            --ent:SetModel(nil)
            ent:SetAbsOrigin(Vector(-1500, 400, 4000))
            return nil
        end
    end, 0)
end


function RandomEvents:OnCreateBusinessMan()
    local name = "npc_dota_creature_businessman"
    local position = Vector(1000, 0, 0)
    local businessMan = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    businessMan:AddNewModifier(nil, nil, "modifier_invulnerable", {})
    CustomGameEventManager:Send_ServerToAllClients("businessMan_index",{index=businessMan:entindex()})

    send_tips_message(0, "注意啦，天使商品店出现在地图中心，存在时间90秒！")

    local time = 90
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("spawn_creep_think"), 
    function()
        if GameRules:IsGamePaused() then
            return 0.1
        end
        if time > 0 then
            time = time - 1
            return 1
        else
            UTIL_Remove(businessMan)
            CustomGameEventManager:Send_ServerToAllClients("closed_item_select",{})
            return nil
        end
    end, 0)
end

function RandomEvents:OnCreatedBaoXiang()
    local name = "npc_dota_creature_baoxiang"
    local position = Vector(0, 0, 0)
    local baoxiang = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    self:setMonsterBaseInformation(baoxiang, 10, 1)

    CustomGameEventManager:Send_ServerToAllClients("show_event_tip",{event_name="baoXiang"})

    local time = 90
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("spawn_creep_think"), 
    function()
        if GameRules:IsGamePaused() then
            return 0.1
        end
        if time > 0 then
            time = time - 1
            return 1
        else
            UTIL_Remove(baoxiang)
            return nil
        end
    end, 0)  
end

function RandomEvents:OnCreateGold(Vec)
    local position = Vec
    local newItem = CreateItem("item_baoxiang_gold", nil, nil)
    newItem:SetPurchaseTime(0)
    newItem:SetCurrentCharges(GlobalVarFunc.MonsterWave * 200)
    local drop = CreateItemOnPositionForLaunch(position, newItem)
    local dropTarget = position + RandomVector(RandomFloat(200, 1500))
    newItem:LaunchLoot(false, 600, 0.75, dropTarget)
    ParticleManager:CreateParticle(
        "particles/econ/items/dazzle/dazzle_dark_light_weapon/dazzle_dark_shallow_grave.vpcf", PATTACH_ABSORIGIN_FOLLOW,
        newItem:GetContainer())
end

function RandomEvents:OnCreatedBigBoss()
    local name = "npc_dota_creature_BigBoss"
    local position = Vector(-4900, -4900, 0)
    local bigBoss = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    self:setMonsterBaseInformation(bigBoss, 40, 20)

    CustomGameEventManager:Send_ServerToAllClients("show_event_tip",{event_name="bigBoss"})

    local time = 90
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("spawn_creep_think"), 
    function()
        if GameRules:IsGamePaused() then
            return 0.1
        end
        if time > 0 then
            time = time - 1
            return 1
        else
            UTIL_Remove(bigBoss)
            return nil
        end
    end, 0) 
end

function RandomEvents:setMonsterBaseInformation(unit, health_multiple, attack_multiple)
    local health = self:_Health(health_multiple)
    local attack = self:_AttackDamage(attack_multiple)

    unit:SetBaseMaxHealth(health)
    unit:SetMaxHealth(health)
    unit:SetHealth(health)
    unit:SetBaseDamageMax(attack)
    unit:SetBaseDamageMin(attack)
end

function RandomEvents:_AttackDamage(multiple)
    local attack = ((GlobalVarFunc.MonsterWave - 1) * (GlobalVarFunc.MonsterWave - 1) * 20 + 30) * multiple

    return attack * (GlobalVarFunc.game_type*0.3+0.5)
end

function RandomEvents:_Health(multiple)
    local health = ((GlobalVarFunc.MonsterWave - 1) * (GlobalVarFunc.MonsterWave - 1) * (GlobalVarFunc.MonsterWave - 1) * 35 + 30) * multiple
 
    return health * (GlobalVarFunc.game_type*0.3+0.5)
end

function RandomEvents:OnKillRandomEvents(event)
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    if killedUnit:GetUnitName() == "npc_dota_creature_baoxiang" then
        local position = killedUnit:GetOrigin()
        for i = 1, 10 do
            self:OnCreateGold(position)
        end
    end
end

function RandomEvents:OnAddBusinessItem(args)
    local itemName = args.item_name
    local itemCost = args.item_cost
    local nPlayerID = args.PlayerID
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    if hHero:IsNull() then
        return
    end

    if itemCost > PlayerResource:GetGold(nPlayerID) then
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="金币不够"})
    else
        PlayerResource:ModifyGold(nPlayerID,-itemCost,true,DOTA_ModifyGold_PurchaseItem)
        hHero:AddItemByName(itemName)
    end
end



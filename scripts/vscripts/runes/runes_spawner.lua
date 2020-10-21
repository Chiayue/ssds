-- 引用刷怪配置
local runes_config = require("runes/runes_config")

--符文生成,包括金币，消耗品
if RunesSpawner == nil then 
    RunesSpawner = class({})
end

--启动物品生成
function RunesSpawner:Start() 

    -- ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap(RunesSpawner,"OnPickedUpGoldAndWood"),self)

    GameRules:GetGameModeEntity():SetThink("OnThinker",self)
end

--每过几秒生成一次
function RunesSpawner:OnThinker()
    
    --判段是否暫停
    if GameRules:IsGamePaused() then
        return 0.1
    end

    --判断是否游戏结束
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end

    local now = GameRules:GetDOTATime(false, false)  --返回Dota游戏内的时间。（是否包含赛前时间或负时间)
    now = math.floor(now)
    if now >= runes_config.create_begin then
        for i=1,4 do
            --40波之后不刷金袋
            if GlobalVarFunc.MonsterWave <= 40 then
                self:OnCreateGold()
            end
            self:OnCreateWood()
        end
    end

    return runes_config.create_time
end

--金袋
function RunesSpawner:OnCreateGold()
    local position = Vector(0, 0, 0) + RandomVector( RandomFloat( 300, 4000 ))
    local newItem = CreateItem( runes_config.goods[1].name, nil, nil )
    newItem:SetPurchaseTime( 0 )                                       --设置物品的购买时间    
    local gold = GlobalVarFunc.MonsterWave * 5 * GlobalVarFunc.playersNum
    newItem:SetCurrentCharges(gold)
    local drop = CreateItemOnPositionForLaunch( position, newItem )   --CreateItemOnPositionSync()在给定位置创建一个可见的物品
    local dropTarget = position + RandomVector( RandomFloat( 10, 20 ) ) 
    newItem:LaunchLoot( false, 300, 0.75, dropTarget)

    Timer(runes_config.disappear_time,function()
        UTIL_Remove(drop)
    end)
end

--木头
function RunesSpawner:OnCreateWood()
    local position = Vector(0, 0, 0) + RandomVector( RandomFloat( 300, 4000 ))
    local newItem = CreateItem( runes_config.goods[2].name, nil, nil )
    newItem:SetPurchaseTime( 0 ) 
    newItem:SetCurrentCharges(RandomInt(5, 10 * GlobalVarFunc.playersNum))                                      
    local drop = CreateItemOnPositionForLaunch( position, newItem )   
    local dropTarget = position + RandomVector( RandomFloat( 10, 20 ) ) 
    newItem:LaunchLoot( false, 300, 0.75, dropTarget)

    Timer(runes_config.disappear_time,function()
        UTIL_Remove(drop)
    end)
end

function RunesSpawner:OnPickedUpGoldAndWood(args)
    local PlayerID = args.PlayerID 
	local nPlayer = PlayerResource:GetPlayer(PlayerID)
    local hItem = EntIndexToHScript(args.ItemEntityIndex or -1)
    if hItem == nil then return end
    if args.itemname == "item_archers_wood" then
        EmitSoundOnClient("custom_music.mutou", nPlayer)
        EmitSoundOn("custom_music.mutou",hItem)
    end
    if args.itemname == "item_archers_gold" then
    	EmitSoundOnClient("custom_music.jinbi", nPlayer)
        EmitSoundOn("custom_music.jinbi",hItem)
	end
	if args.itemname == "item_baoxiang_gold" then
    	EmitSoundOnClient("custom_music.jinbi", nPlayer)
        EmitSoundOn("custom_music.jinbi",hItem)
    end
end
local BigBossInfo = {
    --肉山等级 1，2，3，4，5,6,7
    level = 1,
    health = {50000,250000,1000000,5000000,25000000,100000000,100000000},
    attack = {1000,2000,4000,8000,15000,30000,50000},
    armor = 0,
    magicalResistance = 0,
    isCreated = false,
    CD_time = 240
}

--极寒之王等级网表，和运营解锁挂钩
local bigBoss_level_table = {}

if MonsterBigBoss == nil then 
    MonsterBigBoss = class({})
end

function MonsterBigBoss:Start() 
    bigBoss_level_table["level"] = 0
    CustomNetTables:SetTableValue( "gameInfo","bigBossLevel", bigBoss_level_table)
    ListenToGameEvent("entity_killed", Dynamic_Wrap(MonsterBigBoss, "OnKillBigBoss"), self)
    GameRules:GetGameModeEntity():SetThink("OnThinkerRouShan",self)
end

function MonsterBigBoss:OnThinkerRouShan()
    
    --判段是否暫停
    if GameRules:IsGamePaused() then
        return 0.1
    end
    --判断是否游戏结束
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end

    if BigBossInfo.isCreated==false and GlobalVarFunc.MonsterWave >= 3 then
        self:OnCreatedBigBoss()
    end

    return 1
end

function MonsterBigBoss:OnCreatedBigBoss()
    BigBossInfo.isCreated = true
    local name = "npc_dota_creature_BigBoss"
    local position = Vector(-5200, -5200, 0)
    local bigBoss = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    self:setBaseInformation(bigBoss)

    CustomGameEventManager:Send_ServerToAllClients("challenge_event_tip",{event_name="jihanzhiwang1"})
end

function MonsterBigBoss:setBaseInformation(unit)
    local health = self:_Health()
    local healthRegen = self:_HealthRegen()
    local attack = self:_AttackDamage()
    local armor = self:_Armor()
    local magicalResistance = self:_MagicalResistance()
    local xp = self:_DeathXP()
    local gold = self:_DeathGold()
    local level = self:_Level()

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
	unit:CreatureLevelUp(level)
end

--野怪攻击力
function MonsterBigBoss:_AttackDamage()
    local attack = BigBossInfo.attack[BigBossInfo.level]
    return attack
end

function MonsterBigBoss:_Health() 
    local health = BigBossInfo.health[BigBossInfo.level]
    return health
end

function MonsterBigBoss:_HealthRegen() 
    return 0
end

function MonsterBigBoss:_DeathXP() 
    return 100 
end

function MonsterBigBoss:_DeathGold() 
    return 100 
end

function MonsterBigBoss:_Armor() 
    local armor = BigBossInfo.armor
    return armor
end

function MonsterBigBoss:_MagicalResistance() 
    local magicalResistance = BigBossInfo.magicalResistance
    return magicalResistance
end

function MonsterBigBoss:_Level() 
    local level = BigBossInfo.level
    return level
end

function MonsterBigBoss:OnKillBigBoss(event) 
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    if killedUnit:GetUnitName() == "npc_dota_creature_BigBoss" then
        bigBoss_level_table["level"] = BigBossInfo.level
        CustomNetTables:SetTableValue( "gameInfo","bigBossLevel", bigBoss_level_table)
        
        CustomGameEventManager:Send_ServerToAllClients("challenge_event_tip",{event_name="jihanzhiwang2"})

        local position = killedUnit:GetOrigin()
        --创建石板
        -- for i = 1 , GlobalVarFunc.playersNum do
        --     local randNum = RandomInt(1,2)
        --     if randNum == 1 then
        --         MonsterBigBoss:OnCreatedShiBan(position)
        --     end
        -- end
        --创建团队宝物书
        if BigBossInfo.level % 2 == 0 then
            MonsterBigBoss:OnCreatedBaoWuBook(position)
        end 

        local time = BigBossInfo.CD_time
        GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("spawn_creep_think"), 
        function()
            if GameRules:IsGamePaused() then
                return 0.1
            end
            if time > 0 then
                time = time - 1
                return 1
            else
                BigBossInfo.isCreated = false
                BigBossInfo.level = BigBossInfo.level + 1
                if BigBossInfo.level >= 7 then
                    BigBossInfo.level = 7
                end
                self:OnCreatedBigBoss()
                return nil
            end
        end, 0)  
    end
end

function MonsterBigBoss:OnCreatedShiBan(Vector)
    local newItem = CreateItem( "item_study_passive", nil, nil )
	local drop = CreateItemOnPositionSync( Vector, newItem )
	local dropTarget = Vector 
	newItem:LaunchLoot( false, 300, 0.75, dropTarget )
end

function MonsterBigBoss:OnCreatedBaoWuBook(Vector)
    local newItem = CreateItem( "item_baoWu_book", nil, nil )
	local drop = CreateItemOnPositionSync( Vector, newItem )
	local dropTarget = Vector 
    newItem:LaunchLoot( false, 300, 0.75, dropTarget )
    
    --宝物音效
    GlobalVarFunc:OnGameSound("baowubook_sound")
end
require("monster/monster_spawner")
local spawner_config = require("monster/monster_config")

if MonsterNeutral == nil then
    MonsterNeutral = class({})
end

function MonsterNeutral:Start()

    ListenToGameEvent("entity_killed", Dynamic_Wrap(MonsterNeutral, "OnKillMonsterNeutral"), self)

    GameRules:GetGameModeEntity():SetThink("OnMonsterNeutralThinker",self)
end

function MonsterNeutral:OnMonsterNeutralThinker()
    if GameRules:IsGamePaused() then
        return 0.1
    end
    --判断是否游戏结束
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end
    
    if (spawner_config.mosterWave > 0) and (spawner_config.mosterWave < 50) and (GlobalVarFunc.neutralMosterNum < 15) and (GlobalVarFunc.game_type ~= 1002) then
        self:OnCreateNeutralBoss()
    end

    if (GlobalVarFunc.MonsterWave >= 50) and ((GlobalVarFunc.MonsterWave - 50) % 10 == 0) and (GlobalVarFunc.game_type == 1001) then
        if GlobalVarFunc.tuTengNumber ~= GlobalVarFunc.MonsterWave then
            self:OnCreateTuTeng()
            GlobalVarFunc.tuTengNumber = GlobalVarFunc.MonsterWave
        end
    end
    
    return 1
end

function MonsterNeutral:OnCreateTuTeng()
    local name = "ice_totem_unit"
    local position = GlobalVarFunc:IsCanFindPath(1000, 4500)
    local tuteng = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    self:setMonsterBaseInformation(tuteng)

    --添加ai
    tuteng:AddNewModifier(tuteng, nil, "modifier_cooldown_ai", nil)
    local ability = tuteng:AddAbility("ability_abyss_18")
    ability:SetLevel(1)
end

function MonsterNeutral:OnCreateNeutralBoss()
    local name = "npc_dota_creature_zhongli_monster"
    local position = self:FindPathablePositionNearby()
    local Boss = CreateUnitByNameInPool(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    self:setMonsterBaseInformation(Boss)

    GlobalVarFunc.neutralMosterNum = GlobalVarFunc.neutralMosterNum + 1
end

function MonsterNeutral:OnKillMonsterNeutral(event)
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    local Vec = killedUnit:GetOrigin()
    if killedUnit:GetUnitName() == "npc_dota_creature_zhongli_monster" then
        GlobalVarFunc.neutralMosterNum = GlobalVarFunc.neutralMosterNum - 1
        
        Timer(1, function()
            for i = 1, 10 do
                self:OnCreateMonster(Vec)
            end
        end)
    end

    if killedUnit:GetUnitName() == "ice_totem_unit" then 
        local position = killedUnit:GetOrigin()
        self:OnCreateChanZi(position)
    end
end

function MonsterNeutral:OnCreateChanZi(vector)
    local position = vector
    local newItem = CreateItem( "item_gold_spade_fragment", nil, nil )
    local drop = CreateItemOnPositionSync( position, newItem )
    local dropTarget = position 
    newItem:LaunchLoot( false, 300, 0.75, dropTarget )
end

function MonsterNeutral:OnCreateMonster(Vec)

    --小兵模型
    local wave_info_waves = spawner_config.waves
    local model = spawner_config.mosterWave 
    if spawner_config.mosterWave <= 50 then 
        model = spawner_config.mosterWave
    else
        if spawner_config.mosterWave%50==0 then 
            model = 1
        else
            model = spawner_config.mosterWave%50
        end
    end 
    
    local monster_name = wave_info_waves.name..model


    local position = Vec + RandomVector( RandomFloat( 0, 200 ))
    local path_ok =  GridNav:CanFindPath(position, Vector(1000, 0, 0))
    --判断是否能从某个起始点移动到某个终点
    if not path_ok then
        position = Vector(1000, 0, 0)
    end
    local monster = CreateUnitByNameInPool(monster_name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    --monster:SetRenderColor(0, 0, 0) 

    self:setMonsterBaseInformation(monster)

    if GlobalVarFunc.game_type == 1001 then
        GlobalVarFunc:OnWeeklyGameChange(monster)
    end
    GlobalVarFunc:_addMoveSpeedAbility(monster)
end

--设置怪物基本属性
function MonsterNeutral:setMonsterBaseInformation(unit)
    local health = self:_Health()
    local healthRegen = self:_HealthRegen()
    local attack = self:_AttackDamage()
    local armor = self:_Armor()
    local magicalResistance = self:_MagicalResistance()
    local xp = self:_DeathXP()
    local gold = self:_DeathGold()

    --血量上限20亿
    if health > 2000000000 then
        health = 2000000000
    end

    --图腾
    if unit:GetUnitName() == "ice_totem_unit" then
        health = GlobalVarFunc.playersNum * 40
    end

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
	unit:CreatureLevelUp(1)
end

--野怪攻击力
function MonsterNeutral:_AttackDamage()
    local attack = ((spawner_config.mosterWave-1)*(spawner_config.mosterWave-1)*20+30)*(GlobalVarFunc.duliuLevel*0.03 + 1) * GlobalVarFunc.MonsterViolent
    if GlobalVarFunc.game_mode == "common" then
        return attack * (GlobalVarFunc.game_type*0.3+0.5)
    else
        if spawner_config.mosterWave > 20 then
            return attack * 6
        else
            return attack * 2
        end
    end
end

function MonsterNeutral:_Health() 
    local health =((spawner_config.mosterWave-1)*(spawner_config.mosterWave-1)*(spawner_config.mosterWave-1)*35+30)
    if spawner_config.mosterWave>=20 then
        health = health *10
    elseif spawner_config.mosterWave >=16 then
        health = health *5
    elseif spawner_config.mosterWave >=12 then
        health = health *2
    end

    if GlobalVarFunc.game_mode == "common" then
        return health * (GlobalVarFunc.game_type*0.3+0.5)
    else
        if spawner_config.mosterWave > 20 then
            return health * 2 * 0.1
        else
            return health * 2 
        end
    end
end

function MonsterNeutral:_HealthRegen() 
    return 0
end

function MonsterNeutral:_DeathXP() 
    return spawner_config.mosterWave*3 + 15
end

function MonsterNeutral:_DeathGold() 
    return 1
end

function MonsterNeutral:_Armor() 
    
    if GlobalVarFunc.game_mode == "common" then
        return spawner_config.mosterWave
    else
        if spawner_config.mosterWave>69 then
            return 400
        elseif spawner_config.mosterWave>39 then
            return 146
        elseif spawner_config.mosterWave>20 then
            return 68
        else
            return spawner_config.mosterWave
        end
    end

end

function MonsterNeutral:_MagicalResistance() 
    if spawner_config.mosterWave <= 20 then
        return spawner_config.mosterWave * 2
    elseif spawner_config.mosterWave < 40 then
        return 80
    elseif spawner_config.mosterWave < 69 then
        return 90
    else
        return 94
    end
end

function MonsterNeutral:FindPathablePositionNearby()
    local position = Vector(0, 0, 0) + RandomVector( RandomFloat( 2000, 4500 ))
	local nAttempts = 0
	local nMaxAttempts = 20

	while ( ( not GridNav:CanFindPath( Vector(0, 0, 0), position ) ) and ( nAttempts < nMaxAttempts ) ) do
		position = Vector(0, 0, 0) + RandomVector( RandomFloat( 2000, 4500 ))
		nAttempts = nAttempts + 1
	end

    return position
end
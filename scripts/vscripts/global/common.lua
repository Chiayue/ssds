-- 通用函数

--获取单位的攻击范围
function GetUnitRange(hUnit)
	local nTotalRange = 0
	local hRangeModi = {
		"modifier_item_archer_bow",
		"modifier_Upgrade_Range",
		"modifier_gem_yuanshemoshi",
		"modifier_ability_baiyin_challenge",
		"modifier_ability_chuanshuo_challenge",
		"modifier_ability_qingtong_challenge",
		"modifier_ability_huangjin_challenge",
		"modifier_ability_shishi_challenge",
		"modifier_ability_tianjue_challenge",
		"modifier_arrowSoul_meditation",
		"modifier_series_attr_range",
	}
	for k,v in pairs(hRangeModi) do
		for _,hModi in pairs(hUnit:FindAllModifiersByName(v)) do
			local nModiRange = hModi:GetModifierAttackRangeBonus() or 0
			nTotalRange = nTotalRange + nModiRange
		end
	end
	return nTotalRange
end

function GetTableLength(hTable)
	local l = 0
	for _,v in pairs(hTable) do
		l = l + 1
	end
	return l
end

-- 获取地图等级
local hEXPTable = {}
for lv=1,50 do
	local nowEXP = 1
	if lv >1 then
		nowEXP = lv * 1 + hEXPTable[lv-1]
	end
	hEXPTable[lv] = nowEXP
end

function GetPlayerMapLevel(nTime)
	local nHour = math.floor(nTime/3600)
	for k,v in pairs(hEXPTable) do
		if nHour < v then
			return k
		end
	end
	return #hEXPTable
end

function CopyTable(hTable)
	local tab = {}
	for k, v in pairs(hTable or {}) do
		if type(v) ~= "table" then
			tab[k] = v
		else
			tab[k] = CopyTable(v)
		end
	end
	return tab
end

-- 获取所有玩家的英雄等级
function GetAllHeroesCountLevel()
	local nAllLevel = 0
	local hAllHero = HeroList:GetAllHeroes()
    for k,v in pairs(hAllHero) do
    	nAllLevel = nAllLevel + v:GetLevel() 
    end
	return nAllLevel
end


-----------------
tUnitPools = {}
tBossPools = {}
_G.UnitCustom = LoadKeyValues("scripts/npc/npc_units_custom.txt")
function CreateUnitByNameInPool( UnitName, vVector, bool, handle_4, handle_5, int_6 )
	if tUnitPools[UnitName] == nil then tUnitPools[UnitName] = {} end
	if #tUnitPools[UnitName] == 0 then
		local hUnit = CreateUnitByName(UnitName, vVector, bool, handle_4, handle_5, int_6)
		return hUnit
	else
		local hUnit = tUnitPools[UnitName][1]
		table.remove(tUnitPools[UnitName],1)
		local hUnitCustom = _G.UnitCustom[UnitName]
		local sModel =  hUnitCustom["Model"]
		-- hUnit:RespawnUnit()
		-- hUnit:SetModel(sModel)
		-- FindClearSpaceForUnit(hUnit, vVector, bool)
		try1 {
			main = function ()
				-- 清除技能
				-- for n=0,hUnit:GetAbilityCount() - 1 do
					
				-- end
				

				hUnit:RespawnUnit()
				hUnit:SetModel(sModel)
				FindClearSpaceForUnit(hUnit, vVector, bool)
			end,
			catch = function (errors)
				-- print("errors")
				-- hUnit:RemoveSelf()
				-- print("catch : " .. errors)
				hUnit = CreateUnitByName(UnitName, vVector, bool, handle_4, handle_5, int_6)
			end,
			finally = function (ok, errors)
				-- print("finally : " .. tostring(ok))
			end,
		}
		return hUnit
	end
end


-- 异常捕获
function try1(block)
	local main = block.main
	local catch = block.catch
	local finally = block.finally
	assert(main)
     -- try to call it
	local ok, errors = xpcall(main, debug.traceback)
	if not ok then
         -- run the catch function
         if catch then
             catch(errors)
         end
     end
	 
	-- run the finally function
	if finally then
		finally(ok, errors)
	end
 
	-- ok?
	if ok then
		return errors
	end
end

-- 从表里寻找值的键TableFindKey[ByValue]
function TableFindKey(t, v)
	if t == nil then
		return nil
	end

	for _k, _v in pairs(t) do
		if v == _v then
			return _k
		end
	end
	return nil
end

--------------- 铲子事件 ------------
function RunSpadeEvent(hCaster,sSpadeName,hParam)
	-- print(sEventName,"/",nAmount)
	-- body
	local nAmount = hParam.amount or 0
	local sEventName = hParam.event
	local gameEvent = {}
	local nPlayerID = hCaster:GetOwner():GetPlayerID()
	local hAllHero = HeroList:GetAllHeroes()
	if sEventName == "add_gold" then
	    for k,v in pairs(hAllHero) do
	    	local hPlayer = PlayerResource:GetPlayer(v:GetPlayerID())
	    	v:ModifyGold(nAmount, false, 0)
	    	SendOverheadEventMessage( hPlayer, OVERHEAD_ALERT_GOLD, v, nAmount, nil )
	    end
	elseif sEventName == "add_round_income" then
		local hOperateInfo = CustomNetTables:GetTableValue( "gameInfo", "operate" )
		for k,v in pairs(hOperateInfo) do
			v.operate_gold = v.operate_gold + nAmount
		end
		CustomNetTables:SetTableValue( "gameInfo", "operate", hOperateInfo)
	elseif sEventName == "add_str" or sEventName == "add_str2" then
		for k,v in pairs(hAllHero) do
			Player_Data:AddBasebonus(v,DOTA_ATTRIBUTE_STRENGTH,nAmount)
		end
	elseif sEventName == "add_agi" or sEventName == "add_agi2"then
		for k,v in pairs(hAllHero) do
			Player_Data:AddBasebonus(v,DOTA_ATTRIBUTE_AGILITY,nAmount)
		end
	elseif sEventName == "add_int" or sEventName == "add_int2" then
		for k,v in pairs(hAllHero) do
			Player_Data:AddBasebonus(v,DOTA_ATTRIBUTE_INTELLECT,nAmount)
		end
	elseif sEventName == "add_all" or sEventName == "add_all2" then
		for k,v in pairs(hAllHero) do
			Player_Data:AddBasebonus(v,DOTA_ATTRIBUTE_STRENGTH,nAmount)
			Player_Data:AddBasebonus(v,DOTA_ATTRIBUTE_AGILITY,nAmount)
			Player_Data:AddBasebonus(v,DOTA_ATTRIBUTE_INTELLECT,nAmount)
		end
	elseif sEventName == "level_up" then
		for k,v in pairs(hAllHero) do
			for n=1,nAmount do v:HeroLevelUp(true) end
		end
	elseif sEventName == "add_monster_ms" then
		game_enum.nMonsterMoveBonus = game_enum.nMonsterMoveBonus + nAmount
		CustomNetTables:SetTableValue( "common", "monster_move_bonus",{ move_bonus = game_enum.nMonsterMoveBonus} )
	-- elseif sEventName == "add_hero_ms" then
		
	elseif sEventName == "add_wood" then
		for P = 0 , MAX_PLAYER - 1 do
			Player_Data:AddPoint(P ,nAmount)
		end
	elseif sEventName == "add_item" then
		local sItemName = hParam.name
		gameEvent["ability_name"] = sItemName
		hCaster:AddItemByName(sItemName)
	elseif sEventName == "add_serieitem" then
		for k,hHero in pairs(hAllHero) do
			SeriseSystem:CreateSeriesItem(hHero,4,1,3)
		end
	end
	gameEvent[ "player_id" ] = nPlayerID
	gameEvent[ "teamnumber" ] = -1
	gameEvent[ "int_value" ] = nAmount
	gameEvent[ "message" ] = "#DOTA_HUD_SPADE_"..sSpadeName.."_"..sEventName
	FireGameEvent( "dota_combat_event_message", gameEvent )
	if hParam.screen_arcane == true then CustomGameEventManager:Send_ServerToAllClients("screen_arcane",{}) end
end

function addHeroRandomAttr(hHero)
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
-- 寻找范围的单位： 队伍、位置、目标、范围、队伍过滤、类型过滤
function GetAOEMostTargetsSpellTarget(team_number, search_position, target, radius, team_filter, type_filter)
	local targets = FindUnitsInRadius(team_number, search_position, target, radius, team_filter, type_filter, 0, 0, false)

	return targets
end

function FindUnitsInRadius2( iTeamNumber, vPosition, hCacheUnit, flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
	local nMax = 20
	local enemies = FindUnitsInRadius(
		iTeamNumber, 
		vPosition, 
		hCacheUnit, 
		flRadius, 
		iTeamFilter, 
		iTypeFilter, 
		iFlagFilter,
		FIND_UNITS_EVERYWHERE,--iOrder,
		false 
	)
	local nCounts = #enemies
	if nCounts > nMax then
		for i=nMax,nCounts do
			enemies[i] = nil
		end
	end
	return enemies
end

function CreateModifierThinker2( handle_1, handle_2, string_3, handle_4, Vector_5, int_6, bool_7 ) 
	print("CreateModifierThinker  C:",IsClient()," S:",IsServer())
	CreateModifierThinker( handle_1, handle_2, string_3, handle_4, Vector_5, int_6, bool_7 ) 
end

function SendParticlesToClient(sParticles,hUnit,ParticleAttachment_t)
	if ParticleAttachment_t == nil then ParticleAttachment_t = PATTACH_ABSORIGIN_FOLLOW end
	local queryUnit = hUnit:GetEntityIndex()
	local vVector = hUnit:GetAbsOrigin() 
	CustomGameEventManager:Send_ServerToAllClients(
		"local_player_particles",
		{ Particles = sParticles , Vector = vVector,queryUnit = queryUnit , Attachment = ParticleAttachment_t}
	)
end

---------------------  新伤害计算 ---------------------
if ApplyDamage_Original == nil then
	ApplyDamage_Original = ApplyDamage
end

function ApplyDamageS2(tDamageTable)
	-- 技能伤害
	local hAttack 		= tDamageTable.attacker
	if hAttack:GetTeam() == 2 then
		local hTarget 		= tDamageTable.victim
		local fDamage 		= tDamageTable.damage
		local iDamageType 	= tDamageTable.damage_type
		local bIsCrit		= RollCritDamage(hAttack,iDamageType)

		if iDamageType == 1 then
			-- 判断是否暴击


		elseif iDamageType == 2 then
			
		end
	end
	return ApplyDamage_Original(tDamageTable)
end

function RollCritDamage(hAttack,iDamageType)
	return false
end

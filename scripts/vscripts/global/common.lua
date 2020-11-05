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
--[[
1.全队金钱+15000               20%
2.全队力量+200                 10%
3.全队敏捷+200                 10%
4.全队智力+200                 10%
5.怪物移动速度+5%              10%
6.全队木材+2000                20%
7.什么都没有                   20%
]]
local hSpadeEvent = {
	{ event = "add_gold", amount = 15000 , chance = 20 },
	{ event = "add_str", amount = 200 , chance = 10 },
	{ event = "add_agi", amount = 200 , chance = 10 },
	{ event = "add_int", amount = 200 , chance = 10 },
	{ event = "add_monster_ms", amount = 5 , chance = 10 },
	{ event = "add_wood", amount = 2000 , chance = 20 },
	{ event = "none", amount = 0 , chance = 20 },
}
--------------- 铲子事件 ------------
function RunSpadeEvent(nPlayerID,sSpadeName,sEventName,nAmount)
	-- print(sEventName,"/",nAmount)
	-- body
	local gameEvent = {}
	gameEvent[ "player_id" ] = nPlayerID
	gameEvent[ "teamnumber" ] = -1
	gameEvent["int_value"] = nAmount
	gameEvent[ "message" ] = "#DOTA_HUD_SPADE_"..sSpadeName.."_"..sEventName
	FireGameEvent( "dota_combat_event_message", gameEvent )
	local hAllHero = HeroList:GetAllHeroes()
	if sEventName == "add_gold" then
	    for k,v in pairs(hAllHero) do
	    	local hPlayer = PlayerResource:GetPlayer(v:GetPlayerID())
	    	v:ModifyGold(nAmount, false, 0)
	    	SendOverheadEventMessage( hPlayer, OVERHEAD_ALERT_GOLD, v, nAmount, nil )
	    end
	elseif sEventName == "add_str" then
		for k,v in pairs(hAllHero) do
			Player_Data:AddBasebonus(v,DOTA_ATTRIBUTE_STRENGTH,nAmount)
		end
	elseif sEventName == "add_agi" then
		for k,v in pairs(hAllHero) do
			Player_Data:AddBasebonus(v,DOTA_ATTRIBUTE_AGILITY,nAmount)
		end
	elseif sEventName == "add_int" then
		for k,v in pairs(hAllHero) do
			Player_Data:AddBasebonus(v,DOTA_ATTRIBUTE_INTELLECT,nAmount)
		end
	elseif sEventName == "add_monster_ms" then
		game_enum.nMonsterMoveBonus = game_enum.nMonsterMoveBonus + nAmount
		CustomNetTables:SetTableValue( "common", "monster_move_bonus",{ move_bonus = game_enum.nMonsterMoveBonus} )
	elseif sEventName == "add_wood" then
		for P = 0 , MAX_PLAYER - 1 do
			Player_Data:AddPoint(P ,nAmount)
		end
	end
end
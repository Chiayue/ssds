-- 通用函数

--获取单位的攻击范围
function GetUnitRange(hUnit)


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
-- 储存全局变量和全局函数
if GlobalVarFunc == nil then
    GlobalVarFunc = {}
end

-- <==============================全局常量================================>
game_enum = {}
game_enum.GAME_ENDTIME = 1800
game_enum.GAME_CODE = "archers_survive"             -- 游戏名称编码
---------
MAX_PLAYER = 6                  -- 最大玩家数量
--------- 科技

-------- 副职列表
DEPUTY_LIST = {
	"archon_deputy_scavenging",
	"archon_deputy_technology",
	"archon_deputy_killer",
	"archon_deputy_forging",
	"archon_deputy_investment",
	"archon_deputy_doctor",
	"archon_deputy_boxer",
	"archon_deputy_idler",
}

-------- 初始天赋列表
TALENT_LIST = {
    "archon_passive_fire",
    "archon_passive_earth",
    "archon_passive_ice",
    "archon_passive_natural",
    "archon_passive_dark",
    "archon_passive_light",
    "archon_passive_rage",
    "archon_passive_puncture",
    "archon_passive_magic",
    "archon_passive_bank",

    "archon_passive_time",
    -- "archon_passive_resist_armour",
    -- "archon_passive_soul",
    -- "archon_passive_speed",
    -- "archon_passive_interspace",
    -- "archon_passive_shuttle",
    -- "archon_passive_greed"
}

ITEM_CUSTOM = LoadKeyValues("scripts/npc/npc_items_custom.txt")
-------- 玩家属性 -------
GlobalVarFunc.damage = {}
GlobalVarFunc.attr = {}
for n=0,5 do 
	local hAttribute = {
		final_damage = 0,
		physical_damage = 0,
		physical_crit = 0,
		physical_crit_damage = 150,
		magic_damage = 0,
		magic_crit = 0,
		magic_crit_damage = 150,
		fdamage_a = 0, -- 最终伤害乘区a
		fdamage_b = 0, -- 最终伤害乘区b
		fdamage_c = 0, -- 最终伤害乘区c
		fdamage_d = 0, -- 最终伤害乘区d
		fdamage_e = 0, -- 最终伤害乘区e
		fdamage_f = 0, -- 最终伤害乘区f

		da_buff = 0,
		da_debuff = 0,
		da_baolie = 0,

	}
	table.insert(GlobalVarFunc.attr,hAttribute)
	table.insert(GlobalVarFunc.damage,0)
end




-- <==============================全局变量================================>
--游戏模式分类：   普通(默认)："common"    挂机："hook"      无尽："endless"     
GlobalVarFunc.game_mode =  "common"
--游戏模式选择:-2表示挂机模式，0表示序章，1表示第一章，2表示第二章........1000表示无尽模式, 1001表示自闭模式
GlobalVarFunc.game_type = 0
--记录游戏玩家数
GlobalVarFunc.playersNum = 0
--挂机模式木桩是否创建
GlobalVarFunc.isCreateMuZhuang = false
--无尽模式记录boss是否活着
GlobalVarFunc.endless_boss_isAlive = false
--记录池子外的怪是否刷满
GlobalVarFunc.monsterIsShuaMan = false
--boss音效
GlobalVarFunc.boss_sound = nil
--无尽模式刷boss间隔1秒
GlobalVarFunc.suspend = 1
--野怪波数记录
GlobalVarFunc.MonsterWave = 0
--地狱火（中立怪）的数量记录
GlobalVarFunc.neutralMosterNum = 0
--记录玩家是否胜利（是否通关）,通关为true，反之为false
GlobalVarFunc.isClearance = false
--毒瘤发育等级
GlobalVarFunc.duliuLevel = 0
--记录团队宝物书随机掉落的数量
GlobalVarFunc.baowushu_num = 0
--怪物狂暴了，攻击力+50%，当前波数的怪，持续120秒
GlobalVarFunc.MonsterViolent = 1
--金币投资奖励(随机事件)
GlobalVarFunc.GoldInvestmentRewards = 1
--竞技场是否打开
GlobalVarFunc.isOpenDoor = true
--弓魂投资/回合收入提升奖励
GlobalVarFunc.InvestmentAndOperate = {1.00,1.00,1.00,1.00,1.00,1.00}
--宝物回合收入奖励系数
GlobalVarFunc.OperateRewardCoefficient = {1.00,1.00,1.00,1.00,1.00,1.00}
--宝物投资收入奖励系数
GlobalVarFunc.InvestmentRewardCoefficient = {1.00,1.00,1.00,1.00,1.00,1.00}
--箭魂通关奖励系数
GlobalVarFunc.arrowSoulRewardCoefficient = {1.00,1.00,1.00,1.00,1.00,1.00}
--玩家宝物池子
GlobalVarFunc.player_treasure_list = {}
--单个玩家普通章节死亡游戏不结束，多1条命
GlobalVarFunc.singlePlayerLife = 1
--萝莉单位记录
GlobalVarFunc.Luoli = nil

-- <==============================全局函数================================>
-- 切割字符串为数组
function GlobalVarFunc:Split(sStr,sReps)
	local resultStrList = {}
    string.gsub(sStr,'[^'..sReps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

function RandFetch(list,num,poolSize,pool) -- list 存放筛选结果，num 筛取个数，poolSize 筛取源大小，pool 筛取源
	pool = pool or {}
	for i=1,num do
		local rand = RandomInt(i,poolSize)
		local tmp = pool[rand] or rand -- 对于第二个池子，序号跟id号是一致的
		pool[rand] = pool[i] or i
		pool[i] = tmp
		table.insert(list, tmp)
	end
end

function GlobalVarFunc:GloFunc_Getgame_enum()
    return game_enum
end

function GlobalVarFunc:OnOpenDoor()
	if GlobalVarFunc.isOpenDoor then
	    GlobalVarFunc.isOpenDoor = false
		local door = Entities:FindByName(nil,"door001open")
		local doorTirgger = Entities:FindByName(nil,"door001o")
		local v = door:GetOrigin(  )
		door:SetContextThink(DoUniqueString("open_the_door"), function ()
			v.z = v.z -15 
			door : SetOrigin(v)
			if v.z < -1000 then 
				doorTirgger:Trigger(nil,nil)
				return nil
			end
			return 0.01
		end, 0)
	end
end

--播放宝物，金币，木头 等音效（短音效）
function GlobalVarFunc:OnGameSound(soundName, nPlayerID)
	if nPlayerID == nil then
		if soundName == "baowubook_sound" then
			CustomGameEventManager:Send_ServerToAllClients("game_sound",{soundName = "custom_music.baowubook"})
		end
		if soundName == "miaojishi_sound" then
			CustomGameEventManager:Send_ServerToAllClients("game_sound",{soundName = "custom_music.miaojishi"})
		end
		if soundName == "siwang_sound" then
			CustomGameEventManager:Send_ServerToAllClients("game_sound",{soundName = "custom_music.siwang"})
		end
	else
		if soundName == "jinbi_sound" then
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"game_sound",{soundName = "custom_music.jinbi"})
		end
		if soundName == "mutou_sound" then
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"game_sound",{soundName = "custom_music.mutou"})
		end
	end
end

--随机播放boss音效
function GlobalVarFunc:OnRandomBossSound()
	if GlobalVarFunc.game_mode == "common" then

		local random = RandomInt(1,7)
		GlobalVarFunc.boss_sound = "custom_music.bossBgm_"..random
		
		if GlobalVarFunc.MonsterWave == 20 then
			GlobalVarFunc.boss_sound = "custom_music.boss_20"
		end

        CustomGameEventManager:Send_ServerToAllClients("boss_strat_sound",{soundName = GlobalVarFunc.boss_sound})
	end
end

--boss死亡停止音效
function GlobalVarFunc:OnStopBossSound()
    CustomGameEventManager:Send_ServerToAllClients("boss_stop_sound",{soundName = GlobalVarFunc.boss_sound})
end

--游戏结束类型   -3：初始值 -2：玩家全部阵亡  -1:野怪没清完  0：序章胜利  1：第一章胜利  2：第二章  3：第三章  4：第四-九章  5：第十-十二章  6：第十三章以及之后
function GlobalVarFunc:OnGameOverState(num)
    local game_info = CustomNetTables:GetTableValue( "gameInfo", "gameInfo" )
    game_info["gameOver_state"] = num
    CustomNetTables:SetTableValue( "gameInfo","gameInfo", game_info)
end